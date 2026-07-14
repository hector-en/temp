from __future__ import annotations

import io
import json
import tempfile
import unittest
import zipfile
from contextlib import redirect_stdout
from pathlib import Path

from infractl.cli import main
from infractl.project import PrivateSourceResolutionError, derive_output_root, resolve_private_source


def write_project(root: Path, version: str, readme_version: str, extra_readme_lines: list[str] | None = None):
    root.mkdir(parents=True, exist_ok=True)
    project = {
        "project_id": "agentfield-grn",
        "name": "Agentfield GRN Infra-Skeleton",
        "version": version,
        "paths": {
            "private_bundle_root": ".",
            "source_root": "sources",
            "generated_root": "generated",
        },
    }
    for name, payload in {
        "project.yaml": project,
        "batches.yaml": {"batches": []},
        "files.yaml": {"source_keys": {}},
        "hooks.yaml": {"hooks": []},
        "layers.yaml": {"layers": []},
    }.items():
        (root / name).write_text(json.dumps(payload, indent=2), encoding="utf-8")
    readme_lines = [
        f"# agentfield-grn-private real-{readme_version} bundle",
        "",
        f"Private project data bundle for `infractl` real-{readme_version}.",
    ]
    if extra_readme_lines:
        readme_lines.extend(["", *extra_readme_lines])
    (root / "README_PRIVATE_BUNDLE.md").write_text("\n".join(readme_lines) + "\n", encoding="utf-8")
    (root / "sources").mkdir(exist_ok=True)


def make_zip(source_root: Path, zip_path: Path):
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(source_root.rglob("*")):
            if path.is_file():
                zf.write(path, path.relative_to(source_root.parent))


def minimal_public_root(root: Path):
    (root / "infractl").mkdir(parents=True, exist_ok=True)
    (root / "dots").mkdir(parents=True, exist_ok=True)
    for rel in [
        "README.md",
        "infractl.md",
        "infractl/cli.py",
        "infractl/project.py",
        "dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot",
    ]:
        path = root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("ok\n", encoding="utf-8")


class PrivateIdentityTests(unittest.TestCase):
    def test_valid_v1_zip(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            root = tmp_path / "agentfield-grn-private_real_v1"
            zip_path = tmp_path / "agentfield-grn-private_real_v1.zip"
            write_project(root, "real-v1-batch04", "v1")
            make_zip(root, zip_path)

            result = resolve_private_source(zip_path)

            self.assertEqual(result["status"], "pass")
            self.assertEqual(result["verified_private_bundle_version"], "v1")
            self.assertEqual(result["default_output_root"], "/mnt/data/generated_real_v1")

    def test_valid_future_v2_zip(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            root = tmp_path / "agentfield-grn-private_real_v2"
            zip_path = tmp_path / "agentfield-grn-private_real_v2.zip"
            write_project(root, "real-v2-batch04", "v2")
            make_zip(root, zip_path)

            result = resolve_private_source(zip_path)

            self.assertEqual(result["verified_private_bundle_version"], "v2")
            self.assertEqual(result["default_output_root"], "/mnt/data/generated_real_v2")

    def test_multiple_candidates_require_explicit_selection(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            write_project(tmp_path / "agentfield-grn-private_real_v1", "real-v1-batch04", "v1")
            write_project(tmp_path / "agentfield-grn-private_real_v2", "real-v2-batch04", "v2")

            with self.assertRaises(PrivateSourceResolutionError) as ctx:
                resolve_private_source(tmp_path)

            self.assertEqual(ctx.exception.payload["code"], "AMBIGUOUS_PRIVATE_SOURCE_COLLECTION")

    def test_filename_root_metadata_mismatch_stops(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            root = tmp_path / "agentfield-grn-private_real_v0"
            zip_path = tmp_path / "agentfield-grn-private_real_v1.zip"
            write_project(root, "real-v0-batch04", "v0")
            make_zip(root, zip_path)

            with self.assertRaises(PrivateSourceResolutionError) as ctx:
                resolve_private_source(zip_path)

            self.assertEqual(ctx.exception.payload["code"], "PRIVATE_IDENTITY_MISMATCH")

    def test_valid_direct_root(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "agentfield-grn-private_real_v1"
            write_project(root, "real-v1-batch04", "v1")

            result = resolve_private_source(root)

            self.assertEqual(result["source_kind"], "direct-root")
            self.assertEqual(result["verified_private_bundle_version"], "v1")

    def test_missing_source(self):
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(PrivateSourceResolutionError) as ctx:
                resolve_private_source(Path(tmp) / "missing.zip")

            self.assertEqual(ctx.exception.payload["code"], "PRIVATE_SOURCE_NOT_FOUND")

    def test_validate_real_layout_uses_version_aware_mode(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            public_root = tmp_path / "public"
            private_root = tmp_path / "agentfield-grn-private_real_v1"
            minimal_public_root(public_root)
            write_project(private_root, "real-v1-batch04", "v1")

            stdout = io.StringIO()
            with redirect_stdout(stdout):
                main(
                    [
                        "validate-real-layout",
                        "--project",
                        str(private_root),
                        "--public-tool-root",
                        str(public_root),
                    ]
                )
            text = stdout.getvalue()

            self.assertIn('"mode": "two-root-version-aware"', text)
            self.assertIn('"verified_private_bundle_version": "v1"', text)

    def test_collision_suffix_zip_name_normalizes(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            root = tmp_path / "agentfield-grn-private_real_v1"
            zip_path = tmp_path / "agentfield-grn-private_real_v1(3).zip"
            write_project(root, "real-v1-batch04", "v1")
            make_zip(root, zip_path)

            result = resolve_private_source(zip_path)

            self.assertEqual(result["logical_source_name"], "agentfield-grn-private_real_v1.zip")
            self.assertEqual(result["verified_private_bundle_version"], "v1")

    def test_output_root_override_wins(self):
        self.assertEqual(derive_output_root("v1"), "/mnt/data/generated_real_v1")
        self.assertEqual(derive_output_root("v2"), "/mnt/data/generated_real_v2")
        self.assertEqual(derive_output_root("v2", "/tmp/custom-out"), "/tmp/custom-out")

    def test_historical_v0_text_does_not_override_selected_v2(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            root = tmp_path / "agentfield-grn-private_real_v2"
            zip_path = tmp_path / "agentfield-grn-private_real_v2.zip"
            write_project(
                root,
                "real-v2-batch04",
                "v2",
                extra_readme_lines=[
                    "Historical note: older exports used agentfield-grn-private_real_v0.zip.",
                    "Historical note: previous bundle was real-v0.",
                ],
            )
            make_zip(root, zip_path)

            result = resolve_private_source(zip_path)

            self.assertEqual(result["verified_private_bundle_version"], "v2")


if __name__ == "__main__":
    unittest.main()
