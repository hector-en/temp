# SMOKE-01B — Verify Research Assistant Dynamic Smoke + Evidence — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
SMOKE_01B_verify_research_assistant_smoke_SPEC.md
```

## Current status

```text
Batch 01 GREEN is complete.
The official dynamic smoke module already exists:
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

This run is verification plus evidence, not module creation.

## Read order

Read only:

```text
SMOKE_01B_verify_research_assistant_smoke_SPEC.md
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
/workspace/scripts/smoke.sh
/workspace/scripts/smoke_current_state.sh if present
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

Prefer no code changes.

Allowed to edit only if validation exposes a concrete bug or safety issue:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Create/update only evidence files here:

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

Do not install packages. Do not run live external services.

## Tasks

### Task 1 — Verify current module style and syntax

Read:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
/workspace/scripts/smoke.sh
```

Requirements:

```text
- Confirm the module follows the current smoke runner convention.
- Confirm it is executable or make it executable if needed.
- Do not rewrite it for style-only reasons.
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/90-research-assistant.smoke.sh
test -x /workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

If executable bit is missing, run:

```bash
chmod +x /workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

---

### Task 2 — Verify research-assistant helper safety

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
- If safety cannot be confirmed, do not run the helper; record WARN/BLOCKED in evidence.
```

Do not edit research-assistant files.

Validation:

```bash
PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile /workspace/repos/research-assistant/smoke_test.py /workspace/repos/research-assistant/brain_router.py /workspace/repos/research-assistant/runpod_brain_client.py
```

---

### Task 3 — Run existing module directly

Run the module directly according to the current convention.

For the current simple executable module style:

```bash
BATCH_SLUG="01-runtime-substrate" /workspace/tests/smoke.d/90-research-assistant.smoke.sh skeleton-progress /tmp
```

Requirements:

```text
- Direct run must not call live APIs.
- Direct run must not require credentials.
- Direct run must report PASS/WARN/FAIL clearly.
```

If this exposes a concrete bug or safety issue, make the smallest possible edit to:

```text
/workspace/tests/smoke.d/90-research-assistant.smoke.sh
```

Then rerun Task 1 and Task 3 validations.

---

### Task 4 — Run full Batch 01 dynamic smoke

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
- Confirm the existing 90-research-assistant module appears in the smoke report, or explain exactly why it was not discovered.
- Do not edit implementation files to make smoke pass.
- Missing optional infra tools should remain WARN, not FAIL.
- Record the smoke report path if available.
```

---

### Task 5 — Write SMOKE-01B evidence pack

Create directory:

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

POSTCHECK.md must include:

```text
# SMOKE-01B postcheck
Canonical path: /mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/POSTCHECK.md
Date: <YYYY-MM-DD>
Status: PASS|WARN|FAIL|BLOCKED

## Changed files
- /workspace/tests/smoke.d/90-research-assistant.smoke.sh only if changed
- /mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/POSTCHECK.md
- /mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/INTEGRATION_REQUEST.md

## Tasks executed
- Task 1 — Verify current module style and syntax
- Task 2 — Verify research-assistant helper safety
- Task 3 — Run existing module directly
- Task 4 — Run full Batch 01 dynamic smoke
- Task 5 — Write SMOKE-01B evidence pack

## Tests run
- <commands>

## Results
- <result>

## Safety confirmations
- No /workspace/repos/research-assistant/* files were edited.
- No config tool internals were edited.
- No runtime implementation files were edited.
- No original Batch 01 evidence files were overwritten.
- No RunPod/OpenRouter/model/provider API calls were made.
- No credentials or env values were printed.
- No packages were installed.
- No Docker/Terraform/Kubernetes/RunPod mutation occurred.

## Smoke report
- <path or unavailable>

## Notes
- <notes>
```

INTEGRATION_REQUEST.md must include:

```text
Role owner: smoke/dynamic-smoke
Workspace root: /workspace/tests/smoke.d
Commands to expose: none
Config integration needed: no
Suggested integration type: none / smoke-only
Smoke check: BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
Output contract: existing official dynamic smoke module wraps repo-local research-assistant smoke helper
Safety boundaries: offline/local/dummy only; no provider calls; no secrets
Open questions for operator-side integration: none
```

Validation:

```bash
test -f /mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/POSTCHECK.md
test -f /mnt/egress/dev-recordings/smoke/01B-research-assistant-dynamic-smoke/INTEGRATION_REQUEST.md
test -f /mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
test -f /mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
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
- whether the existing module was changed or left untouched
- whether smoke_test.py was confirmed local/offline
- whether original Batch 01 evidence existed and was preserved
- whether the module was discovered by the dynamic runner
- confirmation no live API/model/RunPod calls were made
- confirmation no config/runtime/research-assistant implementation files were changed
```

## Suggested commit

```bash
git commit -m "test: verify research assistant dynamic smoke evidence"
```
