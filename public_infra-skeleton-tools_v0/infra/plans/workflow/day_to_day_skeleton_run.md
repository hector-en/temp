# Day-to-Day Skeleton Run — Updated Operational Workflow

This file is the day-to-day execution workflow for Skeleton Batches 01–24.

It incorporates:

```text
final_workflow.md
skeleton_timeline_full_step_file_ledger.md
workflow_addendum_full_file_ledger.md
corrected smoke.d mapping
dynamic smoke runner clarification
```

The purpose is to make the daily process unambiguous: what ChatGPT does, what Codex does, what files are uploaded or produced, when smoke runs, when companions update, and when config integration is allowed.

---

## 0. Current runner rule

There is one conceptual runner: the **dynamic smoke orchestrator**.

It discovers global smoke modules, runs them for the requested phase, and writes a timestamped smoke report.

```text
runner
  -> discovers /workspace/tests/smoke.d/*.smoke.sh
  -> runs each applicable global smoke module
  -> may call project-local smoke routines through those modules
  -> writes /workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
```

### Current compatibility rule

If the workspace currently has `/workspace/scripts/smoke.sh` as the implemented active runner, use it until a dedicated D-SM2 runner migration is performed.

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh skeleton-progress
```

If the workspace has already migrated to the final canonical runner, use:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

### Final intended state

```text
/workspace/scripts/smoke_current_state.sh
  canonical real orchestrator

/workspace/scripts/smoke.sh
  compatibility wrapper that calls smoke_current_state.sh
```

Do not keep two independent implementations.

---

## 1. Canonical paths

| Path | Meaning |
|---|---|
| `/workspace` | Shared project workspace. Code, scripts, tests, runs, smoke reports, generated batch folders. |
| `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` | Dynamic smoke protocol/spec. Update only when smoke architecture changes. |
| `/workspace/scripts/smoke_current_state.sh` | Final canonical dynamic smoke runner/orchestrator. |
| `/workspace/scripts/smoke.sh` | Current implemented runner or compatibility wrapper, depending on migration state. |
| `/workspace/tests/smoke.d/*.smoke.sh` | Global domain-owned smoke modules. |
| `/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md` | Smoke result for one phase run. |
| `/workspace/runs/smoke/<timestamp-phase>/module-results/` | Per-module logs. |
| `/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md` | Skeleton batch postcheck evidence. |
| `/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md` | Skeleton handoff request for later operator config integration. |
| `/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md` | Skeleton companion output. |
| `/mnt/ingress/infra/skeleton/companion/INDEX.md` | Optional skeleton companion index. |

---

## 2. Day-to-day skeleton loop

Use this loop for every skeleton batch.

```text
S-T1  ChatGPT creates one batch package.
S-T2  Human/Codex stages the package.
S-T3  Codex implements the batch.
S-T4  Codex runs dynamic smoke.
S-T5  Human/ChatGPT classifies PASS/WARN/FAIL.
S-T6  ChatGPT/Codex updates companion only at logical checkpoints or contract changes.
Repeat until Batch 24.
S-T7  Run skeleton-complete smoke.
S-T8  Create integration manifest after skeleton-complete.
S-T9  Run vmuser/operator config integration later, not during skeleton implementation.
```

Minimum daily rule:

```text
Do not start the next skeleton batch until the current batch has:
1. POSTCHECK.md
2. INTEGRATION_REQUEST.md
3. a smoke report path
4. PASS, SKIP, or accepted documented WARN
```

---

## 3. Step S-T1 — Create skeleton batch in ChatGPT

| Field | Day-to-day instruction |
|---|---|
| Owner | ChatGPT only. Do not run Codex yet. |
| When | At the start of each skeleton batch number. |
| User prompt pattern | `Read and follow general_new_chat_batch_generation_prompt.md. Set BATCH_NUMBER=<N>. Use the skeleton master, updated skeleton batch plan, templates, and optional latest companion/evidence. Produce one Codex-ready skeleton batch package. Do not repeat template prompts manually.` |
| Upload to ChatGPT | `general_new_chat_batch_generation_prompt.md`; skeleton master; updated `skeleton_dummy_codex_batch_plan.md`; `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; `CONFIG_TOOL.md` as read-only context; optional latest skeleton `COMPANION.md`/`INDEX.md`; optional latest dev-recordings summary. |
| ChatGPT creates | `codex_skeleton_batch_<N>_<slug>.zip`; batch `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; optional missing-file report. |
| ChatGPT must not create | Project code, dev-recordings evidence, companion docs, integration manifest, config/lv/workflow edits. |
| Codex role | None. |

S-T1 output should be one clean batch package, not a mixed implementation and smoke repair package unless explicitly requested.

---

## 4. Step S-T2 — Stage skeleton batch for Codex

| Field | Day-to-day instruction |
|---|---|
| Owner | Human or Codex for extraction/staging. |
| When | Immediately after S-T1 creates the zip. |
| Codex must have access to | Generated zip or extracted folder; `/workspace`; batch `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; `CODEX_RECORDING_INSTRUCTIONS.md` if external; writable `/mnt/egress/dev-recordings/skeleton/<batch-slug>/`. |
| Codex prompt | `Extract/stage the generated skeleton batch. Confirm CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, and POSTCHECK_TEMPLATE.md exist. Do not execute implementation yet unless S-T3 is explicitly started.` |
| Codex may run | `unzip`; `ls`; `find`; `test -f`; `head`; `tree`; `mkdir -p` for evidence folder. |
| Codex creates/updates | Extracted batch folder; optional staging log; required evidence folder if missing. |
| Codex must not create | Project implementation changes; `POSTCHECK.md`; `INTEGRATION_REQUEST.md`; companion docs; config/lv/workflow edits. |

---

## 5. Step S-T3 — Run skeleton Codex implementation

| Field | Day-to-day instruction |
|---|---|
| Owner | Codex as `researchscientist` or the active project implementation user. |
| When | After S-T2 confirms batch files exist. |
| Codex must have access to | `/workspace`; extracted batch folder; `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; `CODEX_RECORDING_INSTRUCTIONS.md` if external; writable `/mnt/egress/dev-recordings/skeleton/<batch-slug>/`. |
| Codex prompt | `Open and follow CODEX_PROMPT.txt, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, and CODEX_RECORDING_INSTRUCTIONS.md if present. Use those files as source of truth. Do not paste their contents into the prompt. Work under /workspace and write evidence to /mnt/egress/dev-recordings/skeleton/<batch-slug>/.` |
| Codex may run | Commands explicitly allowed/listed in `RUN_INSTRUCTIONS.md`; safe local file inspection; dependency checks; unit-level local checks; `mkdir`; `test`; `cat`; `find`; `grep`; `git diff` style commands. |
| Codex creates/updates | Project code under `/workspace`; batch-defined scripts/modules/tests; `POSTCHECK.md`; `INTEGRATION_REQUEST.md`; optional implementation logs. |
| Codex must not create | Config/lv/workflow edits; companion docs; `INTEGRATION_MANIFEST.md`; organ live outputs; project source under `/home/<role>` except role-local scratch. |

S-T3 may create local project/domain smoke routines when the batch owns such a local surface. It should not create or alter global smoke modules unless the batch explicitly includes that work.

---

## 6. Step S-T4 — Prepare and run idempotent smoke after every skeleton batch

S-T4 is split into two parts:

```text
S-T4A ChatGPT prepares a cache-aware smoke execution instruction set.
S-T4B Codex executes only that instruction set.
```

The reason for this split is that Codex is the execution model. Codex should not be asked to re-read the full background set every time. ChatGPT reads the background/evidence, compresses it into a small execution cache and exact Codex prompt, and Codex runs only the named commands.

---

### 6.1 Step S-T4A — ChatGPT prepares the smoke execution instruction set

| Field | Day-to-day instruction |
|---|---|
| Owner | ChatGPT. |
| When | After S-T3 implementation has produced `POSTCHECK.md` and `INTEGRATION_REQUEST.md`, and before Codex runs smoke. |
| Purpose | Convert the current batch evidence and smoke workflow background into a small, cache-aware Codex smoke execution instruction set. |
| ChatGPT should read/upload | `day_to_day_skeleton_run.md`; `final_workflow.md`; `skeleton_dummy_codex_batch_plan.md`; `Corrected_Smoke_d_Batch_Mapping_Report_Skeleton_Batches_01_24_proper.md`; `dynamic_smoketest_howto_addendum.md`; current batch `SPEC.md`; current batch `RUN_INSTRUCTIONS.md`; current batch `POSTCHECK.md`; current batch `INTEGRATION_REQUEST.md`; latest `SMOKE_REPORT.md` only if repairing or comparing a previous smoke run; optional list of `/workspace/tests/smoke.d/*.smoke.sh` if module coverage is being reviewed. |
| ChatGPT must not require Codex to read | Full workflow files, full batch plan, full corrected smoke report, full dynamic smoke HOWTO, old smoke reports, or unrelated prior batch packages. |
| ChatGPT creates | A small smoke execution instruction set for Codex, normally named `SMOKE_RUN_PROJECT_CACHE.md` and `SMOKE_RUN_CODEX_PROMPT.txt`, or equivalent pasted prompt text if no files are being generated. |
| ChatGPT output must include | `BATCH_NUMBER`; `BATCH_SLUG`; active runner path; phase; exact command; expected evidence files; expected report output; accepted WARNs if already known; stop conditions; files Codex may inspect; files Codex must not inspect unless failure requires it. |
| ChatGPT output must decide | Whether this is a per-batch `skeleton-progress` smoke run or a logical-group/global checkpoint smoke run. |
| ChatGPT must not create | Project code, smoke reports, companion docs, config/lv/workflow edits, integration manifest, or new smoke modules unless explicitly asked for a smoke repair/update package. |

#### Files named explicitly for S-T4A

Use these exact names where available:

```text
day_to_day_skeleton_run.md
final_workflow.md
skeleton_dummy_codex_batch_plan.md
Corrected_Smoke_d_Batch_Mapping_Report_Skeleton_Batches_01_24_proper.md
dynamic_smoketest_howto_addendum.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK.md
INTEGRATION_REQUEST.md
SMOKE_REPORT.md
SMOKE_RUN_PROJECT_CACHE.md
SMOKE_RUN_CODEX_PROMPT.txt
```

#### S-T4A ChatGPT prompt template

```text
Prepare a cache-aware Codex smoke execution instruction set for the just-completed skeleton batch.

Read the uploaded:
- day_to_day_skeleton_run.md
- final_workflow.md
- skeleton_dummy_codex_batch_plan.md
- Corrected_Smoke_d_Batch_Mapping_Report_Skeleton_Batches_01_24_proper.md
- dynamic_smoketest_howto_addendum.md
- current batch SPEC.md
- current batch RUN_INSTRUCTIONS.md
- current batch POSTCHECK.md
- current batch INTEGRATION_REQUEST.md
- latest SMOKE_REPORT.md only if this is a repair/re-run

Do not make Codex read all those background files.
Produce:
1. SMOKE_RUN_PROJECT_CACHE.md
2. SMOKE_RUN_CODEX_PROMPT.txt

The Codex prompt must be token-sensitive and execution-only.
It must name the exact active runner, exact phase, exact BATCH_SLUG, exact smoke command, exact evidence files to verify, expected output report path pattern, accepted WARNs if known, and stop conditions.
It must forbid config edits, source-code edits, companion edits, integration manifest creation, live RunPod/model/Kubernetes/Terraform actions, and broad background-file reading.
Also state whether this is:
- per-batch skeleton-progress smoke, or
- logical-group/global checkpoint smoke.
```

---

### 6.2 Step S-T4B — Codex executes the prepared smoke instruction set

| Field | Day-to-day instruction |
|---|---|
| Owner | Codex. |
| When | Immediately after S-T4A creates `SMOKE_RUN_PROJECT_CACHE.md` and `SMOKE_RUN_CODEX_PROMPT.txt`, or provides equivalent prompt text. |
| Codex reads only | `SMOKE_RUN_PROJECT_CACHE.md`; `SMOKE_RUN_CODEX_PROMPT.txt`; the exact evidence files named inside the prompt, usually current batch `POSTCHECK.md` and `INTEGRATION_REQUEST.md`; runner script existence; smoke report output path after execution. |
| Codex should not read | `day_to_day_skeleton_run.md`; `final_workflow.md`; full batch plan; full corrected smoke report; full smoke HOWTO; old batch packages; unrelated source files; all smoke modules manually. The runner discovers modules. |
| Current command if `smoke.sh` is active | `BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh skeleton-progress` |
| Final canonical command after migration | `BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress` |
| Logical-group/global checkpoint command if `smoke.sh` is active | `bash /workspace/scripts/smoke.sh full` or the exact checkpoint command named by S-T4A. |
| Logical-group/global checkpoint command after migration | `bash /workspace/scripts/smoke_current_state.sh platform-current` or the exact checkpoint command named by S-T4A. |
| Codex may run | The exact smoke command from `SMOKE_RUN_CODEX_PROMPT.txt`; `test -f` on named evidence files; `test -x` or `bash -n` on the named runner if instructed; `cat`/`tail` of the newly generated `SMOKE_REPORT.md`; no other tests unless the prepared prompt explicitly allows them. |
| Codex creates/updates | `/workspace/runs/smoke/<timestamp>-<phase>/SMOKE_REPORT.md`; module logs under `/workspace/runs/smoke/<timestamp>-<phase>/module-results/`; optional `POSTCHECK.md` update only if `SMOKE_RUN_CODEX_PROMPT.txt` explicitly says to record the smoke path/result. |
| Codex must not create/update | Project code; global smoke modules; local smoke routines; config/lv/workflow files; companion docs; `INTEGRATION_MANIFEST.md`; destructive cleanup; overwritten old smoke reports; real organ/live outputs. |

#### S-T4B Codex prompt template

```text
Read and follow SMOKE_RUN_CODEX_PROMPT.txt and SMOKE_RUN_PROJECT_CACHE.md.

Do not read the full workflow files, full batch plan, full corrected smoke report, full smoke HOWTO, old batch packages, or unrelated source trees.

This is an execution-only smoke step.

Verify only the files named in SMOKE_RUN_CODEX_PROMPT.txt.
Run exactly the smoke command named in SMOKE_RUN_CODEX_PROMPT.txt.
Return:
- exact command run
- exit status
- SMOKE_REPORT.md path
- PASS/WARN/SKIP/FAIL summary
- exact failing command if any
- whether POSTCHECK.md was updated with the report path, if instructed

Do not edit source code.
Do not edit config/lv/workflow.
Do not edit companion docs.
Do not create INTEGRATION_MANIFEST.md.
Do not run live RunPod, live model/provider calls, Kubernetes mutation, Terraform apply/destroy, Docker containers, or other live/mutating actions.
```

---

### 6.3 Per-batch progress smoke versus logical-group/global smoke

| Smoke type | When | Who prepares instruction set | Who runs | Command pattern |
|---|---|---|---|---|
| Per-batch progress smoke | After every skeleton batch S-T3. | ChatGPT S-T4A. | Codex S-T4B. | `BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh skeleton-progress` or migrated equivalent. |
| Logical-group/global smoke | After every skeleton logical group or contract-changing group checkpoint, before S-T6 companion update. | ChatGPT S-T4A. | Codex S-T4B. | Active runner global/current-state command, for example `bash /workspace/scripts/smoke.sh full` or migrated `bash /workspace/scripts/smoke_current_state.sh platform-current`. |
| Skeleton-complete smoke | After final skeleton batch and required companions/evidence are ready. | ChatGPT may prepare a final S-T4A-style instruction set or use S-T7 directly. | Codex. | `bash /workspace/scripts/smoke.sh skeleton-complete` or migrated equivalent. |

Minimum rule:

```text
Run per-batch skeleton-progress smoke after every skeleton batch.
Run a global/current-state smoke checkpoint after every logical group before updating companion.
Run skeleton-complete smoke after the final skeleton batch.
```

### Smoke report review input

After S-T4B, collect exactly:

```text
/workspace/runs/smoke/<timestamp>-<phase>/SMOKE_REPORT.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

If this was a logical-group/global checkpoint, also collect the latest relevant companion path if S-T6 is next:

```text
/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md
/mnt/ingress/infra/skeleton/companion/INDEX.md
```

---

## 7. Step S-T5 — Read smoke report and decide PASS/WARN/FAIL

| Field | Day-to-day instruction |
|---|---|
| Owner | Human or ChatGPT interprets. Codex only fixes if instructed. |
| When | Immediately after S-T4. |
| Upload to ChatGPT if analysis is needed | Latest `SMOKE_REPORT.md`; latest `POSTCHECK.md`; latest `INTEGRATION_REQUEST.md`; batch `SPEC.md`; batch `RUN_INSTRUCTIONS.md`; failing stdout/stderr log; optional code diff. |
| ChatGPT prompt | `Read SMOKE_REPORT.md, POSTCHECK.md, INTEGRATION_REQUEST.md, SPEC.md, and RUN_INSTRUCTIONS.md. Classify PASS/WARN/FAIL. If FAIL, create a Codex fix prompt naming exact files to edit and the exact smoke command to rerun. Do not invent missing files.` |
| ChatGPT creates | PASS/WARN/FAIL decision; exact missing-file list; exact Codex fix prompt; optional POSTCHECK update text. |
| Codex may run if fixing | Only named file fixes; the same S-T4 smoke command; safe checks named by `RUN_INSTRUCTIONS.md`. |
| Continue condition | Continue only on PASS/SKIP or accepted documented WARN. Stop on FAIL/BLOCKED/missing required evidence. |

### Status handling

| Result | Action |
|---|---|
| PASS | Continue to next step. |
| SKIP | Continue only if SKIP is expected for absent/not-yet-applicable domain. |
| WARN | Classify expected/acceptable versus blocking. Document reason. |
| FAIL | Stop. Fix before continuing. |
| Missing evidence | Stop. List exact missing files. Do not invent evidence. |

---

## 8. Step S-T6 — Update skeleton companion after checked skeleton state

| Field | Day-to-day instruction |
|---|---|
| Owner | Usually ChatGPT drafts; Codex may write to ingress. |
| When | After a skeleton logical group, after a contract-changing skeleton batch, or after skeleton-complete smoke passes/warns acceptably. |
| Upload to ChatGPT | `COMPANION_GENERATOR_INSTRUCTIONS.md`; latest `POSTCHECK.md`; latest `INTEGRATION_REQUEST.md`; latest `SMOKE_REPORT.md`; latest codebase analysis output; existing skeleton `COMPANION.md` if present; existing skeleton `INDEX.md` if present; relevant generated batch `SPEC.md` and `RUN_INSTRUCTIONS.md` if exact commands changed. |
| ChatGPT prompt | `Update the skeleton companion for this checked skeleton state. Use the uploaded POSTCHECK.md, INTEGRATION_REQUEST.md, SMOKE_REPORT.md, codebase analysis, existing COMPANION.md/INDEX.md, and relevant SPEC/RUN_INSTRUCTIONS. Return updated COMPANION.md content and any INDEX.md update. Do not invent missing files. If required evidence is missing, stop and list it. Do not propose config edits here.` |
| ChatGPT creates | Updated `COMPANION.md` content; optional `INDEX.md` update text; optional missing-file report; optional command/contract checklist. |
| Codex must have access to | `/workspace`; skeleton evidence root; latest smoke report; `/mnt/ingress/infra/skeleton/companion/<batch-slug>/`; ChatGPT-created companion content or patch. |
| Codex prompt | `Write the provided skeleton companion update to /mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md. Update INDEX.md only if provided. Do not edit config. Do not run live actions. Preserve existing companion history unless replacement was explicitly provided.` |
| Codex may run | File write commands only; optional `test -f`; optional smoke command only if explicitly requested. |
| Codex creates/updates | Skeleton `COMPANION.md`; optional skeleton `INDEX.md`; optional write log. |
| Codex must not create | Config/lv/workflow edits; organ companion docs; invented integration manifests. |

### Skeleton logical groups

Use the corrected skeleton logical groups from the final workflow, not the older generic ranges.

| Logical group | Skeleton batches | Companion update recommended when |
|---|---|---|
| Foundation/runtime | 01 | Runtime roots, thin remote-model dummy contract, evidence roots, command exposure, or smoke runner contract changes. |
| Research workspace | 02 | `nca-art-grn` workspace/data/runs/artifacts contract changes, dummy science CLI, package policy. |
| AI/PKM/Publisher setup | 03, 04, 05 | AI Engineer roots, PKM skeleton/templates, publisher/LaTeX structure, no-overwrite or no-build guardrails change. |
| GRN/NCA/ART science contracts | 06, 07, 08, 09 | DSL/schema, dummy organ outputs, local smoke output contract, or mechanism report guardrails change. |
| Search contracts | 10, 11, 12 | Search templates, scoring/report schemas, ranking outputs, or local search smoke changes. |
| RunPod dry-run | 13 | Manifest, job-template, dry-run output, secret-name, or no-live RunPod guard changes. |
| OpenClaw reasoning access | 14, 15 | Context indexes, artifact ingest, reasoner configs, or query smoke changes. |
| Agentfield POC | 16, 17, 18 | Spec/status schema, controller, registry, reasoner, bridge, or guarded RunPod target changes. |
| Paperclip adapter | 19, 20 | Request/status mapper, review action mapping, mock card/status output changes. |
| Campaign orchestration | 21, 22, 23, 24 | Campaign schema, agents, review gate, artifact collector, retry/resume/live guard changes. |

Minimum rule:

```text
Run smoke after every skeleton batch.
Update skeleton companion after every logical group or after any contract-changing batch.
```

---

## 9. Global smoke.d and local smoke routines in the daily loop

### Global smoke modules

Global modules live here:

```text
/workspace/tests/smoke.d/*.smoke.sh
```

They are domain-owned, not batch-owned.

Examples:

| Domain | Global module |
|---|---|
| Core runtime/layout | `10-core-layout.smoke.sh` |
| Python/package | `20-python-package.smoke.sh` |
| Skeleton evidence | `30-skeleton-evidence.smoke.sh` |
| Config boundary | `50-config-boundary.smoke.sh` |
| Infra tools | `60-infra-tools.smoke.sh` |
| GRN/NCA/ART | `70-grn-contract.smoke.sh` |
| Research assistant | `90-research-assistant.smoke.sh` |
| RunPod dry-run | future `75-runpod-dryrun.smoke.sh` |
| PKM/OpenClaw | future `80-openclaw-pkm.smoke.sh` |
| Publisher/LaTeX | future `82-publisher-latex.smoke.sh` |
| Agentfield | future `85-agentfield.smoke.sh` |
| Paperclip adapter | future `86-paperclip-adapter.smoke.sh` |
| Campaign | future `88-agentfield-campaign.smoke.sh` |

Create/update a global module only when a domain surface or smoke coverage changes.

Do not create one smoke module per batch.

### Local project smoke routines

Local routines live inside the relevant project or artifact area.

Examples:

```text
/workspace/repos/research-assistant/smoke_test.py
/workspace/repos/nca-art-grn/scripts/local_smoke.sh
/workspace/repos/agentfield/scripts/poc_local_smoke.sh
/workspace/repos/paperclip-agentfield-adapter/scripts/adapter_dryrun.smoke.sh
```

They validate one local subsystem. A global smoke module may call them.

### Daily decision rule

| Change | Update local routine? | Update global module? | Update runner/protocol? |
|---|---:|---:|---:|
| Batch creates a local CLI/fixture/schema smoke path | Yes, if needed | Only if it must be included in current-state smoke | No |
| Batch changes a domain-wide contract | Maybe | Yes, update smallest matching domain module | No |
| New smoke phase/report/module contract | Maybe | Maybe | Yes |
| Runner discovery/report aggregation changes | No | No | Yes |
| Environment/mount/group issue | No | No | No; fix environment and rerun smoke |

---

## 10. Corrected skeleton batch-to-smoke map

| Batch | Slug | Global smoke modules | Smoke verifies | Must not do |
|---:|---|---|---|---|
| 01 | `01-runtime-substrate` | `10-core-layout`, `60-infra-tools`, `90-research-assistant` | `/workspace` roots, `/workspace/runtime`, `/workspace/scripts/runtime_checks`, `/workspace/repos/research-assistant`, Python compile, dummy answer path, evidence files | create `nca-art-grn`, launch RunPod, run containers, call model APIs, run Terraform/Kubernetes mutation |
| 02 | `02-research-workspace` | `20-python-package`, `70-grn-contract`, `30-skeleton-evidence` | `/workspace/repos/nca-art-grn`, `/workspace/data/nca-art-grn`, `/workspace/runs/nca-art-grn`, `/workspace/artifacts/nca-art-grn`, package-policy files, dummy CLI, dummy artifact filenames | run research experiments, train models, build Agentfield, build Paperclip |
| 03 | `03-ai-engineer-workspaces` | `20-python-package`, future `85-agentfield`, future `80-openclaw-pkm`, `30-skeleton-evidence` | `/workspace/repos/agentfield`, `/workspace/repos/openclaw-workspace`, package-policy markers, AI Engineer readiness report | start Agentfield, call models, run OpenClaw jobs, build Paperclip adapter |
| 04 | `04-pkm-skeleton` | future `80-openclaw-pkm`, possibly future `81-zettelkasten` if split | `/workspace/pkm/zettelkasten`, expected folders, templates, bridge paths, no-overwrite sentinel | print note bodies, index whole vault, rewrite notes, auto-promote notes |
| 05 | `05-publisher-latex` | future `82-publisher-latex` | `/workspace/artifacts/papers/grn-paper`, `grn-paper.tex`, `cls/`, `styles/`, `bib/`, `files/grn/`, `fig/grn/`, `tables/grn/`, `build/`, `zettelkasten_bridge/` | install TeX unless explicit, build PDF by default, overwrite manuscript text, consume all Obsidian notes, run simulations, call models |
| 06 | `06-nca-art-base` | `70-grn-contract` | DSL schema/modules/configs, mechanism hypothesis schema/configs, fake 5-node candidate, package import/syntax | run simulation, train NCA, run ART2/ARTMAP, claim discovery |
| 07 | `07-dummy-science-organs` | `70-grn-contract` | dummy simulator/NCA/ART2/ARTMAP/perturbation outputs, expected JSON shapes | large simulations, real NCA training, RunPod, parameter campaigns, real biological claims |
| 08 | `08-mechanism-reporting` | `70-grn-contract` | prototype store, transition graph store, prototype-to-DSL stubs, mechanism report with guardrail headings | infer real biology, overwrite reports, treat final pattern as proof |
| 09 | `09-local-smoke` | `70-grn-contract` | tiny local smoke output folder with `metadata.json`, `candidate.dsl.json`, `simulator_summary.json`, `nca_summary.json`, `art2_prototypes.json`, `artmap_transitions.json`, `pattern_dynamics.json`, `perturbation_summary.json`, `mechanism_report.md` | large simulations, full NCA training, RunPod, parameter campaigns, claim discovery |
| 10 | `10-search-templates` | `70-grn-contract`, future `72-search-contract` if split | search configs, parameter-space schema, baseline/search method templates | run real search, launch campaigns, use distributed compute |
| 11 | `11-search-scoring` | `70-grn-contract`, future `72-search-contract` | scoring schema, shared result schema, ranking config, robustness/perturbation templates, search report template | expensive sweeps, real campaigns, model training |
| 12 | `12-search-smoke` | `70-grn-contract`, future `72-search-contract` | tiny dummy search run writes results, ranking, and report | real candidate campaigns, RunPod, full NCA training |
| 13 | `13-runpod-dryrun` | future `75-runpod-dryrun`, `60-infra-tools` only for optional command presence | local manifests, workspace layout, job templates, dryrun report/status | create RunPod pod, spend credits, call RunPod API, start containers |
| 14 | `14-openclaw-indexes` | future `80-openclaw-pkm` | OpenClaw workspace, context indexes, artifact indexes, bridge configs | index whole vault, print note bodies, call models, run experiments |
| 15 | `15-openclaw-reasoners` | future `80-openclaw-pkm` | reasoner configs, profile templates, query smoke, mocked/local reasoning report | call paid models by default, write notes into vault, launch experiments, build paper output |
| 16 | `16-agentfield-poc` | future `85-agentfield` | Agentfield repo structure, POC import, spec/status schemas, controller entrypoint | start live server by default, call OpenRouter, print keys, claim full discovery platform |
| 17 | `17-agentfield-reasoners` | future `85-agentfield` | registry YAML, invoker, dummy reasoners, fixture JSON, dryrun resolved stages/status | live model calls unless explicit, start server by default, treat POC as real discovery |
| 18 | `18-agentfield-hardening-stubs` | future `85-agentfield` | bridge stubs, artifact/status mapping, mechanism report status, RunPod target stub defaulting to non-live | run `nca-art-grn`, launch RunPod, call real services |
| 19 | `19-paperclip-adapter-core` | future `86-paperclip-adapter` | adapter workspace, paperclip job schema, Agentfield endpoints config, request/status mappers | call live Agentfield, write Paperclip DB, call Paperclip API |
| 20 | `20-paperclip-review-dryrun` | future `86-paperclip-adapter` | fixture Paperclip job maps to Agentfield request; mock response maps to Paperclip card/status/review actions | call live Agentfield by default, submit real Paperclip job, auto-approve actions |
| 21 | `21-campaign-core` | future `88-agentfield-campaign` | campaign schema, campaign status schema, state-store directories, stage registry | run campaign, evaluate candidates, launch RunPod |
| 22 | `22-campaign-agents` | future `88-agentfield-campaign` | agent stubs/configs, evidence/review/next-experiment fields, mechanism guardrails | generate real candidates, declare discovery, run science |
| 23 | `23-campaign-review-smoke` | future `88-agentfield-campaign`, future `86-paperclip-adapter` for payload shape | local fixture campaign writes campaign status, stage results, candidate rankings, artifact refs, next-experiment suggestions, Paperclip review payload | auto-approve, launch next campaign, treat mock result as science |
| 24 | `24-campaign-guarded-stubs` | future `88-agentfield-campaign`, future `75-runpod-dryrun` | live-capability stubs exist but default to dryrun/guarded; retry/resume/comparison/live-submit are not active by default | submit live job, launch RunPod, write Paperclip live data, retry real jobs |

---

## 11. Step S-T7 — Skeleton-complete checkpoint and final skeleton smoke

| Field | Day-to-day instruction |
|---|---|
| Owner | Codex runs skeleton-complete smoke; ChatGPT reviews readiness if needed. |
| When | After Batch 24 or the final planned skeleton batch and required companions are complete. |
| Codex command if `smoke.sh` is active | `bash /workspace/scripts/smoke.sh skeleton-complete` |
| Final canonical command after migration | `bash /workspace/scripts/smoke_current_state.sh skeleton-complete` |
| Upload to ChatGPT if review needed | Skeleton-complete `SMOKE_REPORT.md`; latest skeleton `COMPANION.md`/`INDEX.md`; final or representative `POSTCHECK.md`; final or representative `INTEGRATION_REQUEST.md`; latest codebase analysis; final skeleton `SPEC.md`/`RUN_INSTRUCTIONS.md` if applicable. |
| ChatGPT creates | Skeleton-complete readiness decision; blocker list; optional organ-start checklist; optional Codex fix prompt. |
| Codex creates/updates | `/workspace/runs/smoke/<timestamp>-skeleton-complete/SMOKE_REPORT.md`; optional readiness note; optional `POSTCHECK.md` update with skeleton-complete result. |
| Codex must not create | Organ implementation outputs; config integration edits; `INTEGRATION_MANIFEST.md` unless S-T8 is explicitly started. |

---

## 12. Step S-T8 — Create skeleton integration manifest in ChatGPT

| Field | Day-to-day instruction |
|---|---|
| Owner | ChatGPT. |
| When | After skeleton-complete smoke is PASS or accepted WARN and before vmuser/operator config integration. |
| Upload to ChatGPT | `INTEGRATION_MANIFEST_TEMPLATE.md`; `CONFIG_TOOL.md`; completed skeleton `INTEGRATION_REQUEST.md` files; completed skeleton `POSTCHECK.md` files; skeleton `COMPANION.md`/`INDEX.md`; skeleton-complete `SMOKE_REPORT.md`; relevant codebase analysis; optional `PROJECT_CACHE.md`/`SPEC.md`/`RUN_INSTRUCTIONS.md` for exact commands. |
| ChatGPT prompt | `Read INTEGRATION_MANIFEST_TEMPLATE.md, CONFIG_TOOL.md, completed skeleton INTEGRATION_REQUEST.md files, POSTCHECK.md files, companion docs, and smoke reports. Produce INTEGRATION_MANIFEST.md. Do not repeat the manifest template in the prompt; follow the file.` |
| ChatGPT creates | `INTEGRATION_MANIFEST.md`; optional manifest slices; optional operator Codex batch prompt; missing-evidence report if required files are absent. |
| Codex role | Optional save-only. |
| Codex must not create | Config/lv/workflow edits during planning; organ outputs; invented evidence. |

---

## 13. Step S-T9 — Run vmuser/operator skeleton config integration and post-config smoke

| Field | Day-to-day instruction |
|---|---|
| Owner | ChatGPT may generate operator batch; Codex runs as vmuser/operator. |
| When | After S-T8 manifest exists. This is the first skeleton step where config/lv/workflow edits may occur. |
| Upload to ChatGPT | `general_new_chat_config_integration_batch_generation_prompt.md` if present; `INTEGRATION_MANIFEST.md`; `CONFIG_TOOL.md`; relevant companion docs; skeleton-complete `SMOKE_REPORT.md`; optional current config file list; optional existing lv/workflow snippets. |
| ChatGPT creates | Operator config-integration `CODEX_PROMPT.txt`; `PROJECT_CACHE.md`; `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK_TEMPLATE.md`; exact post-config smoke instruction; optional missing-file report. |
| Codex must have access to | Generated operator config-integration batch files; `/workspace` or config repo; approved config/lv/workflow files; `INTEGRATION_MANIFEST.md`; `CONFIG_TOOL.md`; runner script; previous evidence folders. |
| Codex prompt | `Open and follow the generated operator CODEX_PROMPT.txt, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, INTEGRATION_MANIFEST.md, and CONFIG_TOOL.md. Apply only manifest-approved config/lv/workflow changes. Then run post-config smoke.` |
| Codex may run | Approved config edit commands from `RUN_INSTRUCTIONS.md`; safe validation commands; post-config smoke; config health checks named by `RUN_INSTRUCTIONS.md`. |
| Codex creates/updates | Approved config/lv/workflow files; operator integration `POSTCHECK.md`; post-config `SMOKE_REPORT.md`; optional config health-check logs. |
| Codex must not create | Unapproved science rewrites; new organ live actions; undocumented aliases; config changes not present in the manifest. |

Post-config smoke command:

```bash
# current active runner
bash /workspace/scripts/smoke.sh post-config

# final canonical runner after migration
bash /workspace/scripts/smoke_current_state.sh post-config
```

---

## 14. Quick command ledger

| Situation | Current active runner command | Final canonical command |
|---|---|---|
| After each skeleton batch | `BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh skeleton-progress` | `BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress` |
| After all skeleton batches | `bash /workspace/scripts/smoke.sh skeleton-complete` | `bash /workspace/scripts/smoke_current_state.sh skeleton-complete` |
| Before config integration | `bash /workspace/scripts/smoke.sh pre-config` | `bash /workspace/scripts/smoke_current_state.sh pre-config` |
| After config integration | `bash /workspace/scripts/smoke.sh post-config` | `bash /workspace/scripts/smoke_current_state.sh post-config` |
| Current-state check | `bash /workspace/scripts/smoke.sh full` | `bash /workspace/scripts/smoke_current_state.sh platform-current` |

---

## 15. File tracking checklist by day-to-day step

| Step | Upload to ChatGPT | ChatGPT creates | Codex needs/accesses | Codex creates |
|---|---|---|---|---|
| S-T1 | Batch generation prompt, skeleton master, updated batch plan, templates, config context, optional companion/evidence | Batch zip and five standard files | None | None |
| S-T2 | Optional zip/batch file list only | Optional sanity checklist | Batch zip/folder, `/workspace`, evidence folder | Extracted folder, staging log, evidence folder |
| S-T3 | Troubleshooting only | Optional fix prompt | Batch files, `/workspace`, evidence root | Project code, scripts/tests, `POSTCHECK.md`, `INTEGRATION_REQUEST.md` |
| S-T4 | Only if smoke is missing/broken | Optional smoke fix/clarification | Runner, smoke modules, `/workspace`, evidence files | `SMOKE_REPORT.md`, module logs, optional POSTCHECK smoke path update |
| S-T5 | Smoke report, postcheck, integration request, spec, run instructions, error logs | PASS/WARN/FAIL decision, fix prompt | Only if fixing | Bugfixes, updated evidence, new smoke report |
| S-T6 | Generator instructions, postcheck, integration request, smoke report, codebase analysis, existing companion/index, relevant spec/run instructions | Companion content, optional index update, missing-file list | Ingress companion folder, ChatGPT content, evidence files | `COMPANION.md`, optional `INDEX.md` |
| S-T7 | Skeleton-complete smoke, companions, evidence, code analysis | Readiness decision, blocker list, organ-start checklist | Runner, all skeleton evidence, companion docs | Skeleton-complete smoke report |
| S-T8 | Manifest template, config context, skeleton integration requests, postchecks, companions, smoke reports | `INTEGRATION_MANIFEST.md`, manifest slices, missing-evidence report | Optional save location only | Optional saved manifest |
| S-T9 | Config integration prompt/template, manifest, config context, companions, skeleton-complete smoke | Operator config-integration batch | Config repo/tool files, manifest, runner, evidence | Config/lv/workflow updates, config POSTCHECK, post-config smoke report |

---

## 16. Minimal copy prompts

### S-T1 prompt to ChatGPT

```text
Read and follow general_new_chat_batch_generation_prompt.md.
Set BATCH_NUMBER=<N>.
Use the uploaded skeleton master, updated skeleton_dummy_codex_batch_plan.md, template files, and CONFIG_TOOL.md as read-only context.
Produce one Codex-ready skeleton batch package.
Do not repeat the template prompts manually.
Do not modify config tool files.
```

### S-T2 prompt to Codex

```text
Extract/stage the generated skeleton batch.
Confirm these files exist:
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md

Do not execute implementation yet unless S-T3 is explicitly started.
```

### S-T3 prompt to Codex

```text
Open and follow CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, and CODEX_RECORDING_INSTRUCTIONS.md if present.
Use those files as the source of truth.
Do not paste their contents into the prompt.
Work under /workspace.
Write evidence to /mnt/egress/dev-recordings/skeleton/<batch-slug>/.
Do not edit config/lv/workflow files.
Do not run live/external provider actions unless the batch explicitly allows a guarded dry-run.
```

### S-T4A prompt to ChatGPT

```text
Prepare a cache-aware Codex smoke execution instruction set for the just-completed skeleton batch.

Read the uploaded day_to_day_skeleton_run.md, final_workflow.md, skeleton_dummy_codex_batch_plan.md, Corrected_Smoke_d_Batch_Mapping_Report_Skeleton_Batches_01_24_proper.md, dynamic_smoketest_howto_addendum.md, current batch SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK.md, INTEGRATION_REQUEST.md, and latest SMOKE_REPORT.md only if repairing or comparing a previous smoke run.

Do not make Codex read all those background files.

Produce:
1. SMOKE_RUN_PROJECT_CACHE.md
2. SMOKE_RUN_CODEX_PROMPT.txt

The Codex prompt must be token-sensitive and execution-only.
It must name the exact active runner, phase, BATCH_SLUG, command, evidence files, expected output report path pattern, accepted WARNs if known, and stop conditions.
Also state whether this is per-batch skeleton-progress smoke or logical-group/global checkpoint smoke.
```

### S-T4B prompt to Codex

```text
Read and follow SMOKE_RUN_CODEX_PROMPT.txt and SMOKE_RUN_PROJECT_CACHE.md.

Do not read the full workflow files, full batch plan, full corrected smoke report, full smoke HOWTO, old batch packages, or unrelated source trees.

This is an execution-only smoke step.
Run exactly the smoke command named in SMOKE_RUN_CODEX_PROMPT.txt.
Return the command, exit status, SMOKE_REPORT.md path, summary, and exact failing command if any.

Do not edit source code, config/lv/workflow, companion docs, or integration manifests.
Do not run live RunPod, live model/provider calls, Kubernetes mutation, Terraform apply/destroy, Docker containers, or other live/mutating actions.
```

### S-T5 prompt to ChatGPT

```text
Read the uploaded SMOKE_REPORT.md, POSTCHECK.md, INTEGRATION_REQUEST.md, SPEC.md, and RUN_INSTRUCTIONS.md.
Classify the current skeleton batch state as PASS, acceptable WARN, blocking WARN, FAIL, or BLOCKED.
If fixing is needed, produce an exact Codex fix prompt naming the files to edit and the exact smoke command to rerun.
Do not invent missing evidence.
```

### S-T6 prompt to ChatGPT

```text
Update the skeleton companion for this checked skeleton state.
Use the uploaded POSTCHECK.md, INTEGRATION_REQUEST.md, SMOKE_REPORT.md, codebase analysis, existing COMPANION.md/INDEX.md, and relevant SPEC/RUN_INSTRUCTIONS.
Return updated COMPANION.md content and any INDEX.md update.
Do not invent missing files. If required evidence is missing, stop and list it.
Do not propose config edits here.
```

### S-T7 prompt to Codex

```text
Run the skeleton-complete smoke checkpoint.
Use the active runner for this workspace:
bash /workspace/scripts/smoke.sh skeleton-complete

If the workspace has migrated to the final canonical runner, use:
bash /workspace/scripts/smoke_current_state.sh skeleton-complete

Preserve previous smoke reports.
Do not edit config.
Do not run organ actions.
Return the SMOKE_REPORT.md path.
```

### S-T8 prompt to ChatGPT

```text
Read INTEGRATION_MANIFEST_TEMPLATE.md, CONFIG_TOOL.md, completed skeleton INTEGRATION_REQUEST.md files, POSTCHECK.md files, companion docs, and smoke reports.
Produce INTEGRATION_MANIFEST.md.
Do not repeat the manifest template in the prompt; follow the file.
If required evidence is missing, stop and list exact missing files.
Do not edit config.
```

### S-T9 prompt to Codex

```text
Open and follow the generated operator CODEX_PROMPT.txt, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, INTEGRATION_MANIFEST.md, and CONFIG_TOOL.md.
Apply only manifest-approved config/lv/workflow changes.
Run post-config smoke with the active runner.
Write POSTCHECK.md, include the smoke report path, and list every changed file.
Do not create unapproved config entries or science implementation changes.
```

---

## 17. Daily stop rules

Stop immediately when any of these occurs:

```text
required batch file missing
required evidence path missing
POSTCHECK.md missing
INTEGRATION_REQUEST.md missing
smoke runner missing or broken
SMOKE_REPORT.md shows FAIL
SMOKE_REPORT.md shows unexpected WARN not yet classified
mount/permission issue blocks evidence or reports
Codex proposes config edits during S-T1 through S-T8
Codex proposes live RunPod/model/Kubernetes/Terraform mutation by default
```

Do not continue by guessing. Upload the exact report/log and ask for a fix prompt.

---

## 18. One-page daily rule

```text
Generate one skeleton batch package in ChatGPT.

Stage it.

Run Codex implementation from the named batch files only.

Write POSTCHECK.md and INTEGRATION_REQUEST.md.

Run the active dynamic smoke runner.

Review SMOKE_REPORT.md.

Continue only on PASS/SKIP/accepted WARN.

Update companion only at logical checkpoints or contract changes.

After all skeleton batches, run skeleton-complete.

Create integration manifest only after skeleton-complete.

Run config integration only later as vmuser/operator from a manifest-approved batch.
```
