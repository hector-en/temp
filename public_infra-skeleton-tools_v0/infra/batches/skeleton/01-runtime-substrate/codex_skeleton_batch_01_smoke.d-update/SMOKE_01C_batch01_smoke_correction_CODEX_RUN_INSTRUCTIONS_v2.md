# SMOKE-01C — Batch 01 Smoke Correction — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
SMOKE_01C_batch01_smoke_correction_SPEC_v2.md
```

## Current status

```text
Batch 01 is implemented.
DYN-SMOKE v2 is active.
SMOKE-01B verified the research-assistant smoke module.
The suspected issue was /workspace ownership, which the operator corrected.
This pass validates the fix and writes SMOKE-01C evidence only.
```

## Read order

Read only:

```text
SMOKE_01C_batch01_smoke_correction_SPEC_v2.md
/workspace/scripts/smoke.sh
/workspace/tests/smoke.d/10-core-layout.smoke.sh
/workspace/tests/smoke.d/60-infra-tools.smoke.sh
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/INTEGRATION_REQUEST.md
```

Do not scan the whole repo.

## Hard scope

Allowed to create/update only:

```text
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/INTEGRATION_REQUEST.md
```

Do not edit:

```text
/workspace/scripts/smoke.sh
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/*.smoke.sh
/workspace/repos/research-assistant/*
/workspace/runtime/*
/workspace/scripts/runtime_checks/*
/workspace/docs/*
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh/*
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/*
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/*
```

If validation fails, stop and report the exact failing command. Do not repair speculatively.

## Tasks

### Task 1 — Confirm active runner contract

Run:

```bash
bash --noprofile --norc -n /workspace/scripts/smoke.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Confirm:

```text
runner executes modules directly
modules print PASS/WARN/SKIP/FAIL
no detect/run conversion is needed
```

### Task 2 — Verify workspace ownership/readiness

Run read-only checks:

```bash
stat -c '%U:%G %A %n' /workspace /workspace/repos /workspace/scripts /workspace/tests /workspace/runtime /workspace/runs
test -w /workspace
test -w /workspace/runs
test -w /workspace/repos
```

Do not run `chown`.
Do not change permissions.

### Task 3 — Run direct research-assistant smoke

Run:

```bash
BATCH_SLUG="01-runtime-substrate" /workspace/tests/smoke.d/90-research-assistant.smoke.sh skeleton-progress /tmp || true
```

Expected:

```text
PASS or WARN.
WARN is acceptable only for optional endpoint env vars or OpenCode config paths.
```

### Task 4 — Run full Batch 01 smoke

Run:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
```

Expected:

```text
PASS or WARN.
WARN is acceptable only for optional infra tools, endpoint env vars, or OpenCode config.
```

Record the new `SMOKE_REPORT.md` path.

### Task 5 — Write SMOKE-01C evidence

Create:

```text
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/INTEGRATION_REQUEST.md
```

POSTCHECK.md must include:

```text
# SMOKE-01C postcheck
Canonical path: /mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/POSTCHECK.md
Date: <YYYY-MM-DD>
Status: PASS|WARN|FAIL|BLOCKED

## Changed files
- /mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/POSTCHECK.md
- /mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/INTEGRATION_REQUEST.md

## Validation summary
- Workspace ownership/readiness was checked.
- No smoke modules were edited.
- No research-assistant files were edited.
- Full Batch 01 smoke was run.

## Tests run
- <commands>

## Results
- <result>

## Safety confirmations
- No smoke module implementation files were edited.
- No research-assistant implementation files were edited.
- No runtime implementation files were edited.
- No config tool internals were edited.
- Original Batch 01 evidence was not overwritten.
- SMOKE-01B evidence was not overwritten.
- No RunPod/OpenRouter/model/provider API calls were made.
- No credentials or env values were printed.
- No packages were installed.
- No Docker/Terraform/Kubernetes/RunPod mutation occurred.
- No ownership or permission mutation was performed by this pass.

## Smoke report
- <path or unavailable>

## Notes
- <ownership/readiness notes>
```

INTEGRATION_REQUEST.md must include:

```text
Role owner: smoke/dynamic-smoke
Workspace root: /workspace
Commands to expose: none
Config integration needed: no
Suggested integration type: none / smoke-only
Smoke check: BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
Output contract: Batch 01 smoke modules preserve DYN-SMOKE v2 direct PASS/WARN/SKIP/FAIL contract
Safety boundaries: local-only, no provider calls, no secrets, no infra mutation
Open questions for operator-side integration: none
```

Validation:

```bash
test -f /mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/POSTCHECK.md
test -f /mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/INTEGRATION_REQUEST.md
```

## Expected final response from Codex

```text
Changed files:
- ...

Tests run:
- ...

Result:
- ...

Notes:
- ...
```

## Suggested commit

If this pass creates evidence outside the repo only, no project commit is required.

If you decide to track smoke evidence in a separate evidence repo, commit there with:

```bash
git commit -m "test(batch-01): record smoke ownership validation"
```
