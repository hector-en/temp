#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable

FORBIDDEN = "/mnt/ingress/infra"
PASS = 0
WARN = 1
FAIL = 2


@dataclass
class Record:
    file: str
    line: int
    classification: str
    active_scope: str
    failure_reason: str


TEXT_EXTENSIONS = {
    ".md",
    ".txt",
    ".py",
    ".sh",
    ".yaml",
    ".yml",
    ".json",
    ".dot",
    ".toml",
}


def parse_args() -> argparse.Namespace:
  parser = argparse.ArgumentParser()
  parser.add_argument("--public-root", required=True)
  parser.add_argument("--private-root", required=True)
  parser.add_argument("--json", action="store_true", dest="json_output")
  return parser.parse_args()


def is_text_candidate(path: Path) -> bool:
    if path.is_dir():
        return False
    if path.suffix.lower() in TEXT_EXTENSIONS:
        return True
    return path.name in {"README", "README.md"}


def iter_paths(base: Path, entries: Iterable[str]) -> Iterable[tuple[str, Path]]:
    for entry in entries:
        root = base / entry
        if root.is_dir():
            for path in sorted(p for p in root.rglob("*") if p.is_file()):
                yield entry, path
        elif root.is_file():
            yield entry, root


def is_historical_path(private_root: Path, path: Path) -> bool:
    try:
        rel = path.relative_to(private_root)
    except ValueError:
        return False
    rel_str = rel.as_posix()
    if "sources/evidence_snapshots/" in rel_str:
        return True
    if path.name.endswith("_OLD.md") or path.suffix == ".old":
        return True
    if "generated/" in rel_str and ("historical" in rel_str or "public_private_contract_correction" in rel_str):
        return True
    return False


def cli_notes_dated_history(line_number: int, headings: list[tuple[int, str]]) -> bool:
    current_heading = ""
    for heading_line, heading_text in headings:
        if heading_line > line_number:
            break
        current_heading = heading_text
    if current_heading.startswith("## 20") and "—" in current_heading:
        return True
    return False


def classify_occurrence(path: Path, line_number: int, line: str, scope: str, private_root: Path, cli_headings: list[tuple[int, str]]) -> Record:
    if path.name == "check_forbidden_active_roots.py":
        return Record(str(path), line_number, "explicit-forbidden-root-warning", scope, "")
    if "forbidden-root" in line or "forbidden root" in line.lower():
        return Record(str(path), line_number, "explicit-forbidden-root-warning", scope, "")
    if path.name == "CLI_EXTRACTION_NOTES.md" and cli_notes_dated_history(line_number, cli_headings):
        return Record(str(path), line_number, "dated-historical-notes", scope, "")
    if is_historical_path(private_root, path):
        return Record(str(path), line_number, "immutable-historical-evidence", scope, "")
    if path.name.endswith("_OLD.md") or path.suffix == ".old":
        return Record(str(path), line_number, "superseded-file", scope, "")
    return Record(
        str(path),
        line_number,
        "active-execution-or-instruction-reference",
        scope,
        f"active scope still references forbidden root {FORBIDDEN}",
    )


def read_text(path: Path) -> list[str]:
    try:
        data = path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError:
        raise ValueError(f"Unreadable in-scope text file: {path}")
    return data


def scan(public_root: Path, private_root: Path) -> tuple[list[Record], list[str]]:
    records: list[Record] = []
    warnings: list[str] = []

    public_entries = [
        "scripts",
        "dots",
        "templates",
        "examples",
        "README.md",
        "infractl.md",
        "prompt_guide.md",
        "workflow.md",
        "infractl_workflow.md",
        "instructions.md",
    ]
    private_entries = [
        "project.yaml",
        "files.yaml",
        "hooks.yaml",
        "sources/workflow",
        "sources/implementation",
        "sources/specifications",
        "sources/companions",
    ]

    cli_notes_path = private_root / "sources/workflow/CLI_EXTRACTION_NOTES.md"
    cli_headings: list[tuple[int, str]] = []
    if cli_notes_path.exists():
        for idx, line in enumerate(read_text(cli_notes_path), start=1):
            if line.startswith("## "):
                cli_headings.append((idx, line.strip()))

    for scope, path in iter_paths(public_root, public_entries):
        if not is_text_candidate(path):
            continue
        lines = read_text(path)
        for idx, line in enumerate(lines, start=1):
            if FORBIDDEN in line:
                records.append(classify_occurrence(path, idx, line, f"public:{scope}", private_root, cli_headings))

    for scope, path in iter_paths(private_root, private_entries):
        if is_historical_path(private_root, path):
            if not is_text_candidate(path):
                continue
            lines = read_text(path)
            for idx, line in enumerate(lines, start=1):
                if FORBIDDEN in line:
                    records.append(classify_occurrence(path, idx, line, f"private:{scope}", private_root, cli_headings))
            continue
        if not is_text_candidate(path):
            continue
        lines = read_text(path)
        for idx, line in enumerate(lines, start=1):
            if FORBIDDEN in line:
                records.append(classify_occurrence(path, idx, line, f"private:{scope}", private_root, cli_headings))

    active_failures = [r for r in records if r.classification == "active-execution-or-instruction-reference"]
    if not records:
        warnings.append("No forbidden-root occurrences found in active scopes.")
    return active_failures + [r for r in records if r.classification != "active-execution-or-instruction-reference"], warnings


def main() -> int:
    args = parse_args()
    public_root = Path(args.public_root).resolve()
    private_root = Path(args.private_root).resolve()

    try:
        records, warnings = scan(public_root, private_root)
    except ValueError as exc:
        payload = {
            "status": "FAIL",
            "records": [],
            "warnings": warnings if "warnings" in locals() else [],
            "error": str(exc),
        }
        if args.json_output:
            print(json.dumps(payload, indent=2))
        else:
            print(f"FAIL {exc}")
        return FAIL

    status = "FAIL" if any(r.classification == "active-execution-or-instruction-reference" for r in records) else "PASS"
    code = FAIL if status == "FAIL" else PASS
    payload = {
        "status": status,
        "records": [asdict(r) for r in records],
        "warnings": warnings,
    }

    if args.json_output:
        print(json.dumps(payload, indent=2))
    else:
        print(status)
        for warning in warnings:
            print(f"WARN {warning}")
        for record in records:
            print(
                f"{record.classification} | {record.active_scope} | "
                f"{record.file}:{record.line} | {record.failure_reason}"
            )
    return code


if __name__ == "__main__":
    sys.exit(main())
