# <BATCH_ID> — <BATCH_TITLE> — Transition-to-Real-Organs SPEC

## Purpose

Replace the skeleton/dummy implementation for `<BATCH_TITLE>` with real implementation while preserving all skeleton contracts.

This batch upgrades only the organ(s) listed below. It must not redesign the surrounding nervous system.

## Source of truth

Skeleton master:

```text
<SKELETON_MASTER_FILE_PATH>
```

Transition master:

```text
<TRANSITION_MASTER_FILE_PATH>
```

Use PROJECT_CACHE.md for stable context.

## In-scope transition rows

| Task | Transition row | Skeleton step | Real organ target | Contract to preserve |
|---:|---:|---|---|---|
| 1 | `<ROW>` | `<STEP_NAME>` | `<REAL_COMPONENT>` | `<COMMAND_OR_OUTPUT_CONTRACT>` |
| 2 | `<ROW>` | `<STEP_NAME>` | `<REAL_COMPONENT>` | `<COMMAND_OR_OUTPUT_CONTRACT>` |

## Out of scope

Do not implement unrelated real organs.

Explicitly out of scope unless in the table:

```text
config tool internal edits
full Runpod live submission
live Paperclip database writes
auto-approval of next experiments
OpenClaw live agent execution
large training/inference jobs
paper PDF final build
private vault indexing
```

## Current skeleton contract

Document the contract before changing it.

```text
Command/import path:
Inputs:
Outputs:
Status files:
Downstream consumers:
```

## Required real behavior

Replace the dummy behavior with:

```text
<real behavior>
<real behavior>
<real behavior>
```

The real implementation must still write:

```text
<same output filename>
<same output filename>
<same output filename>
```

## External dependency handling

If real implementation depends on an external system, follow this rule:

```text
Add dry-run/live separation.
Add config/env variable names without printing secret values.
Add clear TODO pointing to required external docs/help.
Do not guess undocumented API behavior.
```

External help required for this batch:

```text
Runpod: <yes/no and why>
Agentfield: <yes/no and why>
Paperclip: <yes/no and why>
OpenClaw: <yes/no and why>
```


## Posthoc config integration request

Create or update this handoff only after the real-organ change is known:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

Use it to record what a later operator/config pass may need to expose: workspace root, commands, Python/system packages, smoke checks, role owner, suggested integration type, safety boundaries, and open questions. Do not decide final config step names here. Do not edit config/lv/workflow files directly. If no integration is needed, say `suggested integration type: none`.

## Acceptance criteria

- Existing skeleton command/import paths still work.
- Existing dummy output filenames are preserved.
- Real implementation is behind the same CLI/schema/status contract.
- New tests prove both compatibility and the new real behavior.
- Live external behavior is dry-run by default or explicitly gated.
- No config tool internals are modified unless explicitly in scope.
- `INTEGRATION_REQUEST.md` is created or marked as `suggested integration type: none`.
- Final config/lv/workflow names are deferred to the later operator/config pass.
- No secrets/private data are printed.

## Validation commands

Fill with only safe commands for this transition.

```bash
python -m py_compile <file.py>
python -m pytest <tests>
<existing skeleton smoke command>
<new dry-run real-organ command>
```

## Postcheck log

Write:

```text
/mnt/egress/organs/dev-recordings/<batch-slug>/POSTCHECK.md
```

Also record the integration request path and whether later config integration is needed.
