# BATCH_CREATION_ANX01_spectral_operator_dsl_bridge

Status: batch-creation hook for `NEW_CHAT_PROMPT_batch_creation.md`.  
Purpose: make the Layer 3 spectral/operator DSL annex consumable by future skeleton batch-generation chats.

## Canonical annex file to request

When the selected batch needs this context, ask the user to upload:

```text
SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md
```

This file is a batch-aligned annex for Layer 3 / Batch 06. It records the bridge between typed DSL mechanisms, spectral/operator analysis, Hiscock/Megason-style mechanism discrimination, and the Turing-pattern equations:

```math
a_k(t)=e^{-Dk^2t}a_k(0)
```

and

```math
\partial_t a_n = \left(J_f(u^*) - \lambda_nD\right)a_n.
```

## Batch request rule

Use this table during skeleton batch creation:

| Selected batch | Ask user to supply the annex? | Batch-creation behavior |
|---:|---|---|
| 06 `06-nca-art-base` | yes, required | Stop and ask for the annex if missing. |
| 07 `07-dummy-science-organs` | yes, required | Stop and ask for the annex if missing. |
| 08 `08-mechanism-reporting` | yes, required | Stop and ask for the annex if missing. |
| 09 `09-local-smoke` | yes, optional/strong | Ask for it; continue only if user confirms it is unavailable. |
| 10 `10-search-templates` | yes, optional/strong | Ask for it when search templates should include mechanism-evidence fields. |
| 11 `11-search-scoring` | yes, optional/strong | Ask for it when scoring must reward spectral, dispersion, perturbation, or falsification evidence. |
| 12 `12-search-smoke` | yes, optional | Ask only if the smoke output should include spectral/search-evidence placeholders. |
| other skeleton batches | no | Do not ask unless the user explicitly wants Layer 3 DSL/science context. |

Real-organ mirror rule:

| Organ batch | Ask user to supply the annex? | Behavior |
|---:|---|---|
| R02 `real-grn-dsl-simulator` | yes, required | Needed to replace DSL/simulator placeholders with deterministic first-pass real internals. |
| R05 `real-mechanism-report` | yes, required | Needed to turn report placeholders into evidence-based mechanism-discrimination reports. |
| R04 `real-art2-artmap` | yes, optional/strong | Useful for linking prototype/transition evidence back to DSL/spectral outputs. |

## How generated batch files should consume it

### Batch 06

Add the annex to `PROJECT_CACHE.md` as a required read-only input. The generated `SPEC.md` should include:

```text
This batch must only create schema/base surfaces for `prepare_dsl_candidate_runtime` and `prepare_mechanism_hypothesis_runtime`.
It should encode spectral/operator placeholders and mechanism-hypothesis fields, but must not run simulation or compute real dispersion relations.
```

### Batch 07

Use the annex to require deterministic dummy outputs for:

```text
mode_growth_summary
laplacian_mode_placeholders
dominant_wavelength_placeholder
dispersion_relation_placeholder
interaction_kernel_family_placeholder
perturbation_signature_placeholder
```

Do not claim real biology or real mechanism discovery.

### Batch 08

Use the annex to require mechanism reports to include:

```text
Final pattern is not sufficient evidence
Mechanism hypothesis
Spectral / mode-growth evidence
Dynamics evidence
Perturbation prediction
Parameter or kernel constraint
Experimental design suggestion
Falsification criterion
```

### Batch 10 and 11

Use the annex to bias search templates and scoring toward mechanism evidence:

```text
mode-growth consistency
wavelength / selected mode plausibility
parameter-constraint consistency
perturbation-response evidence
DSL recoverability
falsification value
```

Do not reduce scoring to final image similarity.

## Stop condition language for batch-generation chats

For Batch 06, 07, or 08, if the annex is missing, respond:

```text
Missing required annex for this Layer 3 science batch:
- SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md

Please upload it before I generate the Codex batch package, because this batch must preserve the spectral/operator DSL bridge and Hiscock/Megason mechanism-discrimination direction.
```

For Batch 09, 10, 11, or 12, if the annex is missing, respond:

```text
Recommended annex is missing:
- SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md

This annex is not strictly required for this batch, but it helps preserve the spectral/operator DSL and mechanism-evidence scoring direction. Upload it if available; otherwise confirm I should proceed without it.
```

## Guardrail

This hook does not change the skeleton batch slicing. The corrected 01-24 batch plan remains the slicing authority. The annex is contextual implementation guidance for selected Layer 3 science batches only.
