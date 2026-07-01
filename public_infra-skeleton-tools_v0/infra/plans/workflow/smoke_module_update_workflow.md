# Smoke Module Update Workflow — Global `smoke.d` and Local `*.smoke.sh`

This document targets one question only:

```text
When and how do we update global /workspace/tests/smoke.d/*.smoke.sh modules
versus local project/domain *.smoke.sh routines?
```

It is aligned with:

```text
final_workflow.md
day_to_day_skeleton_run.md
day_to_day_organs_run.md
skeleton_dummy_codex_batch_plan_UPDATED.md
transition_real_organs_codex_batch_plan_UPDATED.md
dynamic_smoketest_howto_addendum.md
```

It is meant to sit beside the day-to-day skeleton and organ workflows. It does not replace them.

---

## 1. Short answer

There are three different smoke layers:

| Layer | Path | What it does | Who updates it |
|---|---|---|---|
| Smoke protocol | `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` | Defines phases, module contract, statuses, safety rules, runner/module relationship. | ChatGPT drafts; Codex writes only when smoke architecture changes. |
| Runner/orchestrator | `/workspace/scripts/smoke_current_state.sh` or current active `/workspace/scripts/smoke.sh` | Discovers global modules, runs them, writes `SMOKE_REPORT.md`. | Codex updates only when discovery/reporting/phase/env behavior changes. |
| Global smoke modules | `/workspace/tests/smoke.d/*.smoke.sh` | Domain-owned current-state checks. | Codex updates when a domain contract changes or a new domain surface appears. |
| Local smoke routines | Project-local `*.smoke.sh`, `smoke_test.py`, or tiny local smoke CLI | One package/subsystem/fixture dry-run check. | Codex creates/updates inside the batch that owns that subsystem. |

The important rule:

```text
Do not create one global smoke.d module per batch.
Create or update the smallest domain-owned global smoke module only when a domain contract or platform surface changes.
Create local smoke routines when a project/subsystem needs a small repeatable local check.
```

---

## 2. Global versus local smoke

| Question | Global `/workspace/tests/smoke.d/*.smoke.sh` | Local `*.smoke.sh` or local smoke routine |
|---|---|---|
| Scope | Whole workspace/domain current-state check. | One project, CLI, fixture, schema, or subsystem. |
| Discovery | Runner discovers it automatically. | Not discovered globally unless a global module calls it. |
| Typical owner | Smoke framework/domain module. | Batch implementation or project repo. |
| Example | `70-grn-contract.smoke.sh` | `/workspace/repos/nca-art-grn/scripts/local_smoke.sh` |
| Phase awareness | Required. Must understand `skeleton-progress`, `organ-progress`, `pre-config`, etc. | Optional, unless called across phases. |
| Evidence awareness | Usually yes for skeleton/organ phases. | Usually local only. |
| Writes | Only under `$SMOKE_RUN_DIR/module-results/` unless explicitly safe. | Local outputs only where batch contract allows. |
| Failure meaning | Platform/domain contract is broken. | Local subsystem failed. |
| Update trigger | Domain contract changed or new domain appears. | Local CLI/schema/fixture/subsystem changed. |

Pattern:

```text
runner
  -> /workspace/tests/smoke.d/70-grn-contract.smoke.sh
     -> optionally calls /workspace/repos/nca-art-grn/scripts/local_smoke.sh
        -> validates one local real/dummy science path
     -> writes global PASS/WARN/SKIP/FAIL into SMOKE_REPORT.md
```

---

## 3. The dynamic smoke contract

Every global module must obey the dynamic smoke contract:

```text
Filename: NN-domain.smoke.sh
Inputs: PHASE, BATCH_SLUG, PROJECT_ROOT, SMOKE_RUN_DIR, optional ALLOW_LIVE
Writes: only under $SMOKE_RUN_DIR/module-results/ unless explicitly harmless
Safe default: no cloud/cluster/config/live organ/secret/external mutation
Missing absent domain: SKIP or WARN, not FAIL
Real failure: FAIL only when a present required contract is broken
Idempotent: rerun changes only smoke report/logs
Output: short status lines plus module log
```

The runner must remain generic:

```text
discover modules
create smoke run directory
export phase/env variables
run modules
aggregate PASS/WARN/SKIP/FAIL
write SMOKE_REPORT.md
```

Do not put domain-specific checks inside the runner.

---

## 4. Where this fits into the day-to-day workflows

### Skeleton day-to-day placement

| Day-to-day step | Smoke-module decision |
|---|---|
| S-T1 creates skeleton batch package | Usually no module update. The batch may include instructions to create/update local smoke routines or a global module only if the batch creates/changes a domain contract. |
| S-T2 stages batch | No module update. |
| S-T3 implements batch | Local smoke routines may be created/updated if the batch owns a local subsystem. Global smoke modules should be touched only if the batch explicitly changes a domain current-state contract. |
| S-T4A prepares smoke instruction set | ChatGPT decides whether this is run-only or whether a separate smoke-module update package is needed. |
| S-T4B runs smoke | Codex only executes. It does not create/update smoke modules unless the S-T4A prompt explicitly says this is a smoke repair/update task. |
| S-T5 reviews smoke | If FAIL/WARN reveals missing coverage or wrong contract, ChatGPT prepares a separate targeted smoke-module update prompt. |
| S-T6 companion update | Before companion update, run per-batch smoke and, at logical-group boundary, global/current-state smoke. If the domain contract changed, update smoke first, then companion. |

### Organ day-to-day placement

| Day-to-day step | Smoke-module decision |
|---|---|
| O-T1 creates organ batch package | Batch may include local smoke routine requirements and explicit global smoke-module update scope if the organ creates/changes a domain contract. |
| O-T2 stages batch | No module update. |
| O-T3 implements organ | Local organ smoke routines may be created/updated. Global modules only if the organ changes a domain current-state contract. |
| O-T4A prepares organ smoke instruction set | ChatGPT decides run-only versus separate smoke-module update. |
| O-T4B runs smoke | Codex only executes prepared smoke command. |
| O-T5 reviews smoke | If smoke shows missing/incorrect domain coverage, create a separate D-SM3 module update package. |
| O-T6 companion update | Run global/current-state checkpoint after logical organ group. If smoke coverage changed, update modules before writing companion. |

---

## 5. Update trigger matrix

Use this matrix before every smoke-related edit.

| Trigger | Update local routine? | Update global smoke.d module? | Update runner? | Update protocol? |
|---|---:|---:|---:|---:|
| Batch creates a local CLI, fixture, package command, schema validator, or dry-run path. | Yes, usually. | Only if global smoke should call it. | No. | No. |
| Batch changes public output filenames, schema shape, evidence paths, or success criteria for a domain. | Maybe. | Yes, update smallest domain module. | No. | No, unless module contract changes. |
| Batch only changes implementation internals while preserving public contract. | Maybe, if local tests need it. | No. | No. | No. |
| New platform/domain appears, such as RunPod dry-run, PKM/OpenClaw, Publisher, Agentfield, Paperclip, Campaign. | Maybe. | Yes, create/update domain module. | No. | No if existing module contract covers it. |
| New phase appears. | Maybe. | Maybe. | Yes. | Yes. |
| Runner env variables change. | Maybe. | Maybe. | Yes. | Yes. |
| Report path/schema/status meanings change. | Maybe. | Maybe. | Yes. | Yes. |
| Module discovery behavior changes. | No. | Maybe. | Yes. | Yes. |
| Smoke failure is caused by missing evidence file or mount permission. | No. | No, unless module incorrectly classifies it. | No. | No. |
| Smoke failure is caused by module using outdated expected path. | No. | Yes. | No. | No. |
| Smoke failure is caused by runner not exporting expected variables. | No. | Maybe. | Yes. | Maybe. |
| Batch docs are being refined before implementation. | Usually no. | Usually no. | No. | No, unless smoke contract itself changes. |

---

## 6. Decision tree

### A. Should I create or update a local `*.smoke.sh` routine?

Yes when:

```text
the batch creates a new local command
the batch creates a new fixture/dummy output path
the batch creates a new real local dry-run path
the batch introduces a local schema validator
the batch creates a tiny reproducible local proof that one subsystem works
```

No when:

```text
only docs changed
only evidence text changed
only companion wording changed
global module already checks the local contract without needing a new helper
the check is broad platform state rather than local subsystem behavior
```

### B. Should I update a global `smoke.d` module?

Yes when:

```text
a public domain contract changed
a new domain surface appears
a local routine should now be part of current-state smoke
an existing module checks the wrong paths or old filenames
a new skeleton/organ batch creates domain outputs that must be globally visible
a FAIL/WARN shows the module is outdated or under-scoped
```

No when:

```text
the implementation changed internally but outputs are stable
the problem is a missing file that should be created by the batch
the problem is mount/read/write permissions
the problem is optional tool absence already expected as WARN
the user is only updating planning docs and not changing implemented files/contracts yet
```

### C. Should I update the runner?

Yes only when:

```text
phase set changes
module discovery changes
env variables passed to modules change
SMOKE_REPORT.md format changes
aggregation/exit policy changes
compatibility wrapper behavior changes
```

No for normal domain changes.

### D. Should I update `IDEMPOTENT_SMOKETEST_DYNAMIC.md`?

Yes only when:

```text
smoke architecture changes
module contract changes
runner/module relationship changes
status meanings change
phase list changes
forbidden/live-action policy changes
report schema changes
```

No for ordinary Batch 02, research, infra, or organ implementation work.

---

## 7. Current scenario: updating documents for a more detailed Batch 02 contract

Your current situation is document/planning work:

```text
You are updating documents that will later create a more detailed Batch 02 contract.
Batch 02 = 02-research-workspace.
Corrected skeleton mapping says Batch 02 uses:
- prepare_nca_art_workspace
- prepare_experiment_output_layout
- dummy science CLI
- no prepare_grn_workspace
- smoke modules: 20-python-package, 70-grn-contract, 30-skeleton-evidence
```

### Does this trigger local `*.smoke.sh` update now?

Usually **no**, because you are not yet changing implemented code.

It becomes **yes** when the Batch 02 implementation package actually creates or changes one of these:

```text
/workspace/repos/nca-art-grn local CLI
dummy science CLI
local research workspace readiness check
local package/import check
local fixture output generator
local schema validator
```

Then the local routine could be something like:

```text
/workspace/repos/nca-art-grn/scripts/local_smoke.sh
/workspace/repos/nca-art-grn/scripts/dummy_science_cli_smoke.sh
/workspace/repos/nca-art-grn/smoke_test.py
```

### Does this trigger global `smoke.d` update now?

Usually **no**, while it is still only documentation.

It becomes **yes** when the detailed Batch 02 contract changes what global smoke must verify, for example:

```text
new required path under /workspace/repos/nca-art-grn
new required path under /workspace/data/nca-art-grn
new required path under /workspace/runs/nca-art-grn
new required path under /workspace/artifacts/nca-art-grn
new package-policy marker
new dummy CLI command
new dummy artifact filename
new evidence rule
old prepare_grn_workspace reference must be removed from smoke
```

Then update the smallest matching modules:

```text
20-python-package.smoke.sh
  if package/import/compile expectations changed

70-grn-contract.smoke.sh
  if nca-art-grn roots, dummy CLI, dummy science artifacts, or GRN contract changed

30-skeleton-evidence.smoke.sh
  if evidence path or required evidence behavior changed
```

### What should happen before Codex?

Use ChatGPT to prepare a small smoke-module update decision first:

```text
Read updated Batch 02 contract docs, current Batch 02 SPEC/RUN_INSTRUCTIONS if available, latest smoke report if any, and current smoke.d listing/content if changing modules.

Decide:
- no smoke change
- local smoke routine only
- global module update only
- both local routine and global module update
- protocol/runner update
```

Codex should then receive only a compact execution/update prompt, not the full background set.

---

## 8. Future scenario: going deeper into research parts

Research parts map primarily to these skeleton batches and organ batches:

```text
Skeleton 06-09: GRN/NCA/ART science contracts
Skeleton 10-12: search contracts
Organs R02-R06: real DSL, simulator, NCA, ART2/ARTMAP, mechanism report, search
```

### Local smoke trigger in research work

Create/update local routines when you add or change:

```text
DSL candidate generator
mechanism hypothesis generator
PDE/ODE simulator
NCA rollout/training local dry-run
ART2 prototype generator
ARTMAP transition generator
pattern dynamics metrics
perturbation design/run fixture
prototype-to-DSL mapper
mechanism report generator
search sampler
mechanism scoring
candidate ranking
tiny end-to-end local research smoke
```

Typical local routines:

```text
/workspace/repos/nca-art-grn/scripts/dsl_smoke.sh
/workspace/repos/nca-art-grn/scripts/simulator_smoke.sh
/workspace/repos/nca-art-grn/scripts/nca_smoke.sh
/workspace/repos/nca-art-grn/scripts/art_smoke.sh
/workspace/repos/nca-art-grn/scripts/mechanism_report_smoke.sh
/workspace/repos/nca-art-grn/scripts/search_smoke.sh
/workspace/repos/nca-art-grn/scripts/local_smoke.sh
```

### Global smoke trigger in research work

Update global `70-grn-contract.smoke.sh` when public contract changes:

```text
expected JSON filenames
expected report filenames
schema fields
artifact folder layout
safe CLI command
local smoke command path
PASS/WARN/FAIL classification
batch applicability by phase/slug
```

Consider a future split only if `70-grn-contract` becomes too broad:

```text
72-search-contract.smoke.sh
  for search templates/scoring/ranking/local search smoke

73-mechanism-report.smoke.sh
  only if mechanism reporting becomes independent enough to justify it
```

Do not split just because a new batch exists. Split only when the domain is large enough and separately meaningful.

---

## 9. Future scenario: going deeper into infra parts

Infra work maps primarily to:

```text
Skeleton 01: runtime substrate
Skeleton 13: RunPod dry-run
Organs R07: real RunPod dry-run-to-live boundary
Later config integration: aliases, health checks, env profiles
```

### Local smoke trigger in infra work

Create local routines when you add:

```text
RunPod manifest validator
RunPod dry-run client wrapper
remote run manifest generator
checkpoint policy validator
result return policy validator
container readiness script
GPU/CUDA/Torch compatibility probe
```

Example local routines:

```text
/workspace/scripts/runtime_checks/gpu_smoke.sh
/workspace/repos/<project>/scripts/runpod_manifest_smoke.sh
/workspace/repos/<project>/scripts/runpod_dryrun.smoke.sh
```

### Global smoke trigger in infra work

Update or create global modules when infra surfaces become domain-wide:

```text
60-infra-tools.smoke.sh
  command presence and safe readiness only:
  docker, terraform, kubectl, runpod, GPU

75-runpod-dryrun.smoke.sh
  manifests, job templates, dry-run status, no live pod launch
```

### Do not do this by default

```text
docker run
terraform apply/destroy
kubectl apply/delete/scale/restart
runpod pod/job launch
secret print
remote provider call
```

If live capability appears, smoke should check that it is guarded and disabled by default.

---

## 10. Future scenario: PKM/OpenClaw, Publisher, Agentfield, Paperclip, Campaign

| Area | Local smoke routine trigger | Global smoke.d trigger |
|---|---|---|
| PKM/OpenClaw | selected-context query fixture, local mocked reasoning report, index validator | future `80-openclaw-pkm.smoke.sh` when indexes/reasoners become current-state contract |
| Publisher/LaTeX | TeX structure check, bibliography path check, no-build guard check | future `82-publisher-latex.smoke.sh` when paper project structure is required |
| Agentfield | controller local dry-run, schema/status fixture, reasoner registry check | future `85-agentfield.smoke.sh` when POC/controller/reasoner surfaces exist |
| Paperclip adapter | request/status mapper fixture, adapter dry-run card payload | future `86-paperclip-adapter.smoke.sh` when adapter mapping becomes current-state contract |
| Campaign | campaign fixture smoke, stage registry check, review payload mapper | future `88-agentfield-campaign.smoke.sh` when campaign schema/stage/review state exists |

Rule:

```text
Local first for one subsystem.
Global module when the subsystem becomes a platform/domain current-state contract.
```

---

## 11. Batch-specific smoke trigger map

### Skeleton batches

| Skeleton batch/group | Default smoke module action | Local routine action |
|---|---|---|
| 01 runtime substrate | `10-core-layout`, `60-infra-tools`, `90-research-assistant` already relevant. Update only if paths/client contract/tool readiness changes. | Add/update local runtime or research-assistant smoke only if client/check implementation changes. |
| 02 research workspace | Update `20-python-package`, `70-grn-contract`, or `30-skeleton-evidence` only if detailed contract changes implemented paths/CLI/artifacts/evidence. | Add local `nca-art-grn` smoke when dummy CLI/package fixture appears. |
| 03 AI engineer workspaces | Future `85-agentfield`/`80-openclaw-pkm` only when real domain surfaces are meaningful. | Local workspace readiness checks if needed. |
| 04 PKM skeleton | Future `80-openclaw-pkm` or possible `81-zettelkasten` if split. | Local template/no-overwrite smoke if useful. |
| 05 Publisher LaTeX | Future `82-publisher-latex` when paper structure is required. | Local TeX structure smoke. |
| 06-09 GRN/NCA/ART | `70-grn-contract` evolves. Split only if too broad. | Local DSL/simulator/NCA/ART/report/local-smoke routines. |
| 10-12 Search | `70-grn-contract`; future `72-search-contract` if split. | Local search smoke. |
| 13 RunPod dry-run | Future `75-runpod-dryrun`, `60-infra-tools` for optional tools. | Local manifest/job-template dry-run. |
| 14-15 OpenClaw | Future `80-openclaw-pkm`. | Local selected-context query smoke. |
| 16-18 Agentfield | Future `85-agentfield`. | Local controller/registry/reasoner dry-run. |
| 19-20 Paperclip adapter | Future `86-paperclip-adapter`. | Local adapter mapping dry-run. |
| 21-24 Campaign | Future `88-agentfield-campaign`; `86` for payload shape; `75` for RunPod guard. | Local campaign fixture smoke. |

### Organ batches

| Organ batch | Default smoke module action | Local routine action |
|---|---|---|
| R01 contract audit | Usually no new domain module unless audit adds a new required readiness contract. | Local audit script only if repeatable audit command exists. |
| R02 real GRN DSL/simulator | Update `70-grn-contract` if real DSL/simulator changes output contract. | DSL/simulator local smoke. |
| R03 real NCA | Update `70-grn-contract` if NCA output contract changes. | NCA local smoke. |
| R04 real ART2/ARTMAP | Update `70-grn-contract` if prototype/transition outputs change. | ART local smoke. |
| R05 real mechanism report | Update `70-grn-contract` or future report module if report contract changes. | Mechanism report local smoke. |
| R06 real search | Update `70-grn-contract` or future `72-search-contract`. | Search local smoke. |
| R07 RunPod boundary | Update future `75-runpod-dryrun` and maybe `60-infra-tools`. | RunPod manifest/client dry-run smoke. |
| R08 OpenClaw/PKM | Update future `80-openclaw-pkm`. | Selected-context/reasoner smoke. |
| R09 Agentfield | Update future `85-agentfield`. | Agentfield controller/status dry-run smoke. |
| R10 Paperclip adapter | Update future `86-paperclip-adapter`. | Adapter mapping dry-run smoke. |
| R11 Campaign | Update future `88-agentfield-campaign`, maybe `86`, maybe `75`. | Campaign fixture smoke. |
| R12 end-to-end local | Usually no new module unless coverage gap is discovered. | End-to-end local no-live smoke. |

---

## 12. D-SM3 workflow: update smoke modules safely

Use D-SM3 when a trigger says a global module or local routine must change.

### D-SM3A — ChatGPT module update planning

| Field | Exact content |
|---|---|
| Owner | ChatGPT. |
| When | After S-T5/O-T5 reveals a smoke coverage issue, or during S-T1/O-T1 batch generation if the batch explicitly changes smokeable domain contracts. |
| Upload/read | Latest batch `SPEC.md`; `RUN_INSTRUCTIONS.md`; `POSTCHECK.md`; `INTEGRATION_REQUEST.md`; latest `SMOKE_REPORT.md`; relevant day-to-day workflow; corrected skeleton or organ batch plan; current smoke module file list/content only for modules being changed; relevant local routine if changing one. |
| ChatGPT creates | `SMOKE_MODULE_UPDATE_PROJECT_CACHE.md`; `SMOKE_MODULE_UPDATE_CODEX_PROMPT.txt`; optional exact module patch/content. |
| Decision required | local routine only, global module only, both, runner/protocol update, or no update. |
| Codex should not read | Full unrelated workflow files, old batch packages, unrelated smoke modules, unrelated source trees. |

### D-SM3B — Codex module update execution

| Field | Exact content |
|---|---|
| Owner | Codex. |
| Reads only | `SMOKE_MODULE_UPDATE_PROJECT_CACHE.md`; `SMOKE_MODULE_UPDATE_CODEX_PROMPT.txt`; exact files named in the prompt. |
| May update | The named local smoke routine and/or named `/workspace/tests/smoke.d/NN-domain.smoke.sh`. |
| Must not update | Runner, protocol, config, companion docs, integration manifests, unrelated modules, unrelated implementation code unless explicitly named. |
| May run | `bash -n` on edited shell scripts; direct local routine if safe; active runner phase command named by prompt; global/current-state command if named. |
| Must not run | Live/deploy/apply/mutate/provider calls. |
| Output | Changed files, commands run, new `SMOKE_REPORT.md` path, PASS/WARN/SKIP/FAIL summary, remaining risks. |

---

## 13. Minimal prompts

### Ask ChatGPT whether a smoke update is triggered

```text
Review whether this batch/document change triggers a smoke update.

Use the uploaded:
- final_workflow.md
- day_to_day_skeleton_run.md or day_to_day_organs_run.md
- relevant updated batch plan
- current batch SPEC.md and RUN_INSTRUCTIONS.md if available
- POSTCHECK.md and INTEGRATION_REQUEST.md if implementation already ran
- latest SMOKE_REPORT.md if available
- current smoke.d listing/content only if a module may change

Classify:
1. no smoke update
2. local *.smoke.sh routine only
3. global smoke.d module only
4. both local routine and global module
5. runner/protocol update

Name exact files to create/update.
Do not make Codex read broad background files.
```

### Ask ChatGPT to produce a smoke module update package

```text
Produce a cache-aware Codex smoke module update instruction set.

Create:
1. SMOKE_MODULE_UPDATE_PROJECT_CACHE.md
2. SMOKE_MODULE_UPDATE_CODEX_PROMPT.txt

The prompt must name:
- exact module(s) to create/update
- exact local smoke routine(s), if any
- exact files Codex may read
- exact validation commands
- exact active runner command to rerun
- forbidden actions

Do not include broad workflow background in the Codex prompt.
```

### Codex prompt for smoke module update

```text
Read and follow SMOKE_MODULE_UPDATE_CODEX_PROMPT.txt and SMOKE_MODULE_UPDATE_PROJECT_CACHE.md.

Update only the files named there.
Do not read unrelated workflow files, old batch packages, unrelated smoke modules, or unrelated source trees.

Run only the validation commands named there.
Return:
- changed files
- commands run
- smoke report path
- PASS/WARN/SKIP/FAIL summary
- remaining risks

Do not edit config/lv/workflow.
Do not edit companion docs.
Do not create integration manifests.
Do not run live RunPod/model/Kubernetes/Terraform/Docker/provider actions.
```

---

## 14. Anti-patterns

Do not do these:

```text
create one global smoke module per batch
put domain logic into the runner
make Codex read every workflow/planning file for a run-only smoke step
update IDEMPOTENT_SMOKETEST_DYNAMIC.md for ordinary batch contract refinements
update smoke_current_state.sh for ordinary domain contract refinements
treat missing mount/evidence as reason to rewrite smoke modules
silence FAIL by converting it to SKIP without proving the domain is absent
run live infra/model/provider actions from smoke by default
let local smoke routines write global SMOKE_REPORT.md directly
let global modules mutate project state outside SMOKE_RUN_DIR
```

---

## 15. One-page rule

```text
Day-to-day S-T4/O-T4 runs smoke.
D-SM3 changes smoke modules.

Local smoke routines belong to the project/subsystem.
Global smoke.d modules belong to domain current-state checks.
The runner belongs to orchestration only.
The protocol belongs to architecture only.

Planning documents alone usually do not trigger smoke code changes.
Implemented contract changes do.

When a trigger happens:
ChatGPT compresses background into a small smoke update cache/prompt.
Codex updates only named files and runs only named safe commands.
```
