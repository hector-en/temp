# DYN-SMOKE-01 — Dynamic Idempotent Smoke Tool SPEC v2

## Purpose

Create a dedicated dynamic smoke-test tool for the shared project workspace.

The smoke tool must be safe, idempotent, cache-stable, and extensible. It must let the platform grow by adding small smoke modules for Kubernetes, Terraform, AgentField, RunPod, GRN, skeleton, organs, config, and future areas without rewriting the runner.

## Critical v2 correction

Codex must not create ChatGPT-authored reference documents.

The following documents are external reference inputs. They must already exist in the project folder because ChatGPT/the operator created them earlier:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
```

If any of these are missing, Codex must stop and ask the operator to place the missing file(s) there. Codex must not invent, regenerate, summarize, or replace them.

## Final control model

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
    existing ChatGPT-created protocol/spec document; read-only input for Codex

/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
    existing ChatGPT-created instruction for creating new smoke modules; read-only input for Codex

/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
    existing ChatGPT-created instruction for repairing smoke modules; read-only input for Codex

/workspace/scripts/smoke.sh
    stable smoke runner/orchestrator created by Codex

/workspace/tests/smoke.d/*.smoke.sh
    small safe dynamic modules created/updated by Codex

/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
    generated report for each smoke run

/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/
    implementation evidence written by Codex
```

## Design rule

```text
smoke.sh = stable runner
smoke.d modules = dynamic platform-specific checks
ChatGPT docs = protocol and module-authoring guidance
config integration = later wrapper only
```

Do not put this directly into config first. Config/lv integration comes later after the project-local smoke runner works.

## Safety contract

The smoke runner and all smoke modules may:

```text
- read project files
- check whether files/directories/commands exist
- run safe dry-run commands only
- run syntax checks
- validate output contracts
- write reports only under /workspace/runs/smoke/...
```

They must not:

```text
- deploy
- install packages
- mutate config/lv/workflow files
- run broad bootstrap/install/mount/pull/push commands
- run live organs
- call real external APIs unless a module explicitly proves it is offline/dry-run
- delete project files
- delete previous smoke reports
- read or print credential files
- print tokens, secrets, private datasets, or manuscripts
- modify Kubernetes context
- run terraform apply
- run docker containers
- start OpenClaw/AgentField/RunPod live agents
- create or overwrite ChatGPT-authored reference docs under /workspace/docs
```

## Idempotency rule

Running the same command repeatedly must be safe:

```bash
bash /workspace/scripts/smoke.sh skeleton-progress
bash /workspace/scripts/smoke.sh skeleton-progress
bash /workspace/scripts/smoke.sh pre-config
bash /workspace/scripts/smoke.sh post-config
```

Repeated runs may create new timestamped reports. They must not change platform state.

## Phases

The runner must accept at least these phases:

```text
skeleton-progress
skeleton-complete
organ-progress
organ-complete
pre-config
post-config
full
```

Unknown phases must fail clearly and list valid phases.

## Required environment inputs

Optional environment variables:

```text
BATCH_SLUG=<batch-slug>
SMOKE_MODULE_GLOB=/workspace/tests/smoke.d/*.smoke.sh
SMOKE_REPORT_ROOT=/workspace/runs/smoke
SMOKE_STRICT=0|1
```

Rules:
- `BATCH_SLUG` is expected for `skeleton-progress` and `organ-progress`.
- If `BATCH_SLUG` is missing, modules that need it should return WARN or SKIP, not invent a slug.
- `SMOKE_STRICT=1` may convert WARN into final non-zero status.

## Required runner behavior

`/workspace/scripts/smoke.sh` must:

```text
1. validate phase
2. verify required ChatGPT reference docs exist
3. create a timestamped report directory under /workspace/runs/smoke/<timestamp-phase>/
4. discover executable or readable modules from /workspace/tests/smoke.d/*.smoke.sh
5. run modules in sorted filename order
6. pass phase, report dir, BATCH_SLUG, and project paths via environment variables
7. capture module status as PASS/WARN/SKIP/FAIL
8. write SMOKE_REPORT.md
9. exit 0 if no FAIL and strict mode allows WARN
10. exit nonzero on FAIL, or on WARN when SMOKE_STRICT=1
```

## Required module interface

Each `*.smoke.sh` module must be a shell script that can be executed by the runner.

The runner should provide at least:

```text
SMOKE_PHASE
SMOKE_REPORT_DIR
SMOKE_BATCH_SLUG
SMOKE_PROJECT_ROOT=/workspace
SMOKE_EGRESS_ROOT=/mnt/egress
SMOKE_INGRESS_ROOT=/mnt/ingress
SMOKE_STRICT
```

Module output convention:

```text
PASS: message
WARN: message
SKIP: message
FAIL: message
```

The runner should classify a module as:
- FAIL if the module exits nonzero or emits `FAIL:`.
- WARN if it emits `WARN:` and no fail occurs.
- SKIP if it emits `SKIP:` and no fail/warn occurs.
- PASS otherwise.

## Initial module set

Create small safe modules only. Do not overbuild.

```text
10-core-layout.smoke.sh
20-python-package.smoke.sh
30-skeleton-evidence.smoke.sh
40-organ-evidence.smoke.sh
50-config-boundary.smoke.sh
60-infra-tools.smoke.sh
70-grn-contract.smoke.sh
```

### 10-core-layout.smoke.sh

Check:
- `/workspace` exists.
- `/workspace/scripts` exists.
- `/workspace/tests/smoke.d` exists.
- `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` exists.
- `/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md` exists.
- `/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md` exists.
- `/mnt/egress` and `/mnt/ingress` exist if mounted.

Missing required project smoke docs should be FAIL at runner preflight; module may also report them.

### 20-python-package.smoke.sh

Check only if Python package files exist. Examples:
- `pyproject.toml`
- `setup.py`
- package directory under `/workspace`

Safe checks:
- `python --version`
- import/syntax checks only if an obvious package exists
- no package install
- no pip install

### 30-skeleton-evidence.smoke.sh

For skeleton phases, check:
- `/mnt/egress/dev-recordings/skeleton/<BATCH_SLUG>/POSTCHECK.md` if BATCH_SLUG is provided.
- `/mnt/egress/dev-recordings/skeleton/<BATCH_SLUG>/INTEGRATION_REQUEST.md` if BATCH_SLUG is provided.
- skeleton companion root exists when expected:
  `/mnt/ingress/infra/skeleton/companion/`

No guessing of slugs.

### 40-organ-evidence.smoke.sh

For organ phases, check:
- `/mnt/egress/organs/dev-recordings/organs/<BATCH_SLUG>/POSTCHECK.md` if BATCH_SLUG is provided.
- `/mnt/egress/organs/dev-recordings/organs/<BATCH_SLUG>/INTEGRATION_REQUEST.md` if BATCH_SLUG is provided.
- organ companion root exists when expected:
  `/mnt/ingress/infra/organs/companion/`

No guessing of slugs.

### 50-config-boundary.smoke.sh

Check that smoke tool has not directly edited config integration surfaces in this milestone.

It may check file existence, but must not edit:
- config/lv/workflow files
- `/home/vmuser/.local/bin/config.sh`
- `/home/vmuser/.local/bin/lv.sh`
- `/home/vmuser/.local/etc/config-sh/...`

This module is a boundary reminder, not a config mutator.

### 60-infra-tools.smoke.sh

Check presence/version only, if commands exist:
- docker
- terraform
- kubectl
- runpod

Do not run containers.
Do not run `terraform apply`.
Do not change Kubernetes context.
Do not call external APIs.

### 70-grn-contract.smoke.sh

Check for GRN/project contract artifacts only if present:
- expected CLI files
- expected output directories
- known metadata/report filenames

It may run a documented dry-run only if the command is already documented in the current batch SPEC/RUN_INSTRUCTIONS and is explicitly safe/local/dry-run.

## Evidence output

Codex must write:

```text
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/INTEGRATION_REQUEST.md
```

These evidence files describe what was created and how it should later be wrapped by config/lv.

## What Codex may create/update

```text
/workspace/scripts/smoke.sh
/workspace/tests/smoke.d/*.smoke.sh
/workspace/runs/smoke/.../SMOKE_REPORT.md
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/INTEGRATION_REQUEST.md
```

## What Codex must not create/update

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
config/lv/workflow integration files
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/bin/lv.sh
/home/vmuser/.local/etc/config-sh/...
/mnt/ingress/infra/skeleton/companion/...
/mnt/ingress/infra/organs/companion/...
```

## Acceptance criteria

- The runner exists at `/workspace/scripts/smoke.sh`.
- The runner refuses to proceed if required ChatGPT docs are missing and lists them exactly.
- The runner discovers sorted `*.smoke.sh` modules.
- The runner writes timestamped smoke reports under `/workspace/runs/smoke/...`.
- Re-running the same command is safe and produces only a new report.
- Initial modules exist and are safe/read-only except for report writing.
- Missing optional subsystems produce SKIP or WARN, not false FAIL.
- Config/lv integration is not modified in this milestone.
- Codex-created POSTCHECK and INTEGRATION_REQUEST evidence exist.
- No credentials/private data are read or printed.
