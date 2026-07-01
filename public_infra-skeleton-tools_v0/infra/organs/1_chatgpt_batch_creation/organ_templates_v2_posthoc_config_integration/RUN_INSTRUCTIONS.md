# <BATCH_ID> — <BATCH_TITLE> — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
SPEC.md
PROJECT_CACHE.md
```

Read `CONFIG_TOOL.md` only if this batch uses config/lv commands or target-role workflow context.

## Current status

```text
The skeleton implementation exists.
This transition batch replaces one or more dummy organs with real implementation.
The skeleton command/output contract must not break.
```

## Stable context pack

Rules:

```text
Implement only the transition tasks in SPEC.md.
Preserve command names, import paths, schemas, output filenames, and downstream compatibility.
Default to dry-run for external systems.
Do not guess Runpod/Agentfield/Paperclip/OpenClaw APIs; leave documented stubs if details are missing.
Do not edit config tool internals unless the SPEC explicitly lists a named file.
```

## Tasks

### Task 1 — Identify and freeze the skeleton contract

Implement only Task 1.

Read:

```text
<current skeleton files>
<tests or fixtures>
```

Do:

```text
- Record current command/import path.
- Record current dummy inputs and outputs.
- Add or update a compatibility test if missing.
- Do not replace dummy internals yet.
```

Validation:

```bash
<existing smoke command>
<compatibility test command>
```

### Task 2 — Replace one dummy organ with real implementation

Implement only Task 2 after Task 1 passes.

Read:

```text
<files needed for this organ>
```

Create/update:

```text
<files to update>
```

Requirements:

```text
- Preserve the contract from Task 1.
- Replace only the named dummy behavior.
- Keep live external calls disabled unless explicitly configured.
- If external API details are missing, create a stub plus TODO pointing to the correct external help source.
```

Validation:

```bash
<syntax check>
<unit test>
<dry-run smoke>
```

### Task 3 — End-to-end compatibility smoke

Implement only Task 3 after Task 2 passes.

Do:

```text
- Run the old skeleton smoke path.
- Run the new dry-run/real-organ path.
- Confirm downstream output filenames and schemas are unchanged.
```

Validation:

```bash
<old smoke command>
<new smoke command>
test -f <expected output>
```

## Final validation

```bash
<batch final validation command>
<batch final validation command>
```

## Postcheck log

Create:

```text
/mnt/egress/organs/dev-recordings/<batch-slug>/POSTCHECK.md
```

Use this format:

```text
<BATCH_ID> transition postcheck
Date: <date>
Status: PASS|FAIL

Changed files:
- <path>

Contract preserved:
- command/import path: yes/no
- output filenames: yes/no
- downstream compatibility smoke: yes/no

Tests run:
- <command>

Results:
- PASS|FAIL

Safety confirmations:
- No config tool internals were edited unless explicitly in scope.
- No broad bootstrap/install/mount/pull/push commands were run.
- No credentials/private data were read or printed.
- No live external jobs were launched unless explicitly requested.

External blockers / help needed:
- Runpod: <none|needed>
- Agentfield: <none|needed>
- Paperclip: <none|needed>
- OpenClaw: <none|needed>
```

## Integration request

Create or update:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

Use it only as a posthoc handoff for later operator/config integration. Do not edit config/lv/workflow files here. If no integration is needed, write `suggested integration type: none`.

Suggested fields:

```text
Implemented organ:
Workspace root:
Commands or CLIs to expose:
Python/system packages:
Smoke checks:
Output contracts:
Suggested integration type: none/workspace/python-env/role-workflow/launcher/health-check/dryrun-hook/other
Safety boundaries:
Open questions:
```

## Output summary for Codex response

At the end, report only:

```text
Changed files:
Validation run:
Contract preserved:
Postcheck log:
Integration request:
External blockers:
```
