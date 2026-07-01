# Organ Track — ChatGPT Integration Planner

Use this with a higher-reasoning ChatGPT model after one or more transition-to-real-organs batches have completed.

## Purpose

Create an `INTEGRATION_MANIFEST.md` from completed organ evidence, then generate small vmuser/operator config-integration batches. Do not guess from roadmap names.

## Required inputs

Provide at least one completed organ batch evidence set:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
or filled postcheck log

/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md

/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md

Codex organ dev-recording notes, if available
CONFIG_TOOL.md or latest config-tool code analysis
Target role/operator context
```

## Missing-file rule

If required evidence is missing:

```text
stop
list exact missing files
classify each missing file as required or optional
ask only for missing required files
do not infer integration from roadmap names alone
```

Optional files may be absent, but say so briefly.

## Facts to collect per organ batch

```text
batch number and slug
role owner
workspace root
created folders
created scripts
created Python modules
needed packages
needed env vars
commands to expose
smoke commands
outputs written
health checks
mount/output validation needs
whether command is dryrun, guarded real, or real organ
live-action boundaries
external blockers
```

## Create integration manifest

Write or update:

```text
INTEGRATION_MANIFEST.md
```

The manifest groups evidence into candidate platform hooks:

```text
config workflow step
lv Python environment/profile
role alias
health check
bootstrap/install hook
status command
dry-run launcher
guarded live launcher
mount/output validation
```

## Generate config-integration batches

From `INTEGRATION_MANIFEST.md`, generate one small vmuser/operator batch at a time.

Each generated config-integration batch contains, created on the fly:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

These are not fixed files in this bridge folder.

## Organ integration phases

```text
config-integration/01-read-organ-integration-requests
config-integration/02-register-workspace-roots
config-integration/03-register-python-env-profiles
config-integration/04-register-researchscientist-real-organ-workflows
config-integration/05-register-runpod-dryrun-hooks
config-integration/06-register-agentfield-paperclip-openclaw-hooks
config-integration/07-register-organ-transition-hooks
config-integration/08-register-platform-health-status-checks
```

## Hard guardrail

```text
organ batch:
  preserves skeleton contract + creates real organ code + postcheck + INTEGRATION_REQUEST.md

companion generator:
  creates readable COMPANION.md

config integration batch:
  reads manifest + integration requests + companion docs, then updates config/lv/workflows
```
