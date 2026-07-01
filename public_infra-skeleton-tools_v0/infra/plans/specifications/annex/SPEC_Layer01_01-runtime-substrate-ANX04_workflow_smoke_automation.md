# SPEC_Layer01_01-runtime-substrate-ANX04_workflow_smoke_automation

Status: created from current workflow, smoke, skeleton, organ, hook, and batch-generation authority files.  
Parent layer spec: `SPEC_Layer01_runtime_substrate.md`.  
Primary batch placement: **Batch 01 / `01-runtime-substrate`**.  
Annex purpose: `workflow and smoke automation guardrails for batch generation`.  
Batch slicing authority: `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md`.  
Operational authority: `final_workflow.md`, `smoke_module_update_workflow.md`, `day_to_day_skeleton_run.md`, and `day_to_day_organs_run.md` where relevant.  
Hook file: `BATCH_CREATION_ANX04_workflow_smoke_automation.md`.

## Why this annex exists

The batch-generation system already creates one Codex-ready implementation batch at a time, and the day-to-day workflows already define what must happen after implementation. The gap is that a generated batch can still forget to carry the operational after-steps forward: write evidence, run dynamic smoke, classify the smoke result, decide whether local or global smoke coverage changed, update companion only at the right checkpoint, and defer config integration.

This annex makes those workflow expectations part of the hook/ANX system without bloating `NEW_CHAT_PROMPT_batch_creation.md`. The compact hook tells batch-generation chats when to request this annex. This deeper annex explains the workflow contract that generated batch files should include.

This is a cross-cutting operational annex. It is anchored to Layer 1 / Batch 01 because the evidence roots, dynamic smoke runner, smoke report path, and runtime guardrails are platform substrate concerns. It applies to every later skeleton and organ batch as a guardrail, not as a new implementation slice.

## Most relevant implementation batch

```text
Primary skeleton batch: 01-runtime-substrate
Primary layer: Layer 1 — Runtime substrate
Primary reason: smoke runner, evidence paths, runtime roots, no-live default, and config-boundary behavior are foundational runtime contracts.
```

Batch 01 is not the only consumer. The annex is required across all skeleton and organ batches because every generated batch must preserve the same stop/continue discipline.

## Related layer and bundle

This annex belongs to:

```text
Layer 1 — Runtime substrate
Batch 01 — 01-runtime-substrate
Operational concern — dynamic smoke, evidence roots, workflow stop gates, and no-live/default-safe execution
```

It references all later layers because those layers create domain surfaces that may require local smoke routines or global smoke-module coverage:

```text
Layer 2 — role workstations, PKM, publisher setup
Layer 3 — research execution loops, local science smoke, RunPod dry-run
Layer 4 — OpenClaw / PKM reasoning access
Layer 5 — Agentfield, Paperclip adapter, campaign orchestration
```

## Background source notes

Source files used:

```text
NEW_CHAT_PROMPT_create_hook_and_spec_annex.md
NEW_CHAT_PROMPT_batch_creation.md
NEW_CHAT_PROMPT_update_specs.md
NEW_CHAT_PROMPT_implement_in_codex.md
BATCH_CREATION_ANX01_spectral_operator_dsl_bridge.md
SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md
SPEC_Layer01_runtime_substrate.md
SPEC_Layer02_role_workstations.md
SPEC_Layer03_research_execution_loops.md
SPEC_Layer04_knowledge_reasoning.md
SPEC_Layer05_platform_orchestration.md
00_A0_skeleton_dummy_master_implementation_companion.md
00_A1_skeleton_dummy_codex_batch_plan_v2.md
00_A2_skeleton_batch_mapping_report_batches_01_24.md
01_B0_transition_to_real_organs_master_v2.md
01_B1_transition_real_organs_codex_batch_plan_v2.md
day_to_day_skeleton_run.md
final_workflow.md
smoke_module_update_workflow.md
day_to_day_organs_run.md
CONFIG_TOOL.md
```

Concepts extracted:

```text
1. Batch generation should remain one-batch-only and cache-stable.
2. Long workflow tables should not be embedded in NEW_CHAT_PROMPT_batch_creation.md.
3. Hooks can request deeper annex files only when a batch needs the context.
4. Every skeleton batch must leave POSTCHECK.md, INTEGRATION_REQUEST.md, and a smoke report path before the next batch begins.
5. Every organ batch must also preserve the relevant skeleton output contract.
6. Smoke has protocol, runner, global module, and local routine layers.
7. Global smoke modules are domain-owned, not batch-owned.
8. Local routines are created by the batch that owns the subsystem.
9. Runner/protocol changes are rare and should not be mixed into ordinary implementation batches.
10. Config/lv/workflow edits are deferred to later vmuser/operator config-integration batches.
```

## What this extends in the main layer SPEC

This annex extends `SPEC_Layer01_runtime_substrate.md` by making the dynamic smoke and evidence workflow an explicit batch-generation dependency.

The main Layer 1 SPEC defines runtime roots and safe runtime contracts. This annex adds the operational contract that generated batch files must carry:

```text
implementation -> evidence -> smoke instruction set -> smoke run -> PASS/WARN/FAIL classification -> companion at checkpoint -> later integration manifest -> later config integration
```

It does not add new product code to Batch 01 by itself. It adds reusable workflow guardrails that future generated batches should include.

## Batch -> implementation relevance

### Batch 01 / `01-runtime-substrate`

Batch 01 should include this annex as required context because it establishes:

```text
/workspace roots
/workspace/scripts/smoke.sh or /workspace/scripts/smoke_current_state.sh expectations
/workspace/tests/smoke.d/*.smoke.sh discovery model
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md output pattern
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
no-live runtime defaults
config-boundary rules
```

Generated Batch 01 files should not implement the whole workflow. They should make the evidence/smoke requirements visible and preserve the dynamic runner compatibility rule.

### Batches 02-05 / role, PKM, publisher setup

These batches should use the annex to ensure that new role/path surfaces are followed by:

```text
POSTCHECK.md and INTEGRATION_REQUEST.md evidence
skeleton-progress smoke
local-vs-global smoke decision
companion update only at logical checkpoint or contract change
no config edits during implementation
```

Batch 02 especially must decide whether `nca-art-grn` local smoke routines are created and whether `20-python-package`, `70-grn-contract`, or `30-skeleton-evidence` global modules need updated expectations.

### Batches 06-13 / research execution and RunPod dry-run

These batches are the highest-risk skeleton consumers because they create or change DSL, simulator, NCA, ART, mechanism-report, search, local smoke, and RunPod dry-run contracts.

Generated files should include explicit decisions for:

```text
local repo smoke routines under /workspace/repos/nca-art-grn/scripts/ or equivalent
global 70-grn-contract.smoke.sh coverage
future 72-search-contract split only if domain size justifies it
future 75-runpod-dryrun.smoke.sh when RunPod dry-run surfaces become current-state contracts
no live RunPod, no large training/search, no real provider calls by default
```

### Batches 14-15 / OpenClaw and PKM reasoning

Generated files should include explicit decisions for:

```text
future 80-openclaw-pkm.smoke.sh coverage
local selected-context query smoke
no whole-vault indexing
no note-body logging
no paid/live model calls by default
```

### Batches 16-24 / Agentfield, Paperclip, campaigns

Generated files should include explicit decisions for:

```text
future 85-agentfield.smoke.sh
future 86-paperclip-adapter.smoke.sh
future 88-agentfield-campaign.smoke.sh
local controller/adapter/campaign fixture smoke
no live Agentfield server, Paperclip write, RunPod launch, or model call by default
human review gates for campaign and Paperclip payloads
```

## Concrete steps affected

This annex affects batch-generation instructions, not direct platform code. Generated `PROJECT_CACHE.md`, `SPEC.md`, `RUN_INSTRUCTIONS.md`, and `POSTCHECK_TEMPLATE.md` should carry the following checkpoints when relevant:

```text
1. Implement only the selected batch.
2. Write POSTCHECK.md in the correct skeleton or organ evidence root.
3. Write INTEGRATION_REQUEST.md in the correct skeleton or organ evidence root.
4. Run no smoke automatically inside the implementation task unless RUN_INSTRUCTIONS.md explicitly says to run a local safe smoke.
5. Prepare or request a separate smoke execution instruction set after implementation.
6. Run the active dynamic smoke runner in the correct phase.
7. Record the SMOKE_REPORT.md path.
8. Classify PASS / SKIP / WARN / FAIL before continuing.
9. If domain contracts changed, decide local routine and global smoke-module updates.
10. Defer config/lv/workflow integration to a later vmuser/operator manifest-approved batch.
```

## Path and ownership contracts

### Skeleton evidence

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

### Organ evidence

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

### Smoke runtime

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/scripts/smoke_current_state.sh
/workspace/scripts/smoke.sh
/workspace/tests/smoke.d/*.smoke.sh
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
/workspace/runs/smoke/<timestamp-phase>/module-results/
```

### Companion outputs

```text
/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md
/mnt/ingress/infra/skeleton/companion/INDEX.md
/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md
/mnt/ingress/infra/organs/companion/INDEX.md
```

### Config boundary

```text
Do not edit /home/vmuser/.local/bin/config
Do not edit /home/vmuser/.local/bin/config.sh
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh
Do not edit /home/vmuser/.local/etc/config-sh/*
Do not edit /home/vmuser/.local/state/config-sh/*
```

Config may be inspected or invoked only through allowed operational interfaces where a batch explicitly requires it.

## Output contracts

Generated skeleton batches should preserve these output contracts:

```text
codex_skeleton_batch_<N>_<slug>.zip
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
```

Generated organ batches should preserve equivalent organ contracts:

```text
codex_organ_batch_<RNN>_<slug>.zip or active organ naming convention
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
```

Smoke-instruction set outputs, when generated, should be compact and execution-only:

```text
SMOKE_RUN_PROJECT_CACHE.md
SMOKE_RUN_CODEX_PROMPT.txt
```

Smoke-module update packages, when needed, should be separate from ordinary batch implementation packages:

```text
SMOKE_MODULE_UPDATE_PROJECT_CACHE.md
SMOKE_MODULE_UPDATE_CODEX_PROMPT.txt
```

## Guardrails / non-goals

This annex must not cause generated batches to:

```text
merge multiple skeleton batches
create one global smoke module per batch
put domain-specific checks into the runner
edit config/lv/workflow during ordinary skeleton or organ implementation
create companion docs during S-T1/S-T3 or O-T1/O-T3
invent POSTCHECK.md, INTEGRATION_REQUEST.md, or SMOKE_REPORT.md evidence
continue after missing required evidence
continue after FAIL or unclassified WARN
run live RunPod, live model/provider calls, live Paperclip writes, live Agentfield actions, Kubernetes mutation, Terraform apply/destroy, or Docker containers by default
read or print secrets
```

## Smoke and validation relevance

The dynamic smoke system has four separable layers:

```text
1. Protocol: /workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
2. Runner/orchestrator: /workspace/scripts/smoke_current_state.sh or /workspace/scripts/smoke.sh
3. Global modules: /workspace/tests/smoke.d/*.smoke.sh
4. Local routines: project-local *.smoke.sh, smoke_test.py, or safe local smoke CLIs
```

Generated batch files should apply this decision model:

```text
local routine: yes when the batch creates a local CLI, fixture, schema validator, dry-run path, or local subsystem proof

global module: yes when the public domain contract, paths, filenames, schema shape, success criteria, or platform/domain surface changes

runner: yes only when phases, discovery, exported variables, report schema, or aggregation/exit behavior changes

protocol: yes only when smoke architecture, module contract, status meanings, phase list, forbidden/live-action policy, or report schema changes
```

Default safe command patterns:

```text
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh skeleton-progress
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke.sh organ-progress
BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress
bash /workspace/scripts/smoke.sh skeleton-complete
bash /workspace/scripts/smoke_current_state.sh skeleton-complete
```

The exact command must be chosen by the smoke execution instruction set according to the workspace migration state.

## How Codex should use this annex when generating a batch

For every generated skeleton batch, include selected-batch-relevant workflow text in the generated files.

### PROJECT_CACHE.md

Include only compact points:

```text
Required read-only annex: SPEC_Layer01_01-runtime-substrate-ANX04_workflow_smoke_automation.md
Evidence root: /mnt/egress/dev-recordings/skeleton/<batch-slug>/
Required evidence after implementation: POSTCHECK.md and INTEGRATION_REQUEST.md
Required smoke after implementation: active dynamic runner, phase skeleton-progress
Continue condition: PASS, SKIP, or accepted documented WARN
Smoke-module decision: local routine vs global module vs runner/protocol update
No config/lv/workflow edits in implementation batch
```

### SPEC.md

Add a small acceptance section:

```text
This batch is not complete until POSTCHECK.md, INTEGRATION_REQUEST.md, and a smoke report path exist, and the smoke result is PASS, SKIP, or accepted documented WARN.
```

Add a smoke-scope section:

```text
If the batch creates or changes a local subsystem command/fixture/schema/dry-run, create/update a local smoke routine inside the owning project.
If the batch changes a domain-wide public contract, update the smallest matching global smoke.d module through a separate smoke-module update task or explicit batch scope.
Do not create a global smoke.d module merely because this is a new batch.
```

### RUN_INSTRUCTIONS.md

Add implementation-run guardrails:

```text
After implementation, fill POSTCHECK_TEMPLATE.md into POSTCHECK.md.
Write INTEGRATION_REQUEST.md even if suggested config integration type is none.
Do not run broad/global smoke unless this RUN_INSTRUCTIONS.md explicitly includes a local safe check.
Do not edit config/lv/workflow.
After this implementation task, use a separate S-T4A/O-T4A smoke instruction set.
```

### POSTCHECK_TEMPLATE.md

Include fields:

```text
Implementation summary
Files created/updated
Evidence root
INTEGRATION_REQUEST.md path
Local smoke routine created/updated: yes/no/path/reason
Global smoke module update needed: yes/no/module/reason
Runner/protocol update needed: yes/no/reason
Suggested smoke phase and command pattern
Actual SMOKE_REPORT.md path after smoke, if known
WARN classification, if any
Open blockers
```

## Real-organ transition relevance

Real-organ batches must preserve corrected skeleton output contracts while replacing dummy internals. This annex is required for organ batch generation because organ work has higher risk of accidentally running real compute, live services, or contract-breaking replacements.

Organ generated files should include:

```text
Evidence root: /mnt/egress/organs/dev-recordings/organs/<batch-slug>/
Required evidence: POSTCHECK.md and INTEGRATION_REQUEST.md
Required smoke phase: organ-progress unless a final checkpoint is explicitly requested
Continue condition: PASS, SKIP, or accepted documented WARN
Additional condition: relevant skeleton output contract preserved
Local organ smoke routine decision
Global smoke.d module update decision
Guarded live boundary statement
```

Organ-specific smoke-domain hints:

```text
R01: contract audit uses core, python, evidence, config-boundary, infra, research-assistant domains
R02-R06: GRN/NCA/ART and search contracts, primarily 70-grn-contract and possible future 72-search-contract
R07: RunPod dry-run-to-live boundary, future 75-runpod-dryrun and maybe 60-infra-tools
R08: OpenClaw/PKM, future 80-openclaw-pkm
R09: Agentfield, future 85-agentfield
R10: Paperclip adapter, future 86-paperclip-adapter
R11: Campaign, future 88-agentfield-campaign plus payload-related 86 and RunPod-related 75 where needed
R12: end-to-end local no-live smoke across all applicable discovered domains
```

## Open questions

```text
1. Should the project create a dedicated NEW_CHAT_PROMPT_smoke_execution.md so S-T4A/O-T4A can be started from a reusable prompt file instead of repeated manual wording?
2. Should D-SM3 smoke-module update packs have their own stable template files beside CODEX_PROMPT/SPEC/RUN_INSTRUCTIONS style files?
3. Should NEW_CHAT_PROMPT_batch_creation.md always require this ANX04 hook for every batch, or should it become a core required workflow input instead of a conditional hook?
4. Should the skeleton and organ batch generators emit SMOKE_RUN_PROJECT_CACHE.md and SMOKE_RUN_CODEX_PROMPT.txt immediately after creating a batch, or only after POSTCHECK.md/INTEGRATION_REQUEST.md exist?
5. Should the companion update decision be represented as a checklist field in POSTCHECK_TEMPLATE.md for every batch?
```

## 24-batch visual map

| Batch | Slug | Workflow/smoke automation relevance |
|---:|---|---|
| 01 | `01-runtime-substrate` | Required. Anchors runner/evidence/runtime/no-live contracts. |
| 02 | `02-research-workspace` | Required. First project-domain workspace; local/global smoke decision begins. |
| 03 | `03-ai-engineer-workspaces` | Required. AI/platform roots may need readiness and later Agentfield/OpenClaw smoke coverage. |
| 04 | `04-pkm-skeleton` | Required. PKM no-overwrite/no-index-all guardrails and future OpenClaw smoke. |
| 05 | `05-publisher-latex` | Required. Publisher no-build/no-overwrite and future LaTeX smoke. |
| 06 | `06-nca-art-base` | Required. DSL/schema contracts and `70-grn-contract` coverage. |
| 07 | `07-dummy-science-organs` | Required. Dummy organ outputs and local science smoke decisions. |
| 08 | `08-mechanism-reporting` | Required. Mechanism report contract and guardrail headings. |
| 09 | `09-local-smoke` | Required. Explicit local smoke output contract and global module call decision. |
| 10 | `10-search-templates` | Required. Search schema/template smoke coverage. |
| 11 | `11-search-scoring` | Required. Scoring/result/ranking/report contract coverage. |
| 12 | `12-search-smoke` | Required. Tiny dummy search smoke and possible future search-domain split. |
| 13 | `13-runpod-dryrun` | Required. RunPod dry-run boundaries and no-live launch guard. |
| 14 | `14-openclaw-indexes` | Required. Selected context and future OpenClaw/PKM smoke. |
| 15 | `15-openclaw-reasoners` | Required. Mock/local reasoning smoke and no paid model calls. |
| 16 | `16-agentfield-poc` | Required. Agentfield POC/status/controller smoke domain begins. |
| 17 | `17-agentfield-reasoners` | Required. Registry/invoker/reasoner fixture smoke. |
| 18 | `18-agentfield-hardening-stubs` | Required. Bridge/status/RunPod-target guarded smoke. |
| 19 | `19-paperclip-adapter-core` | Required. Adapter schemas/mappers and no live Paperclip writes. |
| 20 | `20-paperclip-review-dryrun` | Required. Review dry-run payload/status/action smoke. |
| 21 | `21-campaign-core` | Required. Campaign schema/status/state smoke domain begins. |
| 22 | `22-campaign-agents` | Required. Campaign agent/evidence/review guardrails. |
| 23 | `23-campaign-review-smoke` | Required. Campaign fixture and Paperclip review payload smoke. |
| 24 | `24-campaign-guarded-stubs` | Required. Guarded live stubs, retry/resume/comparison/live-submit disabled by default. |

## Already-run batch update mode

This annex has two consumption modes:

```text
1. Creation mode:
   Used by NEW_CHAT_PROMPT_batch_creation.md through
   BATCH_CREATION_ANX04_workflow_smoke_automation.md.

2. Update mode:
   Used by NEW_CHAT_PROMPT_batch_update.md through
   BATCH_UPDATE_ANX04_workflow_smoke_automation.md.
```

Update mode exists for batches that have already been implemented before this workflow/smoke automation annex was introduced or before a later workflow rule changed.

Update mode must never regenerate a completed batch as if it were new. It creates a delta Codex update pack that:

```text
reads existing POSTCHECK.md, INTEGRATION_REQUEST.md, and latest smoke report when available;
compares the already-run batch against this annex and the update hook;
classifies the delta as evidence, smoke, local-smoke, global-smoke, runner/protocol, instruction, companion, or repair work;
updates only missing workflow/smoke/evidence contracts;
preserves original POSTCHECK.md and INTEGRATION_REQUEST.md;
writes new update evidence under updates/<update-id>/;
reruns the relevant active smoke phase when required;
records whether the batch remains PASS, SKIP, accepted WARN, or FAIL;
keeps config/lv/workflow internals read-only unless a separate config-integration milestone explicitly authorizes edits.
```

## Update-mode files

The update-mode prompt and hook are:

```text
NEW_CHAT_PROMPT_batch_update.md
BATCH_UPDATE_ANX04_workflow_smoke_automation.md
update_workflow.md
```

Generated update packs should contain exactly:

```text
CODEX_UPDATE_PROMPT.txt
PROJECT_UPDATE_CACHE.md
UPDATE_SPEC.md
UPDATE_RUN_INSTRUCTIONS.md
UPDATE_POSTCHECK_TEMPLATE.md
```

Update pack names should follow:

```text
codex_<target-track>_batch_update_<target-batch>_<target-slug>_<update-topic>.zip
```

## Update-mode evidence paths

Skeleton update evidence:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/updates/<update-id>/UPDATE_POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/updates/<update-id>/UPDATE_INTEGRATION_REQUEST.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/updates/<update-id>/CHANGESET_MANIFEST.md
```

Organ update evidence:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/updates/<update-id>/UPDATE_POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/updates/<update-id>/UPDATE_INTEGRATION_REQUEST.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/updates/<update-id>/CHANGESET_MANIFEST.md
```

## Update-mode classifications

Each update pack must choose exactly one primary classification:

```text
evidence-reconciliation
smoke-run-reconciliation
local-smoke-routine-update
global-smoke-module-update
runner-protocol-update
instruction-contract-update
companion-index-update
blocking-repair
```

The classification decides what Codex may edit. If evidence is missing, the update must not invent evidence; it records the missing path and creates update evidence describing the gap. If smoke is missing, the update may be smoke-run reconciliation. If a domain contract changed, the update may touch the smallest domain-owned global smoke module. If a local subsystem needs a repeatable check, the update may touch only the project-local smoke routine and optional caller path.

## Update-mode guardrail

Update mode does not change the corrected skeleton or organ batch slicing. It is a retrofit lane for already-run batches.

For already-run Batch 01, this means:

```text
Do not rerun Batch 01.
Do not regenerate the Batch 01 creation pack.
Do not overwrite original Batch 01 evidence.
Verify runtime/smoke/evidence/no-live contracts.
Apply only missing workflow/smoke/evidence deltas.
Record the update under /mnt/egress/dev-recordings/skeleton/01-runtime-substrate/updates/<update-id>/.
```

For later already-run skeleton batches and real-organ batches, the same rule applies: preserve original batch scope, preserve public output contracts, and record only the new delta.
