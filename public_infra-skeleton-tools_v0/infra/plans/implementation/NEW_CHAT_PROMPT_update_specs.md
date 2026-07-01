# New-chat prompt: map annex background into the correct Layer SPEC and batch-aligned ANX files

Use this prompt in a fresh ChatGPT chat when I upload new platform background notes, layer plans, batch plans, or annex/detail files and ask you to update the right SPEC files.

## What I want you to do

I am building a 5-layer platform plan and a set of implementation-batch specs. I may upload background notes without knowing which layer or batch they belong to. Your job is to read the uploaded planning files, infer the correct layer and batch mapping, and create or update the correct markdown files.

Do not assume that a note belongs to a layer just because its filename says so. Use the actual content, the latest batch plan, the corrected batch mapping, and the layer/bundle descriptions to decide where it belongs.

## Naming convention to use

### Main layer SPEC

Name the main layer-level spec like this:

```text
SPEC_Layer<##>_<actual_layer_implementation>.md
```

Examples:

```text
SPEC_Layer01_runtime_substrate.md
SPEC_Layer02_role_workstations.md
SPEC_Layer03_research_execution_loops.md
SPEC_Layer04_knowledge_reasoning.md
SPEC_Layer05_platform_orchestration.md
```

The main SPEC is layer-level. It should explain the layer purpose, product boundary, product meaning, bundles, non-goals, success condition, and the batch-to-layer implementation map.

### Annex / detail SPEC

Name annex files like this:

```text
SPEC_Layer<##>_<batch-slug>-ANX<##>_<actual_annex_implementation>.md
```

Examples:

```text
SPEC_Layer01_02-research-workspace-ANX01_workspace_boundaries.md
SPEC_Layer02_04-pkm-skeleton-ANX01_zettelkasten_templates.md
SPEC_Layer03_06-nca-art-base-ANX01_dsl_candidate_runtime.md
SPEC_Layer05_19-paperclip-adapter-core-ANX01_request_status_mapping.md
```

The batch slug must reflect the actual batch where the annex background is most valuable for implementation. For example, details about `prepare_nca_art_workspace` are not implemented in Layer 1 Batch 01, even if they explain a Layer 1 boundary. They belong to Batch 02 `02-research-workspace`, so the annex name should use `02-research-workspace`.

## Required source files to ask me for

If any of these are missing, ask me to upload them before generating final files. Stop and report exactly what is missing if a required file is unavailable or unreadable.

### Global and layer context

```text
00_Global_architecture_and_layer_grouping.md
Platform_plan_Layer1_ProductOwner_runtime_substrate.md
Platform_plan_Layer2_ProductOwner_role_workstations.md or equivalent Layer 2 files
Platform_plan_Layer3_ProductOwner_research_execution_loops.md
Platform_plan_Layer4_ProductOwner_knowledge_reasoning.md
Platform_plan_Layer5_ProductOwner_platform_orchestration.md
```

If a complete Layer 2 Product Owner file is not available, use any provided Layer 2 bundle files, such as Bundle 9 or Bundle 10 files, but say that the Layer 2 source set is partial.

### Skeleton implementation authority

```text
00_A0_skeleton_dummy_master_implementation_companion.md
00_A1_skeleton_dummy_codex_batch_plan_v2.md
00_A2_skeleton_batch_mapping_report_batches_01_24.md
```

If `00_A1_skeleton_dummy_codex_batch_plan_v1.md` is uploaded, read it as historical comparison only. Prefer v2 and the corrected mapping report when they disagree.

### Real-organ transition authority, when relevant

```text
01_B0_transition_to_real_organs_master_v2.md
01_B1_transition_real_organs_codex_batch_plan_v2.md
```

If v1 versions are uploaded, read them as historical comparison only. Prefer v2 when they disagree.

### Optional context

```text
CONFIG_TOOL.md
latest existing SPEC_Layer*.md files
latest existing SPEC_Layer*-ANX*.md files
latest Platform_plan_*.md aliases
latest dev-recordings / POSTCHECK.md / INTEGRATION_REQUEST.md if available
```

Use these only to preserve naming, compatibility, and implementation trajectory.

## Required read order

Read files in this order:

1. Global architecture and layer grouping.
2. Product-owner layer files for Layers 1-5.
3. Skeleton master implementation companion.
4. Skeleton batch plan v2.
5. Corrected skeleton batch mapping report.
6. Real-organ transition master and batch plan if the request mentions real organs or transition work.
7. Existing SPEC files and annex files, if uploaded.
8. New annex/background notes to be classified.

## Core mapping rule

The layer files explain product meaning and semantics. The batch plans decide implementable slices.

Use this logic:

```text
Background note -> identify concrete steps / paths / outputs / boundaries
Concrete steps -> match to skeleton master step names
Step names -> match to batch plan and corrected mapping
Batch -> infer layer, bundle, slug, smoke domain, and implementation timing
Result -> update the right SPEC_Layer file and create/update the right ANX file
```

Do not map from layer to batch first. Map from batch to what it implements or consumes from that layer.

## Skeleton batch map to use

Use the latest corrected 24-batch skeleton map as the implementation authority:

```text
01-runtime-substrate
02-research-workspace
03-ai-engineer-workspaces
04-pkm-skeleton
05-publisher-latex
06-nca-art-base
07-dummy-science-organs
08-mechanism-reporting
09-local-smoke
10-search-templates
11-search-scoring
12-search-smoke
13-runpod-dryrun
14-openclaw-indexes
15-openclaw-reasoners
16-agentfield-poc
17-agentfield-reasoners
18-agentfield-hardening-stubs
19-paperclip-adapter-core
20-paperclip-review-dryrun
21-campaign-core
22-campaign-agents
23-campaign-review-smoke
24-campaign-guarded-stubs
```

Layer-to-batch grouping:

```text
Layer 1: Batch 01
Layer 2: Batches 02-05
Layer 3: Batches 06-13
Layer 4: Batches 14-15
Layer 5: Batches 16-24
```

But remember: if a background note belongs semantically to Layer 1 but is actually implemented by Batch 02, the annex filename should use the implementable batch slug, not the nearby layer slug.

## What to put in the main layer SPEC

Each `SPEC_Layer<##>_<implementation>.md` should contain:

```text
# SPEC_Layer<##>_<implementation>

## Purpose
## Product goal
## Product meaning
## Layer answers
## Layer boundary
### Should do
### Should not do
## Bundles in this layer
## Key concretizations
## Batch -> layer implementation map
## 24-batch visual map
## Smoke / validation mapping
## Output and path contracts
## Relationship to earlier layers
## Relationship to later layers
## Annex index
## Acceptance / success condition
## Developer notes
```

Product meaning must be detailed enough for a developer who has not read the whole chat. Do not over-compress it. Explain why the layer exists, what downstream developers must preserve, and what must not be hidden inside setup.

The `Batch -> layer implementation map` must read like this:

```text
Batch 01 implements these parts of Layer 1: ...
Batch 02 consumes these Layer 1 contracts while implementing Layer 2 research workspace: ...
Batch 13 consumes these Layer 1 runtime contracts for RunPod dry-run: ...
```

The map should not read as `Layer 1 maps to Batch 01 only` if later batches consume Layer 1 contracts.

## What to put in an annex SPEC

Each annex should contain:

```text
# SPEC_Layer<##>_<batch-slug>-ANX<##>_<annex-purpose>

## Why this annex exists
## Most relevant implementation batch
## Related layer and bundle
## Background source notes
## What this extends in the main layer SPEC
## Batch -> implementation relevance
## Concrete steps affected
## Path and ownership contracts
## Output contracts
## Guardrails / non-goals
## Smoke and validation relevance
## How Codex should use this annex when generating a batch
## Open questions
```

The annex should preserve enough detail from the background note that Codex can use it during batch generation. Do not strip it down to a summary if the details are implementation-significant.

## Visual batch style

Use one consistent visual map in all SPEC and ANX files.

Recommended markdown style:

```text
- **[x] 01-runtime-substrate** - active for this layer/spec
- ~~[ ] 02-research-workspace~~ - not implemented by this layer, but may consume its contracts
- ~~[ ] 03-ai-engineer-workspaces~~
```

For annex files, tick the batch where the annex is most valuable during batch creation. If the annex is consumed by more than one batch, tick the primary batch and list secondary batches separately.

## Classification rules for annex/background notes

When I upload a background note, classify it using the following rules:

### Runtime roots, GPU/CUDA, Docker, Terraform/Kubernetes read-only checks, remote model dummy client

Primary target:

```text
SPEC_Layer01_runtime_substrate.md
SPEC_Layer01_01-runtime-substrate-ANX##_...
```

Usually Batch 01.

### `prepare_nca_art_workspace`, NCA-ART-GRN repo structure, repo-local vs /workspace shared storage

Primary target:

```text
SPEC_Layer02_role_workstations.md
SPEC_Layer02_02-research-workspace-ANX##_...
```

If the note explains why Layer 1 must stay generic, reference it from Layer 1, but do not name the annex as Batch 01 unless Batch 01 implements it.

### PKM / Obsidian / Zettelkasten templates

Primary target:

```text
SPEC_Layer02_role_workstations.md
SPEC_Layer02_04-pkm-skeleton-ANX##_...
```

### Publisher / LaTeX / paper export

Primary target:

```text
SPEC_Layer02_role_workstations.md
SPEC_Layer02_05-publisher-latex-ANX##_...
```

### DSL, simulator, NCA, ART2, ARTMAP, mechanism reports, local science smoke

Primary target:

```text
SPEC_Layer03_research_execution_loops.md
SPEC_Layer03_06-nca-art-base-ANX##_...
SPEC_Layer03_07-dummy-science-organs-ANX##_...
SPEC_Layer03_08-mechanism-reporting-ANX##_...
SPEC_Layer03_09-local-smoke-ANX##_...
```

Choose the exact batch by the concrete steps affected.

### Parameter search, scoring, robustness, perturbation search

Primary target:

```text
SPEC_Layer03_research_execution_loops.md
SPEC_Layer03_10-search-templates-ANX##_...
SPEC_Layer03_11-search-scoring-ANX##_...
SPEC_Layer03_12-search-smoke-ANX##_...
```

### RunPod training/inference/job manifests/checkpoints/result return

Primary target:

```text
SPEC_Layer03_research_execution_loops.md
SPEC_Layer03_13-runpod-dryrun-ANX##_...
```

If the note is only generic runtime readiness, it may belong to Layer 1 Batch 01 instead.

### OpenClaw / PKM reasoning / model reasoning over selected context

Primary target:

```text
SPEC_Layer04_knowledge_reasoning.md
SPEC_Layer04_14-openclaw-indexes-ANX##_...
SPEC_Layer04_15-openclaw-reasoners-ANX##_...
```

### Agentfield POC, reasoners, hardening stubs

Primary target:

```text
SPEC_Layer05_platform_orchestration.md
SPEC_Layer05_16-agentfield-poc-ANX##_...
SPEC_Layer05_17-agentfield-reasoners-ANX##_...
SPEC_Layer05_18-agentfield-hardening-stubs-ANX##_...
```

### Paperclip-Agentfield adapter

Primary target:

```text
SPEC_Layer05_platform_orchestration.md
SPEC_Layer05_19-paperclip-adapter-core-ANX##_...
SPEC_Layer05_20-paperclip-review-dryrun-ANX##_...
```

### Campaign schema, agents, review gate, guarded live stubs

Primary target:

```text
SPEC_Layer05_platform_orchestration.md
SPEC_Layer05_21-campaign-core-ANX##_...
SPEC_Layer05_22-campaign-agents-ANX##_...
SPEC_Layer05_23-campaign-review-smoke-ANX##_...
SPEC_Layer05_24-campaign-guarded-stubs-ANX##_...
```

## Real-organ transition overlay

If I ask about real organs or transition work, create/update a real-organ section in the relevant layer SPEC and annex. Use the transition batch plan to map skeleton batches to real-organ batches.

Real-organ batch names are separate from skeleton batch names. Do not rename skeleton annex files as real-organ batches unless I explicitly ask.

Use this pattern for organ annexes only if requested:

```text
SPEC_Layer<##>_R<##>-<organ-slug>-ANX<##>_<annex-purpose>.md
```

## Required behavior when files are missing

If any required file is missing or unreadable:

1. Stop.
2. Say exactly which file is missing or unreadable.
3. Explain what you can still infer, if anything.
4. Ask me to upload the missing file.
5. Do not generate final SPEC files until the required files are present.

## Output I want from you

After you process the uploaded background, produce:

1. Updated or created main layer SPEC file(s).
2. Updated or created annex SPEC file(s).
3. Compatibility aliases only if I ask for them.
4. A short final response listing the files created and what each one is for.

When creating files, provide sandbox links.

## Codex instruction generation mode

If I ask you to create Codex instruction files from the specs, generate a Codex-ready package that tells Codex:

- Which SPEC_Layer file to read.
- Which SPEC_Layer...ANX file(s) to read.
- Which batch from the 24-batch skeleton plan is active.
- Which concrete steps it must implement.
- Which files/directories it may create.
- Which files/directories it must not touch.
- Which smoke domain applies.
- Which output contracts must be preserved.
- Which guardrails apply.
- Where to write POSTCHECK.md and INTEGRATION_REQUEST.md.

Codex instruction files should not repeat the entire layer background. They should cite or reference the relevant SPEC and ANX files and include only batch-specific implementation facts.

## Guardrails to preserve in every generated SPEC/ANX/Codex instruction

```text
Do not edit the config tool unless a dedicated config-integration batch explicitly says so.
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh.
Do not run broad bootstrap.
Do not mount, pull, push, or read credentials unless explicitly requested.
Do not launch RunPod jobs by default.
Do not run Docker builds or containers by default.
Do not call live model/provider APIs by default.
Do not write to Paperclip live state by default.
Do not overwrite PKM notes or manuscript content by default.
Preserve output contracts so dummy skeleton organs can later become real organs.
Smoke tests prove shape/readiness/contracts, not scientific truth.
Final pattern similarity is never sufficient mechanism evidence.
```

## First message template I will use next time

I may paste something like this:

```text
Read this prompt and the uploaded platform files. I am adding new annex/background notes and I do not know which layer or batch they belong to. Classify them, update the correct SPEC_Layer file, create or update the correct SPEC_Layer<##>_<batch-slug>-ANX<##> file(s), and tell me which skeleton batch should receive each annex during Codex batch generation. Stop if required files are missing.
```

Follow this document exactly when responding to that request.
