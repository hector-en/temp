# 4 Operator Config Integration — Track Split

This folder is for after-the-fact config integration. It does not contain a runnable config batch by itself.

Use one track depending on the completed evidence source:

```text
skeleton_track/  -> completed skeleton batches
organ_track/     -> completed real-organ transition batches
```

## Mental model

```text
1. Run skeleton/organ batch as researchscientist.
2. Codex writes postlog/dev-recordings to /mnt/egress/...
3. Companion generator writes COMPANION.md to /mnt/ingress/infra/...
4. ChatGPT planner creates INTEGRATION_MANIFEST.md from evidence.
5. ChatGPT planner generates one config-integration Codex batch.
6. Run that generated batch as vmuser/operator.
```

Do not create config steps directly from roadmap names. Integrate only from completed batch evidence.

## What ChatGPT creates

ChatGPT, acting as the higher-reasoning planner, consumes completed evidence and creates:

```text
INTEGRATION_MANIFEST.md
config-integration Codex batch zip
```

The generated config-integration batch zip should contain its own concrete execution files:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

These files are generated later from the manifest. They are not fixed source files in this folder.

## Required evidence to give ChatGPT

For each skeleton or organ batch you want integrated, provide:

```text
POSTCHECK.md or filled postcheck log
INTEGRATION_REQUEST.md
COMPANION.md, if already generated
dev-recording files or folder summary, if available
CONFIG_TOOL.md or current config-tool code analysis
target role/operator context
```

If any required file is missing, the planner must stop, list the exact missing file, say whether it is required or optional, and ask only for the missing required files. It must not guess integration from roadmap names alone.

## What the manifest records

The manifest collects the stable facts that config should expose later:

```text
batch number
created folders
created scripts
created Python modules
needed packages
needed env vars
smoke commands
outputs written
health checks
role owner
whether command is skeleton, dry-run, or real organ
```

## What the operator/config batch may add

The generated Codex batch may add controlled platform hooks such as:

```text
config workflow step
lv Python environment/profile
role alias
health check
bootstrap/install hook
status command
dry-run launcher
mount/output validation
```

It may update config files only inside that generated SPEC scope, for example:

```text
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh/...
/home/vmuser/.local/bin/config.sh only if truly needed
lv profiles
role workflow files
step registries
aliases
health checks
```

## How to run the final integration

After ChatGPT creates `INTEGRATION_MANIFEST.md` and a generated config-integration Codex batch zip:

```text
1. Log in or operate as vmuser/operator.
2. Unpack the generated config-integration batch zip.
3. Read CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md.
4. Verify INTEGRATION_MANIFEST.md is present or embedded/quoted in PROJECT_CACHE.md.
5. Verify referenced INTEGRATION_REQUEST.md evidence is present or quoted.
6. Run only the explicit tasks in RUN_INSTRUCTIONS.md.
7. Modify only files named by SPEC.md.
8. Run the safe validation/status commands named by RUN_INSTRUCTIONS.md.
9. Fill POSTCHECK_TEMPLATE.md or write the requested postcheck log.
10. Do not run broad bootstrap/install/mount/pull/push/account mutation unless SPEC explicitly scopes it.
```

If the generated batch cannot verify its manifest or source evidence, it must stop before editing config.

## Track files

```text
skeleton_track/01_CHATGPT_INTEGRATION_PLANNER.md
skeleton_track/02_CODEX_OPERATOR_EXECUTION.md
organ_track/01_CHATGPT_INTEGRATION_PLANNER.md
organ_track/02_CODEX_OPERATOR_EXECUTION.md
INTEGRATION_REQUEST_TEMPLATE.md
INTEGRATION_MANIFEST_TEMPLATE.md
```
