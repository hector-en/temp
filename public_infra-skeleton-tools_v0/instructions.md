# Infra-Skeleton v0 Webchat / CLI / Codex Instructions

Use this file as the starter instruction for a new ChatGPT workflow after the public `infractl` tool has been pushed to GitHub.

## 0. Core rule

Keep the public reusable tool and the private project data separate.

Public tool:

```text
infra-skeleton-tools_real_v0/
  infractl/
    cli.py
    project.py
    render.py
    pack.py
    evidence.py
    profiles.py
  schemas/
  templates/
  examples/
  README.md
```

Private project bundle:

```text
agentfield-grn-private_real_v0/
  project.yaml
  layers.yaml
  batches.yaml
  hooks.yaml
  files.yaml
  sources/
    implementation/
    implementation/HOOKS/
    specifications/
    specifications/annex/
    workflow/
    source_inventory/
  evidence_snapshots/
  generated/
```

Never push the private project bundle to a public repository.

## 1. New-chat starting workflow

When starting a new chat, do this:

1. Read the public tool repo:

```text
https://github.com/hector-en/temp/tree/main/infra-skeleton-tools_real_v0
```

2. Confirm that the public CLI files are accessible, especially:

```text
infractl/cli.py
infractl/project.py
infractl/render.py
infractl/pack.py
infractl/evidence.py
infractl/profiles.py
schemas/README.md
templates/README.md
README.md
```

3. Ask the user to upload the private bundle zip:

```text
agentfield-grn-private_real_v0_bundle.zip
```

4. Unpack or stage the private bundle under:

```text
/mnt/data/agentfield-grn-private_real_v0
```

5. Validate that the private bundle contains:

```text
project.yaml
layers.yaml
batches.yaml
hooks.yaml
files.yaml
sources/
evidence_snapshots/
generated/
```

6. Run only deterministic `webchat-sandbox` commands inside ChatGPT.

7. Write generated artifacts under:

```text
/mnt/data/generated_real_v0
```

8. Do not treat extra uploaded sources as authoritative until routed through:

```text
EXTRA_SOURCE_ROUTING.md
```

## 1A. Required workflow direction gate

Before running any `infractl request-create`, `infractl request-update`, `infractl package-codex-create`, or `infractl package-codex-update` command, ask the user for a `WORKFLOW_DIRECTION` block.

Required format:

```text
WORKFLOW_DIRECTION:
  mode: request-create | request-update | package-codex-create | package-codex-update | check-evidence | status
  track: skeleton | organ
  batch: <batch-id>
  topic: <short-topic-slug>
  evidence_required: yes | no
  extra_sources: none | <list of uploaded filenames or paths>
```

Do not infer the direction from the uploaded bundle.

Safe validation commands may run before this block is provided:

```bash
python -m infractl.cli profiles
python -m infractl.cli list-batches --project <PRIVATE_PROJECT>
python -m infractl.cli list-hooks --project <PRIVATE_PROJECT>
python -m infractl.cli check-required-files --project <PRIVATE_PROJECT>
python -m infractl.cli status --project <PRIVATE_PROJECT>
```

Do not run request, update, or packaging commands until the user has provided `WORKFLOW_DIRECTION`.

## 1B. Missing evidence stop rule

If `WORKFLOW_DIRECTION.evidence_required` is `yes`, check the expected evidence snapshot before generating any request/update pack.

If any expected evidence is missing, stop and ask the user to upload the missing files or explicitly confirm continuing without evidence.

For a skeleton update, expected evidence is usually:

```text
evidence_snapshots/skeleton/<batch-slug>/POSTCHECK.md
evidence_snapshots/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
evidence_snapshots/skeleton/<batch-slug>/SMOKE_REPORT.md
```

For an organ update, expected evidence is usually:

```text
evidence_snapshots/organ/<batch-slug>/POSTCHECK.md
evidence_snapshots/organ/<batch-slug>/INTEGRATION_REQUEST.md
evidence_snapshots/organ/<batch-slug>/SMOKE_REPORT.md
```

The assistant must not silently continue when `evidence_required=yes` and evidence is missing.

## 2. Supported v0 profiles

The CLI supports four profiles:

```text
webchat-sandbox
cli-dry-run
codex-pack
workspace
```

### webchat-sandbox

Use inside ChatGPT's container.

Rules:

```text
- read public CLI files and private bundle files
- write generated request packs under /mnt/data
- do not write to /workspace
- do not write to /mnt/egress
- do not run smoke
- do not execute Codex
- do not call APIs
```

### cli-dry-run

Use locally on the user's machine for safe preview.

Rules:

```text
- read the local private project bundle
- write generated packs under the selected output folder
- do not mutate the real implementation workspace
- do not run smoke
- do not execute Codex
```

### codex-pack

Use when packaging ChatGPT-produced files into a Codex-ready zip.

Rules:

```text
- validate required Codex pack files
- package create/update packs
- do not implement the batch
- do not run smoke
```

### workspace

Use inside the user's real workspace or Codex environment.

Rules:

```text
- validate the real repo layout using files.yaml
- use the real repo root supplied by the user
- do not edit private source documents unless explicitly instructed
- do not write to /mnt/egress unless the current Codex pack explicitly says so
- do not run smoke unless the current Codex pack explicitly says so
```

## 3. Supported v0 commands

The public CLI should support:

```text
profiles
list-batches
list-hooks
explain-batch
check-required-files
validate-real-layout
request-create
request-update
package-codex-create
package-codex-update
check-evidence
status
```

## 4. Batch scope for v0

v0 is active for:

```text
Skeleton Batch 01
Skeleton Batch 02
Skeleton Batch 03
Skeleton Batch 04
```

v0 is organ-aware but only scaffolded for:

```text
Organ R01
```

Do not attempt full organ execution yet.

## 5. Manual workflow replacement strategy

The old manual workflow was:

```text
1. User uploads many source files manually.
2. ChatGPT decides which files belong to the current batch/update.
3. ChatGPT creates batch or update artifacts.
4. User downloads artifacts and gives them to Codex.
5. Codex executes the batch/update.
6. User later returns evidence and companion files manually.
```

The v0 replacement workflow is:

```text
1. Public infractl is read from GitHub.
2. User uploads private project bundle zip.
3. infractl validates the private bundle.
4. infractl creates a request pack with manifests and selected context.
5. ChatGPT uses the request pack to produce Codex create/update files.
6. infractl packages those files into a Codex pack.
7. Codex executes the Codex pack in the real workspace.
8. Evidence is later checked through snapshots or workspace validation.
```

The CLI replaces repetitive deterministic tasks only. ChatGPT still performs reasoning, classification, and writing.

## 6. Request-create flow

Use `request-create` for a not-yet-run skeleton batch.

Example:

Only run the following `request-create` command after the user has provided a matching `WORKFLOW_DIRECTION`.

```bash
cd /mnt/data/infra-skeleton-tools_real_v0

python -m infractl.cli request-create \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --track skeleton \
  --batch 02 \
  --topic manual_workflow_batch02 \
  --profile webchat-sandbox \
  --out /mnt/data/generated_real_v0
```

Expected request folder outputs:

```text
CHATGPT_REQUEST.md
REQUIRED_INPUTS.md
SELECTED_CONTEXT_MANIFEST.md
EXTRA_SOURCE_ROUTING.md
CLI_EXTRACTION_REMINDER.md
manifest.json
source_bundle.zip
```

## 7. Request-update flow

Use `request-update` for already-run batches or retroactive corrections.

Example:

Only run the following `request-update` command after the user has provided a matching `WORKFLOW_DIRECTION`.

```bash
cd /mnt/data/infra-skeleton-tools_real_v0

python -m infractl.cli request-update \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --track skeleton \
  --batch 01 \
  --topic workflow_smoke_automation \
  --profile webchat-sandbox \
  --out /mnt/data/generated_real_v0
```

Expected request folder outputs:

```text
CHATGPT_REQUEST.md
REQUIRED_INPUTS.md
SELECTED_CONTEXT_MANIFEST.md
EXISTING_EVIDENCE_CHECK.md
EXTRA_SOURCE_ROUTING.md
CLI_EXTRACTION_REMINDER.md
manifest.json
source_bundle.zip
```

Update rules:

```text
- do not overwrite original POSTCHECK.md
- do not overwrite original INTEGRATION_REQUEST.md
- do not pretend to rerun the original batch
- write update evidence under an updates/<update-id>/ path when Codex later executes
```

## 8. Extra source handling

Only use:

```bash
--extra-source PATH
```

Do not use `--extra-mode`.

Every extra source is candidate context only.

The generated request pack must include:

```text
EXTRA_SOURCE_ROUTING.md
```

ChatGPT must classify whether the extra source should:

```text
- update the selected batch
- create/update a SPEC annex
- create/update a hook
- update future batch creation
- update already-run batches
- be ignored as irrelevant or outdated
- require more files before continuing
```

No extra source is authoritative by default.

## 9. Packaging ChatGPT outputs for Codex

Creation packs require exactly:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

Package command:

```bash
python -m infractl.cli package-codex-create \
  --input /path/to/chatgpt_create_outputs \
  --out /path/to/generated
```

Update packs require exactly:

```text
CODEX_UPDATE_PROMPT.txt
PROJECT_UPDATE_CACHE.md
UPDATE_SPEC.md
UPDATE_RUN_INSTRUCTIONS.md
UPDATE_POSTCHECK_TEMPLATE.md
```

Package command:

```bash
python -m infractl.cli package-codex-update \
  --input /path/to/chatgpt_update_outputs \
  --out /path/to/generated
```

## 10. Workspace/Codex setup

Recommended real workspace placement:

```text
/workspace/repos/infra-skeleton-tools_real_v0
/workspace/private/agentfield-grn-private_real_v0
```

Run from the public tool folder:

```bash
cd /workspace/repos/infra-skeleton-tools_real_v0

python -m infractl.cli list-batches \
  --project /workspace/private/agentfield-grn-private_real_v0

python -m infractl.cli list-hooks \
  --project /workspace/private/agentfield-grn-private_real_v0

python -m infractl.cli check-required-files \
  --project /workspace/private/agentfield-grn-private_real_v0
```

Validate real layout:

```bash
python -m infractl.cli validate-real-layout \
  --project /workspace/private/agentfield-grn-private_real_v0 \
  --repo-root /mnt/ingress
```

The `--repo-root` value must point to the parent folder that contains the real private `infra/` directory. For this project, use `/mnt/ingress`, because the private Infra-Skeleton planning/control tree lives at `/mnt/ingress/infra`. Keep `/workspace` free for implementation repos, experiments, runs, artifacts, and generated working code.

## 11. Private bundle real-path mapping

The private bundle should use `files.yaml` to map portable source names to real repo paths.

Important real-path families:

```text
infra/plans/implementation/
infra/plans/implementation/HOOKS/
infra/plans/specifications/
infra/plans/specifications/annex/
infra/plans/workflow/
infra/batches/skeleton/01-runtime-substrate/
infra/skeleton/1_chatgpt_batch_creation/
infra/organs/1_chatgpt_batch_creation/
infra/skeleton/companion/
```

The webchat bundle may carry copied fallback files under `sources/`, but the workspace profile should validate against the real repo paths.

## 12. CLI_EXTRACTION_NOTES.md rule

Until after Skeleton Batch 04, every request pack should include a reminder to update:

```text
CLI_EXTRACTION_NOTES.md
```

Use this one-liner:

```text
At the end, update `CLI_EXTRACTION_NOTES.md` with only the reusable patterns from this batch/update run that should inform a future `infractl` CLI.
```

After Batch 04, use those notes to design v1/v2 updates through `NEW_CHAT_PROMPT_update_infra.md`.

## 13. What v0 must not do

v0 must not:

```text
- call OpenAI or any other LLM API
- execute Codex
- run smoke automatically
- mutate /workspace in webchat-sandbox or cli-dry-run
- write to /mnt/egress in webchat-sandbox or cli-dry-run
- edit config internals
- treat extra sources as authoritative by default
- flatten the private repo into the public tool
- publish private SPECs, annexes, prompts, or evidence
```


## 14. Infra/tool update line

Use `NEW_CHAT_PROMPT_update_infra.md` when the goal is to update the public `infractl` tool, the private bundle format, or both.

This update line is for producing future versions such as:

```text
infra-skeleton-tools_real_v1.zip
agentfield-grn-private_real_v1_bundle.zip
infra-skeleton-tools_real_v2.zip
agentfield-grn-private_real_v2_bundle.zip
```

Inputs it should ask for:

```text
- public infractl repo URL or current public tool zip
- current private bundle zip
- fresh private codebase analysis of /mnt/ingress/infra
- CLI_EXTRACTION_NOTES.md
- current instructions.md
- any newly created NEW_CHAT_PROMPT_*.md files
```

The first output should be a delta plan, not immediate files:

```text
- public CLI changes
- private bundle changes
- files.yaml mapping changes
- new commands or flags
- what stays private
- what can be pushed publicly
- migration steps from the previous version
```

Only after the delta plan is confirmed should ChatGPT generate the updated public/private zips.

Recommended starter prompt for this line:

```text
Follow `NEW_CHAT_PROMPT_update_infra.md`. Read the public infractl repo, then use my uploaded private codebase analysis, current private bundle, current instructions.md, and CLI_EXTRACTION_NOTES.md to create a delta plan first for the next public/private Infra-Skeleton tool version. Do not generate files until the delta plan is confirmed.
```

## 15. New-chat starter prompt

Use this prompt in future chats:

```text
Read the public `infractl` tool from https://github.com/hector-en/temp/tree/main/infra-skeleton-tools_real_v0, then ask me for my private `agentfield-grn-private_real_v0` bundle zip, validate both, and ask me for a `WORKFLOW_DIRECTION` block before running any request/update or packaging command. If required files or evidence snapshots are missing, stop and ask me to upload them or explicitly confirm continuing without them. Run only deterministic commands in `webchat-sandbox` mode, do not treat extra sources as authoritative until routed through `EXTRA_SOURCE_ROUTING.md`, and keep `CLI_EXTRACTION_NOTES.md` active until Skeleton Batch 04.
```
