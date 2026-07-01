# <BATCH_ID> — <BATCH_TITLE> — Skeleton-Dummy SPEC

## Purpose

Implement the skeleton-first version of `<BATCH_TITLE>`.

This batch should make the platform shape visible and testable using dummy/template behavior. It must preserve the output contracts needed by later real science/platform work.

## Source of truth

Primary source:

```text
<MASTER_FILE_PATH>
```

Use the master only for the step rows listed below. Use PROJECT_CACHE.md for stable context.

Optional source when config workflow context is needed:

```text
CONFIG_TOOL.md
```

## In-scope steps

Only implement the steps listed here.

| Task | Master order | Step | Owner role | Target root | Skeleton output |
|---:|---:|---|---|---|---|
| 1 | `<ORDER>` | `<STEP_NAME>` | `<ROLE>` | `<PATH>` | `<EXPECTED_FILE_OR_DIR>` |
| 2 | `<ORDER>` | `<STEP_NAME>` | `<ROLE>` | `<PATH>` | `<EXPECTED_FILE_OR_DIR>` |
| 3 | `<ORDER>` | `<STEP_NAME>` | `<ROLE>` | `<PATH>` | `<EXPECTED_FILE_OR_DIR>` |

## Out of scope

Do not implement anything outside the in-scope table.

Explicitly out of scope unless named above:

```text
real NCA/ART/PDE/ODE science
real parameter search
real Runpod job submission
real Agentfield live server execution
real Paperclip database writes
real OpenClaw agent runs
paper PDF build
vault indexing beyond explicit manifests
config-tool internal changes
```

## Required behavior

- Create directories and placeholder files only if missing.
- Provide minimal Python modules/CLI entrypoints where needed.
- CLI entrypoints must return deterministic dummy JSON/Markdown outputs.
- Dummy outputs must use the same filenames expected by future real implementation.
- Keep side effects local to the target paths in this SPEC.
- Do not overwrite existing files unless they are generated smoke outputs under a new timestamped run directory.
- Keep all live/external actions behind explicit future flags or stubs.

## Expected file/path map

Fill this section for the concrete batch.

```text
<path/to/create>
<path/to/create>
<path/to/create>
```

## Output contract

The batch must produce or preserve these outputs:

```text
<output_1>
<output_2>
<output_3>
```


## Posthoc config integration request

If this batch creates commands, scripts, folders, package needs, smoke checks, or
role-facing behavior that may later need platform exposure, create:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

This file is only a bridge for later operator/config integration. Do not decide
final config step names here, and do not edit config/lv/workflow files in this
batch. The later config-integration batch will read the request and decide
whether to add bootstrap steps, Python env profiles, role aliases, launchers,
health checks, or leave the item project-only.

Include at minimum:

```text
Role owner
Workspace root
Commands to expose
Python packages needed
Config integration needed
Smoke check
Output contract
Deferred/none if no config integration is needed
```

## Acceptance criteria

- All in-scope paths exist.
- Placeholder code imports or shell scripts syntax-check.
- Smoke command, if present, writes deterministic output under `/workspace/runs/...`.
- No config tool internals are modified.
- No broad setup or live external work is run.
- No credentials/private data are read or printed.
- Postcheck log is written.
- INTEGRATION_REQUEST.md is written when later config/platform exposure may be needed, or explicitly marked not needed in the postcheck.

## Validation commands

Use only commands relevant to this batch. Delete unused examples when instantiating.

```bash
# Python syntax/import checks
python -m py_compile <file.py>
python -m pytest <tests> || true

# Shell syntax checks
bash --noprofile --norc -n <script.sh>

# Path checks
test -d <expected_dir>
test -f <expected_file>

# Optional config inspection only
config --target <user> config-show
config --target <user> bootstrap steps
sudo config --target <user> bootstrap status
```

## Postcheck log

Write:

```text
/mnt/egress/dev-recordings/<batch-slug>/POSTCHECK.md
```

If the batch naturally belongs in a project repo, also copy the postcheck into:

```text
/mnt/egress/dev-recordings/<batch-slug>/POSTCHECK.md
```
