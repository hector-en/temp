# Daily `infractl` Operator Workflow

Use this when you want to operate the platform, not redesign it. One cycle is always:

```text
WORKFLOW_DIRECTION -> request folder -> ChatGPT Codex files -> Codex zip -> Codex execution -> evidence_snapshots/ -> next direction
```

The direction block is the control point. Do not let ChatGPT infer the next batch, mode, or topic from the bundle.

---

## 0A. Public/private contract and mapping preflight

### Public tool: reusable CLI only

Provide either:

```text
https://github.com/hector-en/temp/tree/main/public_infra-skeleton-tools_v0
public_infra-skeleton-tools_v0.zip
```

Public files do this:

```text
infractl/cli.py        = command entry point
infractl/project.py    = reads YAML and file maps
infractl/render.py     = renders request packs
infractl/pack.py       = packages ChatGPT outputs for Codex
infractl/evidence.py   = checks evidence snapshots
infractl/profiles.py   = enforces safe profiles
```

Public files must not contain private SPECs, annexes, prompts, evidence, or project content.

### Private bundle: project map and copied context

Upload:

```text
agentfield-grn-private_real_v0_bundle.zip
```

Current private mapping files:

```text
project.yaml   1.6 KB  = project identity, profile defaults, safety boundaries
layers.yaml    0.9 KB  = 5-layer architecture and layer ownership
batches.yaml   6.6 KB  = skeleton/organ batch IDs, tracks, required packs
hooks.yaml     1.0 KB  = ANX/hook routing for creation/update work
files.yaml     7.0 KB  = source key -> bundle_path -> real_path mapping
```

Current `files.yaml` status:

```text
28 source_keys
11 required
17 optional
```

Required source keys:

```text
A0, A1, A2, NEW_CREATE, NEW_UPDATE, SPEC_L1, SPEC_L2,
WF_FINAL, WF_SKELETON, WF_SMOKE, CLI_NOTES
```

Important two-root contract:

```text
PUBLIC_TOOL_ROOT=/workspace/repos/infractl-public
PRIVATE_PROJECT_ROOT=/workspace/private/agentfield-grn-private_real_v0
```

Strict v0 preflight in Codex/real workspace:

```bash
cd /workspace/repos/infractl-public

python3 -m infractl.cli validate-real-layout \
  --project /workspace/private/agentfield-grn-private_real_v0 \
  --public-tool-root /workspace/repos/infractl-public
```

This validates the public tool root and the private project root together. Required private source keys resolve by `bundle_path` under `PRIVATE_PROJECT_ROOT`; `files.yaml.real_path` remains legacy metadata and is not expanded under a third contract root.

Inside ChatGPT webchat only, validate the uploaded private bundle contents directly:

```bash
python3 -m infractl.cli validate-real-layout \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --public-tool-root /mnt/data/infractl-public
```

---

## 0B. Expansion lane: creating/updating SPEC, ANX, hooks, prompts

Use this when new knowledge should expand the system.

```text
extra source -> request-update with --extra-source -> EXTRA_SOURCE_ROUTING.md -> ChatGPT classifies -> SPEC / ANX / hook / prompt update -> Codex pack -> evidence
```

Choose this lane when a new file should:

```text
- update the selected batch
- create/update a SPEC annex
- create/update a creation hook
- create/update an update hook
- update future batch creation
- update already-run batches
- become future deterministic infractl behavior through CLI_EXTRACTION_NOTES.md
```

For lane-wide public-bundle, `README.md`, `prompt_guide.md`, DOT-path, strict-prompt, guardrail, or two-root-contract maintenance, use `0B` first to classify/scope the update and trigger `HOOK_public_bundle_lane_update_method` before reading `CLI_EXTRACTION_NOTES.md`. Normal P1-P6 and CIP lanes do not read that file by default.

Extra sources are candidate context only. They are not authoritative until routed.

---

## 1. WORKFLOW_DIRECTION field guide

Every direction must include:

```text
WORKFLOW_DIRECTION:
  mode: <request-create | request-update | package-codex-create | package-codex-update | check-evidence | status>
  track: <skeleton | organ>
  batch: <01 | 02 | 03 | 04 | R01>
  topic: <short-topic-slug>
  evidence_required: <yes | no>
  extra_sources: <none | list of uploaded paths>
```

Choose fields like this:

```text
mode=request-create          create a new request for a not-yet-run batch
mode=request-update          correct or expand an already-run batch
mode=package-codex-create    package create outputs written by ChatGPT
mode=package-codex-update    package update outputs written by ChatGPT
mode=check-evidence          inspect returned proof before next step
mode=status                  inventory only, no new request

track=skeleton               use for Batches 01-04, before real organs
track=organ                  use for R01 and later organ phase

batch=01..04                 skeleton batch number
batch=R01                    first organ scaffold

evidence_required=no         creation/scaffold work with no prior evidence dependency
evidence_required=yes        update/expansion work that must see prior evidence first

extra_sources=none           normal create/update
extra_sources=[paths]        knowledge expansion; must route through EXTRA_SOURCE_ROUTING.md
```

If `evidence_required: yes` and evidence is missing, stop and ask for the missing evidence or explicit permission to continue without it.

---

## 2. ChatGPT webchat: generate one request folder

ChatGPT consumes:

```text
public tool
private bundle
optional extra source files
one WORKFLOW_DIRECTION block
```

Safe checks before choosing a request command:

```bash
cd /mnt/data/public_infra-skeleton-tools_v0

python3 -m infractl.cli profiles
python3 -m infractl.cli list-batches --project /mnt/data/agentfield-grn-private_real_v0 --track skeleton
python3 -m infractl.cli list-hooks --project /mnt/data/agentfield-grn-private_real_v0
python3 -m infractl.cli check-required-files --project /mnt/data/agentfield-grn-private_real_v0 --track skeleton
python3 -m infractl.cli status --project /mnt/data/agentfield-grn-private_real_v0
```

### Create skeleton batch

```text
Consumes: public tool + private bundle
Direction: mode=request-create, track=skeleton, batch=02, evidence_required=no
Produces: request folder
```

```bash
python3 -m infractl.cli request-create \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --track skeleton \
  --batch 02 \
  --topic batch02_creation \
  --profile webchat-sandbox \
  --out /mnt/data/generated_real_v0
```

### Update skeleton batch

```text
Consumes: public tool + private bundle + selected-batch evidence
Direction: mode=request-update, track=skeleton, batch=01, evidence_required=yes
Produces: request folder with EXISTING_EVIDENCE_CHECK.md
```

```bash
python3 -m infractl.cli request-update \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --track skeleton \
  --batch 01 \
  --topic workflow_smoke_automation \
  --profile webchat-sandbox \
  --out /mnt/data/generated_real_v0
```

### Expand knowledge with an extra source

```text
Consumes: public tool + private bundle + evidence + extra source
Direction: mode=request-update, track=skeleton, batch=02, evidence_required=yes, extra_sources=[path]
Produces: request folder with EXTRA_SOURCE_ROUTING.md
```

```bash
python3 -m infractl.cli request-update \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --track skeleton \
  --batch 02 \
  --topic workspace_boundary_update \
  --profile webchat-sandbox \
  --extra-source /mnt/data/new_note_or_spec.md \
  --out /mnt/data/generated_real_v0
```

### Create organ R01 scaffold

```text
Consumes: public tool + private bundle + stable skeleton contracts
Direction: mode=request-create, track=organ, batch=R01, evidence_required=no
Produces: organ scaffold request folder
```

```bash
python3 -m infractl.cli request-create \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --track organ \
  --batch R01 \
  --topic organ_r01_scaffold \
  --profile webchat-sandbox \
  --out /mnt/data/generated_real_v0
```

Request folders contain:

```text
CHATGPT_REQUEST.md
REQUIRED_INPUTS.md
SELECTED_CONTEXT_MANIFEST.md
EXTRA_SOURCE_ROUTING.md
CLI_EXTRACTION_REMINDER.md
manifest.json
source_bundle.zip
EXISTING_EVIDENCE_CHECK.md, for updates
```

---

## 3. ChatGPT writing: request folder to Codex files

ChatGPT reads the request folder and writes exactly one pack shape.

Create pack files:

```text
CODEX_PROMPT.txt
PROJECT_CACHE.md
SPEC.md
RUN_INSTRUCTIONS.md
POSTCHECK_TEMPLATE.md
```

Update pack files:

```text
CODEX_UPDATE_PROMPT.txt
PROJECT_UPDATE_CACHE.md
UPDATE_SPEC.md
UPDATE_RUN_INSTRUCTIONS.md
UPDATE_POSTCHECK_TEMPLATE.md
```

ChatGPT writes only. It does not execute the batch.

---

## 4. WSL2/local CLI: package Codex zip

Package create files:

```bash
cd ~/repos/public_infra-skeleton-tools_v0

python3 -m infractl.cli package-codex-create \
  --input ~/chatgpt_outputs/batch02_create \
  --out ~/generated_real_v0
```

Package update files:

```bash
python3 -m infractl.cli package-codex-update \
  --input ~/chatgpt_outputs/batch01_update \
  --out ~/generated_real_v0
```

Produces one Codex zip. This is the only artifact Codex should execute.

---

## 5. Codex/real workspace: validate, execute, return evidence

Before implementation, Codex runs strict layout validation:

```bash
cd /workspace/repos/infractl-public

python3 -m infractl.cli validate-real-layout \
  --project /workspace/private/agentfield-grn-private_real_v0 \
  --public-tool-root /workspace/repos/infractl-public
```

Codex follows only:

```text
RUN_INSTRUCTIONS.md
UPDATE_RUN_INSTRUCTIONS.md
```

Evidence returns to:

```text
evidence_snapshots/skeleton/<batch-slug>/
  POSTCHECK.md
  INTEGRATION_REQUEST.md
  SMOKE_REPORT.md

evidence_snapshots/skeleton/<batch-slug>/updates/<update-id>/
  UPDATE_POSTCHECK.md
  UPDATE_INTEGRATION_REQUEST.md
  CHANGESET_MANIFEST.md

evidence_snapshots/organ/<batch-slug>/
```

---

## 6. Batch landscape

```text
Skeleton 01 = runtime substrate / first contracts
Skeleton 02 = role workstations / workspace boundaries
Skeleton 03 = research execution loops
Skeleton 04 = knowledge/reasoning and stable CLI lessons
Organ R01   = first organ scaffold after skeleton rules are stable
```

Skeleton comes first because it proves contracts. Organ phase comes later because real organs depend on stable evidence, packaging, workspace, and safety gates.

---

## 7. Daily finish rule

Each cycle ends only when:

```text
evidence copied back into evidence_snapshots/
CLI_EXTRACTION_NOTES.md updated with reusable CLI lessons
next WORKFLOW_DIRECTION chosen explicitly
```
