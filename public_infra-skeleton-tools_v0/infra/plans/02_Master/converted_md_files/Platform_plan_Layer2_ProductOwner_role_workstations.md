# Layer 2 — Role workstations

**Product-owner version**

**Product goal:** turn Linux users into clear working roles with no duplicated project folders.

Layer 2 answers:

```text
Can each role log in and know where their work lives?

Does each role have the right environment and package stack?

Can research, platform engineering, PKM, and publishing happen without mixing identities, paths, and outp
```

## Product boundary

Layer 2 prepares role workstations.

It should do:

```text
prepare researchscientist for scientific work
prepare aiengineer for platform and agent engineering
prepare publisher for PKM and paper production
connect roles to shared /workspace paths
```

It should not do:

```text
not run research experiments
not train models
not build Agentfield
not build Paperclip adapter
not auto-index the vault
not auto-generate a paper
not duplicate GRN workspace folders
```

The corrected rule is:

```text
Project source lives in /workspace/repos/<project>.
Large shared data lives in /workspace/data/<project>.
Real runs live in /workspace/runs/<project>.
Reusable outputs live in /workspace/artifacts/<project>.
```

## Bundles inside Layer 2

```text
Bundle 2 — Research Scientist NCA-ART-GRN workspace
Bundle 6 — AI Engineer agent/platform dev environment
Bundle 9 — Atomic Zettelkasten / PKM writing machine
Bundle 10 — Publisher LaTeX / paper export
```

---

## Bundle 2 — Research Scientist NCA-ART-GRN workspace

**Product outcome:** `researchscientist` has one coherent home for the GRN/NCA/ART research engine.

Concretizations:

```text
install_grn_core_research_stack
install_nca_art_research_stack
install_parameter_search_comparison_stack
prepare_nca_art_workspace
prepare_experiment_output_layout
check_research_env_ready
```

Removed as duplicate:

```text
prepare_grn_workspace
```

Main repo:

```text
/workspace/repos/nca-art-grn
```

Shared outputs:

```text
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

**Product value:** keeps PDE/ODE simulator, NCA, ART, DSL, mapping, search, tests, notebooks, and scripts in one research engine repo instead of scattered GRN folders.

---

## Bundle 6 — AI Engineer agent/platform dev environment

**Product outcome:** `aiengineer` has a clean workspace for platform engineering, not science notebooks.

Concretizations:

```text
install_ai_platform_stack
install_local_model_client_stack
install_agent_dev_stack
prepare_agentfield_dev_workspace
prepare_openclaw_dev_workspace
check_ai_engineer_env_ready
```

Workspaces:

```text
/workspace/repos/agentfield
```

**Product value:** separates platform services, model clients, Agentfield controllers, adapter code, OpenClaw tooling, APIs, and smoke tests from the research repo.

---

## Bundle 9 — Atomic Zettelkasten / PKM writing machine

**Product outcome:** `publisher` and/or `researchscientist` has a structured PKM system for source-linked thinking.

Concretizations:

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

Knowledge flow:

```text
source notes
  -> atom notes
  -> molecule insight notes
  -> topic/research-question maps
```

**Product value:** makes your PKM part of the research operating system. It supports GRN research, NCA/ART ideas, Runpod notes, Agentfield architecture, Paperclip adapter design, OpenClaw reasoning, MRes writing, and future product/IP notes.

---

## Bundle 10 — Publisher LaTeX / paper export

**Product outcome:** `publisher` has a GRN/NCA/ART scientific paper project based on your existing labreport / IBA-protocol style.

Concretizations:

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

Paper output root:

```text
/workspace/artifacts/papers/grn-paper
```

Core structure:

```text
grn-paper.tex
cls/labreport.cls
styles/grn.sty
bib/grn.bib
files/grn/*.tex
fig/grn/
tables/grn/
build/
zettelkasten_bridge/
```

**Product value:** converts selected alloy notes, figures, tables, citations, and research outputs into a reproducible scientific paper build without turning Obsidian or notebooks into the manuscript engine.

## Layer 2 success condition

After Layer 2, you should be able to say:

```text
researchscientist has the NCA-ART-GRN research engine home.
aiengineer has the platform/agent engineering home.
publisher has the PKM and paper-production homes.
No GRN workspace is duplicated.
PKM organizes thinking.
LaTeX builds the paper.
Research code remains separate from publishing and platform code.
```

---

Source footer visible in PDF:

```text
23.06.26, 19:37 vmuser - Milestone Creation for Codex
https://chatgpt.com/g/g-p-6a075280f07c8191991e270b7e4a17e0/c/6a0c46d1-c268-832d-81c2-17196c756a31
```
