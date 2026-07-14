from __future__ import annotations

import json
import re
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any


REQUIRED_PROJECT_FILES = (
    "project.yaml",
    "layers.yaml",
    "batches.yaml",
    "hooks.yaml",
    "files.yaml",
)
IGNORED_ARCHIVE_PREFIXES = ("__MACOSX/",)
IGNORED_ARCHIVE_PARTS = {".DS_Store"}
ROOT_VERSION_RE = re.compile(r"_real_v(?P<version>[0-9]+)$")
PROJECT_VERSION_RE = re.compile(r"^real-v(?P<version>[0-9]+)(?:\b|-)")
README_VERSION_RE = re.compile(r"\breal-v(?P<version>[0-9]+)\b")
COLLISION_SUFFIX_RE = re.compile(r"^(?P<stem>.+)\((?P<suffix>[1-9][0-9]*)\)(?P<ext>\.zip)$")


class PrivateSourceResolutionError(Exception):
    def __init__(self, payload: dict[str, Any]):
        super().__init__(payload.get("message", "private source resolution failed"))
        self.payload = payload


def load_text_data(text: str, origin: str):
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        try:
            import yaml  # type: ignore

            return yaml.safe_load(text)
        except Exception as exc:
            raise SystemExit(
                f"Cannot parse {origin}. Use JSON-formatted YAML or install PyYAML. Error: {exc}"
            )


def load_data(path: Path):
    text = Path(path).read_text(encoding="utf-8")
    return load_text_data(text, str(path))


def load_project(project_dir):
    root = Path(project_dir).resolve()
    data = {"root": root}
    for name in REQUIRED_PROJECT_FILES:
        path = root / name
        if not path.exists():
            raise SystemExit(f"Missing required project file: {path}")
        data[name[:-5]] = load_data(path)
    return data


def _error(
    code: str,
    message: str,
    *,
    source: Path | None = None,
    source_kind: str | None = None,
    diagnostics: list[dict[str, Any]] | None = None,
    partial: dict[str, Any] | None = None,
):
    payload: dict[str, Any] = {
        "status": "error",
        "code": code,
        "message": message,
        "diagnostics": diagnostics or [],
    }
    if source is not None:
        payload["physical_source"] = str(source)
    if source_kind is not None:
        payload["source_kind"] = source_kind
    if partial:
        payload.update(partial)
    raise PrivateSourceResolutionError(payload)


def _normalize_logical_zip_name(name: str) -> str:
    match = COLLISION_SUFFIX_RE.match(name)
    if match:
        return f"{match.group('stem')}{match.group('ext')}"
    return name


def _version_label(number: str | None) -> str | None:
    return f"v{number}" if number else None


def _version_from_root_name(name: str) -> str | None:
    match = ROOT_VERSION_RE.search(name)
    return _version_label(match.group("version")) if match else None


def _version_from_project_value(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    match = PROJECT_VERSION_RE.search(value.strip())
    return _version_label(match.group("version")) if match else None


def _readme_identity_version(text: str | None) -> str | None:
    if not text:
        return None
    head = "\n".join(text.splitlines()[:30])
    for line in head.splitlines():
        lowered = line.lower()
        if "real-v" not in lowered:
            continue
        if "bundle" in lowered or "private project data bundle" in lowered:
            match = README_VERSION_RE.search(line)
            if match:
                return _version_label(match.group("version"))
    return None


def _derive_output_root(private_bundle_version: str | None, explicit_output_root: str | None = None) -> str | None:
    if explicit_output_root:
        return explicit_output_root
    if not private_bundle_version:
        return None
    return f"/mnt/data/generated_real_{private_bundle_version}"


def _assert_matching_versions(
    signals: dict[str, str | None],
    *,
    source: Path,
    source_kind: str,
    partial: dict[str, Any] | None = None,
):
    present = {name: version for name, version in signals.items() if version}
    if not present:
        _error(
            "MISSING_REQUIRED_IDENTITY_SIGNAL",
            "No recognizable private bundle version signal was found.",
            source=source,
            source_kind=source_kind,
            diagnostics=[{"kind": "version_signals", "signals": signals}],
            partial=partial,
        )
    versions = set(present.values())
    if len(versions) != 1:
        _error(
            "PRIVATE_IDENTITY_MISMATCH",
            "Private bundle identity signals do not agree.",
            source=source,
            source_kind=source_kind,
            diagnostics=[{"kind": "version_signals", "signals": signals}],
            partial=partial,
        )
    return next(iter(versions))


def _project_file_set(root: Path) -> set[str]:
    return {name for name in REQUIRED_PROJECT_FILES if (root / name).exists()}


def _collection_candidates(root: Path) -> list[str]:
    candidates: list[str] = []
    for child in sorted(root.iterdir()):
        if child.is_dir() and _project_file_set(child) == set(REQUIRED_PROJECT_FILES):
            candidates.append(str(child))
        elif child.is_file() and child.suffix.lower() == ".zip":
            candidates.append(str(child))
    return candidates


def _read_first_existing_text(root: Path, names: list[str]) -> str | None:
    for name in names:
        path = root / name
        if path.exists() and path.is_file():
            return path.read_text(encoding="utf-8", errors="ignore")
    return None


def _resolve_direct_root(root: Path, *, source: Path) -> dict[str, Any]:
    missing = [name for name in REQUIRED_PROJECT_FILES if not (root / name).exists()]
    if missing:
        _error(
            "MISSING_REQUIRED_PROJECT_FILES",
            "Direct project root is missing required project files.",
            source=source,
            source_kind="direct-root",
            diagnostics=[{"kind": "missing_required_files", "missing": missing}],
            partial={"resolved_root": str(root), "root_basename": root.name},
        )
    project_data = load_data(root / "project.yaml")
    readme_text = _read_first_existing_text(root, ["README_PRIVATE_BUNDLE.md", "README.md"])
    signals = {
        "root_basename_version": _version_from_root_name(root.name),
        "project_version": _version_from_project_value(project_data.get("version")),
        "readme_version": _readme_identity_version(readme_text),
    }
    verified_version = _assert_matching_versions(
        signals,
        source=source,
        source_kind="direct-root",
        partial={"resolved_root": str(root), "root_basename": root.name},
    )
    return {
        "status": "pass",
        "source_kind": "direct-root",
        "physical_source": str(source),
        "logical_source_name": None,
        "logical_source_stem": None,
        "resolved_root": str(root),
        "root_basename": root.name,
        "archive_root_basename": None,
        "selected_project_root": str(root),
        "signal_versions": {
            "archive_filename_version": None,
            "archive_root_version": None,
            "resolved_root_version": signals["root_basename_version"],
            "project_metadata_version": signals["project_version"],
            "readme_version": signals["readme_version"],
        },
        "verified_private_bundle_version": verified_version,
        "default_output_root": _derive_output_root(verified_version),
        "diagnostics": [],
    }


def _ignored_archive_entry(name: str) -> bool:
    if not name:
        return True
    if any(name.startswith(prefix) for prefix in IGNORED_ARCHIVE_PREFIXES):
        return True
    return any(part in IGNORED_ARCHIVE_PARTS for part in PurePosixPath(name).parts)


def _zip_required_files(zf: zipfile.ZipFile, root_name: str) -> tuple[dict[str, str], str | None]:
    entries = [info.filename for info in zf.infolist() if not _ignored_archive_entry(info.filename)]
    file_entries = [name for name in entries if not name.endswith("/")]
    root_level_files = [name for name in file_entries if len(PurePosixPath(name).parts) < 2]
    top_dirs = {PurePosixPath(name).parts[0] for name in file_entries if len(PurePosixPath(name).parts) >= 2}
    if root_level_files:
        return {}, "ZIP contains substantive root-level files instead of exactly one project directory."
    if len(top_dirs) != 1:
        return {}, "ZIP must contain exactly one substantive top-level project directory."
    top_dir = next(iter(top_dirs))
    required = {name: f"{top_dir}/{name}" for name in REQUIRED_PROJECT_FILES}
    missing = [name for name, member in required.items() if member not in file_entries]
    if missing:
        return {}, f"ZIP project root is missing required project files: {', '.join(missing)}"
    return required, None


def _read_zip_text(zf: zipfile.ZipFile, member: str) -> str:
    return zf.read(member).decode("utf-8", errors="ignore")


def _read_zip_readme(zf: zipfile.ZipFile, root_name: str) -> str | None:
    for name in [f"{root_name}/README_PRIVATE_BUNDLE.md", f"{root_name}/README.md"]:
        try:
            return _read_zip_text(zf, name)
        except KeyError:
            continue
    return None


def _resolve_zip_source(source: Path) -> dict[str, Any]:
    physical_name = source.name
    logical_name = _normalize_logical_zip_name(physical_name)
    logical_stem = Path(logical_name).stem
    archive_filename_version = _version_from_root_name(logical_stem)

    with zipfile.ZipFile(source) as zf:
        required_members, error_message = _zip_required_files(zf, logical_stem)
        if error_message:
            _error(
                "INVALID_ZIP_ROOT_SHAPE",
                error_message,
                source=source,
                source_kind="zip",
                partial={
                    "logical_source_name": logical_name,
                    "logical_source_stem": logical_stem,
                },
            )

        archive_root_basename = next(iter({member.split("/", 1)[0] for member in required_members.values()}))
        project_data = load_text_data(
            _read_zip_text(zf, required_members["project.yaml"]),
            f"{source}!/{required_members['project.yaml']}",
        )
        readme_text = _read_zip_readme(zf, archive_root_basename)

    signals = {
        "archive_filename_version": archive_filename_version,
        "archive_root_version": _version_from_root_name(archive_root_basename),
        "project_metadata_version": _version_from_project_value(project_data.get("version")),
        "readme_version": _readme_identity_version(readme_text),
    }
    verified_version = _assert_matching_versions(
        signals,
        source=source,
        source_kind="zip",
        partial={
            "logical_source_name": logical_name,
            "logical_source_stem": logical_stem,
            "archive_root_basename": archive_root_basename,
        },
    )
    return {
        "status": "pass",
        "source_kind": "zip",
        "physical_source": str(source),
        "logical_source_name": logical_name,
        "logical_source_stem": logical_stem,
        "resolved_root": archive_root_basename,
        "root_basename": archive_root_basename,
        "archive_root_basename": archive_root_basename,
        "selected_project_root": None,
        "signal_versions": {
            "archive_filename_version": signals["archive_filename_version"],
            "archive_root_version": signals["archive_root_version"],
            "resolved_root_version": None,
            "project_metadata_version": signals["project_metadata_version"],
            "readme_version": signals["readme_version"],
        },
        "verified_private_bundle_version": verified_version,
        "default_output_root": _derive_output_root(verified_version),
        "diagnostics": [],
    }


def _compare_zip_with_project_root(zip_info: dict[str, Any], project_root: Path, source: Path):
    direct_info = _resolve_direct_root(project_root, source=project_root)
    comparisons = {
        "archive_root_basename": zip_info.get("archive_root_basename"),
        "extracted_root_basename": direct_info.get("root_basename"),
        "archive_project_metadata_version": zip_info["signal_versions"].get("project_metadata_version"),
        "extracted_project_metadata_version": direct_info["signal_versions"].get("project_metadata_version"),
        "archive_readme_version": zip_info["signal_versions"].get("readme_version"),
        "extracted_readme_version": direct_info["signal_versions"].get("readme_version"),
        "verified_private_bundle_version": zip_info.get("verified_private_bundle_version"),
        "extracted_verified_private_bundle_version": direct_info.get("verified_private_bundle_version"),
    }
    mismatches = []
    if zip_info.get("archive_root_basename") != direct_info.get("root_basename"):
        mismatches.append("root basename")
    if zip_info["signal_versions"].get("project_metadata_version") != direct_info["signal_versions"].get(
        "project_metadata_version"
    ):
        mismatches.append("project.yaml.version")
    zip_readme = zip_info["signal_versions"].get("readme_version")
    direct_readme = direct_info["signal_versions"].get("readme_version")
    if zip_readme and direct_readme and zip_readme != direct_readme:
        mismatches.append("README identity")
    if zip_info.get("verified_private_bundle_version") != direct_info.get("verified_private_bundle_version"):
        mismatches.append("verified private bundle version")
    if mismatches:
        _error(
            "PRIVATE_IDENTITY_MISMATCH",
            "ZIP identity does not agree with the supplied extracted project root.",
            source=source,
            source_kind="zip",
            diagnostics=[{"kind": "zip_vs_project_root", "comparisons": comparisons, "mismatches": mismatches}],
            partial={
                "logical_source_name": zip_info.get("logical_source_name"),
                "archive_root_basename": zip_info.get("archive_root_basename"),
                "resolved_root": str(project_root),
            },
        )
    zip_info["resolved_root"] = str(project_root)
    zip_info["selected_project_root"] = str(project_root)
    zip_info["root_basename"] = project_root.name
    zip_info["signal_versions"]["resolved_root_version"] = direct_info["signal_versions"].get("resolved_root_version")
    return zip_info


def resolve_private_source(source, project_root=None):
    source_path = Path(source).resolve()
    if not source_path.exists():
        _error(
            "PRIVATE_SOURCE_NOT_FOUND",
            "Selected private source does not exist.",
            source=source_path,
            diagnostics=[{"kind": "missing_source", "path": str(source_path)}],
        )

    if source_path.is_file():
        if source_path.suffix.lower() != ".zip":
            _error(
                "UNSUPPORTED_PRIVATE_SOURCE",
                "Selected private source file must be a .zip archive.",
                source=source_path,
                source_kind="zip",
            )
        info = _resolve_zip_source(source_path)
        if project_root is not None:
            info = _compare_zip_with_project_root(info, Path(project_root).resolve(), source_path)
        return info

    if source_path.is_dir() and _project_file_set(source_path) == set(REQUIRED_PROJECT_FILES):
        info = _resolve_direct_root(source_path, source=source_path)
        if project_root is not None and source_path != Path(project_root).resolve():
            direct_info = _resolve_direct_root(Path(project_root).resolve(), source=Path(project_root).resolve())
            if direct_info.get("root_basename") != info.get("root_basename") or direct_info.get(
                "verified_private_bundle_version"
            ) != info.get("verified_private_bundle_version"):
                _error(
                    "PRIVATE_IDENTITY_MISMATCH",
                    "Selected direct project root does not agree with the supplied comparison root.",
                    source=source_path,
                    source_kind="direct-root",
                    diagnostics=[
                        {
                            "kind": "direct_root_comparison",
                            "selected_root": info.get("resolved_root"),
                            "comparison_root": direct_info.get("resolved_root"),
                            "selected_version": info.get("verified_private_bundle_version"),
                            "comparison_version": direct_info.get("verified_private_bundle_version"),
                        }
                    ],
                )
        return info

    if source_path.is_dir():
        candidates = _collection_candidates(source_path)
        if candidates:
            code = "AMBIGUOUS_PRIVATE_SOURCE_COLLECTION" if len(candidates) > 1 else "EXPLICIT_SOURCE_REQUIRED"
            _error(
                code,
                "Selected path is a collection of possible private sources. Choose one ZIP or one direct project root explicitly.",
                source=source_path,
                diagnostics=[{"kind": "source_collection", "candidates": candidates}],
            )
        _error(
            "INVALID_PRIVATE_SOURCE_ROOT",
            "Selected directory is not a private project root and contains no explicit selectable private source.",
            source=source_path,
            diagnostics=[{"kind": "missing_required_files", "missing": list(REQUIRED_PROJECT_FILES)}],
        )

    _error(
        "UNSUPPORTED_PRIVATE_SOURCE",
        "Selected private source is neither a supported ZIP archive nor a direct project root.",
        source=source_path,
    )


def derive_output_root(private_bundle_version: str | None, explicit_output_root: str | None = None) -> str | None:
    return _derive_output_root(private_bundle_version, explicit_output_root)


def batches(data, track=None):
    items = data.get("batches", {}).get("batches", [])
    if track:
        items = [item for item in items if item.get("track") == track]
    return items


def hooks(data):
    return data.get("hooks", {}).get("hooks", [])


def find_batch(data, batch_id, track=None):
    for item in batches(data, track):
        if str(item.get("id")) == str(batch_id):
            return item
    raise SystemExit(f"No batch found for id={batch_id!r} track={track!r}")


def source_entry(data, key):
    return data.get("files", {}).get("source_keys", {}).get(key)


def source_path(data, key, prefer_real=False, repo_root=None):
    entry = source_entry(data, key)
    if not entry:
        return None
    return data["root"] / entry.get("bundle_path", "")


def _looks_placeholder(path: Path) -> bool:
    if not path.exists() or not path.is_file():
        return False
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return False
    prefix = text[:1200].lower()
    markers = (
        "# placeholder for real-workspace source",
        "actual file content was not mounted",
        "placeholder-only source",
    )
    return any(marker in prefix for marker in markers)


def source_status(data, key, repo_root=None):
    entry = source_entry(data, key)
    if not entry:
        return {
            "key": key,
            "known": False,
            "required": False,
            "bundle_exists": False,
            "placeholder": False,
            "substantive": False,
            "real_exists": None,
        }
    path = data["root"] / entry.get("bundle_path", "")
    exists = path.exists()
    placeholder = _looks_placeholder(path) if exists else False
    content_gate = entry.get("content_gate")
    substantive = bool(exists and not placeholder)
    return {
        "key": key,
        "known": True,
        "required": bool(entry.get("required")),
        "content_gate": content_gate,
        "bundle_path": str(path),
        "bundle_exists": exists,
        "placeholder": placeholder,
        "substantive": substantive,
        "real_path": entry.get("real_path"),
        "real_exists": None,
    }


def hook_map(data):
    return {item.get("id"): item for item in hooks(data)}


def collect_source_keys(data, batch):
    keys = list(batch.get("required_sources", []))
    mapping = hook_map(data)
    unknown_hooks = []
    for hook_id in batch.get("required_hooks", []):
        hook = mapping.get(hook_id)
        if not hook:
            unknown_hooks.append(hook_id)
            continue
        keys.extend(hook.get("source_keys", []))
    unique = []
    for key in keys:
        if key not in unique:
            unique.append(key)
    return unique, unknown_hooks


def selected_source_statuses(data, batch, repo_root=None):
    keys, unknown_hooks = collect_source_keys(data, batch)
    return [source_status(data, key, repo_root) for key in keys], unknown_hooks


def checked(record):
    lifecycle = record.get("lifecycle", {})
    return (
        lifecycle.get("implementation") == "completed"
        and lifecycle.get("evidence") == "checked"
        and lifecycle.get("stability") == "stable"
    )


def route_preflight(data, batch, mode):
    errors = []
    track = batch.get("track")
    batch_id = str(batch.get("id"))
    lifecycle = batch.get("lifecycle", {})
    route_gate = batch.get("route_gate", {})

    if lifecycle.get("registration") != "registered":
        errors.append({"code": "NOT_REGISTERED", "track": track, "batch": batch_id})

    if mode == "create":
        if checked(batch) or route_gate.get("request_create") == "blocked-already-implemented":
            errors.append({"code": "ALREADY_IMPLEMENTED_USE_UPDATE", "track": track, "batch": batch_id})

        for dep_id in batch.get("depends_on_skeleton", []):
            try:
                dep = find_batch(data, dep_id, "skeleton")
            except SystemExit:
                errors.append({"code": "UNKNOWN_SKELETON_DEPENDENCY", "dependency": dep_id})
                continue
            if not checked(dep):
                errors.append({"code": "UNCHECKED_SKELETON_DEPENDENCY", "dependency": dep_id})

        for dep_id in batch.get("depends_on_organs", []):
            try:
                dep = find_batch(data, dep_id, "organ")
            except SystemExit:
                errors.append({"code": "UNKNOWN_ORGAN_DEPENDENCY", "dependency": dep_id})
                continue
            if not checked(dep):
                errors.append({"code": "UNCHECKED_ORGAN_DEPENDENCY", "dependency": dep_id})

        if track == "organ" and batch.get("transition_gate") == "skeleton-complete-after-batch-24":
            incomplete = [item.get("id") for item in batches(data, "skeleton") if not checked(item)]
            if incomplete:
                errors.append({"code": "SKELETON_COMPLETE_GATE_NOT_MET", "incomplete": incomplete})

    elif mode == "update":
        if lifecycle.get("implementation") != "completed":
            errors.append({"code": "UPDATE_REQUIRES_IMPLEMENTED_TARGET", "track": track, "batch": batch_id})

    return errors


def public_tool_status(public_tool_root):
    root = Path(public_tool_root).resolve()
    required = [
        ("README.md", root / "README.md"),
        ("infractl.md", root / "infractl.md"),
        ("infractl package", root / "infractl"),
        ("infractl/cli.py", root / "infractl" / "cli.py"),
        ("infractl/project.py", root / "infractl" / "project.py"),
        ("dots/", root / "dots"),
        (
            "dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot",
            root / "dots" / "infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot",
        ),
    ]
    return [
        {
            "kind": "public_tool_check",
            "name": name,
            "path": str(path),
            "exists": path.exists(),
            "required": True,
        }
        for name, path in required
    ]
