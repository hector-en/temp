# REPAIR_SMOKE_MODULE_CODEX.md — Repair a Dynamic Smoke Module or Orchestrator

Use this file as the short, cache-stable Codex instruction when an existing dynamic smoke test fails, warns unexpectedly, blocks, or no longer matches the current platform state.

This file is ChatGPT/operator-authored. Codex may read it. Codex must not overwrite it.

Pair it with:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
```

## Purpose

Repair the smallest possible part of the smoke system while preserving the dynamic smoke-test contract.

Repair targets may include:

```text
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/<module>.smoke.sh
```

Do not edit unrelated platform code unless the smoke report proves the platform code itself is broken and the user explicitly scopes that fix.

## Required read-only inputs

Codex must read:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/
```

Codex must read the failing report:

```text
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
/workspace/runs/smoke/<timestamp-phase>/raw/*.stdout.log
/workspace/runs/smoke/<timestamp-phase>/raw/*.stderr.log
```

If this failure happened after a batch, Codex must also read the relevant evidence:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

or:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

## Stop conditions

Stop and report exact missing files if any required input is missing.

Stop if the only way to make the smoke pass would require a forbidden live/mutating action:

```text
terraform apply
kubectl apply
helm install
helm upgrade
RunPod pod creation
live organ execution
live model/provider spending
credential printing
config mutation without explicit config-integration scope
vault overwrite
Paperclip production write
```

## Task scope

Repair one module or the orchestrator per Codex run.

Prefer this order:

```text
1. Fix broken smoke module logic.
2. Fix incorrect detect/run phase classification.
3. Fix report parsing or exit-code mapping in orchestrator only if multiple modules are affected.
4. Mark optional not-yet-ready checks as WARN/SKIP instead of FAIL when appropriate.
5. Leave true broken platform behavior as FAIL/BLOCKED.
```

Do not create duplicate modules.

Do not create ChatGPT/operator docs.

Do not create or edit:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
```

## Diagnosis steps

Read the smoke report and classify each issue:

```text
SKIP expected: domain absent in this phase.
WARN expected: optional readiness missing but workflow can continue.
FAIL real: required safe check failed.
BLOCKED real: required evidence/tool/permission missing.
Smoke bug: module detection, phase handling, paths, command syntax, or result-line formatting is wrong.
```

Before editing, identify:

```text
failing module
phase
reported status
raw stdout/stderr file
exact missing path or failing command
whether failure is smoke-code bug or real platform issue
```

## Repair rules

Allowed repairs:

```text
correct paths
correct phase-specific SKIP/WARN/FAIL logic
correct shell syntax
correct final SMOKE_RESULT line
make detect less brittle but still honest
make run read existing artifacts instead of guessing
add safe local dry-run checks
write clearer BLOCKED messages with exact missing files
```

Forbidden repairs:

```text
hide true failures by always returning PASS
delete evidence checks
remove forbidden-action protection
run live infrastructure commands
install packages just to make smoke pass unless user explicitly requested an installer task
edit config from a smoke repair task
print credentials
```

## Python package handling during repair

If a module fails because a Python package is missing, do not install packages inside the smoke repair unless explicitly requested.

Instead:

```text
- return WARN if optional for the current phase;
- return BLOCKED if required for this phase;
- print the exact missing import/tool;
- suggest the managed install/config step or target environment that should provide it.
```

## Validation commands

Run syntax checks for changed shell files:

```bash
bash --noprofile --norc -n /workspace/scripts/smoke_current_state.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/<module>.smoke.sh
```

Run the repaired module detect command:

```bash
bash --noprofile --norc /workspace/tests/smoke.d/<module>.smoke.sh detect
```

Then rerun the same phase that failed:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh <phase>
```

If no batch slug applies:

```bash
bash /workspace/scripts/smoke_current_state.sh <phase>
```

## Evidence update

If the repair was tied to a batch POSTCHECK, append or update:

```text
Smoke repair summary:
Repaired file:
Old status:
New status:
New smoke report path:
Remaining warnings/failures:
```

Do not rewrite historical smoke reports.

## Response format

End with:

```text
Changed files:
- ...

Tests run:
- ...

New smoke report:
- ...

Remaining issues:
- ...

Notes:
- ...
```
