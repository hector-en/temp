# 01 — Runtime Substrate and Remote Model Dummy Client — Skeleton-Dummy SPEC

## Purpose

Implement the skeleton-first version of the Layer 1 runtime substrate and thin remote-model client contract.

This batch should make the platform's generic runtime shape visible and testable while preserving boundaries for later research, Agentfield, Paperclip, PKM, and publisher work.

## Source of truth

Primary source:

```text
00_skeleton_dummy_master_implementation_companion.md
```

Use the master only for orders 1-14. Use PROJECT_CACHE.md for stable context.

Supplemental source for smoke/domain mapping:

```text
Batch_Mapping_Report_—_Skeleton_Batches_01–24.docx
```

Optional source when config workflow context is needed:

```text
CONFIG_TOOL.md
```

## In-scope steps

Only implement the steps listed here.

| Task | Master order | Step | Owner role | Target root | Skeleton output |
|---:|---:|---|---|---|---|
| 1 | 1 | `prepare_runpod_workspace` | operator/config | `/workspace` | generic roots: repos, envs, data, runs, artifacts, models, checkpoints, logs |
| 1 | 2 | `prepare_runpod_volume_layout` | operator/config | `/workspace/runtime` | volume layout contract/marker files |
| 2 | 3 | `check_runpod_workspace` | operator/config | `/workspace/scripts/runtime_checks` | non-mutating workspace readiness check |
| 2 | 4 | `check_gpu_runtime` | operator/config | `/workspace/scripts/runtime_checks` | GPU availability check that passes safely on CPU-only hosts |
| 2 | 5 | `check_cuda_torch_runtime` | operator/config | `/workspace/scripts/runtime_checks` | optional torch/CUDA import check without installing torch |
| 2 | 6 | `prepare_docker_runtime_policy` | operator/config | `/workspace/runtime` | `docker_policy.yaml` or equivalent |
| 2 | 7 | `check_docker_gpu_access` | operator/config | `/workspace/scripts/runtime_checks` | docker/GPU capability check that does not start containers |
| 2 | 8 | `prepare_remote_compute_profile` | operator/config | `/workspace/runtime` | local/runpod/kubernetes compute profiles |
| 2 | 9 | `prepare_terraform_runtime_policy` | operator/config | `/workspace/runtime` | inspection-only terraform policy stub |
| 2 | 10 | `check_kubernetes_context` | operator/config | `/workspace/scripts/runtime_checks` | kubectl context check that does not apply resources |
| 3 | 11 | `prepare_remote_model_client` | aiengineer/config | `/workspace/repos/research-assistant` | dummy remote model client contract files |
| 3 | 12 | `check_runpod_brain_endpoint` | aiengineer/config | `/workspace/repos/research-assistant` | env-name-only endpoint readiness check without printing secrets |
| 3 | 13 | `prepare_brain_router_project` | aiengineer/config | `/workspace/repos/research-assistant` | deterministic dummy router functions |
| 3 | 14 | `check_opencode_remote_model_config` | aiengineer/config | `/workspace/repos/research-assistant` | non-overwriting OpenCode/model-alias config check |

## Out of scope

Do not implement anything outside the in-scope table.

Explicitly out of scope unless named above:

```text
/workspace/repos/nca-art-grn creation
/workspace/data/nca-art-grn creation
real NCA/ART/PDE/ODE science
real simulations or model training
real Runpod job submission
Docker builds or container starts
terraform init/apply/plan against live infra
kubectl apply or cluster mutation
real remote model/provider API calls
Agentfield server/controller work
Paperclip adapter work
OpenClaw/PKM indexing
LaTeX/paper build
config-tool internal changes
```

## Required behavior

- Create directories and placeholder files only if missing.
- Do not overwrite existing user files.
- Checks must be safe, local, non-mutating, and deterministic.
- CPU-only machines must produce a clear skip/unavailable status, not fail the whole skeleton.
- Docker/Kubernetes/Terraform checks must inspect command availability/config only and must not mutate infrastructure.
- Remote-model client must return deterministic dummy JSON when no key is configured.
- Endpoint checks must report only whether expected environment variable names are present; never print secret values.
- If live behavior is scaffolded, it must be behind an explicit future flag and default to disabled.
- Keep side effects local to the target paths in this SPEC and postcheck/recording roots.

## Expected file/path map

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
/workspace/runtime/docker_policy.yaml
/workspace/runtime/compute_profiles.yaml
/workspace/runtime/terraform_policy.yaml
/workspace/scripts/runtime_checks/check_runpod_workspace.py
/workspace/scripts/runtime_checks/check_gpu_runtime.py
/workspace/scripts/runtime_checks/check_cuda_torch_runtime.py
/workspace/scripts/runtime_checks/check_docker_gpu_access.py
/workspace/scripts/runtime_checks/check_kubernetes_context.py
/workspace/repos/research-assistant/README.md
/workspace/repos/research-assistant/.env.example
/workspace/repos/research-assistant/requirements.txt
/workspace/repos/research-assistant/runpod_brain_client.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/prompts.py
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/check_runpod_brain_endpoint.py
/workspace/repos/research-assistant/check_opencode_remote_model_config.py
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Equivalent package-style layouts under `/workspace/repos/research-assistant/research_assistant/` are acceptable if the same command contracts and filenames are documented in POSTCHECK.md.

## Output contract

The batch must produce or preserve these outputs:

```text
Generic /workspace storage roots exist and are writable/readable where permissions allow.
Runtime layout contract exists and states project namespaces are created by later batches.
Runtime policies exist for Docker, remote compute profiles, and Terraform inspection-only behavior.
Safe readiness checks report status without mutating infrastructure.
Remote model dummy client can be imported or run locally and returns deterministic dummy JSON without keys.
Brain router exposes execute(task), analyze(task), summarize(task), triage_failure(task), rank_hypothesis(task), and draft_section(task) using a dummy backend.
Endpoint config check reports presence/absence of RUNPOD_API_KEY, OPENROUTER_API_KEY, RUNPOD_ENDPOINT_ID, and AI_MODEL without revealing values.
OpenCode config check reports present/missing alignment without overwriting editor config.
Postcheck and integration request evidence are written when /mnt/egress is writable.
```

## Smoke alignment

Batch mapping identifies the preferred smoke owner as `10-core-layout.smoke.sh`, with `60-infra-tools.smoke.sh` only for explicit tool checks. The implementation should leave evidence that can be consumed by:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
```

Fallback if the current runner is still named `smoke_current_state.sh`:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

Do not create or modify smoke.d modules in this batch unless RUN_INSTRUCTIONS.md explicitly adds it. This package does not add that scope.

## Posthoc config integration request

Create:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Include at minimum:

```text
Role owner
Workspace root
Commands to expose
Python packages needed
Config integration needed
Smoke check
Output contract
Deferred/none if no config integration is needed
```

This file is only a bridge for later operator/config integration. Do not edit config/lv/workflow files in this batch.

## Acceptance criteria

- All generic runtime roots exist.
- `/workspace/runtime` contains the required policy/contract files.
- Check scripts syntax-check and run without mutating external systems.
- Remote model dummy client and router syntax-check and return deterministic dummy output without keys.
- No research repo, Agentfield repo, Paperclip adapter, OpenClaw workspace, PKM vault, or paper project is created by this batch.
- No config tool internals are modified.
- No broad setup or live external work is run.
- No credentials/private data are read or printed.
- Postcheck log is written or a clear note is made if `/mnt/egress` is unavailable.
- INTEGRATION_REQUEST.md is written when `/mnt/egress` is writable, or explicitly marked not-created/unavailable in the postcheck.

## Validation commands

Use only safe, local validation. Adapt paths if the implementation documents equivalent package-style locations.

```bash
# Path checks
test -d /workspace/repos
test -d /workspace/envs
test -d /workspace/data
test -d /workspace/runs
test -d /workspace/artifacts
test -d /workspace/models
test -d /workspace/checkpoints
test -d /workspace/logs
test -f /workspace/runtime/volume_layout.md
test -f /workspace/runtime/docker_policy.yaml
test -f /workspace/runtime/compute_profiles.yaml
test -f /workspace/runtime/terraform_policy.yaml
test -f /workspace/repos/research-assistant/runpod_brain_client.py
test -f /workspace/repos/research-assistant/brain_router.py

# Python syntax checks
python -m py_compile /workspace/scripts/runtime_checks/check_runpod_workspace.py
python -m py_compile /workspace/scripts/runtime_checks/check_gpu_runtime.py
python -m py_compile /workspace/scripts/runtime_checks/check_cuda_torch_runtime.py
python -m py_compile /workspace/scripts/runtime_checks/check_docker_gpu_access.py
python -m py_compile /workspace/scripts/runtime_checks/check_kubernetes_context.py
python -m py_compile /workspace/repos/research-assistant/runpod_brain_client.py
python -m py_compile /workspace/repos/research-assistant/brain_router.py
python -m py_compile /workspace/repos/research-assistant/smoke_test.py
python /workspace/repos/research-assistant/smoke_test.py
```
