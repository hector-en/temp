from pathlib import Path
import argparse
import json

from .project import (
    batches,
    find_batch,
    hooks,
    load_project,
    public_tool_status,
    route_preflight,
    selected_source_statuses,
    source_status,
)
from .profiles import PROFILES, validate_profile
from .render import write_request
from .pack import package
from .evidence import check_evidence, missing_required_evidence


def print_json(value):
    print(json.dumps(value, indent=2, default=str))


def blocking_source_statuses(statuses):
    return [
        status
        for status in statuses
        if not status.get("known")
        or not status.get("bundle_exists")
        or status.get("placeholder")
        or (status.get("content_gate") and not status.get("substantive"))
    ]


def main(argv=None):
    parser = argparse.ArgumentParser(prog="infractl")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("profiles")
    for command in ["list-batches", "list-hooks", "status"]:
        item = sub.add_parser(command)
        item.add_argument("--project", required=True)
        item.add_argument("--track")
        item.add_argument("--repo-root")
        item.add_argument("--allow-bundle-fallback", action="store_true")
    item = sub.add_parser("check-required-files")
    item.add_argument("--project", required=True)
    item.add_argument("--track", required=True)
    item.add_argument("--batch")
    item.add_argument("--repo-root")
    item.add_argument("--allow-bundle-fallback", action="store_true")
    item = sub.add_parser("validate-real-layout")
    item.add_argument("--project", required=True)
    item.add_argument("--public-tool-root")
    item.add_argument("--repo-root", help="Deprecated compatibility alias for --public-tool-root.")
    item.add_argument("--allow-bundle-fallback", action="store_true")
    item = sub.add_parser("explain-batch")
    item.add_argument("--project", required=True)
    item.add_argument("--track")
    item.add_argument("--batch", required=True)
    for command in ["request-create", "request-update"]:
        item = sub.add_parser(command)
        item.add_argument("--project", required=True)
        item.add_argument("--track", required=True)
        item.add_argument("--batch", required=True)
        item.add_argument("--topic", default="manual")
        item.add_argument("--profile", default="webchat-sandbox")
        item.add_argument("--out", required=True)
        item.add_argument("--extra-source", action="append", default=[])
        item.add_argument("--repo-root")
    item = sub.add_parser("package-codex-create")
    item.add_argument("--input", required=True)
    item.add_argument("--out", required=True)
    item = sub.add_parser("package-codex-update")
    item.add_argument("--input", required=True)
    item.add_argument("--out", required=True)
    item = sub.add_parser("check-evidence")
    item.add_argument("--project", required=True)
    item.add_argument("--track", required=True)
    item.add_argument("--batch", required=True)
    args = parser.parse_args(argv)

    if args.cmd == "profiles":
        print_json(PROFILES)
        return
    if args.cmd.startswith("package-codex"):
        kind = "create" if args.cmd.endswith("create") else "update"
        print(package(args.input, args.out, kind))
        return

    data = load_project(args.project)
    if args.cmd == "list-batches":
        for batch in batches(data, args.track):
            lifecycle = batch.get("lifecycle", {})
            print(
                f"{batch.get('track')} {batch.get('id')} {batch.get('slug')} "
                f"status={batch.get('status')} implementation={lifecycle.get('implementation')} "
                f"| {batch.get('scope')}"
            )
    elif args.cmd == "list-hooks":
        for hook in hooks(data):
            print(
                f"{hook.get('id')} {hook.get('anx')} applies={','.join(hook.get('applies_to', []))} "
                f"| {hook.get('purpose')}"
            )
    elif args.cmd == "explain-batch":
        print_json(find_batch(data, args.batch, args.track))
    elif args.cmd == "check-required-files":
        selected = [find_batch(data, args.batch, args.track)] if args.batch else batches(data, args.track)
        all_statuses = {}
        unknown_hooks = []
        for batch in selected:
            statuses, missing_hooks = selected_source_statuses(data, batch, args.repo_root)
            unknown_hooks.extend({"batch": batch.get("id"), "hook": hook} for hook in missing_hooks)
            for status in statuses:
                all_statuses[status["key"]] = status
        for status in all_statuses.values():
            print_json(status)
        blocking = blocking_source_statuses(list(all_statuses.values()))
        if unknown_hooks or blocking:
            print_json(
                {
                    "error": "SELECTED_SOURCE_CLOSURE_FAILED",
                    "unknown_hooks": unknown_hooks,
                    "blocking_sources": blocking,
                }
            )
            raise SystemExit(2)
    elif args.cmd == "validate-real-layout":
        public_root = Path(args.public_tool_root or args.repo_root or Path.cwd()).resolve()
        public_failures = []
        private_failures = []
        print_json(
            {
                "kind": "contract_roots",
                "public_tool_root": str(public_root),
                "private_project_root": str(data["root"]),
                "mode": "two-root-v0",
            }
        )
        for status in public_tool_status(public_root):
            print_json(status)
            if status.get("required") and not status.get("exists"):
                public_failures.append(status["name"])
        for name in ["project.yaml", "layers.yaml", "batches.yaml", "hooks.yaml", "files.yaml", "sources/"]:
            path = data["root"] / name.rstrip("/")
            status = {
                "kind": "private_project_check",
                "name": name,
                "path": str(path),
                "exists": path.exists(),
                "required": True,
            }
            print_json(status)
            if not path.exists():
                private_failures.append(name)
        missing_global = []
        for key, entry in data.get("files", {}).get("source_keys", {}).items():
            if not entry.get("required"):
                continue
            status = source_status(data, key, args.repo_root)
            print_json(status)
            if not status.get("bundle_exists") or status.get("placeholder"):
                missing_global.append(key)
        if public_failures or private_failures or missing_global:
            print_json(
                {
                    "error": "INVALID_PUBLIC_PRIVATE_CONTRACT",
                    "missing_required_keys": missing_global,
                    "missing_public_paths": public_failures,
                    "missing_private_paths": private_failures,
                }
            )
            raise SystemExit(2)
    elif args.cmd in ["request-create", "request-update"]:
        validate_profile(args.profile)
        batch = find_batch(data, args.batch, args.track)
        mode = "create" if args.cmd == "request-create" else "update"
        errors = route_preflight(data, batch, mode)
        if errors:
            print_json({"error": "ROUTE_PREFLIGHT_FAILED", "details": errors})
            raise SystemExit(2)
        statuses, unknown_hooks = selected_source_statuses(data, batch, args.repo_root)
        blocking = blocking_source_statuses(statuses)
        if unknown_hooks or blocking:
            print_json(
                {
                    "error": "SELECTED_SOURCE_CLOSURE_FAILED",
                    "unknown_hooks": unknown_hooks,
                    "blocking_sources": blocking,
                }
            )
            raise SystemExit(2)
        if mode == "update":
            missing = missing_required_evidence(data, batch)
            if missing:
                print_json(
                    {
                        "error": "MISSING_UPDATE_BASELINE_EVIDENCE",
                        "track": args.track,
                        "batch": args.batch,
                        "missing": [
                            {"name": row["name"], "path": str(row["path"])} for row in missing
                        ],
                    }
                )
                raise SystemExit(2)
        root, archive = write_request(
            data,
            batch,
            mode,
            args.topic,
            args.profile,
            args.out,
            args.extra_source,
            args.repo_root,
        )
        print(root)
        print(archive)
    elif args.cmd == "check-evidence":
        batch = find_batch(data, args.batch, args.track)
        missing = False
        for row in check_evidence(data, batch):
            label = "required" if row["required"] else "conditional"
            print(f"{row['name']}: {'OK' if row['exists'] else 'MISSING'} ({label}) {row['path']}")
            if row["required"] and not row["exists"]:
                missing = True
        if missing:
            raise SystemExit(2)
    elif args.cmd == "status":
        print(f"Project: {data['project'].get('name')} ({data['project'].get('version')})")
        for batch in batches(data, args.track):
            print(
                f"{batch.get('track')} {batch.get('id')} {batch.get('slug')} "
                f"status={batch.get('status')} profiles={','.join(data['project'].get('supported_profiles', []))}"
            )


if __name__ == "__main__":
    main()
