# Skeleton-Dummy Codex Batch Plan

**Purpose:** use this file in a new chat together with the master MD, template bundles, `CONFIG_TOOL.md`, and the skeleton/transition master files. It defines the proposed small Codex implementation batches for the first skeleton-dummy pass.

**Use case:** parallel branches. Each branch can take one batch zip generated from this plan and implement only that slice.

**Master file role:** the master MD remains the authoritative roadmap. This batch plan is only the slicing plan used to create cache-aware Codex bundles.

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

## Global rules for every generated batch

```text
Do not edit the config tool.
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh unless the batch explicitly says otherwise.
Use config only for inspection/status/explicit existing step execution.
Implement skeleton code under /workspace/repos/*.
Write outputs under /workspace/{data,runs,artifacts,models,checkpoints}.
Preserve the master MD step order.
Preserve output contracts so dummy skeleton organs can later be replaced by real organs.
```

`CONFIG_TOOL.md` should be included only when the batch needs role/config/lv context. It is read-only context.

**Posthoc config integration bridge:** each implemented skeleton batch must leave enough evidence for a later operator-side config integration batch, but it must not edit the config tool itself. The project implementation batch should create or update an integration request under:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

This file is the handoff from target-side project work to later operator/vmuser config integration. It should describe commands to expose, Python/package needs, health checks, role aliases, workflow hooks, output contracts, and whether the request should become a config bootstrap step, lv/Python env profile change, role workflow, alias, or health/status check.

---

## Proposed skeleton-dummy batch list

| Batch | Scope | Main purpose | Include `CONFIG_TOOL.md`? |
|---:|---|---|---|
| 01 | Layer 1 / Bundle 1 + 7 | Runtime roots, Runpod workspace checks, remote model dummy client | optional |
| 02 | Layer 2 / Bundle 2 | Research Scientist workspace, package stack intent, no duplicate `prepare_grn_workspace`, dummy science CLI | yes |
| 03 | Layer 2 / Bundle 6 | AI Engineer platform workspaces: Agentfield, adapter, OpenClaw dev roots | yes |
| 04 | Layer 2 / Bundle 9 | Atomic Zettelkasten / PKM skeleton and templates | yes |
| 05 | Layer 2 / Bundle 10 | Publisher LaTeX/paper export skeleton, including missing publisher install steps | yes |
| 06 | Layer 3 / Bundle 3A | NCA-ART-GRN repo base, DSL candidate schema, mechanism hypothesis schema | no |
| 07 | Layer 3 / Bundle 3B | Dummy PDE/ODE, NCA, ART2, ARTMAP, perturbation outputs | no |
| 08 | Layer 3 / Bundle 3C | Prototype store, transition graph store, prototype-to-DSL stubs, mechanism report | no |
| 09 | Layer 3 / Bundle 3D | NCA-ART local smoke configs and end-to-end dummy science smoke | no |
| 10 | Layer 3 / Bundle 4A | Search parameter space, random/grid, LHS, evolutionary, Bayesian, active-learning templates | no |
| 11 | Layer 3 / Bundle 4B | Mechanism scoring, result schema, ranking, robustness/perturbation/search reports | no |
| 12 | Layer 3 / Bundle 4C | Parameter search smoke configs and dummy local search smoke | no |
| 13 | Layer 3 / Bundle 5 | Runpod training/inference workspace, manifests, job templates, dryrun smoke only | yes |
| 14 | Layer 4 / Bundle 8A | OpenClaw workspace, PKM/artifact indexes, report ingest bridges | yes |
| 15 | Layer 4 / Bundle 8B | Reasoning profiles, model config templates, query smoke, later reasoner wrappers | yes |
| 16 | Layer 5 / Bundle 11A | Agentfield POC import, spec/status schemas, controller entrypoint | yes |
| 17 | Layer 5 / Bundle 11B | Agent registry, reasoner invoker, dummy GRN reasoners, execute fixtures, local smoke | yes |
| 18 | Layer 5 / Bundle 11C | Agentfield hardening stubs: repo split, NCA-ART bridge, artifact/status/report/runpod stubs | yes |
| 19 | Layer 5 / Bundle 12A | Paperclip-Agentfield adapter workspace, job schema, Agentfield client, request/status mappers | yes |
| 20 | Layer 5 / Bundle 12B | Artifact mapper, review actions, config profiles, fixtures, dryrun/live smoke stubs | yes |
| 21 | Layer 5 / Bundle 13A | Campaign schema, status schema, state store, stage registry | yes |
| 22 | Layer 5 / Bundle 13B | Candidate/mechanism/search/perturbation/evidence/next-experiment agents | yes |
| 23 | Layer 5 / Bundle 13C | Human review gate, artifact collector, Paperclip payload mapper, campaign smoke | yes |
| 24 | Layer 5 / Bundle 13D | First-run guarded stubs: Runpod campaign executor, async resume, retry, comparison, live submit | yes |

---

## Recommended branch mapping

Use one branch per batch or per small group of batches.

```text
skeleton/01-runtime-substrate
skeleton/02-research-workspace
skeleton/03-ai-engineer-workspaces
skeleton/04-pkm-skeleton
skeleton/05-publisher-latex
skeleton/06-nca-art-base
skeleton/07-dummy-science-organs
skeleton/08-mechanism-reporting
skeleton/09-local-smoke
skeleton/10-search-templates
skeleton/11-search-scoring
skeleton/12-search-smoke
skeleton/13-runpod-dryrun
skeleton/14-openclaw-indexes
skeleton/15-openclaw-reasoners
skeleton/16-agentfield-poc
skeleton/17-agentfield-reasoners
skeleton/18-agentfield-hardening-stubs
skeleton/19-paperclip-adapter-core
skeleton/20-paperclip-review-dryrun
skeleton/21-campaign-core
skeleton/22-campaign-agents
skeleton/23-campaign-review-smoke
skeleton/24-campaign-guarded-stubs
```

---

## How to ask ChatGPT to generate the actual zips

Use this prompt in a new chat after uploading:

```text
I uploaded:
- the master skeleton-dummy MD
- the transition-to-real-organs MD
- CONFIG_TOOL.md
- the Codex template bundles
- skeleton_dummy_codex_batch_plan.md

Create the actual skeleton-dummy Codex batch zips from skeleton_dummy_codex_batch_plan.md.
Use the skeleton-dummy template.
Start with Batch 01 only, then generate the rest after I approve the Batch 01 structure.
Do not modify config tool files.
Each batch must contain CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md.
```

To generate all batches after the first one is approved:

```text
Generate all remaining skeleton-dummy Codex batch zips from Batch 02 to Batch 24.
Use the same structure as the approved Batch 01.
Keep each PROJECT_CACHE.md compact and limited to that batch.
Create one zip per batch and one combined index zip.
```

---

## Batch generation principles

1. **Master MD is authoritative.** The batch files must not invent new step names unless explicitly marked as compatibility stubs or later placeholders.
2. **Small tasks.** `RUN_INSTRUCTIONS.md` should split each batch into small tasks, each with “Implement only Task N”.
3. **Cache-aware.** `PROJECT_CACHE.md` should include only the relevant step rows, path contracts, file contracts, and safety rules.
4. **No config edits.** `CONFIG_TOOL.md` may explain how to inspect roles and environments, but Codex must not patch the config tool.
5. **Dummy first.** Skeleton batches should produce folders, schemas, dummy CLIs, fake JSON, fake Markdown, smoke scripts, and no real expensive science or remote jobs.
6. **Transition friction reduction.** Dummy outputs should use the same filenames and schema shapes expected by the later real implementation.
7. **Integration request required.** Every implemented batch should produce `INTEGRATION_REQUEST.md` in its dev-recordings folder. This is not a config edit; it is a posthoc request for a later config-integration track to decide whether to add/update config bootstrap steps, lv/Python env profiles, role workflows, aliases, health checks, or status hooks.
8. **Postcheck required.** Every batch should end with a filled `POSTCHECK_TEMPLATE.md` or a postcheck log containing changed files, tests run, skipped items, risks, and next batch notes.

---

## Integration request handoff contract

The generated Codex batch zip still contains only the standard five instruction files. During the actual Codex implementation run, however, the batch instructions should require the run to create or update:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

The readable companion generator may later create or update:

```text
/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md
```

`INTEGRATION_REQUEST.md` should be concise and should include, when applicable:

```text
Role owner
Workspace root
Commands to expose
Python packages needed
System packages needed
Config integration needed
Suggested integration type: bootstrap step / lv profile / role alias / health check / workflow hook / status command / none
Smoke check
Output contract
Safety boundaries
Open questions for operator-side integration
```

These requests are consumed later by a dedicated config-integration track such as:

```text
config-integration/01-read-integration-requests
config-integration/02-register-workspace-roots
config-integration/03-register-python-env-profiles
config-integration/04-register-researchscientist-workflows
config-integration/05-register-ai-engineer-workflows
config-integration/06-register-publisher-and-pkm-workflows
config-integration/07-register-runpod-dryrun-hooks
config-integration/08-register-agentfield-paperclip-openclaw-hooks
config-integration/09-register-organ-transition-hooks
config-integration/10-platform-health-status-checks
```

Those config-integration batches are operator/vmuser tasks. They may modify config/lv/workflow files only after reading the completed project batch evidence and integration requests.

---

## Expected output after all batches are generated

```text
codex_skeleton_batch_01_runtime_substrate.zip
codex_skeleton_batch_02_research_workspace.zip
codex_skeleton_batch_03_ai_engineer_workspaces.zip
codex_skeleton_batch_04_pkm_skeleton.zip
codex_skeleton_batch_05_publisher_latex.zip
codex_skeleton_batch_06_nca_art_base.zip
codex_skeleton_batch_07_dummy_science_organs.zip
codex_skeleton_batch_08_mechanism_reporting.zip
codex_skeleton_batch_09_local_smoke.zip
codex_skeleton_batch_10_search_templates.zip
codex_skeleton_batch_11_search_scoring.zip
codex_skeleton_batch_12_search_smoke.zip
codex_skeleton_batch_13_runpod_dryrun.zip
codex_skeleton_batch_14_openclaw_indexes.zip
codex_skeleton_batch_15_openclaw_reasoners.zip
codex_skeleton_batch_16_agentfield_poc.zip
codex_skeleton_batch_17_agentfield_reasoners.zip
codex_skeleton_batch_18_agentfield_hardening_stubs.zip
codex_skeleton_batch_19_paperclip_adapter_core.zip
codex_skeleton_batch_20_paperclip_review_dryrun.zip
codex_skeleton_batch_21_campaign_core.zip
codex_skeleton_batch_22_campaign_agents.zip
codex_skeleton_batch_23_campaign_review_smoke.zip
codex_skeleton_batch_24_campaign_guarded_stubs.zip
codex_skeleton_batches_index.zip
```

