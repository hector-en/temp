# SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture

Status: Layer 3 annex created from the uploaded NCA, ART, and From Config to Agentfield background notes.  
Parent layer spec: `SPEC_Layer03_research_execution_loops.md`.  
Related layer specs: `SPEC_Layer01_runtime_substrate.md`, `SPEC_Layer02_role_workstations.md`, `SPEC_Layer04_knowledge_reasoning.md`, `SPEC_Layer05_platform_orchestration.md`.  
Related Layer 2 annex: `SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md`.  
Primary batch placement: **Batch 06 / `06-nca-art-base`**.  
Annex purpose: `art_nca_core_architecture`.  
Batch slicing authority: `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md`.  
Real-organ transition authority: `01_B0_transition_to_real_organs_master_v2.md` and `01_B1_transition_real_organs_codex_batch_plan_v2.md`.  
Operational authority: `final_workflow.md`, `smoke_module_update_workflow.md`, `day_to_day_skeleton_run.md`, and `day_to_day_organs_run.md`.  
Batch-creation hook: `BATCH_CREATION_ANX02_art_nca_core_architecture.md`.

## Why this annex exists

This annex preserves the implementation-significant content from the uploaded first-draft ART/NCA core idea material:

```text
NCA_self_organising_textures_latex.md
ART_latex.md
from_config_to_agentfield_part1_latex.md
from_config_to_agentfield_part2_latex.md
from_config_to_agentfield_part3_latex.md
```

The notes are not only bibliography. They define how the NCA-ART-GRN core should be shaped inside the Infra-Skeleton / Agentfield platform:

```text
DSL-defined 5-node GRN candidate
 -> PDE/ODE reaction-diffusion simulator
 -> trajectory and local-state capture
 -> NCA local-rule / pattern-process surrogate
 -> ART2 continuous prototype discovery
 -> ARTMAP prototype/context transition learning
 -> prototype-to-DSL inverse mapping
 -> mechanism-discrimination report
 -> local smoke, search, RunPod dry-run, Agentfield orchestration, and Paperclip review later
```

The most important scientific guardrail is:

```text
A visually nice final pattern is not sufficient mechanism evidence.
```

The platform must preserve formation dynamics, perturbation response, simulator-to-NCA agreement/disagreement, ART prototype evidence, ARTMAP transition evidence, DSL recoverability, and falsification hooks.

This annex exists so future batch-generation chats can request one compact, batch-aligned Layer 3 annex instead of re-reading the full NCA paper, ART paper, and Agentfield notes every time.

## Most relevant implementation batch

```text
Primary batch: 06-nca-art-base
Primary layer: Layer 3 — Research Execution Loops
Primary bundle: Bundle 3 — NCA-ART-DSL mechanism discovery stack
Primary role: researchscientist
Primary smoke domain: 70-grn-contract.smoke.sh
```

Batch 06 is primary because it creates the schema/base contract for:

```text
prepare_dsl_candidate_runtime
prepare_mechanism_hypothesis_runtime
```

Those schema/base surfaces must already have places for NCA, ART2, ARTMAP, perturbation, prototype-to-DSL, and falsification evidence. If Batch 06 omits those fields, later Batch 07/08/09 and real-organ R02/R03/R04/R05 work will need an avoidable contract migration.

Batch 06 must not implement full simulator execution, NCA training, ART2 clustering, ARTMAP learning, parameter search, RunPod execution, Agentfield orchestration, or biological claims. It should create only the contract surfaces that make those later organs possible.

## Related layer and bundle

This annex belongs to:

```text
Layer 3 — Research Execution Loops
Bundle 3 — NCA-ART-DSL mechanism discovery stack
Batch 06 — 06-nca-art-base
```

It depends on Layer 2 Batch 02 for the research repo and shared output roots:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

It also prepares contracts consumed later by:

```text
Batch 07 — dummy simulator/NCA/ART2/ARTMAP organs
Batch 08 — mechanism reporting
Batch 09 — local science smoke
Batch 10-12 — search templates, scoring, and search smoke
Batch 13 — RunPod dry-run manifests and result return
Batch 18 — Agentfield NCA-ART bridge/status stubs
R02-R05 — real DSL/simulator, NCA, ART2/ARTMAP, and mechanism-report organs
R06-R09/R12 — real search, RunPod boundary, Agentfield, and end-to-end smoke consumers
```

## Background source notes

### NCA source intent

`NCA_self_organising_textures_latex.md` should be read as the pattern-generation / local-update-rule inspiration for the NCA organ.

Implementation-significant points:

```text
- NCA cells share one learned local rule.
- Each cell updates from local neighborhood state.
- NCA is suitable for pattern and texture generation because local rules can coordinate into global structure.
- A pattern should be treated as a generated process, not as an exact bitmap lookup.
- Reaction-diffusion PDEs can be discretized into CA/NCA-like local updates.
- The NCA state may contain visible and hidden channels.
- Gradient and Laplacian perception features are natural local inputs.
- Stochastic/asynchronous updates should be modeled explicitly later.
- NCA pattern quality is ambiguous; visual appearance is not enough for mechanism proof.
```

Useful mathematical anchor from the NCA note:

```latex
\frac{\partial s}{\partial t} = f\!\left(s, \nabla_x s, \nabla_x^2 s\right)
```

Implementation reading for this platform:

```text
The PDE/ODE simulator remains the authoritative forward model.
The NCA organ is a local-rule surrogate or test model over simulator trajectories, perturbation replays, and local neighborhood features.
NCA agreement is evidence about local-rule recoverability, not proof that a biological mechanism is true.
```

### ART source intent

`ART_latex.md` should be read as the prototype/category-stability inspiration for ART2 and ARTMAP organs.

Implementation-significant points:

```text
- ART-style learning emphasizes stable adaptive recognition in nonstationary input environments.
- Prototype discovery should be inspectable and persistent.
- Top-down expectation, matching, and resonance map naturally to prototype validation.
- Vigilance-like parameters should be explicit in configs and result metadata.
- Competitive/cooperative dynamics, normalization, and gain-control ideas are relevant to prototype selection and category stability.
- ART2/ARTMAP evidence should be separate from final pattern evidence.
- The skeleton does not need to implement the whole Grossberg architecture; it needs fields and output contracts that can later host ART-compatible organs.
```

Useful equation anchors for later real organs:

```latex
\frac{d}{dt}x_i=-A_i x_i+\sum_j f_j(x_j)z_{ji}+I_i
```

```latex
\frac{d}{dt}z_{ij}=h_j(x_j)\left[-F_{ij}z_{ij}+G_{ij}f_i(x_i)\right]
```

Implementation reading for this platform:

```text
ART2 should turn continuous simulator/NCA/local-state trajectories into inspectable prototype records.
ARTMAP should map prototype transitions and context changes into an explicit transition graph.
Mechanism reports and search scoring should consume those records instead of treating learned categories as hidden model state.
```

### From Config to Agentfield source intent

The `from_config_to_agentfield_part*.md` notes define the architecture transition from manual/config-managed prototyping to orchestrated experiments.

Implementation-significant points:

```text
- Config prepares users, profiles, mounts, environments, package policy, and safe checks.
- The `nca-art-grn` repo owns scientific execution.
- Manual/config-managed prototyping is the right starting point for the first NCA-ART core loop.
- Agentfield becomes valuable once there are many candidates, seeds, hyperparameters, and runs to compare.
- RunPod should be used for expensive training/inference/sweep capacity only after local contracts are stable.
- Costs are dominated by GPU-hours, so run manifests, seeds, failure reasons, resume state, and result comparability matter.
- Agentfield should consume stable run manifests, artifact contracts, status fields, failure categories, and review gates.
- Paperclip should consume human-facing status and review payloads, not raw hidden science internals.
```

Implementation reading for this platform:

```text
Do not hide science inside Agentfield.
Do not let RunPod become an uncontrolled execution sink.
Build the local/manual NCA-ART evidence contract first, then let Agentfield orchestrate over it later.
```

## What this extends in the main layer SPEC

`SPEC_Layer03_research_execution_loops.md` already defines the correct Layer 3 loop:

```text
DSL candidate GRN
-> PDE/ODE simulator
-> trajectory and local-state capture
-> NCA local-rule or surrogate testing
-> ART2 prototype discovery
-> ARTMAP transition learning
-> prototype-to-DSL inverse mapping
-> mechanism-discrimination analysis
-> perturbation / experiment-design proposal
```

This annex extends the main Layer 3 SPEC by making the intended ART/NCA core architecture explicit:

```text
NCA = local differentiable update-rule / pattern-process surrogate.
ART2 = continuous prototype discovery over state and trajectory evidence.
ARTMAP = transition/context mapping between prototypes.
DSL = symbolic mechanism record and recoverability target.
Mechanism report = evidence comparison, falsification, and next-experiment surface.
RunPod = later controlled compute, not day-one live execution.
Agentfield = later orchestration/status layer over stable artifacts, not owner of hidden science.
Paperclip = later human review surface, not a science engine.
```

## Batch -> implementation relevance

### Batch 01 / `01-runtime-substrate`

Batch 01 is upstream only. It provides generic `/workspace` roots and a thin remote-model dummy contract. It must not create NCA-ART-GRN science internals.

### Batch 02 / `02-research-workspace`

Batch 02 creates the repo and output roots consumed by this annex. Use `SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md` for the repo-local versus platform-output boundary.

### Batch 06 / `06-nca-art-base`

Batch 06 owns this annex. It should use the annex to shape the DSL and mechanism-hypothesis schemas so later simulator, NCA, ART2, ARTMAP, perturbation, reporting, search, RunPod, and Agentfield stages can be added without changing the base contract.

### Batch 07 / `07-dummy-science-organs`

Batch 07 consumes this annex to create dummy simulator/NCA/ART2/ARTMAP/perturbation outputs that look replaceable by real organs.

### Batch 08 / `08-mechanism-reporting`

Batch 08 consumes this annex to make the mechanism report evidence-based and falsifiable rather than final-image-driven.

### Batch 09 / `09-local-smoke`

Batch 09 consumes this annex to ensure local smoke outputs include the full artifact set needed by later real organs and orchestration.

### Batch 10-12 / search and scoring

Search templates, scoring, ranking, and smoke outputs should include NCA/ART/mechanism-discrimination fields instead of optimizing only final-pattern similarity.

### Batch 13 / `13-runpod-dryrun`

RunPod dry-run work should preserve run manifests, cost-aware execution metadata, result-return policy, and evidence artifact references.

### Batch 18 / `18-agentfield-hardening-stubs`

Agentfield hardening should map NCA-ART-GRN artifacts into status fields and stage results. It should not own science internals.

### 24-batch visual map

- ~~[ ] 01-runtime-substrate~~ - upstream runtime roots only; do not implement this annex here.
- ~~[ ] 02-research-workspace~~ - creates research repo and shared roots consumed by this annex.
- ~~[ ] 03-ai-engineer-workspaces~~
- ~~[ ] 04-pkm-skeleton~~
- ~~[ ] 05-publisher-latex~~
- **[x] 06-nca-art-base** - primary: DSL/mechanism schema surfaces must encode the ART/NCA evidence contract.
- ~~[ ] 07-dummy-science-organs~~ - secondary: dummy organs must preserve replaceable output shapes.
- ~~[ ] 08-mechanism-reporting~~ - secondary: reports must include NCA/ART evidence and falsification.
- ~~[ ] 09-local-smoke~~ - secondary: smoke artifact set should include all evidence files.
- ~~[ ] 10-search-templates~~ - secondary: search configs should preserve mechanism-evidence fields.
- ~~[ ] 11-search-scoring~~ - secondary: scoring should include NCA/ART/prototype/transition evidence.
- ~~[ ] 12-search-smoke~~ - secondary: dummy search smoke should preserve evidence fields.
- ~~[ ] 13-runpod-dryrun~~ - secondary: result return should include mechanism evidence artifacts.
- ~~[ ] 14-openclaw-indexes~~ - later selected-context consumer.
- ~~[ ] 15-openclaw-reasoners~~ - later reasoning consumer.
- ~~[ ] 16-agentfield-poc~~ - indirect consumer through future status shape.
- ~~[ ] 17-agentfield-reasoners~~ - indirect consumer through reasoner vocabulary.
- ~~[ ] 18-agentfield-hardening-stubs~~ - secondary: maps NCA-ART artifacts to Agentfield status.
- ~~[ ] 19-paperclip-adapter-core~~
- ~~[ ] 20-paperclip-review-dryrun~~
- ~~[ ] 21-campaign-core~~
- ~~[ ] 22-campaign-agents~~
- ~~[ ] 23-campaign-review-smoke~~
- ~~[ ] 24-campaign-guarded-stubs~~

### Real-organ transition map

| Organ batch | Relationship to this annex |
|---:|---|
| R02 | Required for real DSL, mechanism hypothesis, simulator, and simulator evidence contracts. |
| R03 | Required for real NCA local-rule/surrogate implementation. |
| R04 | Required for real ART2 prototype and ARTMAP transition organs. |
| R05 | Required for real mechanism report generation. |
| R06 | Recommended for search/ranking evidence design. |
| R07 | Recommended for RunPod dry-run-to-live result-return boundaries. |
| R09 | Recommended for Agentfield experiment/status bridge design. |
| R12 | Recommended for end-to-end real local smoke. |

## Concrete steps affected

### `prepare_dsl_candidate_runtime`

Purpose:

```text
Create the symbolic candidate mechanism surface for 5-node GRN candidates.
Do not simulate or train; create schema, fixtures, configs, and validation placeholders only.
```

Minimum schema direction:

```text
candidate_id
node_count
nodes
edges
signs
interaction_matrix
reaction_parameters
diffusion_parameters
initial_conditions
boundary_conditions
observables
perturbables
motif_provenance
constraints
notes
```

### `prepare_mechanism_hypothesis_runtime`

Purpose:

```text
Create the mechanism hypothesis surface that predicts what simulator/NCA/ART/perturbation evidence should look like.
Do not claim discovery.
```

Minimum schema direction:

```text
mechanism_hypothesis_id
candidate_id
mechanism_class
local_activation_assumption
long_range_inhibition_assumption
diffusion_transport_assumption
formation_dynamics_prediction
pattern_spacing_prediction
perturbation_predictions
expected_nca_evidence
expected_art2_prototypes
expected_artmap_transitions
falsification_criteria
experimental_design_suggestions
```

### `prepare_pde_ode_simulation_runtime`

Later Batch 07/R02 consumer. It should use the DSL and mechanism hypothesis records as input and produce simulator evidence without overwriting source contracts.

Expected output direction:

```text
simulator_summary.json
trajectory_ref
pattern_dynamics_ref
status
failure_reason
```

### `prepare_nca_cell_runtime` and `prepare_pde_ode_to_nca_dataset`

Later Batch 07/R03 consumers. They should treat NCA as a local-rule or surrogate organ over simulator trajectories.

Expected output direction:

```text
nca_summary.json
input_dataset_ref
local_rule_features
update_mode
rollout_steps
agreement_metrics
perturbation_replay_metrics
hidden_state_summary
status
failure_reason
```

### `prepare_art2_discovery_runtime`

Later Batch 07/R04 consumer. It should expose prototype/category discovery rather than hide it inside model weights.

Expected output direction:

```text
art2_prototypes.json
method
vigilance
prototype_count
prototype_schema
prototypes
support_counts
source_trajectory_refs
perturbation_contexts
status
failure_reason
```

### `prepare_artmap_transition_runtime`

Later Batch 07/R04 consumer. It should expose prototype-to-prototype or context-to-prototype transitions.

Expected output direction:

```text
artmap_transitions.json
source_prototype
target_prototype
transition_frequency
time_delta
context_features
perturbation_id
transition_score
recovery_or_failure_flag
status
failure_reason
```

### `prepare_mechanism_discrimination_report`

Later Batch 08/R05 consumer. It should consume all evidence files and write a report that separates appearance, dynamics, NCA, ART2, ARTMAP, perturbation, and falsification evidence.

### `run_nca_art_local_smoke`

Later Batch 09/R12 consumer. It should prove shape/readiness only. It should not prove scientific truth.

### `prepare_agentfield_nca_art_bridge`

Later Batch 18/R09 consumer. It should map stable evidence artifacts to Agentfield status fields and stage results.

## Path and ownership contracts

### Research engine repo

```text
/workspace/repos/nca-art-grn
  Owner role: researchscientist
  Purpose: DSL, candidates, simulator, capture, NCA, ART2, ARTMAP, mapping, analysis, search, local smoke helpers, and mechanism reports.
```

### Shared output roots

```text
/workspace/data/nca-art-grn
  Purpose: source data, candidate batches, simulator-to-NCA datasets, selected input manifests.

/workspace/runs/nca-art-grn
  Purpose: local smoke runs, experiment runs, tiny search smoke runs, dry-run status, execution traces.

/workspace/artifacts/nca-art-grn
  Purpose: selected mechanism reports, prototype stores, transition graphs, search reports, figures/tables, reusable evidence.

/workspace/models/nca-art-grn
  Purpose: promoted trained/evaluable model artifacts later; not skeleton dummy output by default.

/workspace/checkpoints/nca-art-grn
  Purpose: training checkpoints later; not skeleton dummy output by default.
```

### Orchestration consumers

```text
/workspace/repos/agentfield
  Owner role: aiengineer
  Purpose: later experiment controller/status bridge that consumes NCA-ART-GRN artifacts.

/workspace/repos/openclaw-workspace
  Owner role: aiengineer
  Purpose: selected-context reasoning over reports/artifacts; must not own science internals.

/workspace/pkm/zettelkasten
  Owner role: publisher
  Purpose: selected notes and paper context; must not be auto-overwritten.
```

## Output contracts

### Required local smoke artifact set

```text
/workspace/runs/nca-art-grn/smoke/<timestamp>/
  metadata.json
  candidate.dsl.json
  simulator_summary.json
  nca_summary.json
  art2_prototypes.json
  artmap_transitions.json
  pattern_dynamics.json
  perturbation_summary.json
  mechanism_report.md
```

### Required join fields

Every JSON artifact should include enough identifiers to join evidence without guessing:

```text
run_id
candidate_id
mechanism_hypothesis_id
seed
batch_slug
artifact_schema_version
created_at
source_config
source_command
status
failure_reason
```

### Mechanism report required headings

```text
Final pattern is not sufficient evidence
Mechanism hypothesis
Dynamics evidence
NCA local-rule evidence
ART2 prototype evidence
ARTMAP transition evidence
Perturbation prediction
Prototype-to-DSL recoverability
Experimental design suggestion
Falsification criterion
Open questions
```

### Search/scoring evidence fields

```text
nca_agreement_score
art2_prototype_quality_score
artmap_transition_consistency_score
prototype_to_dsl_recoverability_score
perturbation_response_score
mechanism_discrimination_value
experimental_design_usefulness
final_pattern_score
```

`final_pattern_score` may exist, but it must not be the only score or the final proof.

### Agentfield status mapping fields

```text
candidate_ref
mechanism_hypothesis_ref
simulator_summary_ref
nca_summary_ref
art2_prototypes_ref
artmap_transitions_ref
pattern_dynamics_ref
perturbation_summary_ref
mechanism_report_ref
stage_results
failure_reason
human_review_required
```

## Guardrails / non-goals

This annex does not authorize live or heavy science execution during skeleton batches.

Do not:

```text
edit the config tool
edit /home/vmuser/.local/bin/config.sh
edit /home/vmuser/.local/lib/config-sh/installers.sh
edit /home/vmuser/.local/etc/config-sh
run broad bootstrap
install heavy ML packages unless the active batch explicitly authorizes it
train full NCA models in skeleton batches
run large simulations in skeleton batches
run real ART clustering in skeleton batches unless a real-organ batch explicitly scopes a tiny deterministic local implementation
launch RunPod jobs by default
call RunPod APIs by default
build or start Docker containers by default
run Terraform/Kubernetes mutation
call live model/provider APIs by default
write to Paperclip live state by default
overwrite PKM notes or manuscript content by default
infer real biology from dummy outputs
treat final pattern similarity as proof
hide scientific assumptions inside Agentfield or Paperclip orchestration
```

## Smoke and validation relevance

Primary global smoke domain:

```text
70-grn-contract.smoke.sh
```

Possible future domains:

```text
72-search-contract.smoke.sh
75-runpod-dryrun.smoke.sh
85-agentfield.smoke.sh
88-agentfield-campaign.smoke.sh
```

Smoke must prove only file, schema, readiness, output-shape, and no-live guard behavior. Smoke must not prove scientific truth.

Recommended skeleton validation checks when relevant to the selected batch:

```bash
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/dsl
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/nca
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/art
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/mapping
find /workspace/runs/nca-art-grn/smoke -name candidate.dsl.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name nca_summary.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name art2_prototypes.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name artmap_transitions.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name mechanism_report.md | tail -n 1
```

Recommended no-live smoke constraints:

```text
No RunPod pod creation.
No Docker build/start.
No Terraform/Kubernetes mutation.
No live model/provider call.
No Paperclip live write.
No hidden credential print.
```

## How Codex should use this annex when generating a batch

For Batch 06:

```text
Read this annex with SPEC_Layer03_research_execution_loops.md.
Use it to populate Batch 06 PROJECT_CACHE.md, SPEC.md, and RUN_INSTRUCTIONS.md.
Keep the generated Codex prompt compact; reference this annex instead of copying the full NCA/ART/Agentfield background.
Implement only DSL and mechanism-hypothesis schema/base surfaces.
```

For Batch 07:

```text
Use this annex to shape dummy simulator, NCA, ART2, ARTMAP, pattern-dynamics, and perturbation outputs.
Do not train or run real organs.
```

For Batch 08:

```text
Use this annex to shape mechanism report headings, evidence references, falsification language, and prototype-to-DSL recoverability fields.
```

For Batch 09:

```text
Use this annex to verify the local smoke artifact set and no-live guard shape.
```

For Batches 10-12:

```text
Use this annex to keep search templates and scoring tied to mechanism evidence rather than final-image similarity alone.
```

For Batch 13:

```text
Use this annex to shape RunPod dry-run manifests and result-return policy around evidence artifacts and failure metadata.
```

For Batch 18:

```text
Use this annex to shape Agentfield NCA-ART bridge stubs and artifact/status mappings.
```

For real-organ batches:

```text
Use this annex as required input for R02, R03, R04, and R05.
Use it as recommended input for R06, R07, R09, and R12.
Preserve skeleton output filenames and schema shapes unless the transition master explicitly creates a versioned contract migration.
```

## Batch-creation hook relationship

Future batch-generation chats should not embed all of this annex logic inside `NEW_CHAT_PROMPT_batch_creation.md`.

Instead, `NEW_CHAT_PROMPT_batch_creation.md` should read the compact hook:

```text
BATCH_CREATION_ANX02_art_nca_core_architecture.md
```

The hook tells the batch-generation chat when to request this full SPEC annex and what selected-batch-relevant facts to copy into generated batch files.

## Open questions

```text
Should the first real NCA organ learn only from simulator-derived neighborhood rows, or also from target texture/pattern exemplars?
Which ART family should be the first real organ: ART2, Fuzzy ART, TopoART, dual-vigilance ART, or a minimal deterministic prototype learner with ART-compatible fields?
Should ARTMAP transitions be cell-local, prototype-graph-level, or both?
What is the canonical 5-node motif vocabulary for DSL provenance?
Which pattern dynamics metrics are mandatory for first real local smoke: wavelength, Fourier/mode growth, emergence time, recovery after perturbation, or all?
Which artifacts are promoted into PKM/paper context versus kept as run-only evidence?
What score or condition should set `human_review_required` in Agentfield/Paperclip later?
How much hidden NCA state should be persisted versus summarized?
Should RunPod dry-runs include cost-estimate fields before live submission is enabled?
Should the first real-organ implementation use `nca_art_core_schema_version: 0.1.0` across all outputs?
```

## Acceptance / success condition

This annex is successful when future Codex batch packages can refer to it and preserve the ART/NCA scientific control model without re-reading all source papers in full.

At minimum, a correct batch package using this annex should preserve:

```text
Batch 06 creates schema fields that can host real NCA/ART evidence later.
Batch 07 dummy outputs look like replaceable future real organs.
Batch 08 report headings keep falsification and mechanism-discrimination central.
Batch 09 smoke output includes the complete local evidence artifact set.
Search/scoring batches treat pattern score as one weak signal among many.
RunPod dry-run returns selected evidence artifacts and failure metadata, not uncontrolled dumps.
Agentfield later orchestrates over stable artifact/status contracts instead of owning hidden science.
```
