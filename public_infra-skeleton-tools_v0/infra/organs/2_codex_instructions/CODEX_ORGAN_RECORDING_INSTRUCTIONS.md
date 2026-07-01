# Codex Recording Instructions — Real-Organ Development Sidecar Notes

**Purpose:** instruct Codex to record lightweight development notes alongside each transition-to-real-organs implementation batch.

These notes are not the full companion documentation. They are short, factual run records created during implementation so the companion generator can later turn them into a readable developer companion for the real-organ code path.

---

## Project workspace root

The canonical project workspace root for this real-organ work is:

```text
/home/researchscientist/workspace
```

Codex is expected to be launched from inside this folder. Treat this path as the working tree root for relative repository paths, batch files, master files, templates, and implementation commands.

Rules:
- Prefer relative paths from `/home/researchscientist/workspace` when reading or editing project code.
- Do not assume `/workspace` is the project root unless a specific batch explicitly says so.
- If the current working directory is not `/home/researchscientist/workspace`, stop and report the mismatch before editing.
- Keep output roots separate: development recordings go to `/mnt/egress/organs/dev-recordings` and readable companion documentation goes to `/mnt/ingress/infra/organs/companion`.

---

## Core rule

For every real-organ batch, Codex must create or update a development recording folder under the shared egress recording root. This is for Codex run output/post-run evidence only, not the final readable companion documentation:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/
```

This is the only canonical Codex development-recording output root for the organ transition phase. Do not write development recordings under `/mnt/egress/dev-recordings`, `/workspace/artifacts/dev-recordings`, `/home/researchscientist/workspace/artifacts/dev-recordings`, `/mnt/data/dev-recordings`, or `/mnt/ingress/infra/organs/companion` unless explicitly told to use a temporary local fallback because `/mnt/egress/organs/dev-recordings` is unavailable. The `/mnt/ingress/infra/organs/companion` tree is reserved for normal companion documentation output generated later.

---

## Output root hard rule

All Codex development recording output for real-organ batches goes to:

```text
/mnt/egress/organs/dev-recordings
```

Normal companion documentation output does **not** go here. It goes to:

```text
/mnt/ingress/infra/organs/companion
```

Codex must create parent directories under `/mnt/egress/organs/dev-recordings` if missing. If `/mnt/egress/organs/dev-recordings` is not writable, stop and report the problem in the postcheck instead of silently writing somewhere else.

---

## Batch slugs

Use exactly these folder names:

```text
organs/R01-contract-audit
organs/R02-real-grn-dsl-simulator
organs/R03-real-nca-local-rule
organs/R04-real-art2-artmap
organs/R05-real-mechanism-report
organs/R06-real-parameter-search
organs/R07-real-runpod-boundary
organs/R08-real-openclaw-pkm-bridge
organs/R09-real-agentfield-experiment
organs/R10-real-paperclip-adapter
organs/R11-real-campaign-orchestration
organs/R12-end-to-end-real-local-smoke
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
CONTRACT_CHANGES.md
REAL_ORGAN_EVIDENCE.md
INTEGRATION_REQUEST.md
```

`INTEGRATION_REQUEST.md` is a posthoc operator/config handoff. It does not authorize this batch to edit config/lv/workflow files or decide final config step names.

These files should be short and factual.

---

## Required content

### `README.md`

```md
# Dev Recording — <batch number> <batch title>

- Batch slug: `<slug>`
- Depends on skeleton batch(es): `<skeleton batch list>`
- Transition batch: `<Rxx>`
- Mode: real organ / guarded real organ / contract audit
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
- Main real-organ outputs:
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
| `<path>` | `<script/module>` | `<consumer>` | real / guarded real / dry-run |
```

### `CONTRACT_CHANGES.md`

```md
# Contract Changes

## Preserved skeleton contracts

- `<command/schema/output path>` preserved from skeleton batch `<number>`.

## Intentional contract revisions

| Contract | Previous skeleton shape | New real-organ shape | Reason | Approved by SPEC? |
|---|---|---|---|---|
| `<name>` | `<old>` | `<new>` | `<why>` | yes/no |

## Accidental or unresolved contract drift

- `<item>`
```

### `REAL_ORGAN_EVIDENCE.md`

```md
# Real-Organ Evidence

## Real behavior added

- `<module/function/command>` now performs `<real behavior>`.

## Evidence generated

- `<artifact/test/report>` proves `<claim>`.

## Remaining dummy behavior

- `<dummy component>` remains because `<reason>`.

## Live-action gates

- Runpod: dry-run / human-gated / not touched
- Paperclip: dry-run / human-gated / not touched
- Agentfield: local / dry-run / human-gated / not touched
- OpenClaw/model calls: dry-run / human-gated / not touched
```

### `GAPS_AND_TODOS.md`

```md
# Gaps and TODOs

## Spec gaps

- `<item>`

## Known limitations

- `<item>`

## Remaining skeleton-to-organ hooks

- `<thing>` still needs real `<replacement>`.

## External help needed

- Runpod: `<question or needed code>`
- Agentfield: `<question or needed code>`
- Paperclip: `<question or needed code>`
- OpenClaw: `<question or needed code>`
- Science modules: `<question or needed code>`
```

---

## Recording behavior during implementation

Codex should update these notes as it works, not only at the end.

At minimum, record:

1. Files created.
2. Files modified.
3. New commands or CLIs.
4. New schemas/config files.
5. Skeleton contracts preserved.
6. Contract changes, if any.
7. Real-organ outputs and their fields.
8. Dry-run/live gates preserved.
9. Smoke commands run.
10. Tests run.
11. Known failures.
12. Any SPEC items not implemented.
13. Any skeleton behavior still remaining.

---

### `INTEGRATION_REQUEST.md`

```md
# Integration Request

## Batch

- Batch slug: `<slug>`
- Role owner: researchscientist
- Config integration needed: none / deferred / yes

## What was created

- `<project path>` — `<purpose>`

## Suggested later operator/config exposure

- Suggested integration type: none / workspace root / Python env / role alias / health check / bootstrap step / dry-run hook / live-gated hook
- Commands or entrypoints to expose later:
- Python/system packages to consider later:
- Smoke/status checks to expose later:

## Safety boundaries

- Do not edit config from this batch.
- Keep live/provider actions dry-run or human-gated.

## Open questions for config integration

- `<question>`
```

Only fill this from what the batch actually created. Do not infer config names from roadmap names alone. If no config/platform exposure is needed, set `Suggested integration type: none`.

---

## Relationship to postcheck

At the end of the batch, Codex should still fill the normal `POSTCHECK_TEMPLATE.md`.

The recording files are more detailed and developer-facing. The postcheck is the concise status report.

Use all three layers:

```text
POSTCHECK_TEMPLATE.md       -> compact implementation status
Dev recording folder        -> evidence and notes for companion generation
INTEGRATION_REQUEST.md      -> posthoc operator/config handoff
Companion generator later   -> readable codebase walkthrough under /mnt/ingress/infra/organs/companion
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
Do not run live provider calls, Runpod jobs, Paperclip writes, Agentfield live submissions, OpenClaw/model calls, or expensive training unless the selected batch explicitly permits it and the action is human-gated.

---

## Config tool boundary

The config tool may be used for read-only inspection or explicitly scoped existing bootstrap steps.

Allowed examples:

```text
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
config --target researchscientist bootstrap steps
```

Not allowed in real-organ implementation batches unless a dedicated config-tool SPEC explicitly scopes it:

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

- What was replaced from dummy to real?
- Which skeleton contracts stayed stable?
- Which contracts changed and why?
- Where should I start reading?
- What command proves the organ works locally?
- What output contract must not change?
- What is still fake or guarded?
- What remains for the next real-organ batch?

Bad notes:

- huge pasted source files
- generic summaries with no paths
- logs without interpretation
- claims not supported by changed files or tests
