# SMOKE-01C — Batch 01 Smoke Correction SPEC

## Purpose

Validate the corrected Batch 01 smoke state after the `/workspace` ownership fix, while preserving the SMOKE-01C correction bundle purpose.

This is a validation/evidence pass, not an implementation repair pass.

## Current diagnosis

The earlier suspected problem was workspace ownership. Batch 01 evidence showed that `PYTHONPYCACHEPREFIX=/tmp` was useful because `/workspace` was not writable for `__pycache__`.

The operator has now corrected `/workspace` ownership so the project tree should be writable by `researchscientist:researchscientist`.

Because the root cause was corrected outside this Codex pass, do not edit smoke modules unless validation still proves a concrete code bug remains.

## Current accepted mapping

Batch 01 smoke ownership is:

```text
10-core-layout.smoke.sh
  owns runtime roots, /workspace/runtime, /workspace/scripts/runtime_checks, and Batch 01 layout/evidence shape

60-infra-tools.smoke.sh
  owns optional command presence checks only: docker, terraform, kubectl, runpod, GPU

90-research-assistant.smoke.sh
  owns the Batch 01 dummy answer path / remote-model contract
```

The current DYN-SMOKE runner contract is:

```text
/workspace/scripts/smoke.sh
/workspace/tests/smoke.d/*.smoke.sh
module output: PASS: / WARN: / SKIP: / FAIL:
```

Do not convert modules to `detect/run`.

## Evidence context

Batch 01 implementation evidence should already exist:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

SMOKE-01B research-assistant evidence should already exist:

```text
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/INTEGRATION_REQUEST.md
```

Known acceptable WARNs for Batch 01 are only:

```text
docker/terraform/runpod missing
endpoint env vars not configured
OpenCode config absent
```

## Allowed changes

Create/update only:

```text
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/INTEGRATION_REQUEST.md
```

Do not edit:

```text
/workspace/scripts/smoke.sh
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/10-core-layout.smoke.sh
/workspace/tests/smoke.d/60-infra-tools.smoke.sh
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
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

If validation still fails, stop and report the exact failing command/path. Do not apply speculative fixes.

## Validation requirements

Run only safe, local validation:

```bash
bash --noprofile --norc -n /workspace/scripts/smoke.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
bash --noprofile --norc -n /workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Verify ownership/readiness without mutating it:

```bash
stat -c '%U:%G %A %n' /workspace /workspace/repos /workspace/scripts /workspace/tests /workspace/runtime /workspace/runs
test -w /workspace
test -w /workspace/runs
test -w /workspace/repos
```

Run direct research-assistant smoke:

```bash
BATCH_SLUG="01-runtime-substrate" /workspace/tests/smoke.d/90-research-assistant.smoke.sh skeleton-progress /tmp || true
```

Run full Batch 01 smoke:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
```

Expected result:

```text
PASS or expected WARN only.
```

## Evidence pack

Write:

```text
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/INTEGRATION_REQUEST.md
```

POSTCHECK.md must confirm:

```text
workspace ownership/readiness was checked
no smoke modules were edited
no research-assistant files were edited
full Batch 01 smoke was run
original Batch 01 evidence was preserved
SMOKE-01B evidence was preserved
```

INTEGRATION_REQUEST.md should say:

```text
Config integration needed: no
Suggested integration type: none / smoke-only
```

## Acceptance criteria

- No smoke module implementation files are changed.
- No research-assistant implementation files are changed.
- `/workspace` ownership/readiness is recorded.
- Batch 01 smoke runs through `/workspace/scripts/smoke.sh`.
- Result is PASS or expected WARN only.
- Evidence is written under `/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/`.
- Original Batch 01 and SMOKE-01B evidence are preserved.
