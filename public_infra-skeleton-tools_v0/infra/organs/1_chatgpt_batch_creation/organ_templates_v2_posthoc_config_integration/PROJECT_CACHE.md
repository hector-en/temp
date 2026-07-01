# PROJECT_CACHE — Transition-to-Real-Organs Batch Cache

Use this as the cache-stable context for one transition batch. Do not reread the whole master unless instructed.

## Batch identity

- Batch id: `<BATCH_ID>`
- Layer: `<LAYER_NAME>`
- Bundle(s): `<BUNDLE_NUMBERS_AND_NAMES>`
- Skeleton step(s) being upgraded: `<STEP_NAMES>`
- Transition master rows: `<TRANSITION_ROWS>`
- Skeleton master file: `<SKELETON_MASTER_FILE_PATH>`
- Transition master file: `<TRANSITION_MASTER_FILE_PATH>`
- Mode: `transition-to-real-organs`

## Current goal

Replace dummy internals with real implementation while preserving the skeleton contract.

The transition must keep:

```text
same command names
same import paths
same config filenames
same output filenames
same status/artifact schemas
same run directories
same dry-run defaults
```

## Contract preservation rule

Before changing code, identify:

```text
current skeleton command
current dummy inputs
current dummy outputs
current downstream consumers
real replacement behavior
compatibility tests
```

Do not break downstream consumers.

## Config tool boundary

The config tool is a dependency, not the target.

Allowed when needed:

```text
config --target USER config-show
config --target USER bootstrap steps
sudo config --target USER bootstrap status
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

Read `CONFIG_TOOL.md` only if target-role/config/lv behavior is needed.

## Posthoc config integration bridge

Do not decide final config/lv/workflow integration inside a real-organ batch.

If this batch creates a real command, package need, workspace root, health check, launcher, or guarded live boundary that may need platform exposure later, record it in:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

That file is a later operator/config handoff only. It should describe the real contract now known from implementation: role owner, stable paths, commands, packages/envs, smoke checks, safety gates, suggested integration type, and open questions. If no config/platform exposure is needed, say `suggested integration type: none`.

## External implementation help map

Use these notes whenever a transition needs real external integration:

```text
Runpod:
  Needed for real pod/job submission, endpoint creation, result pulling, checkpoint resume, GPU cost guards.
  Ask Runpod AI/dev chat or use official Runpod docs before live implementation.

Agentfield:
  Needed for real Agentfield SDK/controller/API semantics beyond the local POC.
  Ask the Agentfield developer or inspect Agentfield GitHub/developer docs.

Paperclip:
  Needed for real job submission, database writes, dashboard cards, review action persistence.
  Inspect Paperclip repo/API docs before writing live integration.

OpenClaw:
  Needed for real agent execution, PKM indexing, tool invocation, and vault-safe workflows.
  Inspect OpenClaw docs/repo before live agent calls.
```

## Safety defaults

- Dry-run first.
- Live execution must require explicit flag.
- No secrets in logs.
- No auto-approve of science or expensive jobs until explicit human gate exists.
- Real science must not claim success from final pattern similarity alone.
