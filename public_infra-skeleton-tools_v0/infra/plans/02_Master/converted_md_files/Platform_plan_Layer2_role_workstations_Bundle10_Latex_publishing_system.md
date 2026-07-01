# Bundle 10 - Publisher LaTeX / paper export

**Scrum-master view**

**Bundle objective:** prepare a GRN/NCA/ART scientific-paper LaTeX project based on your existing `labreport` / IBA-protocol structure, then connect it to the Atomic Zettelkasten from Bundle 9.

This bundle is the publication build system. It should not own the research code, run simulations, call models, or manage the PKM itself.

Its job is:

```text
selected alloy notes + figures + tables + citations + research outputs
   -> modular LaTeX section files
   -> reproducible scientific paper build
```

Your existing LaTeX project already has the right direction: a root `.tex` file, custom `cls/labreport`, article-style files, BibTeX/Biber support, modular `files/<type>/...` section files, figure/table helper commands, and build scripts for different engines. `IBA-protocol.tex` is the main structural model: it loads `cls/labreport`, uses an article type style, imports section files, uses bibliography resources, and builds a two-column scientific report with abstract, introduction, methods, results, discussion, conclusion, acknowledgments, and bibliography.

## User story

```text
As the Publisher,
I want a prepared GRN paper LaTeX project,
so that selected Zettelkasten alloy notes, research figures, notebooks, citations,
and experiment outputs can become a reproducible MRes-style scientific paper
without mixing the manuscript build with the research engine.
```

## Concretizations / managed steps

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

I would retire the generic name:

```text
prepare_paper_template_workspace
```

and use:

```text
prepare_grn_paper_latex_project
```

because this is no longer a generic paper folder. It is a GRN discovery paper project with a known style direction.

## What each step should do

### install_publisher_latex_stack

Installs the OS-level LaTeX and document build dependencies.

Expected tools/packages:

```text
texlive-latex-recommended
texlive-latex-extra
texlive-fonts-recommended
texlive-fonts-extra
texlive-science
texlive-bibtex-extra
texlive-formats-extra
texlive-publishers
texlive-xetex
texlive-pictures
latexmk
biber
pandoc
```

Optional desktop tools:

```text
gummi
texworks
evince
xdg-utils
```

These match the direction of your existing `install/install-latex.sh` and `install/install-packages.sh`, which install LaTeX, English/German language support, build tools, Biber, Xetex, science packages, publisher packages, and picture/font packages.

What this does for the work: gives the Publisher role the system tools needed to compile the paper reliably.

Boundary: this may require sudo and OS package installation, so it should be explicit, not hidden inside a harmless-looking prepare step.

### install_publisher_notebook_export_stack

Installs Python-side export tools.

Expected packages:

```text
jupyter
nbconvert
ipykernel
matplotlib
pandas
pyyaml
pandocfilters
```

Optional later:

```text
quarto
jupytext
```

What this does for the work: lets notebooks from the research repo contribute figures, tables, and section drafts without turning notebooks into the final manuscript source.

### prepare_scientific_report_template

Copies or creates the reusable template assets.

It should preserve the pattern:

```text
cls/
styles/
bib/
files/
fig/
tables/
build/
templates/
```

The existing project already has:

```text
cls/labreport.cls
styles/*.sty
bib/*.bib
bib/labreport.bst
build/build_lualatex.sh
build/build_xelatex.sh
build/build_pdflatex.sh
build/build_latex_dvips_ps2pdf.sh
files/iba/*.tex
templates/journal-template.tex
```

What this does for the work: makes your working paper project inherit the structure and style you already like, instead of starting from a blank article template.

Boundary: should not overwrite customized class/style files once created.

### prepare_grn_paper_latex_project

Creates the GRN-specific paper workspace.

Recommended path:

```text
/workspace/artifacts/papers/grn-paper
```

Project structure:

```text
/workspace/artifacts/papers/grn-paper/
├── grn-paper.tex
├── README.md
│
├── cls/
│   └── labreport.cls
│
├── styles/
│   ├── grn.sty
│   └── name.tex
│
├── bib/
│   ├── grn.bib
│   └── labreport.bst
│
├── files/
│   └── grn/
│       ├── abstract.tex
│       ├── introduction.tex
│       ├── background.tex
│       ├── methods.tex
│       ├── simulator.tex
│       ├── nca_art_pipeline.tex
│       ├── parameter_search.tex
│       ├── results.tex
│       ├── discussion.tex
│       ├── conclusion.tex
│       ├── acknowledgments.tex
│       ├── data_availability.tex
│       └── definitions.tex
│
├── fig/
│   └── grn/
│       ├── architecture/
│       ├── simulations/
│       ├── prototypes/
│       ├── transition_graphs/
│       ├── search_results/
│       └── paper_exports/
│
├── tables/
│   └── grn/
│
├── build/
│   ├── build_lualatex.sh
│   ├── build_xelatex.sh
│   ├── build_pdflatex.sh
│   └── out/
│
├── zettelkasten_bridge/
│   ├── publication_goal.yaml
│   ├── section_map.yaml
│   ├── alloy_sources.yaml
│   ├── citation_map.yaml
│   └── figure_map.yaml
│
└── exports/
    ├── drafts/
    ├── submitted/
    └── supplementary/
```

What this does for the work: creates the final paper home that consumes research outputs from `/workspace/artifacts/nca-art-grn/` and publishable notes from the Zettelkasten.

### prepare_labreport_class_assets

Copies or initializes:

```text
cls/labreport.cls
bib/labreport.bst
```

from the known template assets.

It should keep the commands your project relies on:

```text
\articletype{...}
\runningtitle{...}
\runningauthor{...}
\keywords{...}
\dates{...}
\fullref{...}
\inputfile{...}
\twocolstart
\twocolend
```

What this does for the work: preserves the actual report style and helper command system that your previous reports used.

Boundary: once copied, do not overwrite unless a force/update flag is explicitly used.

### prepare_article_style_profile

Creates a GRN-specific style file:

```text
styles/grn.sty
```

It should follow the same role as `styles/iba.sty`: article name, colors, custom labels, `\inputfile` path, two-column helpers, and first-page image hook. The existing `styles/iba.sty` defines `\articletypename`, color values, `\customlabel`, `\fullref`, `\inputfile{files/iba/...}`, and two-column start/stop helpers.

Proposed article identity:

```text
GRN DISCOVERY AND SYNTHETIC PATTERNING
```

Core style responsibilities:

```latex
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{styles/grn}

\newcommand*{\articletypename}{GRN DISCOVERY AND SYNTHETIC PATTERNING}

\definecolor{color2}{RGB}{54,117,174}
\definecolor{color3}{RGB}{54,117,174}

\newcommand{\customlabel}[2]{...}
\newcommand\fullref[1]{\nameref{#1}}

\newcommand*{\inputfile}[1]{%
   \input{files/grn/#1.tex}}

\newcommand\twocolstart{\begin{multicols}{2}}
\newcommand\twocolend{\end{multicols}}
```

What this does for the work: gives the GRN paper its own article type instead of reusing `iba`, `acb`, or `slrp`.

### prepare_latex_section_files

Creates modular section files under:

```text
files/grn/
```

Each section should use the same pattern as your current project:

```latex
\def\introduction {
...
}
\endinput
```

Initial files:

```text
abstract.tex
introduction.tex
background.tex
methods.tex
simulator.tex
nca_art_pipeline.tex
parameter_search.tex
results.tex
discussion.tex
conclusion.tex
acknowledgments.tex
data_availability.tex
definitions.tex
```

Recommended section purpose:

```text
abstract
    one-paragraph summary of the whole work

introduction
    why 5-node GRN discovery and Turing-like patterning matter

background
    known 2/3/4-node motifs, PDE/ODE, NCA, ART, symbolic DSL

methods
    shared method overview

simulator
    PDE/ODE reaction-diffusion simulator and candidate generation

nca_art_pipeline
    NCA surrogate/alternate rule and ART prototype discovery

parameter_search
    random/grid, Latin hypercube, evolutionary, Bayesian, robustness tests

results
    discovered candidates, prototype maps, transition graphs, scores

discussion
    interpretation, limits, biological plausibility, platform implications

conclusion
    concise final claim

data_availability
    where code, candidates, runs, and outputs are stored
```

What this does for the work: gives your paper a research-specific structure before you write all the content.

### prepare_bibliography_pipeline

Creates or verifies:

```text
bib/grn.bib
zettelkasten_bridge/citation_map.yaml
```

It should support two sources of citations:

```text
manual BibTeX entries
Zettelkasten source notes with citation keys
```

It should be compatible with the main paper file using:

```latex
\usepackage[backend=biber,style=apa]{biblatex}
\addbibresource{bib/grn.bib}
```

because that is the pattern used in `IBA-protocol.tex`.

What this does for the work: ensures citations can flow from source notes into the final manuscript.

### prepare_zettelkasten_to_manuscript_bridge

Creates the mapping files that connect Bundle 9 to Bundle 10.

Path:

```text
zettelkasten_bridge/
```

Files:

```text
publication_goal.yaml
section_map.yaml
alloy_sources.yaml
citation_map.yaml
figure_map.yaml
```

Example `section_map.yaml`:

```yaml
abstract:
   latex_file: files/grn/abstract.tex
   source_alloys: []

introduction:
   latex_file: files/grn/introduction.tex
   source_alloys: []

background:
   latex_file: files/grn/background.tex
   source_alloys: []

methods:
   latex_file: files/grn/methods.tex
   source_alloys: []

simulator:
   latex_file: files/grn/simulator.tex
   source_alloys: []

nca_art_pipeline:
   latex_file: files/grn/nca_art_pipeline.tex
   source_alloys: []

parameter_search:
   latex_file: files/grn/parameter_search.tex
   source_alloys: []

results:
   latex_file: files/grn/results.tex
   source_alloys: []

discussion:
   latex_file: files/grn/discussion.tex
```

What this does for the work: it makes the Zettelkasten-to-paper bridge explicit without auto-converting your whole vault.

### prepare_notebook_to_latex_export

Creates configs/scripts that export selected notebooks or generated outputs into manuscript-safe assets.

Expected inputs:

```text
/workspace/repos/nca-art-grn/notebooks/
/workspace/artifacts/nca-art-grn/figures/
/workspace/artifacts/nca-art-grn/reports/
```

Expected outputs:

```text
/workspace/artifacts/papers/grn-paper/fig/grn/
/workspace/artifacts/papers/grn-paper/tables/grn/
```

It should not export every notebook by default.

What this does for the work: lets research notebooks produce figures/tables without becoming the final paper source.

### prepare_manuscript_export_pipeline

Creates a controlled export script/config that can later move selected material from:

```text
Zettelkasten alloy notes
research artifacts
notebook exports
BibTeX entries
```

into:

```text
files/grn/*.tex
fig/grn/
tables/grn/
bib/grn.bib
```

First implementation should create the pipeline skeleton only, not perform full conversion.

What this does for the work: prepares the path from thinking and experiments into manuscript files.

### prepare_final_draft_build

Creates safe build wrappers.

Use the build pattern from your existing project, which includes `build_lualatex.sh`, `build_xelatex.sh`, `build_pdflatex.sh`, and a LaTeX->DVI->PS->PDF route.

Recommended wrappers:

```text
build/build_lualatex.sh
build/build_xelatex.sh
build/build_pdflatex.sh
build/build_clean.sh
```

Default final command later:

```bash
./build/build_lualatex.sh grn-paper.tex
```

or if xelatex works better with your current scripts:

```bash
./build/build_xelatex.sh grn-paper.tex
```

What this does for the work: gives you a repeatable build path while keeping the first setup step non-destructive.

### check_latex_build_tools

Non-mutating check.

Should report:

```text
latex available?
pdflatex available?
xelatex available?
lualatex available?
biber available?
bibtex available?
latexmk available?
pandoc available?
```

It should not install packages and should not build the paper.

### check_publisher_env_ready

Checks the Publisher role.

Should report:

```text
target user
target Python env
LaTeX project path
vault binding path
bib file exists
main tex file exists
section files exist
build scripts exist
figure directories exist
notebook export tools available
```

It must not print manuscript text or private notes.

## Proposed main paper file

The generated `grn-paper.tex` should be modeled on `IBA-protocol.tex`, but adapted for the GRN discovery paper.

```latex
\documentclass[11pt]{cls/labreport}

\usepackage{epstopdf}
\usepackage{multicol}
\usepackage[backend=biber,style=apa]{biblatex}
\addbibresource{bib/grn.bib}

\setlength{\columnsep}{1.4em}
\articletype{grn}

\runningtitle{5-node GRN discovery}
\runningauthor{Hector Edu Nseng}

\title{\vspace*{2cm}Discovery of five-node gene regulatory networks for Turing-like patter

\author[1]{Hector Edu Nseng}
\affil[1]{MRes Systems and Synthetic Biology}

\correspondingauthoraffiliation[$\ast$]{Correspondence Address: To be completed.}

\keywords{Gene regulatory networks; Turing patterns; neural cellular automata; adaptive re

\dates{\rec{xx xx, xxxx} \acc{xx xx, xxxx}}

\begin{document}

\inputfile{abstract}
\inputfile{introduction}
\inputfile{background}
\inputfile{methods}
\inputfile{simulator}
\inputfile{nca_art_pipeline}
\inputfile{parameter_search}
\inputfile{results}
\inputfile{discussion}
\inputfile{conclusion}
\inputfile{acknowledgments}
\inputfile{data_availability}
\inputfile{definitions}

\maketitle
\thispagestyle{firststyle}

\begin{multicols}{2}

\begin{abstract}
   \abstract
\end{abstract}

\section{Introduction}
   \introduction

\section{Background}
   \background

\section{Materials and methods}
   \methods

\section{PDE/ODE simulator}
   \simulator

\section{NCA-ART discovery pipeline}
   \ncaartpipeline

\section{Parameter search and verification}
   \parametersearch

\section{Results}
   \results

\section{Discussion}
   \discussion

\section{Conclusion}
   \conclusion

\section{Acknowledgments}
   \acknowledgments

\section{Data availability}
   \dataavailability

\printbibliography

\end{multicols}
\end{document}
```

## Acceptance criteria

The following managed commands should become valid:

```bash
sudo config --target publisher bootstrap step install_publisher_latex_stack
sudo config --target publisher bootstrap step install_publisher_notebook_export_stack

sudo config --target publisher bootstrap step prepare_grn_paper_latex_project
sudo config --target publisher bootstrap step prepare_labreport_class_assets
sudo config --target publisher bootstrap step prepare_article_style_profile
sudo config --target publisher bootstrap step prepare_latex_section_files
sudo config --target publisher bootstrap step prepare_bibliography_pipeline
sudo config --target publisher bootstrap step prepare_zettelkasten_to_manuscript_bridg
sudo config --target publisher bootstrap step prepare_notebook_to_latex_export
sudo config --target publisher bootstrap step prepare_manuscript_export_pipeline
sudo config --target publisher bootstrap step prepare_final_draft_build

sudo config --target publisher bootstrap step check_latex_build_tools
sudo config --target publisher bootstrap step check_publisher_env_ready
```

They must:

```text
create the GRN paper project
preserve the labreport / IBA-protocol modular architecture
create cls/, styles/, bib/, files/grn/, fig/grn/, tables/, build/, zettelkasten_bridge
create section files only if missing
create bridge YAML files only if missing
create build scripts only if missing
not overwrite manuscript text
not consume all Obsidian notes automatically
not build the PDF unless explicitly requested
not run simulations
not call remote models
not modify research data
```

## Proposed tests

### Registry and shell syntax tests

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh

config bootstrap steps | grep prepare_grn_paper_latex_project
config bootstrap steps | grep prepare_labreport_class_assets
config bootstrap steps | grep prepare_article_style_profile
config bootstrap steps | grep prepare_latex_section_files
config bootstrap steps | grep prepare_zettelkasten_to_manuscript_bridge
config bootstrap steps | grep check_latex_build_tools
```

### Project structure tests

```bash
sudo config --target publisher bootstrap step prepare_grn_paper_latex_project

test -d /workspace/artifacts/papers/grn-paper
test -d /workspace/artifacts/papers/grn-paper/cls
test -d /workspace/artifacts/papers/grn-paper/styles
test -d /workspace/artifacts/papers/grn-paper/bib
test -d /workspace/artifacts/papers/grn-paper/files/grn
test -d /workspace/artifacts/papers/grn-paper/fig/grn
test -d /workspace/artifacts/papers/grn-paper/tables/grn
test -d /workspace/artifacts/papers/grn-paper/build
test -d /workspace/artifacts/papers/grn-paper/zettelkasten_bridge
```

### Template asset tests

```bash
sudo config --target publisher bootstrap step prepare_labreport_class_assets
sudo config --target publisher bootstrap step prepare_article_style_profile

test -f /workspace/artifacts/papers/grn-paper/cls/labreport.cls
test -f /workspace/artifacts/papers/grn-paper/styles/grn.sty
test -f /workspace/artifacts/papers/grn-paper/bib/labreport.bst
```

### Section file tests

```bash
sudo config --target publisher bootstrap step prepare_latex_section_files

test -f /workspace/artifacts/papers/grn-paper/grn-paper.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/abstract.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/introduction.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/background.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/methods.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/simulator.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/nca_art_pipeline.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/parameter_search.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/results.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/discussion.tex
test -f /workspace/artifacts/papers/grn-paper/files/grn/conclusion.tex
```

### Bridge file tests

```bash
sudo config --target publisher bootstrap step prepare_zettelkasten_to_manuscript_bridg

test -f /workspace/artifacts/papers/grn-paper/zettelkasten_bridge/publication_goal.yam
test -f /workspace/artifacts/papers/grn-paper/zettelkasten_bridge/section_map.yaml
test -f /workspace/artifacts/papers/grn-paper/zettelkasten_bridge/alloy_sources.yaml
test -f /workspace/artifacts/papers/grn-paper/zettelkasten_bridge/citation_map.yaml
test -f /workspace/artifacts/papers/grn-paper/zettelkasten_bridge/figure_map.yaml
```

### Build-tool check

```bash
sudo config --target publisher bootstrap step check_latex_build_tools
```

Expected: reports available/missing tools only.

### Optional PDF smoke build

This should not run automatically in the prepare steps. It can be a later explicit test:

```bash
su - publisher
cd /workspace/artifacts/papers/grn-paper
./build/build_lualatex.sh grn-paper.tex
```

Expected output:

```text
build/out/grn-paper.pdf
```

Only do this once the placeholder section files are syntactically valid.

### Non-overwrite test

```bash
echo "DO NOT OVERWRITE" > /workspace/artifacts/papers/grn-paper/files/grn/introduction
sudo config --target publisher bootstrap step prepare_latex_section_files
grep "DO NOT OVERWRITE" /workspace/artifacts/papers/grn-paper/files/grn/introduction.t
```

## Summary

Bundle 10 is the paper production system.

It prepares:

```text
GRN-specific LaTeX paper project
labreport class assets
GRN article style profile
modular section files
bibliography pipeline
figure/table folders
Zettelkasten-to-manuscript bridge
notebook export bridge
safe build scripts
publisher readiness checks
```

It consumes from:

```text
Bundle 9 Atomic Zettelkasten
   selected alloy notes, citations, publication goals

NCA-ART-GRN research repo
   notebooks, figures, tables, results

/workspace/artifacts/nca-art-grn
   reusable research outputs
```

It outputs to:

```text
/workspace/artifacts/papers/grn-paper
```

The boundary is:

```text
Bundle 9 organizes publishable knowledge.
Bundle 10 formats and builds the paper.
Bundle 3/4/5 generate research evidence.
Bundle 10 should never become the research engine.
```

This keeps the manuscript reproducible, modular, and close to the final research-paper direction you already prototyped in `IBA-protocol.tex`.
