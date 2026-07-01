# Day-to-Day Organs Run — Updated Organ File Ledger with O-T4 Split

This file is the updated operational ledger for transition-to-real-organs work.

It updates the original `organs_full_step_file_ledger.md` using:

```text
01_transition_to_real_organs_master_UPDATED.md
transition_real_organs_codex_batch_plan_UPDATED.md
final_workflow.md
```

It preserves the named-file prompt rule:

```text
Prompt the agent to read and follow named files.
Do not paste or repeat full instructions from those files unless the file is missing, being repaired, or intentionally being regenerated.
```

The main update is that **O-T4 is split**:

```text
O-T4A — ChatGPT prepares a compact, cache-aware organ smoke execution instruction set.
O-T4B — Codex executes only that instruction set.
```

This keeps Codex as the execution model and avoids asking it to re-read full background files for every smoke run.

---

## 0. Current organ runner rule

There is one conceptual runner: the **dynamic smoke orchestrator**.

It discovers global smoke modules, runs them for the requested phase, and writes a timestamped smoke report.

```text
runner
  -> discovers /workspace/tests/smoke.d/*.smoke.sh
  -> runs applicable global smoke modules
  -> may call project-local organ smoke routines through those modules
  -> writes /workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
```

### Current compatibility rule

If the workspace currently has `/workspace/scripts/smoke.sh` as the implemented active runner, use it until a dedicated D-SM2 runner migration is performed:

```bash
BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke.sh organ-progress
```

If the workspace has migrated to the final canonical runner, use:

```bash
BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress
```

### Final intended state

```text
/workspace/scripts/smoke_current_state.sh
  canonical real orchestrator

/workspace/scripts/smoke.sh
  compatibility wrapper that calls smoke_current_state.sh
```

Do not keep two independent smoke implementations.

---

## 1. Canonical organ roots

| Root | Meaning |
|---|---|
| `/workspace` | Shared project workspace with completed skeleton and organ implementation code. |
| `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` | Dynamic smoke protocol/spec. Update only when smoke architecture changes. |
| `/workspace/scripts/smoke_current_state.sh` | Final canonical dynamic smoke runner/orchestrator. |
| `/workspace/scripts/smoke.sh` | Current implemented runner or compatibility wrapper, depending on migration state. |
| `/workspace/tests/smoke.d/*.smoke.sh` | Global domain-owned smoke modules. |
| `/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md` | Smoke result for one phase run. |
| `/workspace/runs/smoke/<timestamp-phase>/module-results/` | Per-module logs. |
| `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md` | Organ batch postcheck evidence. |
| `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md` | Organ handoff request for later operator config integration. |
| `/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md` | Organ companion output. |
| `/mnt/ingress/infra/organs/companion/INDEX.md` | Optional organ companion index. |
| `/mnt/ingress/infra/skeleton/companion/<skeleton-slug>/COMPANION.md` | Relevant skeleton companion/contract that organ work must preserve. |

---

## 2. Day-to-day organ loop

Use this loop for every organ batch:

```text
O-T1  ChatGPT creates one organ batch package.
O-T2  Human/Codex stages the package.
O-T3  Codex implements the organ batch.
O-T4A ChatGPT prepares a cache-aware organ smoke instruction set.
O-T4B Codex executes only that instruction set.
O-T5  Human/ChatGPT classifies PASS/WARN/FAIL.
O-T6  ChatGPT/Codex updates organ companion only at logical checkpoints or contract changes.
Repeat until final organ batch.
O-T7  Run organ-complete smoke.
O-T8  Create organ/config integration manifest after organ-complete.
O-T9  Run vmuser/operator config integration later, not during organ implementation.
```

Minimum day-to-day rule:

```text
Do not start the next organ batch until the current organ batch has:
1. POSTCHECK.md
2. INTEGRATION_REQUEST.md
3. a smoke report path
4. PASS, SKIP, or accepted documented WARN
5. preserved the relevant skeleton output contract
```

---

## 3. Updated real-organ batch map

The updated transition batch plan uses the corrected skeleton contracts and smoke domain model.

| Organ batch | Depends on corrected skeleton batch(es) | Scope | Primary smoke domain(s) |
|---:|---|---|---|
| R01 | 01, 02, 03, 04, 05 | Real contract audit and runtime/role readiness | `10-core-layout`, `20-python-package`, `30-skeleton-evidence`, `50-config-boundary`, `60-infra-tools`, `90-research-assistant` |
| R02 | 02, 06, 07 | Real GRN DSL and simulator core | `70-grn-contract` |
| R03 | 07, 09 | Real NCA local-rule organ | `70-grn-contract` |
| R04 | 07, 08 | Real ART2 / ARTMAP prototype organs | `70-grn-contract` |
| R05 | 08, 09 | Real mechanism report organ | `70-grn-contract` |
| R06 | 10, 11, 12 | Real parameter search organ | `70-grn-contract`, future `72-search-contract` if split |
| R07 | 01, 13 | Real RunPod dry-run-to-live boundary | `60-infra-tools`, future `75-runpod-dryrun` |
| R08 | 04, 14, 15 | Real OpenClaw/PKM reasoning bridge | future `80-openclaw-pkm` |
| R09 | 03, 16, 17, 18 | Real Agentfield experiment organ | future `85-agentfield` |
| R10 | 19, 20 | Real Paperclip adapter organ | future `86-paperclip-adapter` |
| R11 | 21, 22, 23, 24 | Real campaign orchestration organ | future `88-agentfield-campaign`, future `75-runpod-dryrun`, future `86-paperclip-adapter` for payload shape |
| R12 | all prior R batches and corrected skeleton 01–24 | End-to-end real local smoke | all applicable discovered smoke domains |

---

## 4. Step O-T1 — Create organ batch in ChatGPT

| Field | Exact content |
|---|---|
| Step owner | ChatGPT only. Codex is not used in this step. |
| When | After the relevant skeleton contract is stable and skeleton-complete or group-level readiness is acceptable. |
| ChatGPT prompt | Read and follow `general_new_chat_organ_batch_generation_prompt.md`. Set `BATCH_NUMBER=<RNN or N>`. Use the updated transition master, updated real-organs batch plan, templates, and skeleton companion contract named below. Produce one Codex-ready organ batch package. Do not repeat template prompts manually; use the uploaded files. |
| Upload to ChatGPT | `general_new_chat_organ_batch_generation_prompt.md`; `01_transition_to_real_organs_master_UPDATED.md`; `transition_real_organs_codex_batch_plan_UPDATED.md`; `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; `CONFIG_TOOL.md` for context only; relevant skeleton `COMPANION.md` or skeleton contract summary; optional latest organ `COMPANION.md`/`INDEX.md`; optional latest organ dev-recordings summary. |
| ChatGPT creates | `codex_organ_batch_<N>_<slug>.zip`; batch `CODEX_PROMPT.txt`; batch `PROJECT_CACHE.md`; batch `SPEC.md`; batch `RUN_INSTRUCTIONS.md`; batch `POSTCHECK_TEMPLATE.md`; optional batch README/checklist; optional missing-file report. |
| Codex must have access to | Not applicable during this step. The created zip is for O-T2/O-T3. |
| Codex prompt | Not applicable. Do not run Codex yet. |
| Codex may run | Nothing. |
| Codex creates/updates | Nothing. |
| Codex must not create | Project code; organ evidence; companion docs; integration manifest; config/lv/workflow edits. |

---

## 5. Step O-T2 — Stage organ batch for Codex

| Field | Exact content |
|---|---|
| Step owner | Human or Codex for extraction/staging. ChatGPT only for optional sanity check. |
| When | Immediately after O-T1 creates the organ batch zip. |
| ChatGPT prompt | Optional only: inspect this organ batch file list against expected batch package files and skeleton contract inputs. Do not regenerate instructions unless required files are missing. |
| Upload to ChatGPT | Optional: zip file listing; generated `CODEX_PROMPT.txt`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; relevant skeleton `COMPANION.md`; file listing. |
| ChatGPT creates | Optional pre-run sanity checklist; optional missing-file list. |
| Codex must have access to | `codex_organ_batch_<N>_<slug>.zip` or extracted folder; `/workspace` with completed skeleton; batch `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; `CODEX_ORGAN_RECORDING_INSTRUCTIONS.md` if not included; relevant skeleton `COMPANION.md`/contract; writable `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/`. |
| Codex prompt | Extract/stage the generated organ batch. Confirm these files exist: `CODEX_PROMPT.txt`, `PROJECT_CACHE.md`, `SPEC.md`, `RUN_INSTRUCTIONS.md`, `POSTCHECK_TEMPLATE.md`, and the relevant skeleton companion/contract. Do not execute implementation yet unless O-T3 is explicitly started. |
| Codex may run | `unzip`; `list`; `test -f`; `cat`; `head`; `find`; `tree`; `mkdir -p` for required organ evidence folder. |
| Codex creates/updates | Extracted organ batch folder; optional staging log; required organ evidence folder if missing. |
| Codex must not create | Project implementation changes; `POSTCHECK.md`; `INTEGRATION_REQUEST.md`; companion docs; config/lv/workflow edits; live outputs. |

---

## 6. Step O-T3 — Run organ Codex implementation

| Field | Exact content |
|---|---|
| Step owner | Codex as `researchscientist`. |
| When | After O-T2 staging confirms batch and skeleton contract files are present. |
| ChatGPT prompt | Not normally used. Use ChatGPT only if Codex reports missing files, skeleton contract ambiguity, or safety-gate ambiguity. |
| Upload to ChatGPT | Optional troubleshooting only: exact Codex error; batch `CODEX_PROMPT.txt`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; relevant skeleton `COMPANION.md`; file listing; relevant logs. |
| ChatGPT creates | Optional fix prompt or missing-file report. No normal project files. |
| Codex must have access to | `/workspace`; generated/extracted organ batch folder; `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; `CODEX_ORGAN_RECORDING_INSTRUCTIONS.md` if external; relevant skeleton `COMPANION.md`/contract; writable `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/`. |
| Codex prompt | Open and follow `CODEX_PROMPT.txt`, `SPEC.md`, `RUN_INSTRUCTIONS.md`, `POSTCHECK_TEMPLATE.md`, `CODEX_ORGAN_RECORDING_INSTRUCTIONS.md` if present, and the relevant skeleton `COMPANION.md`/contract. Use those files as the source of truth. Work under `/workspace` and write evidence to `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/`. Preserve skeleton output contracts. |
| Codex may run | Commands explicitly allowed/listed in `RUN_INSTRUCTIONS.md`; safe dry-run/guarded checks; local file inspection; dependency checks; `mkdir`; `test`; `cat`; `find`; `grep`; `git diff` style commands. |
| Codex creates/updates | Organ project code under `/workspace`; organ modules/tests/scripts; `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md`; `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md`; optional implementation logs. |
| Codex must not create | Ungated live actions; config/lv/workflow edits; skeleton companion docs; organ companion docs; `INTEGRATION_MANIFEST.md`; broken skeleton output contracts. |

O-T3 may create local organ smoke routines when the organ batch owns such a local surface. It should not create or alter global smoke modules unless the organ batch explicitly includes that work.

---

## 7. Step O-T4 — Prepare and run idempotent smoke after every organ batch

O-T4 is split into two parts:

```text
O-T4A ChatGPT prepares a cache-aware organ smoke execution instruction set.
O-T4B Codex executes only that instruction set.
```

The reason for this split is that Codex is the execution model. Codex should not be asked to re-read the full transition master, batch plan, final workflow, or old smoke reports every time. ChatGPT reads the organ background/evidence, compresses it into a small execution cache and exact Codex prompt, and Codex runs only the named commands.

---

### 7.1 Step O-T4A — ChatGPT prepares the organ smoke execution instruction set

| Field | Exact content |
|---|---|
| Step owner | ChatGPT. |
| When | After O-T3 implementation has produced organ `POSTCHECK.md` and organ `INTEGRATION_REQUEST.md`, and before Codex runs organ smoke. |
| Purpose | Convert the current organ batch evidence, relevant skeleton contract, updated transition plan, and final workflow into a small, cache-aware Codex smoke execution instruction set. |
| ChatGPT should read/upload | `day_to_day_organs_run.md`; `final_workflow.md`; `01_transition_to_real_organs_master_UPDATED.md`; `transition_real_organs_codex_batch_plan_UPDATED.md`; current organ batch `SPEC.md`; current organ batch `RUN_INSTRUCTIONS.md`; current organ `POSTCHECK.md`; current organ `INTEGRATION_REQUEST.md`; relevant skeleton `COMPANION.md` or skeleton contract summary; latest organ `SMOKE_REPORT.md` only if repairing or comparing a previous smoke run; optional list of `/workspace/tests/smoke.d/*.smoke.sh` only if module coverage is being reviewed. |
| ChatGPT must not require Codex to read | Full workflow files, full organ transition master, full organ batch plan, full skeleton plans, old smoke reports, unrelated skeleton/organ batch packages, or unrelated source trees. |
| ChatGPT creates | A small organ smoke execution instruction set for Codex, normally named `ORGAN_SMOKE_RUN_PROJECT_CACHE.md` and `ORGAN_SMOKE_RUN_CODEX_PROMPT.txt`, or equivalent pasted prompt text if no files are being generated. |
| ChatGPT output must include | `ORGAN_BATCH_NUMBER`; `ORGAN_BATCH_SLUG`; relevant skeleton contract/companion identifier; active runner path; phase; exact command; expected organ evidence files; expected report output; accepted WARNs if already known; stop conditions; files Codex may inspect; files Codex must not inspect unless failure requires it. |
| ChatGPT output must decide | Whether this is a per-batch `organ-progress` smoke run, a logical-group/global organ checkpoint smoke run, or an `organ-complete` smoke run. |
| ChatGPT must not create | Project code, smoke reports, companion docs, config/lv/workflow edits, integration manifest, or new smoke modules unless explicitly asked for a smoke repair/update package. |

#### Files named explicitly for O-T4A

Use these exact names where available:

```text
day_to_day_organs_run.md
final_workflow.md
01_transition_to_real_organs_master_UPDATED.md
transition_real_organs_codex_batch_plan_UPDATED.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK.md
INTEGRATION_REQUEST.md
COMPANION.md
SMOKE_REPORT.md
ORGAN_SMOKE_RUN_PROJECT_CACHE.md
ORGAN_SMOKE_RUN_CODEX_PROMPT.txt
```

#### O-T4A ChatGPT prompt template

```text
Prepare a cache-aware Codex organ smoke execution instruction set for the just-completed organ batch.

Read the uploaded:
- day_to_day_organs_run.md
- final_workflow.md
- 01_transition_to_real_organs_master_UPDATED.md
- transition_real_organs_codex_batch_plan_UPDATED.md
- current organ batch SPEC.md
- current organ batch RUN_INSTRUCTIONS.md
- current organ POSTCHECK.md
- current organ INTEGRATION_REQUEST.md
- relevant skeleton COMPANION.md or skeleton contract summary
- latest organ SMOKE_REPORT.md only if this is a repair/re-run

Do not make Codex read all those background files.

Produce:
1. ORGAN_SMOKE_RUN_PROJECT_CACHE.md
2. ORGAN_SMOKE_RUN_CODEX_PROMPT.txt

The Codex prompt must be token-sensitive and execution-only.
It must name:
- exact active runner
- exact phase
- exact ORGAN_BATCH_SLUG/BATCH_SLUG
- exact smoke command
- exact organ evidence files to verify
- relevant skeleton contract file or summary
- expected output report path pattern
- accepted WARNs if known
- stop conditions
- files Codex may inspect
- files Codex must not inspect

It must forbid:
- config edits
- source-code edits
- skeleton or organ companion edits
- integration manifest creation
- ungated live organ actions
- live RunPod/model/Kubernetes/Terraform actions
- broad background-file reading

Also state whether this is:
- per-batch organ-progress smoke
- logical-group/global organ checkpoint smoke
- organ-complete smoke
```

---

### 7.2 Step O-T4B — Codex executes the prepared organ smoke instruction set

| Field | Exact content |
|---|---|
| Step owner | Codex. |
| When | Immediately after O-T4A creates `ORGAN_SMOKE_RUN_PROJECT_CACHE.md` and `ORGAN_SMOKE_RUN_CODEX_PROMPT.txt`, or provides equivalent prompt text. |
| Codex reads only | `ORGAN_SMOKE_RUN_PROJECT_CACHE.md`; `ORGAN_SMOKE_RUN_CODEX_PROMPT.txt`; the exact organ evidence files named inside the prompt, usually current organ `POSTCHECK.md` and `INTEGRATION_REQUEST.md`; relevant skeleton contract file named in the prompt; runner script existence; smoke report output path after execution. |
| Codex should not read | Full workflow files; full organ transition master; full organ or skeleton batch plans; old batch packages; unrelated source files; all smoke modules manually. The runner discovers modules. |
| Current command if `smoke.sh` is active | `BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke.sh organ-progress` |
| Final canonical command after migration | `BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress` |
| Logical-group/global checkpoint command if `smoke.sh` is active | `bash /workspace/scripts/smoke.sh full` or the exact checkpoint command named by O-T4A. |
| Logical-group/global checkpoint command after migration | `bash /workspace/scripts/smoke_current_state.sh platform-current` or the exact checkpoint command named by O-T4A. |
| Organ-complete command if `smoke.sh` is active | `bash /workspace/scripts/smoke.sh organ-complete` |
| Organ-complete command after migration | `bash /workspace/scripts/smoke_current_state.sh organ-complete` |
| Codex may run | The exact smoke command from `ORGAN_SMOKE_RUN_CODEX_PROMPT.txt`; `test -f` on named organ evidence and skeleton contract files; `test -x` or `bash -n` on the named runner if instructed; `cat`/`tail` of the newly generated `SMOKE_REPORT.md`; no other tests unless the prepared prompt explicitly allows them. |
| Codex creates/updates | `/workspace/runs/smoke/<timestamp>-<phase>/SMOKE_REPORT.md`; module logs under `/workspace/runs/smoke/<timestamp>-<phase>/module-results/`; optional organ `POSTCHECK.md` update only if `ORGAN_SMOKE_RUN_CODEX_PROMPT.txt` explicitly says to record the smoke path/result. |
| Codex must not create/update | Project code; global smoke modules; local smoke routines; config/lv/workflow files; skeleton companion docs; organ companion docs; `INTEGRATION_MANIFEST.md`; destructive cleanup; overwritten old smoke reports; ungated live organ outputs. |

#### O-T4B Codex prompt template

```text
Read and follow ORGAN_SMOKE_RUN_CODEX_PROMPT.txt and ORGAN_SMOKE_RUN_PROJECT_CACHE.md.

Do not read the full workflow files, full organ transition master, full organ or skeleton batch plans, old batch packages, or unrelated source trees.

This is an execution-only organ smoke step.

Verify only the files named in ORGAN_SMOKE_RUN_CODEX_PROMPT.txt.
Run exactly the smoke command named in ORGAN_SMOKE_RUN_CODEX_PROMPT.txt.

Return:
- exact command run
- exit status
- SMOKE_REPORT.md path
- PASS/WARN/SKIP/FAIL summary
- exact failing command if any
- whether organ POSTCHECK.md was updated with the report path, if instructed
- whether skeleton contract preservation was verified or not part of this smoke instruction set

Do not edit source code.
Do not edit config/lv/workflow.
Do not edit skeleton or organ companion docs.
Do not create INTEGRATION_MANIFEST.md.
Do not run ungated live organ actions, live RunPod, live model/provider calls, Kubernetes mutation, Terraform apply/destroy, Docker containers, or other live/mutating actions.
```

---

### 7.3 Per-batch organ-progress smoke versus logical-group/global organ smoke

| Smoke type | When | Who prepares instruction set | Who runs | Command pattern |
|---|---|---|---|---|
| Per-batch organ-progress smoke | After every organ batch O-T3. | ChatGPT O-T4A. | Codex O-T4B. | `BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke.sh organ-progress` or migrated equivalent. |
| Logical-group/global organ smoke | After every organ logical group or safety/output contract-changing checkpoint, before O-T6 companion update. | ChatGPT O-T4A. | Codex O-T4B. | Active runner global/current-state command, for example `bash /workspace/scripts/smoke.sh full` or migrated `bash /workspace/scripts/smoke_current_state.sh platform-current`. |
| Organ-complete smoke | After final organ batch and required companions/evidence are ready. | ChatGPT may prepare a final O-T4A-style instruction set or use O-T7 directly. | Codex. | `bash /workspace/scripts/smoke.sh organ-complete` or migrated equivalent. |

Minimum rule:

```text
Run per-batch organ-progress smoke after every organ batch.
Run a global/current-state smoke checkpoint after every organ logical group before updating organ companion.
Run organ-complete smoke after the final organ batch.
```

### Organ smoke report review input

After O-T4B, collect exactly:

```text
/workspace/runs/smoke/<timestamp>-<phase>/SMOKE_REPORT.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

If this was a logical-group/global checkpoint and O-T6 is next, also collect:

```text
/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md
/mnt/ingress/infra/organs/companion/INDEX.md
/mnt/ingress/infra/skeleton/companion/<skeleton-slug>/COMPANION.md
```

---

## 8. Step O-T5 — Read organ smoke report and decide PASS/WARN/FAIL

| Field | Exact content |
|---|---|
| Step owner | Human or ChatGPT for interpretation. Codex only supplies files or applies fixes. |
| When | Immediately after O-T4B smoke finishes. |
| ChatGPT prompt | Read `SMOKE_REPORT.md`, organ `POSTCHECK.md`, organ `INTEGRATION_REQUEST.md`, organ `SPEC.md`, organ `RUN_INSTRUCTIONS.md`, and the skeleton companion/contract. Classify PASS/WARN/FAIL. If FAIL, create a Codex fix prompt naming exact files and the exact smoke command to rerun. Do not invent missing files. Preserve skeleton output contracts. |
| Upload to ChatGPT | Latest organ `SMOKE_REPORT.md`; latest organ `POSTCHECK.md`; latest organ `INTEGRATION_REQUEST.md`; organ `SPEC.md`; organ `RUN_INSTRUCTIONS.md`; relevant skeleton `COMPANION.md`; failing stdout/stderr log if present; optional code diff. |
| ChatGPT creates | PASS/WARN/FAIL decision; exact missing-file list; exact Codex fix prompt; optional `POSTCHECK.md` update text. |
| Codex must have access to | Only if fixes are required: `/workspace`; relevant source files named by ChatGPT; latest `SMOKE_REPORT.md`; organ `POSTCHECK.md`; organ `INTEGRATION_REQUEST.md`; organ `SPEC.md`; organ `RUN_INSTRUCTIONS.md`; skeleton companion/contract. |
| Codex prompt | Apply only the fixes named by ChatGPT. Re-run exactly the smoke command specified by the prepared smoke prompt or ChatGPT fix prompt. Update organ `POSTCHECK.md` with the new report path and result if instructed. |
| Codex may run | File fixes within batch scope; same O-T4 smoke command; safe local checks named by `RUN_INSTRUCTIONS.md`. |
| Codex creates/updates | Bugfixes under `/workspace` if required; updated organ `POSTCHECK.md`; updated organ `INTEGRATION_REQUEST.md` only if the request changed; new timestamped `SMOKE_REPORT.md`. |
| Codex must not create | Config integration; companion docs unless O-T6 is explicitly started; integration manifests; hidden manual overrides; ungated live actions. |

---

## 9. Step O-T6 — Update organ companion after a checked organ state

| Field | Exact content |
|---|---|
| Step owner | Usually ChatGPT drafts the organ companion content; Codex may write it to ingress. |
| When | After an organ logical group, after an organ safety/output contract change, or after organ-complete smoke passes/warns acceptably. |
| ChatGPT prompt | Read `ORGAN_COMPANION_GENERATOR_INSTRUCTIONS.md` and use the named evidence files. Update organ `COMPANION.md` for the checked real-organ state. Preserve skeleton output contracts. Do not repeat the generator instructions in the prompt. Do not invent missing evidence. |
| Upload to ChatGPT | `ORGAN_COMPANION_GENERATOR_INSTRUCTIONS.md`; latest organ `POSTCHECK.md`; latest organ `INTEGRATION_REQUEST.md`; latest organ `SMOKE_REPORT.md`; latest codebase analysis output; existing organ `COMPANION.md` if present; existing organ `INDEX.md` if present; relevant skeleton `COMPANION.md` or skeleton contract summary; relevant organ batch `SPEC.md` and `RUN_INSTRUCTIONS.md` if exact commands are needed. |
| ChatGPT creates | Updated organ `COMPANION.md` content; optional organ `INDEX.md` update text; optional missing-file report; optional safety-gate checklist; optional Codex write prompt. |
| Codex must have access to | `/workspace`; `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md`; `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md`; latest `SMOKE_REPORT.md`; `/mnt/ingress/infra/organs/companion/<batch-slug>/`; ChatGPT-created `COMPANION.md` content or patch. |
| Codex prompt | Write the provided ChatGPT organ companion content to `/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md`. Update `INDEX.md` only if ChatGPT provided exact `INDEX.md` content. Do not edit config, project code, or skeleton companion docs. |
| Codex may run | `mkdir -p`; file write commands; `test -f`; `cat`; `head`; `tail`; optional dry-run/smoke only if explicitly requested. |
| Codex creates/updates | `/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md`; optional `/mnt/ingress/infra/organs/companion/INDEX.md`; optional write log. |
| Codex must not create | Config/lv/workflow edits; skeleton companion docs; invented integration manifests; live outputs. |

### Organ logical groups for O-T6

Use these organ logical groups for day-to-day companion timing.

| Logical group | Suggested organ range | Companion update recommended when |
|---|---|---|
| O-G1 Contract audit and adapter shell | R01 | Real-organ migration audit is complete, prerequisites are documented, and skeleton contracts are mapped to organ targets. |
| O-G2 Core GRN/DSL/simulator/NCA/ART organs | R02–R05 | Real local science organs write skeleton-compatible filenames/schemas and are smoke-verified. |
| O-G3 Search and RunPod boundary | R06–R07 | Real search drivers/scoring and RunPod dry-run-to-live boundary are smoke-verified and live gates are documented. |
| O-G4 OpenClaw, Agentfield, Paperclip adapters | R08–R10 | Real selected-context reasoning, Agentfield lifecycle/status, and Paperclip adapter mappings are smoke-verified behind dry-run/live guards. |
| O-G5 Campaign and final handoff | R11–R12 | Real campaign pipeline and full local no-live end-to-end smoke are stable enough for config integration planning. |

Minimum rule:

```text
Run organ-progress smoke after every organ batch.
Run a global/current-state checkpoint after every organ logical group before O-T6.
Update organ companion after every logical group or after any real-output/safety-contract change.
```

---

## 10. Step O-T7 — Organ-complete checkpoint and final organ smoke

| Field | Exact content |
|---|---|
| Step owner | Codex runs organ-complete smoke; ChatGPT reviews readiness if needed. |
| When | After final organ batch R12 or the final planned organ batch and required companions are complete. |
| ChatGPT prompt | Read organ-complete `SMOKE_REPORT.md`, latest organ companion docs, skeleton companion contract, and completed organ evidence. Decide whether operator/config integration may start. If blocked, name exact files/commands to fix. Do not create config batch instructions if organ-complete smoke fails. |
| Upload to ChatGPT | Organ-complete `SMOKE_REPORT.md`; latest organ `COMPANION.md`/`INDEX.md`; relevant skeleton `COMPANION.md`; final or representative organ `POSTCHECK.md` files; final or representative organ `INTEGRATION_REQUEST.md` files; latest codebase analysis; final organ `SPEC.md`/`RUN_INSTRUCTIONS.md` if applicable. |
| ChatGPT creates | Organ-complete readiness decision; blocker list; optional config-start checklist; optional Codex fix prompt. |
| Codex must have access to | Runner script; `/workspace`; all organ evidence folders under `/mnt/egress/organs/dev-recordings/organs/`; organ companion docs; relevant skeleton companion docs. |
| Codex prompt | Run the organ-complete smoke checkpoint using the active runner. Preserve previous smoke reports. Do not edit config unless O-T9 is explicitly started. Do not run ungated live actions. |
| Codex may run | `bash /workspace/scripts/smoke.sh organ-complete` if `smoke.sh` is active; or `bash /workspace/scripts/smoke_current_state.sh organ-complete` after migration; `test`; `cat`; `tail` report; safe local commands called by the smoke script. |
| Codex creates/updates | `/workspace/runs/smoke/<timestamp>-organ-complete/SMOKE_REPORT.md`; optional readiness note in dev-recordings; optional `POSTCHECK.md` update with organ-complete result. |
| Codex must not create | Config integration edits; `INTEGRATION_MANIFEST.md` unless O-T8 is explicitly started; new live outputs. |

---

## 11. Step O-T8 — Create organ integration manifest in ChatGPT

| Field | Exact content |
|---|---|
| Step owner | ChatGPT plans integration from completed evidence. |
| When | After organ-complete smoke is PASS or accepted WARN and before vmuser/operator config integration. |
| ChatGPT prompt | Read `INTEGRATION_MANIFEST_TEMPLATE.md`, `CONFIG_TOOL.md`, completed organ `INTEGRATION_REQUEST.md` files, organ `POSTCHECK.md` files, organ companion docs, skeleton companion contract, and smoke reports. Produce `INTEGRATION_MANIFEST.md` or organ manifest slice. Do not repeat the manifest template in the prompt; follow the file. |
| Upload to ChatGPT | `INTEGRATION_MANIFEST_TEMPLATE.md`; `CONFIG_TOOL.md`; completed organ `INTEGRATION_REQUEST.md` files; completed organ `POSTCHECK.md` files; organ `COMPANION.md`/`INDEX.md`; relevant skeleton `COMPANION.md`; organ-complete `SMOKE_REPORT.md`; relevant codebase analysis; optional `PROJECT_CACHE.md`/`SPEC.md`/`RUN_INSTRUCTIONS.md` for exact commands. |
| ChatGPT creates | Organ `INTEGRATION_MANIFEST.md` content or manifest slice; optional operator Codex batch prompt; missing-evidence report if required files are absent. |
| Codex must have access to | Only if asked to save the manifest: approved output folder; ChatGPT-created `INTEGRATION_MANIFEST.md` content. |
| Codex prompt | Optional only: write the provided organ `INTEGRATION_MANIFEST.md` or manifest slice to the approved planning/evidence location. Do not edit config yet. |
| Codex may run | File write and `test -f` only if asked to save the manifest. |
| Codex creates/updates | Optional saved organ `INTEGRATION_MANIFEST.md` or manifest slice; optional write log. |
| Codex must not create | Config/lv/workflow edits during planning; new organ implementation outputs; invented evidence. |

---

## 12. Step O-T9 — Run vmuser/operator organ config integration and post-config smoke

| Field | Exact content |
|---|---|
| Step owner | ChatGPT may generate operator batch; Codex as vmuser/operator executes it. |
| When | After O-T8 manifest exists. This is the organ step where config/lv/workflow edits may occur. |
| ChatGPT prompt | Read `general_new_chat_config_integration_batch_generation_prompt.md` if available, organ `INTEGRATION_MANIFEST.md`, `CONFIG_TOOL.md`, organ companion docs, and skeleton companion contract. Generate a vmuser/operator config-integration Codex batch. Do not repeat config prompt text manually; use the files as instructions. |
| Upload to ChatGPT | `general_new_chat_config_integration_batch_generation_prompt.md` if present; organ `INTEGRATION_MANIFEST.md`; `CONFIG_TOOL.md`; organ `COMPANION.md`/`INDEX.md`; relevant skeleton `COMPANION.md`; organ-complete `SMOKE_REPORT.md`; optional current config file list; optional existing lv/workflow snippets. |
| ChatGPT creates | Operator organ config-integration `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; exact post-config smoke instruction; optional missing-file report. |
| Codex must have access to | Generated operator config-integration batch files; `/workspace` or config repo; approved config/lv/workflow files; organ `INTEGRATION_MANIFEST.md`; `CONFIG_TOOL.md`; runner script; previous organ/skeleton evidence folders. |
| Codex prompt | Open and follow generated operator `CODEX_PROMPT.txt`, `SPEC.md`, `RUN_INSTRUCTIONS.md`, `POSTCHECK_TEMPLATE.md`, organ `INTEGRATION_MANIFEST.md`, and `CONFIG_TOOL.md`. Apply only manifest-approved config/lv/workflow changes. Then run post-config smoke. |
| Codex may run | Approved config edit commands from `RUN_INSTRUCTIONS.md`; safe validation commands; post-config smoke; config health checks named by `RUN_INSTRUCTIONS.md`. |
| Codex creates/updates | Approved config/lv/workflow files; operator integration `POSTCHECK.md`; `/workspace/runs/smoke/<timestamp>-post-config/SMOKE_REPORT.md`; optional config health-check logs. |
| Codex must not create | Unapproved science rewrites; ungated live actions; undocumented aliases; config changes not present in the manifest. |

Post-config smoke command:

```bash
# current active runner
bash /workspace/scripts/smoke.sh post-config

# final canonical runner after migration
bash /workspace/scripts/smoke_current_state.sh post-config
```

---

## 13. Quick organ command ledger

| Situation | Current active runner command | Final canonical command |
|---|---|---|
| After each organ batch | `BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke.sh organ-progress` | `BATCH_SLUG="<organ-batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress` |
| After each organ logical group | `bash /workspace/scripts/smoke.sh full` or exact checkpoint command from O-T4A | `bash /workspace/scripts/smoke_current_state.sh platform-current` or exact checkpoint command from O-T4A |
| After all organ batches | `bash /workspace/scripts/smoke.sh organ-complete` | `bash /workspace/scripts/smoke_current_state.sh organ-complete` |
| Before config integration | `bash /workspace/scripts/smoke.sh pre-config` | `bash /workspace/scripts/smoke_current_state.sh pre-config` |
| After config integration | `bash /workspace/scripts/smoke.sh post-config` | `bash /workspace/scripts/smoke_current_state.sh post-config` |

---

## 14. Organ file tracking checklist by day-to-day step

| Step | Upload to ChatGPT | ChatGPT creates | Codex needs/accesses | Codex creates |
|---|---|---|---|---|
| O-T1 | Organ generation prompt, updated transition master, updated organ batch plan, templates, config context, relevant skeleton companion/contract, optional organ companion/evidence | Organ batch zip and five standard files | None | None |
| O-T2 | Optional zip/batch file list only | Optional sanity checklist | Organ batch zip/folder, `/workspace`, skeleton contract, organ evidence folder | Extracted folder, staging log, evidence folder |
| O-T3 | Troubleshooting only | Optional fix prompt | Organ batch files, `/workspace`, skeleton contract, organ evidence root | Organ code, scripts/tests, organ `POSTCHECK.md`, organ `INTEGRATION_REQUEST.md` |
| O-T4A | Day-to-day organs run, final workflow, updated transition master, updated organ batch plan, organ spec/run instructions, organ evidence, skeleton companion/contract | `ORGAN_SMOKE_RUN_PROJECT_CACHE.md`, `ORGAN_SMOKE_RUN_CODEX_PROMPT.txt` | None | None |
| O-T4B | None unless Codex output needs review | None | Organ smoke cache/prompt, named evidence files, named skeleton contract, runner | `SMOKE_REPORT.md`, module logs, optional `POSTCHECK.md` smoke path update |
| O-T5 | Smoke report, organ postcheck, organ integration request, organ spec, run instructions, skeleton companion/contract, error logs | PASS/WARN/FAIL decision, fix prompt | Only if fixing | Bugfixes, updated evidence, new smoke report |
| O-T6 | Organ generator instructions, organ postcheck, organ integration request, smoke report, codebase analysis, existing organ companion/index, skeleton contract | Organ companion content, optional index update, missing-file list | Ingress organ companion folder, ChatGPT content, evidence files | Organ `COMPANION.md`, optional organ `INDEX.md` |
| O-T7 | Organ-complete smoke, organ companions, skeleton companion, evidence, code analysis | Readiness decision, blocker list, config-start checklist | Runner, all organ evidence, organ/skeleton companion docs | Organ-complete smoke report |
| O-T8 | Manifest template, config context, organ integration requests, postchecks, companions, skeleton contract, smoke reports | Organ integration manifest or slice, missing-evidence report | Optional save location only | Optional saved manifest |
| O-T9 | Config integration prompt/template, organ manifest, config context, organ/skeleton companions, organ-complete smoke | Operator organ config-integration batch | Config repo/tool files, manifest, runner, evidence | Config/lv/workflow updates, config POSTCHECK, post-config smoke report |

---

## 15. Minimal copy prompts for organs

### O-T1 prompt to ChatGPT

```text
Read and follow general_new_chat_organ_batch_generation_prompt.md.
Set BATCH_NUMBER=<RNN or N>.
Use the uploaded 01_transition_to_real_organs_master_UPDATED.md, transition_real_organs_codex_batch_plan_UPDATED.md, template files, CONFIG_TOOL.md as read-only context, and the relevant skeleton COMPANION.md or skeleton contract summary.
Produce one Codex-ready organ batch package.
Do not repeat the template prompts manually.
Do not modify config tool files.
```

### O-T2 prompt to Codex

```text
Extract/stage the generated organ batch.
Confirm these files exist:
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md

Also confirm the relevant skeleton COMPANION.md or skeleton contract file is available.

Do not execute implementation yet unless O-T3 is explicitly started.
```

### O-T3 prompt to Codex

```text
Open and follow CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, CODEX_ORGAN_RECORDING_INSTRUCTIONS.md if present, and the relevant skeleton COMPANION.md/contract.
Use those files as the source of truth.
Do not paste their contents into the prompt.
Work under /workspace.
Write evidence to /mnt/egress/organs/dev-recordings/organs/<batch-slug>/.
Preserve skeleton output contracts.
Do not edit config/lv/workflow files.
Do not run live/external provider actions unless the batch explicitly allows a guarded dry-run.
```

### O-T4A prompt to ChatGPT

```text
Prepare a cache-aware Codex organ smoke execution instruction set for the just-completed organ batch.

Read the uploaded:
- day_to_day_organs_run.md
- final_workflow.md
- 01_transition_to_real_organs_master_UPDATED.md
- transition_real_organs_codex_batch_plan_UPDATED.md
- current organ batch SPEC.md
- current organ batch RUN_INSTRUCTIONS.md
- current organ POSTCHECK.md
- current organ INTEGRATION_REQUEST.md
- relevant skeleton COMPANION.md or skeleton contract summary
- latest organ SMOKE_REPORT.md only if repairing or comparing a previous smoke run

Do not make Codex read all those background files.

Produce:
1. ORGAN_SMOKE_RUN_PROJECT_CACHE.md
2. ORGAN_SMOKE_RUN_CODEX_PROMPT.txt

The Codex prompt must be token-sensitive and execution-only.
It must name the exact active runner, phase, ORGAN_BATCH_SLUG/BATCH_SLUG, command, organ evidence files, relevant skeleton contract, expected output report path pattern, accepted WARNs if known, and stop conditions.
Also state whether this is per-batch organ-progress smoke, logical-group/global checkpoint smoke, or organ-complete smoke.
```

### O-T4B prompt to Codex

```text
Read and follow ORGAN_SMOKE_RUN_CODEX_PROMPT.txt and ORGAN_SMOKE_RUN_PROJECT_CACHE.md.

Do not read the full workflow files, full organ transition master, full organ or skeleton batch plans, old batch packages, or unrelated source trees.

This is an execution-only organ smoke step.
Run exactly the smoke command named in ORGAN_SMOKE_RUN_CODEX_PROMPT.txt.
Return the command, exit status, SMOKE_REPORT.md path, summary, exact failing command if any, and whether organ POSTCHECK.md was updated with the report path if instructed.

Do not edit source code, config/lv/workflow, skeleton companion docs, organ companion docs, or integration manifests.
Do not run ungated live organ actions, live RunPod, live model/provider calls, Kubernetes mutation, Terraform apply/destroy, Docker containers, or other live/mutating actions.
```

### O-T5 prompt to ChatGPT

```text
Read the uploaded organ SMOKE_REPORT.md, organ POSTCHECK.md, organ INTEGRATION_REQUEST.md, organ SPEC.md, organ RUN_INSTRUCTIONS.md, and relevant skeleton COMPANION.md/contract.
Classify the current organ batch state as PASS, acceptable WARN, blocking WARN, FAIL, or BLOCKED.
If fixing is needed, produce an exact Codex fix prompt naming the files to edit and the exact smoke command to rerun.
Do not invent missing evidence.
Preserve skeleton output contracts.
```

### O-T6 prompt to ChatGPT

```text
Update the organ companion for this checked real-organ state.
Use the uploaded organ POSTCHECK.md, organ INTEGRATION_REQUEST.md, organ SMOKE_REPORT.md, codebase analysis, existing organ COMPANION.md/INDEX.md, and relevant skeleton companion contract.
Return updated COMPANION.md content and any INDEX.md update.
Preserve skeleton output contracts.
Do not invent missing files. If required evidence is missing, stop and list it.
Do not propose config edits here.
```

### O-T7 prompt to Codex

```text
Run the organ-complete smoke checkpoint.
Use the active runner for this workspace:
bash /workspace/scripts/smoke.sh organ-complete

If the workspace has migrated to the final canonical runner, use:
bash /workspace/scripts/smoke_current_state.sh organ-complete

Preserve previous smoke reports.
Do not edit config.
Do not run ungated live actions.
Return the SMOKE_REPORT.md path.
```

### O-T8 prompt to ChatGPT

```text
Read INTEGRATION_MANIFEST_TEMPLATE.md, CONFIG_TOOL.md, completed organ INTEGRATION_REQUEST.md files, organ POSTCHECK.md files, organ companion docs, relevant skeleton COMPANION.md, and smoke reports.
Produce INTEGRATION_MANIFEST.md or an organ manifest slice.
Do not repeat the manifest template in the prompt; follow the file.
If required evidence is missing, stop and list exact missing files.
Do not edit config.
```

### O-T9 prompt to Codex

```text
Open and follow the generated operator CODEX_PROMPT.txt, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, organ INTEGRATION_MANIFEST.md, and CONFIG_TOOL.md.
Apply only manifest-approved config/lv/workflow changes.
Run post-config smoke with the active runner.
Write POSTCHECK.md, include the smoke report path, and list every changed file.
Do not create unapproved config entries, science implementation changes, or ungated live actions.
```

---

## 16. Organ stop rules

Stop immediately when any of these occurs:

```text
required organ batch file missing
required skeleton companion/contract missing
required organ evidence path missing
organ POSTCHECK.md missing
organ INTEGRATION_REQUEST.md missing
smoke runner missing or broken
SMOKE_REPORT.md shows FAIL
SMOKE_REPORT.md shows unexpected WARN not yet classified
skeleton output contract appears broken
mount/permission issue blocks evidence or reports
Codex proposes config edits during O-T1 through O-T8
Codex proposes ungated live organ, RunPod, model, Kubernetes, Docker, or Terraform mutation by default
```

Do not continue by guessing. Upload the exact report/log and ask for a fix prompt.

---

## 17. One-page organ daily rule

```text
Generate one organ batch package in ChatGPT.

Stage it.

Run Codex implementation from the named organ batch files and relevant skeleton contract only.

Write organ POSTCHECK.md and organ INTEGRATION_REQUEST.md.

ChatGPT prepares a compact organ smoke execution cache/prompt.

Codex runs only that smoke prompt.

Review organ SMOKE_REPORT.md.

Continue only on PASS/SKIP/accepted WARN and preserved skeleton contract.

Run a global/current-state checkpoint after logical organ groups.

Update organ companion only at logical checkpoints or contract/safety changes.

After all organ batches, run organ-complete.

Create organ integration manifest only after organ-complete.

Run config integration only later as vmuser/operator from a manifest-approved batch.
```
