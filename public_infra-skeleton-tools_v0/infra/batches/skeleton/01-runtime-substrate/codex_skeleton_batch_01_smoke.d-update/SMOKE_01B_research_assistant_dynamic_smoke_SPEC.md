# SMOKE-01B — Research Assistant Dynamic Smoke Module SPEC

## Purpose

Add official dynamic smoke coverage for the Batch 01 remote-model dummy client/router contract.

Batch 01 GREEN created a repo-local helper:

```text
/workspace/repos/research-assistant/smoke_test.py
```

That helper is acceptable as a local repo test, but it should not be the primary dynamic smoke module.

This smoke update should add an official smoke.d wrapper:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

The wrapper should call the repo-local helper safely and keep all remote-model validation offline/dummy/local.

## Source of truth

Read these first:

```text
POSTCHECK.md
INTEGRATION_REQUEST.md
existing /workspace/scripts/smoke.sh
existing /workspace/tests/smoke.d/*.smoke.sh
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/runpod_brain_client.py
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

Batch 01 GREEN evidence says these files exist:

```text
/workspace/repos/research-assistant/README.md
/workspace/repos/research-assistant/.env.example
/workspace/repos/research-assistant/requirements.txt
/workspace/repos/research-assistant/runpod_brain_client.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/prompts.py
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/check_runpod_brain_endpoint.py
/workspace/repos/research-assistant/check_opencode_remote_model_config.py
```

Batch 01 integration evidence lists this helper smoke command:

```bash
python3 /workspace/repos/research-assistant/smoke_test.py
```

The implementation should treat that command as a local helper smoke only. The dynamic smoke runner should use `90-research-assistant.smoke.sh` as the official module.

## Design decision

Keep this split:

```text
/workspace/repos/research-assistant/smoke_test.py
    repo-local helper test

/workspace/tests/smoke.d/90-research-assistant.smoke.sh
    official dynamic smoke module
```

Do not move the research-assistant helper logic into `10-core-layout.smoke.sh`.

`10-core-layout.smoke.sh` may continue to check only the existence of `/workspace/repos/research-assistant` as part of Batch 01 layout, but the dummy client/router behavior belongs in the new module.

## Required smoke module

Create:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

The module must preserve the current smoke runner convention.

If existing modules are simple executable shell scripts that print `PASS:`, `WARN:`, `SKIP:`, or `FAIL:`, use that style.

If existing modules use function-based `detect`/`run`, follow that interface instead.

## Checks required

The official smoke module should verify:

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

For Python files, compile with:

```bash
PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile <files>
```

Use `PYTHONPYCACHEPREFIX=/tmp` because the Batch 01 postcheck observed that `/workspace` may not be writable for `__pycache__`.

Then run the local helper:

```bash
PYTHONPYCACHEPREFIX=/tmp python3 /workspace/repos/research-assistant/smoke_test.py
```

Only run this helper if inspection confirms it is local/offline and does not require credentials.

## Offline/dummy safety requirements

The new smoke module must force or verify local/offline/dummy behavior.

It must not:

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
import brain_router
call deterministic local functions
call smoke_test.py if it returns dummy/local JSON
print non-secret PASS/WARN/FAIL messages
```

If the module cannot prove the helper is offline-safe, it should not run it. It should return WARN or BLOCKED according to the current runner convention with an exact reason.

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

## Runner integration

The module should be executable:

```bash
chmod +x /workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

It should be discovered automatically by the existing smoke runner if the runner discovers:

```text
/workspace/tests/smoke.d/*.smoke.sh
```

Do not edit the runner unless discovery requires no change and validation proves the new file is picked up.

## Acceptance criteria

- `90-research-assistant.smoke.sh` exists and is executable.
- It follows the current smoke module interface.
- It verifies Batch 01 research-assistant file contracts.
- It compiles Python files with `PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile`.
- It runs `smoke_test.py` only as a local/offline helper.
- It does not call live APIs, require credentials, print secrets, install packages, or mutate infrastructure.
- Batch 01 smoke run includes the new module or otherwise documents why the runner did not discover it.
