# NEW_CHAT_PROMPT_batch_creation — Generate One Skeleton-Dummy Codex Batch

Use this prompt in a fresh chat when you want to generate one actual skeleton-dummy Codex implementation batch from the shared planning files.

This is the updated batch-creation prompt formerly named `new_chat.md`. Save or upload this file as `NEW_CHAT_PROMPT_batch_creation.md`.

This prompt is reusable: paste it into a new chat, upload the project context files, set `BATCH_NUMBER`, and ask for one batch only.

## Files I will upload to the new chat

The project directory / uploaded context contains these required files:

```text
00_skeleton_dummy_master_implementation_companion.md
CONFIG_TOOL.md
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
skeleton_dummy_codex_batch_plan.md
```

Optional trajectory context, if available:

```text
   - latest dev-recordings summary
   - latest companion guide
   - config_platform_integration_bridge_plan.md
   - INTEGRATION_REQUEST_TEMPLATE.md
```

Do **not** require `CODEX_RECORDING_INSTRUCTIONS.md` or `COMPANION_GENERATOR_INSTRUCTIONS.md` for batch creation. The generated batch should still tell Codex where to write postcheck/run recordings, but the separate recording-instructions file is not needed to generate the batch zip.

The generated batch should also tell Codex to create a small `INTEGRATION_REQUEST.md` after the implementation run. This request is not a config edit. It is a posthoc bridge file for a later operator/vmuser config-integration batch.

## Optional latest-run trajectory context

If I provide current run results or companion docs, use them only to keep the next batch aligned with the latest implementation trajectory.

Preferred locations if the files are accessible in the new chat/runtime:

```text
Last Codex run recordings / postcheck evidence:
/mnt/egress/dev-recordings

Current readable companion docs:
/mnt/ingress/infra/skeleton/companion
```

Use the latest relevant postcheck/recording and companion material to understand what the previous batch actually created, what was skipped, and what path/contract choices should be preserved. Do not require these folders for first-batch generation. If they are unavailable, say so briefly and proceed using the master file and batch plan.


## Conditional annex inputs for Layer 3 science batches

Some batches require additional batch-aligned ANX context. Do not ask for these annex files for every batch. Ask only when the selected batch needs them.

### Spectral/operator DSL bridge annex

Canonical annex filename:

```text
SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md
```

This annex connects the Layer 3 DSL direction with the Turing-pattern / spectral-operator equations:

```math
a_k(t)=e^{-Dk^2t}a_k(0)
```

and

```math
\partial_t a_n = \left(J_f(u^*) - \lambda_nD\right)a_n.
```

It also records the Hiscock/Megason mechanism-discrimination direction: mode growth, dispersion relations, parameter/kernel constraints, perturbation signatures, and the rule that a final pattern is not sufficient mechanism evidence.

Use this request rule:

| Selected batch | Ask for `SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md`? | Behavior if missing |
|---:|---|---|
| 06 `06-nca-art-base` | yes, required | Stop and ask the user to upload it before generating the batch package. |
| 07 `07-dummy-science-organs` | yes, required | Stop and ask the user to upload it before generating the batch package. |
| 08 `08-mechanism-reporting` | yes, required | Stop and ask the user to upload it before generating the batch package. |
| 09 `09-local-smoke` | yes, optional/strong | Ask for it; continue only if the user confirms it is unavailable. |
| 10 `10-search-templates` | yes, optional/strong | Ask for it if search templates should include spectral/operator mechanism-evidence fields. |
| 11 `11-search-scoring` | yes, optional/strong | Ask for it if scoring should reward dispersion, perturbation, falsification, or DSL-recoverability evidence. |
| 12 `12-search-smoke` | yes, optional | Ask only if the smoke outputs should carry spectral/search-evidence placeholders. |
| other skeleton batches | no | Do not ask unless the user explicitly requests Layer 3 DSL/science context. |

For Batch 06, 07, or 08, use this exact missing-file response:

```text
Missing required annex for this Layer 3 science batch:
- SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md

Please upload it before I generate the Codex batch package, because this batch must preserve the spectral/operator DSL bridge and Hiscock/Megason mechanism-discrimination direction.
```

For Batch 09, 10, 11, or 12, use this exact recommended-file response if the annex is missing:

```text
Recommended annex is missing:
- SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md

This annex is not strictly required for this batch, but it helps preserve the spectral/operator DSL and mechanism-evidence scoring direction. Upload it if available; otherwise confirm I should proceed without it.
```

When the annex is provided, read it after the Layer 3 SPEC and before writing the selected batch files. Put only the selected-batch-relevant points into `PROJECT_CACHE.md`, `SPEC.md`, and `RUN_INSTRUCTIONS.md`; do not paste the full annex.

Real-organ mirror rule for later organ-batch prompts: require the same annex for R02 `real-grn-dsl-simulator` and R05 `real-mechanism-report`, and treat it as strongly recommended for R04 `real-art2-artmap`.

### ART/NCA core architecture annex

Canonical annex filename:

```text
SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md
```

This annex captures the ART/NCA/Agentfield scientific control model for the NCA-ART-GRN research engine. It preserves this intended architecture:

```text
DSL-defined 5-node GRN candidate
-> PDE/ODE forward simulator
-> local trajectory/state capture
-> NCA local-rule / pattern-generator surrogate
-> ART2 prototype discovery
-> ARTMAP transition learning
-> prototype-to-DSL inverse mapping
-> mechanism-discrimination report
-> search / RunPod / Agentfield orchestration later
```

Use this annex to keep the batch package aligned with the ART/NCA implementation direction:

```text
- NCA is a shared local update rule / pattern-generation surrogate, not only an image generator.
- ART2 prototype evidence and ARTMAP transition evidence are first-class mechanism evidence.
- Mechanism reports must separate appearance evidence from formation dynamics, NCA evidence, ART evidence, perturbation evidence, falsification, and DSL recoverability.
- Search/scoring must not optimize only final pattern similarity.
- RunPod and Agentfield stubs must return/map stable evidence artifacts, not uncontrolled images or hidden state dumps.
```

Use this request rule:

| Selected batch | Ask for `SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md`? | Behavior if missing |
|---:|---|---|
| 06 `06-nca-art-base` | yes, required | Stop and ask the user to upload it before generating the batch package. |
| 07 `07-dummy-science-organs` | yes, required | Stop and ask the user to upload it before generating the batch package. |
| 08 `08-mechanism-reporting` | yes, required | Stop and ask the user to upload it before generating the batch package. |
| 09 `09-local-smoke` | yes, recommended | Ask for it; continue only if the user confirms it is unavailable. |
| 10 `10-search-templates` | yes, recommended | Ask for it if search templates should preserve ART/NCA evidence fields. |
| 11 `11-search-scoring` | yes, recommended | Ask for it if scoring should reward NCA agreement, ART2 prototype quality, ARTMAP transition consistency, perturbation response, falsification, or DSL recoverability. |
| 12 `12-search-smoke` | yes, recommended | Ask if smoke outputs should carry the complete ART/NCA mechanism-evidence artifact set. |
| 13 `13-runpod-dryrun` | yes, recommended | Ask if manifests/result-return policy should return ART/NCA mechanism evidence artifacts. |
| 18 `18-agentfield-hardening-stubs` | yes, recommended | Ask if Agentfield bridge/status mappings should consume NCA-ART-GRN artifact refs. |
| other skeleton batches | no | Do not ask unless the user explicitly requests ART/NCA core architecture context. |

For Batch 06, 07, or 08, use this exact missing-file response:

```text
Missing required annex for this Layer 3 ART/NCA science batch:
- SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md

Please upload it before I generate the Codex batch package, because this batch must preserve the ART/NCA core architecture, replaceable science-organ contracts, and mechanism-discrimination direction.
```

For Batch 09, 10, 11, 12, 13, or 18, use this exact recommended-file response if the annex is missing:

```text
Recommended annex is missing:
- SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md

This annex is not strictly required for this batch, but it helps preserve the ART/NCA core architecture, evidence artifact contracts, and downstream Agentfield/RunPod mapping direction. Upload it if available; otherwise confirm I should proceed without it.
```

When this annex is provided, read it after `SPEC_Layer03_research_execution_loops.md` and before writing the selected batch files. Put only the selected-batch-relevant points into `PROJECT_CACHE.md`, `SPEC.md`, and `RUN_INSTRUCTIONS.md`; do not paste the full annex.

Real-organ mirror rule for later organ-batch prompts: require this annex for R02 `real-grn-dsl-simulator`, R03 `real-nca-local-rule`, R04 `real-art2-artmap`, and R05 `real-mechanism-report`; treat it as strongly recommended for R06 `real-parameter-search`, R07 `real-runpod-boundary`, R09 `real-agentfield-experiment`, and R12 `end-to-end-real-local-smoke`.


## Posthoc config integration bridge

This skeleton batch generation is still target-side project work. It must not edit the config tool.

However, every generated batch should instruct Codex to leave behind an implementation bridge file after the run:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

The bridge file records what a later operator/vmuser config-integration batch may need to expose through config/lv/workflows. It should capture actual implemented facts, not guesses:

```text
- role owner
- workspace root
- commands or CLIs to expose
- Python packages or env profile needs
- config integration needed, if any
- smoke checks
- output contracts
- safety boundaries
- whether a real config step is requested, or only an alias/health check/env package change
```

Do not make the skeleton batch modify:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh
```

The later config-integration track decides whether each roadmap step becomes a config bootstrap step, lv profile update, role alias, health check, or stays project-only.


## Batch number to generate

Generate this batch only:

```text
BATCH_NUMBER = <PUT_BATCH_NUMBER_HERE>
```

Examples:

```text
BATCH_NUMBER = 02
BATCH_NUMBER = 13
BATCH_NUMBER = 24
```

## Required task

Read all required files first. Do not continue if any required file is missing or unreadable.

Create the actual skeleton-dummy Codex batch zip for `BATCH_NUMBER` from `skeleton_dummy_codex_batch_plan.md`, using the skeleton-dummy template files.

Each generated batch zip must contain exactly these five instruction/template files:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

The implementation run produced from those instructions should later create run outputs under `/mnt/egress/dev-recordings`, including:

```text
POSTCHECK.md or filled postcheck log
INTEGRATION_REQUEST.md
```

Create:

```text
codex_skeleton_batch_<BATCH_NUMBER>_<slug>.zip
codex_skeleton_batch_<BATCH_NUMBER>_<slug>/CODEX_PROMPT.txt
codex_skeleton_batch_<BATCH_NUMBER>_<slug>/PROJECT_CACHE.md
codex_skeleton_batch_<BATCH_NUMBER>_<slug>/SPEC.md
codex_skeleton_batch_<BATCH_NUMBER>_<slug>/RUN_INSTRUCTIONS.md
codex_skeleton_batch_<BATCH_NUMBER>_<slug>/POSTCHECK_TEMPLATE.md
```

Also create or update one compact index zip for the generated batch:

```text
codex_skeleton_batch_<BATCH_NUMBER>_index.zip
```

The index zip should contain a small index markdown file that names the batch, the scope, generated files, expected workspace root, recording root, companion-doc root, and hard guardrails.

## Mandatory read order

Read the files in this order:

1. `skeleton_dummy_codex_batch_plan.md`
2. `00_skeleton_dummy_master_implementation_companion.md`
3. `CODEX_PROMPT.txt`
4. `PROJECT_CACHE.md`
5. `SPEC.md`
6. `RUN_INSTRUCTIONS.md`
7. `POSTCHECK_TEMPLATE.md`
8. `CONFIG_TOOL.md` only if the selected batch needs config/lv/role context
9. `SPEC_Layer03_research_execution_loops.md` if the selected batch is in Layer 3 or the user supplies layer SPEC context
10. Conditional ANX files required/recommended by the selected batch, especially `SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md` and `SPEC_Layer03_06-nca-art-base-ANX01_art_nca_core_architecture.md` for the Layer 3 and downstream batches named in the annex request tables above
11. Latest relevant file(s) from `/mnt/egress/dev-recordings`, if available and useful for continuity
12. Latest relevant companion doc(s) from `/mnt/ingress/infra/skeleton/companion`, if available and useful for continuity
13. `config_platform_integration_bridge_plan.md` and/or `INTEGRATION_REQUEST_TEMPLATE.md`, if available and useful for preserving the posthoc integration-request pattern

Stop and report exactly which file is missing if any required file is not present.

Do not stop just because optional trajectory folders or optional companion instructions are absent.

## Batch extraction rule

From `skeleton_dummy_codex_batch_plan.md`, identify only the row/section for `BATCH_NUMBER`.

Use only that batch's scope for the generated files. Do not generate neighboring batches. Do not merge scopes.

Keep `PROJECT_CACHE.md` compact and limited to the selected batch. It should include:

```text
- selected batch number and slug
- layer/bundle scope
- target workspace roots
- what the previous batch produced, if known from dev-recordings/companion context
- exact non-goals
- relevant commands/contracts
- expected dummy outputs
- files/directories Codex may create
- files/directories Codex must not touch
- config-tool read-only note if relevant
- posthoc config integration request expectations
- selected-batch-relevant annex notes and required read-only annex files, if the selected batch uses a conditional ANX
```

Do not paste the full master file into `PROJECT_CACHE.md`.

## Canonical roots

Use these roots unless the selected batch SPEC explicitly overrides them:

```text
Project workspace / code root:
/home/researchscientist/workspace

Codex run recordings / postcheck evidence:
/mnt/egress/dev-recordings

Posthoc integration requests written by implemented batches:
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md

Normal readable companion docs:
/mnt/ingress/infra/skeleton/companion
```

Batch working folders should follow this layout:

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

## Hard guardrails for generated batch files

Every generated batch file must clearly say:

```text
Do not modify the config tool.
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh unless this batch explicitly says otherwise.
Use config only for inspection/status/explicit existing step execution.
Do not run broad bootstrap, mount, pull, push, account lifecycle, credentials, Docker build, Kubernetes apply, Runpod job, OpenClaw agent, model training, or live Paperclip/Agentfield submission.
Do not read or print secrets.
Do not write output outside the approved roots.
```

The config tool is a dependency/interface, not an implementation target. Skeleton batches may request later config integration only by writing `INTEGRATION_REQUEST.md`; they must not perform that integration themselves.

## Skeleton-dummy behavior

The selected batch is a skeleton-dummy implementation batch. It must produce safe placeholder code, schemas, fixtures, dry-run commands, and smoke tests only.

Do not implement real science, real Runpod jobs, real OpenClaw agents, real Paperclip writes, real Agentfield live controllers, or real model calls unless the batch plan explicitly marks a stub/dry-run placeholder.

Dummy outputs should be deterministic, small, and inspectable.

## Output quality requirements

`CODEX_PROMPT.txt` must be short and usable as the prompt pasted to Codex for that batch.

`PROJECT_CACHE.md` must be cache-stable and compact.

`SPEC.md` must include:

```text
- Purpose
- Selected batch scope
- Inputs
- Prior-batch continuity notes, if available
- Non-goals
- Files/directories to create
- Commands/CLIs to provide
- Dummy output contracts
- Validation/smoke tests
- Acceptance criteria
- Guardrails
- Conditional annex context, if the selected batch requires or recommends an ANX file
```

`RUN_INSTRUCTIONS.md` must include:

```text
- Read order
- Current batch only rule
- Task list split into small tasks
- Validation commands
- Recording/postcheck requirements
- INTEGRATION_REQUEST.md requirements for later operator/config reintegration
- Expected final response from Codex
```

`POSTCHECK_TEMPLATE.md` must include:

```text
- batch number/name
- changed files
- commands run
- tests passed/failed
- outputs created
- integration request created/updated
- companion docs created or updated
- unresolved gaps
- next recommended batch
```


## Layer 3 spectral/operator annex consumption rules

When `SPEC_Layer03_06-nca-art-base-ANX01_spectral_operator_dsl_bridge.md` is used, generated batch instructions should preserve these roles:

```text
Batch 06:
  Store typed DSL/schema vocabulary and mechanism-hypothesis placeholders.
  Include spectral/operator placeholder fields.
  Do not compute real spectra, run simulations, train NCA, or claim discovery.

Batch 07:
  Produce deterministic dummy simulator, pattern dynamics, interaction-kernel,
  dispersion/mode-growth, wavelength, and perturbation-signature placeholders.
  Do not run large simulations or claim real biological evidence.

Batch 08:
  Require mechanism reports to include final-pattern insufficiency, dynamics,
  spectral/mode evidence, perturbation prediction, parameter/kernel constraints,
  experimental-design suggestion, and falsification criterion.

Batch 10/11:
  Bias templates and scoring toward mechanism evidence, perturbation response,
  DSL recoverability, and falsification value; do not score only image similarity.
```

Keep this annex contextual. It does not override the corrected 01-24 batch slicing, output roots, smoke domains, or safety guardrails.

## Final response required

After generating the batch files, respond with:

```text
Generated batch: <BATCH_NUMBER> <slug>
Scope: <short scope>
Files created:
- <zip link>
- <index zip link>
Notes:
- whether latest dev-recordings were used
- whether latest companion docs were used
- whether config integration bridge context was used
- any missing optional context
```
