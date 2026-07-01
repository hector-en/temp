# Bundle 12 — Paperclip-Agentfield adapter
## Scrum-master view
Bundle objective: create the bridge between Paperclip as the human-facing workflow/dashboard and Agentfield as the experiment-aware
controller.

Bundle 11 established the first Agentfield pattern:

```
GRNExperiment intent
-> ExperimentAwareController
-> stage resolver
-> agent registry
-> reasoner invoker
-> selected GRN reasoners
-> status/results
-> Agentfield UI DAG
```

Bundle 12 now prepares the adapter that lets Paperclip work with that lifecycle.

The adapter should answer:

```
Can Paperclip request a GRN experiment without knowing Agentfield internals?
```

```
Can Paperclip display Agentfield experiment status, selected agents, stage results,
artifact refs, failures, and review-needed states?
```

```
Can a human approve, reject, retry, annotate, or escalate experiment outputs from Paperclip?
```

```
Can Paperclip eventually launch NCA-ART-GRN mechanism-discovery work through Agentfield,
without becoming the controller itself?
```

The core rule:

```
Paperclip is the human workflow surface.
Agentfield is the experiment controller.
nca-art-grn is the science engine.
config prepares the environment.
```

## Where this bundle sits in the platform

```
config
prepares adapter workspace, schemas, fixtures, mappings, smoke checks
```

```
Paperclip-Agentfield adapter
maps Paperclip jobs/actions to Agentfield execute requests
maps Agentfield status/results back to Paperclip-visible objects
```

```
Agentfield
owns run_experiment and experiment lifecycle
```

```
nca-art-grn
later owns real DSL/PDE/NCA/ART2/ARTMAP research execution
```

```
Paperclip
owns dashboard, inbox, review, approvals, user workflow, visibility
```

Bundle 12 is not the Paperclip app itself.
It is not Agentfield itself.
It is the translation and integration layer between them.

## User story

```
As the Operator / Research Scientist,
I want Paperclip to submit and review Agentfield GRN experiments through a clear adapter,
so that I can start experiment-aware workflows from a human-facing dashboard, inspect
status/results/artifacts, and approve or reject next actions without manually calling
Agentfield endpoints.
```

## Product outcome
After Bundle 12, this Paperclip-side request:

```
Create a GRN discovery experiment for this dataset using PCA, correlation,
perturbation planning, and hypothesis ranking.
```

should map to the Agentfield execute shape from the Bundle 11 POC:

```
POST /api/v1/execute/grn-experiment.run_experiment
```

```
{
"input": {
"name": "GRN Discovery in Human Cortex",
"description": "Identify key transcription factor regulatory networks in human cortical development u
"dataset_ref": "GSE123456_cortex_scrna",
"organism": "human",
"method_flags": ["pca", "correlation", "perturbation"]
}
}
```

Then the adapter maps Agentfield’s response/status into a Paperclip-visible object:

```
PaperclipExperimentCard:
title
phase
selected agents
stage summaries
execution id
artifact links
failure reason
review actions
```

## Step type legend

```
CONFIG STEP
Managed bootstrap/check/smoke step invoked by config.
```

```
ADAPTER CODE
Code inside /workspace/repos/paperclip-agentfield-adapter.
```

```
PAPERCLIP CONTRACT
Job/action/review schema visible to Paperclip.
```

```
AGENTFIELD CONTRACT
Execute request, execution id, status/result shape from Agentfield.
```

```
RESEARCH OUTPUT
Mechanism reports, search reports, artifacts, stage summaries.
```

```
AGENTFIELD LATER
Already started in Bundle 11; Bundle 12 calls it.
```

## Concretizations / managed steps

```
prepare_paperclip_agentfield_adapter_workspace
prepare_paperclip_job_schema
prepare_agentfield_execute_client
prepare_agentfield_request_mapper
prepare_agentfield_status_mapper
prepare_artifact_link_mapper
prepare_review_action_mapper
prepare_adapter_config_profiles
prepare_adapter_smoke_fixtures
prepare_adapter_cli_smoke_commands
check_paperclip_agentfield_adapter_ready
run_paperclip_agentfield_adapter_dryrun_smoke
```

## Optional live step, only when Agentfield server is running

```
run_paperclip_agentfield_adapter_live_smoke
```

## Not first pass

```
submit_real_paperclip_job
write_to_paperclip_database
launch_runpod_from_paperclip
auto_approve_next_experiment
```

## What each step should do
### `prepare_paperclip_agentfield_adapter_workspace`

Type: CONFIG STEP
Owner: config prepares workspace.
Target role: usually aiengineer .

Creates:

```
/workspace/repos/paperclip-agentfield-adapter/
README.md
pyproject.toml
paperclip_agentfield_adapter/
__init__.py
schemas/
clients/
mappers/
review/
artifacts/
cli/
configs/
adapter.yaml
agentfield_endpoints.yaml
paperclip_profiles.yaml
fixtures/
paperclip_jobs/
agentfield_responses/
smoke_tests/
runs/
```

What this does for the platform:
Creates a clean adapter repo, separate from Agentfield and separate from Paperclip.

What this does for the research:
Gives the experiment workflow a human-review bridge without polluting the scientific repo or Agentfield controller code.

How it links into the whole system:

```
config creates adapter workspace
adapter calls Agentfield
Paperclip later calls adapter
Agentfield calls reasoners/research engine
Paperclip receives reviewable results
```

### `prepare_paperclip_job_schema`
Type: CONFIG STEP
Creates/validates ADAPTER CODE + PAPERCLIP CONTRACT:

```
paperclip_agentfield_adapter/schemas/paperclip_job.py
configs/paperclip_job.schema.yaml
```

Paperclip job schema must encode:

```
job_id
title
description
job_type
requested_by
created_at
dataset_ref
organism
intent
method_flags
research_mode
candidate_id
candidate_batch_id
review_policy
priority
```

Initial supported job_type values:

```
grn_experiment_poc
nca_art_mechanism_smoke
parameter_search_review
mechanism_report_review
```

What this does for the platform:
Defines what Paperclip can ask for without knowing Agentfield internals.

What this does for the research:
Allows the Research Scientist to request experiments in research language: dataset, mechanism intent, candidate, method flags, review policy.

How it links into the whole system:

```
Paperclip job -> adapter schema validation
adapter -> Agentfield request mapper
Agentfield -> run_experiment
```

### `prepare_agentfield_execute_client`
Type: CONFIG STEP
Creates ADAPTER CODE:

```
paperclip_agentfield_adapter/clients/agentfield_client.py
configs/agentfield_endpoints.yaml
```

Client must support:

```
sync execute request
async execute request
poll execution status
```

```
fetch execution result
timeout handling
server health check
```

Initial endpoint profile:

```
agentfield:
base_url: "http://localhost:8080"
execute_sync_path: "/api/v1/execute/{node}.{reasoner}"
execute_async_path: "/api/v1/execute_async/{node}.{reasoner}"
default_node: "grn-experiment"
default_reasoner: "run_experiment"
```

The developer POC trigger uses the sync execute endpoint for grn-experiment.run_experiment , while noting that Agentfield also has an async
execute endpoint for longer workflows.

What this does for the platform:
Gives the adapter one clean way to call Agentfield.

What this does for the research:
Lets research workflows become dashboard-triggerable without manually writing curl commands.

How it links into the whole system:

```
Paperclip job -> Agentfield client -> Agentfield execute endpoint
Agentfield response -> status mapper -> Paperclip card
```

### `prepare_agentfield_request_mapper`
Type: CONFIG STEP
Creates ADAPTER CODE:

```
paperclip_agentfield_adapter/mappers/request_mapper.py
configs/request_mapping.yaml
```

The mapper converts Paperclip job fields into Agentfield input.

For the current POC:

```
PaperclipJob.title            -> input.name
PaperclipJob.description -> input.description
PaperclipJob.dataset_ref -> input.dataset_ref
PaperclipJob.organism         -> input.organism
PaperclipJob.method_flags -> input.method_flags
```

Example mapping:

```
{
"input": {
"name": "{title}",
"description": "{description}",
"dataset_ref": "{dataset_ref}",
"organism": "{organism}",
"method_flags": "{method_flags}"
}
}
```

Future fields should pass through when Bundle 11 schema supports them:

```
research_mode
candidate_id
candidate_batch_id
mechanism_hypothesis_id
```

```
config_ref
```

What this does for the platform:
Decouples Paperclip’s job model from Agentfield’s reasoner input model.

What this does for the research:
Preserves experiment meaning during translation. The adapter should not collapse a mechanism-discovery request into a generic prompt.

How it links into the whole system:

```
Paperclip job -> request mapper -> Agentfield GRNExperiment input
```

### `prepare_agentfield_status_mapper`
Type: CONFIG STEP
Creates ADAPTER CODE:

```
paperclip_agentfield_adapter/mappers/status_mapper.py
configs/status_mapping.yaml
```

The mapper converts Agentfield status/results into Paperclip display fields.

Current POC output shape includes:

```
phase
selected_agents
stage_results
final_summary
```

The POC GRNExperimentStatus accumulates selected agents, per-stage results, and a final summary.

Paperclip-visible status should include:

```
job_id
execution_id
phase
selected_agents
stage_count
completed_stage_count
stage_summaries
final_summary
failure_reason
review_required
```

Phase mapping:

```
Pending -> queued
Running -> running
Completed -> completed_review_required
Failed -> failed
```

What this does for the platform:
Turns Agentfield internal status into human-facing workflow status.

What this does for the research:
Lets the user see which reasoning/science stages ran and what they concluded.

How it links into the whole system:

```
Agentfield result -> status mapper -> Paperclip experiment card
```

### `prepare_artifact_link_mapper`

Type: CONFIG STEP
Creates ADAPTER CODE:

```
paperclip_agentfield_adapter/mappers/artifact_mapper.py
configs/artifact_mapping.yaml
```

First-pass POC artifacts:

```
stage summaries
final summary
execution id
DAG/UI link
```

Future NCA-ART-GRN artifacts:

```
mechanism_report.md
search_report.md
candidate.dsl.json
pattern_dynamics.json
nca_summary.json
art2_prototypes.json
artmap_transitions.json
perturbation_summary.json
figures
tables
failure_reason.txt
```

Each artifact link should encode:

```
artifact_type
label
path_or_url
required
exists
```

```
display_priority
review_action_hint
```

What this does for the platform:
Makes outputs visible and reviewable instead of buried in run folders.

What this does for the research:
Surfaces the actual evidence chain: mechanism reports, NCA/ART/ARTMAP outputs, perturbation summaries, and candidate DSL files.

How it links into the whole system:

```
Agentfield status/artifact refs -> artifact mapper -> Paperclip visible links
```

### `prepare_review_action_mapper`
Type: CONFIG STEP
Creates ADAPTER CODE:

```
paperclip_agentfield_adapter/review/actions.py
configs/review_actions.yaml
```

Review actions:

```
approve_result
reject_result
request_retry
request_more_evidence
promote_to_mechanism_candidate
promote_to_zettelkasten_alloy
queue_next_experiment
mark_as_failed_science
mark_as_platform_failure
```

First pass should not execute all actions. It should define the schema and dry-run mappings.

Each action must encode:

```
action_id
label
requires_human
allowed_phases
payload_schema
side_effects
dryrun_only_first_pass
```

What this does for the platform:
Defines how humans interact with Agentfield results through Paperclip.

What this does for the research:
Keeps the Research Scientist in control. The system can suggest next experiments, but a human approves before costly or publication-relevant
work.

How it links into the whole system:

```
Paperclip review action -> adapter action mapper
later -> Agentfield new experiment or PKM bridge
```

### `prepare_adapter_config_profiles`
Type: CONFIG STEP
Creates:

```
configs/adapter.yaml
configs/paperclip_profiles.yaml
configs/agentfield_endpoints.yaml
```

Profiles:

```
local_dev
agentfield_poc
nca_art_grn_dev
paperclip_mock
```

Must encode:

```
agentfield_base_url
default_node
default_reasoner
sync_or_async
poll_interval
timeout_seconds
paperclip_mock_mode
artifact_base_path
review_policy
```

What this does for the platform:
Lets the same adapter run in local dev, mock mode, or later real Paperclip mode.

What this does for the research:
Allows safe iteration without accidentally submitting real workflows or calling remote systems.

How it links into the whole system:

```
config profile -> adapter behavior
local smoke -> mock mode
live smoke -> Agentfield local server
future -> Paperclip integration
```

### `prepare_adapter_smoke_fixtures`
Type: CONFIG STEP
Creates fixtures:

```
fixtures/paperclip_jobs/grn_experiment_poc.json
fixtures/paperclip_jobs/nca_art_mechanism_smoke.json
fixtures/agentfield_responses/grn_experiment_completed.json
fixtures/agentfield_responses/grn_experiment_failed.json
```

Current POC Paperclip job fixture should map to the developer’s example:

```
{
"job_id": "pc-grn-poc-001",
"title": "GRN Discovery in Human Cortex",
"description": "Identify key transcription factor regulatory networks in human cortical development using scR
"job_type": "grn_experiment_poc",
"dataset_ref": "GSE123456_cortex_scrna",
"organism": "human",
"method_flags": ["pca", "correlation", "perturbation"],
"review_policy": "human_required"
}
```

What this does for the platform:
Gives deterministic test data.

What this does for the research:
Lets you validate the adapter path before real experiments or real Paperclip integration.

How it links into the whole system:

```
fixture Paperclip job -> request mapper -> Agentfield request
fixture Agentfield response -> status mapper -> Paperclip card
```

### `prepare_adapter_cli_smoke_commands`
Type: CONFIG STEP
Creates CLI/script wrappers:

```
paperclip_agentfield_adapter/cli/dryrun.py
paperclip_agentfield_adapter/cli/live_smoke.py
smoke_tests/run_adapter_dryrun.sh
smoke_tests/run_adapter_live_smoke.sh
```

Dryrun command should:

```
load Paperclip job fixture
validate Paperclip schema
map to Agentfield execute request
load mock Agentfield response
map to Paperclip status/card
write dryrun output
```

Live smoke command should:

```
load fixture
map to Agentfield request
call local Agentfield execute endpoint
map response
write live output
```

What this does for the platform:
Makes adapter behavior testable without the full Paperclip app.

What this does for the research:
Lets you verify the whole “human request -> Agentfield experiment -> human-readable result” path.

How it links into the whole system:

```
CLI dryrun -> no server required
CLI live -> Agentfield server required
future Paperclip -> same adapter library
```

### `check_paperclip_agentfield_adapter_ready`
Type: CONFIG CHECK STEP
Runs: no Agentfield call, no Paperclip call.

Should check:

```
adapter workspace exists
schemas exist
client exists
request mapper exists
status mapper exists
artifact mapper exists
review action mapper exists
fixtures exist
configs exist
dryrun CLI exists
Python imports available
Agentfield URL configured or defaultable
```

What this does for the platform:
Preflight before dryrun/live testing.

What this does for the research:
Prevents adapter wiring issues from being confused with Agentfield or science failures.

How it links into the whole system:

```
aiengineer runs check
fixes adapter setup
then runs dryrun or live smoke
```

### `run_paperclip_agentfield_adapter_dryrun_smoke`
Type: CONFIG SMOKE STEP
Runs: no Agentfield server required.

Should do:

```
load Paperclip job fixture
validate job schema
map to Agentfield execute request
load mock Agentfield completed response
map to Paperclip card/status
map mock artifacts
map review actions
write dryrun report
```

Output:

```
/workspace/runs/paperclip-agentfield-adapter/dryrun/<timestamp>/
paperclip_job.json
agentfield_request.json
mock_agentfield_response.json
paperclip_status.json
```

```
paperclip_card.json
review_actions.json
dryrun_report.md
```

What this does for the platform:
Proves the adapter translation works without needing live systems.

What this does for the research:
Confirms that experiment intent and stage evidence survive translation.

How it links into the whole system:

```
today:
mock Paperclip job -> adapter dryrun
```

```
later:
Paperclip UI -> adapter -> Agentfield
```

### `run_paperclip_agentfield_adapter_live_smoke`
Type: CONFIG SMOKE STEP
Runs: live local Agentfield call only when explicitly configured.

Requires:

```
af server running
grn_experiment.py Agentfield node running
OPENROUTER_API_KEY set if using live POC model calls
AGENTFIELD_URL reachable
```

Should do:

```
load Paperclip fixture
map to Agentfield execute request
call /api/v1/execute/grn-experiment.run_experiment
capture response
map to Paperclip status/card
write live smoke output
```

Output:

```
/workspace/runs/paperclip-agentfield-adapter/live/<timestamp>/
paperclip_job.json
agentfield_request.json
agentfield_response.json
paperclip_status.json
paperclip_card.json
```

What this does for the platform:
Proves the adapter can call the current Bundle 11 POC.

What this does for the research:
Shows that a dashboard-style request can trigger the experiment-aware controller.

How it links into the whole system:

```
Paperclip-like job -> adapter -> Agentfield POC -> status/card
```

## Whole-system linkage
Bundle 12 connects like this:

```
Bundle 11
Agentfield POC/controller exposes run_experiment
```

```
Bundle 12
adapter maps Paperclip job to run_experiment input
adapter maps Agentfield result to Paperclip status/card
```

```
Bundle 13
later uses this bridge for full GRN discovery campaigns
```

```
Paperclip
later becomes the actual UI/inbox/review system
```

Concrete flow:

```
Paperclip job:
"Run GRN experiment"
```

```
Adapter:
validate job
map request
call Agentfield
map status/results
expose review actions
```

```
Agentfield:
run_experiment
selected agents
stage results
final summary
```

```
Paperclip:
show card
ask human for review action
```

## Acceptance criteria
The following should become valid:

```
sudo config --target aiengineer bootstrap step prepare_paperclip_agentfield_adapter_workspace
sudo config --target aiengineer bootstrap step prepare_paperclip_job_schema
sudo config --target aiengineer bootstrap step prepare_agentfield_execute_client
sudo config --target aiengineer bootstrap step prepare_agentfield_request_mapper
sudo config --target aiengineer bootstrap step prepare_agentfield_status_mapper
sudo config --target aiengineer bootstrap step prepare_artifact_link_mapper
sudo config --target aiengineer bootstrap step prepare_review_action_mapper
sudo config --target aiengineer bootstrap step prepare_adapter_config_profiles
sudo config --target aiengineer bootstrap step prepare_adapter_smoke_fixtures
sudo config --target aiengineer bootstrap step prepare_adapter_cli_smoke_commands
sudo config --target aiengineer bootstrap step check_paperclip_agentfield_adapter_ready
```

Explicit dryrun:

```
sudo config --target aiengineer bootstrap step run_paperclip_agentfield_adapter_dryrun_smoke
```

Optional explicit live smoke:

```
sudo config --target aiengineer bootstrap step run_paperclip_agentfield_adapter_live_smoke
```

Prepare/check steps must:

```
not require real Paperclip
not require live Agentfield server
not call OpenRouter
not print API keys
not launch experiments
```

```
not launch Runpod
not write to Paperclip database
not auto-approve next actions
```

Dryrun smoke must:

```
use fixtures only
write mapped request/status/card
not call Agentfield
not call Paperclip
not call model APIs
```

Live smoke must:

```
require explicit live mode
call only local Agentfield endpoint
record request/response
not submit real Paperclip data
not call Runpod
```

Proposed tests
Registry and syntax tests

```
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
```

```
config bootstrap steps | grep prepare_paperclip_agentfield_adapter_workspace
config bootstrap steps | grep prepare_paperclip_job_schema
config bootstrap steps | grep prepare_agentfield_execute_client
config bootstrap steps | grep prepare_agentfield_request_mapper
```

```
config bootstrap steps | grep prepare_agentfield_status_mapper
config bootstrap steps | grep run_paperclip_agentfield_adapter_dryrun_smoke
```

Workspace tests

```
sudo config --target aiengineer bootstrap step prepare_paperclip_agentfield_adapter_workspace
```

```
test -d /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/schemas
test -d /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/clients
test -d /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/mappers
test -d /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/review
test -d /workspace/repos/paperclip-agentfield-adapter/fixtures/paperclip_jobs
test -d /workspace/repos/paperclip-agentfield-adapter/fixtures/agentfield_responses
```

Schema tests

```
sudo config --target aiengineer bootstrap step prepare_paperclip_job_schema
```

```
test -f /workspace/repos/paperclip-agentfield-adapter/configs/paperclip_job.schema.yaml
test -f /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/schemas/paperclip_job
```

Schema must include:

```
job_id
title
description
job_type
dataset_ref
organism
method_flags
review_policy
```

Client tests

```
sudo config --target aiengineer bootstrap step prepare_agentfield_execute_client
```

```
test -f /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/clients/agentfield_cli
test -f /workspace/repos/paperclip-agentfield-adapter/configs/agentfield_endpoints.yaml
grep "grn-experiment" /workspace/repos/paperclip-agentfield-adapter/configs/agentfield_endpoints.yaml
grep "run_experiment" /workspace/repos/paperclip-agentfield-adapter/configs/agentfield_endpoints.yaml
```

Mapper tests

```
sudo config --target aiengineer bootstrap step prepare_agentfield_request_mapper
sudo config --target aiengineer bootstrap step prepare_agentfield_status_mapper
sudo config --target aiengineer bootstrap step prepare_artifact_link_mapper
```

```
test -f /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/mappers/request_mapper
test -f /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/mappers/status_mapper
test -f /workspace/repos/paperclip-agentfield-adapter/paperclip_agentfield_adapter/mappers/artifact_mappe
```

Fixture tests

```
sudo config --target aiengineer bootstrap step prepare_adapter_smoke_fixtures
```

```
test -f /workspace/repos/paperclip-agentfield-adapter/fixtures/paperclip_jobs/grn_experiment_poc.json
test -f /workspace/repos/paperclip-agentfield-adapter/fixtures/agentfield_responses/grn_experiment_comple
```

Dryrun smoke

```
sudo config --target aiengineer bootstrap step run_paperclip_agentfield_adapter_dryrun_smoke
```

```
find /workspace/runs/paperclip-agentfield-adapter/dryrun -name agentfield_request.json | tail -n 1
find /workspace/runs/paperclip-agentfield-adapter/dryrun -name paperclip_status.json | tail -n 1
find /workspace/runs/paperclip-agentfield-adapter/dryrun -name paperclip_card.json | tail -n 1
find /workspace/runs/paperclip-agentfield-adapter/dryrun -name review_actions.json | tail -n 1
```

Mapping correctness test
For the POC fixture, agentfield_request.json must contain:

```
input.name = GRN Discovery in Human Cortex
input.dataset_ref = GSE123456_cortex_scrna
input.organism = human
input.method_flags = ["pca", "correlation", "perturbation"]
```

Status mapping test
Mock completed response should map to:

```
phase = completed_review_required
selected_agents present
stage_summaries present
final_summary present
review_actions present
```

Live smoke preflight
Before live smoke:

```
curl http://localhost:8080/health
```

or adapter equivalent health check.

Then:

```
sudo config --target aiengineer bootstrap step run_paperclip_agentfield_adapter_live_smoke
```

Expected:

```
agentfield_response.json exists
paperclip_card.json exists
```

## Scientific / platform guardrails
Bundle 12 must not turn Paperclip into the experiment engine.

Wrong:

```
Paperclip directly runs NCA training.
Paperclip directly reads/writes nca-art-grn internals.
Paperclip decides scientific truth.
```

Correct:

```
Paperclip requests/reviews.
Adapter translates.
Agentfield orchestrates.
nca-art-grn executes science.
Research Scientist approves meaning.
```

Also, Paperclip should not show “success” just because an LLM produced a confident summary.

The card should distinguish:

```
workflow completed
human review required
scientific evidence incomplete
artifact missing
platform failure
science failure
```

## Summary
Bundle 12 is the Paperclip-Agentfield integration layer.

It turns this:

```
Paperclip job/request
```

into this:

```
Agentfield run_experiment input
```

and turns this:

```
Agentfield status/results
```

into this:

```
Paperclip-visible card, artifact links, and review actions
```

Platform-wise:

```
config prepares adapter
adapter maps Paperclip <-> Agentfield
```

```
Agentfield runs experiment-aware controller
nca-art-grn later performs science
Paperclip later exposes the human workflow
```

Research-wise:

```
Bundle 12 makes experiment-aware GRN workflows reviewable by a human,
without letting the dashboard replace the science engine or the controller.
```
