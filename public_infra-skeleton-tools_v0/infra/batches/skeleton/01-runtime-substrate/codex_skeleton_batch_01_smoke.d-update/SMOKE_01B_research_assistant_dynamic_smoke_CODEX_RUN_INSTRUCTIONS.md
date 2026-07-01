# SMOKE-01B — Research Assistant Dynamic Smoke Module — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
SMOKE_01B_research_assistant_dynamic_smoke_SPEC.md
```

## Current status

```text
Batch 01 GREEN is complete.
Batch 01 created /workspace/repos/research-assistant/smoke_test.py.
That file is a repo-local helper test.
The official dynamic smoke wrapper should be /workspace/tests/smoke.d/90-research-assistant.smoke.sh.
```

## Read order

Read only:

```text
SMOKE_01B_research_assistant_dynamic_smoke_SPEC.md
/workspace/scripts/smoke.sh
/workspace/tests/smoke.d/10-core-layout.smoke.sh
/workspace/tests/smoke.d/60-infra-tools.smoke.sh if present
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/runpod_brain_client.py
/workspace/repos/research-assistant/check_runpod_brain_endpoint.py
/workspace/repos/research-assistant/check_opencode_remote_model_config.py
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md if present
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md if present
```

Do not scan the whole repo.

## Hard scope

Create/update only:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Do not edit unless absolutely required by current runner behavior:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
/workspace/tests/smoke.d/60-infra-tools.smoke.sh
/workspace/scripts/smoke.sh
```

Do not edit:

```text
/workspace/repos/research-assistant/*
/workspace/runtime/*
/workspace/scripts/runtime_checks/*
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh/*
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Do not install packages. Do not run live external services.

## Tasks

### Task 1 — Inspect current smoke module style

Implement only Task 1.

Read:

```text
/workspace/scripts/smoke.sh
/workspace/tests/smoke.d/*.smoke.sh
```

Determine whether modules are:

```text
simple executable scripts
function-based detect/run modules
another local convention
```

Requirements:

```text
- Preserve the existing convention.
- Do not rewrite the smoke runner.
- Do not rename existing modules.
```

Validation:

```bash
ls -1 /workspace/tests/smoke.d/*.smoke.sh
```

---

### Task 2 — Inspect research-assistant helper safety

Implement only Task 2 after Task 1 passes.

Read:

```text
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/runpod_brain_client.py
```

Requirements:

```text
- Confirm smoke_test.py is local/offline by default.
- Confirm it does not require RUNPOD_API_KEY or OPENROUTER_API_KEY.
- Confirm it does not print secret values.
- Confirm brain_router import path does not trigger live network calls.
- If safety cannot be confirmed, the dynamic module must not execute smoke_test.py and must report WARN/BLOCKED.
```

Do not edit research-assistant files.

Validation:

```bash
PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile /workspace/repos/research-assistant/smoke_test.py /workspace/repos/research-assistant/brain_router.py /workspace/repos/research-assistant/runpod_brain_client.py
```

---

### Task 3 — Create `90-research-assistant.smoke.sh`

Implement only Task 3 after Task 2 passes.

Create:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Requirements:

```text
- Follow current smoke module output/interface convention.
- Check required research-assistant files exist.
- Compile expected Python files with PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile.
- Run /workspace/repos/research-assistant/smoke_test.py only if Task 2 confirmed local/offline safety.
- Do not read .env files.
- Do not print env values.
- Do not call live APIs.
- Do not install packages.
```

Required files to check:

```text
/workspace/repos/research-assistant/.env.example
/workspace/repos/research-assistant/requirements.txt
/workspace/repos/research-assistant/runpod_brain_client.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/prompts.py
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/check_runpod_brain_endpoint.py
/workspace/repos/research-assistant/check_opencode_remote_model_config.py
```

Make executable:

```bash
chmod +x /workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

---

### Task 4 — Run module directly

Implement only Task 4 after Task 3 passes.

Run the module directly according to its interface.

For simple script modules:

```bash
BATCH_SLUG="01-runtime-substrate" /workspace/tests/smoke.d/90-research-assistant.smoke.sh skeleton-progress /tmp
```

If the current runner passes different arguments, use the convention discovered in Task 1.

Requirements:

```text
- Direct run must not call live APIs.
- Direct run must not require credentials.
- Direct run must report PASS/WARN/FAIL clearly.
```

---

### Task 5 — Run full Batch 01 dynamic smoke

Implement only Task 5 after Task 4 passes.

Run:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
```

If `/workspace/scripts/smoke.sh` is absent but `/workspace/scripts/smoke_current_state.sh` exists, run:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

Requirements:

```text
- Confirm the new 90-research-assistant module appears in the smoke report, or explain exactly why it was not discovered.
- Do not edit implementation files to make smoke pass.
- Missing optional infra tools should remain WARN, not FAIL.
```

---

## Expected final response from Codex

```text
Changed files:
- /workspace/tests/smoke.d/90-research-assistant.smoke.sh

Tests run:
- PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile ...
- bash --noprofile --norc -n /workspace/tests/smoke.d/90-research-assistant.smoke.sh
- BATCH_SLUG="01-runtime-substrate" /workspace/tests/smoke.d/90-research-assistant.smoke.sh ...
- BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress

Result:
- PASS/WARN/FAIL/BLOCKED according to runner output

Notes:
- whether smoke_test.py was confirmed local/offline
- whether evidence files existed
- whether the new module was discovered by the dynamic runner
- confirmation no live API/model/RunPod calls were made
- confirmation no config/runtime/research-assistant implementation files were changed
```

## Suggested commit

```bash
git commit -m "test: add research assistant dynamic smoke module"
```
