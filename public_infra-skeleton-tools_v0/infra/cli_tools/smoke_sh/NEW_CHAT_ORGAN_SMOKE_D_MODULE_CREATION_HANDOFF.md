# New Chat Handoff — Organ `smoke.d` Module Creation

Use this file to continue creating dynamic smoke-test modules for the real-organ batches in a new ChatGPT chat.

This handoff assumes the dynamic smoke-test framework already exists in the project:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/
```

The goal is to go **organ batch by organ batch**, inspect what each real-organ batch actually implemented, and create or update the smallest safe idempotent smoke module that checks that implementation.

---

## 1. Upload these files to the new ChatGPT chat

Upload the latest available versions of:

```text
transition_real_organs_codex_batch_plan.md
00_transition_to_real_organs_master.md
00_skeleton_dummy_master_implementation_companion.md
skeleton_dummy_codex_batch_plan.md
latest workspace codebase analysis output
latest organ dev-recordings summary or full code-analysis output
latest skeleton companion or skeleton contract summary
latest organ companion docs if present
```

For the specific organ batch being handled, also upload or summarize:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
/workspace/runs/smoke/<latest>/SMOKE_REPORT.md if one already exists
```

Do not upload secrets, credentials, vault contents, private datasets, or live provider tokens.

---

## 2. Required project files Codex must have access to

Before asking Codex to create or repair an organ smoke module, ensure these files are already present in the project:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/
/workspace
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

If any required file is missing, Codex must stop and list the exact missing path. Codex must not invent evidence.

---

## 3. Organ batch order from the transition plan

The transition plan defines these real-organ batches:

| Batch | Branch / slug hint | Scope | Primary smoke target |
|---|---|---|---|
| R01 | `R01-contract-audit` | Real workspace contract audit | evidence/contract smoke |
| R02 | `R02-real-grn-dsl-simulator` | Real GRN DSL and simulator core | GRN DSL/simulator smoke |
| R03 | `R03-real-nca-local-rule` | Real NCA local-rule organ | NCA dry-run smoke |
| R04 | `R04-real-art2-artmap` | Real ART2 / ARTMAP prototype organs | ART clustering/mapping smoke |
| R05 | `R05-real-mechanism-report` | Real mechanism report organ | report generation smoke |
| R06 | `R06-real-parameter-search` | Real parameter search organ | local search smoke |
| R07 | `R07-real-runpod-boundary` | Real RunPod dry-run-to-live boundary | RunPod dry-run/gating smoke |
| R08 | `R08-real-openclaw-pkm-bridge` | Real OpenClaw/PKM reasoning bridge | PKM/reasoning dry-run smoke |
| R09 | `R09-real-agentfield-experiment` | Real Agentfield experiment organ | Agentfield lifecycle dry-run smoke |
| R10 | `R10-real-paperclip-adapter` | Real Paperclip adapter organ | guarded adapter dry-run smoke |
| R11 | `R11-real-campaign-orchestration` | Real campaign orchestration organ | resumable campaign local smoke |
| R12 | `R12-end-to-end-real-local-smoke` | End-to-end real local smoke | all-organ local no-live smoke |

The transition plan says real-organ batches must preserve the existing skeleton commands, filenames, schemas, and smoke-test expectations unless the transition master explicitly changes them. It also says implementation batches must not edit the config tool and must write evidence under `/mnt/egress/organs/dev-recordings`. 

---

## 4. Important corrected paths

Use the corrected shared workspace model:

```text
Project workspace / shared code root:
/workspace

Organ evidence root:
/mnt/egress/organs/dev-recordings/

Organ batch evidence:
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/

Organ companion docs:
/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md
```

Do not use `/home/researchscientist/workspace` as the shared project root in new smoke-module instructions. Use `/workspace`.

---

## 5. Dynamic smoke-test rule

Do **not** create one new smoke file for every batch by default.

Create or update the smoke module that matches the domain introduced by the batch:

| Organ batch type | Preferred smoke module |
|---|---|
| general organ evidence / dry-run contract | `/workspace/tests/smoke.d/20-organs.smoke.sh` |
| GRN DSL/simulator | `/workspace/tests/smoke.d/80-grn.smoke.sh` |
| NCA local rule | `/workspace/tests/smoke.d/81-nca.smoke.sh` or extend `20-organs.smoke.sh` if small |
| ART2 / ARTMAP | `/workspace/tests/smoke.d/82-art.smoke.sh` |
| mechanism report | `/workspace/tests/smoke.d/83-mechanism-report.smoke.sh` |
| parameter search | `/workspace/tests/smoke.d/84-parameter-search.smoke.sh` |
| RunPod boundary | `/workspace/tests/smoke.d/70-runpod.smoke.sh` |
| OpenClaw / PKM bridge | `/workspace/tests/smoke.d/60-openclaw-pkm.smoke.sh` |
| Agentfield | `/workspace/tests/smoke.d/60-agentfield.smoke.sh` |
| Paperclip adapter | `/workspace/tests/smoke.d/85-paperclip.smoke.sh` |
| campaign orchestration | `/workspace/tests/smoke.d/86-campaign.smoke.sh` |
| full local end-to-end | `/workspace/tests/smoke.d/99-end-to-end-real-local.smoke.sh` |

If an existing module already covers the new behavior cleanly, update that module instead of creating a new one.

---

## 6. Safety rules for organ smoke modules

Every organ smoke module must be:

```text
idempotent
local-first
non-destructive
phase-aware
evidence-aware
contract-preserving
```

Organ smoke modules may:

```text
read project code under /workspace
read POSTCHECK.md and INTEGRATION_REQUEST.md
run dry-run/local commands
validate schemas and expected output filenames
write only smoke reports under /workspace/runs/smoke/...
return PASS, WARN, FAIL, BLOCKED, or SKIP
```

Organ smoke modules must not:

```text
run live organs
spend provider credits
create RunPod jobs
call live Paperclip writes
run OpenClaw agents live
submit live Agentfield experiments
apply Terraform
apply Kubernetes manifests
edit config/lv/workflow files
install packages
read or print secrets
remove old smoke reports
```

If a dependency is missing, the module should return `WARN` or `BLOCKED` and name the exact missing command/path. It should not install the dependency.

---

## 7. Prompt to ChatGPT in the new chat

Use this prompt after uploading the current codebase analysis, plan files, and batch evidence:

```text
We are continuing dynamic smoke.d module creation for real-organ batches.

Read the uploaded:
- transition_real_organs_codex_batch_plan.md
- 00_transition_to_real_organs_master.md if uploaded
- 00_skeleton_dummy_master_implementation_companion.md if uploaded
- latest workspace codebase analysis
- latest organ POSTCHECK.md and INTEGRATION_REQUEST.md for the selected batch
- latest skeleton companion/contract summary if uploaded

Use /workspace as the shared project root.
Use /mnt/egress/organs/dev-recordings/organs/<batch-slug>/ for organ evidence.
Use /workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md as the smoke-test protocol.

Create the Codex prompt for the next organ batch only: <batch-slug>.
The prompt must name the exact files Codex should read and the exact smoke module path to create or update.
Do not repeat the full contents of docs that Codex can read from files.
Do not ask Codex to create docs already authored by ChatGPT.
Do not allow live actions.
```

---

## 8. Prompt to Codex for one organ batch

Replace `<batch-slug>`, `<phase>`, and `<module-path>`.

```text
Read these files first:

/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md

Also inspect only the relevant implementation files under:
/workspace

Create or update this smoke module:
<module-path>

Implement the smallest safe idempotent smoke check for organ batch <batch-slug>.
The module must support:

bash <module-path> detect
bash <module-path> run <phase> <report_dir>

Rules:
- preserve the dynamic smoke module contract
- run safe local/dry-run checks only
- do not run live organs
- do not call live providers
- do not create RunPod jobs
- do not apply Terraform or Kubernetes
- do not edit config
- do not install packages
- do not delete old smoke reports
- if required evidence is missing, return BLOCKED with exact missing path
- if optional readiness is missing, return WARN with exact missing path
- if the domain does not exist yet, return SKIP from detect

After creating or updating the module, run:

BATCH_SLUG="<batch-slug>" smoke <phase>

If the smoke wrapper is unavailable, run:

BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh <phase>

Then update:

/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md

with:
- smoke module path
- command run
- SMOKE_REPORT.md path
- result PASS/WARN/FAIL/BLOCKED/SKIP
- any missing files or follow-up fixes

Output:
Changed files:
Tests run:
Smoke report:
Notes:
```

---

## 9. Phase to use per organ step

| Situation | Phase |
|---|---|
| after one organ batch | `organ-progress` |
| after all organ batches | `organ-complete` |
| before config integration | `pre-config` |
| after config integration | `post-config` |
| generic check anytime | `current-state` |

Typical command:

```bash
BATCH_SLUG="R02-real-grn-dsl-simulator" smoke organ-progress
```

Fallback command:

```bash
BATCH_SLUG="R02-real-grn-dsl-simulator" bash /workspace/scripts/smoke_current_state.sh organ-progress
```

---

## 10. Batch-by-batch starting prompts

### R01

```text
Create or update /workspace/tests/smoke.d/20-organs.smoke.sh for R01 contract audit evidence checks. It should validate that POSTCHECK.md and INTEGRATION_REQUEST.md exist for the batch and that the current organ evidence does not claim config edits or live actions.
```

### R02

```text
Create or update /workspace/tests/smoke.d/80-grn.smoke.sh for R02 real GRN DSL and simulator checks. It should run only tiny deterministic local parse/simulator checks discovered from the implementation evidence. Do not run long training.
```

### R03

```text
Create or update /workspace/tests/smoke.d/81-nca.smoke.sh for R03 real NCA local-rule checks. It should run only local dry-run/evaluation paths and validate skeleton-compatible outputs.
```

### R04

```text
Create or update /workspace/tests/smoke.d/82-art.smoke.sh for R04 ART2/ARTMAP checks. It should run only tiny deterministic clustering/mapping checks and validate expected output files.
```

### R05

```text
Create or update /workspace/tests/smoke.d/83-mechanism-report.smoke.sh for R05 mechanism report checks. It should use existing simulator/NCA/ART/perturbation outputs when present and validate report creation without inventing evidence.
```

### R06

```text
Create or update /workspace/tests/smoke.d/84-parameter-search.smoke.sh for R06 parameter search checks. It should run only tiny local search/dry-run checks and validate comparable result records.
```

### R07

```text
Create or update /workspace/tests/smoke.d/70-runpod.smoke.sh for R07 RunPod boundary checks. It should validate dry-run job specs and live-gate behavior only. It must not create pods or spend credits.
```

### R08

```text
Create or update /workspace/tests/smoke.d/60-openclaw-pkm.smoke.sh for R08 OpenClaw/PKM bridge checks. It should validate safe artifact/PKM selection and dry-run reasoning wrappers without dumping private notes or running live agents.
```

### R09

```text
Create or update /workspace/tests/smoke.d/60-agentfield.smoke.sh for R09 Agentfield experiment checks. It should validate lifecycle/controller dry-run behavior only. It must not submit live experiments.
```

### R10

```text
Create or update /workspace/tests/smoke.d/85-paperclip.smoke.sh for R10 Paperclip adapter checks. It should validate request/status/artifact mapping behind guarded dry-run mode only. It must not write live Paperclip records.
```

### R11

```text
Create or update /workspace/tests/smoke.d/86-campaign.smoke.sh for R11 campaign orchestration checks. It should validate resumable campaign local dry-run behavior and guard rails only.
```

### R12

```text
Create or update /workspace/tests/smoke.d/99-end-to-end-real-local.smoke.sh for R12 end-to-end local smoke. It should run the full local no-live organ path only, consume prior batch outputs if present, and validate that the skeleton contract still holds.
```

---

## 11. Acceptance criteria for each organ smoke step

For each batch, the final result should have:

```text
1. One created or updated /workspace/tests/smoke.d/*.smoke.sh module.
2. The module implements detect and run.
3. The module is safe/idempotent/non-live.
4. The smoke command was run with the correct BATCH_SLUG and phase.
5. A timestamped /workspace/runs/smoke/.../SMOKE_REPORT.md exists.
6. The batch POSTCHECK.md records the module path, command, report path, and result.
7. No config/lv/workflow files were edited.
8. No package installs were performed by the smoke module.
9. No live providers, live organs, deploys, applies, or cost-spending actions were run.
```

---

## 12. What to ask next after each batch

After Codex completes one batch smoke module, bring the result back to ChatGPT with:

```text
Here is the updated codebase analysis after organ smoke module <batch-slug>.
Here is the POSTCHECK.md.
Here is the INTEGRATION_REQUEST.md.
Here is the SMOKE_REPORT.md.
Check whether the smoke module is safe, idempotent, phase-aware, and correctly mapped to the organ batch. Then give me the next Codex prompt for the next organ batch.
```
