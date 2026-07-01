# SPEC Layer 04 — Knowledge, reasoning, and writing automation

**Layer name:** Layer 4 — Knowledge, reasoning, and writing automation  
**Primary bundle:** Bundle 8 — OpenClaw + PKM reasoning workspace  
**Skeleton batches:** Batch 14 `14-openclaw-indexes`; Batch 15 `15-openclaw-reasoners`  
**Primary role owner:** `aiengineer`  
**Supporting roles:** `publisher`, `researchscientist`  
**Main workspace root:** `/workspace/repos/openclaw-workspace`  
**Generated from:** Layer 4 product-owner file + Bundle 8 scrum-master file, reconciled against the current master, batch plan, corrected batch mapping, day-to-day workflow, final workflow, smoke-module workflow, and config-tool boundary.

---

## 1. Authority and reconciliation rules

Use this file as the consolidated Layer 4 planning/spec background for future Codex batch generation and implementation prompts.

When sources disagree, use this priority order:

1. `00_A0_skeleton_dummy_master_implementation_companion.md`
2. `00_A1_skeleton_dummy_codex_batch_plan_v2.md`
3. `00_A2_skeleton_batch_mapping_report_batches_01_24.md`
4. `day_to_day_skeleton_run.md`, `final_workflow.md`, and `smoke_module_update_workflow.md`
5. `CONFIG_TOOL.md`
6. Layer 4 product-owner and Bundle 8 planning files

The Layer 4 product-owner file is useful for product meaning and boundaries, but it is not the slicing authority. The current batch plan and corrected mapping split Layer 4 into **Batch 14** and **Batch 15**. Any older or thinner Layer 4 text that only names four or five concretizations is incomplete for the current skeleton plan.

---

## 2. Layer purpose

Layer 4 turns research outputs and PKM notes into safe, selected, queryable reasoning context.

It sits above the experiment loops and below full platform orchestration:

```text
Layer 1 -> runtime substrate and remote model dummy client
Layer 2 -> role workstations, PKM vault, publisher workspace
Layer 3 -> NCA-ART-GRN artifacts, mechanism reports, search reports, run metadata
Layer 4 -> OpenClaw / PKM reasoning access over selected context
Layer 5 -> Agentfield, Paperclip adapter, campaign orchestration
```

Layer 4 does **not** reorganize the Zettelkasten. Bundle 9 / Batch 04 owns the PKM structure. Layer 4 adds read/suggest-only reasoning access over selected notes and selected artifacts.

---

## 3. Layer questions

Layer 4 answers:

- Can selected research notes, experiment outputs, papers, code summaries, mechanism reports, and search reports be queried safely?
- Can runs become structured reasoning context without manually reading every artifact?
- Can OpenClaw or a local/remote model reason over selected PKM material without corrupting the vault?
- Can Layer 3 outputs become next-experiment suggestions, mechanism reviews, failure triage reports, paper-outline context, or candidate alloy-note drafts?
- Can future Agentfield and Paperclip flows reuse the same reasoner profiles and output contracts?

---

## 4. Layer boundary

### Layer 4 should do

- Prepare `/workspace/repos/openclaw-workspace`.
- Prepare selected PKM context indexes.
- Prepare selected research-artifact context indexes.
- Prepare mechanism-report and search-report ingest bridge templates.
- Prepare a read/suggest-only Zettelkasten reasoning bridge.
- Prepare local and remote model reasoner config templates.
- Prepare repeatable reasoning profile templates.
- Prepare safe PKM query smoke files.
- Prepare next-experiment question templates.
- Prepare mechanism-report-to-alloy-note bridge templates.
- Prepare readiness checks and mocked/local reasoning smoke output.
- Prepare explicit mock-mode reasoner wrappers for future OpenClaw/manual/Agentfield use.

### Layer 4 should not do

- Do not replace, reorganize, or overwrite the Zettelkasten vault.
- Do not index the whole vault by default.
- Do not print note bodies in logs or smoke reports.
- Do not auto-promote notes from source to atom, molecule, or alloy.
- Do not write model output into the real vault without human approval.
- Do not auto-generate final paper sections or overwrite manuscript text.
- Do not run GRN simulations, parameter searches, NCA training, ART discovery, or RunPod jobs.
- Do not call paid or live remote models by default.
- Do not build Agentfield controllers or Paperclip adapters.
- Do not edit the config tool.

---

## 5. Current skeleton split

Layer 4 maps to two skeleton batches.

| Batch | Slug | Scope | Step group | Smoke module | Smoke verifies | Must not do |
|---:|---|---|---|---|---|---|
| 14 | `14-openclaw-indexes` | Layer 4 / Bundle 8A | OpenClaw workspace, PKM/artifact indexes, report ingest bridges | future `80-openclaw-pkm.smoke.sh` | OpenClaw workspace, context indexes, artifact indexes, bridge configs | index whole vault, print note bodies, call models, run experiments |
| 15 | `15-openclaw-reasoners` | Layer 4 / Bundle 8B | Reasoner configs, profile templates, query smoke, local mocked reasoning, reasoner wrappers | future `80-openclaw-pkm.smoke.sh` | reasoner configs, profile templates, query smoke, mocked/local reasoning report | call paid models by default, write notes into vault, launch experiments, build paper output |

The day-to-day workflow groups Batches 14 and 15 as the **OpenClaw reasoning access** logical group. Update the skeleton companion after this logical group or after any contract-changing Layer 4 batch.

---

## 6. Canonical workspace layout

Layer 4 uses this workspace root:

```text
/workspace/repos/openclaw-workspace/
```

Expected skeleton directories:

```text
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

Layer 4 reads selected material from these roots, but must not own or rewrite them:

```text
/workspace/pkm/zettelkasten
/workspace/artifacts/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/repos/research-assistant
/workspace/artifacts/papers/grn-paper
```

Reasoning outputs belong under:

```text
/workspace/repos/openclaw-workspace/runs/
```

Smoke outputs for mocked/local PKM reasoning should use a subdirectory like:

```text
/workspace/repos/openclaw-workspace/runs/smoke/<timestamp>/
  context_manifest.yaml
  query.md
  reasoning_output.md
  status.json
```

---

## 7. Batch 14 — OpenClaw indexes

**Slug:** `14-openclaw-indexes`  
**Branch:** `skeleton/14-openclaw-indexes`  
**Scope:** Layer 4 / Bundle 8A  
**Role:** `aiengineer`  
**Config context:** yes, read-only config/lv/role context is relevant.

Batch 14 prepares the reasoning-access substrate: workspace, selected context indexes, and bridge definitions. It must not run models.

### 7.1 Managed steps / skeleton components

#### `prepare_openclaw_pkm_workspace`

**Type:** setup  
**Owner:** `aiengineer/config`  
**Creates:**

```text
/workspace/repos/openclaw-workspace/{configs,contexts,queries,profiles,tools,runs,smoke_tests,bridges,reports}
```

**Product meaning:** gives reasoning tools a home separate from the PKM vault and the `nca-art-grn` research repo.

**Done when:** the workspace directory tree exists and is target-readable/writable.

#### `check_openclaw_workspace`

**Type:** check  
**Runs:** no model calls, no indexing  
**Reports:**

- workspace path
- config path
- context path
- query path
- profile path
- bridge path
- runs path
- PKM binding present/missing
- remote model config present/missing

**Done when:** the readiness report is non-mutating and does not inspect note bodies.

#### `prepare_pkm_context_index`

**Type:** template / index manifest  
**Creates:**

```text
/workspace/repos/openclaw-workspace/contexts/pkm_index.yaml
```

**Selected PKM zones:**

```text
/workspace/pkm/zettelkasten/20_knowledge_kasten/atoms
/workspace/pkm/zettelkasten/20_knowledge_kasten/molecules
/workspace/pkm/zettelkasten/20_knowledge_kasten/research_questions
/workspace/pkm/zettelkasten/30_publish_kasten/alloys
/workspace/pkm/zettelkasten/40_experiments
```

**Index fields:**

```text
context_id
path
allowed_note_types
include_patterns
exclude_patterns
max_files
privacy_level
last_scanned_at
```

**Guardrail:** do not index the whole vault by default.

#### `prepare_research_artifact_context_index`

**Type:** template / index manifest  
**Creates:**

```text
/workspace/repos/openclaw-workspace/contexts/research_artifacts_index.yaml
```

**Selected Layer 3 artifact zones:**

```text
/workspace/artifacts/nca-art-grn/mechanism_reports
/workspace/artifacts/nca-art-grn/search_reports
/workspace/artifacts/nca-art-grn/prototypes
/workspace/artifacts/nca-art-grn/transition_graphs
/workspace/artifacts/nca-art-grn/dsl_candidates
/workspace/runs/nca-art-grn/*/metadata.json
```

**Index fields:**

```text
artifact_type
artifact_path
source_run_id
candidate_id
mechanism_hypothesis_id
search_method
```

**Product meaning:** makes mechanism evidence and search outputs queryable without running experiments.

#### `prepare_mechanism_report_ingest`

**Type:** bridge/query template  
**Creates:**

```text
/workspace/repos/openclaw-workspace/bridges/mechanism_report_ingest.yaml
/workspace/repos/openclaw-workspace/queries/mechanism_review.md
```

**Ingest contract should extract:**

```text
candidate_id
mechanism_hypothesis
final_pattern_summary
dynamics_evidence
nca_agreement
art2_evidence
artmap_transition_evidence
perturbation_evidence
dsl_mapping_status
falsification_criterion
next_experiment_suggestion
```

**Product meaning:** turns Bundle 3 mechanism reports into comparable reasoning material.

#### `prepare_search_report_ingest`

**Type:** bridge/query template  
**Creates:**

```text
/workspace/repos/openclaw-workspace/bridges/search_report_ingest.yaml
/workspace/repos/openclaw-workspace/queries/search_comparison_review.md
```

**Ingest contract should extract:**

```text
search_method
candidate_count
failure_count
best_candidates
score_components
pareto_front
robustness_summary
perturbation_summary
recommended_next_search
recommended_next_experiment
```

**Product meaning:** turns Bundle 4 search outputs into decision support.

#### `prepare_zettelkasten_reasoning_bridge`

**Type:** read/suggest-only bridge template  
**Creates:**

```text
/workspace/repos/openclaw-workspace/bridges/zettelkasten_bridge.yaml
```

**Known note types:**

```text
source
atom
molecule
topic
research_question
alloy
latex_section_note
experiment_note
architecture_decision
```

**Allowed operations:**

```text
read selected note metadata
summarize selected notes
suggest links
suggest source -> atom promotion
suggest molecule candidates
suggest alloy candidates
suggest paper section mapping
```

**Forbidden operations:**

```text
overwrite notes
auto-promote notes
delete fleeting notes
rewrite private notes
commit model output into vault without approval
```

---

## 8. Batch 15 — OpenClaw reasoners

**Slug:** `15-openclaw-reasoners`  
**Branch:** `skeleton/15-openclaw-reasoners`  
**Scope:** Layer 4 / Bundle 8B  
**Role:** `aiengineer`  
**Config context:** yes, read-only config/lv/role context is relevant.

Batch 15 prepares model-routing config, reasoning profiles, safe query smoke, mocked local reasoning output, and explicit reasoner wrapper contracts. It must not call paid/live models by default.

### 8.1 Managed steps / skeleton components

#### `prepare_local_model_reasoner_config`

**Type:** template  
**Creates:**

```text
/workspace/repos/openclaw-workspace/configs/local_model_reasoner.yaml
```

**Profiles:**

```text
small_local_summary
local_code_review
local_note_linking
local_failure_triage
```

**Config fields:**

```text
model_provider
model_name
endpoint
context_limit
temperature
allowed_context_paths
output_path
no_write_to_vault_by_default
```

#### `prepare_remote_model_reasoner_config`

**Type:** template  
**Creates:**

```text
/workspace/repos/openclaw-workspace/configs/remote_model_reasoner.yaml
```

**Must point to Layer 1 contract:**

```text
local code -> remote model -> response
```

**Profiles:**

```text
deep_mechanism_review
paper_argument_review
next_experiment_suggestion
architecture_review
codebase_planning_review
```

**Config fields:**

```text
remote_model_client_path
endpoint_env_var
model_alias
max_tokens
cost_guardrail
allowed_context_paths
redaction_policy
output_path
```

**Guardrail:** missing keys should be reported safely; no endpoint call by default.

#### `prepare_reasoning_profile_templates`

**Type:** template  
**Creates:**

```text
/workspace/repos/openclaw-workspace/profiles/mechanism_review.yaml
/workspace/repos/openclaw-workspace/profiles/failure_triage.yaml
/workspace/repos/openclaw-workspace/profiles/next_experiment.yaml
/workspace/repos/openclaw-workspace/profiles/paper_section_context.yaml
/workspace/repos/openclaw-workspace/profiles/search_strategy_review.yaml
/workspace/repos/openclaw-workspace/profiles/codebase_architecture_review.yaml
```

**Each profile must define:**

```text
profile_id
purpose
allowed_context_indexes
query_template
model_profile
output_schema
write_policy
human_review_required
```

#### `prepare_pkm_query_smoke_test`

**Type:** smoke/query template  
**Creates:**

```text
/workspace/repos/openclaw-workspace/smoke_tests/pkm_query_smoke.yaml
/workspace/repos/openclaw-workspace/queries/smoke_pkm_query.md
```

**Smoke questions:**

```text
What research questions exist?
Which mechanism reports are available?
Which candidate reports mention perturbation evidence?
Which notes are likely alloy candidates?
What is one safe next experiment suggestion?
```

**Guardrail:** verifies selected context access without modifying the vault or launching experiments.

#### `prepare_next_experiment_question_generator`

**Type:** profile/query template  
**Creates:**

```text
/workspace/repos/openclaw-workspace/queries/next_experiment_from_mechanism_report.md
/workspace/repos/openclaw-workspace/profiles/next_experiment.yaml
```

**Suggestions must consider:**

```text
mechanism_hypothesis
dynamics_evidence
perturbation_evidence
failure_modes
candidate_robustness
nca_agreement
art2_artmap_consistency
Hiscock_Megason_guardrail_final_pattern_is_not_sufficient
```

**Output schema:**

```text
candidate_id
current_evidence
weakest_claim
proposed_next_experiment
expected_distinguishing_outcome
falsification_criterion
required_input_artifacts
estimated_cost_class
```

#### `prepare_mechanism_report_to_alloy_note_bridge`

**Type:** bridge/query template only  
**Creates:**

```text
/workspace/repos/openclaw-workspace/bridges/mechanism_report_to_alloy.yaml
/workspace/repos/openclaw-workspace/queries/mechanism_report_to_alloy_note.md
```

**Mapping:**

```text
mechanism_claim -> alloy_claim
dynamics_evidence -> argument_support
perturbation_prediction -> falsification_section
ART2_ARTMAP_evidence -> method_result_support
DSL_mapping -> explainability_support
figures_tables -> paper_assets
```

**Guardrail:** OpenClaw may suggest an alloy-note draft, but the human approves and writes into the Zettelkasten later.

#### `check_pkm_reasoning_ready`

**Type:** check  
**Runs:** no model calls  
**Reports:**

```text
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
```

#### `run_pkm_reasoning_local_smoke`

**Type:** smoke execution  
**Runs:** tiny mocked/local query only  
**Should do:**

```text
load pkm context index
load research artifact index
select tiny allowed context
run local or mocked model profile
answer one smoke query
write reasoning report
```

**Output:**

```text
/workspace/repos/openclaw-workspace/runs/smoke/<timestamp>/
  context_manifest.yaml
  query.md
  reasoning_output.md
  status.json
```

**Guardrails:** no vault write, no live model by default, no experiment launch.

#### `run_openclaw_reasoning_job`

**Type:** dummy reasoner wrapper  
**Default:** mock mode only  
**Output root:** `/workspace/repos/openclaw-workspace/runs`  
**Purpose:** stable future command contract for manual workflows, Agentfield, and Paperclip-visible review output.

#### `run_mechanism_review_reasoner`

**Type:** dummy reasoner wrapper  
**Input:** selected `mechanism_report.md` or fixture context  
**Output:** `review.md` under OpenClaw runs  
**Purpose:** summarize mechanism evidence and gaps without asserting discovery.

#### `run_failure_triage_reasoner`

**Type:** dummy reasoner wrapper  
**Input:** failure reason text, missing artifacts, or run-status fixture  
**Output:** triage report under OpenClaw runs  
**Purpose:** classify failure causes and suggest safe next diagnostics.

#### `run_paper_outline_reasoner`

**Type:** dummy reasoner wrapper  
**Input:** selected reports/alloy candidates/section context  
**Output:** paper-outline suggestion under OpenClaw runs  
**Guardrail:** no manuscript write.

---

## 9. Whole-system linkage

Layer 4 connects:

```text
Bundle 3 / Batches 06-09
  -> DSL, dummy science outputs, mechanism reports

Bundle 4 / Batches 10-12
  -> search reports, rankings, candidate evidence

Bundle 5 / Batch 13
  -> remote run manifests and returned artifacts

Bundle 9 / Batch 04
  -> Atomic Zettelkasten folders and note templates

Bundle 8 / Batches 14-15
  -> selected indexes, bridges, profiles, mocked/local reasoning output

Bundle 10 / Batch 05
  -> future LaTeX/paper material consumption

Layer 5 / Batches 16-24
  -> Agentfield and Paperclip reuse reasoner profiles and review outputs
```

The direction is read/suggest/review first. Any writeback into PKM, manuscript, Agentfield live state, Paperclip live state, or RunPod live execution is later, explicit, and human-gated.

---

## 10. Config-tool boundary

`CONFIG_TOOL.md` is relevant for Layer 4 because the owner is generally `aiengineer` and the config tool may expose existing inspection/status/explicit step execution. Codex must treat config as an operational interface, not an implementation target.

Allowed examples:

```bash
config --target aiengineer config-show
sudo config --target aiengineer bootstrap status
config --target aiengineer bootstrap steps
lv conda aiengineer
```

Only run an explicit managed step when the active batch prompt requires it, for example:

```bash
sudo config --target aiengineer bootstrap step prepare_openclaw_pkm_workspace
```

Do not edit:

```text
/home/vmuser/.local/bin/config
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/bin/lv.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh/*
/home/vmuser/.local/state/config-sh/*
```

Layer 4 implementation may request later config integration only by writing the normal posthoc bridge:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

---

## 11. Smoke strategy

Layer 4 belongs to the future global smoke domain:

```text
/workspace/tests/smoke.d/80-openclaw-pkm.smoke.sh
```

Do not create one global smoke module per batch. The OpenClaw/PKM module should cover both Batch 14 and Batch 15 when those domain surfaces exist.

### Batch 14 smoke focus

```text
OpenClaw workspace exists
contexts/pkm_index.yaml exists
contexts/research_artifacts_index.yaml exists
bridges/mechanism_report_ingest.yaml exists
bridges/search_report_ingest.yaml exists
bridges/zettelkasten_bridge.yaml exists
no whole-vault index by default
no note bodies printed
no model call
no experiment run
```

### Batch 15 smoke focus

```text
configs/local_model_reasoner.yaml exists
configs/remote_model_reasoner.yaml exists
profiles/*.yaml exist
smoke_tests/pkm_query_smoke.yaml exists
queries/smoke_pkm_query.md exists
next_experiment profile/query exists
mechanism_report_to_alloy bridge/query exists
check_pkm_reasoning_ready can report readiness without model call
run_pkm_reasoning_local_smoke writes mocked/local reasoning_output.md and status.json outside the vault
```

### Local smoke routines

Layer 4 may add local helper routines inside `/workspace/repos/openclaw-workspace`, such as:

```text
/workspace/repos/openclaw-workspace/scripts/local_context_index_smoke.sh
/workspace/repos/openclaw-workspace/scripts/local_reasoning_smoke.sh
```

A future global `80-openclaw-pkm.smoke.sh` may call these helpers, but the helpers do not replace the global module.

---

## 12. Batch-generation notes for future Codex packages

When generating actual Codex-ready packages from `new_chat.md`, keep Batches 14 and 15 separate. Do not merge their implementation scopes into one Codex package.

### Batch 14 package should include

```text
selected batch number: 14
slug: 14-openclaw-indexes
branch: skeleton/14-openclaw-indexes
layer/bundle: Layer 4 / Bundle 8A
owner: aiengineer
workspace root: /workspace/repos/openclaw-workspace
recording root: /mnt/egress/dev-recordings/skeleton/14-openclaw-indexes
companion root: /mnt/ingress/infra/skeleton/companion/14-openclaw-indexes
smoke module focus: future 80-openclaw-pkm.smoke.sh
```

### Batch 15 package should include

```text
selected batch number: 15
slug: 15-openclaw-reasoners
branch: skeleton/15-openclaw-reasoners
layer/bundle: Layer 4 / Bundle 8B
owner: aiengineer
workspace root: /workspace/repos/openclaw-workspace
recording root: /mnt/egress/dev-recordings/skeleton/15-openclaw-reasoners
companion root: /mnt/ingress/infra/skeleton/companion/15-openclaw-reasoners
smoke module focus: future 80-openclaw-pkm.smoke.sh
```

Both batch packages must include the five standard files:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

Both packages must instruct Codex to produce:

```text
POSTCHECK.md
INTEGRATION_REQUEST.md
```

under the appropriate `/mnt/egress/dev-recordings/skeleton/<batch-slug>/` root.

---

## 13. Acceptance criteria for the full Layer 4 skeleton

Layer 4 is skeleton-complete when:

- `/workspace/repos/openclaw-workspace` exists with `configs`, `contexts`, `queries`, `profiles`, `tools`, `runs`, `smoke_tests`, `bridges`, and `reports`.
- `contexts/pkm_index.yaml` exists and references only selected PKM zones.
- `contexts/research_artifacts_index.yaml` exists and references selected Layer 3 artifacts.
- Mechanism-report and search-report ingest bridges exist.
- Zettelkasten reasoning bridge exists and is read/suggest-only.
- Local and remote model reasoner configs exist and default to safe/no-live behavior.
- Reasoning profile templates exist for mechanism review, failure triage, next experiment, paper section context, search strategy review, and codebase architecture review.
- PKM query smoke test files exist.
- Next-experiment question generator template exists.
- Mechanism-report-to-alloy bridge exists and does not write the vault.
- `check_pkm_reasoning_ready` can report readiness without model calls.
- `run_pkm_reasoning_local_smoke` can write a tiny mocked/local reasoning report under OpenClaw runs.
- Explicit reasoner wrappers exist in mock mode for OpenClaw job, mechanism review, failure triage, and paper outline.
- No note bodies are printed.
- No vault notes are overwritten.
- No experiments, RunPod jobs, paid models, Agentfield live controllers, Paperclip live writes, or manuscript builds are launched.
- Batch 14 and Batch 15 each have `POSTCHECK.md` and `INTEGRATION_REQUEST.md` evidence after implementation.
- Dynamic smoke for `skeleton-progress` passes, skips expected missing domains, or produces documented accepted warnings.

---

## 14. One-line summary

Layer 4 prepares OpenClaw and PKM reasoning access: selected indexes, safe bridges, model/profile templates, mocked query smoke, and human-gated reasoning outputs over research evidence.
