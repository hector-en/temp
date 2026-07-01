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
Master file exists and is authoritative.
This batch is skeleton-dummy only.
The config tool is out of scope and must not be edited.
```

## Stable context pack

You are implementing only the in-scope steps from SPEC.md.

Rules:

```text
Do not scan the whole repo.
Do not edit config tool internals.
Do not run broad setup commands.
Do not run live external services unless this file explicitly says live smoke.
Do not overwrite existing user work.
Create only skeleton files, schemas, configs, dummy CLIs, fake outputs, and smoke tests.
```

## Tasks

### Task 1 — <TASK_TITLE>

Implement only Task 1.

Read only:

```text
<file_or_directory_to_read>
<file_or_directory_to_read>
```

Create/update only:

```text
<file_or_directory_to_create>
<file_or_directory_to_create>
```

Requirements:

```text
- <requirement>
- <requirement>
- <requirement>
```

Validation:

```bash
<validation command>
<validation command>
```

### Task 2 — <TASK_TITLE>

Implement only Task 2 after Task 1 passes.

Read only:

```text
<file_or_directory_to_read>
```

Create/update only:

```text
<file_or_directory_to_create>
```

Requirements:

```text
- <requirement>
- <requirement>
```

Validation:

```bash
<validation command>
```

### Task 3 — <TASK_TITLE>

Implement only Task 3 after Task 2 passes.

Read only:

```text
<file_or_directory_to_read>
```

Create/update only:

```text
<file_or_directory_to_create>
```

Requirements:

```text
- <requirement>
- <requirement>
```

Validation:

```bash
<validation command>
```

## Final validation

Run only safe, local validation:

```bash
<batch final validation command>
<batch final validation command>
```

## Postcheck log

Create:

```text
/mnt/egress/dev-recordings/<batch-slug>/POSTCHECK.md
```

Use this format:

```text
<BATCH_ID> postcheck
Date: <date>
Status: PASS|FAIL

Changed files:
- <path>

Tasks executed:
- Task 1 — <title>
- Task 2 — <title>

Tests run:
- <command>

Results:
- PASS|FAIL

Safety confirmations:
- No config tool internals were edited.
- No broad bootstrap/install/mount/pull/push commands were run.
- No credentials/private data were read or printed.
- No live external jobs were launched.

Notes:
- <notes>
```


## Integration request

If this batch creates a command, script, Python package need, workspace root, smoke check,
health check, launcher, role workflow, or output contract that should later be exposed
through the config platform, create:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

Use it only as a posthoc bridge. Do not decide final config step names here.
Do not edit config/lv/bootstrap files in this implementation batch.

Minimum content:

```text
Role owner:
Workspace root:
Commands to expose:
Python packages needed:
Config integration needed:
Smoke check:
Output contract:
Operator/config notes:
```

A later operator-side config integration batch will read this file and decide whether
to add config bootstrap steps, lv profiles, role aliases, launchers, or health checks.

## Output summary for Codex response

At the end, report only:

```text
Changed files:
Validation run:
Postcheck log:
Integration request:
Notes:
```
