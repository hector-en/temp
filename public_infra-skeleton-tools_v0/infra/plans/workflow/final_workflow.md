# Final Workflow — Skeleton/Organ Batches, Dynamic Smoke, Global `smoke.d`, and Local `*.smoke.sh`

This file is the consolidated operating workflow for the current Infra-Skeleton process.

It links:

```text
logical implementation groups
batch evidence
general/global smoke.d modules
local project/domain *.smoke.sh routines
IDEMPOTENT_SMOKETEST_DYNAMIC.md
smoke_current_state.sh
SMOKE_REPORT.md
companion updates
operator/config integration
```

It applies the corrected smoke.d mapping for Skeleton Batches 01–24 and the dynamic smoke-test workflow addendum.

---

## 1. Canonical truth model

| Area | Canonical rule |
|---|---|
| Shared project root | `/workspace` is the shared project workspace for code, runs, artifacts, models, outputs, and generated platform files. |
| Skeleton evidence | `/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md` and `/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md`. |
| Organ evidence | `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md` and `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md`. |
| Skeleton companion | `/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md`. |
| Organ companion | `/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md`. |
| Dynamic smoke protocol | `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`. |
| Dynamic smoke orchestrator | `/workspace/scripts/smoke_current_state.sh`. |
| General/global smoke modules | `/workspace/tests/smoke.d/*.smoke.sh`. |
| Smoke reports | `/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md`. |
| Module result logs | `/workspace/runs/smoke/<timestamp-phase>/module-results/`. |
| Config edits | Never edit config/lv/workflow during skeleton or organ implementation batches. Only vmuser/operator config-integration batches may edit config/lv/workflow. |
| Missing files | Stop, list exact missing files, classify required/optional, and do not invent evidence. |
| Live actions | Smoke must be safe and idempotent. No Terraform apply/destroy, no Kubernetes mutation, no live RunPod creation, no live model/provider API call, no real organ action unless explicitly gated. |

---

## 2. Three smoke layers and how they link

The workflow has three separate smoke layers. Do not merge them.

| Layer | Path | Owner | Purpose | When updated |
|---|---|---|---|---|
| Protocol | `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` | ChatGPT drafts; Codex writes | Defines phases, module contract, status meanings, safety rules, global/local smoke relationship, report format, and forbidden actions. | Only when the smoke architecture changes. |
| Orchestrator | `/workspace/scripts/smoke_current_state.sh` | Codex writes/updates | Discovers global `smoke.d` modules, creates report directory, exports environment, runs modules, aggregates PASS/WARN/SKIP/FAIL into `SMOKE_REPORT.md`. | Only when the protocol, phases, reporting, or module contract changes. |
| Global modules | `/workspace/tests/smoke.d/*.smoke.sh` | Codex writes/updates | Domain-owned checks for workspace, evidence, infra, GRN/NCA/ART, RunPod dry-run, PKM/OpenClaw, publisher, Agentfield, Paperclip adapter, campaigns. | After each batch if a new/changed domain surface needs a global smoke check. |
| Local routines | Project/domain-local `*.smoke.sh` or tiny safe CLI smoke routines | Codex writes/updates with the implementation batch | Validate one local package, CLI, fixture, schema, or dry-run path. They are called by a global module or run directly during development. | When a batch creates a new local subsystem that needs its own safe check. |

### Key distinction

```text
smoke_current_state.sh
  runs the whole current-state smoke suite.

tests/smoke.d/*.smoke.sh
  are global/domain-owned modules discovered by the orchestrator.

local *.smoke.sh routines
  belong to a project/domain implementation and may be called by a global module.
```

A global smoke module may call a local smoke routine, but the local routine does not replace the global module.

---

## 3. Global smoke.d versus local *.smoke.sh

| Question | Global `/workspace/tests/smoke.d/*.smoke.sh` | Local `*.smoke.sh` routine |
|---|---|---|
| Scope | One platform/domain area across the workspace. | One specific project, package, fixture, CLI, or subsystem. |
| Discovery | Automatically discovered by `smoke_current_state.sh`. | Not globally discovered unless a global module calls it. |
| Report role | Writes status/logs into global smoke report context. | Returns local PASS/WARN/SKIP/FAIL or exits safely; global module records the result. |
| Naming | `NN-domain.smoke.sh`. | Domain-local name, for example `smoke_test.py`, `local_smoke.sh`, `adapter_dryrun.smoke.sh`, or package-specific smoke helper. |
| Phase awareness | Required. Must know whether `skeleton-progress`, `organ-progress`, `pre-config`, etc. applies. | Optional, unless the local routine is called across multiple phases. |
| Evidence awareness | Should check `POSTCHECK.md`, `INTEGRATION_REQUEST.md`, and batch slug when relevant. | Usually checks only local files/outputs. |
| Safety boundary | Must never perform live/mutating actions by default. | Must also be safe; if it has live capability, it must default to dry-run/blocked. |
| When to create | When a domain surface exists or changes. | When a batch implementation creates a domain-local smokeable surface. |

### Pattern

```text
smoke_current_state.sh
  -> discovers /workspace/tests/smoke.d/70-grn-contract.smoke.sh
     -> checks evidence and phase
     -> optionally calls /workspace/repos/nca-art-grn/<local-smoke-routine>
     -> records result in /workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
```

---

## 4. Canonical phases and commands

| Phase | When to run | Command pattern |
|---|---|---|
| `skeleton-progress` | After every skeleton batch. | `BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress` |
| `skeleton-complete` | After all skeleton batches. | `bash /workspace/scripts/smoke_current_state.sh skeleton-complete` |
| `organ-progress` | After every organ batch. | `BATCH_SLUG="<organ-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress` |
| `organ-complete` | After all organ batches. | `bash /workspace/scripts/smoke_current_state.sh organ-complete` |
| `pre-config` | Before vmuser/operator config integration. | `bash /workspace/scripts/smoke_current_state.sh pre-config` |
| `post-config` | After vmuser/operator config integration. | `bash /workspace/scripts/smoke_current_state.sh post-config` |
| `platform-current` | Anytime current-state check is needed. | `bash /workspace/scripts/smoke_current_state.sh platform-current` |

Compatibility note:

```text
If the current workspace still uses /workspace/scripts/smoke.sh as the active DYN-SMOKE v2 runner, keep using it for existing batches until D-SM2 explicitly creates or updates smoke_current_state.sh.

Do not silently switch runners in the middle of a batch. Switch only through the D-SM1/D-SM2 protocol + orchestrator update workflow.
```

---

## 5. Status meanings

| Status | Meaning | Continue? |
|---|---|---|
| PASS | Applicable current-state check passed. | Yes. |
| SKIP | Domain is absent or phase does not apply. | Yes, if expected. |
| WARN | Optional tool/evidence/config is missing, or a non-blocking readiness issue exists. | Usually yes, but record exact reason. |
| FAIL | Required current-state contract is broken. | No. Stop and fix before continuing. |
| BLOCKED | Required file, mount, credential placeholder, permission, or evidence path is unavailable. | No. Provide/fix exact missing item first. |

---

## 6. When to update `IDEMPOTENT_SMOKETEST_DYNAMIC.md`

Do not regenerate the smoke protocol after every batch.

Update `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` only when one of these changes:

| Trigger | Update protocol? | Reason |
|---|---:|---|
| New smoke phase is introduced. | Yes | The orchestrator and all modules need a shared phase contract. |
| Module input variables change. | Yes | Modules need a stable environment contract. |
| PASS/WARN/SKIP/FAIL/BLOCKED meanings change. | Yes | Report interpretation changes. |
| Report directory or report schema changes. | Yes | Companion and postcheck consumers depend on it. |
| Global/local smoke relationship changes. | Yes | The protocol must define what global modules may call and what local routines may write. |
| New domain class appears, such as Paperclip adapter or campaign orchestration, but existing module contract still covers it. | Usually no | Add a domain module; do not update protocol unless the contract changes. |
| A single batch adds files under an already-known domain. | No | Update or run that domain module only. |
| A smoke module has a bug. | No | Repair only that module. |
| Batch evidence path changes. | Yes, if canonical path changes | Evidence roots are part of the smoke contract. |
| Only expected WARN reasons change for a batch. | No | Record in POSTCHECK/companion, not protocol. |

### D-SM1 — protocol update workflow

| Field | Exact workflow |
|---|---|
| Owner | ChatGPT drafts; Codex writes. |
| Inputs | Current `IDEMPOTENT_SMOKETEST_DYNAMIC.md` if present; workflow/correction files; latest smoke reports if the change is motivated by failure; current `smoke_current_state.sh` if present. |
| ChatGPT output | Updated `IDEMPOTENT_SMOKETEST_DYNAMIC.md` content or patch. |
| Codex action | Write/update `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`. |
| Codex may run | `mkdir -p /workspace/docs`; `test -f /workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`. |
| Codex must not do | Edit config; run live actions; change smoke modules unless explicitly included in the same approved smoke architecture update. |

---

## 7. When to update `smoke_current_state.sh`

Update `/workspace/scripts/smoke_current_state.sh` only when orchestration behavior changes.

| Trigger | Update orchestrator? | Reason |
|---|---:|---|
| New phase is added. | Yes | The orchestrator must validate and export it. |
| Environment variables exported to modules change. | Yes | Module contract changes. |
| Report format or module log directory changes. | Yes | Aggregation/reporting changes. |
| Module discovery rules change. | Yes | Orchestrator owns discovery. |
| Strict mode, warning policy, or failure aggregation changes. | Yes | Orchestrator owns final status. |
| Adding a new domain module under `tests/smoke.d`. | No | Discovery should already pick it up. |
| Adding a local routine in a project repo. | No | A global module may call it. |
| Batch evidence content changes. | No | A module reads evidence; orchestrator stays stable. |
| Config integration adds aliases around smoke. | Usually no | Wrappers may call the orchestrator; orchestrator does not need to know aliases. |

### D-SM2 — orchestrator update workflow

| Field | Exact workflow |
|---|---|
| Owner | Codex creates/updates from the protocol; ChatGPT may draft patches. |
| Inputs | `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md`; existing `/workspace/scripts/smoke_current_state.sh` if present; one `SMOKE_REPORT.md` if debugging report format. |
| Codex action | Create/update `/workspace/scripts/smoke_current_state.sh`. |
| Orchestrator must | Discover sorted `/workspace/tests/smoke.d/*.smoke.sh`; create `/workspace/runs/smoke/<timestamp-phase>/`; export phase/batch/report/project paths; run modules; capture status; write `SMOKE_REPORT.md`; exit nonzero on FAIL and on strict WARN if configured. |
| Codex may run | `mkdir -p /workspace/scripts /workspace/tests/smoke.d /workspace/runs/smoke`; `chmod +x /workspace/scripts/smoke_current_state.sh`; `bash -n /workspace/scripts/smoke_current_state.sh`; `bash /workspace/scripts/smoke_current_state.sh platform-current`. |
| Codex must not do | Put domain-specific checks into the orchestrator; edit config; run live or mutating actions. |

---

## 8. When to create/update global smoke.d modules

Global `smoke.d` modules are domain-owned. Do not create one new smoke module per batch by default.

Create or update a global module when:

```text
a batch creates a new domain surface
a batch changes a domain output contract
a batch changes evidence/readiness expectations
a local routine needs to be included in the platform smoke suite
a previous smoke report shows a real gap in domain coverage
```

Do not update a global module when:

```text
only a local implementation detail changed and the existing domain smoke still covers it
only the batch POSTCHECK text changed
only optional WARN wording changed
the failure is an environment/mount/group issue outside the module contract
```

### D-SM3 — global module creation/update workflow

| Field | Exact workflow |
|---|---|
| Owner | ChatGPT designs module boundary; Codex writes/updates. |
| Inputs | Batch `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK.md`; `INTEGRATION_REQUEST.md`; latest `SMOKE_REPORT.md`; current file list/content of `/workspace/tests/smoke.d/`; relevant local routine if present. |
| ChatGPT output | Name exact module to create/update; explain why; name exact files Codex may read; name exact command to run. |
| Codex action | Add/update only the required `/workspace/tests/smoke.d/NN-domain.smoke.sh` module. |
| Codex may run | `bash -n /workspace/tests/smoke.d/NN-domain.smoke.sh`; then the correct phase smoke command. |
| Codex must not do | Rewrite unrelated modules; edit config; install packages; run live/deploy/apply actions; delete old reports. |

---

## 9. When to create/update local `*.smoke.sh` routines

Local routines belong to the implementation surface, not to the global smoke framework.

Create a local routine when a batch introduces a specific package/CLI/fixture that needs a tiny, repeatable, local safety check.

Examples:

| Domain | Local routine example | Global module that may call it |
|---|---|---|
| Research assistant | `/workspace/repos/research-assistant/smoke_test.py` or local helper | `90-research-assistant.smoke.sh` |
| NCA/ART/GRN | `/workspace/repos/nca-art-grn/scripts/local_smoke.sh` | `70-grn-contract.smoke.sh` |
| RunPod dry-run | `/workspace/repos/<project>/scripts/runpod_dryrun.smoke.sh` | `75-runpod-dryrun.smoke.sh` |
| Publisher/LaTeX | `/workspace/artifacts/papers/grn-paper/scripts/latex_structure_smoke.sh` | `82-publisher-latex.smoke.sh` |
| Agentfield | `/workspace/repos/agentfield/scripts/poc_local_smoke.sh` | `85-agentfield.smoke.sh` |
| Paperclip adapter | `/workspace/repos/paperclip-agentfield-adapter/scripts/adapter_dryrun.smoke.sh` | `86-paperclip-adapter.smoke.sh` |
| Campaign | `/workspace/repos/<campaign-project>/scripts/campaign_fixture_smoke.sh` | `88-agentfield-campaign.smoke.sh` |

Local routine rules:

```text
Must be safe and idempotent.
Must not call live providers by default.
Must not print secrets.
Must not mutate config.
Must not launch RunPod, apply Terraform, or mutate Kubernetes.
May create tiny local test outputs only where the batch contract allows it.
Should be callable directly for debugging.
Should return clear PASS/WARN/SKIP/FAIL or a deterministic zero/nonzero result that the global module interprets.
```

---

## 10. Corrected domain module model

| Smoke domain | Global module | Owns |
|---|---|---|
| Core runtime/layout | `10-core-layout.smoke.sh` | `/workspace` roots, generic runtime layout, basic runner/report roots |
| Python package/import | `20-python-package.smoke.sh` | package markers/import/syntax where relevant |
| Skeleton evidence | `30-skeleton-evidence.smoke.sh` | `POSTCHECK.md`, `INTEGRATION_REQUEST.md` |
| Config boundary | `50-config-boundary.smoke.sh` | confirms project batches did not edit config internals |
| Infra tools | `60-infra-tools.smoke.sh` | safe command presence only: docker, terraform, kubectl, runpod, GPU |
| GRN/NCA/ART contracts | `70-grn-contract.smoke.sh`, later may split | DSL, dummy science outputs, mechanism reports, search outputs |
| Research assistant | `90-research-assistant.smoke.sh` | Batch 01 dummy answer path / remote-model contract |
| RunPod dry-run | future `75-runpod-dryrun.smoke.sh` | manifests, job templates, no live RunPod |
| PKM/OpenClaw | future `80-openclaw-pkm.smoke.sh` | indexes, bridges, reasoner profiles, no vault write |
| Publisher/LaTeX | future `82-publisher-latex.smoke.sh` | paper skeleton, TeX structure, no PDF build by default |
| Agentfield | future `85-agentfield.smoke.sh` | POC schemas, controller, reasoners, fixtures, dryrun only |
| Paperclip adapter | future `86-paperclip-adapter.smoke.sh` | adapter schema/mappers/dryrun card, no live Paperclip |
| Campaign orchestration | future `88-agentfield-campaign.smoke.sh` | campaign schemas, state, review payload, human gate |

---

## 11. Skeleton logical groups and their smoke links

Use these logical groups to decide when to update companions and when smoke coverage needs review.

| Logical group | Skeleton batches | Global smoke module focus | Local routine focus | Companion update trigger |
|---|---|---|---|---|
| Foundation/runtime | 01 | `10-core-layout`, `60-infra-tools`, `90-research-assistant` | research-assistant dummy answer path; runtime checks | Runtime roots, thin remote-model dummy contract, evidence roots, or command exposure changes. |
| Research workspace | 02 | `20-python-package`, `70-grn-contract`, `30-skeleton-evidence` | dummy science CLI and package-policy checks | `nca-art-grn` workspace/data/runs/artifacts contract changes. |
| AI/PKM/Publisher setup | 03, 04, 05 | `20-python-package`, future `80-openclaw-pkm`, future `82-publisher-latex`, future `85-agentfield` | dev workspace checks, PKM template checks, LaTeX structure checks | AI Engineer roots, PKM skeleton, or publisher/LaTeX structure changes. |
| GRN/NCA/ART science contracts | 06, 07, 08, 09 | `70-grn-contract` | local NCA/ART/GRN fixture smoke routines | DSL/schema, dummy organ outputs, mechanism reports, or local smoke output contract changes. |
| Search contracts | 10, 11, 12 | `70-grn-contract`, future `72-search-contract` if split | local tiny search smoke | Search templates, scoring/report schemas, ranking outputs, or local search smoke changes. |
| RunPod dry-run | 13 | future `75-runpod-dryrun`, `60-infra-tools` only for optional tools | local RunPod dry-run manifest/template checks | Manifest/job-template/dry-run report contract changes. |
| OpenClaw reasoning access | 14, 15 | future `80-openclaw-pkm` | local query smoke / mocked reasoning report | Context indexes, artifact ingest, reasoner configs, or query smoke changes. |
| Agentfield POC | 16, 17, 18 | future `85-agentfield` | local Agentfield POC dry-run | Spec/status schema, controller, registry, reasoner, bridge, or guarded RunPod target changes. |
| Paperclip adapter | 19, 20 | future `86-paperclip-adapter` | local adapter dry-run fixture | Request/status mapper, review action mapping, mock card/status output changes. |
| Campaign orchestration | 21, 22, 23, 24 | future `88-agentfield-campaign`, future `75-runpod-dryrun`, future `86-paperclip-adapter` for payload shape | local campaign fixture smoke | Campaign schema, agents, review gate, artifact collector, retry/resume/live-guard changes. |

---

## 12. Corrected skeleton batch-to-smoke map

| Batch | Slug | Global modules | Smoke verifies | Must not do |
|---:|---|---|---|---|
| 01 | `01-runtime-substrate` | `10-core-layout`, `60-infra-tools`, `90-research-assistant` | `/workspace` roots, `/workspace/runtime`, `/workspace/scripts/runtime_checks`, `/workspace/repos/research-assistant`, Python compile, dummy answer path, evidence files | create `nca-art-grn`, launch RunPod, run containers, call model APIs, run Terraform/Kubernetes mutation |
| 02 | `02-research-workspace` | `20-python-package`, `70-grn-contract`, `30-skeleton-evidence` | `/workspace/repos/nca-art-grn`, `/workspace/data/nca-art-grn`, `/workspace/runs/nca-art-grn`, `/workspace/artifacts/nca-art-grn`, package-policy files, dummy CLI, dummy artifact filenames | run research experiments, train models, build Agentfield, build Paperclip |
| 03 | `03-ai-engineer-workspaces` | `20-python-package`, future `85-agentfield`, future `80-openclaw-pkm`, `30-skeleton-evidence` | `/workspace/repos/agentfield`, `/workspace/repos/openclaw-workspace`, package-policy markers, AI Engineer readiness report | start Agentfield, call models, run OpenClaw jobs, build Paperclip adapter |
| 04 | `04-pkm-skeleton` | future `80-openclaw-pkm`, possibly future `81-zettelkasten` if split | `/workspace/pkm/zettelkasten`, expected folders, templates, bridge paths, no-overwrite sentinel | print note bodies, index whole vault, rewrite notes, auto-promote notes |
| 05 | `05-publisher-latex` | future `82-publisher-latex` | `/workspace/artifacts/papers/grn-paper`, `grn-paper.tex`, `cls/`, `styles/`, `bib/`, `files/grn/`, `fig/grn/`, `tables/grn/`, `build/`, `zettelkasten_bridge/` | install TeX unless explicit, build PDF by default, overwrite manuscript text, consume all Obsidian notes, run simulations, call models |
| 06 | `06-nca-art-base` | `70-grn-contract` | DSL schema/modules/configs, mechanism hypothesis schema/configs, fake 5-node candidate, package import/syntax | run simulation, train NCA, run ART2/ARTMAP, claim discovery |
| 07 | `07-dummy-science-organs` | `70-grn-contract` | dummy simulator/NCA/ART2/ARTMAP/perturbation outputs, expected JSON shapes | large simulations, real NCA training, RunPod, parameter campaigns, real biological claims |
| 08 | `08-mechanism-reporting` | `70-grn-contract` | prototype store, transition graph store, prototype-to-DSL stubs, mechanism report with guardrail headings | infer real biology, overwrite reports, treat final pattern as proof |
| 09 | `09-local-smoke` | `70-grn-contract` | tiny local smoke config and output folder containing `metadata.json`, `candidate.dsl.json`, `simulator_summary.json`, `nca_summary.json`, `art2_prototypes.json`, `artmap_transitions.json`, `pattern_dynamics.json`, `perturbation_summary.json`, `mechanism_report.md` | large simulations, full NCA training, RunPod, parameter campaigns, claim discovery |
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

## 13. Batch workflow with smoke and companions

### Skeleton batch loop

| Step | Owner | Action | Smoke action |
|---:|---|---|---|
| S-T1 | ChatGPT | Generate next skeleton batch package from the batch plan and templates. | No smoke yet. |
| S-T2 | User/Codex | Place batch files in project/Codex context. | No smoke yet. |
| S-T3 | Codex | Implement the skeleton batch under `/workspace`; write `POSTCHECK.md` and `INTEGRATION_REQUEST.md`. | Local implementation smoke may run during development if the batch creates local routines. |
| S-T4 | Codex | Run global current-state smoke for the batch. | `BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress`. |
| S-T5 | User/ChatGPT | Review `SMOKE_REPORT.md`, `POSTCHECK.md`, `INTEGRATION_REQUEST.md`. | Continue only on PASS, SKIP, or acceptable documented WARN. Stop on FAIL/BLOCKED. |
| S-T6 | ChatGPT/Codex | Update skeleton companion after logical group or contract change. | Use latest smoke report as checked-state evidence. |
| S-T7 | Repeat | Continue to next skeleton batch. | Repeat smoke after each batch. |
| S-T8 | Codex/ChatGPT | After Batch 24, run skeleton-complete and update final skeleton companion/index. | `bash /workspace/scripts/smoke_current_state.sh skeleton-complete`. |
| S-T9 | ChatGPT | Prepare evidence for later config integration. | No config edit yet. |

### Organ batch loop

| Step | Owner | Action | Smoke action |
|---:|---|---|---|
| O-T1 | ChatGPT | Generate next organ batch package from transition plan and current skeleton evidence. | No smoke yet. |
| O-T2 | Codex | Implement organ batch under `/workspace`. | Local organ dry-run routines may run during development. |
| O-T3 | Codex | Write organ `POSTCHECK.md` and `INTEGRATION_REQUEST.md`. | Evidence is ready for global smoke. |
| O-T4 | Codex | Run global current-state smoke. | `BATCH_SLUG="<organ-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress`. |
| O-T5 | ChatGPT/User | Review smoke and evidence. | Continue only on PASS, SKIP, or acceptable documented WARN. |
| O-T6 | ChatGPT/Codex | Update organ companion after logical group or contract change. | Use latest smoke report as checked-state evidence. |
| O-T7 | Repeat | Continue through all organ batches. | Repeat smoke after each organ batch. |
| O-T8 | Codex/ChatGPT | Run organ-complete and update final organ companion/index. | `bash /workspace/scripts/smoke_current_state.sh organ-complete`. |

### Config integration loop

| Step | Owner | Action | Smoke action |
|---:|---|---|---|
| C-T1 | Codex/User | Run pre-config smoke. | `bash /workspace/scripts/smoke_current_state.sh pre-config`. |
| C-T2 | vmuser/operator | Read completed `INTEGRATION_REQUEST.md` files and companion docs. | No project implementation changes. |
| C-T3 | vmuser/operator | Apply dedicated config-integration batches only. | Config/lv/workflow edits allowed only here. |
| C-T4 | Codex/User | Run post-config smoke. | `bash /workspace/scripts/smoke_current_state.sh post-config`. |
| C-T5 | ChatGPT/User | Review final reports and update final companion/index if needed. | Stop on FAIL/BLOCKED. |

---

## 14. How to create a global smoke.d module

Use this when a domain appears or a domain smoke gap is found.

```text
Read:
- /workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
- /workspace/scripts/smoke_current_state.sh
- current /workspace/tests/smoke.d/
- latest batch POSTCHECK.md
- latest batch INTEGRATION_REQUEST.md
- latest SMOKE_REPORT.md if repairing a failure
- relevant local implementation files only

Create or update:
- /workspace/tests/smoke.d/NN-domain.smoke.sh

Rules:
- keep it phase-aware
- keep it evidence-aware where relevant
- SKIP if domain absent or phase not applicable
- WARN for optional missing tools/evidence
- FAIL only when a required current-state contract is broken
- call local *.smoke.sh routines only if they are safe/local/dry-run
- write only under the smoke report/module-results path unless checking an explicitly allowed local cache
- do not edit config
- do not install packages
- do not run live/deploy/apply actions
```

Validation:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/NN-domain.smoke.sh
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh <phase>
```

---

## 15. How to create a local `*.smoke.sh` routine

Use this inside a batch implementation when a project/domain needs a local fixture test.

```text
Read:
- batch SPEC.md
- batch RUN_INSTRUCTIONS.md
- local implementation files for this subsystem
- relevant output contract/schema

Create or update:
- project-local safe smoke routine, for example /workspace/repos/<project>/scripts/<domain>_local.smoke.sh

Rules:
- test only this subsystem
- do not own global phase policy
- do not write global SMOKE_REPORT.md directly
- return deterministic PASS/WARN/SKIP/FAIL or deterministic exit status/output
- do not call live providers
- do not print secrets
- do not mutate config/lv/workflow
- do not create cloud/cluster/provider resources
```

Then update the relevant global `smoke.d` module only if this local routine should become part of current-state smoke.

---

## 16. What to run after each kind of change

| Change | Run local routine? | Run global smoke? | Update protocol? | Update orchestrator? |
|---|---:|---:|---:|---:|
| Skeleton batch implemented | If batch created one | Yes, `skeleton-progress` | No, unless smoke architecture changed | No, unless orchestration changed |
| Organ batch implemented | If batch created one | Yes, `organ-progress` | No, unless smoke architecture changed | No, unless orchestration changed |
| New global domain module | Optional direct test | Yes, current phase or `platform-current` | No, unless contract changed | No |
| New local routine only | Yes | Only if global module calls it or batch validation requires it | No | No |
| Protocol/contract changed | Optional | Yes, after orchestrator/modules updated | Yes | Usually yes |
| Report format changed | Optional | Yes | Yes | Yes |
| New phase added | Optional | Yes | Yes | Yes |
| Environment/mount permission fixed | No | Re-run the failing phase | No | No |
| Config integration completed | No | Yes, `post-config` | No, unless config smoke contract changed | Maybe, only if post-config module discovery/reporting changed |

---

## 17. Safe checks by domain

| Domain | Safe checks | Forbidden by default |
|---|---|---|
| Workspace/runtime | `test -d /workspace`; check expected roots; check write only where needed for reports/evidence. | Deleting workspace contents. |
| Python/package | `py_compile`, import check, safe CLI help, tiny fixture dry-run. | Package install unless explicitly part of batch; network calls. |
| Skeleton evidence | Verify `POSTCHECK.md`, `INTEGRATION_REQUEST.md`, expected output roots. | Inventing evidence. |
| Organ evidence | Verify organ evidence and safe dry-run output contracts. | Running live organ action. |
| Infra tools | Command presence/version only. | Docker run, Terraform apply/destroy, Kubernetes mutation. |
| GRN/NCA/ART | Fixture schema checks, tiny deterministic dry-run, expected filenames. | Expensive run, real training, discovery claims. |
| RunPod | Template/env shape, dry-run manifest, secret-name presence without values. | Launching pods, printing secrets, spending credits. |
| PKM/OpenClaw | Index/config existence, selected context smoke, mocked/local reasoning report. | Index whole vault, print note bodies, paid model calls by default. |
| Publisher/LaTeX | File structure, TeX project skeleton, bibliography/template paths. | Build PDF by default, overwrite manuscript text. |
| Agentfield | Schema/config/fixture dry-run, controller entrypoint check. | Start live server by default, call OpenRouter. |
| Paperclip adapter | Request/status/review mapping fixture, mock response mapping. | Write live Paperclip records, call live Agentfield by default. |
| Campaign | Schema/state/stage/fixture checks, human review payload. | Auto-approve, launch campaign, treat mock as science. |
| Config integration | Alias/profile/health-check presence; no-op status command. | Config edits outside dedicated vmuser/operator config-integration batch. |

---

## 18. Continue/stop rule

| Result | Next action |
|---|---|
| All PASS/SKIP | Continue to next planned batch or companion update. |
| Expected WARN only | Continue only after documenting the reason in `POSTCHECK.md`, companion, or smoke review. |
| Unexpected WARN | Stop long enough to classify whether it is optional or blocking. |
| FAIL | Stop. Fix the platform issue or failing module. Re-run smoke before continuing. |
| BLOCKED or missing required evidence | Stop. Provide/fix the exact missing path. Do not guess or invent. |

---

## 19. One-page operating rule

```text
Every implementation batch creates or updates project files and evidence.

Every batch then runs global current-state smoke through smoke_current_state.sh.

The orchestrator discovers global domain-owned smoke.d modules.

Global modules may call local *.smoke.sh routines, but only when they are safe, dry-run, and relevant to the phase.

IDEMPOTENT_SMOKETEST_DYNAMIC.md changes only when the smoke protocol changes.

smoke_current_state.sh changes only when orchestration/reporting/discovery behavior changes.

Most batch work should update only project code, evidence, local routines, or the smallest matching global smoke.d module.

Companions update only after checked logical groups, contract changes, or complete milestones.

Config changes happen only later in dedicated vmuser/operator config-integration batches.
```
