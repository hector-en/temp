
from pathlib import Path
import json, os

def load_data(path: Path):
    text = Path(path).read_text(encoding='utf-8')
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        try:
            import yaml  # type: ignore
            return yaml.safe_load(text)
        except Exception as exc:
            raise SystemExit(f"Cannot parse {path}. Use JSON-formatted YAML or install PyYAML. Error: {exc}")

def load_project(project_dir):
    root = Path(project_dir).resolve()
    data = {"root": root}
    for name in ["project.yaml", "layers.yaml", "batches.yaml", "hooks.yaml", "files.yaml"]:
        p = root / name
        if not p.exists():
            raise SystemExit(f"Missing required project file: {p}")
        data[name[:-5]] = load_data(p)
    return data

def batches(data, track=None):
    items = data.get('batches', {}).get('batches', [])
    if track:
        items = [b for b in items if b.get('track') == track]
    return items

def hooks(data):
    return data.get('hooks', {}).get('hooks', [])

def find_batch(data, batch_id, track=None):
    for b in batches(data, track):
        if str(b.get('id')) == str(batch_id):
            return b
    raise SystemExit(f"No batch found for id={batch_id!r} track={track!r}")

def source_entry(data, key):
    return data.get('files', {}).get('source_keys', {}).get(key)

def source_path(data, key, prefer_real=False, repo_root=None):
    ent = source_entry(data, key)
    if not ent:
        return None
    root = data['root']
    return root / ent.get('bundle_path','')

def source_status(data, key, repo_root=None):
    ent = source_entry(data, key)
    if not ent:
        return {"key": key, "known": False, "bundle_exists": False, "real_exists": False}
    bp = data['root'] / ent.get('bundle_path','')
    return {
        "key": key,
        "known": True,
        "required": bool(ent.get('required')),
        "bundle_path": str(bp),
        "bundle_exists": bp.exists(),
        "real_path": ent.get('real_path'),
        "real_exists": None,
    }

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
