# Layer 5 — Platform Orchestration

**Product-owner version**

**Product goal:** turn the prepared research engine, search loops, remote execution, and reasoning tools into a managed experiment platform.

Layer 1 prepared runtime. Layer 2 prepared roles and workspaces. Layer 3 prepared scientific execution. Layer 4 prepared reasoning over knowledge and results. Layer 5 prepares the orchestration platform.

## Layer 5 answers

- Can I define a GRN/NCA/ART experiment as a structured object?
- Can a controller run the right repo command, track status, collect artifacts, handle failures, and resume or compare runs?
- Can Paperclip show the human-facing lifecycle of experiments, reports, candidate rankings, failures, and review actions?
- Can the full discovery system become repeatable instead of a collection of manual commands?

## Layer 5 boundary

### Layer 5 should do

- Define experiment objects.
- Define controller/runtime contracts.
- Orchestrate repo CLI commands.
- Track status and artifacts.
- Connect Agentfield to the NCA-ART-GRN research engine.
- Connect Paperclip to Agentfield status and actions.
- Prepare future GRN discovery platform workflows.

### Layer 5 should not do

- Not rewrite the research engine.
- Not replace config setup.
- Not replace the Zettelkasten.
- Not become the LaTeX publisher.
- Not hide scientific assumptions.
- Not treat final images as final success.
- Not launch uncontrolled remote jobs.
- Not bypass role/user/environment policy.

## Core rule

- `config` prepares the machine and roles.
- `nca-art-grn` owns scientific execution.
- OpenClaw reasons over selected context.
- Agentfield orchestrates experiments.
- Paperclip exposes the workflow to humans.

## Bundles inside Layer 5

- Bundle 11 — Agentfield experiment runtime foundation
- Bundle 12 — Paperclip-Agentfield adapter
- Bundle 13 — Agentic GRN discovery platform

## Layer 5 system relationship

### config

Prepares users, profiles, mounts, Python envs, packages, workspaces, manifests, folders, smoke commands, and safe runtime checks.

### nca-art-grn

Owns DSL, PDE/ODE simulator, NCA, ART2, ARTMAP, search, perturbation tests, reports, and CLI commands.

### OpenClaw / PKM reasoning

Summarizes reports, suggests next experiments, helps with paper/review context.

### Agentfield

Owns experiment objects, lifecycle, controller execution, state, retries, artifact tracking, status, and campaign orchestration.

### Paperclip-Agentfield adapter

Converts Paperclip jobs/actions into Agentfield experiment requests and converts Agentfield status/results back into Paperclip-visible objects.

### Paperclip

Owns the human-facing dashboard, inbox, approvals, review tasks, run overview, governance, and end-to-end visibility.

## Bundle 11 — Agentfield Experiment Runtime Foundation

### Product outcome

A minimal Agentfield runtime that can represent and execute one structured experiment.

This bundle is the first point where Agentfield becomes real.

It should define:

- GRNExperiment object
- Experiment spec schema
- Experiment status schema
- Controller loop
- Repo command runner
- Artifact collector
- Failure recorder
- Result summarizer
- Local/Runpod execution target

### Product value

Bundle 11 turns manual commands like:

```bash
python -m nca_art_grn.cli.run --config configs/experiments/smoke_nca_art_pipeline.yaml
```

into structured platform requests like:

```yaml
GRNExperiment:
  method: nca_art_pipeline
  target: local
  config: configs/experiments/smoke_nca_art_pipeline.yaml
  candidate_batch: ...
  expected_artifacts:
    - mechanism_report.md
    - pattern_dynamics.json
    - art2_prototypes.json
    - artmap_transitions.json
```

It does not own the science. It owns the lifecycle around the science.

### Concretizations

- `prepare_agentfield_runtime_workspace`
- `prepare_grn_experiment_schema`
- `prepare_experiment_status_schema`
- `prepare_agentfield_controller_skeleton`
- `prepare_repo_command_runner`
- `prepare_artifact_collector`
- `prepare_failure_status_runtime`
- `prepare_agentfield_local_smoke_config`
- `check_agentfield_runtime_ready`
- `run_agentfield_local_smoke`

### What this does for the whole system

- Bundle 3/4/5 provide executable research commands.
- Bundle 11 wraps those commands in experiment lifecycle state.
- Bundle 12 later exposes that lifecycle to Paperclip.
- Bundle 13 later uses it for larger autonomous GRN discovery workflows.

## Bundle 12 — Paperclip-Agentfield Adapter

### Product outcome

A bridge between the human-facing Paperclip workflow and Agentfield’s experiment runtime.

This bundle answers:

- Can Paperclip request an experiment without knowing all repo internals?
- Can Paperclip show whether an Agentfield experiment is queued, running, failed, or complete?
- Can Paperclip show links to mechanism reports, search reports, prototypes, transition graphs, figures, candidate DSL files, and failure reasons?
- Can a human approve, reject, retry, annotate, or escalate a run?

### Product value

This is the visibility and governance layer.

Agentfield can run experiments, but Paperclip makes them human-manageable:

```text
Paperclip job/action
  -> adapter
  -> Agentfield GRNExperiment
  -> nca-art-grn execution
  -> Agentfield status/results
  -> adapter
  -> Paperclip dashboard/review item
```

### Concretizations

- `prepare_paperclip_agentfield_adapter_workspace`
- `prepare_paperclip_job_schema`
- `prepare_agentfield_request_mapper`
- `prepare_agentfield_status_mapper`
- `prepare_artifact_link_mapper`
- `prepare_review_action_mapper`
- `prepare_adapter_smoke_fixtures`
- `check_paperclip_agentfield_adapter_ready`
- `run_paperclip_agentfield_adapter_smoke`

### What this does for the whole system

- Bundle 11 owns experiment execution state.
- Bundle 12 lets Paperclip request and review that state.
- Paperclip remains the dashboard.
- Agentfield remains the controller.
- `nca-art-grn` remains the scientific engine.

## Bundle 13 — Agentic GRN Discovery Platform

### Product outcome

A higher-level GRN discovery workflow that can coordinate candidate generation, mechanism testing, search, remote execution, reasoning, and review.

Bundle 13 is where the system becomes an integrated research platform rather than isolated tools.

It should coordinate:

- DSL candidate generation
- PDE/ODE simulation
- NCA training/evaluation
- ART2 prototype discovery
- ARTMAP transition learning
- Prototype-to-DSL mapping
- Parameter search comparison
- Robustness sweeps
- Perturbation design
- Runpod execution
- Mechanism reports
- Reasoning summaries
- Paperclip review tasks

### Product value

Bundle 13 turns the earlier bundles into campaigns:

- Generate candidate mechanisms.
- Evaluate mechanism dynamics.
- Train/test NCA local rules.
- Discover ART2 prototypes.
- Learn ARTMAP transitions.
- Map back to DSL.
- Run perturbation and robustness tests.
- Rank candidates.
- Suggest next experiments.
- Ask human to approve next campaign.

It should still obey the scientific guardrail:

```text
The goal is not pretty patterns.
The goal is mechanism evidence and experimental design.
```

### Concretizations

- `prepare_grn_discovery_campaign_schema`
- `prepare_candidate_generation_agent`
- `prepare_mechanism_evaluation_agent`
- `prepare_search_strategy_agent`
- `prepare_perturbation_design_agent`
- `prepare_artifact_review_agent`
- `prepare_next_experiment_agent`
- `prepare_human_review_gate`
- `prepare_campaign_state_store`
- `prepare_grn_discovery_campaign_smoke`
- Check GRN discovery platform ready.

### What this does for the whole system

- Bundle 3 supplies the core mechanism evaluation loop.
- Bundle 4 supplies search and comparison.
- Bundle 5 supplies remote execution.
- Bundle 8 supplies reasoning.
- Bundle 11 supplies Agentfield runtime.
- Bundle 12 supplies Paperclip visibility.
- Bundle 13 composes them into one discovery platform.

## Layer 5 role ownership

Layer 5 uses multiple roles, but each role has a clear responsibility.

### operator / vmuser

Runs config bootstrap/check/smoke steps and manages system-level readiness and safe execution.

### aiengineer

Develops Agentfield, adapter, controller, schemas, and platform logic.

### researchscientist

Owns the scientific configs, experiment meaning, candidate interpretation, and mechanism validity.

### publisher

Later consumes reviewed reports and summaries for notes and papers.

### Key split

- AI Engineer builds the orchestration platform.
- Research Scientist defines what counts as scientific evidence.
- Operator keeps execution safe and repeatable.
- Publisher turns reviewed evidence into knowledge and papers.

## Layer 5 success condition

After Layer 5, you should be able to say:

- I can define a GRN experiment as structured data.
- Agentfield can execute it through the `nca-art-grn` repo.
- The run has status, artifacts, failure reasons, and reports.
- Paperclip can show the run to a human.
- A human can review outputs and approve next actions.
- A larger GRN discovery campaign can be composed from smaller tested pieces.

### In one line

Layer 5 turns the prepared research engine into a managed, reviewable, agent-orchestrated discovery platform.

## Layer 5 acceptance themes

Layer 5 is acceptable only if:

- Agentfield calls existing repo commands instead of duplicating science code.
- Paperclip displays experiment lifecycle instead of becoming the controller.
- Config remains responsible for setup, roles, envs, and safe bootstrap.
- Research artifacts remain under `/workspace/runs` and `/workspace/artifacts`.
- Mechanism reports remain central outputs.
- Human review gates exist before expensive or publication-relevant actions.
- Final pattern similarity is never treated as sufficient evidence.

## Layer 5 final product view

### Before Layer 5

You have prepared tools, repos, configs, reports, and reasoning workflows.

### After Layer 5

You have a platform that can coordinate those pieces as experiments and campaigns.

## Platform stack

### config

Machine + role + environment + workspace readiness.

### nca-art-grn

Scientific mechanism engine.

### OpenClaw / PKM

Reasoning and knowledge layer.

### Agentfield

Experiment orchestration layer.

### Paperclip adapter

Integration layer.

### Paperclip

Human-facing control and review layer.
