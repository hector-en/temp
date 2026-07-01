# Codex Skeleton Batch 01 Index — Runtime Substrate

Batch slug: `01-runtime-substrate`

## Scope

Layer 1 / Bundle 1 + 7: runtime roots, Runpod workspace checks, runtime policies, safe infrastructure readiness checks, and a thin remote-model dummy client/router contract.

## Generated package

```text
codex_skeleton_batch_01_runtime-substrate.zip
codex_skeleton_batch_01_runtime-substrate/CODEX_PROMPT.txt
codex_skeleton_batch_01_runtime-substrate/PROJECT_CACHE.md
codex_skeleton_batch_01_runtime-substrate/SPEC.md
codex_skeleton_batch_01_runtime-substrate/RUN_INSTRUCTIONS.md
codex_skeleton_batch_01_runtime-substrate/POSTCHECK_TEMPLATE.md
```

## Expected workspace root

```text
/workspace
/workspace/runtime
/workspace/scripts/runtime_checks
/workspace/repos/research-assistant
```

## Expected recording root

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate
```

Expected evidence files:

```text
POSTCHECK.md
INTEGRATION_REQUEST.md
```

## Companion-doc root

If available to the Codex runtime, use current companion docs only as trajectory context:

```text
/mnt/ingress/infra/skeleton/companion
```

Do not require this path for first-batch implementation.

## Steps covered

Master orders 1-14:

```text
prepare_runpod_workspace
prepare_runpod_volume_layout
check_runpod_workspace
check_gpu_runtime
check_cuda_torch_runtime
prepare_docker_runtime_policy
check_docker_gpu_access
prepare_remote_compute_profile
prepare_terraform_runtime_policy
check_kubernetes_context
prepare_remote_model_client
check_runpod_brain_endpoint
prepare_brain_router_project
check_opencode_remote_model_config
```

## Smoke alignment

Preferred smoke domain: `10-core-layout.smoke.sh`.
Secondary smoke domain: `60-infra-tools.smoke.sh` only if explicit command/tool checks are created.

Suggested existing runner command:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
```

Fallback:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

## Hard guardrails

```text
Do not edit config tool internals.
Do not create /workspace/repos/nca-art-grn in Batch 01.
Do not run Docker containers.
Do not run terraform init/plan/apply.
Do not run kubectl apply.
Do not launch Runpod jobs.
Do not call live model/provider APIs.
Do not print secrets or credential values.
Do not overwrite existing user files.
```
