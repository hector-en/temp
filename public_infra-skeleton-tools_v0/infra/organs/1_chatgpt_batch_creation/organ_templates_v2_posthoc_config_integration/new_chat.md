# General New-Chat Prompt — Generate One Transition-to-Real-Organs Codex Batch

Use this prompt in a fresh chat when you want to generate one actual **transition-to-real-organs** Codex implementation batch from the shared planning files.

This prompt is reusable: paste it into a new chat, upload the project context files, set `BATCH_NUMBER`, and ask for one batch only.

## Files I will upload to the new chat

The project directory / uploaded context contains these required files:

```text
00_transition_to_real_organs_master.md
CONFIG_TOOL.md
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
transition_real_organs_codex_batch_plan.md
skeleton_dummy_codex_batch_plan.md
```

If your real-organ batch plan has a different filename, upload it and replace `skeleton_dummy_codex_batch_plan.md` in this prompt with that exact filename before running.

Optional trajectory context, if available:

```text
- latest dev-recordings summary
- latest organ companion guide
- latest skeleton companion docs
- latest implemented skeleton batch zips or postchecks
```

Do **not** require `CODEX_RECORDING_INSTRUCTIONS.md` or `COMPANION_GENERATOR_INSTRUCTIONS.md` for batch creation. The generated batch should still tell Codex where to write postcheck/run recordings, but the separate recording-instructions file is not needed to generate the batch zip.

## Optional latest-run trajectory context

If I provide current run results or companion docs, use them only to keep the next batch aligned with the latest implementation trajectory.

Preferred locations if the files are accessible in the new chat/runtime:

```text
Last Codex run recordings / postcheck evidence:
/mnt/egress/organs/dev-recordings

Current readable organ companion docs:
/mnt/ingress/infra/organs/companion
```

Use the latest relevant postcheck/recording and companion material to understand what the skeleton batch actually created, what was skipped, what paths/contracts were chosen, and what must be preserved during the real-organ transition. Do not require these folders for first real-organ batch generation. If they are unavailable, say so briefly and proceed using the master file and batch plan.

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

Create the actual **transition-to-real-organs** Codex batch zip for `BATCH_NUMBER` from the batch plan, using the transition-to-real-organs template files.

Each generated batch must contain exactly these files:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

Create:

```text
codex_organs_batch_<BATCH_NUMBER>_<slug>.zip
codex_organs_batch_<BATCH_NUMBER>_<slug>/CODEX_PROMPT.txt
codex_organs_batch_<BATCH_NUMBER>_<slug>/PROJECT_CACHE.md
codex_organs_batch_<BATCH_NUMBER>_<slug>/SPEC.md
codex_organs_batch_<BATCH_NUMBER>_<slug>/RUN_INSTRUCTIONS.md
codex_organs_batch_<BATCH_NUMBER>_<slug>/POSTCHECK_TEMPLATE.md
```

Also create or update one compact index zip for the generated batch:

```text
codex_organs_batch_<BATCH_NUMBER>_index.zip
```

The index zip should contain a small index markdown file that names the batch, the scope, generated files, expected workspace root, recording root, companion-doc root, skeleton contracts to preserve, real-organ transition targets, and hard guardrails.

## Mandatory read order

Read the files in this order:

1. batch plan file, usually `skeleton_dummy_codex_batch_plan.md` unless a real-organ batch plan is uploaded
2. `00_transition_to_real_organs_master.md`
3. `CODEX_PROMPT.txt`
4. `PROJECT_CACHE.md`
5. `SPEC.md`
6. `RUN_INSTRUCTIONS.md`
7. `POSTCHECK_TEMPLATE.md`
8. `CONFIG_TOOL.md` only if the selected batch needs config/lv/role context
9. Latest relevant file(s) from `/mnt/egress/organs/dev-recordings`, if available and useful for continuity
10. Latest relevant companion doc(s) from `/mnt/ingress/infra/organs/companion`, if available and useful for continuity

Stop and report exactly which file is missing if any required file is not present.

Do not stop just because optional trajectory folders or optional companion instructions are absent.

## Batch extraction rule

From the batch plan, identify only the row/section for `BATCH_NUMBER`.

Use only that batch's scope for the generated files. Do not generate neighboring batches. Do not merge scopes.

Keep `PROJECT_CACHE.md` compact and limited to the selected batch. It should include:

```text
- selected batch number and slug
- layer/bundle scope
- target workspace roots
- what the matching skeleton batch produced, if known from dev-recordings/companion context
- skeleton commands/contracts that must be preserved
- exact non-goals
- relevant real-organ commands/contracts
- expected real outputs
- files/directories Codex may create or modify
- files/directories Codex must not touch
- config-tool read-only note if relevant
```

Do not paste the full master file into `PROJECT_CACHE.md`.

## Canonical roots

Use these roots unless the selected batch SPEC explicitly overrides them:

```text
Project workspace / code root:
/home/researchscientist/workspace

Codex run recordings / postcheck evidence:
/mnt/egress/organs/dev-recordings

Normal readable organ companion docs:
/mnt/ingress/infra/organs/companion
```

Batch working folders should preserve the skeleton folder layout and replace internals progressively:

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

If the real-organ batch introduces source packages under project repos, keep them under `/home/researchscientist/workspace` and preserve the existing skeleton CLIs, fixtures, and output contracts unless the selected batch explicitly says otherwise.

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

The config tool is a dependency/interface, not an implementation target.

## Posthoc config integration bridge

Every generated real-organ batch must tell Codex to create or update:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

This file is not a config patch. It records what a later operator/vmuser config-integration batch may need to expose after the organ exists: workspace root, commands, packages, smoke checks, output contracts, suggested integration type, safety boundaries, and open questions. If no integration is needed, the request should say `suggested integration type: none`.

The generated batch must not decide final config bootstrap step names, lv profile names, role aliases, workflow entries, or health checks from roadmap names alone.

## Transition-to-real-organs behavior

The selected batch is a **transition-to-real-organs** implementation batch. It must replace a bounded dummy/stub organ with a real first-pass implementation while preserving the skeleton's public commands and output contracts.

Real-organ means:

```text
- keep the existing skeleton batch folder and interfaces stable
- replace deterministic dummy internals with real local logic
- preserve dry-run/live separation
- preserve human review gates
- write small, inspectable outputs
- add tests/smoke checks that prove real behavior without unsafe side effects
```

Do not launch real Runpod jobs, run real OpenClaw agents over private notes, write live Paperclip/Agentfield submissions, call real remote models, or start expensive model training unless the selected batch explicitly marks that behavior as safe and approved.

When scientific code is involved, do not claim mechanism discovery from final pattern similarity alone. Preserve mechanism evidence requirements: dynamics, perturbation response, NCA agreement where relevant, ART/ARTMAP/prototype behavior, DSL recoverability, falsification criteria, and next-experiment value.

## Output quality requirements

`CODEX_PROMPT.txt` must be short and usable as the prompt pasted to Codex for that batch.

`PROJECT_CACHE.md` must be cache-stable and compact.

`SPEC.md` must include:

```text
- Purpose
- Selected batch scope
- Inputs
- Matching skeleton contracts to preserve
- Prior-batch continuity notes, if available
- Non-goals
- Files/directories to create or modify
- Commands/CLIs to preserve or provide
- Real-organ output contracts
- Validation/smoke tests
- Acceptance criteria
- Guardrails
```

`RUN_INSTRUCTIONS.md` must include:

```text
- Read order
- Current batch only rule
- Task list split into small tasks
- Skeleton contract preservation checks
- Validation commands
- Recording/postcheck requirements
- Expected final response from Codex
```

`POSTCHECK_TEMPLATE.md` must include:

```text
- batch number/name
- changed files
- skeleton contracts preserved
- commands run
- tests passed/failed
- outputs created
- integration request created or marked none
- unresolved gaps
- next recommended batch
```

## Final response required

After generating the batch files, respond with:

```text
Generated organ batch: <BATCH_NUMBER> <slug>
Scope: <short scope>
Files created:
- <zip link>
- <index zip link>
Notes:
- whether latest dev-recordings were used
- whether latest companion docs were used
- any missing optional context
```
