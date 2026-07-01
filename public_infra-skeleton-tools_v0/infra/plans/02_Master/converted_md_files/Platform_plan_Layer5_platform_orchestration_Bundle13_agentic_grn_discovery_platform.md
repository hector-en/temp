# Bundle 13 — Agentic GRN discovery platform
## Scrum-master view
Bundle objective: compose the pieces from Bundles 3, 4, 5, 8, 11, and 12 into one managed, reviewable GRN discovery campaign system.

Bundle 11 made the first Agentfield experiment-aware controller real:

```
GRNExperiment intent
-> ExperimentAwareController
-> Agent Registry
-> Reasoner Invoker
-> stage reasoners
-> CRD-like status/results
```


Your current Agentfield POC already proves this pattern at small scale: it accepts structured GRN experiment intent, resolves stages, invokes five
GRN exploration agents, passes context forward, and returns accumulated status/results.

Bundle 12 prepared the Paperclip-Agentfield bridge:

```
Paperclip job
-> adapter
-> Agentfield run_experiment input
-> Agentfield status/results
-> Paperclip card/review action
```


Bundle 13 is the integrated campaign layer.

It turns this:

```
run one experiment-aware GRN workflow
```


into this:


```
run a controlled discovery campaign:
generate candidates
evaluate mechanisms
compare search methods
run perturbation/robustness checks
summarize evidence
ask for human approval
propose the next campaign
```


The scientific guardrail remains:

```
The platform is not searching for pretty final patterns.
```


```
It is searching for mechanisms that produce inspectable evidence:
dynamics
perturbation responses
NCA agreement
ART2 prototypes
ARTMAP transitions
DSL recoverability
falsification criteria
next-experiment value
```


This matters because final pattern similarity alone cannot identify the true mechanism. The platform must preserve mechanism evidence and
experimental-design reasoning.


## Where Bundle 13 sits in the platform

```
config
prepares roles, repos, envs, workspaces, manifests, smoke steps
```


```
nca-art-grn
owns the science engine:
DSL, PDE/ODE, NCA, ART2, ARTMAP, search, perturbations, reports
```


```
OpenClaw / PKM reasoning
owns research summaries, next-experiment suggestions, note/paper context
```


```
Agentfield
owns experiment and campaign orchestration:
specs, controller flow, selected agents, status, artifacts, summaries
```


```
Paperclip-Agentfield adapter
maps human jobs/actions into Agentfield requests
maps status/results back into Paperclip cards
```


```
Paperclip
owns human review, approval, dashboard, inbox, governance
```

Bundle 13 is the first bundle where these pieces become a discovery platform instead of isolated components.


## User story

```
As the Research Scientist / AI Engineer,
I want Agentfield to coordinate a full GRN discovery campaign,
so that candidate generation, mechanism evaluation, search comparison,
perturbation design, evidence review, and next-experiment proposals happen
as a managed workflow with human review gates, rather than as disconnected
manual commands.
```


## Product outcome
After Bundle 13, the system should support a campaign object like:

```
GRNDiscoveryCampaign:
campaign_id: grn-campaign-001
name: 5-node NCA-ART-GRN discovery smoke
objective: discover and rank candidate 5-node GRN mechanisms
execution_target: local
research_mode: nca_art_grn
candidate_source:
mode: dsl_seeded
motif_priors: true
evaluation_plan:
run_dsl_review: true
run_pde_ode: true
run_nca: true
run_art2: true
run_artmap: true
run_perturbation_design: true
run_hypothesis_ranking: true
search_plan:
method: smoke_lhs
candidate_budget: 3
review_policy:
human_review_required: true
auto_launch_next_campaign: false
```


This should produce:

```
campaign_status.json
campaign_stage_results.json
```


```
candidate_rankings.json
artifact_refs.json
mechanism_reports/
search_report.md
next_experiment_suggestions.md
paperclip review payload.json
```


## Step type legend

```
CONFIG STEP
Managed bootstrap/check/smoke step invoked by config.
```


```
AGENTFIELD CODE
Code inside /workspace/repos/agentfield.
```


```
RESEARCH ENGINE
nca-art-grn repo code and CLI entrypoints.
```


```
REASONING LAYER
OpenClaw/PKM profiles and summaries.
```


```
ADAPTER LAYER
Paperclip-Agentfield translation code.
```


```
RESEARCH OUTPUT
Candidate artifacts, metrics, reports, rankings, failure reasons.
```


```
PAPERCLIP LATER
Human-facing dashboard/review layer.
```


## Concretizations / managed steps

### `prepare_grn_discovery_campaign_schema`
### `prepare_campaign_status_schema`
### `prepare_campaign_state_store`
### `prepare_campaign_stage_registry`
### `prepare_candidate_generation_agent`
### `prepare_mechanism_evaluation_agent`
### `prepare_search_strategy_agent`
### `prepare_perturbation_design_agent`
### `prepare_evidence_review_agent`
### `prepare_next_experiment_agent`
### `prepare_human_review_gate`
### `prepare_campaign_artifact_collector`
### `prepare_campaign_paperclip_payload_mapper`
### `prepare_grn_discovery_campaign_smoke_fixtures`
### `check_grn_discovery_platform_ready`
### `run_grn_discovery_campaign_local_smoke`


## Optional later

### `prepare_runpod_campaign_executor`
### `prepare_async_campaign_resume`
### `prepare_campaign_retry_policy`
### `prepare_multi_campaign_comparison`
### `prepare_paperclip_campaign_live_submit`


Those should wait until the local campaign smoke works.


## What each step should do
### `prepare_grn_discovery_campaign_schema`


Type: CONFIG STEP
Owner: config prepares schema files; aiengineer develops them.
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/schemas/grn_discovery_campaign.py
configs/campaigns/grn_discovery_campaign.schema.yaml
```


The campaign schema must encode:

```
campaign_id
name
description
objective
created_by
target_role
research_mode
execution_target
candidate_source
candidate_budget
mechanism_hypothesis_scope
evaluation_plan
search_plan
perturbation_plan
reasoning_plan
artifact_policy
resource_policy
review_policy
paperclip_visibility
```


The evaluation_plan must be able to select:

```
dsl_candidate_review
pde_ode_simulation
nca_evaluation
```


```
art2_discovery
artmap_transition_learning
prototype_to_dsl_mapping
mechanism_report_review
perturbation_design
hypothesis_ranking
```


What this does for the platform:
Defines campaign intent as structured data instead of a loose prompt or shell script.

What this does for the research:
Keeps the discovery campaign traceable: what candidates were considered, what evidence was required, which methods were allowed, and what
counted as reviewable output.

How it links into the whole system:

```
Paperclip later creates campaign request
adapter maps it into campaign schema
Agentfield validates it
Agentfield runs staged experiments
nca-art-grn produces artifacts
Paperclip reviews results
```


### `prepare_campaign_status_schema`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/schemas/campaign_status.py
configs/campaigns/campaign_status.schema.yaml
```


Campaign status must encode:


```
campaign_id
phase
started_at
finished_at
current_stage
candidate_count
completed_candidates
failed_candidates
selected_agents
stage_results
experiment_refs
artifact_refs
ranking_refs
report_refs
failure_reason
human_review_state
next_action_suggestions
```


Recommended phases:

```
created
validated
planning
generating_candidates
evaluating_candidates
running_search
running_perturbation_review
collecting_artifacts
summarizing
review_required
completed
failed
cancelled
```


What this does for the platform:
Extends Bundle 11’s experiment status into campaign-level lifecycle state.

What this does for the research:
Lets you inspect campaign progress and distinguish platform failure from scientific failure.

How it links into the whole system:

```
Agentfield writes campaign_status.json
Paperclip displays campaign phase
OpenClaw summarizes completed/failed campaigns
```


### `prepare_campaign_state_store`
Type: CONFIG STEP
Creates directories and simple persistence contracts:

```
/workspace/runs/agentfield/campaigns/
active/
completed/
failed/
review_required/
```


Each campaign run should contain:

```
campaign.yaml
campaign_status.json
stage_results.jsonl
experiment_refs.json
artifact_refs.json
candidate_rankings.json
```


```
failure reason.json
```
What this does for the platform:
Gives Agentfield campaigns durable state without needing a database in the first pass.

What this does for the research:
Makes each campaign reproducible and auditable.

How it links into the whole system:

```
config prepares state store
Agentfield writes campaign state
adapter maps review payload to Paperclip
```


### `prepare_campaign_stage_registry`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/registry/campaign_stage_registry.py
configs/campaigns/campaign_stage_registry.yaml
```


The registry maps campaign stages to agents/reasoners/runners.

First-pass campaign stages:

```
candidate_generation
mechanism_evaluation
search_strategy
perturbation_design
evidence_review
```


```
t       i    t
```
Future NCA-ART-GRN evidence stages:

```
dsl_candidate_review
pde_ode_evidence_review
nca_agreement_review
art2_prototype_review
artmap_transition_review
prototype_to_dsl_review
mechanism_report_review
```


What this does for the platform:
Keeps the controller thin. The campaign controller resolves stages through a registry rather than hardcoding every workflow.

What this does for the research:
Makes it clear which kind of reasoning/execution is happening at each point.

How it links into the whole system:

```
campaign schema -> stage registry
stage registry -> selected agents/reasoners/runners
selected stages -> campaign status
```


### `prepare_candidate_generation_agent`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/agents/candidate_generation.py
configs/campaigns/agents/candidate_generation.yaml
```


The agent must support first-pass modes:

```
fixture_candidates
dsl_seeded_candidates
search_report_shortlist
manual_candidate_refs
```


Later modes:

```
motif_seeded_generation
prototype_to_dsl_generated
evolutionary_generated
bayesian_suggested
active_learning_suggested
```


Generated candidate records must encode:

```
candidate_id
source
dsl_path
mechanism_hypothesis_id
motif_provenance
parameter_set
generation_reason
expected_tests
```


What this does for the platform:
Gives campaigns a controlled candidate input step.

What this does for the research:
Prevents candidate generation from being opaque. Every candidate must state where it came from and why it should be tested.

How it links into the whole system:


```
Bundle 3 DSL runtime defines candidate format
Bundle 4 search outputs candidate shortlists
candidate generation agent selects/creates candidate refs
mechanism evaluation agent evaluates them
```


### `prepare_mechanism_evaluation_agent`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/agents/mechanism_evaluation.py
configs/campaigns/agents/mechanism_evaluation.yaml
```


This agent should call or wrap Bundle 3/11-style experiment execution.

Evaluation must check for evidence:

```
candidate_dsl
mechanism_hypothesis
pattern_dynamics
nca_summary
art2_prototypes
artmap_transitions
perturbation_summary
mechanism_report
failure_reason
```


What this does for the platform:
Runs or reviews candidate mechanism evaluations as Agentfield-managed experiments.

What this does for the research:
Ensures that a candidate is not “successful” just because it produced a visual pattern.


How it links into the whole system:

```
candidate refs -> mechanism evaluation agent
agent -> Agentfield GRNExperiment or nca-art-grn CLI
outputs -> mechanism reports and artifact refs
```


### `prepare_search_strategy_agent`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/agents/search_strategy.py
configs/campaigns/agents/search_strategy.yaml
```


This agent chooses or reviews search strategy using Bundle 4 outputs.

It must support:

```
random_grid
latin_hypercube
evolutionary
bayesian
active_learning
manual_shortlist
```


It should reason over:

```
candidate budget
failure rate
score component breakdown
robustness evidence
perturbation evidence
```


```
mechanism-discrimination value
available compute
```

What this does for the platform:
Turns search comparison into a campaign decision point.

What this does for the research:
Helps choose the next search method based on scientific value, not habit.

How it links into the whole system:

```
Bundle 4 search reports -> search strategy agent
agent -> next candidate set or next search recommendation
```


### `prepare_perturbation_design_agent`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/agents/perturbation_design.py
configs/campaigns/agents/perturbation_design.yaml
```


This extends the POC’s perturbation planning agent, but for your mechanism-discovery workflow.

It must propose:

```
targeted perturbation
expected distinguishing outcome
mechanism claim being tested
falsification criterion
required input artifact
```


Examples:

```
diffusion scaling test
boundary condition shift
initial-condition bias
local ablation/state reset
reaction parameter sensitivity test
NCA rollout perturbation replay
ART2 vigilance sensitivity test
```


What this does for the platform:
Makes perturbation planning an explicit campaign stage.

What this does for the research:
Keeps the whole system aligned with mechanism testing rather than final-image matching.

How it links into the whole system:

```
mechanism report -> perturbation design agent
agent -> next experiment suggestion
human review gate -> approve or reject
```


### `prepare_evidence_review_agent`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/agents/evidence_review.py
configs/campaigns/agents/evidence_review.yaml
```


The review agent should summarize evidence across candidates.


It must inspect:

```
mechanism reports
search reports
candidate rankings
artifact refs
failure reasons
stage results
perturbation summaries
```


It must output:

```
best candidate shortlist
weakest evidence per candidate
missing artifacts
platform failures
science failures
recommended next actions
human-review notes
```


What this does for the platform:
Creates a campaign-level result summary.

What this does for the research:
Helps the Research Scientist decide what is worth trusting, rerunning, scaling, or rejecting.

How it links into the whole system:

```
Agentfield campaign artifacts -> evidence review agent
review output -> Paperclip review payload
review output -> OpenClaw/PKM notes later
```


### `prepare_next_experiment_agent`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/agents/next_experiment.py
configs/campaigns/agents/next_experiment.yaml
```


The agent should produce structured suggestions:

```
suggestion_id
candidate_id
reason
proposed_next_experiment
expected_result_if_hypothesis_true
expected_result_if_alternative_true
falsification_criterion
estimated_compute_cost
requires_human_approval
```


What this does for the platform:
Turns campaign results into a next-step proposal.

What this does for the research:
Prevents the system from stopping at summaries. It helps transform evidence gaps into testable next experiments.

How it links into the whole system:

```
evidence review -> next experiment agent
next experiment suggestion -> human review gate
Paperclip later shows approve/reject/modify
```


### `prepare_human_review_gate`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/review/human_review_gate.py
configs/campaigns/human_review_gate.yaml
```


The gate must enforce:

```
no expensive remote campaign without approval
no publication promotion without approval
no auto-accept mechanism claim without approval
no next experiment launch without approval
review_required by default for campaign smoke
```


Review states:

```
not_required
required
approved
rejected
needs_more_evidence
retry_requested
escalated
```


What this does for the platform:
Keeps autonomous workflow bounded.

What this does for the research:
Keeps scientific interpretation under human control.

How it links into the whole system:


```
Agentfield campaign reaches review_required
adapter maps review payload to Paperclip
Paperclip human action returns approval/rejection later
```


### `prepare_campaign_artifact_collector`
Type: CONFIG STEP
Creates/validates AGENTFIELD CODE:

```
agentfield_grn/artifacts/campaign_collector.py
configs/campaigns/campaign_expected_artifacts.yaml
```


Artifact classes:

```
campaign_status
candidate_list
candidate_rankings
mechanism_reports
search_report
perturbation_suggestions
next_experiment_suggestions
paperclip_review_payload
failure_reasons
logs
```


Future research artifacts:

```
candidate_dsl
pattern_dynamics
nca_summary
art2_prototypes
artmap_transitions
```


```
prototype_to_dsl_mapping
figures
tables
```


What this does for the platform:
Indexes campaign outputs into a reviewable collection.

What this does for the research:
Ensures evidence does not get lost across multiple candidate runs.

How it links into the whole system:

```
candidate/evaluation/search stages write outputs
collector indexes them
Paperclip payload links them
OpenClaw can later reason over them
```


### `prepare_campaign_paperclip_payload_mapper`
Type: CONFIG STEP
Creates/validates AGENTFIELD/ADAPTER CONTRACT:

```
agentfield_grn/review/paperclip_payload.py
configs/campaigns/paperclip_payload.schema.yaml
```


Payload must include:

```
campaign_id
title
phase
summary
candidate_count
best_candidates
```


```
failed_candidates
artifact_links
review_actions
next_experiment_suggestions
human_review_state
```


Review actions:

```
approve_next_experiment
reject_campaign
request_more_evidence
retry_failed_candidates
promote_candidate_to_paper_context
archive_campaign
```


What this does for the platform:
Prepares Bundle 13 outputs for Bundle 12’s adapter.

What this does for the research:
Makes campaign outcomes human-reviewable, not just machine-generated.

How it links into the whole system:

```
Agentfield campaign output -> Paperclip payload
adapter maps payload -> Paperclip card
human reviews in Paperclip later
```


### `prepare_grn_discovery_campaign_smoke_fixtures`
Type: CONFIG STEP
Creates fixtures:


```
smoke_tests/fixtures/grn_discovery_campaign_smoke.yaml
smoke_tests/fixtures/candidate_fixture_set.json
smoke_tests/fixtures/mock_mechanism_report.md
smoke_tests/fixtures/mock_search_report.md
```


Smoke campaign should be tiny:

```
1-3 fixture candidates
no Runpod
no full NCA training
mock or dryrun reasoners allowed
human_review_required true
no auto-next-campaign launch
```


What this does for the platform:
Creates a safe test fixture for the whole campaign flow.

What this does for the research:
Lets you validate campaign structure before running real science.

How it links into the whole system:

```
fixtures -> campaign controller smoke
smoke -> campaign status/artifacts/review payload
```


### `check_grn_discovery_platform_ready`
Type: CONFIG CHECK STEP
Runs: no campaign execution.

Should check:


```
Agentfield workspace exists
campaign schema exists
campaign status schema exists
stage registry exists
candidate generation agent exists
mechanism evaluation agent exists
search strategy agent exists
perturbation design agent exists
evidence review agent exists
next experiment agent exists
human review gate exists
artifact collector exists
Paperclip payload mapper exists
smoke fixtures exist
state store writable
```


What this does for the platform:
Preflight for the integrated campaign layer.

What this does for the research:
Avoids mistaking missing platform wiring for a scientific failure.

How it links into the whole system:

```
operator/aiengineer runs readiness check
fixes missing platform components
then runs local campaign smoke
```


### `run_grn_discovery_campaign_local_smoke`
Type: CONFIG SMOKE EXECUTION STEP
Runs: tiny local campaign only.


Smoke flow:

```
load campaign fixture
validate campaign schema
create campaign state directory
resolve campaign stages
load fixture candidates
run mock/tiny mechanism evaluation
run search strategy review
run perturbation design review
run evidence review
run next experiment suggestion
apply human review gate
collect artifacts
write Paperclip review payload
mark campaign review_required
```


Output:

```
/workspace/runs/agentfield/campaigns/review_required/<campaign_id>/
campaign.yaml
campaign_status.json
stage_results.jsonl
candidate_list.json
candidate_rankings.json
artifact_refs.json
next_experiment_suggestions.md
paperclip_review_payload.json
```


What this does for the platform:
Proves that Agentfield can coordinate a multi-stage discovery campaign.

What this does for the research:
Shows the end-to-end research decision loop: candidates, evidence, ranking, perturbation suggestion, and human review.


How it links into the whole system:

```
today:
local Agentfield campaign smoke
```


```
later:
real nca-art-grn candidate evaluations
```


```
later:
Runpod campaign execution
```


```
later:
Paperclip dashboard review
```


```
later:
PKM/paper pipeline
```


## Whole-system linkage
Bundle 13 connects all previous platform pieces:

```
Bundle 3
single-candidate NCA-ART-GRN mechanism evaluation
```


```
Bundle 4
parameter search and comparison
```


```
Bundle 5
remote execution and result return
```


```
Bundle 8
OpenClaw/PKM reasoning and next-experiment context
```


```
Bundle 11
Agentfield experiment-aware controller foundation
```


```
Bundle 12
Paperclip-Agentfield adapter
```


```
Bundle 13
campaign-level GRN discovery orchestration
```


Concrete platform path:

```
Paperclip later:
user requests campaign
```


```
Adapter:
maps campaign job to Agentfield campaign input
```


```
Agentfield:
runs campaign stages
creates experiments as needed
collects status and artifacts
applies human review gate
```


```
nca-art-grn:
evaluates candidates and writes scientific outputs
```


```
OpenClaw:
can summarize reports and propose next experiments
```


```
Paperclip:
shows review payload and waits for human action
```


## Acceptance criteria
The following should become valid:

```
sudo config --target aiengineer bootstrap step prepare_grn_discovery_campaign_schema
sudo config --target aiengineer bootstrap step prepare_campaign_status_schema
sudo config --target aiengineer bootstrap step prepare_campaign_state_store
sudo config --target aiengineer bootstrap step prepare_campaign_stage_registry
sudo config --target aiengineer bootstrap step prepare_candidate_generation_agent
sudo config --target aiengineer bootstrap step prepare_mechanism_evaluation_agent
sudo config --target aiengineer bootstrap step prepare_search_strategy_agent
sudo config --target aiengineer bootstrap step prepare_perturbation_design_agent
sudo config --target aiengineer bootstrap step prepare_evidence_review_agent
sudo config --target aiengineer bootstrap step prepare_next_experiment_agent
sudo config --target aiengineer bootstrap step prepare_human_review_gate
sudo config --target aiengineer bootstrap step prepare_campaign_artifact_collector
sudo config --target aiengineer bootstrap step prepare_campaign_paperclip_payload_mapper
sudo config --target aiengineer bootstrap step prepare_grn_discovery_campaign_smoke_fixtures
sudo config --target aiengineer bootstrap step check_grn_discovery_platform_ready
```


Explicit smoke:

```
sudo config --target aiengineer bootstrap step run_grn_discovery_campaign_local_smoke
```


Prepare/check steps must:

```
not launch Runpod
not launch full NCA training
not call Paperclip live API
not auto-approve next campaigns
not overwrite Agentfield runs
not overwrite nca-art-grn research artifacts
not claim real scientific discovery from mock smoke outputs
not treat final pattern similarity as sufficient evidence
```


Smoke step must:

```
use fixture or tiny local candidates
write campaign state
write stage results
write candidate ranking
write artifact refs
write next-experiment suggestions
write Paperclip review payload
mark human_review_required
clearly label output as smoke
```


Proposed tests
Registry and syntax tests

```
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
```


```
config bootstrap steps | grep prepare_grn_discovery_campaign_schema
config bootstrap steps | grep prepare_campaign_stage_registry
config bootstrap steps | grep prepare_candidate_generation_agent
config bootstrap steps | grep prepare_mechanism_evaluation_agent
config bootstrap steps | grep prepare_human_review_gate
config bootstrap steps | grep run_grn_discovery_campaign_local_smoke
```


Workspace/state tests


```
sudo config --target aiengineer bootstrap step prepare_campaign_state_store
```


```
test -d /workspace/runs/agentfield/campaigns/active
test -d /workspace/runs/agentfield/campaigns/completed
test -d /workspace/runs/agentfield/campaigns/failed
test -d /workspace/runs/agentfield/campaigns/review_required
```


Schema tests

```
sudo config --target aiengineer bootstrap step prepare_grn_discovery_campaign_schema
sudo config --target aiengineer bootstrap step prepare_campaign_status_schema
```


```
test -f /workspace/repos/agentfield/configs/campaigns/grn_discovery_campaign.schema.yaml
test -f /workspace/repos/agentfield/configs/campaigns/campaign_status.schema.yaml
```


Campaign schema must include:

```
campaign_id
objective
research_mode
execution_target
candidate_source
evaluation_plan
search_plan
review_policy
```


Campaign status schema must include:

```
campaign_id
phase
current_stage
candidate_count
stage_results
```


```
artifact_refs
human_review_state
```


Agent module tests

```
sudo config --target aiengineer bootstrap step prepare_candidate_generation_agent
sudo config --target aiengineer bootstrap step prepare_mechanism_evaluation_agent
sudo config --target aiengineer bootstrap step prepare_search_strategy_agent
sudo config --target aiengineer bootstrap step prepare_perturbation_design_agent
sudo config --target aiengineer bootstrap step prepare_evidence_review_agent
sudo config --target aiengineer bootstrap step prepare_next_experiment_agent
```


```
test -f /workspace/repos/agentfield/agentfield_grn/agents/candidate_generation.py
test -f /workspace/repos/agentfield/agentfield_grn/agents/mechanism_evaluation.py
test -f /workspace/repos/agentfield/agentfield_grn/agents/search_strategy.py
test -f /workspace/repos/agentfield/agentfield_grn/agents/perturbation_design.py
test -f /workspace/repos/agentfield/agentfield_grn/agents/evidence_review.py
test -f /workspace/repos/agentfield/agentfield_grn/agents/next_experiment.py
```


Human review gate tests

```
sudo config --target aiengineer bootstrap step prepare_human_review_gate
```


```
test -f /workspace/repos/agentfield/agentfield_grn/review/human_review_gate.py
test -f /workspace/repos/agentfield/configs/campaigns/human_review_gate.yaml
grep "human_review_required" /workspace/repos/agentfield/configs/campaigns/human_review_gate.yaml
```


The gate config must enforce:

```
no_auto_launch_next_campaign
no_auto_promote_to_paper
no_auto_accept_mechanism_claim
```


Paperclip payload tests

```
sudo config --target aiengineer bootstrap step prepare_campaign_paperclip_payload_mapper
```


```
test -f /workspace/repos/agentfield/configs/campaigns/paperclip_payload.schema.yaml
test -f /workspace/repos/agentfield/agentfield_grn/review/paperclip_payload.py
```


Payload schema must include:

```
campaign_id
phase
summary
artifact_links
review_actions
next_experiment_suggestions
human_review_state
```


Readiness check

```
sudo config --target aiengineer bootstrap step check_grn_discovery_platform_ready
```


Expected: readiness report only, no campaign execution.

Local campaign smoke

```
sudo config --target aiengineer bootstrap step run_grn_discovery_campaign_local_smoke
```


```
find /workspace/runs/agentfield/campaigns -name campaign_status.json | tail -n 1
find /workspace/runs/agentfield/campaigns -name candidate_rankings.json | tail -n 1
find /workspace/runs/agentfield/campaigns -name paperclip_review_payload.json | tail -n 1
find /workspace/runs/agentfield/campaigns -name next_experiment_suggestions.md | tail -n 1
```


Expected campaign smoke state:

```
phase: review_required
human_review_state: required
candidate_count >= 1
paperclip_review_payload.json exists
```


Scientific guardrail test
The campaign summary or review payload must contain:

```
Final pattern similarity is not sufficient evidence
Mechanism evidence required
Perturbation or falsification suggestion required
Human review required
```


Non-overwrite test

```
mkdir -p /workspace/runs/agentfield/campaigns/review_required/existing_campaign
echo "DO NOT OVERWRITE" > /workspace/runs/agentfield/campaigns/review_required/existing_campaign/campaign
sudo config --target aiengineer bootstrap step run_grn_discovery_campaign_local_smoke
grep "DO NOT OVERWRITE" /workspace/runs/agentfield/campaigns/review_required/existing_campaign/campaign_s
```


Scientific and platform guardrails
Bundle 13 must not become an uncontrolled autonomous scientist.

Wrong:


```
generate candidates
rank them
declare mechanism discovered
launch Runpod automatically
write paper section automatically
```


Correct:

```
generate or select candidates
evaluate mechanism evidence
rank with uncertainty
suggest next experiments
collect artifacts
require human review
only then proceed
```


Bundle 13 must clearly separate:

```
platform completion:
campaign ran and produced required artifacts
```


```
scientific strength:
evidence quality, perturbation value, robustness, falsifiability
```


```
human decision:
approve, reject, retry, request more evidence
```


Updated Bundle 13 summary
Bundle 13 is the agentic campaign orchestration layer.

It composes:


```
Bundle 3:
mechanism evaluation
```


```
Bundle 4:
search and comparison
```


```
Bundle 5:
remote execution contracts
```


```
Bundle 8:
reasoning and next-experiment suggestions
```


```
Bundle 11:
Agentfield experiment-aware controller
```


```
Bundle 12:
Paperclip review bridge
```


into:

```
a managed GRN discovery campaign system
```


Platform-wise:

```
config prepares the platform
Agentfield runs campaigns
nca-art-grn produces scientific evidence
OpenClaw summarizes and suggests
Paperclip reviews and governs
```


Research-wise:


```
Bundle 13 helps discover candidate mechanisms,
but it does not declare truth.
```


```
It produces ranked evidence, missing-evidence notes,
perturbation suggestions, and human-review payloads.
```


In one line:

```
Bundle 13 turns your experiment-aware Agentfield POC into the campaign-level GRN discovery platform, with
```
