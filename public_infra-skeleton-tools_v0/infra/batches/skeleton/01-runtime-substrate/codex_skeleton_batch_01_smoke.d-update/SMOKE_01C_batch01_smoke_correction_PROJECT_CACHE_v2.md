# PROJECT_CACHE — SMOKE-01C Batch 01 Smoke Correction

## Batch identity

- Work item: SMOKE-01C
- Target batch: 01-runtime-substrate
- Mode: validation/evidence-only
- Evidence root: /mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction

## Source files to read

Read these files in order:

```text
SMOKE_01C_batch01_smoke_correction_SPEC_v2.md
SMOKE_01C_batch01_smoke_correction_CODEX_RUN_INSTRUCTIONS_v2.md
```

Treat those two files as the full source of truth. Do not repeat or expand their instructions from memory.

## Current decision

The suspected Batch 01 issue was workspace ownership, not a smoke-module implementation defect.

The operator corrected `/workspace` ownership. This pass validates that correction and writes evidence.

## Active smoke model

Use the current DYN-SMOKE v2 direct module contract:

```text
/workspace/scripts/smoke.sh
/workspace/tests/smoke.d/*.smoke.sh
PASS: / WARN: / SKIP: / FAIL:
```

Do not convert modules to `detect/run`.

## Scope summary

Create/update only:

```text
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01C-batch01-smoke-correction/INTEGRATION_REQUEST.md
```

Do not edit project code, smoke modules, research-assistant files, runtime files, docs, or config internals.

## Expected result

Run the validations named in RUN_INSTRUCTIONS.

Accept only PASS or expected WARN.

Expected WARNs are limited to optional missing infra tools, endpoint env vars, or OpenCode config.
