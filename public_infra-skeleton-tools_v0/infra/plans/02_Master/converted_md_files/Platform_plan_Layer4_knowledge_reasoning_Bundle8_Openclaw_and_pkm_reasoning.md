# Bundle 8 — OpenClaw + PKM reasoning workspace

## Scrum-master view

Bundle objective: prepare the reasoning layer that can safely query your PKM, experiment reports,
mechanism reports, search reports, code summaries, and paper-planning material.

This bundle does not reorganize the Zettelkasten. Bundle 9 already owns the vault structure.

This bundle adds:

selected context packs
safe indexing manifests
model/reasoner profiles
OpenClaw workspace
query smoke tests
```
bridges from research artifacts -> reasoning context
bridges from reasoning context -> next experiment questions
```

The goal is:

not "chat with all notes randomly"

but

ask targeted questions over selected research context:
What mechanism evidence do we have?
Which candidates deserve next perturbation tests?
Which reports should become alloy notes?
Which experiment failed and why?
Which paper section can use this evidence?

## Where this bundle sits in the platform

Bundle 8 is mostly config-managed AI/PKM workspace preparation.

config
prepares OpenClaw workspace, PKM index manifests, model profiles, smoke tests

OpenClaw workspace
owns query workflows, context packs, reasoning runs, tool configs

Atomic Zettelkasten
owns notes, atoms, molecules, research questions, alloy notes

nca-art-grn artifacts
provide mechanism reports, search reports, candidate DSL, figures, metrics

remote model client
comes from Layer 1

Agentfield later
can call these reasoners for summaries, triage, ranking, and next-step suggestions

Paperclip later
exposes selected reasoning outputs for human review

This bundle is not Agentfield yet.
It prepares the reasoning workspace that Agentfield can later use.

## User story

As the Research Scientist / AI Engineer,
I want a prepared OpenClaw + PKM reasoning workspace,

so that I can query selected Zettelkasten notes, mechanism reports, search reports,
candidate artifacts, and code summaries to produce next-experiment suggestions,
failure triage, paper-writing context, and research decisions without overwriting
my vault or launching experiments.

## Concretizations / managed steps

### `prepare_openclaw_pkm_workspace`

### `check_openclaw_workspace`

### `prepare_pkm_context_index`

### `prepare_research_artifact_context_index`

### `prepare_mechanism_report_ingest`

### `prepare_search_report_ingest`

### `prepare_zettelkasten_reasoning_bridge`

### `prepare_local_model_reasoner_config`

### `prepare_remote_model_reasoner_config`

### `prepare_reasoning_profile_templates`

### `prepare_pkm_query_smoke_test`

### `prepare_next_experiment_question_generator`

### `prepare_mechanism_report_to_alloy_note_bridge`

### `check_pkm_reasoning_ready`

### `run_pkm_reasoning_local_smoke`

## Optional later

run_openclaw_reasoning_job
run_mechanism_review_reasoner
run_failure_triage_reasoner
run_paper_outline_reasoner

Those should be explicit later commands, not automatic prepare steps.

## Step type legend

CONFIG STEP
Managed bootstrap/check/smoke step invoked by config.

OPENCLAW WORKSPACE
Reasoning configs, context packs, query templates, runs.

PKM VAULT
Existing Atomic Zettelkasten notes; should not be overwritten.

RESEARCH ARTIFACT
Outputs from nca-art-grn: reports, metrics, candidates, figures.

MODEL CONTRACT
Local/remote model client config.

AGENTFIELD LATER
Future orchestration; not implemented in this bundle.

## What each step should do

### `prepare_openclaw_pkm_workspace`

**Type:** CONFIG STEP
**Owner:** config prepares workspace.
**Target role:** usually aiengineer , sometimes publisher or researchscientist .

**Creates:**

```
/workspace/repos/openclaw-workspace/
configs/
contexts/
queries/
profiles/
tools/
runs/
smoke_tests/
bridges/
reports/
```

#### What this does for the research:

Gives your reasoning tools a separate home. OpenClaw should not live inside the Zettelkasten vault and
should not live inside the nca-art-grn research repo. It is a reasoning layer that reads selected material and
writes reasoning outputs.

#### How it links into the platform:

config creates workspace
OpenClaw reads selected contexts
model client answers queries
outputs go to /workspace/repos/openclaw-workspace/runs
Agentfield later can call the same reasoning profiles
Paperclip later can display reasoning outputs

### `check_openclaw_workspace`

**Type:** CONFIG CHECK STEP
**Runs:** no model calls, no indexing.

**Checks:**

workspace exists
configs exists
contexts exists
queries exists
profiles exists
runs exists
bridges exists
PKM binding exists or missing
remote model config exists or missing

#### What this does for the research:

Confirms the reasoning workspace exists before you ask models to reason over notes, reports, or experiment
outputs.

#### How it links into the platform:

operator can verify readiness
aiengineer can fix missing config
Agentfield later can run this as preflight

### `prepare_pkm_context_index`

**Type:** CONFIG STEP
**Owner:** config prepares index/manifest; OpenClaw uses it.

**Creates:**

```
/workspace/repos/openclaw-workspace/contexts/pkm_index.yaml
```

The index should point to selected Zettelkasten zones:

```
/workspace/pkm/zettelkasten/20_knowledge_kasten/atoms
/workspace/pkm/zettelkasten/20_knowledge_kasten/molecules
/workspace/pkm/zettelkasten/20_knowledge_kasten/research_questions
/workspace/pkm/zettelkasten/30_publish_kasten/alloys
/workspace/pkm/zettelkasten/40_experiments
```

It should not index everything by default.

**The index must encode:**

context_id
path
allowed_note_types
include_patterns
exclude_patterns
max_files
privacy_level
last_scanned_at

#### What this does for the research:

Turns the Atomic Zettelkasten into a controlled reasoning source. It lets you ask questions over atoms,
molecules, research questions, and alloy notes without feeding the whole vault into a model.

#### How it links into the platform:

Bundle 9 creates vault
Bundle 8 creates selected context index
OpenClaw queries selected notes
Bundle 10 can consume selected alloy/section outputs

### `prepare_research_artifact_context_index`

**Type:** CONFIG STEP
**Creates:**

```
/workspace/repos/openclaw-workspace/contexts/research_artifacts_index.yaml
```

**Should index selected outputs from Layer 3:**

```
/workspace/artifacts/nca-art-grn/mechanism_reports
/workspace/artifacts/nca-art-grn/search_reports
/workspace/artifacts/nca-art-grn/prototypes
/workspace/artifacts/nca-art-grn/transition_graphs
/workspace/artifacts/nca-art-grn/dsl_candidates
/workspace/runs/nca-art-grn/*/metadata.json
```

**The index must encode:**

artifact_type
artifact_path
source_run_id
candidate_id
mechanism_hypothesis_id
search_method

#### What this does for the research:

Makes mechanism evidence queryable. You should be able to ask: “Which candidate has the best
perturbation evidence?” or “Which ART2 prototypes recur across robust candidates?”

#### How it links into the platform:

Bundle 3/4/5 produce artifacts
Bundle 8 indexes selected artifacts
reasoner summarizes evidence
Agentfield later can attach summaries to experiment status
Paperclip later can expose summaries

### `prepare_mechanism_report_ingest`

**Type:** CONFIG STEP
Creates REASONING WORKFLOW:

```
/workspace/repos/openclaw-workspace/bridges/mechanism_report_ingest.yaml
/workspace/repos/openclaw-workspace/queries/mechanism_review.md
```

The ingest contract should extract:

candidate_id
mechanism_hypothesis
final pattern summary
dynamics evidence
NCA agreement
ART2 evidence
ARTMAP transition evidence

perturbation evidence
DSL mapping status
falsification criterion
next experiment suggestion

#### What this does for the research:

Transforms Bundle 3 mechanism reports into reasoning material. It helps you compare candidate
mechanisms and decide what to test next.

#### How it links into the platform:

```
mechanism_report.md -> OpenClaw context pack
OpenClaw summary -> next experiment note or review report
```

Agentfield later can call this after each completed run

### `prepare_search_report_ingest`

**Type:** CONFIG STEP
**Creates:**

```
/workspace/repos/openclaw-workspace/bridges/search_report_ingest.yaml
/workspace/repos/openclaw-workspace/queries/search_comparison_review.md
```

The ingest contract should extract:

search_method
candidate count
failure count
best candidates
score components
Pareto front

robustness summary
perturbation summary
recommended next search
recommended next experiment

#### What this does for the research:

Turns Bundle 4 search outputs into decision support. It helps answer whether random search, LHS,
evolutionary, Bayesian, or active sampling is actually useful for your scientific goal.

#### How it links into the platform:

```
search_report.md -> reasoning context
reasoner -> search decision summary
summary -> Zettelkasten molecule/alloy candidate
```

Agentfield later can use summary to choose next campaign

### `prepare_zettelkasten_reasoning_bridge`

**Type:** CONFIG STEP
**Creates:**

```
/workspace/repos/openclaw-workspace/bridges/zettelkasten_bridge.yaml
```

The bridge must understand note types from Bundle 9:

source
atom
molecule
topic
research_question
alloy

latex_section_note
experiment_note
architecture decision

**It should define allowed operations:**

read selected note metadata
summarize selected notes
suggest links
```
suggest promotion from source -> atom
```

suggest molecule candidates
suggest alloy candidates
suggest paper section mapping

**It must not:**

overwrite notes
auto-promote notes
delete fleeting notes
rewrite private notes
commit model output into vault without approval

#### What this does for the research:

Lets AI help with the thinking workflow while preserving human control over the Zettelkasten.

#### How it links into the platform:

```
Bundle 9 vault -> bridge
```

OpenClaw suggests note actions
publisher/researchscientist approves manually
Bundle 10 later consumes selected alloy/section material

### `prepare_local_model_reasoner_config`

**Type:** CONFIG STEP
**Creates:**

```
/workspace/repos/openclaw-workspace/configs/local_model_reasoner.yaml
```

Should support profiles:

small_local_summary
local_code_review
local_note_linking
local_failure_triage

**Config must encode:**

model_provider
model_name
endpoint
context_limit
temperature
allowed_context_paths
output_path
no_write_to_vault_by_default

#### What this does for the research:

Lets you use a local model for cheap/private summarization and triage where appropriate.

#### How it links into the platform:

OpenClaw chooses local model profile
local model reads selected context pack

outputs reasoning report

### `prepare_remote_model_reasoner_config`

**Type:** CONFIG STEP
**Creates:**

```
/workspace/repos/openclaw-workspace/configs/remote_model_reasoner.yaml
```

This should use Layer 1’s thin contract:

```
local code -> remote model -> response
```

**Profiles:**

deep_mechanism_review
paper_argument_review
next_experiment_suggestion
architecture_review
codebase_planning_review

**Config must encode:**

remote_model_client_path
endpoint_env_var
model_alias
max_tokens
cost_guardrail
allowed_context_paths
redaction_policy
output_path

#### What this does for the research:

Lets stronger remote models reason over selected context packs when the task needs deeper reasoning,
such as comparing mechanism evidence or drafting next experiment logic.

#### How it links into the platform:

Layer 1 prepares remote model client
Bundle 8 prepares reasoner profiles
OpenClaw calls remote reasoner
Agentfield later can call profile from agents
Paperclip later can show result to operator

### `prepare_reasoning_profile_templates`

**Type:** CONFIG STEP
**Creates:**

```
/workspace/repos/openclaw-workspace/profiles/
mechanism_review.yaml
failure_triage.yaml
next_experiment.yaml
paper_section_context.yaml
search_strategy_review.yaml
codebase_architecture_review.yaml
```

**Each profile must define:**

profile_id
purpose
allowed_context_indexes
query_template

model_profile
output_schema
write_policy
human_review_required

#### What this does for the research:

Keeps reasoning tasks repeatable. You should not handcraft prompts every time you want to review a
mechanism report or a failed run.

#### How it links into the platform:

```
OpenClaw profile -> context indexes -> model profile -> output schema
```

Agentfield later can reference profile_id
Paperclip later can show profile output and approval state

### `prepare_pkm_query_smoke_test`

**Type:** CONFIG STEP
Creates tiny smoke query files:

```
/workspace/repos/openclaw-workspace/smoke_tests/pkm_query_smoke.yaml
/workspace/repos/openclaw-workspace/queries/smoke_pkm_query.md
```

**Smoke questions:**

What research questions exist?
Which mechanism reports are available?
Which candidate reports mention perturbation evidence?
Which notes are likely alloy candidates?
What is one safe next experiment suggestion?

#### What this does for the research:

Verifies that the reasoning stack can read selected context and produce a report without modifying the vault
or launching experiments.

#### How it links into the platform:

config prepares smoke query
OpenClaw runs query
output goes to openclaw-workspace/runs
Agentfield later can use same smoke as reasoner preflight

### `prepare_next_experiment_question_generator`

**Type:** CONFIG STEP
Creates workflow/template:

```
/workspace/repos/openclaw-workspace/queries/next_experiment_from_mechanism_report.md
/workspace/repos/openclaw-workspace/profiles/next_experiment.yaml
```

**The generated suggestions must consider:**

mechanism hypothesis
dynamics evidence
perturbation evidence

failure modes
candidate robustness
NCA agreement
ART2/ARTMAP consistency
Hiscock/Megason guardrail: final pattern is not sufficient

**Output schema:**

candidate_id
current_evidence
weakest_claim
proposed_next_experiment
expected distinguishing outcome
falsification criterion
required input artifacts
estimated cost class

#### What this does for the research:

Turns reports into actionable next experiments instead of passive summaries.

#### How it links into the platform:

```
mechanism report -> next experiment suggestion
```

researchscientist reviews suggestion
Bundle 4/5 can implement the next search/Runpod campaign
```
Agentfield later automates suggestion -> proposed experiment
```

Paperclip later asks human to approve

### `prepare_mechanism_report_to_alloy_note_bridge`

**Type:** CONFIG STEP
Creates bridge template only:

```
/workspace/repos/openclaw-workspace/bridges/mechanism_report_to_alloy.yaml
/workspace/repos/openclaw-workspace/queries/mechanism_report_to_alloy_note.md
```

**The bridge should map:**

```
mechanism claim -> alloy claim
dynamics evidence -> argument support
perturbation prediction -> falsification section
ART2/ARTMAP evidence -> method/result support
DSL mapping -> explainability support
figures/tables -> paper assets
```

#### What this does for the research:

Connects experiment evidence to publishable arguments. It helps move from mechanism reports into Bundle
9 alloy notes and then Bundle 10 LaTeX sections.

#### How it links into the platform:

```
Bundle 3/4/5 reports -> bridge
```

OpenClaw suggests alloy note draft
human approves and writes into Zettelkasten
Bundle 10 later uses selected alloy notes

### `check_pkm_reasoning_ready`

**Type:** CONFIG CHECK STEP
**Runs:** no model calls.

**Should report:**

OpenClaw workspace exists
PKM vault binding exists
PKM context index exists
research artifact index exists
mechanism report ingest exists
search report ingest exists
model profiles exist
reasoning profiles exist
smoke query exists
output path writable

#### What this does for the research:

Confirms the reasoning layer is wired before spending model tokens or generating outputs.

#### How it links into the platform:

operator runs readiness check
aiengineer fixes missing profiles
Agentfield later can use as reasoner preflight

### `run_pkm_reasoning_local_smoke`

**Type:** CONFIG SMOKE EXECUTION STEP
**Runs:** tiny query only. No vault write.

**Should do:**

load pkm context index
load research artifact index
select tiny allowed context
run local or mocked model profile

answer one smoke query
write reasoning report

**Output:**

```
/workspace/repos/openclaw-workspace/runs/smoke/<timestamp>/
context_manifest.yaml
query.md
reasoning_output.md
status.json
```

#### What this does for the research:

Proves you can query the research knowledge system safely.

#### How it links into the platform:

today:
config runs tiny smoke query

later:
OpenClaw runs richer reasoning workflows

later:
Agentfield calls reasoner profiles after experiments

later:
Paperclip displays reasoning outputs for approval

## Whole-system linkage

Bundle 8 connects the research system to the knowledge system:

Bundle 3
produces mechanism reports

Bundle 4
produces search reports and ranked candidates

Bundle 5
produces remote run summaries and returned artifacts

Bundle 9
owns Atomic Zettelkasten notes

Bundle 8
indexes selected notes/artifacts and reasons over them

Bundle 10
receives selected alloy/section-ready material later

Agentfield later
uses these reasoner profiles for agents and experiment summaries

Paperclip later
exposes human review of reasoning outputs

## Concrete flow

config today:
```
sudo config --target aiengineer bootstrap step run_pkm_reasoning_local_smoke
```

OpenClaw workspace:
reads context indexes
runs query profile
writes reasoning report

future Agentfield:
ExperimentReporterAgent uses mechanism_review profile
FailureTriageAgent uses failure_triage profile
HypothesisRankingAgent uses search_strategy_review profile

future Paperclip:
shows reasoning report
asks user approve/reject/convert to note/plan next experiment

## Acceptance criteria

The following should become valid:

```
sudo config --target aiengineer bootstrap step prepare_openclaw_pkm_workspace
sudo config --target aiengineer bootstrap step check_openclaw_workspace
sudo config --target aiengineer bootstrap step prepare_pkm_context_index
sudo config --target aiengineer bootstrap step prepare_research_artifact_context_index
sudo config --target aiengineer bootstrap step prepare_mechanism_report_ingest
sudo config --target aiengineer bootstrap step prepare_search_report_ingest
sudo config --target aiengineer bootstrap step prepare_zettelkasten_reasoning_bridge
sudo config --target aiengineer bootstrap step prepare_local_model_reasoner_config
sudo config --target aiengineer bootstrap step prepare_remote_model_reasoner_config
sudo config --target aiengineer bootstrap step prepare_reasoning_profile_templates
sudo config --target aiengineer bootstrap step prepare_pkm_query_smoke_test
sudo config --target aiengineer bootstrap step prepare_next_experiment_question_generator
sudo config --target aiengineer bootstrap step prepare_mechanism_report_to_alloy_note_bridge
sudo config --target aiengineer bootstrap step check_pkm_reasoning_ready
```

## Explicit smoke

```
sudo config --target aiengineer bootstrap step run_pkm_reasoning_local_smoke
```

## Prepare/check steps must

not overwrite PKM notes
not rewrite Zettelkasten structure
not index entire vault by default
not print private note bodies
not call remote models during checks
not run GRN simulations
not launch Runpod jobs
not write generated notes into the vault without approval
not build paper outputs

Smoke step must:

use tiny selected context
write output only to openclaw-workspace/runs
not modify the vault
not call paid remote model unless explicitly configured
clearly label output as smoke

Proposed tests
Registry and syntax tests

bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh

config bootstrap steps | grep prepare_openclaw_pkm_workspace
config bootstrap steps | grep prepare_pkm_context_index
config bootstrap steps | grep prepare_research_artifact_context_index
config bootstrap steps | grep prepare_reasoning_profile_templates
config bootstrap steps | grep check_pkm_reasoning_ready

Workspace structure tests

```
sudo config --target aiengineer bootstrap step prepare_openclaw_pkm_workspace
```

```
test -d /workspace/repos/openclaw-workspace/configs
test -d /workspace/repos/openclaw-workspace/contexts
test -d /workspace/repos/openclaw-workspace/queries
test -d /workspace/repos/openclaw-workspace/profiles
test -d /workspace/repos/openclaw-workspace/bridges
test -d /workspace/repos/openclaw-workspace/runs
```

## Context index tests

```
sudo config --target aiengineer bootstrap step prepare_pkm_context_index
sudo config --target aiengineer bootstrap step prepare_research_artifact_context_index
```

```
test -f /workspace/repos/openclaw-workspace/contexts/pkm_index.yaml
test -f /workspace/repos/openclaw-workspace/contexts/research_artifacts_index.yaml
```

## Bridge tests

```
sudo config --target aiengineer bootstrap step prepare_mechanism_report_ingest
sudo config --target aiengineer bootstrap step prepare_search_report_ingest
sudo config --target aiengineer bootstrap step prepare_zettelkasten_reasoning_bridge
```

```
test -f /workspace/repos/openclaw-workspace/bridges/mechanism_report_ingest.yaml
test -f /workspace/repos/openclaw-workspace/bridges/search_report_ingest.yaml
test -f /workspace/repos/openclaw-workspace/bridges/zettelkasten_bridge.yaml
```

## Reasoning profile tests

```
sudo config --target aiengineer bootstrap step prepare_reasoning_profile_templates
```

```
test -f /workspace/repos/openclaw-workspace/profiles/mechanism_review.yaml
test -f /workspace/repos/openclaw-workspace/profiles/failure_triage.yaml
test -f /workspace/repos/openclaw-workspace/profiles/next_experiment.yaml
test -f /workspace/repos/openclaw-workspace/profiles/search_strategy_review.yaml
```

## Readiness check

```
sudo config --target aiengineer bootstrap step check_pkm_reasoning_ready
```

Expected: reports readiness only, no model call.

## Smoke test

```
sudo config --target aiengineer bootstrap step run_pkm_reasoning_local_smoke
```

```
find /workspace/repos/openclaw-workspace/runs/smoke -name reasoning_output.md | tail -n 1
find /workspace/repos/openclaw-workspace/runs/smoke -name status.json | tail -n 1
```

## Vault non-write test

```
echo "DO NOT OVERWRITE" > /workspace/pkm/zettelkasten/20_knowledge_kasten/atoms/test_atom.md
sudo config --target aiengineer bootstrap step run_pkm_reasoning_local_smoke
grep "DO NOT OVERWRITE" /workspace/pkm/zettelkasten/20_knowledge_kasten/atoms/test_atom.md
```

## Summary

Bundle 8 is the reasoning access layer.

It does not own the vault.
It does not own the research engine.
It does not own Agentfield yet.

Bundle 9:
owns PKM structure

Bundle 3/4/5:
produce research evidence

Bundle 8:
makes selected knowledge and evidence queryable

Layer 1:
provides model client contract

Agentfield later:
orchestrates reasoner profiles

Paperclip later:
exposes reasoning outputs to the user

## In one line

Bundle 8 lets OpenClaw and model reasoners safely ask useful questions over your research knowledge witho
