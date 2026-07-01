# BATCH_CREATION_ANX03_mres_latex_architecture

Status: batch-creation hook for `NEW_CHAT_PROMPT_batch_creation.md`.  
Purpose: make `SPEC_Layer02_05-publisher-latex-ANX03_mres_latex_architecture.md` consumable by future skeleton and organ batch-generation chats.

## Canonical annex file to request

When the selected batch needs this context, ask the user to upload:

```text
SPEC_Layer02_05-publisher-latex-ANX03_mres_latex_architecture.md
```

## What this hook represents

This hook represents the MRes thesis adaptation of the existing labreport / IBA LaTeX template. The deeper annex captures how the uploaded MRes Word template constraints should be implemented in the Publisher LaTeX project without breaking the existing `grn-paper` skeleton contract.

The annex matters because the thesis specification is stricter than the current IBA coursework template in several ways:

```text
single-column thesis flow instead of IBA two-column article flow
MRes title page, contents, abbreviations, abstract, ordered sections, and bibliography
Arial/Helvetica-compatible 11 pt minimum typography
1.5 line spacing
2.5 cm margins
Nature-style superscript numbered references
no PDF build by default during skeleton batch generation
no manuscript overwrite without explicit human request
```

## Batch request rule

| Selected skeleton batch | Ask user to supply the annex? | Batch-creation behavior |
|---:|---|---|
| 04 `04-pkm-skeleton` | yes, optional-strong | Ask for it if PKM LaTeX section-note templates or the LaTeX bridge should already align to the final MRes thesis section architecture. Continue only if the user confirms it is unavailable. |
| 05 `05-publisher-latex` | yes, required | Stop and ask for the annex if missing. This is the primary batch that creates the Publisher LaTeX project and must preserve the MRes thesis architecture. |
| 14 `14-openclaw-indexes` | yes, optional | Ask only if OpenClaw indexes should include manuscript section targets or thesis-context manifests. |
| 15 `15-openclaw-reasoners` | yes, optional | Ask only if reasoner profiles should produce MRes-section-aware next-experiment, mechanism-review, or paper-outline outputs. |
| other skeleton batches | no | Do not ask unless the user explicitly wants MRes publishing or LaTeX architecture context. |

## Real-organ mirror rule

| Organ batch | Ask user to supply the annex? | Behavior |
|---:|---|---|
| R01 `real-contract-audit-runtime-role-readiness` | yes, optional-strong | Useful for auditing whether the corrected skeleton Batch 05 publisher contract can support the true MRes/IBA thesis requirements. |
| R08 `real-openclaw-pkm-reasoning-bridge` | yes, optional | Useful only when selected PKM/OpenClaw reasoning outputs need to target actual MRes thesis sections. |
| R12 `end-to-end-real-local-smoke` | yes, optional | Useful for final current-state checks that include publisher/LaTeX smoke readiness, but still no PDF build by default. |

## How generated batch files should consume it

### Batch 04

Add the annex to `PROJECT_CACHE.md` only when the PKM batch is expected to create LaTeX section-note templates that mirror the final thesis architecture. Generated instructions should keep Batch 04 focused on templates and bridge paths only; it must not build the paper, rewrite notes, or auto-promote notes.

### Batch 05

Add the annex to `PROJECT_CACHE.md` as a required read-only input. The generated `SPEC.md` should require a Publisher LaTeX skeleton that preserves:

```text
/workspace/artifacts/papers/grn-paper/grn-paper.tex
/workspace/artifacts/papers/grn-paper/cls/labreport.cls
/workspace/artifacts/papers/grn-paper/styles/grn_mres.sty or equivalent
/workspace/artifacts/papers/grn-paper/bib/grn.bib
/workspace/artifacts/papers/grn-paper/files/grn/*.tex
/workspace/artifacts/papers/grn-paper/fig/grn/
/workspace/artifacts/papers/grn-paper/tables/grn/
/workspace/artifacts/papers/grn-paper/build/
/workspace/artifacts/papers/grn-paper/zettelkasten_bridge/
```

The generated `RUN_INSTRUCTIONS.md` should tell Codex to create skeleton placeholders only, verify file structure and LaTeX syntax safely, and avoid building the PDF unless explicitly requested.

### Batch 14

Use the annex only to add selected manuscript-section targets to OpenClaw context manifests. Do not index the whole vault, print note bodies, call models, write manuscript text, or launch experiments.

### Batch 15

Use the annex only to make mocked/local reasoner outputs section-aware, for example mapping a mechanism review to `discussion_conclusion.tex` or a method detail to `methods_materials.tex`. Do not write into the real manuscript by default.

## Stop condition language for batch-generation chats

For required batches, if the annex is missing, respond:

```text
Missing required annex for this batch:
- SPEC_Layer02_05-publisher-latex-ANX03_mres_latex_architecture.md

Please upload it before I generate the Codex batch package, because Batch 05 must preserve the MRes thesis structure, IBA/labreport template adaptation, Nature-style citation direction, and no-build/no-overwrite publisher guardrails.
```

For recommended batches, if the annex is missing, respond:

```text
Recommended annex is missing:
- SPEC_Layer02_05-publisher-latex-ANX03_mres_latex_architecture.md

This annex is not strictly required for this batch, but it helps preserve the MRes thesis section architecture and LaTeX bridge direction. Upload it if available; otherwise confirm I should proceed without it.
```

## Guardrail

This hook does not change the corrected skeleton or real-organ batch slicing. It is contextual implementation guidance only. It must not cause batch generation to build PDFs by default, overwrite manuscript content, consume all Obsidian notes, call live models, or edit config internals.
