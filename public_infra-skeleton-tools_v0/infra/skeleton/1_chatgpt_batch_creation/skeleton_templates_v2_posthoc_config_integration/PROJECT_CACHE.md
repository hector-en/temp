# PROJECT_CACHE — Skeleton-Dummy Batch Cache

Use this file as the cache-stable context for the current Codex batch. Do not reread the whole master unless instructed.

## Batch identity

- Batch id: `<BATCH_ID>`
- Layer: `<LAYER_NAME>`
- Bundle(s): `<BUNDLE_NUMBERS_AND_NAMES>`
- Step range from master: `<ORDER_START>-<ORDER_END>`
- Master file: `<MASTER_FILE_PATH>`
- Mode: `skeleton-dummy`

## Current goal

Implement a minimal skeleton that preserves the final platform shape while using dummy behavior.

The target outcome is:

```text
folders + schemas + configs + small CLI entrypoints + fake JSON/Markdown outputs + smoke tests
```

not:

```text
real science, real Runpod execution, live Paperclip writes, uncontrolled model calls, or config-tool changes
```

## Repository/path authority

Use these roots unless the SPEC overrides them:

```text
/workspace/repos/nca-art-grn
/workspace/repos/agentfield
/workspace/repos/paperclip-agentfield-adapter
/workspace/repos/openclaw-workspace
/workspace/data
/workspace/runs
/workspace/artifacts
/workspace/models
/workspace/checkpoints
/workspace/pkm/zettelkasten
/workspace/artifacts/papers/grn-paper
```

## Config tool boundary

The config tool is already implemented. It is a dependency, not the implementation target.

Allowed when needed:

```text
config --target USER config-show
config --target USER bootstrap steps
sudo config --target USER bootstrap status
sudo config --target USER bootstrap step <explicit step named by SPEC>
lv
lv conda ENV
```

Forbidden unless SPEC explicitly overrides a named file:

```text
edit /home/vmuser/.local/bin/config.sh
edit /home/vmuser/.local/lib/config-sh/installers.sh
edit /home/vmuser/.local/etc/config-sh/*
run broad config bootstrap/install/mount/pull/push
run account create/remove commands
print credentials or private data
```

If config/lv context is required, read `CONFIG_TOOL.md`; otherwise skip it to save tokens.

## Posthoc config integration bridge

This skeleton batch must not integrate itself into the config platform. It should only leave a compact handoff file for a later operator-side config-integration batch.

If this batch creates commands, package needs, workflow hooks, health checks, aliases, launchers, or role-specific setup that should later be exposed through `config`, `lv`, bootstrap profiles, or role workflows, record that in:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

The integration request is evidence, not config mutation. It should be created alongside the postcheck output and should capture only what the implemented batch actually produced.

Minimum integration request fields:

```text
Role owner: <researchscientist|aiengineer|publisher|operator|mixed>
Workspace root: <actual workspace root used by the batch>
Commands to expose: <safe commands or none>
Python packages needed: <packages or none>
Config integration needed: <workspace root|python env|role workflow|alias|health check|dryrun hook|organ transition|none>
Smoke check: <safe local command or none>
Output contract: <files/directories produced by this batch>
Config files that may later need a dedicated operator-side change: <names only, or none>
```

Do not decide final config step names in this skeleton batch unless SPEC.md explicitly requires a proposed name. The later config-integration track will read `INTEGRATION_REQUEST.md` files and decide whether to add bootstrap steps, `lv` profiles, package groups, role aliases, health checks, or launcher wrappers.

## Skeleton output contract

Dummy science/platform steps should write stable filenames that later real organs will reuse.

Common research dummy outputs:

```text
metadata.json
candidate.dsl.json
pattern_dynamics.json
nca_summary.json
art2_prototypes.json
artmap_transitions.json
perturbation_summary.json
mechanism_report.md
search_report.md
candidate_rankings.json
status.json
```

Common platform dummy outputs:

```text
experiment.yaml
campaign.yaml
stage_results.jsonl
artifact_refs.json
paperclip_review_payload.json
next_experiment_suggestions.md
reasoning_output.md
```

## Non-overwrite rule

Create placeholder files only if missing. Never overwrite user research code, notebooks, notes, manuscript sections, run artifacts, checkpoints, or reports.

## External code/help notes

If real external integration is required, do not guess. Leave a clearly marked stub and note the required source of help:

```text
Runpod code/API needed: ask Runpod AI/dev chat or use official Runpod docs.
Agentfield code/API needed: ask Agentfield developer or use Agentfield GitHub/developer docs.
Paperclip code/API needed: use Paperclip repo/API docs before live database writes.
OpenClaw code/API needed: use OpenClaw repo/docs before running agents.
```
