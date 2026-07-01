# Bundle 5 — Runpod training / inference / campaign execution loop

## Scrum-master view

Bundle objective: prepare the remote execution layer for expensive NCA-ART-GRN research runs.

Bundle 3 prepared the single-candidate mechanism loop.
Bundle 4 prepared search and comparison tools.
Bundle 5 prepares the same work to run safely on Runpod or other remote compute.

This bundle does not invent new science. It scales the science from Bundles 3 and 4.

Bundle 3
evaluates one candidate mechanism deeply

Bundle 4
compares many candidates and search methods

Bundle 5
moves expensive candidate batches, NCA training, ART2/ARTMAP discovery,
perturbation sweeps, and result return onto remote compute

The scientific guardrail stays the same:

A remote run is not successful because it made a nice image.
A remote run is successful if it returns inspectable mechanism evidence:
dynamics metrics
NCA agreement
ART2 prototypes
ARTMAP transitions
perturbation response
DSL artifacts
mechanism reports

This stays aligned with Hiscock/Megason: final pattern similarity alone is weak evidence; runs should preserve dynamics, perturbation responses,
parameter constraints, and mechanism-discrimination information.

## Where this bundle sits in the platform

Bundle 5 is still mostly config-managed runtime preparation, plus tiny execution smoke tests.

config
prepares Runpod workspace paths, job layouts, checkpoint policy,
result-return policy, and smoke commands

nca-art-grn repo
owns training/evaluation/search CLI code

```text
/workspace
```
stores inputs, runs, artifacts, checkpoints, models

Runpod
executes expensive jobs

Agentfield later
schedules Runpod-backed experiments/campaigns

Paperclip later
shows job status, costs, artifacts, and review reports

These are not Agentfield controller steps yet. They are the Runpod execution foundation that Agentfield will later call.

## User story

As the Research Scientist / Operator,
I want a prepared Runpod execution loop for NCA-ART-GRN experiments,
so that candidate batches, NCA training, ART2/ARTMAP discovery, perturbation sweeps,
and mechanism reports can run remotely, return results safely, and remain comparable
with local smoke runs.

## Concretizations / managed steps

### prepare_runpod_training_workspace

### prepare_runpod_inference_workspace

### prepare_candidate_batch_layout

### prepare_training_run_layout

### prepare_checkpoint_policy

### prepare_result_return_policy

### prepare_remote_run_manifest_schema

### prepare_runpod_job_templates

### prepare_runpod_nca_training_configs

### prepare_runpod_art_discovery_configs

### prepare_runpod_search_campaign_configs

### prepare_runpod_mechanism_report_configs

### check_runpod_training_ready

### run_runpod_local_dryrun_smoke

Optional later:

### submit_runpod_training_job

### pull_runpod_results

### resume_runpod_checkpoint

Those should be explicit later commands, not automatic prepare steps.

## Step type legend

### CONFIG STEP

Managed bootstrap/check/smoke step invoked by config.

### REPO CODE

Python modules, CLIs, configs, tests, scripts inside nca-art-grn.

### REMOTE EXECUTION

Runpod job or container execution.

### RESEARCH OUTPUT

Candidate batches, run outputs, checkpoints, artifacts, reports.

### AGENTFIELD LATER

Future orchestration layer; not implemented in this bundle.

## What each step should do

### prepare_runpod_training_workspace

Type: CONFIG STEP
Owner: config prepares remote-training paths.
Target role: usually researchscientist .

Creates shared paths:

```text
/workspace/runs/nca-art-grn/runpod/
/workspace/checkpoints/nca-art-grn/
/workspace/models/nca-art-grn/
```

```text
/workspace/artifacts/nca-art-grn/runpod/
/    k      /l    /        t     /       d/
```
What this does for the research:
Gives expensive NCA training and large simulation/search runs a stable place to write outputs without polluting the repo.

How it links into the platform:

config prepares paths
repo training CLI writes there
Runpod mounts /workspace
Agentfield later stores these paths in experiment status
Paperclip later displays returned run artifacts

### prepare_runpod_inference_workspace

Type: CONFIG STEP
Creates paths for remote evaluation/inference:

```text
/workspace/runs/nca-art-grn/inference/
/workspace/artifacts/nca-art-grn/inference/
/workspace/models/nca-art-grn/served/
/workspace/data/nca-art-grn/inference_inputs/
```

What this does for the research:
Separates long training from later evaluation/inference. For example, after an NCA model is trained, you can run rollout evaluation, perturbation
replay, ART2 prototype extraction, or candidate scoring as separate jobs.

How it links into the platform:

trained model checkpoint -> inference workspace
inference run -> dynamics/prototype/transition artifacts

Agentfield later can schedule inference only experiments

### prepare_candidate_batch_layout

Type: CONFIG STEP
Creates research input layout:

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
```
created_by
candidate_count
source_search_method
mechanism_hypothesis_ids
simulation_budget
nca_budget

art2_settings
artmap_settings
perturbation_plan
expected outputs

What this does for the research:
Lets you send a controlled set of DSL candidates to remote compute. This keeps remote jobs traceable to search method, mechanism hypothesis,
and perturbation plan.

How it links into the platform:

Bundle 4 produces ranked/search candidates
candidate_batch_layout packages them
Runpod evaluates batch
results return to /workspace/runs and /workspace/artifacts
Agentfield later treats batch_manifest as experiment input

### prepare_training_run_layout

Type: CONFIG STEP
Creates standard run directory schema:

```text
/workspace/runs/nca-art-grn/runpod/<run_id>/
```
### run_manifest.yaml

```text
environment.json
```
command.txt
```text
inputs/
logs/
checkpoints/
outputs/
artifacts/
reports/
status.json
```

```text
run_manifest.yaml must encode:
```

### run_id

```text
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

What this does for the research:
Makes remote runs reproducible and auditable. A run is not just “something happened on Runpod”; it becomes a structured scientific execution
record.

How it links into the platform:

config creates run layout
repo writes outputs into run layout
Agentfield later maps run_manifest to experiment status
Paperclip later displays run lifecycle and failure reason

### prepare_checkpoint_policy

Type: CONFIG STEP
Creates policy/config files:

```text
configs/runpod/checkpoint_policy.yaml
/workspace/checkpoints/nca-art-grn/README.md
```

Policy must encode:

checkpoint frequency
checkpoint naming
keep-last-N policy
best-model policy
resume policy
failed-run recovery policy
large-file handling
model artifact promotion rules

What this does for the research:
Protects expensive NCA training and long evaluations from being lost. It also prevents uncontrolled checkpoint sprawl.

How it links into the platform:

NCA training writes checkpoints
inference jobs consume promoted checkpoints
Agentfield later resumes failed jobs
Paperclip later exposes checkpoint status

### prepare_result_return_policy

Type: CONFIG STEP
Creates policy/config files:

```text
configs/runpod/result_return_policy.yaml
/workspace/artifacts/nca-art-grn/result_return/README.md
```

Policy must specify which outputs are returned/promoted:

```text
metadata.json
```
### run_manifest.yaml

```text
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

It should avoid returning uncontrolled huge files by default.

What this does for the research:
Ensures that remote results are useful for science, not just raw dumped files. The key returned artifact is the mechanism evidence trail.

How it links into the platform:

Runpod writes outputs
result_return_policy selects important artifacts
Bundle 9 can turn reports into notes
Bundle 10 can use figures/tables/reports
Paperclip later shows selected outputs

### prepare_remote_run_manifest_schema

Type: CONFIG STEP
Creates/validates repo schema:

```text
src/nca_art_grn/runs/remote_manifest.py
configs/runpod/remote_run_manifest_schema.yaml
```

Schema must include:

### run_id

### run_kind

candidate_batch_id
mechanism_hypothesis_ids
search_method
nca_training_mode
art2_mode
artmap_mode
perturbation_plan_id
```text
input_paths
output_paths
```
checkpoint_policy
result_return_policy
cost_limit
expected_artifacts

What this does for the research:
Makes local, Runpod, and later Agentfield runs speak the same language.

How it links into the platform:

config writes manifest
repo CLI reads manifest

Runpod executes manifest
Agentfield later creates manifest from GRNExperiment spec
Paperclip later shows manifest summary

### prepare_runpod_job_templates

Type: CONFIG STEP
Creates scripts/templates:

```text
scripts/runpod/run_batch.sh
scripts/runpod/run_nca_training.sh
scripts/runpod/run_art_discovery.sh
scripts/runpod/run_search_campaign.sh
scripts/runpod/collect_results.sh
configs/runpod/job_templates/
```

Each template must define:

working directory
environment activation
input manifest path
output directory
logging path
failure trap
exit code handling
result collection

What this does for the research:
Provides repeatable remote commands without having to remember ad hoc shell incantations.

How it links into the platform:

operator can run template manually
config can dry-run template
Agentfield later calls same template from controller
Paperclip later displays template/job kind

### prepare_runpod_nca_training_configs

Type: CONFIG STEP
Creates configs:

```text
configs/runpod/nca_training_small.yaml
configs/runpod/nca_training_medium.yaml
configs/runpod/nca_training_resume.yaml
```

Config must encode:

dataset path
candidate batch path
model config
loss config
training steps
checkpoint interval
validation interval
rollout length
perturbation validation
device policy

What this does for the research:
Lets NCA training scale from tiny local smoke to real remote training while preserving the same data contract from Bundle 3.

How it links into the platform:

PDE/ODE-to-NCA datasets -> NCA training config
training -> checkpoints
checkpoints -> inference workspace
Agentfield later schedules NCA training experiments

### prepare_runpod_art_discovery_configs

Type: CONFIG STEP
Creates configs:

```text
configs/runpod/art2_discovery_batch.yaml
configs/runpod/artmap_transition_batch.yaml
configs/runpod/prototype_to_dsl_batch.yaml
```

Config must encode:

input trajectory paths
NCA rollout paths
ART2 vigilance settings
ARTMAP mapping settings
prototype store target
transition graph target
mechanism report target

What this does for the research:
Lets ART2 and ARTMAP run on larger trajectory collections than local smoke can handle.

How it links into the platform:

remote simulator/NCA outputs -> ART2/ARTMAP batch
ART2/ARTMAP -> prototypes and transitions

prototype_to_dsl -> DSL artifacts
h      i      t   >     i   /         i   li

### prepare_runpod_search_campaign_configs

Type: CONFIG STEP
Creates configs:

```text
configs/runpod/search_random_grid_campaign.yaml
configs/runpod/search_lhs_campaign.yaml
configs/runpod/search_evolutionary_campaign.yaml
configs/runpod/search_bayesian_campaign.yaml
configs/runpod/search_active_learning_campaign.yaml
```

Config must encode:

search method
candidate budget
remote batch size
simulation budget per candidate
NCA evaluation budget
ART2/ARTMAP evaluation budget
perturbation budget
checkpoint policy
result return policy
cost guardrails

What this does for the research:
Moves Bundle 4’s search comparison from toy local smoke into actual remote campaigns.

How it links into the platform:

Bundle 4 search config -> Runpod campaign config
Runpod campaign -> ranked candidates and reports

Agentfield later tracks campaign phase/status
Paperclip later enables human review of campaign outputs

### prepare_runpod_mechanism_report_configs

Type: CONFIG STEP
Creates configs/templates:

```text
configs/runpod/mechanism_report_batch.yaml
configs/reports/runpod_mechanism_report_template.md
```

Report must summarize:

candidate batch
best candidates
failed candidates
dynamics evidence
NCA agreement
ART2 prototype evidence
ARTMAP transition evidence
perturbation evidence
DSL mapping evidence
experimental design suggestions
cost/runtime summary

What this does for the research:
Ensures remote campaigns return science-ready interpretation, not just raw logs.

How it links into the platform:

remote outputs -> mechanism reports
reports -> Bundle 9 alloy notes

reports -> Bundle 10 paper sections
reports -> Agentfield status artifact
reports -> Paperclip review item

### check_runpod_training_ready

Type: CONFIG CHECK STEP
Runs: no training, no Runpod launch.

Should report:

workspace paths exist
repo exists
Python env exists
GPU visible if on Runpod
CUDA/Torch ready
candidate batch path exists
checkpoint path exists
result return path exists
runpod configs exist
job templates exist
required package imports available
remote model/client env optional status

What this does for the research:
Prevents expensive failed remote jobs caused by missing paths, packages, configs, or GPU visibility.

How it links into the platform:

operator runs check
researchscientist fixes missing pieces
Agentfield later runs preflight before scheduling remote job

### run_runpod_local_dryrun_smoke

Type: CONFIG SMOKE STEP
Runs: local dry-run only; no paid remote launch.

Should do:

create fake run_id
load tiny remote manifest
validate candidate batch manifest
validate job template command
validate output directories
```text
write dryrun status.json
```
write dryrun report

Output:

```text
/workspace/runs/nca-art-grn/runpod/dryrun/<timestamp>/
```
### run_manifest.yaml

command.txt
```text
status.json
dryrun_report.md
```

What this does for the research:
Confirms the Runpod execution contract without spending money or launching a job.

How it links into the platform:

today:
config validates remote-run shape

later:
submit_runpod_training_job uses same manifest

later:

## Whole-system linkage

Bundle 5 is the bridge from local research engine to remote execution.

Bundle 3
defines and evaluates mechanism candidates

Bundle 4
chooses candidate/search campaigns

Bundle 5
executes those campaigns remotely and returns structured evidence

Bundle 11 later
Agentfield controls experiment lifecycle

Bundle 12 later
Paperclip-Agentfield adapter exposes that lifecycle to Paperclip

Paperclip later
shows remote job status, artifacts, reports, and review actions

## Concrete later flow:

config today:
```text
sudo config --target researchscientist bootstrap step run_runpod_local_dryrun_smoke
```

manual repo command:
```text
python -m nca_art_grn.cli.remote_dryrun \
--manifest /workspace/runs/nca-art-grn/runpod/dryrun/<id>/run_manifest.yaml
```

future Agentfield:
GRNExperiment.spec.execution.target = runpod
GRNExperiment.spec.method = nca_art_pipeline | parameter_search | nca_training
```text
controller writes run_manifest.yaml
```
controller launches Runpod job
status points to /workspace/runs/nca-art-grn/runpod/<run_id>

future Paperclip:
displays queued/running/failed/completed
links mechanism_report.md, search_report.md, prototypes, figures, checkpoints

Acceptance criteria
The following should become valid:

```text
sudo config --target researchscientist bootstrap step prepare_runpod_training_workspace
sudo config --target researchscientist bootstrap step prepare_runpod_inference_workspace
sudo config --target researchscientist bootstrap step prepare_candidate_batch_layout
sudo config --target researchscientist bootstrap step prepare_training_run_layout
sudo config --target researchscientist bootstrap step prepare_checkpoint_policy
sudo config --target researchscientist bootstrap step prepare_result_return_policy
sudo config --target researchscientist bootstrap step prepare_remote_run_manifest_schema
sudo config --target researchscientist bootstrap step prepare_runpod_job_templates
sudo config --target researchscientist bootstrap step prepare_runpod_nca_training_configs
sudo config --target researchscientist bootstrap step prepare_runpod_art_discovery_configs
sudo config --target researchscientist bootstrap step prepare_runpod_search_campaign_configs
sudo config --target researchscientist bootstrap step prepare_runpod_mechanism_report_configs
sudo config --target researchscientist bootstrap step check_runpod_training_ready
```

Explicit dry-run:

```text
sudo config --target researchscientist bootstrap step run_runpod_local_dryrun_smoke
```

Prepare/check steps must:

not launch Runpod jobs
not train models
not run real campaigns
not overwrite checkpoints
not overwrite completed runs
not print secrets
not upload private data automatically
not delete remote results

Dry-run step must:

validate manifests
validate paths
validate command templates
write dryrun report
clearly label outputs as dryrun
not use GPU
not call paid remote APIs
not submit jobs

Proposed tests
Registry and syntax tests

```text
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
```

config bootstrap steps | grep prepare_runpod_training_workspace
config bootstrap steps | grep prepare_candidate_batch_layout
config bootstrap steps | grep prepare_checkpoint_policy
config bootstrap steps | grep prepare_result_return_policy
config bootstrap steps | grep prepare_runpod_job_templates
config bootstrap steps | grep check runpod training ready

Workspace structure tests

```text
sudo config --target researchscientist bootstrap step prepare_runpod_training_workspace
sudo config --target researchscientist bootstrap step prepare_runpod_inference_workspace
```

```text
test -d /workspace/runs/nca-art-grn/runpod
test -d /workspace/checkpoints/nca-art-grn
test -d /workspace/models/nca-art-grn
test -d /workspace/artifacts/nca-art-grn/runpod
```

Candidate batch tests

```text
sudo config --target researchscientist bootstrap step prepare_candidate_batch_layout
```

```text
test -d /workspace/data/nca-art-grn/candidate_batches/pending
test -d /workspace/data/nca-art-grn/candidate_batches/active
test -d /workspace/data/nca-art-grn/candidate_batches/completed
test -d /workspace/data/nca-art-grn/candidate_batches/failed
```

Policy tests

```text
sudo config --target researchscientist bootstrap step prepare_checkpoint_policy
sudo config --target researchscientist bootstrap step prepare_result_return_policy
```

```text
test -f /workspace/repos/nca-art-grn/configs/runpod/checkpoint_policy.yaml
test -f /workspace/repos/nca-art-grn/configs/runpod/result_return_policy.yaml
```

Job template tests

```text
sudo config --target researchscientist bootstrap step prepare_runpod_job_templates
```

```text
test -f /workspace/repos/nca-art-grn/scripts/runpod/run_batch.sh
test -f /workspace/repos/nca-art-grn/scripts/runpod/run_nca_training.sh
test -f /workspace/repos/nca-art-grn/scripts/runpod/run_art_discovery.sh
test -f /workspace/repos/nca-art-grn/scripts/runpod/run_search_campaign.sh
```

```text
bash --noprofile --norc -n /workspace/repos/nca-art-grn/scripts/runpod/run_batch.sh
bash --noprofile --norc -n /workspace/repos/nca-art-grn/scripts/runpod/run_nca_training.sh
```

Readiness check

```text
sudo config --target researchscientist bootstrap step check_runpod_training_ready
```

Expected: readiness report only, no job launch.

Local dry-run smoke

```text
sudo config --target researchscientist bootstrap step run_runpod_local_dryrun_smoke
```

```text
find /workspace/runs/nca-art-grn/runpod/dryrun -name run_manifest.yaml | tail -n 1
find /workspace/runs/nca-art-grn/runpod/dryrun -name status.json | tail -n 1
find /workspace/runs/nca-art-grn/runpod/dryrun -name dryrun_report.md | tail -n 1
```

### Scientific output-contract test

The result-return policy must include:

```text
candidate DSL files
pattern_dynamics.json
nca_summary.json
art2_prototypes.json
artmap_transitions.json
perturbation_summary.json
mechanism_report.md
search_report.md
```

### Non-overwrite checkpoint test

```text
mkdir -p /workspace/checkpoints/nca-art-grn/test_checkpoint
echo "DO NOT OVERWRITE" > /workspace/checkpoints/nca-art-grn/test_checkpoint/marker.txt
sudo config --target researchscientist bootstrap step prepare_checkpoint_policy
grep "DO NOT OVERWRITE" /workspace/checkpoints/nca-art-grn/test_checkpoint/marker.txt
```

## Summary

Bundle 5 is the remote execution and result-return layer.

It does not replace Bundle 3 or 4.

Bundle 3:
makes one mechanism-evaluation loop executable

Bundle 4:
makes many candidates/search methods comparable

Bundle 5:
makes expensive versions run remotely and return structured evidence

Scientifically, it must return:

not just images,
but candidate DSL,
dynamics metrics,
NCA summaries,
ART2 prototypes,
ARTMAP transitions,
perturbation results,
mechanism reports,
search reports,
figures,
tables,
and failure reasons.

Platform-wise:

config prepares remote execution contracts
nca-art-grn owns the executable research code
```text
/workspace stores all remote inputs/outputs
```
Agentfield later schedules these jobs
Paperclip later lets you review them
