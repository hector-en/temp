# SMOKE-01 — Batch 01 Runtime Substrate Smoke.d Update SPEC

## Purpose

Update the dynamic smoke test coverage for skeleton Batch 01, `01-runtime-substrate`.

This is not an implementation batch for the runtime substrate itself. It is a smoke-test batch that verifies the outputs expected from Batch 01 after Codex has implemented:

```text
runtime roots + runtime policy/check files + remote model dummy client/router contract + batch evidence
```

The smoke must be safe, idempotent, local-first, phase-aware, and evidence-aware.

## Source of truth

Primary source for Batch 01 behavior:

```text
codex_skeleton_batch_01_runtime-substrate/SPEC.md
codex_skeleton_batch_01_runtime-substrate/RUN_INSTRUCTIONS.md
codex_skeleton_batch_01_runtime-substrate/PROJECT_CACHE.md
codex_skeleton_batch_01_index.md
```

Primary source for smoke design:

```text
Smoke.d Batch Mapping Report — Skeleton Batches 01–24
Batch 01 Smoke.d Analysis Report — 01-runtime-substrate
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
existing /workspace/scripts/smoke.sh or /workspace/scripts/smoke_current_state.sh
existing /workspace/tests/smoke.d/*.smoke.sh
```

Do not reread the full master implementation companion unless the current files or evidence conflict with this SPEC.

## Cache-stable Batch 01 summary

Batch identity:

```text
Batch: 01
Slug: 01-runtime-substrate
Layer: Layer 1 — Runtime substrate
Bundles: Bundle 1 — Runpod portable runtime base; Bundle 7 — Remote model brain endpoint
Master order range: 1-14
Phase: skeleton-progress
```

Batch 01 implementation tasks:

```text
Task 1 — Generic runtime roots and volume layout
Task 2 — Safe runtime policies and readiness checks
Task 3 — Remote model dummy client and brain router contract
```

Batch 01 steps being smoked:

| Order | Step | Smoke meaning |
|---:|---|---|
| 1 | `prepare_runpod_workspace` | generic runtime roots exist |
| 2 | `prepare_runpod_volume_layout` | `/workspace/runtime/volume_layout.md` contract exists |
| 3 | `check_runpod_workspace` | safe workspace readiness script exists and compiles |
| 4 | `check_gpu_runtime` | GPU check script exists and is safe on CPU-only hosts |
| 5 | `check_cuda_torch_runtime` | CUDA/Torch check script exists and does not install torch |
| 6 | `prepare_docker_runtime_policy` | Docker policy marker exists and is non-secret/non-live |
| 7 | `check_docker_gpu_access` | Docker GPU check exists and does not start containers |
| 8 | `prepare_remote_compute_profile` | compute profile placeholder exists |
| 9 | `prepare_terraform_runtime_policy` | Terraform policy marker exists and is inspection-only |
| 10 | `check_kubernetes_context` | kubectl context check exists and does not mutate clusters |
| 11 | `prepare_remote_model_client` | dummy remote model client contract exists |
| 12 | `check_runpod_brain_endpoint` | endpoint env-name-only readiness check exists |
| 13 | `prepare_brain_router_project` | deterministic dummy router functions exist |
| 14 | `check_opencode_remote_model_config` | non-overwriting model alias/config check exists |

## Smoke module selection

Primary module to update:

```text
/workspace/tests/smoke.d/10-core-layout.smoke.sh
```

Reason:

Batch 01 is primarily a runtime layout and root-contract smoke. The remote model dummy client contract is also part of Layer 1, but it is still a local/offline file-contract check.

Optional secondary module:

```text
/workspace/tests/smoke.d/60-infra-tools.smoke.sh
```

Only update this file if the current smoke design already uses it for host tool-presence checks and a small non-mutating addition is necessary. Do not move Batch 01 required file-contract checks into `60-infra-tools.smoke.sh`.

Do not create:

```text
/workspace/tests/smoke.d/01-runtime-substrate.smoke.sh
```

The smoke model is domain-based, not one smoke module per batch.

## Required paths to smoke

Generic runtime roots:

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

Runtime contract and policy files:

```text
/workspace/runtime/README.md
/workspace/runtime/volume_layout.md
/workspace/runtime/docker_policy.yaml
/workspace/runtime/compute_profiles.yaml
/workspace/runtime/terraform_policy.yaml
```

Runtime check scripts:

```text
/workspace/scripts/runtime_checks/check_runpod_workspace.py
/workspace/scripts/runtime_checks/check_gpu_runtime.py
/workspace/scripts/runtime_checks/check_cuda_torch_runtime.py
/workspace/scripts/runtime_checks/check_docker_gpu_access.py
/workspace/scripts/runtime_checks/check_kubernetes_context.py
```

Remote model dummy client/router root:

```text
/workspace/repos/research-assistant
```

Expected remote model dummy client/router contract files:

```text
/workspace/repos/research-assistant/.env.example
/workspace/repos/research-assistant/runpod_brain_client.py
/workspace/repos/research-assistant/brain_router.py
/workspace/repos/research-assistant/prompts.py
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/research-assistant/requirements.txt
```

Batch evidence:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

## Required smoke behavior

For phase `skeleton-progress` with:

```bash
BATCH_SLUG="01-runtime-substrate"
```

the primary smoke module should verify Batch 01 required paths and contracts.

Expected classifications:

```text
PASS  — required Batch 01 roots/files/evidence exist and safe scripts compile.
WARN  — optional host capabilities are absent or env vars are not configured.
SKIP  — Batch 01-specific checks are not applicable for another batch/phase.
FAIL  — required Batch 01 artifacts are missing after Batch 01 claims completion, or a safety violation is detected.
BLOCKED — use only if the current runner supports it; otherwise represent blocked state using the runner's existing WARN/FAIL convention.
```

The smoke must preserve the current runner convention. If current modules are simple scripts emitting `PASS:`, `WARN:`, `SKIP:`, or `FAIL:`, use that style. If current modules implement `detect`/`run`, preserve that interface.

## Required safety boundaries

The smoke must not:

```text
install packages
edit config/lv/workflow files
run broad bootstrap
launch Runpod
call Runpod APIs
call OpenRouter or other model/provider APIs
print secrets or env values
start Docker containers
run Docker builds
run terraform init/plan/apply
run kubectl apply
mutate Kubernetes context/resources
run science simulations
train models
start Agentfield
run Paperclip
run OpenClaw agents
scan private vaults or datasets
create project-specific research namespaces
```

Batch 01 smoke must not require or create:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
/workspace/repos/agentfield
/workspace/repos/paperclip-agentfield-adapter
/workspace/repos/openclaw-workspace
/workspace/pkm/zettelkasten
/workspace/artifacts/papers/grn-paper
```

## Acceptance criteria

- `10-core-layout.smoke.sh` checks Batch 01 runtime root and contract files when `BATCH_SLUG=01-runtime-substrate`.
- The smoke checks `/workspace/runtime`, `/workspace/scripts/runtime_checks`, and `/workspace/repos/research-assistant` contracts.
- Python readiness scripts are syntax-checked with `python -m py_compile` only.
- Remote model dummy client/router checks are import/syntax/offline-contract checks only.
- Missing optional host tools or env vars are WARN, not hard failures.
- Missing required Batch 01 paths/evidence produce exact path messages.
- The smoke does not require later batch namespaces.
- The smoke does not modify implementation files, config internals, infrastructure, credentials, or external services.
- The smoke runner completes and writes a normal smoke report under `/workspace/runs/smoke/...`.
