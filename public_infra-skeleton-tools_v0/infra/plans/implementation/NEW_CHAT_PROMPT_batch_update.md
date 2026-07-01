# NEW_CHAT_PROMPT_batch_update — Generate One Delta Codex Pack for an Already-Run Batch

Use this prompt in a fresh chat when an already-run skeleton or organ batch must be updated because a new workflow rule, smoke rule, annex hook, evidence requirement, or contract clarification was introduced after the batch was originally implemented.

This prompt is not for normal batch creation. Use `NEW_CHAT_PROMPT_batch_creation.md` when the batch has not been run yet.

## Core distinction

```text
batch_creation = generate a fresh Codex pack for a not-yet-run batch
batch_update   = generate a delta Codex pack for an already-run batch
```

Update mode must never regenerate a completed batch as if it were new. It reads existing evidence, compares it against the selected update hook/annex, and creates a small Codex update pack that applies only the missing delta.

## Required user variables

The user should provide these values in the prompt:

```text
TARGET_TRACK=skeleton|organ
TARGET_BATCH=<01-24 or R01-R12>
TARGET_SLUG=<existing-batch-slug>
UPDATE_TOPIC=<short hook/update topic>
```

Examples:

```text
TARGET_TRACK=skeleton
TARGET_BATCH=01
TARGET_SLUG=01-runtime-substrate
UPDATE_TOPIC=workflow_smoke_automation
```

```text
TARGET_TRACK=organ
TARGET_BATCH=R07
TARGET_SLUG=real-runpod-boundary
UPDATE_TOPIC=workflow_smoke_automation
```

If the user does not provide all four variables, infer what is obvious from filenames and context. If `TARGET_TRACK`, `TARGET_BATCH`, or `TARGET_SLUG` cannot be inferred, stop and ask only for the missing values.

## Files I will upload to the new chat

### Required prompt/update authority

```text
NEW_CHAT_PROMPT_batch_update.md
update_workflow.md
NEW_CHAT_PROMPT_batch_creation.md
NEW_CHAT_PROMPT_implement_in_codex.md
```

### Required platform authority

```text
00_A0_skeleton_dummy_master_implementation_companion.md
00_A1_skeleton_dummy_codex_batch_plan_v2.md
00_A2_skeleton_batch_mapping_report_batches_01_24.md
01_B0_transition_to_real_organs_master_v2.md
01_B1_transition_real_organs_codex_batch_plan_v2.md
CONFIG_TOOL.md
```

### Required workflow authority

```text
day_to_day_skeleton_run.md
final_workflow.md
smoke_module_update_workflow.md
day_to_day_organs_run.md
```

`day_to_day_organs_run.md` is required only when `TARGET_TRACK=organ`, but it may be read as context for skeleton updates too.

### Required layer/spec context

Upload the relevant main layer SPEC and any relevant deep annex SPEC files. For the workflow/smoke automation update topic, upload:

```text
SPEC_Layer01_01-runtime-substrate-ANX04_workflow_smoke_automation.md
BATCH_UPDATE_ANX04_workflow_smoke_automation.md
```

For other update topics, upload the matching `BATCH_UPDATE_ANX*.md` hook and the deep `SPEC_Layer...ANX...md` annex it requests.

### Required existing evidence for the target batch

For skeleton updates, provide or make accessible:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
latest relevant /workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md if available
/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md if available
```

For organ updates, provide or make accessible:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
latest relevant /workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md if available
/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md if available
relevant skeleton evidence/companion if the organ batch preserves a skeleton contract
```

If original evidence is missing, do not invent it. Classify the pack as `evidence-reconciliation` and make Codex write update evidence that records the missing input.

## Conditional batch-update ANX hooks

Keep this update prompt clean. Do not embed full conditional annex tables here. Instead, use compact `BATCH_UPDATE_ANX*.md` hook files.

Current update hook files:

```text
BATCH_UPDATE_ANX04_workflow_smoke_automation.md
```

Use each hook file as follows:

```text
1. Read the hook file.
2. Check whether TARGET_TRACK and TARGET_BATCH are listed as required or recommended.
3. If required and missing, stop with the exact missing-file language from the hook.
4. If recommended and missing, ask using the hook's recommended-file language and proceed only according to the hook rule.
5. If the full SPEC annex is provided, read it after the relevant layer SPEC and before writing the generated update files.
6. Put only target-batch-relevant points into PROJECT_UPDATE_CACHE.md, UPDATE_SPEC.md, and UPDATE_RUN_INSTRUCTIONS.md.
7. Do not paste the full hook or full SPEC annex into generated update files.
```

The update hooks do not change the corrected 01-24 skeleton batch slicing or the R01-R12 organ slicing. They only decide which extra full annex files should be requested for an already-run batch update and how those annexes should be consumed.

## Output files to create

Create one Codex-ready update package. The package should contain exactly:

```text
CODEX_UPDATE_PROMPT.txt
PROJECT_UPDATE_CACHE.md
UPDATE_SPEC.md
UPDATE_RUN_INSTRUCTIONS.md
UPDATE_POSTCHECK_TEMPLATE.md
```

Optional zip name pattern:

```text
codex_<target-track>_batch_update_<target-batch>_<target-slug>_<update-topic>.zip
```

Examples:

```text
codex_skeleton_batch_update_01_01-runtime-substrate_workflow_smoke_automation.zip
codex_organ_batch_update_R07_real-runpod-boundary_workflow_smoke_automation.zip
```

Do not create a normal implementation batch zip from this prompt.

## Update evidence paths that generated packs must require

For skeleton updates:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/updates/<update-id>/UPDATE_POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/updates/<update-id>/UPDATE_INTEGRATION_REQUEST.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/updates/<update-id>/CHANGESET_MANIFEST.md
```

For organ updates:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/updates/<update-id>/UPDATE_POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/updates/<update-id>/UPDATE_INTEGRATION_REQUEST.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/updates/<update-id>/CHANGESET_MANIFEST.md
```

Use an update id like:

```text
<YYYYMMDD>_<update-topic>
```

If Codex cannot know the date at runtime, tell it to compute it with `date +%Y%m%d` and use only ASCII characters in filenames.

## Update classification

Every generated update pack must set exactly one primary classification:

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

Classification rules:

```text
- Missing original POSTCHECK.md or INTEGRATION_REQUEST.md -> evidence-reconciliation.
- Missing smoke report path but code/evidence exists -> smoke-run-reconciliation.
- Batch-owned subsystem needs a local repeatable check -> local-smoke-routine-update.
- Domain surface changed and global current-state coverage must change -> global-smoke-module-update.
- Smoke phase/protocol/orchestrator/report contract changed -> runner-protocol-update.
- Existing generated instructions need new gates but code is unchanged -> instruction-contract-update.
- Checked readable docs/index must change after evidence/smoke -> companion-index-update.
- Existing implementation contradicts a required contract -> blocking-repair.
```

## Required generated file design

### CODEX_UPDATE_PROMPT.txt

Must instruct Codex to:

```text
1. Read UPDATE_SPEC.md, PROJECT_UPDATE_CACHE.md, UPDATE_RUN_INSTRUCTIONS.md, and UPDATE_POSTCHECK_TEMPLATE.md.
2. Confirm all required read-only inputs exist.
3. Stop if any required input is missing, except original batch evidence that the update pack explicitly classifies as missing evidence to reconcile.
4. Apply only the listed delta tasks.
5. Never regenerate the original batch.
6. Never overwrite original POSTCHECK.md, INTEGRATION_REQUEST.md, or historical smoke reports.
7. Write UPDATE_POSTCHECK.md, UPDATE_INTEGRATION_REQUEST.md, and CHANGESET_MANIFEST.md under the update evidence path.
8. Run only the validation commands named in UPDATE_RUN_INSTRUCTIONS.md.
9. Run the active dynamic smoke command only if the update pack includes a smoke execution task.
10. Do not edit config/lv/workflow internals unless the update is explicitly a config-integration milestone.
```

### PROJECT_UPDATE_CACHE.md

Must be compact and stable. Include:

```text
Target track
Target batch
Target slug
Update topic
Update classification
Relevant layer/spec files
Relevant hook files
Original evidence paths
Expected update evidence path
Smoke phase
Smoke domains touched
Files Codex may edit
Files Codex must not edit
Safety boundaries
```

### UPDATE_SPEC.md

Must include:

```text
Purpose
Why this is an update and not a rerun
Current evidence assessment
Required read-only inputs
Control model / architecture
Canonical paths
Update classification
Allowed delta
Forbidden changes
Safety contract
Idempotency contract
Acceptance criteria
Validation overview
```

### UPDATE_RUN_INSTRUCTIONS.md

Must include:

```text
Task list with small numbered tasks
Each task says: Implement only Task N
Files to read for each task
Files allowed to create/edit for each task
Stop conditions for each task
Exact validation commands
Smoke execution command, when applicable
Expected update evidence outputs
```

### UPDATE_POSTCHECK_TEMPLATE.md

Must include fields for:

```text
Target track
Target batch
Target slug
Update id
Update topic
Update classification
Original evidence checked
Original smoke report checked
Files created/updated
Files intentionally not touched
Contracts preserved
Local smoke routine decision
Global smoke module decision
Runner/protocol decision
Validation commands run
Smoke command run
New SMOKE_REPORT.md path
PASS/SKIP/WARN/FAIL classification
Accepted WARN rationale, if any
Open blockers
```

## Smoke command patterns

Skeleton progress smoke:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh skeleton-progress
```

or, if migrated:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

Organ progress smoke:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh organ-progress
```

or, if migrated:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress
```

Do not keep two independent runner implementations. `/workspace/scripts/smoke.sh` may be the current active runner or a compatibility wrapper; `/workspace/scripts/smoke_current_state.sh` is the final canonical runner.

## Safety rules

Generated update packs must preserve these boundaries:

```text
Do not edit the config tool.
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh unless this is explicitly a config-integration milestone.
Do not read or print secrets.
Do not run Terraform apply/destroy.
Do not mutate Kubernetes.
Do not launch RunPod.
Do not call live model/provider APIs.
Do not write live Paperclip data.
Do not run live Agentfield execution unless explicitly approved.
Do not run expensive experiments or training.
Do not rewrite historical evidence.
```

## Final response required from ChatGPT

When the update pack is generated, summarize:

```text
Target track / batch / slug
Update topic
Update classification
Files created
Required original evidence status
Whether smoke execution is included
Any missing inputs or blockers
```

If files are created in the sandbox, link them in the final answer.
