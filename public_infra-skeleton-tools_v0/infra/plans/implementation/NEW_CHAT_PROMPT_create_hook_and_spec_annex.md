# NEW_CHAT_PROMPT_create_batch_creation_hook_and_spec_annex

Use this prompt in a fresh ChatGPT chat when I upload new background notes, paper drafts, technical notes, implementation ideas, architecture notes, or research notes and I want ChatGPT to turn them into:

1. one compact batch-creation hook file, and
2. one deeper batch-aligned `SPEC_Layer...ANX...md` annex file.

The purpose is to keep `NEW_CHAT_PROMPT_batch_creation.md` clean. The batch-creation prompt should consume small `BATCH_CREATION_ANX<##>_<topic>.md` hook files. Each hook file should then point to and request the deeper `SPEC_Layer<##>_<batch-slug>-ANX<##>_<topic>.md` annex only when the selected skeleton or organ batch needs it.

Do not embed long conditional annex tables or detailed science/architecture content directly inside `NEW_CHAT_PROMPT_batch_creation.md`.

---

## 1. What I will upload

I may upload any combination of:

```text
new research notes
paper drafts
latex-to-markdown paper conversions
architecture notes
implementation plans
batch hooks
existing SPEC_Layer*.md files
existing SPEC_Layer*-ANX*.md files
existing BATCH_CREATION_ANX*.md hook files
NEW_CHAT_PROMPT_batch_creation.md
NEW_CHAT_PROMPT_update_specs.md
NEW_CHAT_PROMPT_implement_in_codex.md
skeleton and organ batch plans
workflow files
```

Your job is to classify the new material, infer the correct layer and batch placement, and create the corresponding hook + deep annex pair.

---

## 2. Required files to ask me for

Stop and ask for any missing required file before generating final files.

### Required prompt/template authority

```text
NEW_CHAT_PROMPT_update_specs.md
NEW_CHAT_PROMPT_implement_in_codex.md
NEW_CHAT_PROMPT_batch_creation.md
```

### Required examples for style

```text
BATCH_CREATION_ANX01_spectral_operator_dsl_bridge.md
SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md
```

Use `BATCH_CREATION_ANX01_spectral_operator_dsl_bridge.md` as the style template for the compact batch-creation hook.

Use `SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md` as the style template for the deeper implementation annex.

### Required current platform authority

Use these as the most up-to-date authority when they are uploaded:

```text
SPEC_Layer01_runtime_substrate.md
SPEC_Layer02_role_workstations.md
SPEC_Layer03_research_execution_loops.md
SPEC_Layer04_knowledge_reasoning.md
SPEC_Layer05_platform_orchestration.md
SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md
00_A1_skeleton_dummy_codex_batch_plan_v2.md
00_A2_skeleton_batch_mapping_report_batches_01_24.md
01_B0_transition_to_real_organs_master_v2.md
01_B1_transition_real_organs_codex_batch_plan_v2.md
```

### Required workflow context

```text
00_A0_skeleton_dummy_master_implementation_companion.md
day_to_day_skeleton_run.md
final_workflow.md
smoke_module_update_workflow.md
day_to_day_organs_run.md
```

### Topic/background files

Read whatever new files I upload for the actual annex topic. Examples include:

```text
NCA_self_organising_textures_latex.md
ART_latex.md
from_config_to_agentfield_part1_latex.md
from_config_to_agentfield_part2_latex.md
from_config_to_agentfield_part3_latex.md
```

Those example files are not permanently required for every future run. They are required only when the new topic is the ART/NCA core architecture or another topic that depends on them.

---

## 3. Source priority

When files disagree, use this priority order:

```text
1. Explicit user instruction in the current chat.
2. 00_A1_skeleton_dummy_codex_batch_plan_v2.md and 00_A2_skeleton_batch_mapping_report_batches_01_24.md.
3. 01_B0_transition_to_real_organs_master_v2.md and 01_B1_transition_real_organs_codex_batch_plan_v2.md when real-organ transition is relevant.
4. Existing SPEC_Layer*.md files.
5. Existing SPEC_Layer*-ANX*.md files.
6. NEW_CHAT_PROMPT_update_specs.md for naming, mapping, and SPEC/ANX structure.
7. NEW_CHAT_PROMPT_implement_in_codex.md for cache-stable Codex pack and ownership/safety style.
8. NEW_CHAT_PROMPT_batch_creation.md for how hooks are consumed during batch generation.
9. New uploaded background notes and paper drafts.
10. Older product-owner or platform-plan files as background semantics only.
```

Do not assume a file belongs to a layer because of its filename. Classify by concrete steps, paths, outputs, owners, smoke domains, batch timing, and downstream consumers.

---

## 4. Mandatory read order

Read files in this order:

1. `NEW_CHAT_PROMPT_update_specs.md`
2. `NEW_CHAT_PROMPT_implement_in_codex.md`
3. `NEW_CHAT_PROMPT_batch_creation.md`
4. Existing hook examples: `BATCH_CREATION_ANX*.md`
5. Existing annex example: `SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md`
6. Current `SPEC_Layer01` through `SPEC_Layer05` files
7. Skeleton master and skeleton batch authority files
8. Real-organ transition master and batch plan if the topic has real-organ consumers
9. Workflow files: skeleton, organs, final workflow, smoke workflow
10. New uploaded topic/background files

If any required file is missing or unreadable, stop and report the exact missing file path or filename.

---

## 5. Core mapping method

Use this method for each new background note:

```text
background content
  -> extract concrete technical ideas, steps, paths, outputs, schemas, owners, guardrails
  -> match concrete ideas to existing skeleton step names and batch slugs
  -> match downstream real-organ consumers if relevant
  -> infer primary layer, primary batch, secondary skeleton batches, organ batches, smoke domains
  -> create a compact BATCH_CREATION_ANX hook
  -> create a deeper SPEC_Layer...ANX annex
  -> optionally patch NEW_CHAT_PROMPT_batch_creation.md only by adding the hook filename to the hook registry
```

Do not map from layer name first. Map from implementable batch responsibility first.

---

## 6. Output files to create

For each topic, create these files:

```text
BATCH_CREATION_ANX<##>_<topic_slug>.md
SPEC_Layer<##>_<primary-batch-slug>-ANX<##>_<topic_slug>.md
```

Optional only if requested or required:

```text
NEW_CHAT_PROMPT_batch_creation.md
NEW_CHAT_PROMPT_batch_creation.before_<topic_slug>_hook_registry_update.md
```

Do not rewrite `NEW_CHAT_PROMPT_batch_creation.md` unless I explicitly ask you to update it or unless the hook registry must be updated to include the new hook file. If you update it, keep the change minimal and non-destructive.

---

## 7. Hook file structure

The hook file should be compact and consumable by `NEW_CHAT_PROMPT_batch_creation.md`.

Use this structure:

```markdown
<H1> BATCH_CREATION_ANX<##>_<topic_slug>

Status: batch-creation hook for `NEW_CHAT_PROMPT_batch_creation.md`.  
Purpose: make `<canonical SPEC annex filename>` consumable by future skeleton and/or organ batch-generation chats.

## Canonical annex file to request

When the selected batch needs this context, ask the user to upload:

```text
SPEC_Layer<##>_<primary-batch-slug>-ANX<##>_<topic_slug>.md
```

## What this hook represents

<short explanation of what the deeper annex covers and why it matters>

## Batch request rule

| Selected skeleton batch | Ask user to supply the annex? | Batch-creation behavior |
|---:|---|---|
| <batch> `<slug>` | yes, required / optional / optional-strong | <behavior> |

## Real-organ mirror rule

| Organ batch | Ask user to supply the annex? | Behavior |
|---:|---|---|
| <organ> `<organ-slug>` | yes, required / optional / optional-strong | <behavior> |

## How generated batch files should consume it

### Batch <NN>

<only the selected-batch-relevant behavior>

### Batch <NN>

<only the selected-batch-relevant behavior>

## Stop condition language for batch-generation chats

For required batches, if the annex is missing, respond:

```text
Missing required annex for this batch:
- <canonical SPEC annex filename>

Please upload it before I generate the Codex batch package, because this batch must preserve <short reason>.
```

For recommended batches, if the annex is missing, respond:

```text
Recommended annex is missing:
- <canonical SPEC annex filename>

This annex is not strictly required for this batch, but it helps preserve <short reason>. Upload it if available; otherwise confirm I should proceed without it.
```

## Guardrail

This hook does not change the corrected skeleton or real-organ batch slicing. It is contextual implementation guidance only.
```

The hook must not contain the full science/architecture detail. It should only decide whether the full SPEC annex should be requested and how generated batch files should consume it.

---

## 8. Deep SPEC annex structure

The deeper annex must follow the batch-aligned SPEC annex style.

Use this structure:

```markdown
<H1> SPEC_Layer<##>_<primary-batch-slug>-ANX<##>_<topic_slug>

Status: <created/updated from uploaded background>.  
Parent layer spec: `SPEC_Layer<##>_<layer_name>.md`.  
Primary batch placement: **Batch <NN> / `<primary-batch-slug>`**.  
Annex purpose: `<topic purpose>`.  
Batch slicing authority: `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md`.  
Operational authority: `final_workflow.md`, `smoke_module_update_workflow.md`, `day_to_day_skeleton_run.md`, and `day_to_day_organs_run.md` where relevant.

## Why this annex exists
## Most relevant implementation batch
## Related layer and bundle
## Background source notes
## What this extends in the main layer SPEC
## Batch -> implementation relevance
## Concrete steps affected
## Path and ownership contracts
## Output contracts
## Guardrails / non-goals
## Smoke and validation relevance
## How Codex should use this annex when generating a batch
## Real-organ transition relevance
## Open questions
## 24-batch visual map
```

The deeper annex should preserve enough detail from the uploaded background for future batch generation. Do not over-compress implementation-significant details.

---

## 9. What to put in the deep annex

The deep annex should include:

```text
- why the topic exists
- which source files were used
- what concepts were extracted from each source
- primary skeleton batch and secondary skeleton consumers
- real-organ consumers if relevant
- concrete steps affected
- schemas or fields that should exist later
- paths and ownership contracts
- output contracts and filenames
- smoke modules and local smoke relevance
- what Codex should include in PROJECT_CACHE.md / SPEC.md / RUN_INSTRUCTIONS.md for each consuming batch
- guardrails and non-goals
- open questions
```

For research/science annexes, explicitly preserve:

```text
- final pattern similarity is not proof of mechanism
- mechanism evidence must include dynamics, perturbation, constraints, recoverability, and falsification where relevant
- skeleton batches may create schemas/placeholders/dummy outputs only unless a real-organ batch explicitly replaces internals
- live RunPod, live model/provider calls, Paperclip writes, and Agentfield live execution remain guarded by default
```

---

## 10. Hook registry update rule

If `NEW_CHAT_PROMPT_batch_creation.md` is uploaded and I ask you to update it, make only a minimal registry change.

Allowed update:

```text
Add the new hook filename under the existing "Conditional batch-creation ANX hooks" registry.
```

Not allowed unless explicitly requested:

```text
Do not embed full request tables inside NEW_CHAT_PROMPT_batch_creation.md.
Do not paste the deep SPEC annex into NEW_CHAT_PROMPT_batch_creation.md.
Do not remove existing hooks.
Do not rewrite unrelated sections.
```

Before editing, create a backup:

```text
NEW_CHAT_PROMPT_batch_creation.before_<topic_slug>_hook_registry_update.md
```

---

## 11. Required behavior when files are missing

If a required source file is missing or unreadable, stop and report:

```text
I stopped because a required source file is missing or unreadable.

Missing required file(s):
- <filename>

I can still infer: <briefly say what can be inferred, if anything>
I cannot safely generate the final hook + SPEC annex until you upload the missing file(s).
```

Do not invent missing source content.

---

## 12. Validation before final response

Before final response, verify:

```text
- hook file exists and is non-empty
- SPEC annex exists and is non-empty
- both files have exactly one top-level H1 heading
- hook references the canonical SPEC annex filename
- SPEC annex references parent layer, primary batch, and authority files
- if NEW_CHAT_PROMPT_batch_creation.md was updated, a backup exists
- NEW_CHAT_PROMPT_batch_creation.md does not embed long annex tables or deep annex content
```

Use safe local validation only, such as:

```bash
test -s <file>
grep -n '^# ' <file>
grep -n '<canonical SPEC annex filename>' <hook-file>
grep -n 'BATCH_CREATION_ANX' NEW_CHAT_PROMPT_batch_creation.md
```

---

## 13. Final response format

Return a short final response with sandbox links:

```text
Created:
- <hook file link> — compact batch-creation hook.
- <SPEC annex link> — full batch-aligned annex.

Updated:
- <NEW_CHAT_PROMPT_batch_creation.md link> — only if changed.
- <backup link> — only if changed.

Notes:
- primary batch: <NN> <slug>
- secondary skeleton batches: <list>
- real-organ consumers: <list>
- missing optional context: <list or none>
```

---

## 14. Starter instruction I may paste in a new chat

I may use this message:

```text
Read and follow NEW_CHAT_PROMPT_create_batch_creation_hook_and_spec_annex.md.

I am uploading new background material and I want you to create a clean batch-creation hook plus the deeper batch-aligned SPEC annex.

Keep NEW_CHAT_PROMPT_batch_creation.md clean. The batch-creation prompt should consume a compact BATCH_CREATION_ANX<##>_<topic>.md hook, and that hook should request the deeper SPEC_Layer<##>_<batch-slug>-ANX<##>_<topic>.md annex only for the skeleton or organ batches that need it.

Use BATCH_CREATION_ANX01_spectral_operator_dsl_bridge.md as the hook style template.
Use SPEC_Layer02_02-research-workspace-ANX01_workspace_boundaries.md as the SPEC annex style template.
Use NEW_CHAT_PROMPT_update_specs.md for naming, layer/batch mapping, and annex structure.
Use NEW_CHAT_PROMPT_implement_in_codex.md for cache-stable instruction style, ownership, missing-file behavior, and validation discipline.

Treat the current SPEC_Layer files, A1/A2 skeleton authority files, B0/B1 real-organ authority files, and workflow files as the most up-to-date planning authority.

Stop if any required file is missing or unreadable and report the exact missing file.
```

Follow this document exactly when responding to that request.
