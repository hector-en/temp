# Layer 4 - Knowledge, reasoning, and writing automation

**Product-owner version**

**Product goal:** turn the research platform's outputs into usable knowledge, reasoning context, and writing material.

Layer 1 prepared the runtime.  
Layer 2 prepared the roles.  
Layer 3 prepared scientific execution loops.  
Layer 4 prepares the thinking layer that sits above experiments but below full orchestration.

## It answers

- Can I query my research notes, experiment outputs, papers, code summaries, and mechanism reports?
- Can I turn runs into structured reasoning context without manually reading every artifact?
- Can OpenClaw or a local/remote model help me reason over the PKM without corrupting the vault?
- Can outputs from GRN/NCA/ART runs become Zettelkasten notes, paper sections, or next-experiment ideas?

## Layer 4 boundary

### Layer 4 should do

- prepare PKM context indexes
- prepare OpenClaw workspace
- prepare safe local/remote model reasoning configs
- prepare query smoke tests

### Layer 4 should not do

- not replace the Zettelkasten vault
- not overwrite notes
- not auto-generate final paper sections
- not run GRN simulations
- not train NCA models
- not launch Runpod jobs
- not build Agentfield controller
- not build Paperclip adapter

## The rule

- Bundle 9 owns the PKM structure.
- Layer 4 lets tools reason over that PKM safely.

So this layer does not reorganize the vault again. It adds reasoning access.

## Bundle inside Layer 4

- Bundle 8 - OpenClaw + PKM reasoning workspace

# Bundle 8 - OpenClaw + PKM reasoning workspace

## Product outcome

A prepared workspace where OpenClaw, local model clients, remote model clients, and lightweight indexing tools can reason over selected research material.

This should connect:

- Atomic Zettelkasten
  - source notes, atoms, molecules, research questions, alloy notes
- NCA-ART-GRN artifacts
  - mechanism reports, search reports, candidate DSL files, figures, metrics
- Remote model brain endpoint
  - thin model client from Layer 1
- OpenClaw workspace
  - tool reasoning, query workflows, local context packs

## Concretizations

- `prepare_openclaw_pkm_workspace`
- `check_openclaw_workspace`
- `prepare_pkm_context_index`
- `prepare_local_model_reasoner_config`
- `prepare_pkm_query_smoke_test`

## Potentially later

- `prepare_experiment_report_ingest`
- `prepare_zettelkasten_reasoning_bridge`
- `prepare_next_experiment_question_generator`
- `prepare_mechanism_report_to_alloy_note_bridge`

# Product meaning of each concretization

## `prepare_openclaw_pkm_workspace`

Creates the workspace where OpenClaw-style reasoning workflows live.

Suggested path:

```text
/workspace/repos/openclaw-workspace/
```

It should contain:

```text
configs/
contexts/
queries/
tools/
runs/
smoke_tests/
```

Product value: gives AI reasoning tools a home separate from the research repo and separate from the PKM vault.

## `check_openclaw_workspace`

Checks that the OpenClaw workspace exists and is usable.

It should report:

- workspace path
- config path
- context path
- query path
- runs path
- model config present or missing

Product value: lets the operator verify the reasoning workspace before model calls or indexing.

## `prepare_pkm_context_index`

Creates an index or manifest over selected PKM and artifact material.

It should index or list selected paths such as:

```text
/workspace/pkm/zettelkasten/20_knowledge_kasten
/workspace/pkm/zettelkasten/30_publish_kasten
/workspace/pkm/zettelkasten/40_experiments
/workspace/artifacts/nca-art-grn/mechanism_reports
/workspace/artifacts/nca-art-grn/search_reports
```

It should not index everything by default.

Product value: lets tools ask useful questions over the research corpus without dumping the whole vault into a prompt.

## `prepare_local_model_reasoner_config`

Creates model-routing config for local or remote reasoning.

It should connect to Layer 1's remote model client contract:

```text
local code -> remote model -> response
```

But it should support multiple reasoning profiles:

- `fast_summary`
- `deep_research_reasoning`
- `paper_outline`
- `mechanism_review`
- `next_experiment_suggestion`
- `codebase_triage`

Product value: makes the model reasoning layer reusable by OpenClaw, later Agentfield agents, and manual CLI workflows.

## `prepare_pkm_query_smoke_test`

Creates a tiny query test that asks against a small selected context pack.

Example smoke questions:

- What mechanism reports exist?
- Which candidate has the strongest perturbation evidence?
- Which Zettelkasten research questions are linked to NCA-ART?
- Which mechanism reports should become alloy notes?
- What is the next experiment suggested by the latest search report?

Product value: verifies that PKM reasoning works without modifying notes or launching experiments.

# Layer 4 relationship to earlier layers

- Layer 1
  - provides runtime and remote model client
- Layer 2
  - provides PKM vault and Publisher/AI Engineer roles
- Layer 3
  - produces mechanism reports, search reports, candidate artifacts
- Layer 4
  - reasons over those notes and artifacts

# Layer 4 relationship to later layers

Layer 4 prepares reasoning tools that later become useful to Agentfield and Paperclip:

- Agentfield later
  - can call reasoners to summarize experiments, suggest next runs, rank hypotheses, and triage failures
- Paperclip later
  - can show model-generated summaries, review tasks, next-experiment proposals, and paper-writing suggestions

But at this stage:

- OpenClaw/PKM reasoning is manual or config-smoke driven.
- Agentfield orchestration comes later.
- Paperclip dashboard comes later.

# Layer 4 success condition

After Layer 4, you should be able to say:

- My PKM vault is structured.
- My experiment reports are stored.
- My OpenClaw workspace exists.
- My reasoning config points to local/remote model clients.
- I can run a safe query smoke test over selected research context.
- No notes are overwritten.
- No experiments are launched.
- No papers are auto-generated.

## In one line

Layer 4 turns research outputs and PKM notes into queryable reasoning context.
