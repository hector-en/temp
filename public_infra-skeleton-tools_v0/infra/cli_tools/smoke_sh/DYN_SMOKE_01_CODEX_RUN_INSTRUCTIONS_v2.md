# DYN-SMOKE-01 — Dynamic Smoke Tool — Codex Run Instructions v2

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
DYN_SMOKE_01_SPEC_v2.md
```

## Critical v2 correction

Do not create ChatGPT-authored documents.

The operator must place these files in the project before Codex runs implementation tasks:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
```

Codex must only read these files. If any are missing, stop and ask the operator to put the missing files there. Do not invent, regenerate, summarize, or overwrite them.

## Stable context pack

```text
You are working in /workspace for shared project code.

Shared project workspace:
/workspace

Dynamic smoke protocol docs, already created by ChatGPT/operator:
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md

Smoke runner to create:
/workspace/scripts/smoke.sh

Smoke modules to create:
/workspace/tests/smoke.d/*.smoke.sh

Smoke reports:
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md

Skeleton evidence output:
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/INTEGRATION_REQUEST.md

Do not edit config/lv/workflow integration in this milestone.
Do not create or overwrite the ChatGPT protocol docs.
Do not run broad bootstrap/install/mount/pull/push.
Do not deploy or call live external systems.
Do not read or print credential files.

Output at the end of each task:
Changed files:
Tests run:
Notes:
```

## Task 0 — Preflight only: verify required ChatGPT docs exist

Implement only Task 0.

Read:
- `DYN_SMOKE_01_SPEC_v2.md`
- `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`
- `/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md`
- `/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md`

Do not create or edit files.

Run:

```bash
test -f /workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
test -f /workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
test -f /workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
```

If any file is missing, stop and report exactly:

```text
Missing required ChatGPT-created smoke document(s):
- <path>

Ask the operator to place the missing file(s) in /workspace/docs before continuing.
```

## Task 1 — Create smoke directory layout and runner skeleton

Implement only Task 1.

Prerequisite:
- Task 0 passed.

Read:
- `DYN_SMOKE_01_SPEC_v2.md`
- `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`

Create directories only if missing:

```text
/workspace/scripts
/workspace/tests/smoke.d
/workspace/runs/smoke
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01
```

Create:

```text
/workspace/scripts/smoke.sh
```

Runner requirements for Task 1:
- accept phase argument
- validate phase against: skeleton-progress, skeleton-complete, organ-progress, organ-complete, pre-config, post-config, full
- verify required ChatGPT docs exist at startup
- create timestamped report dir under `/workspace/runs/smoke/<timestamp-phase>/`
- write a minimal `SMOKE_REPORT.md`
- do not run modules yet
- chmod executable

Validation:

```bash
bash --noprofile --norc -n /workspace/scripts/smoke.sh
bash /workspace/scripts/smoke.sh skeleton-complete
ls -1 /workspace/runs/smoke | tail -5
```

## Task 2 — Add module discovery and report aggregation

Implement only Task 2.

Read:
- `DYN_SMOKE_01_SPEC_v2.md`
- `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`
- current `/workspace/scripts/smoke.sh`

Update `/workspace/scripts/smoke.sh` so it:
- discovers modules from `${SMOKE_MODULE_GLOB:-/workspace/tests/smoke.d/*.smoke.sh}`
- sorts modules by filename
- exports `SMOKE_PHASE`, `SMOKE_REPORT_DIR`, `SMOKE_BATCH_SLUG`, `SMOKE_PROJECT_ROOT`, `SMOKE_EGRESS_ROOT`, `SMOKE_INGRESS_ROOT`, `SMOKE_STRICT`
- runs each module safely
- classifies PASS/WARN/SKIP/FAIL
- writes each module result to `SMOKE_REPORT.md`
- exits nonzero on FAIL
- exits nonzero on WARN only when `SMOKE_STRICT=1`
- handles zero modules as WARN, not FAIL

Validation:

```bash
bash --noprofile --norc -n /workspace/scripts/smoke.sh
bash /workspace/scripts/smoke.sh skeleton-complete
SMOKE_STRICT=1 bash /workspace/scripts/smoke.sh skeleton-complete || true
```

## Task 3 — Add core/layout and Python smoke modules

Implement only Task 3.

Read:
- `DYN_SMOKE_01_SPEC_v2.md`
- `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`
- `/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md`
- current `/workspace/scripts/smoke.sh`

Create:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
/workspace/tests/smoke.d/20-python-package.smoke.sh
```

Rules:
- modules must be safe and idempotent
- modules may read only and print PASS/WARN/SKIP/FAIL lines
- modules must not install packages
- modules must not delete or mutate project files
- chmod executable

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/20-python-package.smoke.sh
bash /workspace/scripts/smoke.sh skeleton-complete
```

## Task 4 — Add skeleton/organ evidence modules

Implement only Task 4.

Read:
- `DYN_SMOKE_01_SPEC_v2.md`
- `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`
- `/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md`
- current `/workspace/scripts/smoke.sh`

Create:

```text
/workspace/tests/smoke.d/30-skeleton-evidence.smoke.sh
/workspace/tests/smoke.d/40-organ-evidence.smoke.sh
```

Rules:
- skeleton module applies to skeleton-progress and skeleton-complete.
- organ module applies to organ-progress and organ-complete.
- when BATCH_SLUG is required but missing, report WARN or SKIP; do not invent a slug.
- use canonical evidence paths:
  `/mnt/egress/dev-recordings/skeleton/<batch-slug>/...`
  `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/...`
- use canonical companion roots:
  `/mnt/ingress/infra/skeleton/companion/`
  `/mnt/ingress/infra/organs/companion/`

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/30-skeleton-evidence.smoke.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/40-organ-evidence.smoke.sh
BATCH_SLUG=dyn-smoke-01 bash /workspace/scripts/smoke.sh skeleton-progress || true
BATCH_SLUG=R01-example bash /workspace/scripts/smoke.sh organ-progress || true
```

## Task 5 — Add config-boundary, infra, and GRN contract modules

Implement only Task 5.

Read:
- `DYN_SMOKE_01_SPEC_v2.md`
- `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`
- `/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md`
- current `/workspace/scripts/smoke.sh`

Create:

```text
/workspace/tests/smoke.d/50-config-boundary.smoke.sh
/workspace/tests/smoke.d/60-infra-tools.smoke.sh
/workspace/tests/smoke.d/70-grn-contract.smoke.sh
```

Rules:
- config-boundary must not edit config/lv files.
- infra module may check command presence/version only.
- do not run Docker containers.
- do not run `terraform apply`.
- do not change Kubernetes context.
- do not call live RunPod/AgentField APIs.
- GRN module may only run documented safe/local/dry-run commands if they are present in current SPEC/RUN_INSTRUCTIONS.

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/50-config-boundary.smoke.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/60-infra-tools.smoke.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/70-grn-contract.smoke.sh
bash /workspace/scripts/smoke.sh full || true
```

## Task 6 — Write implementation evidence only

Implement only Task 6.

Read:
- `DYN_SMOKE_01_SPEC_v2.md`
- `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`
- current smoke report from the latest run under `/workspace/runs/smoke/.../SMOKE_REPORT.md`

Create:

```text
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/dyn-smoke-01/INTEGRATION_REQUEST.md
```

POSTCHECK.md must include:
- changed files
- smoke modules created
- commands run
- latest smoke report path
- PASS/WARN/FAIL summary
- known limitations

INTEGRATION_REQUEST.md must include:
- request to later wrap `/workspace/scripts/smoke.sh` in config/lv
- proposed command names, but no direct config edits
- required safe phases
- evidence paths

Do not create/update companion docs.
Do not edit config/lv.

Validation:

```bash
test -f /mnt/egress/dev-recordings/skeleton/dyn-smoke-01/POSTCHECK.md
test -f /mnt/egress/dev-recordings/skeleton/dyn-smoke-01/INTEGRATION_REQUEST.md
grep -n "/workspace/scripts/smoke.sh" /mnt/egress/dev-recordings/skeleton/dyn-smoke-01/INTEGRATION_REQUEST.md
```

## Recommended order

```text
Task 0
Task 1
Task 2
Task 3
Task 4
Task 5
Task 6
```

## Suggested commits

```bash
git commit -m "chore: add dynamic smoke runner skeleton"
git commit -m "feat: add smoke module discovery and reports"
git commit -m "test: add core and Python smoke modules"
git commit -m "test: add skeleton and organ evidence smoke modules"
git commit -m "test: add config boundary infra and GRN smoke modules"
git commit -m "docs: record dynamic smoke implementation evidence"
```
