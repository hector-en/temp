# SMOKE-01 — Batch 01 Runtime Substrate Smoke.d Update — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
SMOKE_01_runtime_substrate_SPEC.md
```

## Current status

```text
Batch 01 implementation scope is known.
Batch 01 covers runtime roots, runtime readiness policies/checks, and a remote model dummy client/router contract.
The preferred smoke owner is /workspace/tests/smoke.d/10-core-layout.smoke.sh.
The optional secondary smoke owner is /workspace/tests/smoke.d/60-infra-tools.smoke.sh only for safe host-tool checks.
Do not create one smoke module per batch.
```

## Read order

Read only these first:

```text
SMOKE_01_runtime_substrate_SPEC.md
/workspace/scripts/smoke.sh
/workspace/scripts/smoke_current_state.sh if it exists
/workspace/tests/smoke.d/10-core-layout.smoke.sh
/workspace/tests/smoke.d/60-infra-tools.smoke.sh if it exists
/workspace/tests/smoke.d/30-skeleton-evidence.smoke.sh if it exists
```

Read Batch 01 implementation evidence only if present:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Do not scan the whole repo.

## Hard scope

You are updating smoke coverage only.

Allowed to update:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
```

Allowed only if necessary and already present:

```text
/workspace/tests/smoke.d/60-infra-tools.smoke.sh
```

Do not update unless explicitly necessary:

```text
/workspace/tests/smoke.d/30-skeleton-evidence.smoke.sh
```

Do not edit:

```text
/workspace/scripts/smoke.sh
/workspace/scripts/smoke_current_state.sh
/workspace/docs/*
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh/*
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Do not install anything. Do not run live infrastructure or model calls.

## Tasks

### Task 1 — Inspect current smoke runner interface and module style

Implement only Task 1.

Read:

```text
/workspace/scripts/smoke.sh
/workspace/scripts/smoke_current_state.sh if it exists
/workspace/tests/smoke.d/10-core-layout.smoke.sh
```

Determine the current module interface:

```text
- simple executable script with PASS/WARN/SKIP/FAIL output
- or detect/run function interface
- or another current local convention
```

Requirements:

```text
- Preserve the current interface.
- Do not rewrite the runner.
- Do not rename existing modules.
- Do not create a new 01-runtime-substrate smoke module.
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
```

If the file is not shell or uses a different executable style, use the equivalent syntax-only validation already used by the repository.

---

### Task 2 — Add Batch 01 generic runtime root checks to `10-core-layout.smoke.sh`

Implement only Task 2 after Task 1 passes.

Update only:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
```

Add phase/batch-aware checks for:

```text
/workspace/repos
/workspace/envs
/workspace/data
/workspace/runs
/workspace/artifacts
/workspace/models
/workspace/checkpoints
/workspace/logs
```

Requirements:

```text
- Checks should activate for BATCH_SLUG=01-runtime-substrate, skeleton-progress, skeleton-complete, or full/current-state as appropriate for the current runner.
- For other batches, preserve existing behavior.
- Report exact missing paths.
- Do not create missing paths.
- Do not require project-specific paths such as /workspace/repos/nca-art-grn.
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
```

---

### Task 3 — Add Batch 01 runtime contract and policy file checks

Implement only Task 3 after Task 2 passes.

Update only:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
```

Check for:

```text
/workspace/runtime/README.md
/workspace/runtime/volume_layout.md
/workspace/runtime/docker_policy.yaml
/workspace/runtime/compute_profiles.yaml
/workspace/runtime/terraform_policy.yaml
```

Requirements:

```text
- Treat `/workspace/runtime/volume_layout.md` as required for Batch 01 completion.
- Treat policy files as required if Batch 01 evidence claims Task 2 completed; otherwise report missing with WARN during skeleton-progress.
- Do not parse policy files deeply unless they already exist and parsing is trivial.
- If checking file content, only grep for safe markers such as `inspection`, `no secrets`, `no apply`, or `no live` where appropriate.
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
```

---

### Task 4 — Add runtime check script existence and syntax checks

Implement only Task 4 after Task 3 passes.

Update only:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
```

Check for:

```text
/workspace/scripts/runtime_checks/check_runpod_workspace.py
/workspace/scripts/runtime_checks/check_gpu_runtime.py
/workspace/scripts/runtime_checks/check_cuda_torch_runtime.py
/workspace/scripts/runtime_checks/check_docker_gpu_access.py
/workspace/scripts/runtime_checks/check_kubernetes_context.py
```

Requirements:

```text
- Use `python -m py_compile <file>` for existing files.
- Do not execute the readiness scripts unless the Batch 01 implementation evidence explicitly says they are safe no-arg checks.
- If python is missing, report WARN/BLOCKED according to current runner convention.
- Do not install Python packages.
- Do not call nvidia-smi, docker, terraform, kubectl, or torch from this task unless existing smoke conventions already classify those as optional WARN checks.
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
```

---

### Task 5 — Add remote model dummy client/router contract checks

Implement only Task 5 after Task 4 passes.

Update only:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
```

Check root:

```text
/workspace/repos/research-assistant
```

Check expected files:

```text
/workspace/repos/research-assistant/.env.example
/workspace/repos/research-assistant/runpod_brain_client.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/prompts.py
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/requirements.txt
```

Requirements:

```text
- Do not read or print actual .env files.
- Do not print values of RUNPOD_API_KEY, OPENROUTER_API_KEY, RUNPOD_ENDPOINT_ID, AI_MODEL, or any other env var.
- Do not call a live endpoint.
- Use syntax/import checks only if they are safe and do not trigger a provider call.
- Prefer `python -m py_compile` for `.py` files.
- If the dummy client has a documented offline smoke command and it is safe by construction, it may be run only if it does not require keys and does not call network.
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
```

---

### Task 6 — Add Batch 01 evidence checks without overwriting evidence

Implement only Task 6 after Task 5 passes.

Update only:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
```

Check:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Requirements:

```text
- Read existence only by default.
- Do not write or overwrite evidence.
- If checking content, grep only for safe non-secret section headings such as `Tasks executed`, `Safety confirmations`, `Integration request`, or `Smoke readiness`.
- Missing evidence must not produce a false PASS.
- Report exact missing paths.
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
```

---

### Task 7 — Optional: keep infra-tool presence checks in `60-infra-tools.smoke.sh`

Implement Task 7 only if the existing smoke design already uses `60-infra-tools.smoke.sh` for optional tool checks.

Allowed to update:

```text
/workspace/tests/smoke.d/60-infra-tools.smoke.sh
```

Optional WARN-level checks may include command presence only:

```text
nvidia-smi
docker
terraform
kubectl
python
```

Requirements:

```text
- Do not run docker containers.
- Do not run terraform init/plan/apply.
- Do not run kubectl apply.
- Do not modify Kubernetes context.
- Do not import torch here unless the existing module already does this safely.
- Missing tools should normally be WARN, not FAIL, for Batch 01 skeleton-progress.
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/60-infra-tools.smoke.sh
```

Skip this task if `60-infra-tools.smoke.sh` is absent or already covers these optional checks safely.

---

### Task 8 — Run final smoke validation

Implement only Task 8 after Tasks 1-6 pass and Task 7 is either completed or skipped.

Run syntax checks:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
test ! -f /workspace/tests/smoke.d/60-infra-tools.smoke.sh || bash --noprofile --norc -n /workspace/tests/smoke.d/60-infra-tools.smoke.sh
```

Run the Batch 01 smoke command:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
```

If `/workspace/scripts/smoke.sh` does not exist but `/workspace/scripts/smoke_current_state.sh` does, run:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

Requirements:

```text
- Do not fix implementation files from this smoke task.
- If implementation artifacts are missing, report the smoke result honestly.
- Do not create missing runtime roots or evidence.
- Record the smoke report path from the runner output if visible.
```

---

## Expected output from Codex

At the end, report:

```text
Changed files:
- /workspace/tests/smoke.d/10-core-layout.smoke.sh
- /workspace/tests/smoke.d/60-infra-tools.smoke.sh only if changed

Tests run:
- bash --noprofile --norc -n /workspace/tests/smoke.d/10-core-layout.smoke.sh
- optional syntax check for 60-infra-tools
- BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
  or fallback smoke_current_state.sh

Result:
- PASS/WARN/FAIL/BLOCKED according to runner output

Notes:
- Exact missing required paths if any
- Whether Batch 01 evidence exists
- Whether optional host-tool checks were WARN
- Confirmation that no implementation/config/infrastructure files were changed
```

## Suggested commit

```bash
git commit -m "test: add batch 01 runtime substrate smoke coverage"
```
