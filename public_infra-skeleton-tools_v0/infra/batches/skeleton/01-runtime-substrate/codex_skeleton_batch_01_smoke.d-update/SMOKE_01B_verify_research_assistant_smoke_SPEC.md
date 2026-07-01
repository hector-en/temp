# SMOKE-01B — Verify Research Assistant Dynamic Smoke + Evidence SPEC

## Purpose

Verify the existing official dynamic smoke coverage for the Batch 01 remote-model dummy client/router contract and write a separate smoke-system evidence pack for this follow-up.

The dynamic smoke module already exists:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Do not recreate it.

This follow-up should:

```text
verify the existing module
minimally harden it only if validation exposes a concrete bug or safety issue
run the dynamic smoke validations
write SMOKE-01B evidence
```

This is a smoke-system follow-up. Do not overwrite the original Batch 01 implementation evidence.

## Source of truth

Read these first:

```text
existing /workspace/tests/smoke.d/90-research-assistant.smoke.sh
existing /workspace/scripts/smoke.sh
existing /workspace/tests/smoke.d/*.smoke.sh
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/runpod_brain_client.py
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Do not reread the full skeleton master unless the files above are unavailable or contradictory.

## Batch context

Batch:

```text
01-runtime-substrate
```

Phase:

```text
skeleton-progress
```

Repo-local helper:

```text
/workspace/repos/research-assistant/smoke_test.py
```

Official dynamic smoke module:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Keep this split:

```text
/workspace/repos/research-assistant/smoke_test.py
    repo-local helper test

/workspace/tests/smoke.d/90-research-assistant.smoke.sh
    official dynamic smoke module
```

## Expected existing dynamic smoke behavior

The existing module should verify:

```text
/workspace/repos/research-assistant
/workspace/repos/research-assistant/.env.example
/workspace/repos/research-assistant/requirements.txt
/workspace/repos/research-assistant/runpod_brain_client.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/prompts.py
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/check_runpod_brain_endpoint.py
/workspace/repos/research-assistant/check_opencode_remote_model_config.py
```

For Python files, it should compile with:

```bash
PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile <files>
```

It may run the local helper:

```bash
PYTHONPYCACHEPREFIX=/tmp python3 /workspace/repos/research-assistant/smoke_test.py
```

only if the helper is local/offline and does not require credentials.

## Allowed changes

Prefer no code changes.

Allowed to edit only if validation exposes a concrete bug or safety issue:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Allowed evidence outputs:

```text
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/INTEGRATION_REQUEST.md
```

Do not edit:

```text
/workspace/repos/research-assistant/*
/workspace/runtime/*
/workspace/scripts/runtime_checks/*
/workspace/scripts/smoke.sh
/workspace/scripts/smoke_current_state.sh
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh/*
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

## Offline/dummy safety requirements

The verified module must not:

```text
call RunPod
call OpenRouter
call any model/provider API
require RUNPOD_API_KEY
require OPENROUTER_API_KEY
print environment variable values
print secrets
read .env files
start Agentfield
run OpenClaw
run Paperclip
launch infrastructure
install packages
```

Acceptable behavior:

```text
check required files
compile Python files
run the repo-local helper if it returns deterministic dummy/local output
print non-secret PASS/WARN/FAIL messages
```

If the helper cannot be confirmed offline-safe, the module should not run it and should return WARN or BLOCKED according to the current runner convention.

## Expected classifications

PASS when:

```text
all expected research-assistant files exist
all expected Python files compile
smoke_test.py runs locally/offline and returns success
no evidence suggests a live model/API call
```

WARN when:

```text
optional endpoint env vars are absent
OpenCode config is absent
docker/terraform/runpod tools are absent
the helper cannot be run due to interpreter/environment mismatch, but files compile
```

FAIL or BLOCKED when:

```text
required research-assistant files are missing
Python files do not compile
smoke_test.py fails
smoke_test.py requires credentials
smoke_test.py attempts network/live model calls by default
secrets are printed
```

Use `BLOCKED` only if the current runner supports it; otherwise use the runner's existing WARN/FAIL convention.

## Evidence pack

Create a new smoke-system evidence pack.

Preferred root:

```text
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke
```

Create:

```text
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/POSTCHECK.md
/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/INTEGRATION_REQUEST.md
```

Do not overwrite:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

### POSTCHECK.md must include

```text
Date
Status
Changed files
Tasks executed
Tests run
Results
Safety confirmations
Smoke report path if available
Notes
```

It must explicitly confirm:

```text
No /workspace/repos/research-assistant/* files were edited.
No config internals were edited.
No runtime implementation files were edited.
No original Batch 01 evidence files were overwritten.
No RunPod/OpenRouter/model API calls were made.
No credentials or env values were printed.
```

### INTEGRATION_REQUEST.md must include

Use smoke-only integration unless evidence proves otherwise:

```text
Role owner: smoke/dynamic-smoke
Workspace root: /workspace/tests/smoke.d
Commands to expose: none, or optional smoke command only
Config integration needed: no
Suggested integration type: none / smoke-only
Smoke check: BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
Output contract: existing official dynamic smoke module wraps repo-local research-assistant smoke helper
Safety boundaries: offline/local/dummy only; no provider calls; no secrets
```

## Acceptance criteria

- Existing `90-research-assistant.smoke.sh` is verified and executable.
- It follows the current smoke module interface.
- It verifies Batch 01 research-assistant file contracts.
- It compiles Python files with `PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile`.
- It runs `smoke_test.py` only as a local/offline helper.
- It does not call live APIs, require credentials, print secrets, install packages, or mutate infrastructure.
- Batch 01 smoke run includes the existing module or otherwise documents why the runner did not discover it.
- A new smoke-system POSTCHECK.md and INTEGRATION_REQUEST.md are written under `/mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke`.
- The original Batch 01 GREEN evidence under `/mnt/egress/dev-recordings/skeleton/01-runtime-substrate` is not overwritten.
