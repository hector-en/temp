# SPEC_Layer01_runtime_substrate

Status: current Layer 1 product/specification file.  
Layer: **Layer 1 — Runtime substrate**.  
Primary skeleton batch: **Batch 01 / `01-runtime-substrate`**.  
Operational authority: `final_workflow.md`, `smoke_module_update_workflow.md`, and `day_to_day_skeleton_run.md`.  
Batch slicing authority: `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md`.

## Purpose

`SPEC_Layer01_runtime_substrate` defines the runtime substrate that later skeleton batches can trust before they create research, PKM, publishing, Agentfield, Paperclip, or campaign surfaces.

Layer 1 prepares the generic machine/runtime foundation for local, WSL, and RunPod-style execution. It creates generic `/workspace` roots, runtime-readiness checks, runtime policies, remote-compute placeholders, and a thin remote-model dummy contract.

Layer 1 is intentionally small. It is **not** the research workspace, not the NCA-ART-GRN implementation, not Agentfield, not Paperclip, not OpenClaw, not PKM, not LaTeX publishing, and not a live RunPod training loop.

## Product goal

Create a reliable machine and remote-model foundation before any research, publishing, Agentfield, or Paperclip automation is built.

## Product meaning

Layer 1 exists so later developers do not build on accidental local state. It answers the most basic platform question: before any science or orchestration exists, can the machine be trusted as a stable runtime substrate?

The layer should let an operator or developer start from a clean local machine, WSL environment, or RunPod pod and know exactly where durable state belongs. It separates platform state from project code, and it makes that separation visible through `/workspace` roots, runtime contracts, and non-mutating readiness checks.

Layer 1 gives later developers three guarantees:

```text
1. Filesystem guarantee:
   shared platform roots exist before project-specific repositories and outputs are created.

2. Runtime guarantee:
   GPU, CUDA/Torch, Docker, Terraform, Kubernetes, and remote-compute readiness can be inspected safely.

3. Model-contract guarantee:
   local code can use one minimal remote-model client contract that returns deterministic dummy responses unless live credentials and live mode are explicitly enabled later.
```

Downstream layers use these guarantees as dependencies:

```text
Layer 2 uses the roots to create role workstations and the NCA-ART-GRN research repo.
Layer 3 uses the roots for real data, run outputs, artifacts, checkpoints, and RunPod dry-runs.
Layer 4 uses the remote-model contract and artifact roots for OpenClaw/PKM reasoning without owning the runtime.
Layer 5 uses the same roots and contracts through Agentfield, the Paperclip adapter, and campaign orchestration.
```

## Source priority and update rule

Use this order when sources disagree:

```text
1. 00_A1_skeleton_dummy_codex_batch_plan_v2.md and 00_A2_skeleton_batch_mapping_report_batches_01_24.md
   are the current batch-slicing and smoke-mapping authority.
2. final_workflow.md, smoke_module_update_workflow.md, and day_to_day_skeleton_run.md
   are the current operational authority for smoke, evidence, companion timing, and stop/continue rules.
3. Product-owner layer files explain product meaning and semantics.
4. Older platform-plan notes are background only; discard outdated naming or batch placement when contradicted by A1/A2.
```

Important correction applied here:

```text
The workspace-boundary annex previously named
SPEC_Layer01_02-research-workspace-ANX01_workspace_boundaries.md
belongs to Layer 2, because Batch 02 implements prepare_nca_art_workspace and project-specific research namespaces.

The corrected annex name is:
SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md
```

Layer 1 may reference that annex as a boundary guard, but Layer 1 does not own it.

## Layer answers

```text
Can I start from a clean local/WSL/RunPod runtime and know where everything lives?
Can later bundles rely on stable roots for repos, data, runs, artifacts, models, checkpoints, envs, and logs?
Can workspace, GPU, CUDA/Torch, Docker, Terraform, Kubernetes, and remote-compute readiness be checked safely?
Can local code call a remote model through one stable contract without each tool inventing its own RunPod/model client?
Can the skeleton prove file/contract/readiness shape without running real science, mutating infrastructure, or calling live paid services by default?
```

## Layer boundary

### Should do

```text
prepare generic /workspace storage roots
prepare persistent-volume layout notes and marker files
prepare /workspace/runtime policy/config placeholders
prepare /workspace/scripts/runtime_checks for safe non-mutating check wrappers
check workspace path readiness
check GPU visibility safely
check CUDA/Torch readiness safely if torch is installed
prepare Docker/runtime policy stubs
check Docker/GPU access without starting containers
prepare remote compute profile placeholders
prepare Terraform runtime policy stubs
check Kubernetes context without applying resources
prepare a thin remote model client contract in /workspace/repos/research-assistant
check remote model endpoint configuration without printing secrets
prepare deterministic dummy router functions for later layers
check editor/OpenCode remote model alignment without overwriting config
create implementation evidence under /mnt/egress/dev-recordings/skeleton/01-runtime-substrate during Codex skeleton runs
create POSTCHECK.md and INTEGRATION_REQUEST.md evidence during the implementation batch
```

### Should not do

```text
not create /workspace/repos/nca-art-grn
not create project-specific research implementation folders
not create real research data, run, artifact, model, or checkpoint namespaces
not run GRN simulations
not train NCA models
not run ART discovery
not launch RunPod jobs
not call the RunPod API by default
not pull or build Docker images
not start Docker containers
not run terraform init, terraform plan, or terraform apply
not apply Kubernetes resources
not call paid/live model APIs by default
not build Agentfield
not build Paperclip adapter
not build OpenClaw reasoning workflows
not build PKM or LaTeX publishing structures
not read or print secrets
not edit the config tool
not edit /home/vmuser/.local/bin/config.sh
not edit /home/vmuser/.local/lib/config-sh/installers.sh
not edit /home/vmuser/.local/etc/config-sh
```

## Bundles in this layer

```text
Bundle 1 — RunPod portable runtime base
Bundle 7 — Remote model brain endpoint
```

Some items are concretizations inside those bundles, not standalone bundles:

```text
prepare_docker_runtime_policy
check_docker_gpu_access
prepare_remote_compute_profile
prepare_terraform_runtime_policy
check_kubernetes_context
```

## Key concretizations

### Batch 01 implementable step set

| Order | Bundle | Step | Type | Skeleton action | Must remain safe by default |
|---:|---|---|---|---|---|
| 1 | Bundle 1 | `prepare_runpod_workspace` | setup | Create generic roots only: `/workspace/repos`, `/workspace/envs`, `/workspace/data`, `/workspace/runs`, `/workspace/artifacts`, `/workspace/models`, `/workspace/checkpoints`, `/workspace/logs`. | Do not create research code or project namespaces. |
| 2 | Bundle 1 | `prepare_runpod_volume_layout` | setup | Write README/marker files explaining root responsibilities. | Do not create experiments. |
| 3 | Bundle 1 | `check_runpod_workspace` | check | Print readiness table: path exists, owner, mode, writable, optional RunPod marker. | Non-mutating report only. |
| 4 | Bundle 1 | `check_gpu_runtime` | check | Check `nvidia-smi` if present; CPU/local dev reports GPU unavailable without failing skeleton. | No GPU job launch. |
| 5 | Bundle 1 | `check_cuda_torch_runtime` | check | Check target Python can import torch only if installed; report missing/skip otherwise. | Do not install torch. |
| 6 | Bundle 1 | `prepare_docker_runtime_policy` | template | Create Docker policy describing image/config/persistent-volume responsibilities. | No build, pull, or container start. |
| 7 | Bundle 1 | `check_docker_gpu_access` | check | Check docker command availability and whether GPU flags look supported. | Do not start containers. |
| 8 | Bundle 1 | `prepare_remote_compute_profile` | template | Create placeholders for `local`, `runpod-pod`, `runpod-serverless`, and `kubernetes-dev`. | No remote compute calls. |
| 9 | Bundle 1 | `prepare_terraform_runtime_policy` | template | Create Terraform inspection-only policy stub. | No `terraform init`, `plan`, or `apply`. |
| 10 | Bundle 1 | `check_kubernetes_context` | check | Check `kubectl` context if available. | Do not apply resources. |
| 11 | Bundle 7 | `prepare_remote_model_client` | template | Create `/workspace/repos/research-assistant` with `.env.example`, `runpod_brain_client.py`, `brain_router.py`, `prompts.py`, `smoke_test.py`, and `requirements.txt`; dummy backend returns JSON without keys. | No live model call by default. |
| 12 | Bundle 7 | `check_runpod_brain_endpoint` | check | Check env variable names only: `RUNPOD_API_KEY` or `OPENROUTER_API_KEY`, `RUNPOD_ENDPOINT_ID`, `AI_MODEL`. | Do not print secret values; do not call endpoint by default. |
| 13 | Bundle 7 | `prepare_brain_router_project` | template | Create deterministic dummy router functions: `execute`, `analyze`, `summarize`, `triage_failure`, `rank_hypothesis`, `draft_section`. | No Agentfield/OpenClaw/Paperclip logic. |
| 14 | Bundle 7 | `check_opencode_remote_model_config` | check | Check whether editor/OpenCode config points to the same model alias. | Do not overwrite editor config. |

## Corrected namespace rule

Layer 1 should not create research code, but it should prepare storage roots that later bundles can use consistently:

```text
/workspace/repos/
/workspace/envs/
/workspace/data/
/workspace/runs/
/workspace/artifacts/
/workspace/models/
/workspace/checkpoints/
/workspace/logs/
/workspace/runtime/
/workspace/scripts/runtime_checks/
```

Later bundles create project-specific paths under those roots, for example:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
/workspace/models/nca-art-grn
/workspace/checkpoints/nca-art-grn
```

Therefore:

```text
prepare_runpod_workspace = generic platform roots and runtime substrate
prepare_nca_art_workspace = later research repository skeleton, owned by Layer 2 Batch 02
prepare_experiment_output_layout = later project-specific data/run/artifact namespaces, owned by Layer 2 Batch 02
```

## Batch -> layer implementation map

Read this map as **batch -> what that batch implements or consumes from Layer 1**.

### Batch 01 / `01-runtime-substrate` implements Layer 1 directly

Batch 01 is the only batch that implements Layer 1. It covers:

```text
Layer 1 / Bundle 1 — RunPod portable runtime base
Layer 1 / Bundle 7 — Remote model brain endpoint
```

The corrected smoke mapping for Batch 01 is:

```text
10-core-layout.smoke.sh
  verifies generic /workspace roots, /workspace/runtime, and basic runner/report roots

60-infra-tools.smoke.sh
  verifies safe command presence/readiness only for docker, terraform, kubectl, runpod, and GPU checks

90-research-assistant.smoke.sh
  verifies /workspace/repos/research-assistant, Python compile, and the deterministic dummy answer path
```

Batch 01 must not create `/workspace/repos/nca-art-grn`, launch RunPod, start containers, call model APIs, or mutate Terraform/Kubernetes state.

### Batch 02 / `02-research-workspace` consumes Layer 1 and owns the workspace-boundary annex

Batch 02 does not implement Layer 1. It implements Layer 2 / Bundle 2. It consumes generic roots created by Batch 01 and creates:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

The detailed workspace-boundary annex must be treated as Layer 2:

```text
SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md
```

Layer 1 should link this annex only as a downstream boundary reference.

### Later batches consume Layer 1 contracts but do not implement Layer 1

```text
Batch 13 / runpod-dryrun consumes runtime roots and remote-compute policy placeholders.
Batch 14-15 / OpenClaw consumes the remote-model contract and artifact roots.
Batch 16-18 / Agentfield consumes workspace roots, research outputs, and remote-model/router contracts.
Batch 19-24 / Paperclip adapter and campaign orchestration consume the same roots/contracts through Agentfield and dry-run payloads.
```

If a later batch needs a new root, health check, alias, or config integration hook, it should request it through that batch's `INTEGRATION_REQUEST.md`, not by editing Layer 1.

## 24-batch visual map

- **[x] 01-runtime-substrate** - implements Layer 1 runtime substrate.
- ~~[ ] 02-research-workspace~~ - implements Layer 2 / Bundle 2; consumes Layer 1 roots and owns the corrected workspace-boundary annex.
- ~~[ ] 03-ai-engineer-workspaces~~
- ~~[ ] 04-pkm-skeleton~~
- ~~[ ] 05-publisher-latex~~
- ~~[ ] 06-nca-art-base~~
- ~~[ ] 07-dummy-science-organs~~
- ~~[ ] 08-mechanism-reporting~~
- ~~[ ] 09-local-smoke~~
- ~~[ ] 10-search-templates~~
- ~~[ ] 11-search-scoring~~
- ~~[ ] 12-search-smoke~~
- ~~[ ] 13-runpod-dryrun~~ - consumes Layer 1 runtime roots and remote-compute placeholders.
- ~~[ ] 14-openclaw-indexes~~ - consumes remote-model/artifact contracts later.
- ~~[ ] 15-openclaw-reasoners~~ - consumes remote-model/artifact contracts later.
- ~~[ ] 16-agentfield-poc~~ - consumes roots/contracts later.
- ~~[ ] 17-agentfield-reasoners~~ - consumes remote-model contract later.
- ~~[ ] 18-agentfield-hardening-stubs~~ - consumes research and RunPod target stubs later.
- ~~[ ] 19-paperclip-adapter-core~~
- ~~[ ] 20-paperclip-review-dryrun~~
- ~~[ ] 21-campaign-core~~
- ~~[ ] 22-campaign-agents~~
- ~~[ ] 23-campaign-review-smoke~~
- ~~[ ] 24-campaign-guarded-stubs~~ - consumes guarded live-action concepts later.

## Smoke / validation mapping

Layer 1 Batch 01 targets these smoke domains:

```text
10-core-layout.smoke.sh
60-infra-tools.smoke.sh
90-research-assistant.smoke.sh
```

The active runner rule from the workflow files is:

```bash
# Current active runner, if the workspace has not migrated yet:
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress

# Final canonical runner after D-SM2 migration:
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

Do not silently switch from `/workspace/scripts/smoke.sh` to `/workspace/scripts/smoke_current_state.sh` in the middle of a batch. Switch only through the dedicated protocol + orchestrator migration workflow.

Smoke proves file/contract/readiness shape. It does not prove scientific truth, live orchestration, live infrastructure, or remote model quality.

## Output and path contracts

Layer 1 Batch 01 may create or verify:

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

Layer 1 Batch 01 evidence must be written to:

```text
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md
```

The smoke report path must follow the active runner's report contract:

```text
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
/workspace/runs/smoke/<timestamp-phase>/module-results/
```

## Operational workflow integration

Use the day-to-day skeleton workflow for Batch 01:

```text
S-T1  ChatGPT creates the Batch 01 Codex package.
S-T2  Human/Codex stages the package.
S-T3  Codex implements the batch under /workspace and writes POSTCHECK.md plus INTEGRATION_REQUEST.md.
S-T4  Codex runs dynamic smoke through the active runner.
S-T5  Human/ChatGPT classifies PASS/WARN/FAIL.
S-T6  Companion updates only at checked logical checkpoints or contract changes.
```

Minimum continue rule:

```text
Do not start the next skeleton batch until Batch 01 has:
1. POSTCHECK.md
2. INTEGRATION_REQUEST.md
3. a smoke report path
4. PASS, SKIP, or accepted documented WARN
```

Stop immediately when any of these occurs:

```text
required batch file missing
required evidence path missing
POSTCHECK.md missing
INTEGRATION_REQUEST.md missing
smoke runner missing or broken
SMOKE_REPORT.md shows FAIL
SMOKE_REPORT.md shows unexpected WARN not yet classified
mount/permission issue blocks evidence or reports
Codex proposes config edits during skeleton implementation
Codex proposes live RunPod/model/Kubernetes/Terraform mutation by default
```

## Global smoke.d versus local smoke routines

Layer 1 uses global/domain-owned smoke modules. Do not create one global smoke module per batch.

For Layer 1:

```text
10-core-layout.smoke.sh
  global module for /workspace roots and runner/report roots

60-infra-tools.smoke.sh
  global module for safe command presence/readiness only

90-research-assistant.smoke.sh
  global module for Batch 01 dummy remote-model contract
```

Local routines may exist only when a project/local surface needs a tiny repeatable check. For Layer 1 that may include:

```text
/workspace/repos/research-assistant/smoke_test.py
/workspace/scripts/runtime_checks/*.sh
```

Local routines must be safe, idempotent, non-live by default, and must not write global `SMOKE_REPORT.md` directly. A global module may call them and record the result.

## Relationship to earlier layers

There are no earlier implementation layers. Layer 1 is the platform base.

## Relationship to later layers

Layer 2 may assume the generic roots exist, but it must create its own role workstations and project namespaces. Layer 3 may assume the roots and namespace conventions when creating dummy/real research contracts. Layer 4 and Layer 5 may use the remote-model client contract, but they must not expand Layer 1 into orchestration.

## Annex index

Layer 1 does not own a Batch 02 annex. The former filename below is deprecated:

```text
SPEC_Layer01_02-research-workspace-ANX01_workspace_boundaries.md
```

Use the corrected Layer 2 annex instead:

```text
SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md
```

This annex should be linked from Layer 1 only as a downstream boundary reference explaining why Batch 01 must stay generic and why Batch 02 creates the NCA-ART-GRN repo.

## Acceptance / success condition

After Layer 1, developers should be able to say:

```text
The runtime has stable generic storage roots.
The runtime has a documented persistent-volume layout.
GPU/CUDA/Torch readiness can be checked safely.
Docker/GPU readiness can be checked safely without starting containers.
Terraform and Kubernetes can be inspected safely without mutating infrastructure.
Remote-compute profiles exist as placeholders, not live launchers.
A research-assistant dummy client provides one remote-model contract.
No NCA-ART-GRN repo, science run, Agentfield runtime, Paperclip adapter, OpenClaw workflow, PKM system, or LaTeX paper has been hidden inside setup.
Batch 01 evidence exists and can be used by a later config-integration track.
```

## Developer notes

```text
Do not edit the config tool unless a dedicated config-integration batch explicitly says so.
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh.
Do not run broad bootstrap.
Do not mount, pull, push, or read credentials unless explicitly requested.
Do not launch RunPod jobs by default.
Do not run Docker builds or containers by default.
Do not call live model/provider APIs by default.
Do not write to Paperclip live state by default.
Preserve output contracts so dummy skeleton organs can later become real organs.
Smoke tests prove shape/readiness/contracts, not scientific truth.
```
