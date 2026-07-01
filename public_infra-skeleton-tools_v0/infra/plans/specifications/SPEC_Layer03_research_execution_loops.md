# Layer 3 — Research Execution Loops

**Combined markdown layer file**  
**Layer name:** Research Execution Loops  
**Authoritative planning status:** skeleton-dummy planning layer, aligned to the current A1/A2 batch plan and smoke mapping.  
**Primary workspace:** `/workspace/repos/nca-art-grn`  
**Primary shared outputs:** `/workspace/data/nca-art-grn`, `/workspace/runs/nca-art-grn`, `/workspace/artifacts/nca-art-grn`, `/workspace/models/nca-art-grn`, `/workspace/checkpoints/nca-art-grn`

---

## 0. Merge authority and conflict rule

This file combines the Layer 3 product-owner file and the three Layer 3 bundle files into one working Layer 3 markdown file.

The merge uses this precedence order:

1. `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md` are the most up-to-date implementation and smoke/batch authority.
2. `00_A0_skeleton_dummy_master_implementation_companion.md` is the authoritative master implementation companion for the full skeleton-dummy pass.
3. `new_chat.md` defines how future Codex-ready batch packages should be generated.
4. `day_to_day_skeleton_run.md`, `final_workflow.md`, and `smoke_module_update_workflow.md` define daily execution, smoke, companion, and config-integration process.
5. The original Layer 3 product-owner and bundle files are retained as background semantics, research intent, and scientific direction.

When product-owner wording conflicts with A1/A2, this combined file keeps the A1/A2 version. In particular:

- Layer files are background semantics, not batch slices.
- The 01–24 skeleton batch plan remains the slicing authority.
- Layer 3 is implemented through Skeleton Batches **06–13**, not as one monolithic batch.
- Layer 3 does not build Agentfield, Paperclip, OpenClaw reasoning, publisher output, dashboards, or live campaign orchestration.
- Layer 3 prepares the research execution machinery manually and reproducibly first.

---

## 1. Layer 3 product goal

Layer 3 turns the prepared runtime and role workstations into executable scientific research loops.

Layer 1 prepares the portable runtime substrate.  
Layer 2 prepares role workstations and project roots.  
Layer 3 prepares the actual research machinery:

- symbolic DSL candidate mechanisms;
- PDE/ODE simulation contracts;
- simulator-to-NCA dataset contracts;
- NCA local-rule/surrogate contracts;
- ART2 prototype discovery contracts;
- ARTMAP transition contracts;
- prototype-to-DSL mapping contracts;
- mechanism-discrimination reporting;
- parameter search and comparison tools;
- local smoke runs;
- RunPod training/inference/campaign dry-run contracts.

Layer 3 is where the MRes/research platform begins to become executable, but still in **skeleton-dummy** form.

---

## 2. Correct scientific direction

The core scientific guardrail is:

```text
A nice final pattern is not enough.
```

The system must not treat a visually plausible Turing-like pattern as proof of the correct biological mechanism. Candidate mechanisms must instead be assessed through:

- formation dynamics;
- perturbation response;
- parameter constraints;
- robustness and resimulation;
- ART2 prototype evidence;
- ARTMAP transition evidence;
- NCA agreement or disagreement;
- DSL recoverability;
- falsifiable experimental predictions.

The correct research loop is:

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

This preserves the intended architecture:

- the PDE/ODE simulator is the authoritative forward model;
- NCA is a learned or testable local cell-update layer;
- ART2 discovers continuous state prototypes;
- ARTMAP learns transitions and local mappings;
- DSL stores human-readable candidate mechanisms;
- reports must explain how a mechanism could be falsified or experimentally distinguished.

---

## 3. Whole-system position

Layer 3 sits in the platform as follows:

```text
config
  owns setup, target roles, package policy, path preparation, and managed checks

nca-art-grn repo
  owns research code: DSL, simulator, NCA, ART2, ARTMAP, search, mapping, reporting

/workspace/data, /workspace/runs, /workspace/artifacts, /workspace/models, /workspace/checkpoints
  own large inputs, run outputs, reports, prototypes, models, checkpoints, and dry-run evidence

RunPod later
  executes expensive training/search/inference runs from the same manifest and artifact contracts

Agentfield later
  orchestrates experiments and campaigns using these repo contracts

Paperclip later
  presents runs, statuses, artifacts, review actions, and human decisions
```

Layer 3 steps are mostly **config-managed preparation/check/smoke concepts** and **repo-owned skeleton-dummy code/contracts**. They are not full Agentfield steps yet. Agentfield will later call these repo entrypoints.

---

## 4. Layer 3 bundles and skeleton batches

Layer 3 contains three bundles, split across Skeleton Batches 06–13.

| Layer 3 bundle | Purpose | Skeleton batches | Batch slugs |
|---|---|---:|---|
| Bundle 3 — NCA-ART-DSL mechanism discovery stack | Core mechanism loop and local science smoke | 06–09 | `06-nca-art-base`, `07-dummy-science-organs`, `08-mechanism-reporting`, `09-local-smoke` |
| Bundle 4 — Parameter search comparison and mechanism-testing tools | Search, scoring, ranking, robustness, and search smoke | 10–12 | `10-search-templates`, `11-search-scoring`, `12-search-smoke` |
| Bundle 5 — RunPod training / inference / campaign execution loop | Remote execution layout, manifests, job templates, local dry-run only | 13 | `13-runpod-dryrun` |

---

## 5. Layer 3 must not do yet

Layer 3 must not:

- build the Agentfield controller;
- build the Paperclip adapter;
- build dashboards;
- automate full campaigns;
- hide scientific steps behind agents;
- launch RunPod jobs;
- spend RunPod credits;
- call live model/provider APIs;
- run full NCA training;
- run large simulations;
- run real parameter campaigns;
- infer real biology from dummy output;
- treat final pattern similarity as proof;
- edit the config tool or any `/home/vmuser/.local` config internals.

---

## 6. Step type legend

| Type | Meaning |
|---|---|
| `CONFIG STEP` | A managed bootstrap/check/smoke concept invoked by `config` or later exposed through config integration. In this skeleton pass, the project batch may create repo scripts/contracts and write an integration request, but must not edit config internals. |
| `REPO CODE` | Python modules, schemas, configs, fixtures, tests, and scripts inside `/workspace/repos/nca-art-grn`. |
| `RESEARCH OUTPUT` | Data, run outputs, prototype stores, transition graphs, reports, ranked candidates, dry-run status, models, and checkpoints under `/workspace/*` roots. |
| `REMOTE EXECUTION` | RunPod or similar remote execution. In Layer 3 skeleton, this is dry-run only. |
| `AGENTFIELD LATER` | Future orchestration layer. Not implemented in Layer 3 skeleton batches. |
| `PAPERCLIP LATER` | Future UI/review layer. Not implemented in Layer 3 skeleton batches. |

---

## 7. Corrected Layer 3 batch map

### Batch 06 — NCA-ART-GRN base

| Field | Correct mapping |
|---|---|
| Scope | Layer 3 / Bundle 3A |
| Branch | `skeleton/06-nca-art-base` |
| Steps smoked | `prepare_dsl_candidate_runtime`, `prepare_mechanism_hypothesis_runtime` |
| Smoke modules | `70-grn-contract.smoke.sh` |
| Smoke verifies | DSL schema/modules/configs, mechanism hypothesis schema/configs, fake 5-node candidate, package import/syntax |
| Must not do | Run simulation, train NCA, run ART2/ARTMAP, claim discovery |

Batch 06 is schema/base contract work, not execution. The DSL must encode topology, signs, interaction matrix, reaction/diffusion parameters, constraints, observables, and perturbables. Mechanism hypotheses must include predicted tests rather than only pattern images.

### Batch 07 — Dummy science organs

| Field | Correct mapping |
|---|---|
| Scope | Layer 3 / Bundle 3B |
| Branch | `skeleton/07-dummy-science-organs` |
| Steps smoked | `prepare_pde_ode_simulation_runtime`, `prepare_nca_cell_runtime`, `prepare_pde_ode_to_nca_dataset`, `prepare_art2_discovery_runtime`, `prepare_artmap_transition_runtime`, `prepare_pattern_dynamics_metrics`, `prepare_interaction_function_inference_runtime`, `prepare_perturbation_design_runtime` |
| Smoke modules | `70-grn-contract.smoke.sh` |
| Smoke verifies | Dummy simulator/NCA/ART2/ARTMAP/perturbation outputs and expected JSON shapes |
| Must not do | Large simulations, real NCA training, RunPod, parameter campaigns, real biological claims |

Batch 07 is broader than only simulator, NCA, ART2, and ARTMAP. It also includes mechanism-discrimination and dynamics/perturbation-oriented dummy contracts.

### Batch 08 — Mechanism reporting

| Field | Correct mapping |
|---|---|
| Scope | Layer 3 / Bundle 3C |
| Branch | `skeleton/08-mechanism-reporting` |
| Steps smoked | `prepare_prototype_store`, `prepare_transition_graph_store`, `prepare_prototype_to_dsl_runtime`, `prepare_mechanism_discrimination_report` |
| Smoke modules | `70-grn-contract.smoke.sh` |
| Smoke verifies | Prototype store, transition graph store, prototype-to-DSL stubs, mechanism report with guardrail headings |
| Must not do | Infer real biology, overwrite reports, treat final pattern as proof |

Mechanism reports must include discrimination/falsification framing.

Required report guardrail headings:

```text
Final pattern is not sufficient evidence
Mechanism hypothesis
Dynamics evidence
Perturbation prediction
Experimental design suggestion
Falsification criterion
```

### Batch 09 — Local science smoke

| Field | Correct mapping |
|---|---|
| Scope | Layer 3 / Bundle 3D |
| Branch | `skeleton/09-local-smoke` |
| Steps smoked | `prepare_nca_art_smoke_configs`, `check_nca_art_pipeline_inputs`, `run_nca_art_local_smoke` |
| Smoke modules | `70-grn-contract.smoke.sh` |
| Smoke verifies | Tiny local smoke config and output folder with required artifacts |
| Must not do | Large simulations, full NCA training, RunPod, parameter campaigns, claim discovery |

Required local smoke output folder:

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

### Batch 10 — Search templates

| Field | Correct mapping |
|---|---|
| Scope | Layer 3 / Bundle 4A |
| Branch | `skeleton/10-search-templates` |
| Steps smoked | `prepare_search_parameter_space`, `prepare_random_grid_baselines`, `prepare_lhs_search_template`, `prepare_evolutionary_search_template`, `prepare_bayesian_search_template`, `prepare_active_learning_search_template` |
| Smoke modules | `70-grn-contract.smoke.sh`, future `72-search-contract.smoke.sh` if split |
| Smoke verifies | Search configs, parameter-space schema, baseline/search method templates |
| Must not do | Run real search, launch campaigns, use distributed compute |

Search must compare methods by mechanism evidence, dynamics, perturbation response, DSL recoverability, and experimental-design value, not just final pattern score.

### Batch 11 — Search scoring

| Field | Correct mapping |
|---|---|
| Scope | Layer 3 / Bundle 4B |
| Branch | `skeleton/11-search-scoring` |
| Steps smoked | `prepare_mechanism_scoring_runtime`, `prepare_search_result_comparison_schema`, `prepare_candidate_ranking_runtime`, `prepare_robustness_sweep_template`, `prepare_perturbation_search_template`, `prepare_search_report_runtime` |
| Smoke modules | `70-grn-contract.smoke.sh`, future `72-search-contract.smoke.sh` |
| Smoke verifies | Scoring schema, shared result schema, ranking config, robustness/perturbation templates, search report template |
| Must not do | Expensive sweeps, real campaigns, model training |

Batch 11 is where the search becomes scientifically comparable through mechanism-discrimination fields.

### Batch 12 — Search smoke

| Field | Correct mapping |
|---|---|
| Scope | Layer 3 / Bundle 4C |
| Branch | `skeleton/12-search-smoke` |
| Steps smoked | `prepare_search_smoke_configs`, `check_parameter_search_inputs`, `run_parameter_search_local_smoke` |
| Smoke modules | `70-grn-contract.smoke.sh`, future `72-search-contract.smoke.sh` |
| Smoke verifies | Tiny dummy search run writes results, ranking, and report |
| Must not do | Real candidate campaigns, RunPod, full NCA training |

Batch 12 may run, but only a tiny local dummy search smoke.

### Batch 13 — RunPod dry-run

| Field | Correct mapping |
|---|---|
| Scope | Layer 3 / Bundle 5 |
| Branch | `skeleton/13-runpod-dryrun` |
| Steps smoked | `prepare_runpod_training_workspace`, `prepare_runpod_inference_workspace`, `prepare_candidate_batch_layout`, `prepare_training_run_layout`, `prepare_checkpoint_policy`, `prepare_result_return_policy`, `prepare_remote_run_manifest_schema`, `prepare_runpod_job_templates`, `prepare_runpod_nca_training_configs`, `prepare_runpod_art_discovery_configs`, `prepare_runpod_search_campaign_configs`, `prepare_runpod_mechanism_report_configs`, `check_runpod_training_ready`, `run_runpod_local_dryrun_smoke` |
| Smoke modules | future `75-runpod-dryrun.smoke.sh`, `60-infra-tools.smoke.sh` only for optional command presence |
| Smoke verifies | Local manifests, workspace layout, job templates, dry-run report/status |
| Must not do | Create RunPod pod, spend credits, call RunPod API, start containers |

Batch 13 prepares the remote execution layer only as a safe local dry-run foundation. Remote success later means returned mechanism evidence, not a nice image.

---

## 8. Bundle 3 — NCA-ART-DSL mechanism discovery stack

### Bundle objective

Prepare the `nca-art-grn` repo so the Research Scientist can run the first local mechanism-discovery loop in skeleton-dummy form.

This bundle is not just:

```text
generate pattern -> score pattern
```

It is:

```text
generate candidate mechanism
simulate dynamics
learn/test NCA cell-rule behavior
discover ART2/ARTMAP prototypes and transitions
map behavior back to DSL
ask what perturbation would distinguish this mechanism
```

### User story

```text
As the Research Scientist,
I want config/project skeletons to prepare the NCA-ART-GRN research engine,
so that I can generate DSL-defined GRN mechanisms, simulate them, train/test NCA
local rules, discover ART2/ARTMAP prototype transitions, and produce mechanism
reports that propose experiments to distinguish the right patterning mechanism.
```

### Bundle 3 managed steps

| Step | Type | Owner / target | Creates or validates | Research meaning | Platform link |
|---|---|---|---|---|---|
| `prepare_dsl_candidate_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | `src/nca_art_grn/dsl/`, `configs/dsl/`, fake 5-node candidate | Formal language for 5-node GRN topology, signs, parameters, diffusion, motif provenance, observables, perturbables | Search samples DSL candidates; runs snapshot candidate DSL; Agentfield later passes DSL into experiments |
| `prepare_mechanism_hypothesis_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | `src/nca_art_grn/mechanisms/`, `configs/mechanisms/` | Forces each candidate to state mechanism class, dynamics predictions, perturbation predictions, falsification criteria | Mechanism reports and search scoring use this metadata |
| `prepare_pde_ode_simulation_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | Simulator stub writing `simulator_summary.json`, trajectory/dynamics placeholders | Authoritative forward model contract; captures dynamics, not just final state | NCA dataset, ART2/ARTMAP, smoke and reports consume simulator outputs |
| `prepare_nca_cell_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | NCA stub writing `nca_summary.json` | Learned/testable local cell-update rule or surrogate | Compares NCA rollout to PDE/ODE and perturbation replay |
| `prepare_pde_ode_to_nca_dataset` | CONFIG STEP / REPO CODE | `researchscientist` | Dataset schema for center/neighborhood `t -> t+1` rows | Makes simulator trajectories train/testable by NCA | Dataset is reused by local and RunPod training configs |
| `prepare_art2_discovery_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | ART2 stub writing `art2_prototypes.json` | Discovers recurring continuous local states/prototypes | Prototype store, reports, search scores consume prototypes |
| `prepare_artmap_transition_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | ARTMAP stub writing `artmap_transitions.json` | Learns local/prototype transition mappings | Transition graphs support mechanism discrimination |
| `prepare_pattern_dynamics_metrics` | CONFIG STEP / REPO CODE | `researchscientist` | Wavelength, Fourier/mode growth, emergence-time, recovery stubs | Measures formation dynamics, not only final pattern | Search scoring and mechanism reports consume dynamics metrics |
| `prepare_interaction_function_inference_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | K(x)-style interaction inference stubs | Compares molecular/cellular/mechanical interaction signatures | Prevents claiming Turing mechanism from final pattern alone |
| `prepare_perturbation_design_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | Diffusion/boundary/initial/local-ablation perturbation configs and output stubs | Generates discriminating perturbation predictions | Reports contain experimental design suggestions |
| `prepare_prototype_store` | CONFIG STEP / RESEARCH OUTPUT | `researchscientist` | `/workspace/artifacts/nca-art-grn/prototypes/{art2,fuzzy_art,topo_art,dual_vigilance}` | Persistent prototype evidence | Later campaigns and reports reference prototype artifacts |
| `prepare_transition_graph_store` | CONFIG STEP / RESEARCH OUTPUT | `researchscientist` | `/workspace/artifacts/nca-art-grn/transition_graphs/{art2,artmap,prototype_transitions,nca_rule_transitions}` | Persistent transition evidence | Later Agentfield/Paperclip statuses can point to transition artifacts |
| `prepare_prototype_to_dsl_runtime` | CONFIG STEP / REPO CODE | `researchscientist` | Mapper stub from prototypes/transitions to fake DSL candidate | Links discovered behavior back to symbolic mechanisms | Search and reports evaluate DSL recoverability |
| `prepare_mechanism_discrimination_report` | CONFIG STEP / REPO CODE + OUTPUT | `researchscientist` | Report template under `/workspace/artifacts/nca-art-grn/mechanism_reports/` | Explicitly asks what experiment would distinguish the mechanism | Bundle 9 notes, Bundle 10 paper, Agentfield status, Paperclip review later consume reports |
| `prepare_nca_art_smoke_configs` | CONFIG STEP / REPO CONFIG | `researchscientist` | Tiny smoke configs for pipeline, mechanism discrimination, diffusion scaling, pattern dynamics, interaction function | Keeps end-to-end tests cheap and inspectable | `70-grn-contract` can validate configs and outputs |
| `check_nca_art_pipeline_inputs` | CONFIG CHECK STEP | `researchscientist` | Readiness report; no run | Prevents missing schema/config/store failures | Later Agentfield preflight can reuse check logic |
| `run_nca_art_local_smoke` | CONFIG SMOKE STEP | `researchscientist` | Tiny local dummy run under `/workspace/runs/nca-art-grn/smoke/<timestamp>/` | Proves the local research loop wiring works | Later replaced by real tiny science smoke with same output contract |

### Bundle 3 important schemas and fields

DSL candidates must encode:

```text
5-node GRN topology
activation/repression signs
interaction matrix
reaction parameters
diffusion parameters
motif provenance
known 2/3/4-node motif embedding
candidate constraints
experimental observables
perturbable parameters
```

Mechanism hypotheses must encode:

```text
mechanism_class
expected local activation source
expected long-range inhibition source
diffusion or transport assumptions
pattern-spacing prediction
dynamics prediction
perturbation predictions
required measurable parameters
falsification criteria
```

Simulator/NCA dataset rows should encode:

```text
candidate_id
mechanism_hypothesis_id
time_t
time_t_plus_1
center_state_t
neighborhood_state_t
center_state_next
diffusion_parameters
reaction_parameters
boundary_conditions
perturbation_id
pattern_metrics_at_t
```

Prototype store records should encode:

```text
prototype_id
method
mechanism_hypothesis_id
candidate_id
input_schema
prototype_vector
support_count
source_runs
perturbation_contexts
```

Transition graph records should encode:

```text
source_prototype
target_prototype
frequency
mechanism_hypothesis_id
candidate_id
perturbation_id
time_delta
context_features
transition_score
recovery_or_failure_flag
```

### Bundle 3 acceptance checks

Registry / step checks should include:

```bash
config bootstrap steps | grep prepare_mechanism_hypothesis_runtime
config bootstrap steps | grep prepare_pattern_dynamics_metrics
config bootstrap steps | grep prepare_interaction_function_inference_runtime
config bootstrap steps | grep prepare_perturbation_design_runtime
config bootstrap steps | grep prepare_mechanism_discrimination_report
```

Structure checks should include:

```bash
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/mechanisms
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/analysis
test -d /workspace/repos/nca-art-grn/configs/mechanisms
test -d /workspace/repos/nca-art-grn/configs/perturbations
test -d /workspace/artifacts/nca-art-grn/mechanism_reports
```

Smoke output checks should include:

```bash
sudo config --target researchscientist bootstrap step run_nca_art_local_smoke
find /workspace/runs/nca-art-grn/smoke -name mechanism_report.md | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name pattern_dynamics.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name perturbation_summary.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name art2_prototypes.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name artmap_transitions.json | tail -n 1
```

Skeleton batches may create repo scripts/contracts and dummy outputs. They must not edit config internals to make these commands real config steps. If later config exposure is needed, the batch writes `INTEGRATION_REQUEST.md`.

---

## 9. Bundle 4 — Parameter search comparison and mechanism-testing tools

### Bundle objective

Prepare the search and comparison layer for the NCA-ART-GRN research engine.

Bundle 3 evaluates one candidate mechanism deeply.  
Bundle 4 makes that loop searchable, comparable, and scientifically testable.

The goal is not:

```text
find a candidate that makes a nice final pattern
```

The correct goal is:

```text
compare search methods by how well they find candidate mechanisms that:
produce plausible dynamics,
survive perturbation checks,
generate useful ART2/ARTMAP structure,
map back into DSL,
and suggest discriminating experimental tests.
```

### User story

```text
As the Research Scientist,
I want prepared parameter-search and comparison tools,
so that I can compare random/grid, Latin hypercube, evolutionary, Bayesian,
and robustness-driven searches for 5-node GRN mechanisms, using not only final
pattern scores but also dynamics, NCA agreement, ART2/ARTMAP evidence,
DSL recoverability, perturbation response, and experimental-design value.
```

### Bundle 4 managed steps

| Step | Type | Creates or validates | Research meaning | Platform link |
|---|---|---|---|---|
| `install_parameter_search_comparison_stack` | CONFIG STEP / package policy | Package policy for Optuna, scikit-optimize, DEAP, SALib, SciPy, scikit-learn, pandas, numpy, networkx, pydantic, YAML tooling | Gives the research role search/comparison tooling | Config may later expose package policy; skeleton should not heavy-install unless explicit |
| `prepare_search_parameter_space` | CONFIG STEP / REPO CODE | `src/nca_art_grn/search/parameter_space.py`, constraints, `configs/search/parameter_space_5node.yaml` | Defines what is searchable while preserving biological and mechanism constraints | Search methods sample from this space; Agentfield later passes campaign configs |
| `prepare_random_grid_baselines` | CONFIG STEP / REPO CODE | Random/grid baseline module and config | Honest baseline every smarter method must beat | Comparison reports use this lower-bound reference |
| `prepare_lhs_search_template` | CONFIG STEP / REPO CODE | Latin hypercube sampler and config | Better early coverage of continuous parameter space | Bundle 5 later scales LHS batches remotely |
| `prepare_evolutionary_search_template` | CONFIG STEP / REPO CODE | Evolutionary, mutation, crossover, selection stubs/configs | Evolves candidate GRNs toward mechanism evidence, not pretty images | Search outputs become ranked candidate artifacts |
| `prepare_bayesian_search_template` | CONFIG STEP / REPO CODE | Bayesian optimizer and surrogate objective stubs/configs | Helps when simulations/NCA/ART evaluations are expensive | Later remote campaigns checkpoint surrogate state |
| `prepare_active_learning_search_template` | CONFIG STEP / REPO CODE | Active sampling and uncertainty stubs/configs | Chooses candidates/perturbations that teach the most about mechanisms | Agentfield later can schedule most-informative next runs |
| `prepare_mechanism_scoring_runtime` | CONFIG STEP / REPO CODE | Scoring/objective modules and config | Encodes final pattern as one weak score among many mechanism evidence scores | Search methods optimize mechanism-discrimination value |
| `prepare_search_result_comparison_schema` | CONFIG STEP / REPO CODE + OUTPUT CONTRACT | Result schema module and YAML | Makes random, LHS, evolutionary, Bayesian, and active methods comparable | Agentfield/Paperclip later use schema as status/review payload source |
| `prepare_candidate_ranking_runtime` | CONFIG STEP / REPO CODE | Ranking/Pareto modules and config | Prevents one metric from dominating; supports diversity and multi-objective ranking | Candidate shortlist feeds reports and later campaigns |
| `prepare_robustness_sweep_template` | CONFIG STEP / REPO CODE | Robustness sweep module/config | Tests whether candidates are mechanisms or fragile accidents | Bundle 5 later scales robustness sweeps |
| `prepare_perturbation_search_template` | CONFIG STEP / REPO CODE | Perturbation search module/config | Finds informative perturbations and experimental predictions | Mechanism reports record falsification tests |
| `prepare_search_report_runtime` | CONFIG STEP / REPO CODE + OUTPUT PATH | Report module and `/workspace/artifacts/nca-art-grn/search_reports/` | Turns search into scientific decision material | Bundle 9 notes, Bundle 10 paper, Agentfield/Paperclip later consume reports |
| `prepare_search_smoke_configs` | CONFIG STEP / REPO CONFIG | Tiny smoke configs for random/grid, LHS, evolutionary, Bayesian, comparison | Confirms search wiring before spending time/money | `70-grn-contract` or future `72-search-contract` validates outputs |
| `check_parameter_search_inputs` | CONFIG CHECK STEP | Readiness report; no search | Prevents missing search modules/configs/package policy failures | Later Agentfield preflight can reuse |
| `run_parameter_search_local_smoke` | CONFIG SMOKE STEP | Tiny dummy local search run writes results/ranking/report | Proves the local search contract | Later same command shape can run real tiny search |

### Search parameter space must encode

```text
5-node GRN topology variables
activation/repression signs
edge presence/absence
interaction matrix ranges
reaction parameter ranges
diffusion parameter ranges
initial condition families
boundary condition families
perturbation parameters
known 2/3/4-node motif seeds
motif embedding rules
biological plausibility constraints
candidate budget
simulation budget
NCA training/evaluation budget
ART2 vigilance ranges
ARTMAP transition settings
```

### Mechanism scoring must include

```text
final pattern score
pattern dynamics score
wavelength stability score
mode growth score
NCA agreement score
ART2 prototype quality score
ARTMAP transition consistency score
prototype-to-DSL recoverability score
perturbation response score
robustness score
mechanism-discrimination value
experimental-design usefulness
```

### Search result schema must record

```text
search_method
candidate_id
mechanism_hypothesis_id
seed
parameter_set
topology_summary
motif_provenance
simulation_status
NCA_status
ART2_status
ARTMAP_status
pattern_metrics
dynamics_metrics
perturbation_metrics
mechanism_score
failure_reason
artifact_paths
report_path
```

### Bundle 4 local smoke output contract

A tiny dummy search smoke should write at least:

```text
/workspace/runs/nca-art-grn/search/smoke/<timestamp>/
results.jsonl
ranking.json
search_report.md
```

It must not run real candidate campaigns, RunPod, or full NCA training.

---

## 10. Bundle 5 — RunPod training / inference / campaign execution loop

### Bundle objective

Prepare the remote execution layer for expensive NCA-ART-GRN research runs.

Bundle 3 prepares the single-candidate mechanism loop.  
Bundle 4 prepares search and comparison tools.  
Bundle 5 moves expensive candidate batches, NCA training, ART2/ARTMAP discovery, perturbation sweeps, and result return onto remote compute later.

Bundle 5 does not invent new science. It scales the science from Bundles 3 and 4.

### User story

```text
As the Research Scientist / Operator,
I want a prepared RunPod execution loop for NCA-ART-GRN experiments,
so that candidate batches, NCA training, ART2/ARTMAP discovery, perturbation sweeps,
and mechanism reports can run remotely, return results safely, and remain comparable
with local smoke runs.
```

### Bundle 5 managed steps

| Step | Type | Creates or validates | Research meaning | Platform link |
|---|---|---|---|---|
| `prepare_runpod_training_workspace` | CONFIG STEP / RESEARCH OUTPUT | `/workspace/runs/nca-art-grn/runpod/`, `/workspace/checkpoints/nca-art-grn/`, `/workspace/models/nca-art-grn/`, `/workspace/artifacts/nca-art-grn/runpod/` | Stable place for expensive training/search outputs outside repo | RunPod and Agentfield later reference these paths |
| `prepare_runpod_inference_workspace` | CONFIG STEP / RESEARCH OUTPUT | Inference run/artifact/model/input folders | Separates training from evaluation/inference | Trained checkpoints feed inference and perturbation replay |
| `prepare_candidate_batch_layout` | CONFIG STEP / RESEARCH OUTPUT | Candidate batch folders and manifest template | Sends controlled DSL candidate sets to remote compute | Bundle 4 produces ranked candidates; Bundle 5 packages them |
| `prepare_training_run_layout` | CONFIG STEP / TEMPLATE | Standard `run_manifest.yaml`, logs, checkpoints, outputs, artifacts, reports, status layout | Makes remote runs reproducible and auditable | Agentfield later maps manifest to experiment status |
| `prepare_checkpoint_policy` | CONFIG STEP / TEMPLATE | `configs/runpod/checkpoint_policy.yaml`, checkpoint README | Protects expensive NCA training and prevents checkpoint sprawl | Inference jobs consume promoted checkpoints |
| `prepare_result_return_policy` | CONFIG STEP / TEMPLATE | `configs/runpod/result_return_policy.yaml`, result-return README | Ensures remote results return mechanism evidence, not uncontrolled dumps | Bundle 9/10 and Paperclip consume selected artifacts |
| `prepare_remote_run_manifest_schema` | CONFIG STEP / REPO CODE | `src/nca_art_grn/runs/remote_manifest.py`, remote schema YAML | Makes local, RunPod, and later Agentfield runs speak same language | Agentfield later creates manifests from experiment specs |
| `prepare_runpod_job_templates` | CONFIG STEP / TEMPLATE | `scripts/runpod/*.sh`, job template configs | Repeatable remote commands without ad hoc shell incantations | Agentfield later calls the same templates |
| `prepare_runpod_nca_training_configs` | CONFIG STEP / REPO CONFIG | Small/medium/resume NCA training configs | Scales NCA training from smoke to remote | Checkpoints feed inference workspace |
| `prepare_runpod_art_discovery_configs` | CONFIG STEP / REPO CONFIG | ART2/ARTMAP/prototype-to-DSL batch configs | Runs ART discovery on larger trajectory sets later | Outputs prototypes, transitions, mechanism reports |
| `prepare_runpod_search_campaign_configs` | CONFIG STEP / REPO CONFIG | Remote search campaign configs | Moves Bundle 4 search comparison from toy local to remote campaigns later | Agentfield later tracks campaign status/costs |
| `prepare_runpod_mechanism_report_configs` | CONFIG STEP / REPO CONFIG | Batch mechanism report configs/templates | Ensures remote campaigns return science-ready interpretation | Reports feed notes, paper, Agentfield status, Paperclip review |
| `check_runpod_training_ready` | CONFIG CHECK STEP | Non-mutating readiness report | Prevents expensive remote failures caused by missing paths/configs/packages/GPU | Agentfield later runs preflight |
| `run_runpod_local_dryrun_smoke` | CONFIG SMOKE STEP | Local dry-run only; writes dry-run manifest/status/report | Confirms remote-run contract without spending money | Future submit/pull/resume use same manifest shape |

Optional later commands must remain explicit and guarded:

```text
submit_runpod_training_job
pull_runpod_results
resume_runpod_checkpoint
```

They are not automatic prepare steps and must not be activated in the skeleton-dummy pass.

### Candidate batch layout

```text
/workspace/data/nca-art-grn/candidate_batches/
pending/
active/
completed/
failed/
```

Each batch should contain:

```text
batch_manifest.yaml
candidates/
  candidate_000001.dsl.json
  candidate_000002.dsl.json
configs/
  evaluation_config.yaml
  perturbation_config.yaml
metadata.json
```

The batch manifest must encode:

```text
batch_id
created_by
candidate_count
source_search_method
mechanism_hypothesis_ids
simulation_budget
nca_budget
art2_settings
artmap_settings
perturbation_plan
expected_outputs
```

### Remote run layout

```text
/workspace/runs/nca-art-grn/runpod/<run_id>/
run_manifest.yaml
environment.json
command.txt
inputs/
logs/
checkpoints/
outputs/
artifacts/
reports/
status.json
```

`run_manifest.yaml` must encode:

```text
run_id
batch_id
repo_commit_or_snapshot
target_role
python_env
container_image
gpu_type
started_at
command
input_paths
output_paths
checkpoint_paths
cost_policy
failure_policy
```

### Result return policy must promote or return

```text
metadata.json
run_manifest.yaml
candidate DSL files
pattern_dynamics.json
nca_summary.json
art2_prototypes.json
artmap_transitions.json
perturbation_summary.json
mechanism_report.md
search_report.md
figures/
tables/
logs summary
failure_reason.txt
```

It should avoid uncontrolled huge files by default.

### RunPod local dry-run output contract

```text
/workspace/runs/nca-art-grn/runpod/dryrun/<timestamp>/
run_manifest.yaml
command.txt
status.json
dryrun_report.md
```

The dry-run must not create a RunPod pod, call the RunPod API, start containers, or spend credits.

---

## 11. Layer 3 smoke model

Layer 3 uses the global dynamic smoke framework. Do not create one global smoke module per batch.

Relevant global modules:

| Domain | Global module | Layer 3 use |
|---|---|---|
| GRN/NCA/ART contracts | `70-grn-contract.smoke.sh` | Batches 06–12; may later call local repo smoke routines |
| Search contracts | future `72-search-contract.smoke.sh` if split | Optional future split when search becomes large enough |
| RunPod dry-run | future `75-runpod-dryrun.smoke.sh` | Batch 13 manifests/job templates/local dry-run |
| Infra tools | `60-infra-tools.smoke.sh` | Optional command presence only for RunPod/GPU tooling |
| Skeleton evidence | `30-skeleton-evidence.smoke.sh` | Confirms `POSTCHECK.md` and `INTEGRATION_REQUEST.md` |
| Config boundary | `50-config-boundary.smoke.sh` | Confirms project batches did not edit config internals |

Local smoke routines belong inside the relevant repo and may be called by a global module. Likely Layer 3 local routines include:

```text
/workspace/repos/nca-art-grn/scripts/dsl_smoke.sh
/workspace/repos/nca-art-grn/scripts/simulator_smoke.sh
/workspace/repos/nca-art-grn/scripts/nca_smoke.sh
/workspace/repos/nca-art-grn/scripts/art_smoke.sh
/workspace/repos/nca-art-grn/scripts/mechanism_report_smoke.sh
/workspace/repos/nca-art-grn/scripts/search_smoke.sh
/workspace/repos/nca-art-grn/scripts/local_smoke.sh
/workspace/repos/nca-art-grn/scripts/runpod_manifest_smoke.sh
```

Update global `70-grn-contract.smoke.sh` or future `72-search-contract.smoke.sh` only when the public contract changes, for example:

- expected JSON filenames;
- expected report filenames;
- schema fields;
- artifact folder layout;
- safe CLI command paths;
- local smoke command path;
- PASS/WARN/FAIL classification;
- batch applicability by phase/slug.

Do not update global modules merely because implementation internals changed.

---

## 12. Daily skeleton run process for Layer 3

For each Layer 3 skeleton batch, follow the day-to-day skeleton loop:

```text
S-T1  ChatGPT creates one Codex-ready skeleton batch package.
S-T2  Human/Codex stages the package.
S-T3  Codex implements the batch under /workspace and writes evidence.
S-T4  Codex runs dynamic smoke using a cache-aware smoke instruction set.
S-T5  Human/ChatGPT classifies PASS/WARN/FAIL.
S-T6  ChatGPT/Codex updates companion only at logical checkpoints or contract changes.
```

Minimum continue rule after each batch:

```text
Do not start the next skeleton batch until the current batch has:
1. POSTCHECK.md
2. INTEGRATION_REQUEST.md
3. a smoke report path
4. PASS, SKIP, or accepted documented WARN
```

Layer 3 companion update is recommended after these logical groups:

| Logical group | Batches | Companion update trigger |
|---|---:|---|
| GRN/NCA/ART science contracts | 06–09 | DSL/schema, dummy organ outputs, mechanism reports, local smoke output contract changes |
| Search contracts | 10–12 | Search templates, scoring/report schemas, ranking outputs, local search smoke changes |
| RunPod dry-run | 13 | Manifest, job-template, dry-run output, secret-name, or no-live RunPod guard changes |

---

## 13. How to generate Codex-ready Layer 3 batch packages

Use `new_chat.md` as the prompt basis. For Layer 3, set `BATCH_NUMBER` to one of:

```text
06
07
08
09
10
11
12
13
```

Required planning files for generation:

```text
00_A1_skeleton_dummy_codex_batch_plan_v2.md
00_A0_skeleton_dummy_master_implementation_companion.md
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
CONFIG_TOOL.md only when role/config/lv context is needed
```

For this current merge context, the following additional files are important background:

```text
00_A2_skeleton_batch_mapping_report_batches_01_24.md
day_to_day_skeleton_run.md
final_workflow.md
smoke_module_update_workflow.md
```

Generated batch zips must contain exactly:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

The implemented batch must later create evidence under:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

The integration request is a handoff for later operator-side config integration. It must describe actual implemented facts, not guesses.

---

## 14. Hard guardrails for all Layer 3 batches

Every Layer 3 batch must clearly preserve these rules:

```text
Do not modify the config tool.
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh unless a future dedicated config-integration batch explicitly says otherwise.
Use config only for inspection/status/explicit existing step execution.
Do not run broad bootstrap, mount, pull, push, account lifecycle, credentials, Docker build, Kubernetes apply, RunPod job, OpenClaw agent, model training, or live Paperclip/Agentfield submission.
Do not read or print secrets.
Do not write output outside approved roots.
Do not claim scientific discovery from skeleton-dummy outputs.
Do not treat final pattern similarity as proof.
```

Approved Layer 3 project roots:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
/workspace/models/nca-art-grn
/workspace/checkpoints/nca-art-grn
/mnt/egress/dev-recordings/skeleton/<batch-slug>/
```

---

## 15. Layer 3 final success condition

After Layer 3 skeleton batches are complete, the platform should be able to run a small local skeleton-dummy research smoke that can:

- load or generate a fake 5-node DSL candidate;
- attach a mechanism hypothesis;
- run a tiny dummy PDE/ODE simulation contract;
- capture dummy local state and dynamics outputs;
- train/test or report a tiny dummy NCA surrogate/local rule summary;
- produce dummy ART2 prototypes;
- produce dummy ARTMAP transitions;
- attempt dummy prototype-to-DSL mapping;
- write a mechanism-discrimination report with falsification framing;
- run tiny dummy search comparison and ranking;
- prepare a local RunPod dry-run manifest and job template;
- write all outputs under `/workspace/runs/nca-art-grn`, `/workspace/artifacts/nca-art-grn`, or approved dry-run roots.

The Layer 3 skeleton is done when it produces stable contracts that later real organs can replace without changing downstream expectations.

---

## 16. Source files merged

This combined Layer 3 file was built from:

```text
Platform_plan_Layer3_ProductOwner_research_execution_loops.md
Platform_plan_Layer3_research_execution_loops_Bundle3_nca_art_dsl_mechanism_discovery_stack.md
Platform_plan_Layer3_research_execution_loops_Bundle4_parameter_search_and_mechanism_testing.md
Platform_plan_Layer3_research_execution_loops_Bundle5_runpod_training_and_inference_loop.md
new_chat.md
00_A0_skeleton_dummy_master_implementation_companion.md
00_A1_skeleton_dummy_codex_batch_plan_v2.md
00_A2_skeleton_batch_mapping_report_batches_01_24.md
day_to_day_skeleton_run.md
final_workflow.md
smoke_module_update_workflow.md
```

No additional update files were required for this merge.
