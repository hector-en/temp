# General New-Chat Prompt — Generate One Skeleton-Dummy Codex Batch

Use this prompt in a fresh chat when you want to generate one actual skeleton-dummy Codex implementation batch from the shared planning files.

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
9. Latest relevant file(s) from `/mnt/egress/dev-recordings`, if available and useful for continuity
10. Latest relevant companion doc(s) from `/mnt/ingress/infra/skeleton/companion`, if available and useful for continuity
11. `config_platform_integration_bridge_plan.md` and/or `INTEGRATION_REQUEST_TEMPLATE.md`, if available and useful for preserving the posthoc integration-request pattern

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
