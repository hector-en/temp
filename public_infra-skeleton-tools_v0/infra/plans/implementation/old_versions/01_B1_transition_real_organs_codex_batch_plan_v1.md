# Transition-to-Real-Organs Codex Batch Plan

**Purpose:** use this file in a new chat together with the transition-to-real-organs master MD, skeleton-dummy master MD, template bundles, `CONFIG_TOOL.md`, and the latest skeleton implementation evidence. It defines small Codex implementation batches for replacing the dummy skeleton organs with real first-pass organs while preserving the skeleton contracts.

**Use case:** parallel branches after the skeleton-dummy batches exist. Each branch can take one real-organ batch zip generated from this plan and implement only that slice.

**Master file role:** the transition-to-real-organs master MD is the authoritative roadmap for real implementation work. The skeleton-dummy master MD remains the contract reference: real organs must preserve the same commands, filenames, schemas, and smoke-test expectations unless the transition master explicitly updates them.

**Template format:** every generated implementation batch should contain exactly:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

**No README is required.**

---

## Global rules for every generated real-organ batch

```text
Do not edit the config tool.
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh unless the batch explicitly says otherwise.
Use config only for inspection/status/explicit existing step execution.
Use the existing skeleton outputs as contracts.
Replace dummy internals, not public contracts, unless the transition master explicitly says to revise a contract.
Preserve CLI command names where possible.
Preserve output filenames and schema shapes where possible.
Record changes and evidence under /mnt/egress/organs/dev-recordings.
Write only development evidence during Codex runs. The companion generator later writes readable docs under /mnt/ingress/infra/organs/companion or the active companion root supplied in the prompt.
Use the project workspace root /home/researchscientist/workspace unless the selected batch explicitly overrides it.
Do not run expensive jobs, live provider calls, live Paperclip writes, real OpenClaw agents, or Runpod jobs unless the batch explicitly marks them as approved dry-run/live actions.
Do not read or print secrets.
```

`CONFIG_TOOL.md` should be included only when the real-organ batch needs role/config/lv context. It is read-only context.

## Posthoc config integration bridge

Real-organ batches must not turn roadmap names into config steps early. Each implemented batch should create or update:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

The request records actual implemented paths, CLIs, packages, smoke checks, outputs, role owner, suggested integration type, safety boundaries, and open questions. A later operator/vmuser config-integration batch reads these requests and decides whether the organ becomes a bootstrap step, lv profile, role workflow, alias, health check, dry-run hook, or remains project-only.

If no config integration is needed, still write the request and mark suggested integration type as `none`.

---

## Continuity inputs for every real-organ batch

When available, use these as trajectory context before writing the batch zip:

```text
Latest skeleton implementation postcheck / Codex evidence:
/mnt/egress/organs/dev-recordings

Current readable organ companion docs:
/mnt/ingress/infra/organs/companion

Current codebase snapshot uploaded by user after the last Codex run

Skeleton-dummy batch plan:
skeleton_dummy_codex_batch_plan.md

Skeleton-dummy master:
00_skeleton_dummy_master_implementation_companion.md

Transition-to-real-organs master:
00_transition_to_real_organs_master.md
or the exact uploaded transition master filename supplied by the user
```

If optional trajectory evidence is missing, say so briefly and proceed from the transition master and skeleton contracts. If required master or template files are missing, stop and report the exact missing file.

---

## Proposed transition-to-real-organs batch list

| Batch | Depends on skeleton batch(es) | Scope | Main purpose | Include `CONFIG_TOOL.md`? |
|---:|---|---|---|---|
| R01 | 01, 02, 06 | Real workspace contract audit | Read current codebase/postlogs, verify skeleton contracts, create real-organ migration checklist | optional |
| R02 | 06, 07 | Real GRN DSL and simulator core | Replace dummy DSL candidate and PDE/ODE simulator with first-pass real deterministic modules | no |
| R03 | 07 | Real NCA local-rule organ | Replace dummy NCA summaries with trainable/evaluable local-rule surrogate interface and deterministic smoke path | no |
| R04 | 07, 08 | Real ART2 / ARTMAP prototype organs | Replace dummy ART2 prototype and ARTMAP transition outputs with first-pass clustering/mapping implementations | no |
| R05 | 08, 09 | Real mechanism report organ | Replace dummy mechanism report assembly with evidence-based report generation over simulator/NCA/ART/perturbation outputs | no |
| R06 | 10, 11, 12 | Real parameter search organ | Replace dummy search templates/scoring with runnable local search drivers and comparable result records | no |
| R07 | 13 | Real Runpod dry-run-to-live boundary | Prepare real Runpod job specs/client wrappers but keep live execution gated and dry-run by default | yes |
| R08 | 14, 15 | Real OpenClaw/PKM reasoning bridge | Replace dummy index/reasoner stubs with safe real artifact/PKM selection and reasoning wrappers without dumping notes | yes |
| R09 | 16, 17, 18 | Real Agentfield experiment organ | Replace dummy Agentfield POC/reasoners/hardening stubs with first-pass experiment lifecycle/controller integration | yes |
| R10 | 19, 20 | Real Paperclip adapter organ | Replace dummy adapter/review dry-run with real request/status/artifact mapping behind guarded live-write boundary | yes |
| R11 | 21, 22, 23, 24 | Real campaign orchestration organ | Replace dummy campaign core/agents/review/guarded stubs with first-pass resumable campaign execution pipeline | yes |
| R12 | all prior R batches | End-to-end real local smoke | Run full local no-live end-to-end real-organ smoke and update companion docs/trajectory index | yes |

---

## Recommended branch mapping

Use one branch per real-organ batch or per small group of closely related real-organ batches.

```text
organs/R01-contract-audit
organs/R02-real-grn-dsl-simulator
organs/R03-real-nca-local-rule
organs/R04-real-art2-artmap
organs/R05-real-mechanism-report
organs/R06-real-parameter-search
organs/R07-real-runpod-boundary
organs/R08-real-openclaw-pkm-bridge
organs/R09-real-agentfield-experiment
organs/R10-real-paperclip-adapter
organs/R11-real-campaign-orchestration
organs/R12-end-to-end-real-local-smoke
```

---

## How to ask ChatGPT to generate one real-organ batch zip

Use this prompt in a new chat after uploading the required files:

```text
I uploaded:
- the transition-to-real-organs master MD
- the skeleton-dummy master MD
- skeleton_dummy_codex_batch_plan.md
- transition_real_organs_codex_batch_plan.md
- CONFIG_TOOL.md
- the Codex template bundle files
- latest dev-recordings and companion docs if available

Create the actual transition-to-real-organs Codex batch zip from transition_real_organs_codex_batch_plan.md.
Use the transition-to-real-organs template.
Generate Batch R01 only.
Do not modify config tool files.
Each batch must contain CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md.
Stop and report if any required file is missing or unreadable.
```

For any later batch:

```text
Create the actual transition-to-real-organs Codex batch zip from transition_real_organs_codex_batch_plan.md.
Use the transition-to-real-organs template.
Generate Batch R06 only.
Read the latest dev-recordings and companion docs if available so the new batch follows the actual implementation trajectory.
Do not modify config tool files.
Each batch must contain CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md.
```

To generate all remaining real-organ batch zips after R01 is approved:

```text
Generate all remaining transition-to-real-organs Codex batch zips from R02 to R12.
Use the same structure as the approved R01.
Keep each PROJECT_CACHE.md compact and limited to that batch.
Use latest dev-recordings and companion docs for continuity when available.
Create one zip per batch and one combined index zip.
```

---

## Batch generation principles

1. **Transition master is authoritative.** Do not invent real-organ behavior outside the transition master or the approved skeleton contract.
2. **Skeleton contracts stay stable.** Public commands, file names, schemas, and smoke-test outputs should remain compatible unless the transition master explicitly changes them.
3. **Small tasks.** `RUN_INSTRUCTIONS.md` should split each real-organ batch into small tasks, each with “Implement only Task N”.
4. **Cache-aware.** `PROJECT_CACHE.md` should include only the relevant skeleton contract, transition target, current-code evidence, postcheck notes, and safety rules.
5. **No config edits.** `CONFIG_TOOL.md` may explain how to inspect roles and environments, but Codex must not patch the config tool.
6. **Real local first.** Prefer real local deterministic implementations before live remote/provider integrations.
7. **Live actions gated.** Runpod, Paperclip live writes, Agentfield live submission, OpenClaw agents, and model calls must remain dry-run or explicitly human-gated unless the selected batch says otherwise.
8. **Scientific evidence over appearance.** Do not treat final pattern similarity alone as mechanism evidence. Preserve dynamics, perturbation response, NCA agreement, ART2 prototypes, ARTMAP transitions, DSL recoverability, and falsification hooks.
9. **Postcheck required.** Every batch should end with a filled `POSTCHECK_TEMPLATE.md` or postcheck log containing changed files, tests run, skipped items, risks, and next batch notes.
10. **Integration request required.** Every batch should write `INTEGRATION_REQUEST.md` with later config/platform needs, or mark suggested integration type as `none`.
11. **Companion docs later.** The companion generator, not the implementation batch, writes the readable `COMPANION.md` after code and postcheck evidence exist.

---

## Expected output after all real-organ batches are generated

```text
codex_organs_batch_R01_contract_audit.zip
codex_organs_batch_R02_real_grn_dsl_simulator.zip
codex_organs_batch_R03_real_nca_local_rule.zip
codex_organs_batch_R04_real_art2_artmap.zip
codex_organs_batch_R05_real_mechanism_report.zip
codex_organs_batch_R06_real_parameter_search.zip
codex_organs_batch_R07_real_runpod_boundary.zip
codex_organs_batch_R08_real_openclaw_pkm_bridge.zip
codex_organs_batch_R09_real_agentfield_experiment.zip
codex_organs_batch_R10_real_paperclip_adapter.zip
codex_organs_batch_R11_real_campaign_orchestration.zip
codex_organs_batch_R12_end_to_end_real_local_smoke.zip
codex_organs_batches_index.zip
```

---

## Real-organ batch output folder guidance

Use these workspace-relative folders unless the transition master gives a stronger path:

```text
organs/R01-contract-audit
organs/R02-real-grn-dsl-simulator
organs/R03-real-nca-local-rule
organs/R04-real-art2-artmap
organs/R05-real-mechanism-report
organs/R06-real-parameter-search
organs/R07-real-runpod-boundary
organs/R08-real-openclaw-pkm-bridge
organs/R09-real-agentfield-experiment
organs/R10-real-paperclip-adapter
organs/R11-real-campaign-orchestration
organs/R12-end-to-end-real-local-smoke
```

Recommended code/output placement:

```text
Project workspace / code root:
/home/researchscientist/workspace

Codex run recordings / postcheck evidence:
/mnt/egress/organs/dev-recordings

Readable organ companion docs:
/mnt/ingress/infra/organs/companion
```

