# Bundle 4 - Parameter search comparison and mechanism-testing tools
## Scrum-master view
Bundle objective: prepare the search and comparison layer for the NCA-ART-GRN research engine.

Bundle 3 made the core mechanism loop possible:

```text
DSL candidate
-> PDE/ODE simulation
-> NCA local rule
-> ART2 prototypes
-> ARTMAP transitions
-> prototype-to-DSL mapping
-> mechanism report

```
Bundle 4 makes that loop searchable, comparable, and scientifically testable.

The goal is not just:

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
This follows the Hiscock/Megason constraint: final periodic pattern similarity is not enough, because different molecular, cellular, and mechanical
mechanisms can produce similar final patterns. Search must therefore optimize for mechanism evidence, dynamics, perturbation response, and
falsifiable predictions, not only visual pattern score.

## Where this bundle sits in the platform
Bundle 4 is still mostly config-managed research-engine preparation.

```text
config
prepares search templates, configs, result schemas, folders, smoke commands

nca-art-grn repo
owns search code and comparison logic

/workspace/runs/nca-art-grn
stores search runs

/workspace/artifacts/nca-art-grn
stores ranked candidates, comparison reports, figures, summaries

Agentfield later
orchestrates search campaigns as experiments

Paperclip later
shows campaign status, candidate rankings, reports, and review decisions

```
So these are not Agentfield steps yet.
They are config bootstrap/check/smoke steps that prepare the repo for future Agentfield orchestration.

## User story

```text
As the Research Scientist,
I want prepared parameter-search and comparison tools,
so that I can compare random/grid, Latin hypercube, evolutionary, Bayesian,
and robustness-driven searches for 5-node GRN mechanisms, using not only final

pattern scores but also dynamics, NCA agreement, ART2/ARTMAP evidence,
DSL recoverability, perturbation response, and experimental-design value.

```
## Concretizations / managed steps

- `install_parameter_search_comparison_stack`

- `prepare_search_parameter_space`
- `prepare_random_grid_baselines`
- `prepare_lhs_search_template`
- `prepare_evolutionary_search_template`
- `prepare_bayesian_search_template`
- `prepare_active_learning_search_template`

- `prepare_mechanism_scoring_runtime`
- `prepare_search_result_comparison_schema`
- `prepare_candidate_ranking_runtime`
- `prepare_robustness_sweep_template`
- `prepare_perturbation_search_template`
- `prepare_search_report_runtime`

- `prepare_search_smoke_configs`
- `check_parameter_search_inputs`
- `run_parameter_search_local_smoke`

## Step type legend

```text
CONFIG STEP
Managed bootstrap/check/smoke step invoked by config.

REPO CODE
Python modules, configs, tests, scripts inside nca-art-grn.

RESEARCH OUTPUT
Data, run outputs, ranked candidates, metrics, reports.

AGENTFIELD LATER
Future orchestration layer; not implemented in this bundle.

```
## What each step should do
### `install_parameter_search_comparison_stack`
**Type:** CONFIG STEP
**Owner:** config installs packages into the researchscientist Python environment.
**Target role:** researchscientist .

Expected package areas:

```text
optuna
scikit-optimize
deap
SALib
scipy
scikit-learn
pandas
numpy
networkx
pyyaml
pydantic
rich
tqdm

```
**Optional later:**

```text
nevergrad
botorch
ray
dask

```
**What this does for the research:**
Gives the research role the tools to compare different ways of searching 5-node GRN parameter/topology space. The point is not only speed. The
point is to know which search method finds mechanisms that are plausible, robust, interpretable, and experimentally testable.

**How it links into the platform:**

```text
config installs package stack
repo search modules use those packages
search outputs go to /workspace/runs/nca-art-grn
Agentfield later can run the same search methods as campaign modes

```
### `prepare_search_parameter_space`
**Type:** CONFIG STEP
**Owner:** config prepares schema/config placeholders; repo owns implementation.
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/search/parameter_space.py
src/nca_art_grn/search/constraints.py
src/nca_art_grn/search/sampling_units.py
configs/search/parameter_space_5node.yaml
configs/search/search_constraints.yaml

```
**The parameter space must encode:**

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
**What this does for the research:**
This defines what is searchable. It keeps the search from becoming random numeric noise by tying parameters to DSL topology, motif priors,
biological constraints, simulator settings, NCA settings, ART2 settings, and mechanism-testing needs.

**How it links into the platform:**

```text
DSL candidate runtime defines candidate representation
search_parameter_space defines allowed variations
search methods sample from this space
runs write sampled candidates and parameter metadata
Agentfield later passes this search config into campaign experiments

```
### `prepare_random_grid_baselines`

**Type:** CONFIG STEP
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/search/random_grid.py
configs/search/random_grid_baseline.yaml

```
**The baseline must support:**

```text
fixed grid over small parameter subsets
random candidate sampling
random seed control
candidate budget
simulation budget
repeat count

```
**What this does for the research:**
Gives you the dumb but honest baseline. Every smarter method must beat this in finding candidates that produce meaningful dynamics, not just
final images.

**How it links into the platform:**

```text
random/grid produces baseline candidate set
Bundle 3 pipeline evaluates candidates
comparison report uses this as lower-bound reference
Agentfield later can run baseline campaigns for reproducibility

```
### `prepare_lhs_search_template`
**Type:** CONFIG STEP
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/search/lhs.py
configs/search/latin_hypercube.yaml

```
**The Latin hypercube template must encode:**

```text
parameter ranges
number of samples
stratification seed
continuous parameter coverage
optional topology fixed / topology varied mode

```
**What this does for the research:**
LHS gives better coverage of continuous GRN parameter space than naive random sampling. It is useful early when you do not yet know which
parameter dimensions matter.

**How it links into the platform:**

```text
LHS samples candidates
simulator/NCA/ART2/ARTMAP evaluate them
metrics compare coverage versus discovery quality
Bundle 5 later can scale LHS batches on Runpod

```
### `prepare_evolutionary_search_template`
**Type:** CONFIG STEP
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/search/evolutionary.py
src/nca_art_grn/search/mutation.py
src/nca_art_grn/search/crossover.py

src/nca_art_grn/search/selection.py
```
**The evolutionary search must encode:**

```text
candidate genome representation
mutation of edge signs
mutation of edge strengths
mutation of diffusion parameters
mutation of reaction parameters
motif-preserving mutation
motif-breaking mutation, optional
selection score
population size
generation count
elitism policy
diversity preservation

```
**What this does for the research:**
This is where candidate GRNs can evolve toward better mechanism evidence. It should not only select “pretty patterns”; it should select candidates
with useful dynamics, perturbation predictions, ART2/ARTMAP structure, and DSL recoverability.

**How it links into the platform:**

```text
candidate DSL -> genome
evolutionary search mutates genome
Bundle 3 evaluates offspring
ranked candidates go to artifacts
Agentfield later can run generations as managed campaign steps

```
### `prepare_bayesian_search_template`
**Type:** CONFIG STEP
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/search/bayesian.py
src/nca_art_grn/search/surrogate_objectives.py
configs/search/bayesian.yaml

```
**Bayesian search must encode:**

```text
objective metric set
continuous parameter bounds
categorical encoding for topology/signs
initial random/LHS points
acquisition function
candidate batch size
budget limit
failed-run handling

```
**What this does for the research:**
Bayesian optimization helps when simulations/NCA/ART evaluations are expensive. It learns where promising candidates may exist based on
previous runs.

**How it links into the platform:**

```text
previous run metrics -> Bayesian surrogate
surrogate proposes next candidates
Bundle 3 evaluates candidates
Bundle 5 later scales expensive batches
Agentfield later can checkpoint campaign state

```
### `prepare_active_learning_search_template`
**Type:** CONFIG STEP
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/search/active_sampling.py
src/nca_art_grn/search/uncertainty.py
configs/search/active_learning.yaml

```
**Active learning must encode:**

```text
uncertainty over mechanism class
uncertainty over perturbation response
uncertainty over prototype assignment
uncertainty over DSL mapping
candidate diversity objective
next-experiment suggestion

```
**What this does for the research:**
This makes search more scientific: it asks which candidate or perturbation would teach the most about the mechanism, not only which candidate
currently scores highest.

**How it links into the platform:**

```text
mechanism reports -> uncertainty signals
active sampler -> next candidate or perturbation
Agentfield later can schedule "most informative next run"
Paperclip later can present suggested next experiments for approval

```
### `prepare_mechanism_scoring_runtime`
**Type:** CONFIG STEP
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/search/scoring.py
src/nca_art_grn/search/objectives.py

src/nca_art_grn/search/mechanism_score.py
configs/search/scoring.yaml
```
**The scoring runtime must include multiple score families:**

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
**What this does for the research:**
This is one of the most important Bundle 4 steps. It encodes the updated scientific principle: final pattern is one weak signal, not the final criterion.
The search score must prefer candidates that help test mechanisms.

**How it links into the platform:**

```text
Bundle 3 outputs metrics/artifacts
mechanism_scoring_runtime combines them
search methods optimize this score
comparison reports explain score components
Agentfield later exposes score fields in experiment status

```
### `prepare_search_result_comparison_schema`
**Type:** CONFIG STEP
**Creates/validates REPO CODE + OUTPUT CONTRACT:**

```text
src/nca_art_grn/search/result_schema.py
configs/search/result_schema.yaml

```
**The result schema must record:**

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
**What this does for the research:**
Makes different search strategies comparable. Without a shared schema, you cannot fairly compare random search, LHS, evolutionary search,
Bayesian optimization, and active learning.

**How it links into the platform:**

```text
all search methods write same result schema
comparison report reads same schema
Agentfield later uses schema as run/campaign status payload
Paperclip later displays method comparison and candidate ranking

```
### `prepare_candidate_ranking_runtime`
**Type:** CONFIG STEP
**Creates/validates REPO CODE:**

```text
src/nca_art_grn/search/ranking.py
src/nca_art_grn/search/pareto.py
configs/search/ranking.yaml

```
**Ranking must support:**

```text
single composite score
multi-objective ranking
Pareto front
minimum viability filters
diversity-aware ranking
mechanism-class grouping
robustness-first ranking
experimental-design-first ranking

```
**What this does for the research:**
Prevents one metric from dominating. For example, a candidate with slightly weaker final pattern but excellent perturbation-discrimination value
may be more scientifically useful than a prettier candidate.

**How it links into the platform:**

```text
search result schema -> ranking
ranking -> candidate shortlist
shortlist -> mechanism reports
shortlist -> Bundle 10 paper figures/tables later
Agentfield later can decide which candidates advance to next campaign

```
### `prepare_robustness_sweep_template`
**Type:** CONFIG STEP
**Creates/validates REPO CODE/CONFIGS:**

```text
src/nca_art_grn/search/robustness.py
configs/search/robustness_sweep.yaml

```
**Robustness sweep dimensions:**

```text
initial condition noise
parameter jitter
diffusion parameter changes
reaction parameter changes
boundary condition changes
grid size changes
time-step changes
perturbation recovery
NCA rollout length
ART2 vigilance variation
ARTMAP transition threshold variation

```
**What this does for the research:**
Tests whether candidates are stable mechanisms or fragile accidents. Robustness matters because the future paper should argue about
mechanisms, not one lucky simulation.

**How it links into the platform:**

```text
candidate shortlist -> robustness sweep
robustness outputs -> mechanism report
Bundle 5 later scales robustness sweeps on Runpod
Agentfield later orchestrates robustness campaigns

```
### `prepare_perturbation_search_template`
**Type:** CONFIG STEP
**Creates/validates REPO CODE/CONFIGS:**

```text
src/nca_art_grn/search/perturbation_search.py
configs/search/perturbation_search.yaml

```
**Perturbation search must support:**

```text
diffusion scaling perturbations
degradation / half-life perturbations
reaction sensitivity perturbations
boundary condition perturbations
initial-condition bias
local ablation / local state reset
noise or heterogeneity injection
NCA-rule perturbation
ART2-vigilance perturbation

```
**What this does for the research:**
This directly operationalizes Hiscock/Megason: the model should suggest perturbations that distinguish mechanisms. The search should therefore
find not just candidates, but candidates with informative perturbation predictions.

**How it links into the platform:**

```text
mechanism hypothesis -> perturbation search
perturbation search -> test configs
Bundle 3 evaluates perturbations
mechanism report records falsification tests
Agentfield later can schedule perturbation campaigns

```
### `prepare_search_report_runtime`
**Type:** CONFIG STEP
**Creates/validates REPO CODE + OUTPUT PATHS:**

```text
src/nca_art_grn/search/report.py
src/nca_art_grn/viz/search_reports.py
/workspace/artifacts/nca-art-grn/search_reports/

```
**Reports should include:**

```text
search method comparison
candidate count
failure count
best candidates
Pareto front
score component breakdown
robustness summary
perturbation summary
NCA agreement summary
ART2/ARTMAP evidence summary
prototype-to-DSL success/failure
recommended next experiments

```
**What this does for the research:**
Turns search results into scientific decision material. It helps decide which candidate is worth deeper simulation, Runpod scaling, experimental-
design writing, or paper inclusion.

**How it links into the platform:**

```text
search outputs -> search report
search report -> Bundle 9 alloy notes
search report -> Bundle 10 paper figures/tables

Agentfield later attaches report path to campaign status

```
### `prepare_search_smoke_configs`
**Type:** CONFIG STEP
**Creates REPO CONFIGS:**

```text
configs/search/smoke_random_grid.yaml
configs/search/smoke_lhs.yaml
configs/search/smoke_evolutionary.yaml
configs/search/smoke_bayesian.yaml
configs/search/smoke_comparison.yaml

```
**Smoke settings must be tiny:**

```text
1-3 candidates
8x8 or 16x16 grid
few time steps
no Runpod
no full NCA training
tiny ART2/ARTMAP pass
single perturbation check
write smoke comparison report

```
**What this does for the research:**
Confirms the search wiring works before spending time or money.

**How it links into the platform:**

```text
config invokes tiny search smoke
repo writes comparison output
Agentfield later reuses same config style for real campaigns

```
### `check_parameter_search_inputs`
**Type:** CONFIG CHECK STEP
**Runs:** no simulations, no training, no search.

**Should report:**

```text
repo exists
research Python env ready
search packages importable
DSL runtime present
mechanism hypothesis configs present
simulator configs present
NCA configs present
ART2/ARTMAP configs present
parameter space config present
scoring config present
result schema present
search output folders present

```
**What this does for the research:**
Prevents running broken campaigns and makes missing parts visible.

**How it links into the platform:**

```text
operator checks readiness
researchscientist fixes missing inputs
Agentfield later can run equivalent preflight before campaign scheduling

```
### `run_parameter_search_local_smoke`

**Type:** CONFIG SMOKE EXECUTION STEP
**Runs:** tiny local search only.

**Should run:**

```text
load tiny search config
sample 1-3 candidates
run tiny Bundle 3 evaluation for each
calculate score components
write shared result schema
rank candidates
write smoke comparison report

```
**Output:**

```text
/workspace/runs/nca-art-grn/search_smoke/<timestamp>/
search_config.yaml
candidates/
results.jsonl
ranking.json
search_report.md

```
**What this does for the research:**
Proves that search methods can call the NCA-ART-DSL mechanism loop and produce comparable outputs.

**How it links into the platform:**

```text
today:
config runs tiny local smoke

later:
Agentfield runs real search campaign

later:

```
## Whole-system linkage
Bundle 4 should connect like this:

```text
Bundle 3
evaluates one candidate mechanism deeply

Bundle 4
chooses and compares many candidates/search methods

Bundle 5
scales expensive searches/training/inference on Runpod

Agentfield later
orchestrates search campaigns

Paperclip later
makes campaigns human-reviewable

```
Concrete later flow:

```text
config:
sudo config --target researchscientist bootstrap step run_parameter_search_local_smoke

repo:
python -m nca_art_grn.cli.compare_search \
--config configs/search/smoke_comparison.yaml

Agentfield later:
GRNExperiment.spec.method = parameter_search_comparison
GRNExperiment.spec.search_method = lhs | evolutionary | bayesian

controller calls repo CLI
status points to /workspace/runs/nca-art-grn/<campaign_id>

Paperclip later:
shows candidates, method comparison, score breakdown, reports, next-experiment suggestions

```
## Acceptance criteria
**The following should be valid:**

```text
sudo config --target researchscientist bootstrap step install_parameter_search_comparison_stack
sudo config --target researchscientist bootstrap step prepare_search_parameter_space
sudo config --target researchscientist bootstrap step prepare_random_grid_baselines
sudo config --target researchscientist bootstrap step prepare_lhs_search_template
sudo config --target researchscientist bootstrap step prepare_evolutionary_search_template
sudo config --target researchscientist bootstrap step prepare_bayesian_search_template
sudo config --target researchscientist bootstrap step prepare_active_learning_search_template
sudo config --target researchscientist bootstrap step prepare_mechanism_scoring_runtime
sudo config --target researchscientist bootstrap step prepare_search_result_comparison_schema
sudo config --target researchscientist bootstrap step prepare_candidate_ranking_runtime
sudo config --target researchscientist bootstrap step prepare_robustness_sweep_template
sudo config --target researchscientist bootstrap step prepare_perturbation_search_template
sudo config --target researchscientist bootstrap step prepare_search_report_runtime
sudo config --target researchscientist bootstrap step prepare_search_smoke_configs
sudo config --target researchscientist bootstrap step check_parameter_search_inputs

```
**Explicit tiny execution:**

```text
sudo config --target researchscientist bootstrap step run_parameter_search_local_smoke

```
**Prepare/check steps must:**

```text
not run full searches
not run large simulations
not train full NCA models
not launch Runpod
not overwrite research code
not overwrite existing search results
not claim final mechanism from final pattern score alone
not build paper outputs

```
**Smoke step must:**

```text
use tiny local configs
run only 1-3 candidates
record search method
record candidate DSL
record mechanism hypothesis
record score components
record failure reasons
write result schema
write search report
clearly label outputs as smoke

```
## Proposed tests
### Registry and shell syntax tests

```text
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh

config bootstrap steps | grep prepare_search_parameter_space
config bootstrap steps | grep prepare_lhs_search_template
config bootstrap steps | grep prepare_evolutionary_search_template
config bootstrap steps | grep prepare_bayesian_search_template
config bootstrap steps | grep prepare_mechanism_scoring_runtime
config bootstrap steps | grep prepare_search_result_comparison_schema
config bootstrap steps | grep run_parameter_search_local_smoke

```
### Repo structure tests

```text
test -d /workspace/repos/nca-art-grn/src/nca_art_grn/search
test -d /workspace/repos/nca-art-grn/configs/search
test -d /workspace/artifacts/nca-art-grn/search_reports

```
### Config tests

```text
sudo config --target researchscientist bootstrap step prepare_search_smoke_configs

test -f /workspace/repos/nca-art-grn/configs/search/smoke_random_grid.yaml
test -f /workspace/repos/nca-art-grn/configs/search/smoke_lhs.yaml
test -f /workspace/repos/nca-art-grn/configs/search/smoke_evolutionary.yaml
test -f /workspace/repos/nca-art-grn/configs/search/smoke_bayesian.yaml
test -f /workspace/repos/nca-art-grn/configs/search/smoke_comparison.yaml

```
### Scoring schema tests

```text
sudo config --target researchscientist bootstrap step prepare_mechanism_scoring_runtime
sudo config --target researchscientist bootstrap step prepare_search_result_comparison_schema

test -f /workspace/repos/nca-art-grn/configs/search/scoring.yaml
test -f /workspace/repos/nca-art-grn/configs/search/result_schema.yaml

```
**The scoring config should include fields for:**

```text
final_pattern_score
pattern_dynamics_score
nca_agreement_score
art2_prototype_quality_score
artmap_transition_consistency_score
perturbation_response_score
mechanism_discrimination_value

```
### Readiness check

```text
sudo config --target researchscientist bootstrap step check_parameter_search_inputs

```
**Expected:** readiness report only, no simulations.

### Local smoke test

```text
sudo config --target researchscientist bootstrap step run_parameter_search_local_smoke

find /workspace/runs/nca-art-grn/search_smoke -name results.jsonl | tail -n 1
find /workspace/runs/nca-art-grn/search_smoke -name ranking.json | tail -n 1
find /workspace/runs/nca-art-grn/search_smoke -name search_report.md | tail -n 1

```
### Scientific guardrail test
**The smoke search report must contain:**

```text
Search method
Candidate IDs
Score component breakdown
Final pattern score is not sufficient

Dynamics evidence
Perturbation evidence
Mechanism-discrimination value
Recommended next experiment

```
### Non-overwrite test

```text
echo "DO NOT OVERWRITE" > /workspace/repos/nca-art-grn/configs/search/scoring.yaml
sudo config --target researchscientist bootstrap step prepare_mechanism_scoring_runtime
grep "DO NOT OVERWRITE" /workspace/repos/nca-art-grn/configs/search/scoring.yaml

```
## Summary
Bundle 4 is the search and comparison layer.

It does not replace Bundle 3. It repeatedly calls Bundle 3’s mechanism-evaluation loop.

```text
Bundle 3 asks:
Is this candidate mechanism meaningful?

Bundle 4 asks:
Which search method finds meaningful mechanisms efficiently and robustly?

```
Scientifically, Bundle 4 must search for:

```text
not just final patterns,
but mechanisms with useful dynamics,
NCA agreement,
ART2 prototype structure,
ARTMAP transition consistency,
DSL recoverability,

robustness,
perturbation response,
and experimental-design value.
```
Platform-wise:

```text
config prepares the search tools
nca-art-grn executes the search logic
/workspace stores runs and reports
Agentfield later orchestrates campaigns
Paperclip later exposes those campaigns for human review

```
