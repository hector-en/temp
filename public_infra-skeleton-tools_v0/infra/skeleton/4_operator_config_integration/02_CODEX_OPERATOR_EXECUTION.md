# Skeleton Track — Codex Operator Execution

Use this only after ChatGPT has generated one concrete config-integration Codex batch from `INTEGRATION_MANIFEST.md`.

## Purpose

Execute one controlled vmuser/operator config integration batch for completed skeleton evidence. Do not infer new scope.

## Required inputs

The generated config-integration batch must contain:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

It must also include or quote:

```text
INTEGRATION_MANIFEST.md slice
source INTEGRATION_REQUEST.md files
source POSTCHECK.md or postcheck logs
source COMPANION.md files
CONFIG_TOOL.md or current config source snapshot
```

## Missing-file rule

Before editing config:

```text
verify generated PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md exist
verify INTEGRATION_MANIFEST.md or a manifest slice exists
verify referenced INTEGRATION_REQUEST.md evidence is present or quoted
stop if evidence is missing or ambiguous
```

## Execution identity

Run as `vmuser` / operator, not `researchscientist`, unless the generated batch explicitly says otherwise.

## Read order

```text
1. CODEX_PROMPT.txt
2. PROJECT_CACHE.md
3. SPEC.md
4. RUN_INSTRUCTIONS.md
5. POSTCHECK_TEMPLATE.md
6. INTEGRATION_MANIFEST.md slice named by SPEC
7. Source INTEGRATION_REQUEST.md files named by SPEC
8. Current config files named by SPEC
```

## Allowed config targets when explicitly scoped

```text
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh/...
/home/vmuser/.local/bin/config.sh only if truly needed and explicitly scoped
lv profiles
role workflow files
step registries
aliases
health checks
```

Prefer additive, narrow changes: wrapper, health check, lv profile entry, role alias, workflow registration, dry-run launcher, or status command.

## What not to do

```text
do not edit project science/skeleton code
do not change skeleton outputs
do not invent missing commands
do not create config steps from roadmap names alone
do not read or print secrets
do not run live GPU, Runpod, Paperclip, Agentfield, OpenClaw, training, or remote jobs unless explicitly human-gated in SPEC
```

## Validation pattern

```bash
bash -n <changed shell file>
config --target researchscientist config-show
config --target researchscientist bootstrap steps
sudo config --target researchscientist bootstrap status
<new alias or wrapper> --help
<new health check> --dry-run
```

## Output to user

```text
Changed files:
Manifest entries consumed:
Config hooks added:
Validation run:
Postcheck path:
Deferred items:
```
