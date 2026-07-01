# SPEC_Layer05_platform_orchestration

## Purpose

Layer 5 is the platform-orchestration layer for the Infra-Skeleton / Agentfield GRN platform. It turns the lower-layer runtime, role workstations, research execution loops, and knowledge/reasoning tools into a managed, inspectable, reviewable experiment platform.

This layer is not a replacement for the science engine, the PKM/reasoning layer, the config tool, or Paperclip itself. It is the orchestration layer that coordinates experiment intent, controller flow, status tracking, artifact references, human review payloads, and eventually campaign-level GRN discovery workflows.

## Product goal

Build the managed experiment control plane for GRN/NCA/ART discovery.

Layer 5 should make it possible to:

- submit a structured GRN experiment intent,
- have Agentfield resolve and execute a sequence of controlled stages,
- track experiment status, selected agents, stage results, artifacts, reports, failures, and review requirements,
- let Paperclip request experiments and display human-facing status without knowing Agentfield internals,
- coordinate campaign-level discovery work across candidate generation, mechanism evaluation, search strategy, perturbation design, evidence review, next-experiment suggestion, and human review gates.

The skeleton pass builds the nervous system first with fake/minimal organs. The transition-to-real-organs pass replaces dummy internals while preserving public output contracts unless a deliberate versioned migration is created.

## Product meaning

Layer 5 is where the platform becomes more than a collection of manual commands.

Earlier layers provide prerequisites:

- **Layer 1** gives runtime roots, safe runtime checks, RunPod/remote model boundaries, and remote-model client contracts.
- **Layer 2** gives role workstations, especially the AI Engineer workspace for Agentfield/adapter development and the Research Scientist workspace for `nca-art-grn` outputs.
- **Layer 3** gives the research execution engine: DSL candidates, PDE/ODE simulator, NCA, ART2, ARTMAP, search, perturbation, mechanism reports, and local smoke artifacts.
- **Layer 4** gives OpenClaw/PKM reasoning, report ingestion, next-experiment reasoning, failure triage, and paper/review context.

Layer 5 composes those pieces into controlled orchestration:

```text
config
  -> prepares roles, envs, repos, mounts, package policy, safe checks

nca-art-grn
  -> owns scientific execution and artifacts

OpenClaw / PKM reasoning
  -> reasons over selected context and reports

Agentfield
  -> owns experiment/campaign intent, controller flow, stage selection, status, artifact refs, and lifecycle state

Paperclip-Agentfield adapter
  -> maps Paperclip jobs/actions to Agentfield requests and maps status/results back to Paperclip-visible objects

Paperclip
  -> owns the human-facing dashboard, inbox, approvals, governance, review actions, and visibility
```

The core Layer 5 rule is:

```text
config prepares the environment.
nca-art-grn owns the science.
OpenClaw / PKM reasons over selected context.
Agentfield orchestrates experiments and campaigns.
Paperclip-Agentfield adapter translates between Paperclip and Agentfield.
Paperclip exposes the workflow to humans.
```

## Layer answers

Layer 5 answers:

- Can a GRN/NCA/ART experiment be represented as a structured object instead of a loose prompt or shell command?
- Can Agentfield run an experiment-aware controller that resolves stages, invokes registered agents/reasoners, passes context forward, and accumulates status/results?
- Can the controller track status, selected agents, execution references, artifact references, report references, failure reasons, and human-review requirements?
- Can Paperclip request an experiment without knowing all Agentfield or `nca-art-grn` internals?
- Can Paperclip show queued/running/failed/completed/review-required status, stage summaries, artifact links, failure reasons, and review actions?
- Can a controlled campaign generate/evaluate/rank GRN candidates and propose next experiments while preserving mechanism evidence and human review gates?
- Can the platform remain repeatable, auditable, dry-run safe, and compatible with later real organs?

## Layer boundary

### Should do

Layer 5 should:

- define Agentfield experiment intent objects,
- define experiment status and result contracts,
- preserve the working Agentfield GRN POC pattern as the starting point,
- split the POC into schemas, controller, registry, invoker, reasoners, fixtures, and smoke docs only after preserving behavior,
- prepare Agentfield-to-`nca-art-grn` bridge stubs,
- map research artifacts into Agentfield status fields,
- prepare Paperclip-Agentfield adapter schemas, clients, mappers, review actions, config profiles, and smoke fixtures,
- prepare campaign schemas, status schemas, state stores, stage registries, agents, review gates, artifact collectors, Paperclip payload mapping, smoke fixtures, and guarded live stubs,
- preserve skeleton output contracts for later real-organ replacement,
- keep all live Agentfield, Paperclip, RunPod, model-provider, Kubernetes, and Terraform behavior guarded and disabled by default.

### Should not do

Layer 5 should not:

- rewrite `nca-art-grn` scientific internals,
- replace `config` role/environment setup,
- hide scientific assumptions inside orchestration,
- treat final images or pretty outputs as proof of mechanism,
- launch uncontrolled remote jobs,
- write to live Paperclip databases or APIs by default,
- call live model/provider APIs by default,
- run real RunPod jobs by default,
- mutate Kubernetes or Terraform state,
- bypass role/user/environment policy,
- create one global smoke module per batch,
- edit config internals during skeleton or organ implementation batches.

## Bundles in this layer

Layer 5 contains three product bundles:

| Bundle | Name | Skeleton batches | Main product outcome |
|---:|---|---|---|
| 11 | Agentfield experiment-aware controller foundation | 16–18 | Agentfield-native experiment POC, schemas/status, controller entrypoint, registry, invoker, reasoners, fixtures, hardening stubs. |
| 12 | Paperclip-Agentfield adapter | 19–20 | Adapter workspace, job schema, Agentfield client, request/status/artifact mappers, review actions, profiles, fixtures, dry-run smoke, guarded live smoke. |
| 13 | Agentic GRN discovery platform | 21–24 | Campaign schema/status/state, stage registry, campaign agents, review gate, artifact collector, Paperclip payload mapper, local smoke, guarded RunPod/async/retry/comparison/live-submit stubs. |

## Key concretizations

### Bundle 11 — Agentfield experiment-aware controller foundation

#### Updated product decision

Bundle 11 is now the Agentfield-native experiment-aware controller foundation.

It is not the older generic Kubernetes-style CRD operator, and it is not only a shell wrapper around `nca-art-grn` commands. The current direction is to preserve the developer’s working Agentfield POC pattern:

```text
Agentfield Agent node
  -> run_experiment entrypoint
  -> deterministic stage resolver
  -> stage reasoners
  -> accumulated status/results
  -> Agentfield UI DAG/call graph
```

The skeleton must preserve the POC as a seed, then harden it toward the real NCA-ART-GRN architecture.

#### Product outcome

A structured Agentfield workspace that can run a GRN experiment-aware POC using:

- `GRNExperimentSpec`,
- `StageResult`,
- `GRNExperimentStatus`,
- a controller entrypoint,
- a deterministic stage resolver,
- an agent registry,
- a reasoner invoker,
- five initial GRN exploration reasoners,
- NCA-ART-GRN future review stubs,
- execute fixtures,
- local smoke docs and guarded live smoke pathways.

#### Initial POC fields to preserve

The initial GRN POC fixture uses:

```json
{
  "input": {
    "name": "GRN Discovery in Human Cortex",
    "description": "Identify key transcription factor regulatory networks in human cortical development using scRNA-seq data",
    "dataset_ref": "GSE123456_cortex_scrna",
    "organism": "human",
    "method_flags": ["pca", "correlation", "perturbation"]
  }
}
```

The NCA-ART-GRN smoke fixture extends that shape:

```json
{
  "input": {
    "name": "NCA-ART-GRN Mechanism Smoke",
    "description": "Evaluate one DSL-defined 5-node GRN mechanism using simulator, NCA, ART2, ARTMAP and perturbation evidence.",
    "dataset_ref": "/workspace/runs/nca-art-grn/smoke/latest",
    "organism": "synthetic",
    "method_flags": ["dsl", "nca", "art2", "artmap", "perturbation", "hypothesis_ranking"],
    "research_mode": "nca_art_grn_smoke"
  }
}
```

#### Bundle 11 skeleton steps

Batch 16, 17, and 18 implement Bundle 11 in the corrected skeleton slicing.

| Step | Type | Batch | Target role | Output contract |
|---|---|---:|---|---|
| `prepare_agentfield_runtime_workspace` | setup | 16 | `aiengineer` | `/workspace/repos/agentfield` with `agentfield_grn/{schemas,controllers,registry,reasoners,invokers,fixtures,cli}`, configs, smoke_tests, runs. |
| `prepare_agentfield_sdk_environment` | package policy | 16 | `aiengineer` | Dry-run/import-check contract for Agentfield SDK, pydantic, httpx/requests, dotenv, pyyaml, rich. |
| `prepare_grn_experiment_poc_import` | template | 16 | `aiengineer` | Preserve current `grn_experiment.py` POC seed inside the Agentfield repo. |
| `prepare_grn_experiment_spec_schema` | schema | 16 | `aiengineer` | `GRNExperiment` spec with POC fields plus future research fields. |
| `prepare_grn_experiment_status_schema` | schema | 16 | `aiengineer` | Status with phase, selected_agents, stage_results, execution_refs, artifact_refs, report_refs, failure_reason, final_summary, human_review_required. |
| `prepare_experiment_aware_controller_entrypoint` | template | 16 | `aiengineer` | `run_experiment` controller preserving stage resolver/invoker/status pattern. |
| `prepare_agent_registry_runtime` | template | 17 | `aiengineer` | Registry for POC stages and future NCA-ART review stages. |
| `prepare_reasoner_invoker_runtime` | template | 17 | `aiengineer` | Invoker helper passing prior context, collecting `StageResult`, catching reasoner errors. |
| `prepare_grn_exploration_reasoners` | dummy reasoner | 17 | `aiengineer` | Five POC reasoners plus NCA-ART-GRN review stubs returning `StageResult`. |
| `prepare_grn_experiment_execute_fixtures` | template | 17 | `aiengineer` | `grn_discovery_human_cortex.json` and `nca_art_mechanism_smoke.json`. |
| `prepare_agentfield_server_smoke_docs` | template | 17 | `aiengineer` | Runbook for `af server`, env vars, sync/async execute; no key printing. |
| `check_agentfield_runtime_ready` | check | 17 | `aiengineer` | Non-live readiness report for workspace, SDK import, POC module, schemas, entrypoint, fixtures, env presence. |
| `run_agentfield_grn_poc_local_smoke` | smoke | 17 | `aiengineer` | Dry-run fixture validation, resolved stages, selected_agents, status output. |
| `prepare_grn_experiment_repo_split` | template | 18 | `aiengineer` | Repo split contract preserving POC behavior while separating schemas/controller/registry/reasoners/invoker. |
| `prepare_agentfield_nca_art_bridge` | template | 18 | `aiengineer` | Bridge stubs from Agentfield stages to `nca-art-grn` dummy CLI/artifacts. |
| `prepare_agentfield_artifact_status_mapping` | template | 18 | `aiengineer` | Artifact filename to status-field mapping. |
| `prepare_agentfield_mechanism_report_status` | template | 18 | `aiengineer` | Mechanism report path/summary to `status.report_refs` and `StageResult`. |
| `prepare_agentfield_runpod_target_stub` | template | 18 | `aiengineer` | Reserved RunPod execution target that refuses live execution in skeleton. |

#### Stage registry direction

The POC registry keeps:

```text
data_profiling -> profile_data
dimensionality_reduction -> reduce_dimensions
candidate_regulators -> find_candidate_regulators
perturbation_planning -> plan_perturbations
hypothesis_ranking -> rank_hypotheses
```

Future NCA-ART-GRN stages should be prepared but not treated as real science in the skeleton:

```text
dsl_candidate_review -> review_dsl_candidate
mechanism_hypothesis_review -> review_mechanism_hypothesis
nca_art_evidence_review -> review_nca_art_evidence
art2_prototype_review -> review_art2_prototypes
artmap_transition_review -> review_artmap_transitions
mechanism_report_review -> review_mechanism_report
```

### Bundle 12 — Paperclip-Agentfield adapter

#### Product outcome

Bundle 12 creates the bridge between Paperclip as the human-facing workflow/dashboard and Agentfield as the experiment-aware controller.

It answers:

- Can Paperclip request a GRN experiment without knowing Agentfield internals?
- Can Paperclip display Agentfield experiment status, selected agents, stage results, artifact refs, failures, and review-needed states?
- Can a human approve, reject, retry, annotate, or escalate experiment outputs from Paperclip?
- Can Paperclip eventually launch NCA-ART-GRN mechanism-discovery work through Agentfield without becoming the controller itself?

The core adapter flow is:

```text
Paperclip job/action
  -> Paperclip-Agentfield adapter
  -> Agentfield execute request
  -> Agentfield experiment status/results
  -> adapter mapping
  -> Paperclip experiment card / review item
```

#### Agentfield execute shape

The initial Agentfield execute endpoint shape is:

```http
POST /api/v1/execute/grn-experiment.run_experiment
```

with a body like:

```json
{
  "input": {
    "name": "GRN Discovery in Human Cortex",
    "description": "Identify key transcription factor regulatory networks in human cortical development using scRNA-seq data",
    "dataset_ref": "GSE123456_cortex_scrna",
    "organism": "human",
    "method_flags": ["pca", "correlation", "perturbation"]
  }
}
```

A corresponding Paperclip-side job fixture is:

```json
{
  "job_id": "pc-grn-poc-001",
  "title": "GRN Discovery in Human Cortex",
  "description": "Identify key transcription factor regulatory networks in human cortical development using scRNA-seq data",
  "job_type": "grn_experiment_poc",
  "dataset_ref": "GSE123456_cortex_scrna",
  "organism": "human",
  "method_flags": ["pca", "correlation", "perturbation"],
  "review_policy": "human_required"
}
```

#### Bundle 12 skeleton steps

Batch 19 and 20 implement Bundle 12 in the corrected skeleton slicing.

| Step | Type | Batch | Target role | Output contract |
|---|---|---:|---|---|
| `prepare_paperclip_agentfield_adapter_workspace` | setup | 19 | `aiengineer` | `/workspace/repos/paperclip-agentfield-adapter` with schemas, clients, mappers, review, artifacts, cli, configs, fixtures, smoke_tests, runs. |
| `prepare_paperclip_job_schema` | schema | 19 | `aiengineer` | Job schema with job_id, title, description, job_type, requested_by, dataset_ref, organism, intent, method_flags, research_mode, candidate refs, review_policy, priority. |
| `prepare_agentfield_execute_client` | adapter | 19 | `aiengineer` | Client builds sync/async execute URLs and supports mock response; no live call by default. |
| `prepare_agentfield_request_mapper` | adapter | 19 | `aiengineer` | Maps Paperclip job fields to Agentfield input fields and passes future research fields through. |
| `prepare_agentfield_status_mapper` | adapter | 19 | `aiengineer` | Maps Agentfield phase/selected_agents/stage_results/final_summary to Paperclip status/card fields. |
| `prepare_artifact_link_mapper` | adapter | 20 | `aiengineer` | Maps stage summaries, execution id, DAG/UI link, and future research artifacts into displayable artifact links. |
| `prepare_review_action_mapper` | adapter | 20 | `aiengineer` | Defines review actions such as approve, reject, retry, request_more_evidence, promote, queue_next_experiment, classify failure. |
| `prepare_adapter_config_profiles` | template | 20 | `aiengineer` | `local_dev`, `agentfield_poc`, `nca_art_grn_dev`, `paperclip_mock` profiles. |
| `prepare_adapter_smoke_fixtures` | template | 20 | `aiengineer` | Paperclip job fixtures and Agentfield response fixtures. |
| `prepare_adapter_cli_smoke_commands` | template | 20 | `aiengineer` | Dry-run/live-smoke CLIs and shell wrappers; live disabled unless explicit. |
| `check_paperclip_agentfield_adapter_ready` | check | 20 | `aiengineer` | Non-live readiness check for adapter workspace, schemas, client, mappers, fixtures, configs, CLI. |
| `run_paperclip_agentfield_adapter_dryrun_smoke` | smoke | 20 | `aiengineer` | Load fixture, map to Agentfield request, load mock response, map card/status/review actions, write dry-run report. |
| `run_paperclip_agentfield_adapter_live_smoke` | smoke | 20 | `aiengineer` | Explicit live smoke wrapper that refuses unless `AGENTFIELD_LIVE=1` and preflight succeeds. |

#### Paperclip-visible status shape

The adapter should be able to produce a display object such as:

```text
PaperclipExperimentCard:
  title
  phase
  selected_agents
  stage summaries
  execution id
  artifact links
  failure reason
  review actions
```

Current POC output fields include:

```text
phase
selected_agents
stage_results
final_summary
```

Future status/card fields should include:

```text
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
artifact_links
review_actions
```

#### Artifact mapping direction

First-pass POC artifacts:

```text
stage summaries
final summary
execution id
DAG/UI link
```

Future NCA-ART-GRN artifacts:

```text
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

```text
artifact_type
label
path_or_url
required
exists
display_priority
review_action_hint
```

### Bundle 13 — Agentic GRN discovery platform

#### Product outcome

Bundle 13 composes Bundles 3, 4, 5, 8, 11, and 12 into one managed, reviewable GRN discovery campaign system.

It turns:

```text
run one experiment-aware GRN workflow
```

into:

```text
run a controlled discovery campaign:
  generate candidates
  evaluate mechanisms
  compare/search strategy
  run perturbation/robustness checks
  summarize evidence
  ask for human approval
  propose next campaign or next experiment
```

The scientific guardrail is central:

```text
The platform is not searching for pretty final patterns.
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

#### Campaign object direction

A first-pass campaign object should look like:

```yaml
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

Expected first-pass campaign outputs:

```text
campaign_status.json
campaign_stage_results.json
candidate_rankings.json
artifact_refs.json
mechanism_reports/
search_report.md
next_experiment_suggestions.md
paperclip_review_payload.json
```

#### Bundle 13 skeleton steps

Batch 21, 22, 23, and 24 implement Bundle 13 in the corrected skeleton slicing.

| Step | Type | Batch | Target role | Output contract |
|---|---|---:|---|---|
| `prepare_grn_discovery_campaign_schema` | schema | 21 | `aiengineer` | Campaign schema with campaign_id, objective, target_role, research_mode, execution_target, candidate_source, evaluation_plan, search_plan, perturbation_plan, reasoning_plan, artifact_policy, resource_policy, review_policy, paperclip_visibility. |
| `prepare_campaign_status_schema` | schema | 21 | `aiengineer` | Campaign status with phases, counts, selected_agents, stage_results, experiment_refs, artifact_refs, ranking_refs, report_refs, failure_reason, human_review_state, next_action_suggestions. |
| `prepare_campaign_state_store` | setup | 21 | `aiengineer` | `/workspace/runs/agentfield/campaigns/{active,completed,failed,review_required}`. |
| `prepare_campaign_stage_registry` | template | 21 | `aiengineer` | Stage registry mapping candidate_generation, mechanism_evaluation, search_strategy, perturbation_design, evidence_review, next_experiment, human_review_gate. |
| `prepare_candidate_generation_agent` | dummy reasoner | 22 | `aiengineer` | Agent returns fixture/manual candidate refs and fake candidate records. |
| `prepare_mechanism_evaluation_agent` | dummy reasoner | 22 | `aiengineer` | Agent calls dummy science CLI or links fake mechanism report. |
| `prepare_search_strategy_agent` | dummy reasoner | 22 | `aiengineer` | Agent chooses smoke_lhs/manual_shortlist with fake rationale. |
| `prepare_perturbation_design_agent` | dummy reasoner | 22 | `aiengineer` | Agent writes fake perturbation suggestion and falsification criterion. |
| `prepare_evidence_review_agent` | dummy reasoner | 22 | `aiengineer` | Agent summarizes fake candidate evidence, missing artifacts, platform/science failures. |
| `prepare_next_experiment_agent` | dummy reasoner | 22 | `aiengineer` | Agent proposes next experiment with expected outcomes and cost class. |
| `prepare_human_review_gate` | template | 23 | `aiengineer` | Gate always marks campaign `review_required` and disables auto-launch. |
| `prepare_campaign_artifact_collector` | adapter | 23 | `aiengineer` | Collects refs to campaign artifacts into `artifact_refs.json`. |
| `prepare_campaign_paperclip_payload_mapper` | adapter | 23 | `aiengineer` | Creates `paperclip_review_payload.json` with review actions and artifact links. |
| `prepare_grn_discovery_campaign_smoke_fixtures` | template | 23 | `aiengineer` | Campaign smoke yaml, candidate fixture set, mock reports. |
| `check_grn_discovery_platform_ready` | check | 23 | `aiengineer` | Non-run readiness check for campaign schemas, agents, registry, review gate, payload mapper, fixtures, state store. |
| `run_grn_discovery_campaign_local_smoke` | smoke | 23 | `aiengineer` | Tiny fixture campaign ending in `review_required` with status, rankings, suggestions, payload. |
| `prepare_runpod_campaign_executor` | template | 24 | `aiengineer` | RunPod campaign executor stub refuses live launch but writes planned manifest. |
| `prepare_async_campaign_resume` | template | 24 | `aiengineer` | Resume-state schema/stub reloads campaign_status and continues no-op stages. |
| `prepare_campaign_retry_policy` | template | 24 | `aiengineer` | Retry policy for retryable/non-retryable failures; no automatic retry by default. |
| `prepare_multi_campaign_comparison` | template | 24 | `aiengineer` | Comparison schema/stub for multiple campaign outputs. |
| `prepare_paperclip_campaign_live_submit` | template | 24 | `aiengineer` | Live-submit wrapper/payload stub refuses unless explicit live flags and Paperclip config exist. |

#### Campaign status phases

Recommended campaign phases:

```text
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

#### Campaign state-store contract

Each campaign run under `/workspace/runs/agentfield/campaigns/...` should contain:

```text
campaign.yaml
campaign_status.json
stage_results.jsonl
experiment_refs.json
artifact_refs.json
candidate_rankings.json
failure_reason.json
paperclip_review_payload.json
next_experiment_suggestions.md
```

The local smoke must preserve no-overwrite behavior. A sentinel such as an existing `campaign_status.json` containing `DO NOT OVERWRITE` under `review_required/existing_campaign` must not be destroyed by `run_grn_discovery_campaign_local_smoke`.

## Batch -> layer implementation map

The corrected skeleton authority maps Layer 5 to Batches 16–24.

| Batch | Slug | Layer 5 scope | Bundle | Implementation meaning |
|---:|---|---|---:|---|
| 16 | `16-agentfield-poc` | Agentfield POC import, spec/status schemas, controller entrypoint | 11A | Establish the Agentfield-native experiment-aware controller foundation and preserve the working POC pattern. |
| 17 | `17-agentfield-reasoners` | Agent registry, reasoner invoker, dummy GRN reasoners, execute fixtures, local smoke | 11B | Make the experiment-aware flow runnable in dry-run/local mode with visible resolved stages and stage results. |
| 18 | `18-agentfield-hardening-stubs` | Repo split, NCA-ART bridge, artifact/status/report/runpod stubs | 11C | Prepare hardening and bridge contracts while keeping live/remote execution guarded. |
| 19 | `19-paperclip-adapter-core` | Adapter workspace, job schema, Agentfield client, request/status mappers | 12A | Let Paperclip-like jobs map to Agentfield execute requests and Agentfield results map back to Paperclip-visible status. |
| 20 | `20-paperclip-review-dryrun` | Artifact mapper, review actions, config profiles, fixtures, mock/dryrun adapter smoke; live smoke optional and guarded | 12B | Make the adapter reviewable and smokeable without live Paperclip or Agentfield writes. |
| 21 | `21-campaign-core` | Campaign schema, status schema, state store, stage registry | 13A | Define campaign intent/status and durable first-pass campaign state. |
| 22 | `22-campaign-agents` | Candidate/mechanism/search/perturbation/evidence/next-experiment agents | 13B | Add dummy but structured campaign agents that preserve scientific evidence semantics. |
| 23 | `23-campaign-review-smoke` | Human review gate, artifact collector, Paperclip payload mapper, campaign smoke | 13C | End a tiny campaign in review_required with artifact refs, rankings, next suggestions, and review payload. |
| 24 | `24-campaign-guarded-stubs` | RunPod campaign executor, async resume, retry, comparison, live submit guarded stubs | 13D | Prepare future live/resumable campaign behavior while refusing unsafe live actions by default. |

## 24-batch visual map

```text
Layer 1
  [01] 01-runtime-substrate

Layer 2
  [02] 02-research-workspace
  [03] 03-ai-engineer-workspaces
  [04] 04-pkm-skeleton
  [05] 05-publisher-latex

Layer 3
  [06] 06-nca-art-base
  [07] 07-dummy-science-organs
  [08] 08-mechanism-reporting
  [09] 09-local-smoke
  [10] 10-search-templates
  [11] 11-search-scoring
  [12] 12-search-smoke
  [13] 13-runpod-dryrun

Layer 4
  [14] 14-openclaw-indexes
  [15] 15-openclaw-reasoners

Layer 5
  [16] 16-agentfield-poc
  [17] 17-agentfield-reasoners
  [18] 18-agentfield-hardening-stubs
  [19] 19-paperclip-adapter-core
  [20] 20-paperclip-review-dryrun
  [21] 21-campaign-core
  [22] 22-campaign-agents
  [23] 23-campaign-review-smoke
  [24] 24-campaign-guarded-stubs
```

## Smoke / validation mapping

Layer 5 uses the dynamic smoke model. It must not create one global smoke module per batch by default.

Relevant global smoke domains:

| Domain | Global module | Layer 5 relevance |
|---|---|---|
| Skeleton evidence | `30-skeleton-evidence.smoke.sh` | Checks `POSTCHECK.md` and `INTEGRATION_REQUEST.md` for each skeleton batch. |
| Config boundary | `50-config-boundary.smoke.sh` | Confirms Layer 5 implementation did not edit config internals. |
| Agentfield | future `85-agentfield.smoke.sh` | Covers Agentfield POC schemas, controller, reasoners, fixtures, local smoke, dry-run only. |
| Paperclip adapter | future `86-paperclip-adapter.smoke.sh` | Covers adapter schema, client, mappers, fixtures, review dry-run, no live Paperclip. |
| Campaign orchestration | future `88-agentfield-campaign.smoke.sh` | Covers campaign schemas, state store, agents, review payload, human gate, guarded stubs. |
| RunPod dry-run | future `75-runpod-dryrun.smoke.sh` | Relevant to guarded RunPod campaign executor stubs; no live RunPod launch. |

Smoke commands follow the active runner rule:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh skeleton-progress
```

or, after runner migration:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

For real-organ transition batches, the equivalent phase is `organ-progress`:

```bash
BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke.sh organ-progress
```

or, after runner migration:

```bash
BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress
```

Layer 5 local smoke routines may be created inside their project repos when a batch owns a smokeable local surface:

```text
/workspace/repos/agentfield/scripts/poc_local_smoke.sh
/workspace/repos/paperclip-agentfield-adapter/scripts/adapter_dryrun.smoke.sh
/workspace/repos/agentfield/scripts/campaign_fixture_smoke.sh
```

These local routines may be called by global modules, but they do not replace global modules.

## Output and path contracts

### Agentfield repo

```text
/workspace/repos/agentfield/
  README.md
  pyproject.toml
  agentfield_grn/
    __init__.py
    schemas/
    controllers/
    registry/
    reasoners/
    invokers/
    fixtures/
    cli/
  configs/
    experiments/
    reasoners/
    campaign/
  smoke_tests/
  runs/
```

### Agentfield experiment outputs

```text
resolved_stages.json
selected_agents.json
experiment_status.json
stage_results.jsonl
artifact_refs.json
report_refs.json
failure_reason.json
```

### Paperclip-Agentfield adapter repo

```text
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

### Adapter outputs

```text
agentfield_execute_request.json
paperclip_experiment_card.json
artifact_links.json
review_actions.json
adapter_dryrun_report.md
```

### Campaign state and outputs

```text
/workspace/runs/agentfield/campaigns/
  active/
  completed/
  failed/
  review_required/
```

Each run should contain:

```text
campaign.yaml
campaign_status.json
stage_results.jsonl
experiment_refs.json
artifact_refs.json
candidate_rankings.json
failure_reason.json
paperclip_review_payload.json
next_experiment_suggestions.md
mechanism_reports/
search_report.md
```

### Skeleton evidence

Each skeleton Layer 5 batch must write evidence under:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

### Organ evidence

Each real-organ transition batch must write evidence under:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

## Relationship to earlier layers

### Relationship to Layer 1 — Runtime substrate

Layer 5 consumes:

- `/workspace` roots,
- runtime/readiness conventions,
- remote model client contract,
- guarded RunPod and compute-profile boundaries,
- dynamic smoke runner and report roots.

Layer 5 must not launch live RunPod jobs, call live model providers, mutate Kubernetes, or apply Terraform unless a later explicitly gated real-organ batch allows it.

### Relationship to Layer 2 — Role workstations

Layer 5 consumes:

- the `aiengineer` role and workspace,
- `/workspace/repos/agentfield`,
- `/workspace/repos/paperclip-agentfield-adapter`,
- AI Engineer package-policy readiness,
- `researchscientist` outputs from `/workspace/runs/nca-art-grn` and `/workspace/artifacts/nca-art-grn`.

Layer 5 must keep Agentfield/adapter code in AI Engineer-owned platform repos and must not pollute the scientific repo with orchestration logic.

### Relationship to Layer 3 — Research execution loops

Layer 5 consumes:

- DSL candidate artifacts,
- simulator outputs,
- NCA summaries,
- ART2 prototypes,
- ARTMAP transitions,
- perturbation summaries,
- mechanism reports,
- search reports,
- local smoke outputs.

Layer 5 wraps these artifacts in experiment/campaign status and review payloads. It does not claim scientific discovery on its own.

### Relationship to Layer 4 — Knowledge, reasoning, and writing automation

Layer 5 consumes:

- selected report/context indexes,
- mechanism review reasoners,
- failure triage reasoners,
- next-experiment suggestion profiles,
- paper/review context outputs.

Layer 5 may invoke or reference reasoning outputs through controlled stubs, but it must not dump the whole vault, write notes by default, call live models by default, or auto-promote results into publication material.

## Relationship to later layers

There are no additional numbered product layers after Layer 5. Later work is the transition from skeleton-dummy organs to real organs.

For Layer 5, the real-organ transition mapping is:

| Organ batch | Depends on skeleton batches | Layer 5 transition meaning | Smoke domain |
|---:|---|---|---|
| R09 | 03, 16, 17, 18 | Replace dummy Agentfield POC/reasoners/hardening stubs with first-pass experiment lifecycle/controller integration and NCA-ART artifact/status bridge. | future `85-agentfield` |
| R10 | 19, 20 | Replace dummy adapter/review dry-run with real request/status/artifact/review mapping behind guarded Agentfield and Paperclip live-write boundaries. | future `86-paperclip-adapter` |
| R11 | 21, 22, 23, 24 | Replace dummy campaign core/agents/review/guarded stubs with first-pass resumable campaign execution pipeline, human review payloads, retry/resume/comparison, and guarded future live submit. | future `88-agentfield-campaign`, future `75-runpod-dryrun`, future `86-paperclip-adapter` |
| R12 | all prior R batches and skeleton 01–24 | End-to-end real local smoke across all applicable discovered smoke domains. | all applicable |

Transition work must replace internals while preserving skeleton public contracts unless the transition master explicitly creates a versioned contract migration.

## Annex index

No separate annex file is produced in this combined Layer 5 SPEC. The following background files were folded into this layer-level SPEC:

| Source file | Used for |
|---|---|
| `00_Global_architecture_and_layer_grouping.md` | Global stack direction and five-layer grouping. |
| `Platform_plan_Layer5_ProductOwner_platform_orchestration.md` | Product-owner Layer 5 intent, boundary, and bundle semantics where not contradicted by newer sources. |
| `Platform_plan_Layer5_platform_orchestration_Bundle11_agentfield_experiment_foundation.md` | Updated Bundle 11 Agentfield-native controller POC direction. |
| `Platform_plan_Layer5_platform_orchestration_Bundle11_agentfield_experiment_foundation_json1.md` | Human-cortex GRN POC execute fixture. |
| `Platform_plan_Layer5_platform_orchestration_Bundle11_agentfield_experiment_foundation_json2.md` | NCA-ART-GRN mechanism smoke fixture. |
| `Platform_plan_Layer5_platform_orchestration_Bundle11_agentfield_experiment_foundation_oneline.md` | Bundle 11 bridge summary. |
| `Platform_plan_Layer5_platform_orchestration_Bundle12_paperclip_agentfield_adapter.md` | Bundle 12 adapter scope, schemas, mappers, review actions, dry-run/live guardrails. |
| `Platform_plan_Layer5_platform_orchestration_Bundle12_paperclip_agentfield_adapter_json1.md` | Agentfield execute request fixture. |
| `Platform_plan_Layer5_platform_orchestration_Bundle12_paperclip_agentfield_adapter_json2.md` | Paperclip job fixture. |
| `Platform_plan_Layer5_platform_orchestration_Bundle12_paperclip_agentfield_adapter_json3.md` | `prepare_paperclip_job_schema` command/check fixture. |
| `Platform_plan_Layer5_platform_orchestration_Bundle12_paperclip_agentfield_adapter_json4.md` | `prepare_agentfield_execute_client` command/check fixture. |
| `Platform_plan_Layer5_platform_orchestration_Bundle12_paperclip_agentfield_adapter_json5.md` | Mapper command/check fixture. |
| `Platform_plan_Layer5_platform_orchestration_Bundle12_paperclip_agentfield_adapter_json6.md` | Adapter smoke fixture checks. |
| `Platform_plan_Layer5_platform_orchestration_Bundle13_agentic_grn_discovery_platform.md` | Bundle 13 campaign schema, agents, state, review, artifact, and smoke semantics. |
| `Platform_plan_Layer5_platform_orchestration_Bundle13_agentic_grn_discovery_platform_json1.md` | No-overwrite campaign smoke sentinel. |
| `Platform_plan_Layer5_platform_orchestration_Bundle13_agentic_grn_discovery_platform_json2.md` | Bundle 13 summary note. |
| `00_A0_skeleton_dummy_master_implementation_companion.md` | Authoritative skeleton step list and Layer 5 step contracts. |
| `00_A1_skeleton_dummy_codex_batch_plan_v2.md` | Corrected skeleton batch slicing authority for Batches 16–24. |
| `00_A2_skeleton_batch_mapping_report_batches_01_24.md` | Corrected smoke/batch mapping and domain smoke authority. |
| `01_B0_transition_to_real_organs_master_v2.md` | Real-organ transition principles and Layer 5 transition guardrails. |
| `01_B1_transition_real_organs_codex_batch_plan_v2.md` | Real-organ batch mapping for Agentfield, adapter, campaign, and end-to-end smoke. |
| `day_to_day_skeleton_run.md` | Skeleton daily evidence/smoke workflow. |
| `day_to_day_organs_run.md` | Organ transition daily evidence/smoke workflow. |
| `final_workflow.md` | Consolidated dynamic smoke and config-boundary workflow. |
| `smoke_module_update_workflow.md` | Global-vs-local smoke module update rules. |

If later detailed annexes are wanted, the most likely split is:

```text
SPEC_Layer05_16-agentfield-poc-ANX01_experiment_aware_controller_poc.md
SPEC_Layer05_19-paperclip-adapter-core-ANX01_request_status_mapping.md
SPEC_Layer05_21-campaign-core-ANX01_campaign_schema_state_registry.md
SPEC_Layer05_23-campaign-review-smoke-ANX01_review_payload_and_smoke.md
```

## Acceptance / success condition

Layer 5 skeleton is successful when:

- Batches 16–24 each have a generated/implemented skeleton package with `POSTCHECK.md`, `INTEGRATION_REQUEST.md`, and acceptable dynamic smoke result.
- Agentfield can represent a GRN experiment intent and produce dry-run/local status with resolved stages, selected agents, stage results, and final summary.
- Agentfield hardening stubs preserve the path from POC to NCA-ART-GRN artifact/status mapping without live remote execution.
- The Paperclip-Agentfield adapter can map a Paperclip job fixture into an Agentfield execute request and map a mock Agentfield response into a Paperclip-visible card/review payload.
- Campaign orchestration can validate a tiny campaign fixture, create durable campaign state, run dummy agents, collect artifact refs, create rankings/suggestions, produce a Paperclip review payload, and end in `review_required`.
- Guarded stubs for RunPod campaign execution, async resume, retry policy, multi-campaign comparison, and Paperclip live submit refuse unsafe live actions by default.
- Dynamic smoke domains remain domain-owned and no one-batch-per-module smoke pattern is introduced.
- Config internals are not edited by Layer 5 skeleton or organ implementation batches.

## Developer notes

- Treat `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md` as the current skeleton authority when they conflict with product-owner wording.
- Treat `01_B0_transition_to_real_organs_master_v2.md` and `01_B1_transition_real_organs_codex_batch_plan_v2.md` as the current real-organ transition authority.
- Product-owner Layer 5 text is useful for product meaning, but outdated wording that frames Bundle 11 as a generic Kubernetes CRD/repo-command wrapper should be replaced by the updated Agentfield-native experiment-aware controller POC direction.
- Do not create `prepare_grn_workspace`; research workspace creation belongs to earlier corrected Batch 02 as `prepare_nca_art_workspace` and `prepare_experiment_output_layout`.
- Do not make Paperclip the controller. Paperclip remains the human-facing dashboard/review layer.
- Do not make Agentfield the science engine. `nca-art-grn` remains the scientific execution engine.
- Do not make OpenClaw/PKM the orchestrator. It reasons over selected evidence and context.
- Do not make `config` an implementation target during Layer 5 batches. It is a dependency and operational interface.
- Every live-capable path must default to dry-run/refusal unless explicit flags, preflight, credentials, and human/operator approval are present.
