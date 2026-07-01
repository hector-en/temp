# NEW_CHAT_PROMPT_update_infra.md

Purpose: update the public `infractl` tool and the private Infra-Skeleton project bundle from a fresh private codebase analysis, while keeping public code and private project data separated.

Use this prompt when you want to create the next version of the Infra-Skeleton tooling, for example `v1`, `v2`, or a focused patch release.

---

## Start condition

You are updating the Infra-Skeleton infrastructure workflow.

The workflow has two separated parts:

```text
1. Public reusable CLI engine
   infra-skeleton-tools_real_v0 or later

2. Private project workspace bundle
   agentfield-grn-private_real_v0 or later
```

The public CLI must never contain private SPECs, annexes, prompts, evidence, or project-specific batch content.

The private project bundle may contain project maps, `files.yaml`, copied/sanitized source files, codebase-analysis inventories, workflow notes, and evidence snapshots.

---

## Required files to ask me for

Before doing the update, ask me to provide or confirm access to:

```text
1. Public infractl repo or zip
   Preferred: GitHub URL, e.g. https://github.com/hector-en/temp/tree/main/infra-skeleton-tools_real_v0
   Alternative: uploaded infra-skeleton-tools_real_v0.zip

2. Current private project bundle zip
   Example: agentfield-grn-private_real_v0_bundle.zip

3. Fresh private codebase analysis output
   Example: private_<timestamp>_code_analysis_output.txt
   This should represent the real private infra tree, usually under /mnt/ingress/infra.

4. CLI_EXTRACTION_NOTES.md
   Use it to decide which manual patterns are ready to become deterministic CLI behavior.

5. Current instructions.md
   The existing operator-facing workflow instruction file.
```

If any required file is missing or inaccessible, stop and list the exact missing files. Do not invent structure.

## Mandatory direction gate

After the public tool and private bundle are available, do not choose a batch, track, topic, or mode yourself.

Ask the user for:

```text
WORKFLOW_DIRECTION:
  mode: request-create | request-update | package-codex-create | package-codex-update | check-evidence | status
  track: skeleton | organ
  batch: <batch-id>
  topic: <short-topic-slug>
  evidence_required: yes | no
  extra_sources: none | <list of uploaded filenames or paths>
```

If the user has not provided this block, stop after validation and ask for it.

Allowed before `WORKFLOW_DIRECTION`:

```text
- validate zip files
- inspect public CLI layout
- inspect private bundle layout
- run `profiles`
- run `list-batches`
- run `list-hooks`
- run `check-required-files`
- run `status`
```

Not allowed before `WORKFLOW_DIRECTION`:

```text
- `request-create`
- `request-update`
- `package-codex-create`
- `package-codex-update`
- generating update packs
- choosing Batch 01 or any default batch automatically
```

## Missing evidence stop rule

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

---

## Optional files to ask for if relevant

Ask for these only if the requested update needs them:

```text
- generated request packs from the last runs
- latest infractl test logs
- latest evidence snapshots
- latest batch/update Codex packs
- latest companion docs or index files
- latest organ transition files
- any newly created SPEC_Layer*.md or BATCH_*_ANX*.md files
```

---

## Authority order

Use this order when inputs disagree:

```text
1. User instruction in the current chat
2. Fresh private codebase analysis
3. CLI_EXTRACTION_NOTES.md
4. Current private bundle YAML files
5. Current public infractl code
6. Older prompt/workflow files
7. Older generated examples or stale archives
```

Do not overwrite newer private structure with older flat-folder assumptions.

---

## Required first output: delta plan only

Before generating files, produce a compact delta plan with these sections:

```text
1. Public CLI changes
   What changes in infractl code, commands, profiles, schemas, templates, or README.

2. Private bundle changes
   What changes in project.yaml, layers.yaml, batches.yaml, hooks.yaml, files.yaml, sources/, evidence_snapshots/, generated/.

3. Manual workflow replacement
   Which repeated manual steps from CLI_EXTRACTION_NOTES.md become deterministic commands.

4. Batch scope
   Which skeleton/organ batches are active for this version.

5. Privacy boundary
   What must remain private and what may be public.

6. Test commands
   Commands to run inside the ChatGPT webchat container and later inside the real workspace/Codex environment.
```

Do not generate files until the user confirms the delta plan.

---

## Public/private folder target

After confirmation, generate these outputs:

```text
/mnt/data/infra-skeleton-tools_<VERSION>.zip
/mnt/data/agentfield-grn-private_<VERSION>_bundle.zip
/mnt/data/INFRA_UPDATE_<VERSION>_DELTA_PLAN.md
/mnt/data/INFRA_UPDATE_<VERSION>_TEST_LOGS.zip
```

The public zip should contain only reusable CLI/tooling files.

The private bundle zip should contain project-specific YAML, private source mappings, sanitized source copies if needed, codebase-analysis inventory, and workflow notes.

---

## Expected public CLI shape

The public tool should use this structure unless the delta plan justifies changing it:

```text
infra-skeleton-tools_<VERSION>/
  README.md
  infractl/
    __init__.py
    cli.py
    project.py
    render.py
    pack.py
    evidence.py
    profiles.py
  schemas/
    README.md
    project.schema.json
    batches.schema.json
    hooks.schema.json
    files.schema.json
  templates/
    README.md
  examples/
    minimal-private-project/
```

---

## Expected private bundle shape

The private project bundle should use this structure unless the real codebase analysis proves a better one:

```text
agentfield-grn-private_<VERSION>/
  README_PRIVATE_BUNDLE.md
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

The `files.yaml` file should map private-bundle source files to their real repo paths under `/mnt/ingress/infra`.

---

## Real workspace convention

In the real workspace, the public CLI and private infra must stay separate:

```text
/workspace/repos/infra-skeleton-tools_<VERSION>/
  public CLI tool

/mnt/ingress/infra/
  real private Infra-Skeleton planning/control tree

/workspace
  implementation repos, experiments, runs, artifacts; keep it free from private infra docs
```

For real layout validation, `--repo-root` must point to the parent folder that contains `infra/`.

For this project, use:

```bash
--repo-root /mnt/ingress
```

because the real private tree is:

```text
/mnt/ingress/infra
```

---

## Webchat-container command pattern

When working inside ChatGPT's container, use `/mnt/data` paths:

```bash
cd /mnt/data/infra-skeleton-tools_<VERSION>

python -m infractl.cli profiles

python -m infractl.cli check-required-files \
  --project /mnt/data/agentfield-grn-private_<VERSION>

python -m infractl.cli validate-real-layout \
  --project /mnt/data/agentfield-grn-private_<VERSION> \
  --repo-root /mnt/data/agentfield-grn-private_<VERSION> \
  --allow-bundle-fallback

# The following `request-create` and `request-update` commands require a matching `WORKFLOW_DIRECTION`.
python -m infractl.cli request-create \
  --project /mnt/data/agentfield-grn-private_<VERSION> \
  --track skeleton \
  --batch 02 \
  --topic manual_workflow_check \
  --profile webchat-sandbox \
  --out /mnt/data/generated_<VERSION>

python -m infractl.cli request-update \
  --project /mnt/data/agentfield-grn-private_<VERSION> \
  --track skeleton \
  --batch 01 \
  --topic workflow_smoke_automation \
  --profile webchat-sandbox \
  --extra-source /mnt/data/agentfield-grn-private_<VERSION>/sources/workflow/CLI_EXTRACTION_NOTES.md \
  --out /mnt/data/generated_<VERSION>
```

If `--allow-bundle-fallback` does not exist in the current CLI, either add it as part of the delta plan or use the existing bundle/source validation command instead. Do not pretend real `/mnt/ingress/infra` exists inside webchat.

---

## Real workspace/Codex command pattern

When Codex or the local machine runs the tool in the real workspace:

```bash
cd /workspace/repos/infra-skeleton-tools_<VERSION>

python -m infractl.cli validate-real-layout \
  --project /workspace/private/agentfield-grn-private_<VERSION> \
  --repo-root /mnt/ingress

# The following workspace request commands require a matching `WORKFLOW_DIRECTION`.
python -m infractl.cli request-create \
  --project /workspace/private/agentfield-grn-private_<VERSION> \
  --track skeleton \
  --batch 02 \
  --topic batch_creation \
  --profile workspace \
  --out /workspace/private/agentfield-grn-private_<VERSION>/generated

python -m infractl.cli request-update \
  --project /workspace/private/agentfield-grn-private_<VERSION> \
  --track skeleton \
  --batch 01 \
  --topic workflow_smoke_automation \
  --profile workspace \
  --out /workspace/private/agentfield-grn-private_<VERSION>/generated
```

Do not run smoke, mutate `/mnt/egress`, edit config internals, or call live APIs unless the user explicitly requests a later execution phase.

---

## Extra-source rule

If the user provides new SPECs, ANX files, notes, codebase analysis, or workflow docs, pass them as `--extra-source` or include them in the private bundle's `source_inventory/`.

Every extra source is candidate context only.

The generated request must include `EXTRA_SOURCE_ROUTING.md`, asking ChatGPT to classify whether the source should:

```text
- update the selected batch
- create/update a SPEC annex
- create/update a creation hook
- create/update an update hook
- update future batch creation
- update already-run batches
- change public CLI behavior
- change private bundle mapping
- be ignored as irrelevant/outdated
- require more files before continuing
```

---

## CLI_EXTRACTION_NOTES.md rule

Until Batch 04 is complete and v1/v2 behavior is stable, keep using this one-liner in generated requests:

```text
At the end, update CLI_EXTRACTION_NOTES.md with only the reusable patterns from this batch/update run that should inform a future infractl CLI.
```

The update-infra workflow must read those notes and decide which repeated patterns are ready to become deterministic code/YAML/templates.

---

## Stop conditions

Stop instead of guessing when:

```text
- the public tool repo/zip is unavailable
- the private bundle is unavailable
- the fresh codebase analysis is unavailable
- files.yaml contradicts the codebase analysis and cannot be resolved
- required private files are missing
- a requested update would put private content into the public CLI
- a requested command would mutate /workspace, /mnt/ingress, /mnt/egress, or config internals without explicit approval
```

---

## Final response requirements

When files are generated, provide links to:

```text
- public CLI zip
- private bundle zip
- delta plan
- test logs
- generated request examples, if any
```

Also state clearly what was not done, especially if no real workspace validation, no smoke run, no Codex execution, or no config integration was performed.
