# SPEC_Layer02_05-publisher-latex-ANX03_mres_latex_architecture

Status: created from uploaded MRes Word template and uploaded LaTeX IBA/labreport code-analysis output.  
Parent layer spec: `SPEC_Layer02_role_workstations.md`.  
Primary batch placement: **Batch 05 / `05-publisher-latex`**.  
Annex purpose: `MRes thesis LaTeX architecture and IBA/labreport template adaptation`.  
Batch slicing authority: `00_A1_skeleton_dummy_codex_batch_plan_v2.md` and `00_A2_skeleton_batch_mapping_report_batches_01_24.md`.  
Operational authority: `final_workflow.md`, `smoke_module_update_workflow.md`, `day_to_day_skeleton_run.md`, and `day_to_day_organs_run.md` where relevant.

## Why this annex exists

This annex exists because the uploaded MRes thesis specification lives in a Word `.docx` template, while the active publishing skeleton is based on an existing LaTeX `labreport` / IBA-style project. The two are close enough to reuse the IBA asset structure, but not close enough to copy the existing `IBA-protocol.tex` unchanged.

The current IBA template is a short coursework/lab-report article skeleton using `cls/labreport`, `styles/iba`, `files/iba/*.tex`, a two-column `multicols` article body, and example sections such as Introduction, Risk Assessment, Materials and Methods, Results, Discussion, Conclusion, and Acknowledgments. The MRes thesis template instead requires a postgraduate thesis/report layout with title page, contents, abbreviations, abstract, ordered thesis sections, Nature-style references, 1.5 line spacing, 2.5 cm margins, 11 pt minimum Arial/Helvetica-compatible font, page numbers, and a 50-page limit including figures and references.

The product decision is therefore:

```text
Preserve the labreport / IBA modular LaTeX architecture and assets,
but adapt it into a single-column MRes thesis/report architecture.
```

This annex is implementation-significant for Batch 05 because Batch 05 creates the Publisher LaTeX project. It also affects Batch 04 templates and later OpenClaw/PKM reasoning outputs only when those outputs need to target manuscript sections.

## Quick adaptation walkthrough

The adaptation should be done in this order:

1. Keep `cls/labreport.cls` as the starting document class only if it can be safely overridden to meet the MRes layout requirements.
2. Create a thesis-specific style profile, preferably `styles/grn_mres.sty`, rather than editing `styles/iba.sty` directly.
3. Keep the skeleton contract filename `grn-paper.tex`, but make it the MRes thesis main file or a wrapper around `grn-mres-thesis.tex`.
4. Remove the IBA default two-column body for thesis mode. Do not wrap the thesis body in `\begin{multicols}{2}`.
5. Use one modular file per thesis section under `files/grn/`.
6. Add a dedicated abbreviations file and table-of-contents/list-of-abbreviations front matter.
7. Use Nature-style superscript numbered references, with either a vetted BibTeX/Natbib route or a vetted BibLaTeX/Biber route, but not a conflicting mixture.
8. Keep PDF build explicit and human-requested during skeleton generation.
9. Add smoke checks for file structure, syntax, bibliography files, figure/table directories, and no-overwrite behavior.

## Proposed final LaTeX architecture for this MRes

Recommended project root:

```text
/workspace/artifacts/papers/grn-paper/
```

Recommended tree:

```text
/workspace/artifacts/papers/grn-paper/
  grn-paper.tex                       # skeleton contract; MRes main or wrapper
  grn-mres-thesis.tex                  # optional explicit thesis main, if wrapper pattern is used
  cls/
    labreport.cls                      # copied/preserved upstream class asset
  styles/
    grn_mres.sty                       # thesis style profile derived from IBA/labreport needs
    iba.sty                            # optional preserved original, not edited in place unless scoped
  bib/
    grn.bib                           # thesis bibliography
    nature.csl or nature.bst          # optional, depending on chosen citation pipeline
  files/grn/
    titlepage.tex
    abbreviations.tex
    abstract.tex
    introduction.tex
    results.tex
    discussion_conclusion.tex
    methods_materials.tex
    appendices.tex                    # optional; beyond marked page limit
  fig/grn/
    README.md
  tables/grn/
    README.md
  build/
    build_lualatex.sh
    build_pdflatex.sh
    lint_latex_structure.sh
  zettelkasten_bridge/
    grn-paper-binding.yaml
    section_targets.yaml
    selected_sources_manifest.yaml
```

Recommended main-file skeleton:

```latex
\documentclass[11pt]{cls/labreport}
\articletype{grn_mres}

% MRes thesis layout overrides: single column, 1.5 spacing, >=2.5 cm margins,
% Helvetica/Arial-compatible sans-serif text, page numbering, thesis front matter.
% Bibliography must be Nature-style superscript numbered citations.

\title{<MRes thesis title>}
\author[1]{<student name or CID>}
\affil[1]{Systems & Synthetic Biology MRes}
\runningtitle{<short MRes title>}
\runningauthor{<student name or CID>}

\begin{document}
\inputfile{titlepage}
\tableofcontents
\inputfile{abbreviations}
\inputfile{abstract}
\inputfile{introduction}
\inputfile{results}
\inputfile{discussion_conclusion}
\inputfile{methods_materials}
\printbibliography % or \bibliography{bib/grn}, depending on the chosen citation route
\inputfile{appendices}
\end{document}
```

Recommended section order from the MRes template:

```text
Table of Contents
List of Abbreviations
Abstract
Introduction
  Background
  Aims
Results
  Experimental Strategy
  Results
Discussion / Conclusion
  Discussion
  Conclusion
  Future work
Materials and Methods
  Reproducible experimental/computational details only
  Do not include experimental strategy here
Bibliography
Appendices / supplementary code and data only if needed, beyond the marked page limit
```

Recommended thesis layout rules:

```text
11 pt minimum Arial/Helvetica-compatible font
1.5 line spacing
2.5 cm margins all round
page numbers enabled
single-column thesis body
figures with proper captions, legends, axis labels, and physical units
quantities written with non-breaking spaces before units where practical
Nature-style superscript numbered references
citation numbers before full stops where required by the MRes template
```

## Most relevant implementation batch

```text
Primary batch: 05-publisher-latex
Primary layer: Layer 2 — Role workstations
Primary bundle: Bundle 10 — Publisher LaTeX / paper export
Primary role: publisher
Supporting roles: researchscientist for outputs; aiengineer only for later bridges/reasoners
Primary smoke domain: future 82-publisher-latex.smoke.sh
```

Batch 05 is the correct primary placement because it owns:

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

## Related layer and bundle

This annex belongs to:

```text
Layer 2 — Role workstations
Bundle 10 — Publisher LaTeX / paper export
Batch 05 — 05-publisher-latex
```

It references:

```text
Layer 2 / Batch 04 — PKM templates may need section-target names.
Layer 3 / Batches 06-13 — research outputs, figures, tables, run reports, and mechanism reports feed the manuscript later.
Layer 4 / Batches 14-15 — OpenClaw/PKM reasoning may prepare selected section-aware suggestions.
Layer 5 — Agentfield/Paperclip may later show manuscript/report artifact status, but does not own the manuscript.
```

## Background source notes

### `project_template_example_2025.docx`

Extracted implementation-significant rules:

```text
MRes report title page with student, supervisors, programme, and date.
Contents and list of abbreviations before abstract.
Abstract around 200 words, usually one paragraph.
Required thesis section order: Abstract; Introduction with Background and Aims; Results with Experimental Strategy and Results; Discussion/Conclusion with Discussion, Conclusion, Future work; Materials and Methods; Bibliography.
Methods must contain reproducible details and must not contain experimental strategy.
References must be Nature format with superscript numbered citations.
Page limit is 50 word-processed pages including figures and references.
Formatting: Arial/Helvetica, 11 point minimum, 1.5 line spacing, minimum 2.5 cm margins all round.
Figures require proper captions, legends, axis labels, and physical units.
Appendices may exist beyond the page limit but are not marked.
```

### `latex_20260623175434_code_analysis_output.txt`

Extracted implementation-significant rules:

```text
Existing LaTeX project has `IBA-protocol.tex` using `\documentclass[11pt]{cls/labreport}`.
Existing IBA style is activated through `\articletype{iba}`.
The template imports content through `\inputfile{...}`, resolved by `styles/iba.sty` to `files/iba/<name>.tex`.
The current IBA body uses `\begin{multicols}{2}`, which should not be used for the MRes thesis body.
Existing files include `cls/labreport.cls`, `styles/iba.sty`, `bib/iba.bib`, `files/iba/abstract.tex`, `files/iba/introduction.tex`, `files/iba/materials.tex`, `files/iba/results.tex`, `files/iba/definitions.tex`, and `files/iba/riskassesment.tex`.
Existing README describes the project as a modular scientific report template with class, styles, figures, files, install scripts, and build scripts.
```

### Current platform authority files

Extracted implementation-significant rules:

```text
Batch 05 is the Publisher LaTeX/paper export skeleton.
Batch 05 must preserve a labreport/IBA-style modular architecture.
The publisher project root is `/workspace/artifacts/papers/grn-paper`.
Expected contract paths include `grn-paper.tex`, `cls/`, `styles/`, `bib/`, `files/grn/`, `fig/grn/`, `tables/grn/`, `build/`, and `zettelkasten_bridge/`.
Batch 05 must not build the PDF by default, overwrite manuscript text, consume all Obsidian notes, run simulations, or call models.
Future publisher smoke domain is `82-publisher-latex.smoke.sh`.
```

## What this extends in the main layer SPEC

This annex extends `SPEC_Layer02_role_workstations.md` by adding MRes-specific detail to the existing Bundle 10 publisher contract.

The main Layer 2 SPEC should stay layer-level. This annex keeps the lower-level details:

```text
how to adapt the uploaded MRes Word template into LaTeX
how to preserve the existing IBA/labreport template assets
which section files should exist
which formatting and reference constraints must be represented
which publisher smoke checks should exist
which no-overwrite/no-build guardrails matter
```

## Batch -> implementation relevance

### Batch 04 / `04-pkm-skeleton`

Batch 04 may consume this annex only when creating LaTeX section-note templates or bridge YAML files. It should use the section target names:

```text
abstract
introduction
results
discussion_conclusion
methods_materials
bibliography
appendices
```

Batch 04 must not build or write the manuscript.

### Batch 05 / `05-publisher-latex`

Batch 05 owns this annex. It should use the annex to create:

```text
/workspace/artifacts/papers/grn-paper/grn-paper.tex
/workspace/artifacts/papers/grn-paper/styles/grn_mres.sty
/workspace/artifacts/papers/grn-paper/files/grn/titlepage.tex
/workspace/artifacts/papers/grn-paper/files/grn/abbreviations.tex
/workspace/artifacts/papers/grn-paper/files/grn/abstract.tex
/workspace/artifacts/papers/grn-paper/files/grn/introduction.tex
/workspace/artifacts/papers/grn-paper/files/grn/results.tex
/workspace/artifacts/papers/grn-paper/files/grn/discussion_conclusion.tex
/workspace/artifacts/papers/grn-paper/files/grn/methods_materials.tex
/workspace/artifacts/papers/grn-paper/files/grn/appendices.tex
/workspace/artifacts/papers/grn-paper/bib/grn.bib
/workspace/artifacts/papers/grn-paper/zettelkasten_bridge/section_targets.yaml
```

Batch 05 should make placeholders safe and human-readable. It should not generate thesis prose beyond skeleton placeholders.

### Batch 14 / `14-openclaw-indexes`

Batch 14 may use the section target manifest as selected context metadata only. It must not index the whole vault or print note bodies.

### Batch 15 / `15-openclaw-reasoners`

Batch 15 may use section targets in mocked/local reasoner profiles. It must not call paid/live models by default and must not write into the real manuscript by default.

## Concrete steps affected

### `prepare_scientific_report_template`

Create or preserve the generic scientific-report template contract, but include MRes-specific notes:

```text
single-column report body
front matter support
abbreviations support
MRes section order
Nature references direction
page/layout requirements documented in comments or README
```

### `prepare_grn_paper_latex_project`

Create `/workspace/artifacts/papers/grn-paper` as the GRN/NCA/ART MRes report project, not a generic paper workspace. Preserve the expected contract name `grn-paper.tex` even if an explicit `grn-mres-thesis.tex` is also present.

### `prepare_labreport_class_assets`

Copy or preserve `cls/labreport.cls` and related class assets. Do not edit upstream class internals unless the batch explicitly scopes a safe patch. Prefer thesis overrides in `styles/grn_mres.sty`.

### `prepare_article_style_profile`

Create `styles/grn_mres.sty` or equivalent. It should:

```text
load content from `files/grn/*.tex`
set article/thesis type string for headers if used
provide `\inputfile{...}` for `files/grn/<name>.tex`
provide `\fullref` / label helpers if still needed
support single-column thesis flow
support page numbering
support 1.5 spacing and 2.5 cm margin intent
avoid forcing IBA-specific two-column coursework layout
```

### `prepare_latex_section_files`

Create the MRes section files listed above with placeholders and comments explaining expected content. Do not generate substantive thesis claims.

### `prepare_bibliography_pipeline`

Create a Nature-style bibliography direction. The implementation must choose one non-conflicting route:

```text
BibLaTeX/Biber route: `backend=biber, style=nature, sorting=none` if compatible with the class after testing.
Natbib/BibTeX route: numeric superscript citations and a suitable Nature-like `.bst` if available.
```

Do not mix incompatible Natbib and BibLaTeX settings without testing.

### `prepare_zettelkasten_to_manuscript_bridge`

Create bridge metadata only. It should map selected source/alloy notes to section targets but must not consume all notes or rewrite manuscript files automatically.

### `prepare_notebook_to_latex_export`

Create export placeholders for selected notebooks and selected outputs only. Do not run notebooks by default.

### `prepare_manuscript_export_pipeline`

Create scripts/configs that can assemble selected sections under human control. Default mode must be dry-run/no-overwrite.

### `prepare_final_draft_build`

Create build scripts and README notes, but do not build the final PDF by default during skeleton generation.

### `check_latex_build_tools`

Check command presence only, such as `latexmk`, `pdflatex`, `lualatex`, `biber`, `bibtex`, `pandoc`, or `jupyter`, as relevant. Missing optional tools should be WARN unless required by the selected task.

### `check_publisher_env_ready`

Report file structure, role owner, tool availability, and no-overwrite guardrails.

## Path and ownership contracts

Primary owner:

```text
publisher
```

Primary project root:

```text
/workspace/artifacts/papers/grn-paper
```

Must preserve:

```text
/workspace/artifacts/papers/grn-paper/grn-paper.tex
/workspace/artifacts/papers/grn-paper/cls/labreport.cls
/workspace/artifacts/papers/grn-paper/styles/
/workspace/artifacts/papers/grn-paper/bib/
/workspace/artifacts/papers/grn-paper/files/grn/
/workspace/artifacts/papers/grn-paper/fig/grn/
/workspace/artifacts/papers/grn-paper/tables/grn/
/workspace/artifacts/papers/grn-paper/build/
/workspace/artifacts/papers/grn-paper/zettelkasten_bridge/
```

May read selected outputs later from:

```text
/workspace/artifacts/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/pkm/zettelkasten/70_bridge
```

Must not own or rewrite:

```text
/workspace/repos/nca-art-grn
/workspace/repos/openclaw-workspace
/workspace/repos/agentfield
/workspace/pkm/zettelkasten source notes
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh
```

## Output contracts

Required Batch 05 skeleton outputs:

```text
grn-paper.tex
cls/labreport.cls
styles/grn_mres.sty or equivalent
bib/grn.bib
files/grn/titlepage.tex
files/grn/abbreviations.tex
files/grn/abstract.tex
files/grn/introduction.tex
files/grn/results.tex
files/grn/discussion_conclusion.tex
files/grn/methods_materials.tex
files/grn/appendices.tex
fig/grn/README.md
tables/grn/README.md
build/build_lualatex.sh or equivalent
build/build_pdflatex.sh or equivalent
zettelkasten_bridge/grn-paper-binding.yaml
zettelkasten_bridge/section_targets.yaml
README.md or STRUCTURE.md explaining MRes/IBA adaptation
```

Recommended `section_targets.yaml` keys:

```yaml
section_targets:
  titlepage: files/grn/titlepage.tex
  abbreviations: files/grn/abbreviations.tex
  abstract: files/grn/abstract.tex
  introduction_background: files/grn/introduction.tex
  introduction_aims: files/grn/introduction.tex
  results_experimental_strategy: files/grn/results.tex
  results_findings: files/grn/results.tex
  discussion: files/grn/discussion_conclusion.tex
  conclusion: files/grn/discussion_conclusion.tex
  future_work: files/grn/discussion_conclusion.tex
  methods_materials: files/grn/methods_materials.tex
  bibliography: bib/grn.bib
  appendices: files/grn/appendices.tex
```

## Guardrails / non-goals

Codex must not:

```text
build the PDF by default
install TeX packages unless explicitly scoped
run broad bootstrap
consume all Obsidian notes
rewrite manuscript text from PKM automatically
overwrite non-placeholder manuscript files
run notebooks by default
run simulations or parameter searches
call local or remote models
start OpenClaw, Agentfield, Paperclip, RunPod, Docker, Kubernetes, or Terraform live actions
print secrets
edit config internals
claim the skeleton thesis text is final scientific writing
```

The MRes report must preserve scientific-writing guardrails:

```text
figures need captions, legends, axes, and physical units
methods must contain reproducible details, not experimental strategy
experimental strategy belongs in Results
references must be Nature-style numbered/superscript direction
abbreviations must be defined at first use and should not be overused
appendices are supplementary and may not be marked
```

## Smoke and validation relevance

Future `82-publisher-latex.smoke.sh` should verify:

```text
publisher project root exists
expected MRes section files exist
`grn-paper.tex` exists
`cls/labreport.cls` exists
`styles/grn_mres.sty` or equivalent exists
`bib/grn.bib` exists
figure and table directories exist
bridge YAML files exist
no PDF build has been run unless explicitly allowed
no non-placeholder manuscript files are overwritten during rerun
LaTeX syntax check/lint scripts are present
build scripts are present but not executed by default
```

Local Batch 05 smoke may run safe checks such as:

```bash
test -f /workspace/artifacts/papers/grn-paper/grn-paper.tex
test -f /workspace/artifacts/papers/grn-paper/cls/labreport.cls
test -f /workspace/artifacts/papers/grn-paper/styles/grn_mres.sty
test -f /workspace/artifacts/papers/grn-paper/files/grn/abstract.tex
test -f /workspace/artifacts/papers/grn-paper/zettelkasten_bridge/section_targets.yaml
bash --noprofile --norc -n /workspace/artifacts/papers/grn-paper/build/build_lualatex.sh
```

Do not run:

```bash
latexmk
pdflatex
lualatex
biber
bibtex
pandoc
jupyter nbconvert
```

unless the selected implementation task explicitly asks for a build/export smoke and the user approves it.

## How Codex should use this annex when generating a batch

### In `PROJECT_CACHE.md`

Include only compact selected-batch facts:

```text
MRes thesis architecture comes from SPEC_Layer02_05-publisher-latex-ANX03_mres_latex_architecture.md.
Primary root: /workspace/artifacts/papers/grn-paper.
Preserve grn-paper.tex and labreport/IBA-style modular assets.
Use single-column MRes structure, not IBA two-column coursework body.
Create front matter, abbreviations, abstract, introduction, results, discussion/conclusion, methods/materials, bibliography, appendices placeholders.
No PDF build or manuscript overwrite by default.
```

### In `SPEC.md`

Include the selected batch acceptance criteria and exact output tree. Do not paste the entire annex.

### In `RUN_INSTRUCTIONS.md`

Tell Codex to implement only the selected batch, read this annex after `SPEC_Layer02_role_workstations.md`, create skeleton placeholders and bridge metadata, run safe file/shell checks, and stop if required files are missing.

### In `POSTCHECK_TEMPLATE.md`

Require Codex to record:

```text
created/updated publisher root
created/updated MRes section files
bibliography pipeline decision placeholder
build scripts created but not run
bridge files created
smoke/check commands run
INTEGRATION_REQUEST.md created
unresolved citation-toolchain questions
```

## Real-organ transition relevance

This annex is relevant to real-organ work when replacing publisher placeholders with real tooling.

Primary transition touchpoints:

```text
R01 real contract audit and runtime/role readiness:
  verify that Batch 05 skeleton can support true MRes/IBA requirements.

R08 real OpenClaw/PKM reasoning bridge:
  only if selected-context reasoning maps notes or mechanism reports into MRes section targets.

R12 end-to-end real local smoke:
  verify publisher/LaTeX current-state readiness without default PDF build.
```

Real-organ publisher work must preserve the same public contract unless a deliberate versioned migration is created:

```text
same root: /workspace/artifacts/papers/grn-paper
same skeleton main: grn-paper.tex
same section target files
same no-overwrite default
same no-build-by-default guardrail
```

## Open questions

```text
Should the final project use `grn-paper.tex` as the actual main file, or should `grn-paper.tex` be a wrapper around `grn-mres-thesis.tex`?
Should the citation pipeline use BibLaTeX/Biber `style=nature`, or Natbib/BibTeX with a vetted Nature-compatible `.bst`?
Should `cls/labreport.cls` be patched for MRes layout, or should all thesis overrides live in `styles/grn_mres.sty` and the main file?
Should the final output title be called a thesis, research report, or MRes project report in the LaTeX metadata?
Which exact supervisor names, title, student/CID, programme string, and date should populate `titlepage.tex`?
Should appendices be included in the same PDF after bibliography, or delivered separately as supplementary material?
```

## 24-batch visual map

| Batch | Slug | Relevance to this annex |
|---:|---|---|
| 01 | `01-runtime-substrate` | No direct use; only provides generic runtime roots. |
| 02 | `02-research-workspace` | No direct publishing work; later research outputs feed the thesis. |
| 03 | `03-ai-engineer-workspaces` | No direct use; later bridge/reasoner tooling may inspect section targets. |
| 04 | `04-pkm-skeleton` | Optional-strong use for LaTeX section-note templates and bridge target names. |
| 05 | `05-publisher-latex` | Primary required use; creates the MRes LaTeX project and IBA/labreport adaptation. |
| 06 | `06-nca-art-base` | Later mechanism/DSL concepts feed introduction/results/discussion, but no direct use. |
| 07 | `07-dummy-science-organs` | Later dummy outputs may become figure/table placeholders, but no direct use. |
| 08 | `08-mechanism-reporting` | Later mechanism reports may feed Results and Discussion. |
| 09 | `09-local-smoke` | Later smoke outputs may feed methods/results provenance. |
| 10 | `10-search-templates` | Later search design may feed Methods/Results. |
| 11 | `11-search-scoring` | Later scoring reports may feed Results/Discussion. |
| 12 | `12-search-smoke` | Later search smoke may feed reproducibility notes. |
| 13 | `13-runpod-dryrun` | Later remote execution manifests may feed Methods. |
| 14 | `14-openclaw-indexes` | Optional use for section-aware context manifests. |
| 15 | `15-openclaw-reasoners` | Optional use for mocked section-aware reasoning outputs. |
| 16 | `16-agentfield-poc` | No direct use. |
| 17 | `17-agentfield-reasoners` | No direct use. |
| 18 | `18-agentfield-hardening-stubs` | Later artifact/status mapping may link to manuscript outputs. |
| 19 | `19-paperclip-adapter-core` | No direct use. |
| 20 | `20-paperclip-review-dryrun` | Later review payloads may link to manuscript artifacts. |
| 21 | `21-campaign-core` | No direct use. |
| 22 | `22-campaign-agents` | No direct use. |
| 23 | `23-campaign-review-smoke` | Later campaign evidence may feed thesis discussion only through selected artifacts. |
| 24 | `24-campaign-guarded-stubs` | No direct use. |
