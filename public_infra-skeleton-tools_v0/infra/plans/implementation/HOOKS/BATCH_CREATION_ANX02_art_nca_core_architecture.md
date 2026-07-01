# BATCH_CREATION_ANX02_art_nca_core_architecture

Status: batch-creation hook for `NEW_CHAT_PROMPT_batch_creation.md`.  
Purpose: make the Layer 3 ART/NCA core architecture annex consumable by future skeleton batch-generation chats without embedding the full annex logic inside the batch-creation prompt.

## Canonical annex file to request

When the selected batch needs this context, ask the user to upload:

```text
SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md
```

This file is a batch-aligned Layer 3 annex for Batch 06 / `06-nca-art-base`. It records the bridge between:

```text
NCA as a local differentiable pattern/process generator
ART2 as stable continuous prototype discovery
ARTMAP as transition/context mapping
DSL candidate mechanisms as symbolic recoverability targets
mechanism reports as falsification and experiment-design surfaces
Agentfield/RunPod as later orchestration and scale layers
```

It is intentionally a hook file. It does not replace the full SPEC annex. It tells a batch-generation chat when to request the full annex and how to summarize it into generated `PROJECT_CACHE.md`, `SPEC.md`, and `RUN_INSTRUCTIONS.md`.

## Batch request rule

Use this table during skeleton batch creation:

| Selected batch | Ask user to supply the annex? | Batch-creation behavior |
|---:|---|---|
| 06 `06-nca-art-base` | yes, required | Stop and ask for the annex if missing. |
| 07 `07-dummy-science-organs` | yes, required | Stop and ask for the annex if missing. |
| 08 `08-mechanism-reporting` | yes, required | Stop and ask for the annex if missing. |
| 09 `09-local-smoke` | yes, optional/strong | Ask for it; continue only if user confirms it is unavailable. |
| 10 `10-search-templates` | yes, optional/strong | Ask for it when search templates should include NCA/ART mechanism-evidence fields. |
| 11 `11-search-scoring` | yes, optional/strong | Ask for it when scoring should reward NCA agreement, ART prototype quality, ARTMAP transition consistency, perturbation evidence, falsification value, or DSL recoverability. |
| 12 `12-search-smoke` | yes, optional | Ask only if the smoke output should include NCA/ART/search-evidence placeholders. |
| 13 `13-runpod-dryrun` | yes, optional/strong | Ask when RunPod manifests/result-return policies should preserve mechanism evidence artifacts instead of only images/checkpoints. |
| 18 `18-agentfield-hardening-stubs` | yes, optional/strong | Ask when Agentfield bridge/status mappings should consume NCA-ART-GRN artifacts. |
| other skeleton batches | no | Do not ask unless the user explicitly wants Layer 3 NCA/ART/science context. |

Real-organ mirror rule:

| Organ batch | Ask user to supply the annex? | Behavior |
|---:|---|---|
| R02 `real-grn-dsl-simulator` | yes, required | Needed to replace dummy DSL/simulator placeholders while preserving future NCA/ART evidence contracts. |
| R03 `real-nca-local-rule` | yes, required | Needed to implement the NCA local-rule/surrogate organ consistently with simulator trajectories and local update evidence. |
| R04 `real-art2-artmap` | yes, required | Needed to implement ART2 prototype and ARTMAP transition organs with inspectable prototype/transition contracts. |
| R05 `real-mechanism-report` | yes, required | Needed to turn evidence artifacts into mechanism-discrimination and falsification reports. |
| R06 `real-parameter-search` | yes, optional/strong | Useful for keeping search/ranking tied to NCA/ART/mechanism evidence. |
| R07 `real-runpod-boundary` | yes, optional/strong | Useful for result-return manifests and cost-aware run evidence. |
| R09 `real-agentfield-experiment` | yes, optional/strong | Useful for Agentfield artifact/status mappings and experiment lifecycle integration. |
| R12 `end-to-end-real-local-smoke` | yes, optional/strong | Useful for validating that all real local organs preserve the same evidence shape. |

## How generated batch files should consume it

### Batch 06

Add the annex to `PROJECT_CACHE.md` as a required read-only input. The generated `SPEC.md` should include:

```text
This batch must only create schema/base surfaces for `prepare_dsl_candidate_runtime` and `prepare_mechanism_hypothesis_runtime`.
It must encode future NCA/ART evidence fields in the DSL and mechanism-hypothesis schemas, but must not run simulation, train NCA, run ART2/ARTMAP, or claim discovery.
```

Required schema direction:

```text
candidate DSL fields: node_count, nodes, edges, signs, interaction_matrix, reaction_parameters, diffusion_parameters, observables, perturbables, motif_provenance, constraints.
mechanism hypothesis fields: formation_dynamics_prediction, perturbation_predictions, expected_nca_evidence, expected_art2_prototypes, expected_artmap_transitions, falsification_criteria, experimental_design_suggestions.
```

### Batch 07

Use the annex to require deterministic dummy outputs for:

```text
simulator_summary.json
pattern_dynamics.json
nca_summary.json
art2_prototypes.json
artmap_transitions.json
perturbation_summary.json
```

The dummy outputs should look replaceable by real organs later. They must preserve IDs and schema shape, but must not claim real biology, real mechanism discovery, or real trained NCA/ART behavior.

### Batch 08

Use the annex to require mechanism reports to include:

```text
Final pattern is not sufficient evidence
Mechanism hypothesis
Dynamics evidence
NCA local-rule evidence
ART2 prototype evidence
ARTMAP transition evidence
Perturbation prediction
Prototype-to-DSL recoverability
Experimental design suggestion
Falsification criterion
Open questions
```

### Batch 09

Use the annex when local smoke creates or changes the NCA-ART-GRN smoke artifact set. The smoke output should include:

```text
metadata.json
candidate.dsl.json
simulator_summary.json
nca_summary.json
art2_prototypes.json
artmap_transitions.json
pattern_dynamics.json
perturbation_summary.json
mechanism_report.md
```

### Batch 10 and 11

Use the annex to bias search templates and scoring toward mechanism evidence:

```text
NCA agreement/disagreement
ART2 prototype quality
ARTMAP transition consistency
prototype-to-DSL recoverability
perturbation-response evidence
mechanism-discrimination value
experimental-design usefulness
```

Do not reduce scoring to final image or texture similarity.

### Batch 13

Use the annex when RunPod dry-run manifests, checkpoint policy, result-return policy, or remote-run status artifacts are generated. Remote outputs should return mechanism evidence references, not uncontrolled output dumps.

### Batch 18

Use the annex when the Agentfield hardening batch creates NCA-ART bridge stubs or artifact/status mappings. Agentfield should map stable artifact references and stage results; it should not own hidden science internals.

## Stop condition language for batch-generation chats

For Batch 06, 07, or 08, if the annex is missing, respond:

```text
Missing required annex for this Layer 3 NCA/ART science batch:
- SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md

Please upload it before I generate the Codex batch package, because this batch must preserve the NCA local-rule, ART2 prototype, ARTMAP transition, mechanism-discrimination, and Agentfield/RunPod handoff direction.
```

For Batch 09, 10, 11, 12, 13, or 18, if the annex is missing, respond:

```text
Recommended annex is missing:
- SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md

This annex is not strictly required for this batch, but it helps preserve the NCA/ART core architecture and mechanism-evidence contract. Upload it if available; otherwise confirm I should proceed without it.
```

For organ batches R02, R03, R04, or R05, if the annex is missing, respond:

```text
Missing required annex for this real-organ NCA/ART batch:
- SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md

Please upload it before I generate the Codex organ batch package, because this organ must preserve the NCA/ART evidence contracts established by the skeleton architecture.
```

## Interaction with the spectral/operator hook

This hook is complementary to:

```text
BATCH_CREATION_ANX01_spectral_operator_dsl_bridge.md
```

Use both hooks when both are available. The spectral/operator hook preserves the Turing/spectral/mechanism-discrimination direction. This ART/NCA hook preserves the local-rule, prototype, transition, artifact, orchestration, and real-organ replacement direction.

## Guardrail

This hook does not change the skeleton batch slicing. The corrected 01-24 batch plan remains the slicing authority. The full Layer 3 SPEC annex remains the detailed source; this hook only decides when and how future batch-generation chats should ask for and consume that annex.
