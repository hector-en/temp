# SPEC_Layer02_role_workstations

## Purpose

Layer 2 turns the platform from a generic runtime substrate into role-owned workstations. It is the layer where the Linux users and shared `/workspace` roots become meaningful working environments for research, platform engineering, PKM, and publishing.

This SPEC combines the Layer 2 Product Owner file, the Bundle 9 Atomic Zettelkasten / PKM file, the Bundle 10 Publisher LaTeX / paper export files, the global layer grouping, and the current skeleton batch authority files. When older Product Owner wording conflicts with `00_A1_skeleton_dummy_codex_batch_plan_v2.md` or `00_A2_skeleton_batch_mapping_report_batches_01_24.md`, this SPEC follows the A1/A2 batch authority.

Layer 2 is not a place to hide experiments, model calls, Agentfield runtime behavior, OpenClaw reasoning, or Paperclip adapter behavior. It prepares role workstations and path contracts so later layers can do that work without mixing identities, folders, outputs, or responsibilities.

## Product goal

Turn Linux users into clear working roles with no duplicated project folders.

Layer 2 answers:

```text
Can each role log in and know where their work lives?
Does each role have the right environment and package-stack intent?
Can research, platform engineering, PKM, and publishing happen without mixing identities, paths, and outputs?
```

## Product meaning

The platform is a stack, not a set of disconnected setup scripts. Layer 1 prepares safe runtime substrate contracts. Layer 2 assigns that substrate to human and automation roles:

- `researchscientist` owns the NCA-ART-GRN research engine workspace and scientific artifact roots.
- `aiengineer` owns platform engineering workspaces for Agentfield/OpenClaw-facing development, without becoming the science notebook owner.
- `publisher` owns PKM and paper-production homes, without becoming the research engine or an auto-paper generator.

Layer 2 matters because downstream batches need stable roots and role boundaries. Later science batches must be able to write predictable GRN outputs. Later PKM/OpenClaw batches must be able to reason over selected context without reorganizing the vault. Later Publisher/LaTeX work must be able to consume selected notes, figures, tables, citations, and research outputs without pulling all notebooks or Obsidian notes into the manuscript. Later Agentfield and Paperclip-adapter batches must be able to consume workspace contracts without owning workstation setup.

The key product invariant is separation of concerns:

```text
Role workstation setup != scientific execution
Role workstation setup != live model use
Role workstation setup != Agentfield runtime
Role workstation setup != Paperclip adapter implementation
Role workstation setup != automatic paper generation
```

## Layer answers

Layer 2 provides concrete answers for:

```text
Where does the research engine live?
Where do research data, runs, and artifacts live?
Where does AI/platform engineering happen?
Where does the PKM vault live?
Where does the GRN paper project live?
Which role owns each workspace?
Which later batches consume each role/path contract?
```

## Layer boundary

### Should do

```text
prepare researchscientist for scientific work
prepare aiengineer for platform and agent engineering
prepare publisher for PKM and paper production
connect roles to shared /workspace paths
create or verify role workspace roots
create package-policy/readiness intent where the batch requires it
create dummy/skeleton files, templates, schemas, fixtures, and no-overwrite contracts
write postcheck and integration-request evidence for later config integration
```

### Should not do

```text
not run research experiments
not train models
not build Agentfield runtime behavior
not build the Paperclip adapter
not call local or remote model APIs
not run OpenClaw reasoning jobs
not auto-index the vault
not print note bodies
not auto-promote notes
not auto-generate a paper
not build a PDF by default
not consume all Obsidian notes
not duplicate GRN workspace folders
not edit the config tool
not run broad bootstrap
not mount, pull, push, or read credentials unless explicitly requested
```

## Bundles in this layer

Layer 2 contains four product bundles, implemented through skeleton batches 02-05.

| Bundle | Product meaning | Skeleton batch |
| --- | --- | --- |
| Bundle 2 - Research Scientist NCA-ART-GRN workspace | One coherent home for the GRN/NCA/ART research engine. | Batch 02 `02-research-workspace` |
| Bundle 6 - AI Engineer agent/platform dev environment | Clean platform-engineering roots separate from science notebooks. | Batch 03 `03-ai-engineer-workspaces` |
| Bundle 9 - Atomic Zettelkasten / PKM writing machine | Structured source-linked thinking system for research, engineering, experiments, and publication planning. | Batch 04 `04-pkm-skeleton` |
| Bundle 10 - Publisher LaTeX / paper export | Reproducible GRN/NCA/ART scientific-paper build skeleton based on the labreport / IBA-protocol style. | Batch 05 `05-publisher-latex` |

## Key concretizations

### Batch 02 / Bundle 2 - Research Scientist workspace

Canonical current steps:

```text
install_grn_core_research_stack
install_nca_art_research_stack
install_parameter_search_comparison_stack
prepare_nca_art_workspace
prepare_experiment_output_layout
check_research_env_ready
prepare_dummy_science_cli
```

Important correction:

```text
prepare_grn_workspace is outdated / removed as duplicate.
Use prepare_nca_art_workspace and prepare_experiment_output_layout.
```

Workspace contracts:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

Product value: the PDE/ODE simulator, NCA, ART, DSL, mapping, search, tests, notebooks, scripts, and dummy CLI contract have one research-engine home instead of scattered GRN folders.

### Batch 03 / Bundle 6 - AI Engineer workspaces

Canonical current steps:

```text
install_ai_platform_stack
install_local_model_client_stack
install_agent_dev_stack
prepare_agentfield_dev_workspace
prepare_openclaw_dev_workspace
check_ai_engineer_env_ready
```

Workspace contracts:

```text
/workspace/repos/agentfield
/workspace/repos/openclaw-workspace
```

Product value: platform services, model clients, Agentfield controllers, adapter-facing code, OpenClaw tooling, APIs, and smoke/readiness checks remain separate from the research repo.

Boundary: this batch may create dev roots and package-policy markers, but it must not start Agentfield, call models, run OpenClaw jobs, or build the Paperclip adapter.

### Batch 04 / Bundle 9 - Atomic Zettelkasten / PKM skeleton

Canonical current steps:

```text
prepare_obsidian_vault_access
prepare_obsidian_vault_mount
check_obsidian_vault_access
prepare_atomic_zettelkasten_structure
prepare_source_note_templates
prepare_atom_note_templates
prepare_molecule_note_templates
prepare_topic_question_templates
prepare_alloy_publish_note_templates
prepare_latex_section_note_templates
prepare_figure_export_paths
prepare_latex_template_binding
```

A2 also lists these compatibility smoke targets:

```text
prepare_paper_note_structure
prepare_literature_note_structure
```

Use the Zettelkasten-specific steps above as the preferred implementation direction. If older generic paper/literature-note names appear in smoke or legacy evidence, treat them as compatibility aliases/stubs only. Do not let them replace the atomic Zettelkasten structure.

Recommended vault root:

```text
/workspace/pkm/zettelkasten
```

Recommended structure:

```text
/workspace/pkm/zettelkasten/
  00_inbox/
  10_reference_manager_kasten/
  20_knowledge_kasten/
  30_publish_kasten/
  40_experiments/
  50_figures/
  60_templates/
  70_bridge/
  90_archive/
```

Knowledge flow:

```text
Research sources
  -> source notes
  -> atomic concept notes
  -> molecule insight notes
  -> research-question/topic maps
  -> alloy publishable notes
  -> later LaTeX section drafts
```

Product value: PKM becomes part of the research operating system for GRN/NCA/ART research, RunPod planning, Agentfield/Paperclip architecture, OpenClaw reasoning, MRes writing, and future product/IP notes.

Boundary: Bundle 9 organizes knowledge; it does not build the paper, index the whole vault, print note contents, write OpenClaw reasoning outputs into the vault, or auto-promote notes.

### Batch 05 / Bundle 10 - Publisher LaTeX / paper export

Canonical current steps:

```text
install_publisher_latex_stack
install_publisher_notebook_export_stack
prepare_scientific_report_template
prepare_grn_paper_latex_project
prepare_labreport_class_assets
prepare_article_style_profile
prepare_latex_section_files
prepare_bibliography_pipeline
prepare_zettelkasten_to_manuscript_bridge
prepare_notebook_to_latex_export
prepare_manuscript_export_pipeline
prepare_final_draft_build
check_latex_build_tools
check_publisher_env_ready
```

Important correction:

```text
prepare_paper_template_workspace is too generic.
Use prepare_grn_paper_latex_project.
```

Paper output root:

```text
/workspace/artifacts/papers/grn-paper
```

Core structure:

```text
/workspace/artifacts/papers/grn-paper/
  grn-paper.tex
  README.md
  cls/labreport.cls
  styles/grn.sty
  styles/name.tex
  bib/grn.bib
  bib/labreport.bst
  files/grn/*.tex
  fig/grn/
  tables/grn/
  build/
  zettelkasten_bridge/
  exports/
```

The main paper should preserve the labreport / IBA-protocol style direction:

```latex
\documentclass[11pt]{cls/labreport}
\usepackage{epstopdf}
\usepackage{multicol}
\usepackage[backend=biber,style=apa]{biblatex}
\addbibresource{bib/grn.bib}
\articletype{grn}
\runningtitle{5-node GRN discovery}
\runningauthor{Hector Edu Nseng}
```

It should input modular GRN section files such as:

```text
abstract
introduction
background
methods
simulator
nca_art_pipeline
parameter_search
results
discussion
conclusion
acknowledgments
data_availability
definitions
```

Product value: Bundle 10 converts selected alloy notes, figures, tables, citations, and research outputs into a reproducible scientific paper build without turning Obsidian or notebooks into the manuscript engine.

Boundary: Bundle 10 formats and builds the paper only when explicitly requested. It must not run simulations, call models, consume the entire vault, overwrite manuscript text, or build a PDF by default.

## Batch -> layer implementation map

Batch 01 implements Layer 1 runtime substrate contracts that Layer 2 consumes: generic `/workspace` roots, runtime readiness checks, and safe command/status posture. Layer 2 should not recreate those runtime roots as a separate system; it should place role-owned workspaces into the Layer 1 substrate.

Batch 02 consumes Layer 1 `/workspace` and runtime-readiness contracts while implementing the Layer 2 Research Scientist workspace. It creates or verifies `/workspace/repos/nca-art-grn`, `/workspace/data/nca-art-grn`, `/workspace/runs/nca-art-grn`, `/workspace/artifacts/nca-art-grn`, package-policy intent, dummy CLI/readiness contracts, and evidence files. It must not run real experiments or train models.

Batch 03 consumes Layer 1 runtime contracts while implementing the Layer 2 AI Engineer platform/dev workspace. It creates or verifies `/workspace/repos/agentfield` and `/workspace/repos/openclaw-workspace`, package-policy markers, and AI Engineer readiness reporting. It must not start Agentfield, call model providers, run OpenClaw jobs, or build the Paperclip adapter.

Batch 04 consumes Layer 1 path and safety contracts while implementing the Layer 2 PKM skeleton. It creates `/workspace/pkm/zettelkasten`, atomic Zettelkasten folders, templates, figure bridges, and LaTeX binding metadata. It must not print note bodies, index the whole vault, rewrite notes, or auto-promote notes.

Batch 05 consumes Layer 1 path contracts and Batch 04 PKM binding contracts while implementing the Layer 2 Publisher LaTeX workspace. It creates `/workspace/artifacts/papers/grn-paper`, the labreport/GRN paper skeleton, bibliography and section structures, build wrappers, and manuscript bridge metadata. It must not build the PDF by default, overwrite manuscript text, run simulations, call models, or consume all Obsidian notes.

Batch 06 and later consume Layer 2 contracts. Science batches consume the NCA-ART-GRN repo and artifact roots. Layer 4 consumes PKM/OpenClaw workspace contracts. Layer 5 consumes Agentfield/Paperclip/campaign workspace contracts. None of those later batches should move or duplicate Layer 2 roots.

## 24-batch visual map

- ~~[ ] 01-runtime-substrate~~ - Layer 1 runtime substrate; consumed by Layer 2
- **[x] 02-research-workspace** - active Layer 2 / Bundle 2
- **[x] 03-ai-engineer-workspaces** - active Layer 2 / Bundle 6
- **[x] 04-pkm-skeleton** - active Layer 2 / Bundle 9
- **[x] 05-publisher-latex** - active Layer 2 / Bundle 10
- ~~[ ] 06-nca-art-base~~ - later Layer 3; consumes Batch 02 roots
- ~~[ ] 07-dummy-science-organs~~ - later Layer 3; consumes Batch 02 roots
- ~~[ ] 08-mechanism-reporting~~ - later Layer 3; consumes Batch 02 roots
- ~~[ ] 09-local-smoke~~ - later Layer 3; consumes Batch 02 roots
- ~~[ ] 10-search-templates~~ - later Layer 3; consumes Batch 02 roots
- ~~[ ] 11-search-scoring~~ - later Layer 3; consumes Batch 02 roots
- ~~[ ] 12-search-smoke~~ - later Layer 3; consumes Batch 02 roots
- ~~[ ] 13-runpod-dryrun~~ - later Layer 3; consumes runtime and research roots
- ~~[ ] 14-openclaw-indexes~~ - later Layer 4; consumes PKM and OpenClaw roots
- ~~[ ] 15-openclaw-reasoners~~ - later Layer 4; consumes PKM/OpenClaw roots
- ~~[ ] 16-agentfield-poc~~ - later Layer 5; consumes Agentfield root
- ~~[ ] 17-agentfield-reasoners~~ - later Layer 5; consumes Agentfield root
- ~~[ ] 18-agentfield-hardening-stubs~~ - later Layer 5; consumes Agentfield and NCA-ART roots
- ~~[ ] 19-paperclip-adapter-core~~ - later Layer 5; consumes AI Engineer roots
- ~~[ ] 20-paperclip-review-dryrun~~ - later Layer 5; consumes adapter roots
- ~~[ ] 21-campaign-core~~ - later Layer 5; consumes Agentfield/platform roots
- ~~[ ] 22-campaign-agents~~ - later Layer 5; consumes Agentfield/platform roots
- ~~[ ] 23-campaign-review-smoke~~ - later Layer 5; consumes campaign and adapter contracts
- ~~[ ] 24-campaign-guarded-stubs~~ - later Layer 5; consumes campaign, RunPod, and adapter contracts

## Smoke / validation mapping

Smoke modules are domain-owned. Do not create one smoke module per batch by default. Smoke proves file/contract/readiness shape, not scientific truth, live orchestration, or live infrastructure.

| Batch | Smoke modules | Smoke verifies | Must not do |
| --- | --- | --- | --- |
| 02 `02-research-workspace` | `20-python-package.smoke.sh`, `70-grn-contract.smoke.sh`, `30-skeleton-evidence.smoke.sh` | `/workspace/repos/nca-art-grn`, `/workspace/data/nca-art-grn`, `/workspace/runs/nca-art-grn`, `/workspace/artifacts/nca-art-grn`, package-policy files, dummy CLI, dummy artifact filenames | run research experiments, train models, build Agentfield, build Paperclip |
| 03 `03-ai-engineer-workspaces` | `20-python-package.smoke.sh`, future `85-agentfield.smoke.sh`, future `80-openclaw-pkm.smoke.sh`, `30-skeleton-evidence.smoke.sh` | `/workspace/repos/agentfield`, `/workspace/repos/openclaw-workspace`, package-policy markers, AI Engineer readiness report | start Agentfield, call models, run OpenClaw jobs, build Paperclip adapter |
| 04 `04-pkm-skeleton` | future `80-openclaw-pkm.smoke.sh`, possibly future `81-zettelkasten.smoke.sh` if split | `/workspace/pkm/zettelkasten`, expected folders, templates, bridge paths, no-overwrite sentinel | print note bodies, index whole vault, rewrite notes, auto-promote notes |
| 05 `05-publisher-latex` | future `82-publisher-latex.smoke.sh` | `/workspace/artifacts/papers/grn-paper`, `grn-paper.tex`, `cls/`, `styles/`, `bib/`, `files/grn/`, `fig/grn/`, `tables/grn/`, `build/`, `zettelkasten_bridge/` | install TeX unless explicit, build PDF by default, overwrite manuscript text, consume all Obsidian notes, run simulations, call models |


## Operational workflow integration

Layer 2 batch work must follow the current skeleton day-to-day loop, not an ad-hoc implementation flow. The minimum operating rule is:

```text
1. Generate one Codex-ready skeleton batch package.
2. Stage it.
3. Run Codex implementation from the named batch files only.
4. Write POSTCHECK.md and INTEGRATION_REQUEST.md.
5. Run the active dynamic smoke runner.
6. Review SMOKE_REPORT.md.
7. Continue only on PASS, SKIP, or accepted documented WARN.
8. Update companion only at logical checkpoints or contract changes.
```

Layer 2 spans the `AI/PKM/Publisher setup` logical group for Batches 03-05, and has a separate `Research workspace` logical group for Batch 02. Companion updates are recommended after Batch 02 when the `nca-art-grn` workspace/data/runs/artifacts contract changes, and again after Batches 03-05 when AI Engineer roots, PKM skeleton/templates, or publisher/LaTeX structure changes.

### Evidence contract after every Layer 2 batch

Each implemented Layer 2 batch must leave:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
```

Do not start the next Layer 2 batch until the current batch has these evidence files and its smoke result is PASS, SKIP, or an accepted documented WARN. Stop on FAIL, BLOCKED, missing POSTCHECK, missing INTEGRATION_REQUEST, missing smoke runner, or unexpected WARN.

### Active smoke runner rule

There is one conceptual dynamic smoke orchestrator. The final intended command is:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

If the current workspace still uses `/workspace/scripts/smoke.sh` as the active implemented runner, keep using it until a dedicated runner migration is performed:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke.sh skeleton-progress
```

Do not silently switch runners in the middle of a batch. The final intended state is `/workspace/scripts/smoke_current_state.sh` as the canonical runner and `/workspace/scripts/smoke.sh` as a compatibility wrapper.

### Per-batch smoke commands

```bash
# Batch 02
BATCH_SLUG="02-research-workspace" bash /workspace/scripts/smoke.sh skeleton-progress
# or, after migration:
BATCH_SLUG="02-research-workspace" bash /workspace/scripts/smoke_current_state.sh skeleton-progress

# Batch 03
BATCH_SLUG="03-ai-engineer-workspaces" bash /workspace/scripts/smoke.sh skeleton-progress
# or, after migration:
BATCH_SLUG="03-ai-engineer-workspaces" bash /workspace/scripts/smoke_current_state.sh skeleton-progress

# Batch 04
BATCH_SLUG="04-pkm-skeleton" bash /workspace/scripts/smoke.sh skeleton-progress
# or, after migration:
BATCH_SLUG="04-pkm-skeleton" bash /workspace/scripts/smoke_current_state.sh skeleton-progress

# Batch 05
BATCH_SLUG="05-publisher-latex" bash /workspace/scripts/smoke.sh skeleton-progress
# or, after migration:
BATCH_SLUG="05-publisher-latex" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

### Smoke layers that Layer 2 must preserve

Do not merge the smoke protocol, runner, global modules, and local routines. Their boundaries are:

| Smoke layer | Canonical path | Layer 2 relevance |
| --- | --- | --- |
| Protocol | `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` | Update only if smoke architecture, phases, report contract, or status meanings change. |
| Runner/orchestrator | `/workspace/scripts/smoke_current_state.sh` or current active `/workspace/scripts/smoke.sh` | Discovers global modules and writes `SMOKE_REPORT.md`; do not put Layer 2 domain logic here. |
| Global smoke modules | `/workspace/tests/smoke.d/*.smoke.sh` | Domain-owned checks for Python/package, GRN contracts, skeleton evidence, PKM/OpenClaw, publisher/LaTeX, Agentfield readiness. |
| Local smoke routines | Project-local `*.smoke.sh`, `smoke_test.py`, or tiny safe CLIs | Validate one local package, CLI, fixture, schema, or dry-run path created by a batch. |

### Global smoke.d versus local smoke routines for Layer 2

Do not create one global smoke module per batch. Create or update the smallest domain-owned global module only when a public domain contract changes or a new domain surface becomes current-state smokeable. Create local routines when the batch introduces a specific local command, fixture, validator, schema, or dry-run path.

| Layer 2 batch | Local routine trigger | Global module trigger |
| --- | --- | --- |
| Batch 02 `02-research-workspace` | Create a local `nca-art-grn` smoke routine only when the dummy science CLI, local package fixture, schema validator, or workspace readiness check is actually implemented. | Update `20-python-package`, `70-grn-contract`, or `30-skeleton-evidence` only if implemented paths, CLI names, dummy artifact filenames, package-policy markers, or evidence rules change. |
| Batch 03 `03-ai-engineer-workspaces` | Local workspace-readiness check may be useful if Agentfield/OpenClaw roots get a project-local check. | Do not create Agentfield/OpenClaw global modules just for empty roots unless their domain surface becomes meaningful; use future `85-agentfield` and `80-openclaw-pkm` only when contracts exist. |
| Batch 04 `04-pkm-skeleton` | Local template/no-overwrite smoke may be useful for vault folders and templates. | Future `80-openclaw-pkm` or possible `81-zettelkasten` only when the PKM structure becomes a current-state domain contract. |
| Batch 05 `05-publisher-latex` | Local TeX structure/no-build smoke may be useful for the paper skeleton. | Future `82-publisher-latex` when the paper structure is required by current-state smoke. |

Planning documents alone usually do not trigger smoke code changes. Implemented contract changes do. If a smoke failure is caused by a module expecting outdated paths or filenames, update the smallest matching module. If a failure is caused by missing evidence, missing mount, or permission issue, do not rewrite smoke modules just to silence it.

### Safe smoke behavior

Layer 2 smoke may check paths, syntax, importability, template existence, no-overwrite sentinels, dummy CLI help or tiny fixtures, and evidence files. It must not install packages, edit config, mount shares, print note contents, index the whole vault, build the PDF by default, launch RunPod, run Docker containers, mutate Kubernetes/Terraform, call model/provider APIs, start Agentfield, call Paperclip, or write live state.

### Smoke update decision for future Codex prompts

When preparing a Layer 2 smoke update package for Codex, classify the change as exactly one of:

```text
1. no smoke update
2. local *.smoke.sh routine only
3. global smoke.d module only
4. both local routine and global module
5. runner/protocol update
```

Codex smoke-update prompts must name only the exact module(s), local routine(s), files to read, validation commands, active runner command, and forbidden actions. Do not make Codex read the full workflow files, unrelated batch plans, old smoke reports, or unrelated source trees for a run-only smoke step.

## Output and path contracts

### Global Layer 2 path rule

```text
Project source lives in /workspace/repos/<project>.
Large shared data lives in /workspace/data/<project>.
Real runs live in /workspace/runs/<project>.
Reusable outputs live in /workspace/artifacts/<project>.
```

### Research Scientist outputs

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

Expected skeleton/dummy continuity contracts include stable names for later science outputs, including:

```text
metadata.json
candidate.dsl.json
pattern_dynamics.json
nca_summary.json
art2_prototypes.json
artmap_transitions.json
perturbation_summary.json
mechanism_report.md
search_report.md
candidate_rankings.json
paperclip_review_payload.json
```

### AI Engineer outputs

```text
/workspace/repos/agentfield
/workspace/repos/openclaw-workspace
```

Optional later consumers may also use:

```text
/workspace/repos/paperclip-agentfield-adapter
/workspace/repos/research-assistant
/workspace/runs/agentfield
/workspace/repos/openclaw-workspace/runs
```

Do not create or own later adapter/runtime behavior unless the active batch explicitly says so.

### PKM outputs

```text
/workspace/pkm/zettelkasten
/workspace/pkm/zettelkasten/60_templates/*.md
/workspace/pkm/zettelkasten/70_bridge/latex/grn-paper-binding.yaml
```

Templates should be created only if missing and must not overwrite user note bodies.

### Publisher outputs

```text
/workspace/artifacts/papers/grn-paper/grn-paper.tex
/workspace/artifacts/papers/grn-paper/cls/labreport.cls
/workspace/artifacts/papers/grn-paper/styles/grn.sty
/workspace/artifacts/papers/grn-paper/bib/grn.bib
/workspace/artifacts/papers/grn-paper/files/grn/*.tex
/workspace/artifacts/papers/grn-paper/fig/grn/
/workspace/artifacts/papers/grn-paper/tables/grn/
/workspace/artifacts/papers/grn-paper/build/
/workspace/artifacts/papers/grn-paper/zettelkasten_bridge/
```

Section files, YAML bridge files, build wrappers, and class/style assets should be non-destructive by default.

### Recording outputs for implemented batches

Each implemented Layer 2 skeleton batch should write evidence under:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

`INTEGRATION_REQUEST.md` is a handoff to a later config-integration track. It is not permission to edit config tool internals in the current batch.

## Relationship to earlier layers

Layer 2 consumes Layer 1 runtime substrate. It assumes Layer 1 owns generic runtime roots, safe runtime checks, remote-model dummy-client boundary, and no-live-infra defaults.

Layer 2 must not move runtime substrate logic into role workstations. It should use Layer 1 contracts to create role-specific work homes. Runtime readiness belongs below Layer 2; research, platform engineering, PKM, and publishing identity belongs in Layer 2.

## Relationship to later layers

Layer 3 consumes the Research Scientist workspace for NCA-ART-GRN schemas, dummy science organs, mechanism reports, local smoke, search templates/scoring/smoke, and RunPod dry-runs.

Layer 4 consumes the PKM/OpenClaw workspaces for selected context indexes, report ingests, reasoning profiles, and safe query smoke. It must not reorganize or overwrite the Zettelkasten.

Layer 5 consumes AI Engineer workspaces and research artifacts for Agentfield POC, reasoners, hardening stubs, Paperclip adapter mapping, review dry-runs, and campaign orchestration. It must not reinterpret Layer 2 as a live controller layer.

## Annex index

Suggested Layer 2 annex split for batch-specific Codex generation:

```text
SPEC_Layer02_02-research-workspace-ANX01_nca_art_grn_workspace.md
SPEC_Layer02_03-ai-engineer-workspaces-ANX01_platform_dev_roots.md
SPEC_Layer02_04-pkm-skeleton-ANX01_atomic_zettelkasten_templates.md
SPEC_Layer02_05-publisher-latex-ANX01_grn_paper_latex_project.md
```

This combined main SPEC contains enough detail to seed those annexes later, but it is intentionally layer-level. Codex batch packages should read the relevant annex when available and should not paste the entire layer SPEC into batch-local cache files.

## Acceptance / success condition

After Layer 2, the following should be true:

```text
researchscientist has the NCA-ART-GRN research engine home.
aiengineer has the platform/agent engineering home.
publisher has the PKM and paper-production homes.
No GRN workspace is duplicated.
PKM organizes thinking without indexing or rewriting the vault.
LaTeX paper skeleton exists without auto-generating the manuscript.
Research code remains separate from publishing and platform code.
Each Layer 2 skeleton batch leaves POSTCHECK.md and INTEGRATION_REQUEST.md evidence.
Later layers can consume stable paths and contracts without moving role-owned roots.
```

Batch-level acceptance highlights:

```text
Batch 02: nca-art-grn repo/data/runs/artifacts roots exist; dummy science CLI and expected dummy artifact filename contracts are present.
Batch 03: agentfield and openclaw-workspace roots exist; AI Engineer readiness markers exist; no live model or Agentfield run occurs.
Batch 04: zettelkasten vault folders/templates/bridges exist; no note contents are printed or overwritten.
Batch 05: grn-paper LaTeX skeleton exists; no PDF build or manuscript overwrite occurs by default.
```

## Developer notes

### Source priority used in this file

1. `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md` are treated as the current batch slicing and smoke-mapping authority.
2. `final_workflow.md`, `smoke_module_update_workflow.md`, and `day_to_day_skeleton_run.md` are treated as the current operational workflow authority for evidence, dynamic smoke, global/local smoke boundaries, companion timing, and stop/continue rules.
3. Layer 2 Product Owner and Bundle 9/10 files are treated as product semantics and implementation detail sources.
4. Outdated Product Owner or older generic names are corrected where A1/A2, the workflow files, or the bundle-specific files give newer names.

### Config tool boundary

Do not modify the config tool.

```text
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh.
Use config only for inspection/status or explicitly named existing bootstrap steps in an active SPEC.
Implement project skeleton code under /workspace/repos/* and outputs under /workspace/*.
```

### Layer 2 implementation style

Layer 2 skeleton work should create deterministic, small, inspectable placeholder structures. It may create directories, skeleton packages, schema fixtures, template Markdown files, YAML bridge files, dummy CLIs, and smoke tests. It should preserve file names and schema fields so dummy skeleton organs can later become real organs without breaking Agentfield, OpenClaw, Paperclip, or Publisher consumers.

Do not hide OS package installation inside innocent-looking prepare steps. Install/check steps must remain explicit and separate.

Do not run broad bootstrap, Docker builds, containers, RunPod jobs, Kubernetes/Terraform mutations, OpenClaw agents, model/provider APIs, live Paperclip/Agentfield submissions, or credential access by default.

### Known missing context not required for this combined Layer 2 file

The full skeleton master companion (`00_A0_skeleton_dummy_master_implementation_companion.md`) was not included in the current upload set. This file therefore uses the uploaded Layer 2 sources plus A1/A2 as the strongest available implementation authority for Layer 2. If A0 later contradicts any step-level detail, update this SPEC to match A0 unless A1/A2 have been explicitly updated to supersede it.
