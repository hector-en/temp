from pathlib import Path
import json
import shutil

from .project import route_preflight, selected_source_statuses, source_path
from .pack import zip_dir
from .evidence import check_evidence, missing_required_evidence


def safe_name(value):
    return "".join(c if c.isalnum() or c in "-_." else "-" for c in str(value)).strip("-")


def _blocking_source_statuses(statuses):
    return [
        status
        for status in statuses
        if not status.get("known")
        or not status.get("bundle_exists")
        or status.get("placeholder")
        or (status.get("content_gate") and not status.get("substantive"))
    ]


def write_request(data, batch, mode, topic, profile, out_dir, extra_sources=None, repo_root=None):
    extra_sources = extra_sources or []
    slug = batch["slug"]
    track = batch.get("track", "skeleton")
    batch_id = batch["id"]
    topic = safe_name(topic or "manual")

    preflight_errors = route_preflight(data, batch, mode)
    if preflight_errors:
        raise SystemExit(json.dumps({"error": "ROUTE_PREFLIGHT_FAILED", "details": preflight_errors}, indent=2))

    statuses, unknown_hooks = selected_source_statuses(data, batch, repo_root)
    blocking_sources = _blocking_source_statuses(statuses)
    if unknown_hooks or blocking_sources:
        raise SystemExit(
            json.dumps(
                {
                    "error": "SELECTED_SOURCE_CLOSURE_FAILED",
                    "unknown_hooks": unknown_hooks,
                    "blocking_sources": blocking_sources,
                },
                indent=2,
                default=str,
            )
        )

    if mode == "update":
        missing_evidence = missing_required_evidence(data, batch)
        if missing_evidence:
            raise SystemExit(
                json.dumps(
                    {
                        "error": "MISSING_UPDATE_BASELINE_EVIDENCE",
                        "track": track,
                        "batch": batch_id,
                        "missing": [
                            {"name": row["name"], "path": str(row["path"])}
                            for row in missing_evidence
                        ],
                    },
                    indent=2,
                )
            )

    name = f"request_{mode}_{track}_{batch_id}_{slug}_{topic}"
    root = Path(out_dir) / name
    zip_path = root.with_suffix(".zip")
    if root.exists() or zip_path.exists():
        raise SystemExit(f"Refusing to overwrite existing request output: {root} or {zip_path}")

    root.mkdir(parents=True, exist_ok=False)
    source_root = root / "source_bundle"
    source_root.mkdir(exist_ok=True)
    copied = []
    for status in statuses:
        path = source_path(data, status["key"], prefer_real=False)
        if path and path.exists():
            destination = source_root / "sources" / path.name
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, destination)
            copied.append(str(destination.relative_to(root)))

    extra_dir = source_root / "extra_sources"
    extra_dir.mkdir(parents=True, exist_ok=True)
    extra_copied = []
    for item in extra_sources:
        source = Path(item)
        if not source.exists():
            extra_copied.append(f"MISSING:{item}")
            continue
        destination = extra_dir / source.name
        if source.is_dir():
            shutil.copytree(source, destination)
        else:
            shutil.copy2(source, destination)
        extra_copied.append(str(destination.relative_to(root)))

    manifest = {
        "mode": mode,
        "profile": profile,
        "track": track,
        "batch": batch_id,
        "slug": slug,
        "topic": topic,
        "source_keys": [status["key"] for status in statuses],
        "copied_sources": copied,
        "extra_sources": extra_copied,
        "safety": "deterministic request only; extra sources candidate only; no real workspace mutation",
    }
    (root / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    required_lines = [f"# Required inputs for {mode} {track} {batch_id} {slug}\n"]
    for status in statuses:
        required_lines.append(
            f"- {status['key']}: bundle=OK | substantive={'yes' if status.get('substantive') else 'no'} "
            f"| real={status.get('real_path')} | selected_batch_required=yes"
        )
    (root / "REQUIRED_INPUTS.md").write_text("\n".join(required_lines) + "\n", encoding="utf-8")

    context = [
        "# Selected context manifest\n",
        f"Mode: `{mode}`",
        f"Profile: `{profile}`",
        f"Track: `{track}`",
        f"Batch: `{batch_id}` `{slug}`",
        f"Topic: `{topic}`",
        "",
        "## Batch scope",
        batch.get("scope", ""),
        "",
        "## Lifecycle",
        json.dumps(batch.get("lifecycle", {}), indent=2),
        "",
        "## Smoke domains",
        "\n".join("- " + item for item in batch.get("smoke_domains", [])),
        "",
        "## Must not",
        "\n".join("- " + item for item in batch.get("must_not", [])),
        "",
        "## Copied source bundle files",
        "\n".join("- " + item for item in copied) or "- none",
    ]
    (root / "SELECTED_CONTEXT_MANIFEST.md").write_text("\n".join(context) + "\n", encoding="utf-8")

    extra_text = (
        "# Extra source routing\n\n"
        "Extra sources are candidate knowledge only. ChatGPT must classify them before any update is proposed.\n\n"
        "Provided extra sources:\n"
        + ("\n".join("- " + item for item in extra_copied) if extra_copied else "- none")
        + "\n\nClassification options:\n"
        "- affects this selected batch/run\n"
        "- creates/updates a SPEC annex\n"
        "- creates/updates a creation/update hook\n"
        "- affects a future registered batch/run\n"
        "- irrelevant/outdated\n"
        "- missing required supporting files\n"
    )
    (root / "EXTRA_SOURCE_ROUTING.md").write_text(extra_text, encoding="utf-8")

    if mode == "update":
        evidence_lines = [f"# Existing evidence check for {track} {batch_id} {slug}\n"]
        for row in check_evidence(data, batch):
            label = "required" if row["required"] else "conditional"
            evidence_lines.append(
                f"- {row['name']}: {'OK' if row['exists'] else 'MISSING'} ({label}) at `{row['path']}`"
            )
        evidence_lines.append(
            "\nUpdate rule: never overwrite original evidence. Use updates/<update-id>/ for update evidence in the real workspace."
        )
        (root / "EXISTING_EVIDENCE_CHECK.md").write_text(
            "\n".join(evidence_lines) + "\n", encoding="utf-8"
        )

    prompt = f"""# CHATGPT_REQUEST

Use this request pack to create a {mode} response for Infra-Skeleton.

Track: `{track}`
Batch: `{batch_id}` `{slug}`
Topic: `{topic}`
Profile: `{profile}`

Read these files in this request folder first:
1. REQUIRED_INPUTS.md
2. SELECTED_CONTEXT_MANIFEST.md
3. EXTRA_SOURCE_ROUTING.md
4. EXISTING_EVIDENCE_CHECK.md if present
5. source_bundle/ contents

Required behavior:
- Stop if selected lifecycle, dependency, evidence, or source gates are not satisfied.
- Use only the selected batch/run scope.
- Treat extra sources as candidate context only.
- Preserve public/private separation: infractl is public; this private bundle is project data.
- No API calls, smoke execution, Codex execution, or workspace mutation in webchat-sandbox.
- Do not read or edit `CLI_EXTRACTION_NOTES.md` in this normal lane. Route a proven reusable helper/manual pattern through zero lane 0C after the lane closes.

Expected ChatGPT output:
- For creation: CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md.
- For update: CODEX_UPDATE_PROMPT.txt, PROJECT_UPDATE_CACHE.md, UPDATE_SPEC.md, UPDATE_RUN_INSTRUCTIONS.md, UPDATE_POSTCHECK_TEMPLATE.md.
"""
    (root / "CHATGPT_REQUEST.md").write_text(prompt, encoding="utf-8")
    archive = zip_dir(root, zip_path)
    return root, archive
