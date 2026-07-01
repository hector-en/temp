# 01 — Runtime Substrate and Remote Model Dummy Client — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
SPEC.md
PROJECT_CACHE.md
```

Read `CONFIG_TOOL.md` only if available and needed to confirm config/lv boundaries. Do not edit config internals.

## Current status

```text
Master file exists and is authoritative.
This batch is skeleton-dummy only.
The config tool is out of scope and must not be edited.
Batch 01 is the generic runtime foundation plus a thin remote-model dummy client contract.
```

## Stable context pack

You are implementing only the in-scope steps from SPEC.md.

Rules:

```text
Do not scan the whole repo.
Do not edit config tool internals.
Do not run broad setup commands.
Do not run live external services.
Do not overwrite existing user work.
Create only generic runtime roots, marker/policy files, safe readiness checks, dummy client/router files, and smoke evidence.
```

## Tasks

### Task 1 — Generic runtime roots and volume layout

Implement only Task 1.

Read only:

```text
PROJECT_CACHE.md
SPEC.md
```

Create/update only if missing:

```text
/workspace/repos/
/workspace/envs/
/workspace/data/
/workspace/runs/
/workspace/artifacts/
/workspace/models/
/workspace/checkpoints/
/workspace/logs/
/workspace/runtime/README.md
/workspace/runtime/volume_layout.md
```

Requirements:

```text
- Create the generic runtime roots named in SPEC.md.
- Do not create project-specific paths such as /workspace/repos/nca-art-grn.
- Write a compact volume layout contract explaining root responsibilities and that project namespaces are created by later batches.
- Preserve existing files; only create missing marker/contract files.
```

Validation:

```bash
test -d /workspace/repos
test -d /workspace/envs
test -d /workspace/data
test -d /workspace/runs
test -d /workspace/artifacts
test -d /workspace/models
test -d /workspace/checkpoints
test -d /workspace/logs
test -f /workspace/runtime/volume_layout.md
```

### Task 2 — Safe runtime policies and readiness checks

Implement only Task 2 after Task 1 passes.

Read only:

```text
/workspace/runtime/volume_layout.md
SPEC.md
PROJECT_CACHE.md
```

Create/update only if missing:

```text
/workspace/runtime/docker_policy.yaml
/workspace/runtime/compute_profiles.yaml
/workspace/runtime/terraform_policy.yaml
/workspace/scripts/runtime_checks/check_runpod_workspace.py
/workspace/scripts/runtime_checks/check_gpu_runtime.py
/workspace/scripts/runtime_checks/check_cuda_torch_runtime.py
/workspace/scripts/runtime_checks/check_docker_gpu_access.py
/workspace/scripts/runtime_checks/check_kubernetes_context.py
```

Requirements:

```text
- `check_runpod_workspace.py` reports root path exists, owner if available, mode if available, writable/readable status, and optional Runpod marker. It may create no experiments.
- `check_gpu_runtime.py` checks for `nvidia-smi`; CPU-only hosts should report unavailable/skip and exit safely.
- `check_cuda_torch_runtime.py` imports torch only if installed; otherwise report missing/skip. Do not install torch.
- `docker_policy.yaml` describes Docker image/config/persistent volume responsibilities and says no secrets in images.
- `check_docker_gpu_access.py` checks docker command presence and static GPU flag support only; do not pull, build, or start containers.
- `compute_profiles.yaml` contains placeholders for local, runpod-pod, runpod-serverless, and kubernetes-dev.
- `terraform_policy.yaml` documents inspection-only skeleton behavior; no terraform init/plan/apply.
- `check_kubernetes_context.py` checks kubectl availability/current context only; no kubectl apply or resource mutation.
```

Validation:

```bash
python -m py_compile /workspace/scripts/runtime_checks/check_runpod_workspace.py
python -m py_compile /workspace/scripts/runtime_checks/check_gpu_runtime.py
python -m py_compile /workspace/scripts/runtime_checks/check_cuda_torch_runtime.py
python -m py_compile /workspace/scripts/runtime_checks/check_docker_gpu_access.py
python -m py_compile /workspace/scripts/runtime_checks/check_kubernetes_context.py
python /workspace/scripts/runtime_checks/check_runpod_workspace.py
python /workspace/scripts/runtime_checks/check_gpu_runtime.py || true
python /workspace/scripts/runtime_checks/check_cuda_torch_runtime.py || true
python /workspace/scripts/runtime_checks/check_docker_gpu_access.py || true
python /workspace/scripts/runtime_checks/check_kubernetes_context.py || true
test -f /workspace/runtime/docker_policy.yaml
test -f /workspace/runtime/compute_profiles.yaml
test -f /workspace/runtime/terraform_policy.yaml
```

### Task 3 — Remote model dummy client and brain router contract

Implement only Task 3 after Task 2 passes.

Read only:

```text
SPEC.md
PROJECT_CACHE.md
/workspace/runtime/compute_profiles.yaml
```

Create/update only if missing:

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

Requirements:

```text
- Keep the remote model layer minimal: local code -> remote model -> response.
- `runpod_brain_client.py` must return deterministic dummy JSON by default and must not call any provider API without a future explicit live flag.
- `.env.example` may name expected variables but must not contain real secrets.
- `check_runpod_brain_endpoint.py` checks only whether RUNPOD_API_KEY, OPENROUTER_API_KEY, RUNPOD_ENDPOINT_ID, and AI_MODEL are set; it must not print values.
- `brain_router.py` must expose execute(task), analyze(task), summarize(task), triage_failure(task), rank_hypothesis(task), and draft_section(task) using the dummy backend.
- `check_opencode_remote_model_config.py` may inspect likely config paths if present but must not overwrite editor/OpenCode config and must not print secrets.
- `smoke_test.py` must run locally and prove the dummy client/router contract without keys.
```

Validation:

```bash
python -m py_compile /workspace/repos/research-assistant/runpod_brain_client.py
python -m py_compile /workspace/repos/research-assistant/brain_router.py
python -m py_compile /workspace/repos/research-assistant/check_runpod_brain_endpoint.py
python -m py_compile /workspace/repos/research-assistant/check_opencode_remote_model_config.py
python -m py_compile /workspace/repos/research-assistant/smoke_test.py
python /workspace/repos/research-assistant/smoke_test.py
python /workspace/repos/research-assistant/check_runpod_brain_endpoint.py || true
python /workspace/repos/research-assistant/check_opencode_remote_model_config.py || true
```

## Final validation

Run only safe, local validation:

```bash
test -d /workspace/repos && test -d /workspace/envs && test -d /workspace/data && test -d /workspace/runs && test -d /workspace/artifacts && test -d /workspace/models && test -d /workspace/checkpoints && test -d /workspace/logs
python -m py_compile /workspace/scripts/runtime_checks/check_runpod_workspace.py /workspace/scripts/runtime_checks/check_gpu_runtime.py /workspace/scripts/runtime_checks/check_cuda_torch_runtime.py /workspace/scripts/runtime_checks/check_docker_gpu_access.py /workspace/scripts/runtime_checks/check_kubernetes_context.py
python -m py_compile /workspace/repos/research-assistant/runpod_brain_client.py /workspace/repos/research-assistant/brain_router.py /workspace/repos/research-assistant/smoke_test.py /workspace/repos/research-assistant/check_runpod_brain_endpoint.py /workspace/repos/research-assistant/check_opencode_remote_model_config.py
python /workspace/repos/research-assistant/smoke_test.py
```

Optional existing smoke runner, only if it already exists:

```bash
if [ -x /workspace/scripts/smoke.sh ] || [ -f /workspace/scripts/smoke.sh ]; then BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress; fi
if [ ! -f /workspace/scripts/smoke.sh ] && [ -f /workspace/scripts/smoke_current_state.sh ]; then BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke_current_state.sh skeleton-progress; fi
```

## Postcheck log

Create:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
```

Use the format in POSTCHECK_TEMPLATE.md and include:

```text
01 postcheck
Date: <date>
Status: PASS|FAIL

Changed files:
- <path>

Tasks executed:
- Task 1 — Generic runtime roots and volume layout
- Task 2 — Safe runtime policies and readiness checks
- Task 3 — Remote model dummy client and brain router contract

Tests run:
- <command>

Results:
- PASS|FAIL

Safety confirmations:
- No config tool internals were edited.
- No broad bootstrap/install/mount/pull/push commands were run.
- No account mutations were run.
- No Docker builds, Kubernetes applies, Runpod jobs, OpenClaw agents, training, or inference jobs were run.
- No credentials, private notes, vault contents, datasets, API keys, or manuscript text were read or printed.
- Existing user files were not overwritten.
- No project-specific research namespace was created by Batch 01.

Notes:
- <notes>
```

If `/mnt/egress/dev-recordings/skeleton/01-runtime-substrate` is not writable, write POSTCHECK.md under the nearest writable local run output and report the actual path.

## Integration request

Create:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Use it only as a posthoc bridge. Do not decide final config step names here. Do not edit config/lv/bootstrap files in this implementation batch.

Minimum content:

```text
Role owner: operator/config for /workspace roots and runtime checks; aiengineer for /workspace/repos/research-assistant
Workspace root: /workspace; /workspace/repos/research-assistant
Commands to expose: list actual safe check/smoke commands implemented, or none
Python packages needed: standard library only unless actual implementation needs more
Config integration needed: deferred; likely workspace-root plus health-check/launcher exposure if operator approves
Smoke check: safe local command(s) used
Output contract: roots, runtime policy files, readiness reports, dummy remote model client/router response
Operator/config notes: do not edit config internals; later operator-side batch decides bootstrap/profile/alias exposure
```

If `/mnt/egress/dev-recordings/skeleton/01-runtime-substrate` is not writable, record this in POSTCHECK.md.

## Output summary for Codex response

At the end, report only:

```text
Changed files:
Validation run:
Postcheck log:
Integration request:
Notes:
```
