# PROJECT_CACHE — Skeleton-Dummy Batch Cache

## Batch identity

- Batch id: `01`
- Batch slug: `01-runtime-substrate`
- Layer: `Layer 1 — Runtime substrate`
- Bundle(s): `1 — Runpod portable runtime base`; `7 — Remote model brain endpoint`
- Step range from master: `1-14`
- Master file: `00_skeleton_dummy_master_implementation_companion.md`
- Batch plan file: `skeleton_dummy_codex_batch_plan.md`
- Batch mapping report: `Batch_Mapping_Report_—_Skeleton_Batches_01–24.docx`
- Mode: `skeleton-dummy`

## Current goal

Implement the first runtime substrate slice: predictable generic `/workspace` roots, safe readiness checks, runtime policy markers, and a thin dummy remote-model client/router contract.

The target outcome is:

```text
folders + marker/contract files + safe local check scripts + dummy JSON responses + smoke evidence
```

not:

```text
real science, real Runpod execution, Docker/Kubernetes mutation, live model calls, Agentfield orchestration, Paperclip integration, PKM indexing, LaTeX publishing, or config-tool changes
```

## Step background resolved for Batch 01

Batch 01 covers master orders 1-14:

1. `prepare_runpod_workspace`
2. `prepare_runpod_volume_layout`
3. `check_runpod_workspace`
4. `check_gpu_runtime`
5. `check_cuda_torch_runtime`
6. `prepare_docker_runtime_policy`
7. `check_docker_gpu_access`
8. `prepare_remote_compute_profile`
9. `prepare_terraform_runtime_policy`
10. `check_kubernetes_context`
11. `prepare_remote_model_client`
12. `check_runpod_brain_endpoint`
13. `prepare_brain_router_project`
14. `check_opencode_remote_model_config`

Batch mapping says this batch smokes runtime root creation, workspace storage layout, `check_runpod_workspace`, and the remote-model dummy client contract. The preferred smoke owner is the core-layout smoke domain, with infra-tools only for command/tool checks.

Layer 1 background says the runtime substrate should answer: can a clean local/WSL/Runpod runtime expose predictable roots, can GPU/CUDA/Docker/remote readiness be inspected without launching experiments, and can local code call a remote model through one stable contract.

Layer 1 correction says this batch stays generic: it may prepare storage roots that later project namespaces use, but it must not create research code or the NCA-ART-GRN project namespace.

## Repository/path authority

Create or preserve only generic roots here:

```text
/workspace/repos
/workspace/envs
/workspace/data
/workspace/runs
/workspace/artifacts
/workspace/models
/workspace/checkpoints
/workspace/logs
/workspace/runtime
/workspace/scripts/runtime_checks
/workspace/repos/research-assistant
```

Project-specific roots are out of scope for Batch 01 unless they already exist and are merely reported by a non-mutating check:

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

## Config tool boundary

The config tool is already implemented. It is a dependency, not this implementation target.

Allowed only for inspection if available and useful:

```text
config --target aiengineer config-show
config --target aiengineer bootstrap steps
sudo config --target aiengineer bootstrap status
lv
lv conda aiengineer
```

Forbidden:

```text
edit /home/vmuser/.local/bin/config.sh
edit /home/vmuser/.local/lib/config-sh/installers.sh
edit /home/vmuser/.local/etc/config-sh/*
run broad config bootstrap/install/mount/pull/push
run account create/remove commands
print credentials or private data
```

## Posthoc config integration bridge

Create the bridge at:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

Minimum fields:

```text
Role owner: operator/config plus aiengineer for /workspace/repos/research-assistant
Workspace root: /workspace and /workspace/repos/research-assistant
Commands to expose: safe runtime checks and remote model dummy smoke commands, or none if not implemented
Python packages needed: standard library only unless implementation truly requires more
Config integration needed: workspace-root, health-check, launcher, python-env, or none/deferred based on actual implementation
Smoke check: safe local command(s)
Output contract: created roots, policy files, check outputs, dummy client files
Config files that may later need a dedicated operator-side change: names only, or none
```

Do not decide final config step names; the later config-integration track will decide.
