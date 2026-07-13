from pathlib import Path
import json


def load_data(path: Path):
    text = Path(path).read_text(encoding="utf-8")
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        try:
            import yaml  # type: ignore
            return yaml.safe_load(text)
        except Exception as exc:
            raise SystemExit(
                f"Cannot parse {path}. Use JSON-formatted YAML or install PyYAML. Error: {exc}"
            )


def load_project(project_dir):
    root = Path(project_dir).resolve()
    data = {"root": root}
    for name in ["project.yaml", "layers.yaml", "batches.yaml", "hooks.yaml", "files.yaml"]:
        path = root / name
        if not path.exists():
            raise SystemExit(f"Missing required project file: {path}")
        data[name[:-5]] = load_data(path)
    return data


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
