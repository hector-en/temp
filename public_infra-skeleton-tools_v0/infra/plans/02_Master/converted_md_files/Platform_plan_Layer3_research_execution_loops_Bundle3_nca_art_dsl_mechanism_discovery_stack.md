Yes — this paper should become a core research constraint for Bundle 3.

The updated principle is:

```text
A nice final pattern is not enough.

The system must produce mathematical models that generate falsifiable
experimental predictions, perturbation designs, and mechanism-discrimination
evidence.

```
Hiscock and Megason’s key warning is that molecular, cellular, and mechanical mechanisms can all generate
qualitatively similar periodic final patterns, so matching the final pattern is not sufficient evidence for the
right mechanism. Instead, mathematical models should guide experiments that distinguish mechanisms by
dynamics, perturbation response, parameter constraints, and interaction functions.

# Updated Bundle 3 — NCA-ART-DSL mechanism discovery stack

## Scrum-master view

**Bundle objective:** prepare the executable research loop for discovering, abstracting, and testing 5-node GRN
patterning mechanisms.

This bundle is no longer just:

```text
generate pattern -> score pattern

```
It is:

```text
generate candidate mechanism
simulate dynamics
learn NCA cell-rule behavior
discover ART2/ARTMAP prototypes and transitions

map behavior back to DSL
ask: what experimental perturbation would distinguish this mechanism?

```
The core research loop becomes:

```text
DSL candidate GRN
-> PDE/ODE simulator
-> NCA cell update model
-> ART2 prototype discovery
-> ARTMAP transition learning
-> prototype-to-DSL inverse mapping
-> mechanism-discrimination analysis
-> experiment-design proposal

```
This matches your existing architecture: simulator as the authoritative forward model, NCA as the
learned/discrete cell update layer, ART as the prototype/transition discovery layer, DSL as the symbolic
model layer, and verification through stability, sweeps, Bayesian/ABC, robustness, and re-simulation.

## Updated user story

```text
As the Research Scientist,
I want the NCA-ART-GRN repo to discover and test candidate 5-node GRN mechanisms,
so that I can move beyond visually matching Turing-like patterns and instead produce
symbolic models, NCA rules, ART2/ARTMAP transition evidence, and mathematical
experimental designs that help distinguish the real mechanism.

```
## Updated concretizations / managed steps

### `prepare_dsl_candidate_runtime`

### `prepare_mechanism_hypothesis_runtime`

### `prepare_pde_ode_simulation_runtime`

### `prepare_nca_cell_runtime`

### `prepare_pde_ode_to_nca_dataset`

### `prepare_art2_discovery_runtime`

### `prepare_artmap_transition_runtime`

### `prepare_prototype_store`

### `prepare_transition_graph_store`

### `prepare_pattern_dynamics_metrics`

### `prepare_interaction_function_inference_runtime`

### `prepare_perturbation_design_runtime`

### `prepare_prototype_to_dsl_runtime`

### `prepare_mechanism_discrimination_report`

### `prepare_nca_art_smoke_configs`

### `check_nca_art_pipeline_inputs`

### `run_nca_art_local_smoke`

New or changed steps are:

### `prepare_mechanism_hypothesis_runtime`

### `prepare_pattern_dynamics_metrics`

### `prepare_interaction_function_inference_runtime`

### `prepare_perturbation_design_runtime`

### `prepare_mechanism_discrimination_report`

These are needed because the paper changes your success criteria.

## What each step should do

### `prepare_dsl_candidate_runtime`

Creates the symbolic candidate language.

The DSL must encode:

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
This is primary, not optional. ART cannot replace the DSL because the DSL is what lets you express human-
readable mechanisms, constraints, matrix dynamics, Turing checks, parameter scaling, and experiment
design. The earlier research notes explicitly separate ART discovery from symbolic DSL analysis and
verification.

### `prepare_mechanism_hypothesis_runtime`

New step.

Creates a schema for mechanism hypotheses.

Path examples:

```text
src/nca_art_grn/mechanisms/
hypothesis.py
classes.py
perturbations.py
observables.py
experimental_design.py

configs/mechanisms/
molecular_reaction_diffusion.yaml
cellular_contact_or_motility.yaml
mechanical_or_boundary.yaml
grn_5node_molecular_default.yaml

```
Even if your current system is focused on molecular GRN reaction-diffusion, the schema should force every
candidate to state:

```text
mechanism_class
expected local activation source
expected long-range inhibition source
diffusion or transport assumptions
pattern-spacing prediction
dynamics prediction
perturbation predictions
required measurable parameters

```
Why: Hiscock and Megason argue that the final pattern cannot distinguish mechanisms; your DSL candidates
therefore need hypotheses and predicted tests attached, not only pattern images.

### `prepare_pde_ode_simulation_runtime`

Creates the authoritative forward simulator.

This remains the ground-truth generator:

```text
5-node GRN ODE per cell
diffusion across grid
initial conditions
boundary conditions
perturbations
noise / heterogeneity
time-course output

```
But the simulator must now save dynamics, not just final states.

Required outputs:

```text
full or sampled time series
pattern wavelength over time
growth rate of modes
candidate metadata
perturbation metadata
boundary condition metadata
diffusion metadata

```
Change: do not only save “final pattern score.” Save enough to test mechanism.

### `prepare_nca_cell_runtime`

Creates the NCA cell-update runtime.

NCA is integral. It should be treated as the learned/discrete local rule that helps answer:

```text
Can the local update behavior implied by the PDE/ODE mechanism be learned,

```
The NCA should support:

```text
neighborhood -> next center state
multi-channel 5-node state
rollout comparison with PDE/ODE
perturbation replay
local-rule inspection
prototype-conditioned rule testing

```
Your previous research plan frames NCA as a per-cell update function trained from simulator trajectories or
used to test ART-derived local rules.

### `prepare_pde_ode_to_nca_dataset`

Creates the simulator-to-NCA dataset contract.

Dataset rows should include:

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
Change: include mechanism_hypothesis_id and perturbation_id , because later you need to know which
mechanism produced which local rule and which perturbations tested it.

### `prepare_art2_discovery_runtime`

Creates ART2-centered continuous prototype discovery.

ART2 is primary because your data are continuous state vectors from PDE/ODE and NCA, not just discrete
labels.

ART2 should cluster:

```text
center-state vectors
center + neighborhood vectors
NCA hidden/local update vectors
perturbed-state vectors
time-window vectors

```
Outputs:

```text
prototype vectors
prototype assignment maps
prototype support counts
prototype birth/update events
prototype stability statistics
representative local patches

```
Change: ART2 prototypes must be tied to mechanism and perturbation metadata, not only pattern classes.

### `prepare_artmap_transition_runtime`

Creates ARTMAP/regression transition learning.

ARTMAP is primary because this project is about mechanisms and local transitions, not only clusters.

ARTMAP should learn mappings such as:

```text
neighborhood state at t -> center state at t+1
prototype at t + context -> prototype at t+1
perturbed local state -> recovery trajectory
DSL candidate parameters -> expected prototype transition family

```
Why: ARTMAP gives you a bridge between observed simulator/NCA dynamics and local rule behavior. That
is directly useful for distinguishing mechanisms because mechanism differences often appear in dynamics,
not final pattern appearance.

### `prepare_prototype_store`

Creates persistent prototype artifacts.

Add required fields:

```text
prototype_id
method = ART2 / FuzzyART / TopoART / DualVigilance
mechanism_hypothesis_id
candidate_id
input_schema
prototype_vector
support_count
source_runs
perturbation_contexts

i     i     i

```
### `prepare_transition_graph_store`

Creates persistent transition graph artifacts.

Add required fields:

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
Change: transitions should support mechanism testing: how does a local state respond after perturbation,
boundary change, diffusion change, or initial-condition change?

### `prepare_pattern_dynamics_metrics`

New step.

Creates metrics that look at formation dynamics, not just final pattern.

Path examples:

```text
src/nca_art_grn/analysis/pattern_dynamics.py
src/nca_art_grn/analysis/wavelength.py

src/nca_art_grn/analysis/dispersion.py
src/nca_art_grn/analysis/mode_growth.py
src/nca_art_grn/analysis/boundary_effects.py

```
Metrics:

```text
pattern wavelength over time
dominant Fourier mode
mode growth rate
time to pattern emergence
stripe/spot/labyrinth classification
boundary sensitivity
initial-condition sensitivity
pattern recovery after perturbation

```
Why: Hiscock and Megason stress that final pattern appearance is not enough; pattern formation dynamics
and perturbation responses are more informative.

### `prepare_interaction_function_inference_runtime`

New step.

Implements the K(x) -style interaction inference idea.

Path examples:

```text
src/nca_art_grn/analysis/interaction_function.py
src/nca_art_grn/analysis/k_estimation.py
src/nca_art_grn/analysis/local_response.py
configs/analysis/interaction_function_smoke.yaml

```
Purpose:

```text
estimate how local states influence nearby states over distance
compare smooth molecular-like interactions vs sharp cellular-like interactions
compare long-range/boundary/mechanical-like effects

```
Even if your first implementation is molecular GRN/PDE focused, this is valuable because it prevents the
system from claiming “Turing mechanism” based only on final pattern similarity.

Hiscock and Megason describe estimating interaction functions from pattern dynamics as a way to
distinguish molecular, cellular, and mechanical interaction classes.

### `prepare_perturbation_design_runtime`

New step.

Creates perturbation configs that are designed to distinguish mechanisms.

Path examples:

```text
src/nca_art_grn/analysis/perturbation_design.py
src/nca_art_grn/analysis/scaling_tests.py
src/nca_art_grn/analysis/experimental_predictions.py

configs/perturbations/
diffusion_scaling.yaml
degradation_half_life.yaml
boundary_condition_shift.yaml
initial_condition_bias.yaml
local_ablation.yaml
noise_heterogeneity.yaml

```
The system should generate predictions like:

```text
If molecular diffusion controls spacing:
increasing diffusion should scale pattern wavelength predictably.

If boundary conditions drive orientation:
changing boundary geometry should alter orientation or spot/stripe selection.

If initial conditions dominate:
changing the seed stripe should bias orientation.

If local rule is robust:
NCA and PDE/ODE should recover similar pattern after perturbation.

```
Why: Hiscock and Megason emphasize perturbations and scaling laws as stronger tests than visual
similarity.

### `prepare_prototype_to_dsl_runtime`

Updated.

This still maps ART/ARTMAP output back to DSL, but now the DSL candidate must include mechanism-test
metadata.

Output DSL artifact should include:

```text
candidate topology
parameters
diffusion values
motif core
prototype sources
transition sources
Turing/stability report placeholder

perturbation predictions

```
Your existing architecture already maps prototypes and transition data into symbolic GRN models using
optimization, sparse regression, sign constraints, and motif reduction.

Change: prototype-to-DSL mapping must not end at “this produces a pattern.” It must produce “this
mechanism predicts these perturbation outcomes.”

### `prepare_mechanism_discrimination_report`

New step.

Creates a report template for each candidate.

Path:

```text
/workspace/artifacts/nca-art-grn/mechanism_reports/

```
Report fields:

```text
candidate_id
mechanism_hypothesis
final_pattern_summary
formation_dynamics_summary
NCA agreement summary
ART2 prototype summary
ARTMAP transition summary
DSL mapping summary
perturbation predictions
parameter constraints

```
This is the most important update.
The report must explicitly answer:

```text
What would I test experimentally to know this is the right mechanism?

```
That is the paper’s core lesson.

### `prepare_nca_art_smoke_configs`

Update the smoke configs to include one mechanism-discrimination mini-test.

Add:

```text
configs/experiments/smoke_mechanism_discrimination.yaml
configs/perturbations/smoke_diffusion_scaling.yaml
configs/analysis/smoke_pattern_dynamics.yaml
configs/analysis/smoke_interaction_function.yaml

```
Smoke should remain tiny:

```text
1 candidate
8x8 or 16x16 grid
few time steps
one diffusion perturbation
one ART2 pass
one ARTMAP transition pass
one NCA mini rollout
one mechanism report

```
### `check_nca_art_pipeline_inputs`

Updated readiness check should report:

```text
DSL runtime ready
mechanism hypothesis configs ready
PDE/ODE simulator configs ready
NCA configs ready
ART2 configs ready
ARTMAP configs ready
prototype store ready
transition graph store ready
pattern dynamics metrics ready
perturbation configs ready
mechanism report path ready

```
### `run_nca_art_local_smoke`

Updated explicit smoke execution.

It should run:

```text
load one DSL candidate
attach mechanism hypothesis
run tiny PDE/ODE simulation
capture trajectory
train/test tiny NCA rollout
run ART2 prototype discovery
run ARTMAP transition mapping
calculate basic dynamics metrics
run one perturbation comparison

attempt prototype-to-DSL mapping
write mechanism-discrimination report

```
**Expected output:**

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
## Updated acceptance criteria

The following should be valid:

```text
sudo config --target researchscientist bootstrap step prepare_dsl_candidate_runtime
sudo config --target researchscientist bootstrap step prepare_mechanism_hypothesis_runtime
sudo config --target researchscientist bootstrap step prepare_pde_ode_simulation_runtime
sudo config --target researchscientist bootstrap step prepare_nca_cell_runtime
sudo config --target researchscientist bootstrap step prepare_pde_ode_to_nca_dataset
sudo config --target researchscientist bootstrap step prepare_art2_discovery_runtime
sudo config --target researchscientist bootstrap step prepare_artmap_transition_runtime
sudo config --target researchscientist bootstrap step prepare_pattern_dynamics_metrics
sudo config --target researchscientist bootstrap step prepare_interaction_function_inference_runtime
sudo config --target researchscientist bootstrap step prepare_perturbation_design_runtime
sudo config --target researchscientist bootstrap step prepare_prototype_to_dsl_runtime

sudo config --target researchscientist bootstrap step prepare_mechanism_discrimination_report

```
Explicit execution:

```text
sudo config --target researchscientist bootstrap step run_nca_art_local_smoke

```
**Prepare/check steps must:**

```text
not run large simulations
not train full NCA models
not launch Runpod
not run parameter campaigns
not overwrite research code
not overwrite existing artifacts
not claim final biological mechanism from pattern appearance alone
not build paper output

```
**Smoke step must:**

```text
use tiny local config
record mechanism hypothesis
record dynamics metrics
record perturbation metadata
record ART2 and ARTMAP settings
write inspectable mechanism report
clearly label outputs as smoke, not discovery result

```
## Updated tests

### Registry tests

```text
config bootstrap steps | grep prepare_mechanism_hypothesis_runtime
config bootstrap steps | grep prepare_pattern_dynamics_metrics
config bootstrap steps | grep prepare_interaction_function_inference_runtime
config bootstrap steps | grep prepare_perturbation_design_runtime
config bootstrap steps | grep prepare_mechanism_discrimination_report

```
### Structure tests

```text
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/mechanisms
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/analysis
test -d /workspace/repos/nca-art-grn/configs/mechanisms
test -d /workspace/repos/nca-art-grn/configs/perturbations
test -d /workspace/artifacts/nca-art-grn/mechanism_reports

```
### Config tests

```text
test -f /workspace/repos/nca-art-grn/configs/mechanisms/grn_5node_molecular_default.yaml
test -f /workspace/repos/nca-art-grn/configs/perturbations/diffusion_scaling.yaml
test -f /workspace/repos/nca-art-grn/configs/analysis/smoke_pattern_dynamics.yaml
test -f /workspace/repos/nca-art-grn/configs/analysis/smoke_interaction_function.yaml

```
### Smoke output tests

```text
sudo config --target researchscientist bootstrap step run_nca_art_local_smoke

find /workspace/runs/nca-art-grn/smoke -name mechanism_report.md | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name pattern_dynamics.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name perturbation_summary.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name art2_prototypes.json | tail -n 1
find /workspace/runs/nca-art-grn/smoke -name artmap_transitions.json | tail -n 1

```
### Scientific guardrail test

**The smoke report must contain these headings:**

```text
Final pattern is not sufficient evidence
Mechanism hypothesis
Dynamics evidence
Perturbation prediction
Experimental design suggestion
Falsification criterion

```
### Updated Bundle 3 summary

Bundle 3 now has the correct scientific core:

```text
The goal is not to find pretty Turing-like images.

The goal is to find candidate GRN mechanisms that:
produce patterning dynamics,
can be represented in DSL,
can be approximated/tested by NCA,
can be summarized by ART2 and ARTMAP,
can survive perturbation/robustness checks,
and can suggest experiments that distinguish the mechanism.

```
This makes Hiscock and Megason part of your research logic:

```text
Pattern match = weak evidence.
Dynamics + perturbation response + parameter constraints + experimental design = strong evidence.

```
So Bundle 3 becomes the foundation for a serious MRes/research platform, not just a pattern generator.

```text
you left out the what does this do for the research, and also its not
clear if this is a config, agentfield etc step and if it is part of that
managed role-python-etc platform thing if not what and how does this
steplink into the whoe system?

```
Nachgedacht für 5s

You are right. I mixed two levels together.

For Bundle 3, most steps are not Agentfield steps yet. They are mostly config-managed bootstrap
steps that prepare the research repo and its runtime contracts. The actual scientific code lives inside
the nca-art-grn repo. Later, Agentfield will call these repo entrypoints, but Agentfield does not own them
yet.

## Corrected Bundle 3 framing

### Where this sits in the whole system

```text
config
owns setup:
users, roles, envs, packages, folders, configs, smoke commands

nca-art-grn repo
owns research code:
DSL, PDE/ODE simulator, NCA, ART2, ARTMAP, mapping, analysis

/workspace/data, /workspace/runs, /workspace/artifacts
own large data, run outputs, prototypes, reports, figures

Agentfield later
owns orchestration:
"run this experiment", track status, compare runs, call repo CLI

Paperclip later
owns human dashboard:
launch/review runs, inspect status/artifacts/results

```
So Bundle 3 steps are mostly:

```text
config-managed preparation steps
that create/verify repo files, configs, folders, and tiny smoke entrypoints

```
They are not full experiments yet, and not Agentfield CRDs yet.

### Bundle 3 — NCA-ART-DSL mechanism discovery stack

## Scrum-master view

**Bundle objective:** prepare the nca-art-grn repo so that the Research Scientist can run the first real local
mechanism-discovery loop.

The research principle from Hiscock and Megason is now a hard requirement:

```text
Final pattern match is weak evidence.
Mechanism-discriminating predictions are strong evidence.

```
They argue that molecular, cellular, and mechanical mechanisms can produce qualitatively similar final
periodic patterns; therefore, mathematical models should guide experiments using dynamics, perturbations,
parameter constraints, and interaction functions, not just final pattern similarity.

**User story**

```text
As the Research Scientist,
I want config to prepare the NCA-ART-GRN research engine,
so that I can generate DSL-defined GRN mechanisms, simulate them, train/test NCA
local rules, discover ART2/ARTMAP prototype transitions, and produce mechanism
reports that propose experiments to distinguish the right patterning mechanism.

```
### Step type legend

Use this to keep the platform clean:

```text
CONFIG STEP
A managed bootstrap/check/smoke step invoked by config.

REPO CODE
Python modules, configs, tests, and scripts inside nca-art-grn.

RESEARCH OUTPUT
Data, runs, artifacts, prototypes, transition graphs, reports.

AGENTFIELD LATER
Not implemented here; later calls the repo CLI/modules.

```
### Concretizations with role, ownership, and research meaning

### `prepare_dsl_candidate_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares it; researchscientist uses it.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/dsl/
configs/dsl/

```
What this does for the research:
This makes the DSL the formal language for your candidate mechanisms. It stores 5-node GRN topology,
activation/repression signs, parameters, diffusion assumptions, motif provenance, perturbable parameters,
and later inverse-mapped candidates from ART/ARTMAP.

How it links into the platform:

```text
config creates DSL skeleton/configs
research code uses DSL to generate candidates
runs write candidate DSL snapshots to /workspace/runs/nca-art-grn
Agentfield later submits "candidate DSL + experiment config" as a run input
Paperclip later displays candidate DSL summary and mechanism report

```
### `prepare_mechanism_hypothesis_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares mechanism schema/configs.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/mechanisms/
configs/mechanisms/

```
What this does for the research:
This step forces every candidate to declare what mechanism it claims to represent. It is where
Hiscock/Megason becomes operational: a candidate must state its local activation, long-range inhibition,
expected dynamics, perturbation predictions, and falsification criteria.

How it links into the platform:

```text
DSL candidate gets mechanism_hypothesis_id
simulator and NCA outputs carry that ID
ART2/ARTMAP prototypes keep that ID
mechanism report summarizes whether evidence supports that hypothesis
Agentfield later groups runs by mechanism_hypothesis_id

```
### `prepare_pde_ode_simulation_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares skeleton/configs; repo owns simulator implementation.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/simulator/
configs/experiments/pde_ode_baseline.yaml

```
What this does for the research:
This creates the authoritative forward model. It should simulate 5-node GRN reaction-diffusion dynamics
and save time-series evidence, not just a final image.

How it links into the platform:

```text
DSL candidate -> simulator config
simulator -> /workspace/runs/nca-art-grn/<run_id>/trajectories
simulator -> NCA dataset writer
simulator -> ART2/ARTMAP input
simulator -> mechanism report dynamics evidence

```
### `prepare_nca_cell_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares NCA module/config placeholders; repo owns implementation.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/nca/
configs/nca/

```
What this does for the research:
NCA is integral. It is the learned/discrete local cell-rule layer. It tests whether local neighborhood dynamics
from the PDE/ODE mechanism can be learned, replayed, perturbed, compressed, and compared against
ART/ARTMAP transitions.

How it links into the platform:

```text
PDE/ODE trajectories -> NCA training/evaluation samples
NCA rollout -> comparison against simulator
NCA local states -> ART2 prototype discovery
NCA rule behavior -> mechanism report
Agentfield later can choose simulator-only, NCA-only, or simulator+NCA experiment modes

```
### `prepare_pde_ode_to_nca_dataset`

**Type:** CONFIG STEP
**Owner:** config prepares dataset contracts.
Creates/validates REPO CODE + RESEARCH OUTPUT contract:

```text
src/nca_art_grn/capture/
configs/data/

```
What this does for the research:
This makes the simulator output trainable for NCA and analyzable by ART/ARTMAP. It defines rows like
neighborhood at t , center state at t+1 , mechanism hypothesis ID, perturbation ID, and pattern metrics.

How it links into the platform:

```text
simulator output -> /workspace/data/nca-art-grn/datasets/
NCA training reads that dataset
ART2/ARTMAP can read same state-transition samples
Agentfield later registers dataset IDs as experiment inputs

```
### `prepare_art2_discovery_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares ART2 module/config placeholders.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/art/art2.py
src/nca_art_grn/art/prototypes.py

configs/art/art2 baseline yaml
```
What this does for the research:
ART2 is the continuous-state prototype discovery layer. It finds recurring local concentration/state patterns
from simulator and NCA trajectories. This gives you a vocabulary of local states rather than relying only on
whole-image pattern scores.

How it links into the platform:

```text
simulator/NCA state vectors -> ART2
ART2 -> /workspace/artifacts/nca-art-grn/prototypes/art2
prototype IDs -> ARTMAP transition learning
prototype summaries -> mechanism report
Paperclip later can show prototypes as reviewable artifacts

```
### `prepare_artmap_transition_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares ARTMAP module/config placeholders.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/art/artmap.py
src/nca_art_grn/art/transition_model.py
configs/artmap/

```
What this does for the research:
ARTMAP is the transition-learning layer. It connects local state/context at t to prototype or state at t+1 .
This is central because mechanism differences often appear in dynamics, not final pattern shape.

How it links into the platform:

```text
ART2 prototypes + transition samples -> ARTMAP
ARTMAP -> transition graph artifacts
transition graph -> prototype-to-DSL mapping
transition evidence -> mechanism report
Agentfield later compares transition models across candidates

```
### `prepare_pattern_dynamics_metrics`

**Type:** CONFIG STEP
**Owner:** config prepares analysis modules/configs.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/analysis/pattern_dynamics.py
src/nca_art_grn/analysis/wavelength.py
src/nca_art_grn/analysis/dispersion.py
src/nca_art_grn/analysis/mode_growth.py

```
What this does for the research:
This prevents “pretty final pattern” from being the criterion. It measures wavelength over time, dominant
Fourier modes, mode growth, time-to-pattern, boundary sensitivity, recovery after perturbation, and pattern
dynamics.

How it links into the platform:

```text
simulator/NCA runs -> dynamics metrics
dynamics metrics -> mechanism discrimination report
Bundle 4 later uses metrics for search/optimization objectives
Agentfield later tracks these metrics as run status/results

```
### `prepare_interaction_function_inference_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares analysis runtime.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/analysis/interaction_function.py
src/nca_art_grn/analysis/k_estimation.py
configs/analysis/interaction_function_smoke.yaml

```
What this does for the research:
This implements the Hiscock/Megason idea of estimating interaction functions from dynamics. It helps ask
whether the observed behavior looks like smooth molecular diffusion, sharp cellular contact, or longer-range
mechanical/boundary effects.

How it links into the platform:

```text
trajectory dynamics -> K(x)-style estimate
K(x) estimate -> mechanism evidence
mechanism evidence -> report
later Agentfield can compare K(x) estimates across hypotheses

```
### `prepare_perturbation_design_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares perturbation configs and analysis modules.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/analysis/perturbation_design.py
src/nca_art_grn/analysis/scaling_tests.py

configs/perturbations/

```
What this does for the research:
This turns mathematical models into experimental design suggestions. It defines perturbations such as
diffusion scaling, degradation/half-life changes, boundary shifts, initial-condition bias, local ablation, and
noise/heterogeneity.

How it links into the platform:

```text
mechanism hypothesis -> perturbation plan
perturbation plan -> simulator/NCA rerun config
perturbation results -> mechanism report
Bundle 4 later uses perturbations in robustness/search
Agentfield later can schedule perturbation campaigns

```
### `prepare_prototype_store`

**Type:** CONFIG STEP
**Owner:** config creates artifact directories/schema.
Creates RESEARCH OUTPUT paths:

```text
/workspace/artifacts/nca-art-grn/prototypes/

```
What this does for the research:
Keeps ART2/ART prototype artifacts traceable to candidate ID, mechanism hypothesis, simulator/NCA run,
timepoint, perturbation context, and support count.

How it links into the platform:

```text
ART2 writes prototypes here
prototype-to-DSL reads from here
mechanism report cites these artifacts
Paperclip later displays these outputs

```
### `prepare_transition_graph_store`

**Type:** CONFIG STEP
**Owner:** config creates artifact directories/schema.
Creates RESEARCH OUTPUT paths:

```text
/workspace/artifacts/nca-art-grn/transition_graphs/

```
What this does for the research:
Stores the local behavior graph: which states become which states, under which candidate, perturbation, and
mechanism hypothesis.

How it links into the platform:

```text
ARTMAP writes transition graphs
prototype-to-DSL uses transition graphs
mechanism report summarizes transition evidence
Agentfield later compares transition graphs across runs

```
### `prepare_prototype_to_dsl_runtime`

**Type:** CONFIG STEP
**Owner:** config prepares mapping modules/configs.

**Creates/validates REPO CODE:**

```text
src/nca_art_grn/mapping/
configs/mapping/

```
What this does for the research:
This closes the loop. It attempts to map ART2 prototypes and ARTMAP transitions back into symbolic DSL
candidates with topology, signs, parameters, constraints, and perturbation predictions.

How it links into the platform:

```text
ART2/ARTMAP artifacts -> prototype-to-DSL mapper
mapper -> candidate DSL artifact
candidate DSL -> resimulation
candidate DSL -> paper/report material
Agentfield later can branch new experiments from mapped candidates

```
### `prepare_mechanism_discrimination_report`

**Type:** CONFIG STEP
**Owner:** config prepares report templates/paths.
**Creates RESEARCH OUTPUT path:**

```text
/workspace/artifacts/nca-art-grn/mechanism_reports/

```
What this does for the research:
This is the scientific checkpoint. Every candidate report must answer:

```text
What mechanism is being claimed?
Why is final pattern similarity insufficient?
What dynamics support it?
What perturbation would falsify it?
What experiment would distinguish it from alternatives?

```
How it links into the platform:

```text
run outputs -> mechanism report
Bundle 10 later cites reports in paper
Agentfield later stores report path in experiment status
Paperclip later shows report for human review

```
### `prepare_nca_art_smoke_configs`

**Type:** CONFIG STEP
**Owner:** config prepares tiny configs only.
Creates/validates REPO CONFIGS:

```text
configs/experiments/smoke_nca_art_pipeline.yaml
configs/experiments/smoke_mechanism_discrimination.yaml
configs/perturbations/smoke_diffusion_scaling.yaml

```
What this does for the research:
Creates a safe tiny end-to-end test. It proves the pipeline is wired without pretending the result is a
discovery.

How it links into the platform:

```text
config can run one tiny smoke test
later Agentfield can reuse same config shape for real experiments

```
### `check_nca_art_pipeline_inputs`

**Type:** CONFIG CHECK STEP
**Owner:** config .
**Runs:** no science, no training.

What this does for the research:
Confirms that all research pipeline pieces exist before wasting time on a broken run.

How it links into the platform:

```text
operator can check readiness
Research Scientist can see missing pieces
Agentfield later can call equivalent readiness check before scheduling jobs

```
### `run_nca_art_local_smoke`

**Type:** CONFIG SMOKE EXECUTION STEP
**Owner:** config invokes tiny repo command as researchscientist .
**Runs:** tiny local smoke only.

What this does for the research:
Proves the complete loop exists:

```text
DSL candidate
-> simulator
-> NCA mini rollout
-> ART2 prototype discovery
-> ARTMAP transition mapping
-> dynamics metrics
-> perturbation mini-test
-> mechanism report

```
How it links into the platform:

```text
today:
config invokes repo smoke command

later:
Agentfield invokes the same repo command with real experiment configs

later still:
Paperclip starts/reviews the Agentfield run

```
**Output:**

```text
/workspace/runs/nca-art-grn/smoke/<timestamp>/

```
## Whole-system linkage

The pipeline should be designed like this:

```text
config step
prepares or checks files/configs/folders

repo CLI
performs research actions

workspace paths
store inputs, runs, artifacts

Agentfield later
orchestrates repo CLI with experiment status

Paperclip later
exposes Agentfield runs to user

```
Concrete later call shape:

```text
config:
sudo config --target researchscientist bootstrap step run_nca_art_local_smoke

repo:
python -m nca_art_grn.cli.run --config configs/experiments/smoke_nca_art_pipeline.yaml

Agentfield later:
GRNExperiment.spec.method = nca_art_pipeline
GRNExperiment.spec.config = configs/experiments/...
controller calls repo CLI
status points to /workspace/runs/nca-art-grn/<run_id>

Paperclip later:
shows run status, prototype artifacts, transition graphs, mechanism report

```
## Updated summary

Bundle 3 is a config-managed research-engine preparation bundle.

It is not Agentfield yet.

```text
config prepares the engine
nca-art-grn contains the engine
/workspace stores the evidence
Agentfield later orchestrates the engine
Paperclip later makes the engine visible

```
And scientifically:

```text
DSL defines candidate mechanisms.
PDE/ODE generates dynamics.
NCA learns/tests local update rules.
ART2 discovers continuous prototypes.
ARTMAP learns transitions.
Perturbation/dynamics analysis tests mechanism claims.
Prototype-to-DSL closes the explanation loop.
Mechanism reports prevent "pretty pattern" from becoming false evidence.

```
