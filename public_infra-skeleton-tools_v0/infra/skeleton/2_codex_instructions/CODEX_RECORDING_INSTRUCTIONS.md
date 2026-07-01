# Codex Recording Instructions — Skeleton Development Sidecar Notes

**Purpose:** instruct Codex to record lightweight development notes alongside each skeleton implementation batch.

These notes are not the full companion documentation. They are short, factual run records created during implementation so the companion generator can later turn them into a readable developer companion.

---


## Project workspace root

The canonical project workspace root for this skeleton work is:

```text
/home/researchscientist/workspace
```

Codex is expected to be launched from inside this folder. Treat this path as the working tree root for relative repository paths, batch files, master files, templates, and implementation commands.

Rules:
- Prefer relative paths from `/home/researchscientist/workspace` when reading or editing project code.
- Do not assume `/workspace` is the project root unless a specific batch explicitly says so.
- If the current working directory is not `/home/researchscientist/workspace`, stop and report the mismatch before editing.
- Keep output roots separate: development recordings go to `/mnt/egress/dev-recordings` and readable companion documentation goes to `/mnt/ingress/infra/skeleton/companion`.

## Core rule

For every skeleton batch, Codex must create or update a development recording folder under the shared egress recording root. This is for Codex run output/post-run evidence only, not the final readable companion documentation:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/
```

This is the only canonical Codex development-recording output root. Do not write development recordings under `/workspace/artifacts/dev-recordings`, `/home/researchscientist/workspace/artifacts/dev-recordings`, `/mnt/data/dev-recordings`, or `/mnt/ingress/infra/skeleton/companion` unless explicitly told to use a temporary local fallback because `/mnt/egress` is unavailable. The `/mnt/ingress/infra/skeleton/companion` tree is reserved for normal companion documentation output generated later.

---

## Output root hard rule

All Codex development recording output goes to:

```text
/mnt/egress/dev-recordings
```

Normal companion documentation output does **not** go here. It goes to:

```text
/mnt/ingress/infra/skeleton/companion
```

Codex must create parent directories under `/mnt/egress/dev-recordings` if missing. If `/mnt/egress/dev-recordings` is not writable, stop and report the problem in the postcheck instead of silently writing somewhere else.

## Batch slugs

Use exactly these folder names:

```text
skeleton/01-runtime-substrate
skeleton/02-research-workspace
skeleton/03-ai-engineer-workspaces
skeleton/04-pkm-skeleton
skeleton/05-publisher-latex
skeleton/06-nca-art-base
skeleton/07-dummy-science-organs
skeleton/08-mechanism-reporting
skeleton/09-local-smoke
skeleton/10-search-templates
skeleton/11-search-scoring
skeleton/12-search-smoke
skeleton/13-runpod-dryrun
skeleton/14-openclaw-indexes
skeleton/15-openclaw-reasoners
skeleton/16-agentfield-poc
skeleton/17-agentfield-reasoners
skeleton/18-agentfield-hardening-stubs
skeleton/19-paperclip-adapter-core
skeleton/20-paperclip-review-dryrun
skeleton/21-campaign-core
skeleton/22-campaign-agents
skeleton/23-campaign-review-smoke
skeleton/24-campaign-guarded-stubs
```

---

## Required files per batch

Each batch recording folder should contain:

```text
README.md
IMPLEMENTATION_NOTES.md
CHANGED_FILES.md
COMMANDS_RUN.md
ARTIFACTS_CREATED.md
GAPS_AND_TODOS.md
INTEGRATION_REQUEST.md
```

These files should be short and factual.

---

## Required content

### `README.md`

```md
# Dev Recording — <batch number> <batch title>

- Batch slug: `<slug>`
- Master step range: `<orders or steps>`
- Layer: `<layer>`
- Bundle(s): `<bundle list>`
- Mode: skeleton dummy
- Status: complete / partial / blocked
- Date/time: `<timestamp if available>`
```

### `IMPLEMENTATION_NOTES.md`

```md
# Implementation Notes

## Short overview

One paragraph explaining what was implemented in this run.

## Implementation shape

- Main entrypoints:
- Main schemas/configs:
- Main dummy outputs:
- Main smoke path:

## Design notes

Short bullets explaining important choices.
```

### `CHANGED_FILES.md`

```md
# Changed Files

| Path | Created/Modified | Purpose |
|---|---|---|
| `<path>` | created/modified | `<why>` |
```

### `COMMANDS_RUN.md`

```md
# Commands Run

| Command | Purpose | Result |
|---|---|---|
| `<command>` | `<why>` | pass/fail/not run |
```

Do not include secrets, tokens, credentials, or private paths.

### `ARTIFACTS_CREATED.md`

```md
# Artifacts Created

| Artifact | Producer | Consumer | Skeleton or real |
|---|---|---|---|
| `<path>` | `<script/module>` | `<future consumer>` | skeleton |
```

### `GAPS_AND_TODOS.md`

```md
# Gaps and TODOs

## Spec gaps

- `<item>`

## Known limitations

- `<item>`

## Transition hooks

- Dummy `<thing>` should later become real `<thing>`.

## External help needed

- Runpod: `<question or needed code>`
- Agentfield: `<question or needed code>`
- Paperclip: `<question or needed code>`
- OpenClaw: `<question or needed code>`
```

### `INTEGRATION_REQUEST.md`

```md
# Integration Request — <batch number> <batch title>

## Summary

- What this batch created:
- Why config might need to expose it later:

## Suggested integration type

- none / workspace root / Python env / role alias / health check / bootstrap step / dry-run hook / guarded live hook

## Evidence

- Postcheck path:
- Changed files:
- Commands to expose or check:
- Artifacts or schemas to preserve:

## Safety boundary

- Do not edit config in this implementation batch.
- Final config/lv/workflow names are decided later by the operator/config integration pass.

## Open questions

- `<item>`
```

---

## Recording behavior during implementation

Codex should update these notes as it works, not only at the end.

At minimum, record:

1. Files created.
2. Files modified.
3. New commands or CLIs.
4. New schemas/config files.
5. Dummy output artifacts and their fields.
6. Smoke commands run.
7. Tests run.
8. Known failures.
9. Any SPEC items not implemented.
10. Any real-organ transition hooks.
11. Any posthoc config/platform exposure request.

---

## Relationship to postcheck

At the end of the batch, Codex should still fill the normal `POSTCHECK_TEMPLATE.md`.

The recording files are more detailed and developer-facing. The postcheck is the concise status report.

Use both:

```text
POSTCHECK_TEMPLATE.md       -> compact implementation status
Dev recording folder        -> evidence and notes for companion generation
INTEGRATION_REQUEST.md      -> posthoc operator/config handoff
Companion generator later   -> readable codebase walkthrough under /mnt/ingress/infra/skeleton/companion
```

---

## Safety rules

Do not record secrets.
Do not record credential file contents.
Do not record API keys.
Do not record SMB password material.
Do not dump private PKM note content.
Do not paste large source files.
Do not paste full logs unless they are short and non-sensitive.
Do not modify the config tool unless a dedicated config-tool SPEC explicitly requires it.

---

## Config tool boundary

The config tool may be used for read-only inspection or explicitly scoped existing bootstrap steps.

Allowed examples:

```text
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
config --target researchscientist bootstrap steps
```

Not allowed in skeleton implementation batches:

```text
edit /home/vmuser/.local/bin/config.sh
edit /home/vmuser/.local/lib/config-sh/installers.sh
edit /home/vmuser/.local/etc/config-sh
run broad bootstrap without explicit SPEC approval
read credential files
```

---

## Developer recording philosophy

Write notes for the next developer, not for the current shell session.

Good notes answer:

- What was added?
- Why does it exist?
- Where should I start reading?
- What command proves it works?
- What output contract must not change?
- What is still fake?
- What will be replaced when the real organ is implemented?
- What should a later operator/config pass consider exposing?

Bad notes:

- huge pasted source files
- generic summaries with no paths
- logs without interpretation
- claims not supported by changed files or tests
