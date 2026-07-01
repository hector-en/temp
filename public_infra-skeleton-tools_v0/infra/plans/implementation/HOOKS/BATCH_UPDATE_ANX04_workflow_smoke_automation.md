# BATCH_UPDATE_ANX04_workflow_smoke_automation

Status: batch-update hook for `NEW_CHAT_PROMPT_batch_update.md`.  
Purpose: make `SPEC_Layer01_01-runtime-substrate-ANX04_workflow_smoke_automation.md` consumable when an already-run skeleton or organ batch must be retrofitted with workflow/smoke/evidence automation behavior.

## Canonical annex file to request

When the selected already-run batch needs this update context, ask the user to upload:

```text
SPEC_Layer01_01-runtime-substrate-ANX04_workflow_smoke_automation.md
```

## What this update hook represents

This hook is the update-mode sibling of:

```text
BATCH_CREATION_ANX04_workflow_smoke_automation.md
```

Creation mode asks what a new batch package must include before implementation.  
Update mode asks what an already-run batch is missing, what has drifted, and what safe delta Codex should apply without rerunning the original batch or overwriting original evidence.

The update should preserve:

```text
original POSTCHECK.md
original INTEGRATION_REQUEST.md
original smoke reports
original batch scope
original public output contracts
```

The update may add:

```text
updates/<update-id>/UPDATE_POSTCHECK.md
updates/<update-id>/UPDATE_INTEGRATION_REQUEST.md
updates/<update-id>/CHANGESET_MANIFEST.md
small workflow/evidence/smoke deltas
local smoke routines when the batch-owned subsystem needs them
global smoke module deltas only when a domain contract or platform surface changed
companion/index update instructions only when a checked contract changed
```

## Batch-update request rule

| Target already-run skeleton batch | Ask user to supply the annex? | Batch-update behavior |
|---:|---|---|
| 01 `01-runtime-substrate` | yes, required | Stop and ask for the annex if missing. Update mode verifies runner/evidence/runtime/no-live contracts and applies only missing workflow/smoke deltas. |
| 02 `02-research-workspace` | yes, required | Stop and ask for the annex if missing. Update mode verifies POSTCHECK / INTEGRATION_REQUEST / smoke gating and local/global smoke decisions for the first project-domain workspace. |
| 03-05 Layer 2 setup batches | yes, required | Stop and ask for the annex if missing. Update mode verifies role, PKM, and publisher evidence and smoke coverage without redoing workstation setup. |
| 06-13 Layer 3 research/run batches | yes, required | Stop and ask for the annex if missing. Update mode verifies research/search/local-smoke/RunPod dry-run workflow guardrails and avoids live or large runs. |
| 14-15 Layer 4 reasoning batches | yes, required | Stop and ask for the annex if missing. Update mode verifies selected-context, no-live-model, smoke, and companion guardrails. |
| 16-24 Layer 5 orchestration batches | yes, required | Stop and ask for the annex if missing. Update mode verifies Agentfield, Paperclip, and campaign guarded-live boundaries plus smoke coverage decisions. |

## Real-organ update mirror rule

| Already-run organ batch | Ask user to supply the annex? | Behavior |
|---:|---|---|
| R01 `real-contract-audit-runtime-role-readiness` | yes, required | Verify skeleton contract audit evidence, role readiness, smoke gates, and no-overwrite update evidence. |
| R02-R06 research organ batches | yes, required | Verify preserved skeleton contracts, local organ smoke, global GRN/search smoke coverage, and no expensive/live runs. |
| R07 `real-runpod-boundary` | yes, required | Verify guarded RunPod dry-run-to-live boundary and forbid accidental live infrastructure actions. |
| R08-R11 platform organ batches | yes, required | Verify OpenClaw, Agentfield, Paperclip, campaign, review, and guarded-live smoke decisions. |
| R12 end-to-end real local smoke | yes, required | Verify end-to-end local no-live smoke evidence and final classification rules. |

## Required evidence inputs for update-mode chats

For skeleton updates, request or inspect:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
latest relevant /workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md if available
/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md if available
```

For organ updates, request or inspect:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
latest relevant /workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md if available
/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md if available
relevant skeleton companion/evidence if the organ batch must preserve a skeleton contract
```

If original POSTCHECK or INTEGRATION_REQUEST is missing, classify the update as evidence reconciliation instead of normal delta update.

## How generated update files should consume it

### Every skeleton batch update

Add the annex to `PROJECT_UPDATE_CACHE.md` as a required read-only input. The generated `UPDATE_SPEC.md` and `UPDATE_RUN_INSTRUCTIONS.md` should include:

```text
Do not regenerate the original batch.
Do not overwrite original POSTCHECK.md or INTEGRATION_REQUEST.md.
Read original evidence and latest smoke report before editing anything.
Write update evidence under /mnt/egress/dev-recordings/skeleton/<batch-slug>/updates/<update-id>/.
Apply only missing workflow/smoke/evidence deltas.
Run the active dynamic smoke runner for skeleton-progress after the update.
Record the new SMOKE_REPORT.md path in UPDATE_POSTCHECK.md.
Do not start dependent update/creation work until PASS, SKIP, or accepted documented WARN is recorded.
Do not edit config/lv/workflow internals during update work.
Decide whether the update requires a local smoke routine, a global smoke.d module update, a runner/protocol update, or no smoke code change.
Do not create one global smoke module per batch.
```

### Every organ batch update

Add the annex to `PROJECT_UPDATE_CACHE.md` as a required read-only input. The generated organ `UPDATE_SPEC.md` and `UPDATE_RUN_INSTRUCTIONS.md` should include:

```text
Do not regenerate the original organ batch.
Do not overwrite original organ evidence.
Read original organ evidence, relevant skeleton evidence, and latest smoke report before editing anything.
Write update evidence under /mnt/egress/organs/dev-recordings/organs/<batch-slug>/updates/<update-id>/.
Apply only missing workflow/smoke/evidence deltas.
Run the active dynamic smoke runner for organ-progress after the update.
Record the new SMOKE_REPORT.md path in UPDATE_POSTCHECK.md.
Do not start dependent update/creation work until PASS, SKIP, or accepted documented WARN is recorded and the relevant skeleton output contract remains preserved.
Do not run live providers, live RunPod, Paperclip writes, Agentfield live execution, Kubernetes mutation, or Terraform mutation unless explicitly approved by the organ update pack.
```

## Stop condition language for batch-update chats

For required skeleton or organ updates, if the annex is missing, respond:

```text
Missing required workflow/smoke automation annex for this already-run batch update:
- SPEC_Layer01_01-runtime-substrate-ANX04_workflow_smoke_automation.md

Please upload it before I generate the Codex update package, because this update must compare existing evidence against the day-to-day evidence, smoke, local/global smoke-module decision, and stop/continue gates.
```

If original evidence is missing, respond with a classification, not a hard failure:

```text
Original batch evidence is incomplete. I will classify this as an evidence-reconciliation update instead of a normal delta update.
Missing original evidence:
- <path>
```

## Update classifications

Use exactly one primary classification in each generated update pack:

| Classification | Meaning | Typical allowed delta |
|---|---|---|
| `evidence-reconciliation` | Original batch ran but required evidence is missing or incomplete. | Create update evidence and optionally reconstruct pointers from available files without inventing results. |
| `smoke-run-reconciliation` | Code/evidence exists, but smoke was not run or report path is missing. | Generate smoke execution instructions and record result path. |
| `local-smoke-routine-update` | A batch-owned subsystem needs a local repeatable smoke routine. | Add/update project-local smoke routine only. |
| `global-smoke-module-update` | A domain contract/platform surface changed and global current-state coverage must change. | Update smallest domain-owned `/workspace/tests/smoke.d/*.smoke.sh` module. |
| `runner-protocol-update` | Smoke architecture, phase behavior, or report contract changed. | Update protocol/orchestrator only if explicitly required. |
| `instruction-contract-update` | Batch instructions need new workflow/evidence gates but implementation code is unchanged. | Update generated instructions/templates and write update evidence. |
| `companion-index-update` | A checked contract changed and readable companion/index must reflect it. | Create/update companion docs only after evidence/smoke classification. |
| `blocking-repair` | Existing implementation contradicts required contract. | Stop normal update flow and create a repair pack with explicit failing contract. |

## Guardrail

This hook does not change the corrected skeleton or real-organ batch slicing. It is update-mode workflow guidance only. It must not embed full workflow files, full smoke update tables, or full annex content into `NEW_CHAT_PROMPT_batch_update.md`.
