# SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries

Status: corrected Layer 2 annex created from the formerly mislayered `SPEC_Layer01_02-research-workspace-ANX01_workspace_boundaries.md`.  
Parent layer spec: `SPEC_Layer02_role_workstations.md`.  
Boundary reference: `SPEC_Layer01_runtime_substrate.md`.  
Primary batch placement: **Batch 02 / `02-research-workspace`**.  
Annex purpose: `workspace boundaries`.  
Batch slicing authority: `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md`.  
Operational authority: `final_workflow.md`, `smoke_module_update_workflow.md`, and `day_to_day_skeleton_run.md`.

## Why this annex exists

This annex preserves detailed workspace-boundary material that is implementation-significant for **Layer 2 / Batch 02 / `02-research-workspace`**.

It was previously named as a Layer 1 annex because it explains a Layer 1 boundary: Batch 01 must create generic runtime roots but must not create the NCA-ART-GRN research repo. Under the current naming rule, however, annex files belong to the layer and batch where the detailed material is most valuable for implementation. The detailed material here is `prepare_nca_art_workspace`, `prepare_experiment_output_layout`, and the repo-local versus platform-level `/workspace` policy. Those are Batch 02 concerns, so this file is now a Layer 2 annex.

Layer 1 still links this annex as a negative boundary reference. Layer 2 owns it as implementation background.

## Most relevant implementation batch

```text
Primary batch: 02-research-workspace
Primary layer: Layer 2 — Role workstations
Primary bundle: Bundle 2 — Research Scientist NCA-ART-GRN workspace
Primary role: researchscientist
```

Batch 02 creates the first research workspace under the generic roots prepared by Batch 01. It must use the corrected A1/A2 step names:

```text
install_grn_core_research_stack
install_nca_art_research_stack
install_parameter_search_comparison_stack
prepare_nca_art_workspace
prepare_experiment_output_layout
check_research_env_ready
prepare_dummy_science_cli
```

Do **not** use the outdated duplicate step name:

```text
prepare_grn_workspace
```

## Related layer and bundle

This annex belongs to:

```text
Layer 2 — Role workstations
Bundle 2 — Research Scientist NCA-ART-GRN workspace
Batch 02 — 02-research-workspace
```

It references Layer 1 because Layer 1 provides generic roots:

```text
/workspace/repos
/workspace/data
/workspace/runs
/workspace/artifacts
/workspace/models
/workspace/checkpoints
/workspace/envs
/workspace/logs
```

Layer 2 Batch 02 creates project-specific research namespaces under those roots:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

Future batches may add or consume project-specific model/checkpoint namespaces when their active specs require them:

```text
/workspace/models/nca-art-grn
/workspace/checkpoints/nca-art-grn
```

## Background source notes

This annex combines these background meanings:

```text
1. prepare_nca_art_workspace is the realistic NCA-ART-GRN research repository skeleton.
2. prepare_runpod_workspace creates generic platform-level /workspace roots only.
3. Layer 1 must know project namespaces will exist later, but must not create research code.
4. Remote-model endpoint belongs to Layer 1 only as a thin local-code -> remote-model -> response contract.
5. Batch 02 is the first implementation point where the research repo and project-specific output namespaces become real skeleton work.
```

## What this extends in the main layer SPEC

This annex extends `SPEC_Layer02_role_workstations.md` by adding detailed Batch 02 implementation background for the Research Scientist NCA-ART-GRN workspace.

The main Layer 2 SPEC should describe the product boundary and layer-level role meaning. This annex keeps the lower-level structure:

```text
repo skeleton
repo-local vs /workspace shared-state policy
Batch 01-to-Batch 02 boundary
smoke/evidence expectations for Batch 02
local/global smoke-module decision rules
```

## Batch -> implementation relevance

### Batch 01 / `01-runtime-substrate`

Batch 01 is upstream only. It must create generic roots and the research-assistant remote-model dummy contract. In relation to this annex, Batch 01 is a boundary guard:

```text
create /workspace/repos
create /workspace/data
create /workspace/runs
create /workspace/artifacts
create /workspace/models
create /workspace/checkpoints
create /workspace/envs and /workspace/logs where required
create /workspace/runtime
create /workspace/scripts/runtime_checks
create /workspace/repos/research-assistant
```

Batch 01 must not create:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

### Batch 02 / `02-research-workspace`

Batch 02 owns this annex. It should use this annex to implement:

```text
prepare_nca_art_workspace
prepare_experiment_output_layout
check_research_env_ready
prepare_dummy_science_cli
```

The key Batch 02 outputs are:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

Batch 02 may also create repo-local directories inside `/workspace/repos/nca-art-grn` for source code, configs, notebooks, scripts, tests, tiny fixtures, local smoke runs, and example artifacts.

### Later batches

Later research batches consume the repo and roots created by Batch 02:

```text
Batch 06-09 consume the research repo for DSL, dummy science organs, reporting, and local science smoke.
Batch 10-12 consume the research repo for search templates, scoring, and search smoke.
Batch 13 consumes Layer 1 runtime roots and later research namespaces for RunPod dry-run contracts.
Batch 18 consumes research repo outputs through Agentfield hardening stubs.
```

## Concrete steps affected

### `prepare_nca_art_workspace`

Purpose:

```text
Prepare the first realistic project skeleton for the NCA-ART-GRN research codebase.
Do not run simulations, train models, install packages, launch RunPod jobs, or generate results.
Only create the workspace where later research code can live.
```

The workspace should reflect this research architecture:

```text
Symbolic DSL / motif library
 -> candidate 5-node GRNs
 -> PDE/ODE reaction-diffusion simulator
 -> generated cell-state trajectories
 -> NCA surrogate or alternate cell-rule model
 -> ART prototype and transition discovery
 -> prototype-to-DSL inverse mapping
 -> verification by Turing checks, sweeps, Bayesian or robustness tests
```

Target role:

```text
primary: researchscientist
secondary later: aiengineer for wrappers, APIs, Agentfield services, or Paperclip integration
```

Default workspace root:

```text
/workspace/repos/nca-art-grn
```

Fallback only if `/workspace` is unavailable:

```text
/home/researchscientist/research/nca-art-grn
```

### `prepare_experiment_output_layout`

Purpose:

```text
Create project-specific shared output namespaces under the platform roots prepared by Layer 1.
Do not run experiments and do not generate scientific results.
```

Primary shared paths:

```text
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

Future or conditional shared paths when an active SPEC requires them:

```text
/workspace/models/nca-art-grn
/workspace/checkpoints/nca-art-grn
```

### `prepare_dummy_science_cli`

Purpose:

```text
Create a deterministic skeleton CLI surface that later batches can smoke-test.
It may emit tiny dummy JSON/Markdown artifacts only when explicitly required by Batch 02 or subsequent batch specs.
It must not perform real science.
```

## Path and ownership contracts

Use this root distinction:

```text
/workspace = shared platform state
/workspace/repos/nca-art-grn = research engine source code
```

Repo-local folders inside `/workspace/repos/nca-art-grn` are for:

```text
source code
configs
notebooks
scripts
tests
small example data
schemas
tiny fixtures
local/dev smoke runs
repo-local example artifacts
internal docs
```

Platform-level folders are for:

```text
real research data
real experiment outputs
reusable reports
reusable figures
important artifacts
models and checkpoints when later active specs require them
```

Concrete rule:

```text
small example data lives in repo/data
real research data lives in /workspace/data/nca-art-grn

local smoke outputs live in repo/runs or a local smoke subfolder defined by the batch
real experiment outputs live in /workspace/runs/nca-art-grn

example/demo artifacts live in repo/artifacts
important reusable results live in /workspace/artifacts/nca-art-grn

source code, configs, tests, notebooks, scripts live in the repo
```

## Recommended research repo skeleton

The first skeleton pass should create only directories and placeholder files that are safe and non-overwriting. It should not create working scientific code.

```text
nca-art-grn/
├── README.md
├── pyproject.toml
├── requirements/
│   ├── base.txt
│   ├── research.txt
│   ├── gpu.txt
│   ├── notebooks.txt
│   └── dev.txt
├── configs/
│   ├── project.yaml
│   ├── paths.yaml
│   ├── logging.yaml
│   ├── runpod.yaml
│   ├── experiments/
│   │   ├── smoke_test.yaml
│   │   ├── grn_5node_baseline.yaml
│   │   ├── nca_surrogate_baseline.yaml
│   │   └── art_discovery_baseline.yaml
│   ├── search/
│   │   ├── random_grid.yaml
│   │   ├── latin_hypercube.yaml
│   │   ├── evolutionary.yaml
│   │   └── bayesian.yaml
│   └── validation/
│       ├── turing_checks.yaml
│       ├── robustness.yaml
│       └── resimulation.yaml
├── src/nca_art_grn/
│   ├── dsl/
│   ├── motifs/
│   ├── candidates/
│   ├── simulator/
│   ├── capture/
│   ├── nca/
│   ├── art/
│   ├── mapping/
│   ├── analysis/
│   ├── search/
│   ├── runs/
│   ├── viz/
│   └── cli/
├── data/
├── artifacts/
├── runs/
├── notebooks/
├── scripts/
├── tests/
└── docs_internal/
```

Minimum placeholder files for Batch 02:

```text
README.md
pyproject.toml
requirements/base.txt
requirements/research.txt
requirements/gpu.txt
requirements/notebooks.txt
requirements/dev.txt
configs/project.yaml
configs/paths.yaml
configs/experiments/smoke_test.yaml
src/nca_art_grn/__init__.py
src/nca_art_grn/dsl/__init__.py
src/nca_art_grn/motifs/__init__.py
src/nca_art_grn/simulator/__init__.py
src/nca_art_grn/capture/__init__.py
src/nca_art_grn/nca/__init__.py
src/nca_art_grn/art/__init__.py
src/nca_art_grn/mapping/__init__.py
src/nca_art_grn/analysis/__init__.py
src/nca_art_grn/search/__init__.py
src/nca_art_grn/runs/__init__.py
src/nca_art_grn/viz/__init__.py
src/nca_art_grn/cli/__init__.py
data/README.md
scripts/smoke_test.sh
tests/test_project_import.py
docs_internal/architecture_notes.md
docs_internal/data_contracts.md
docs_internal/dsl_notes.md
docs_internal/experiment_lifecycle.md
docs_internal/safety_boundary.md
```

## Output contracts

Batch 02 should leave stable path and shape contracts, not scientific results.

Expected path contracts:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

Expected evidence contracts:

```text
/mnt/egress/dev-recordings/skeleton/02-research-workspace/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/02-research-workspace/INTEGRATION_REQUEST.md
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
```

Expected smoke domains from the corrected mapping:

```text
20-python-package.smoke.sh
70-grn-contract.smoke.sh
30-skeleton-evidence.smoke.sh
```

## Guardrails / non-goals

Batch 02 must not:

```text
run research experiments
train NCA models
run ART discovery
start RunPod jobs
call RunPod APIs
call live model/provider APIs
build Agentfield
build Paperclip
create OpenClaw reasoning jobs
index a PKM vault
build a paper
install packages unless the active batch SPEC explicitly allows a named safe check or package-policy marker
edit the config tool
edit /home/vmuser/.local/bin/config.sh
edit /home/vmuser/.local/lib/config-sh/installers.sh
edit /home/vmuser/.local/etc/config-sh
print secrets
overwrite existing research code
```

## Smoke and validation relevance

Use the active runner rule:

```bash
# Current active runner, if the workspace has not migrated yet:
BATCH_SLUG="02-research-workspace" bash /workspace/scripts/smoke.sh skeleton-progress

# Final canonical runner after D-SM2 migration:
BATCH_SLUG="02-research-workspace" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

Do not silently switch runners in the middle of a batch. Switch only through the dedicated D-SM2 protocol + orchestrator update workflow.

Smoke should verify:

```text
/workspace/repos/nca-art-grn exists
/workspace/data/nca-art-grn exists
/workspace/runs/nca-art-grn exists
/workspace/artifacts/nca-art-grn exists
package-policy markers/import/syntax checks where relevant
dummy CLI or local smoke helper exists if the batch creates it
dummy artifact filenames only where the active batch contract requires them
POSTCHECK.md exists
INTEGRATION_REQUEST.md exists
config boundary is preserved
```

Smoke should not:

```text
run real science
train models
launch RunPod
call live providers
mutate Terraform/Kubernetes/Docker state
print secrets
```

## Global smoke.d versus local smoke routines

Planning documents alone do not usually trigger smoke code changes. Implemented contract changes do.

For Batch 02:

```text
20-python-package.smoke.sh
  update only if package/import/compile expectations changed.

70-grn-contract.smoke.sh
  update only if nca-art-grn roots, dummy CLI, dummy science artifacts, or GRN contract changed.

30-skeleton-evidence.smoke.sh
  update only if evidence path or required evidence behavior changed.
```

Local smoke routine examples for Batch 02, if implementation creates them:

```text
/workspace/repos/nca-art-grn/scripts/local_smoke.sh
/workspace/repos/nca-art-grn/scripts/dummy_science_cli_smoke.sh
/workspace/repos/nca-art-grn/smoke_test.py
```

Decision rule:

```text
Create/update a local smoke routine when Batch 02 creates a local CLI, fixture, package command, schema validator, or dry-run path.
Update a global smoke.d module only when the implemented Batch 02 public contract changes what global current-state smoke must verify.
Do not create one global smoke module per batch.
Do not update the runner or smoke protocol for ordinary Batch 02 contract refinements.
```

## How Codex should use this annex when generating a batch

For Batch 01 generation:

```text
Use this annex only as a boundary warning.
Do not implement its research repo content in Batch 01.
```

For Batch 02 generation:

```text
Read this annex with SPEC_Layer02_role_workstations.md.
Use it to populate Batch 02 SPEC.md and PROJECT_CACHE.md.
Keep the Codex prompt compact; reference this annex rather than copying all background.
Implement only skeleton directories, placeholder files, package-policy markers, dummy CLI/readiness checks, and evidence.
```

For later research batches:

```text
Use this annex only to understand the expected repo and shared-root layout.
Do not treat it as permission to run real science.
```

## Open questions

```text
Should Batch 02 create /workspace/models/nca-art-grn and /workspace/checkpoints/nca-art-grn immediately, or should those wait for the first NCA/search/RunPod batch that needs them?
Should the first dummy CLI live as a package module, a scripts/ helper, or both?
Should 70-grn-contract.smoke.sh check only roots in Batch 02, or also a local smoke helper if the helper is created?
```

## 24-batch visual map

- ~~[ ] 01-runtime-substrate~~ - upstream root provider and negative boundary only; does not implement this annex.
- **[x] 02-research-workspace** - implements this annex: `prepare_nca_art_workspace`, `prepare_experiment_output_layout`, repo layout, and project-specific `/workspace/*/nca-art-grn` namespaces.
- ~~[ ] 03-ai-engineer-workspaces~~
- ~~[ ] 04-pkm-skeleton~~
- ~~[ ] 05-publisher-latex~~
- ~~[ ] 06-nca-art-base~~ - consumes the research repo after Batch 02.
- ~~[ ] 07-dummy-science-organs~~ - consumes the research repo after Batch 02.
- ~~[ ] 08-mechanism-reporting~~ - consumes the research repo after Batch 02.
- ~~[ ] 09-local-smoke~~ - consumes the research repo and shared run/artifact roots.
- ~~[ ] 10-search-templates~~
- ~~[ ] 11-search-scoring~~
- ~~[ ] 12-search-smoke~~
- ~~[ ] 13-runpod-dryrun~~ - consumes Layer 1 roots and later research namespaces.
- ~~[ ] 14-openclaw-indexes~~
- ~~[ ] 15-openclaw-reasoners~~
- ~~[ ] 16-agentfield-poc~~
- ~~[ ] 17-agentfield-reasoners~~
- ~~[ ] 18-agentfield-hardening-stubs~~ - later bridges to this research repo.
- ~~[ ] 19-paperclip-adapter-core~~
- ~~[ ] 20-paperclip-review-dryrun~~
- ~~[ ] 21-campaign-core~~
- ~~[ ] 22-campaign-agents~~
- ~~[ ] 23-campaign-review-smoke~~
- ~~[ ] 24-campaign-guarded-stubs~~
