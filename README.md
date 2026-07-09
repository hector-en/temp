# InfraCTL Prompt-Only Execution Library

This folder is a prompt-only execution library for the Infra-Skeleton workflow. It is designed so you can upload `infractl.zip` and `infractl.md` into a fresh ChatGPT or Codex chat, then ask the model to run one specific workflow lane safely.

The library does **not** replace the real public `infractl` tool, the private project bundle, or required evidence files. It tells the model which prompt-only DOT file to read, how to route the task, what variables to suggest, when to ask for confirmation, and when to stop.

## Repo-local DOT rule

When operating inside `/workspace/repos/infractl-public`, read DOT files from:

```text
dots/
```

Use repo-local `dots/...` paths for Codex/WSL/local instructions. Keep `infractl.zip` upload wording for fresh webchat sessions, but do not point local operators at `infractl/<lane>/...`.

---

## Expected zip layout

Your zip should use `infractl/` as the root folder:

```text
infractl.zip
└── infractl/
    ├── infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
    ├── zero-abc/
    │   ├── 0A_public_private_contract_infractl_prompts_only.dot
    │   ├── 0B_expansion_lane_infractl_prompts_only.dot
    │   └── 0C_cli_extraction_feedback_infractl_prompts_only.dot
    ├── request-create-skeleton/
    │   ├── P1_request_create_skeleton_infractl_prompts_only.dot
    │   ├── P2_create_writing_lane_infractl_prompts_only.dot
    │   ├── P3_create_package_lane_infractl_prompts_only.dot
    │   ├── P4_package_to_codex_lane_infractl_prompts_only.dot
    │   ├── P5_evidence_return_lane_infractl_prompts_only.dot
    │   └── P6_next_cycle_lane_infractl_prompts_only.dot
    ├── request-update-skeleton/
    │   ├── P1_request_update_skeleton_infractl_prompts_only.dot
    │   ├── P2_update_writing_lane_infractl_prompts_only.dot
    │   ├── P3_update_package_lane_infractl_prompts_only.dot
    │   ├── P4_package_to_codex_update_skeleton_lane_infractl_prompts_only.dot
    │   ├── P5_evidence_return_update_skeleton_lane_infractl_prompts_only.dot
    │   └── P6_next_cycle_update_skeleton_lane_infractl_prompts_only.dot
    ├── request-create-organs/
    │   ├── P1_request_create_organ_infractl_prompts_only.dot
    │   ├── P2_create_writing_organ_lane_infractl_prompts_only.dot
    │   ├── P3_create_package_organ_lane_infractl_prompts_only.dot
    │   ├── P4_package_to_codex_organ_lane_infractl_prompts_only.dot
    │   ├── P5_evidence_return_organ_lane_infractl_prompts_only.dot
    │   └── P6_next_cycle_organ_lane_infractl_prompts_only.dot
    ├── request-update-organs/
    │   ├── P1_request_update_organ_infractl_prompts_only.dot
    │   ├── P2_update_writing_organ_lane_infractl_prompts_only.dot
    │   ├── P3_update_package_organ_lane_infractl_prompts_only.dot
    │   ├── P4_package_to_codex_update_organ_lane_infractl_prompts_only.dot
    │   ├── P5_evidence_return_update_organ_lane_infractl_prompts_only.dot
    │   └── P6_next_cycle_update_organ_lane_infractl_prompts_only.dot
    └── config-infra/
        ├── CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
        ├── CIP02_rich_integration_request_generation_infractl_prompts_only.dot
        ├── CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
        ├── CIP04_live_config_state_resolution_infractl_prompts_only.dot
        ├── CIP05_config_implementation_planning_infractl_prompts_only.dot
        └── CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

Keep `infractl.md` next to the zip when uploading to a new chat:

```text
infractl.md
infractl.zip
```

---

## The safest way to start a new chat

Upload:

```text
infractl.md
infractl.zip
```

Then give one clear route command.

Example for a new skeleton batch:

```text
Use infractl.md and infractl.zip.

Task:
Create skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P1

Read infractl.md first.
Read the root main v7 DOT next.
Then select the matching prompt-only DOT from:
dots/request-create-skeleton/

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Short version that should also work:

```text
Use infractl.md and infractl.zip to create skeleton batch 02.
Start at P1.
Suggest variables first and wait for confirmation.
```

Avoid saying only:

```text
create batch 2
```

That is ambiguous because it could mean skeleton batch 02, organ R02, an update to batch 02, or a next-cycle continuation.

---

## Route map

Use this table to pick the right folder and starting DOT.

| What you want | MODE | TRACK | Start folder | Start DOT |
|---|---|---|---|---|
| Create a new skeleton batch | `request-create` | `skeleton` | `dots/request-create-skeleton/` | `P1_request_create_skeleton_infractl_prompts_only.dot` |
| Update an already-run skeleton batch | `request-update` | `skeleton` | `dots/request-update-skeleton/` | `P1_request_update_skeleton_infractl_prompts_only.dot` |
| Create the organ/R01 scaffold | `request-create` | `organ` | `dots/request-create-organs/` | `P1_request_create_organ_infractl_prompts_only.dot` |
| Update an already-run organ/R01 route | `request-update` | `organ` | `dots/request-update-organs/` | `P1_request_update_organ_infractl_prompts_only.dot` |
| Validate public/private setup | n/a | n/a | `dots/zero-abc/` | `0A_public_private_contract_infractl_prompts_only.dot` |
| Route new background/spec/annex material | n/a | n/a | `dots/zero-abc/` | `0B_expansion_lane_infractl_prompts_only.dot` |
| Record helper/CLI extraction opportunities | n/a | n/a | `dots/zero-abc/` | `0C_cli_extraction_feedback_infractl_prompts_only.dot` |
| Decide whether raw source/config material belongs in Config-Infra | `config-infra` | `CIP01` | `dots/config-infra/` | `CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot` |
| Generate or retrofit a rich integration request | `config-infra` | `CIP02` | `dots/config-infra/` | `CIP02_rich_integration_request_generation_infractl_prompts_only.dot` |
| Aggregate and approve integration requests | `config-infra` | `CIP03` | `dots/config-infra/` | `CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot` |
| Resolve current live config/tooling state read-only | `config-infra` | `CIP04` | `dots/config-infra/` | `CIP04_live_config_state_resolution_infractl_prompts_only.dot` |
| Plan config implementation without applying changes | `config-infra` | `CIP05` | `dots/config-infra/` | `CIP05_config_implementation_planning_infractl_prompts_only.dot` |
| Apply/close out manifest-approved config changes | `config-infra` | `CIP06` | `dots/config-infra/` | `CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot` |

---

## When to use the zero path

The `zero-abc/` path is for setup, expansion, and tooling feedback. It is not a normal P1-P6 batch lane.

### Use 0A when validating setup

Use 0A before a normal run when the chat has not yet validated the public tool and private bundle layout.

```text
Use infractl.md and infractl.zip.
Run 0A public/private contract preflight.
Suggest variables first and wait for confirmation.
```

Use 0A for questions like:

```text
Do I have the right public/private files?
Can this environment run the Infra-Skeleton workflow safely?
Are required paths present?
```

### Use 0B when adding new knowledge

Use 0B when you have new notes, specs, annex files, papers, workflow text, or background material that must be routed before a batch/create/update run.

```text
Use infractl.md and infractl.zip.
Run 0B expansion lane for these uploaded source files.
Suggest routing first and wait for confirmation.
```

Use 0B for things like:

```text
Add a new annex.
Update a SPEC from new source material.
Create a new hook.
Route background information before a batch.
```

### Use 0C when extracting reusable tooling

Use 0C when a manual pattern, helper script, CLI friction, or repeated workflow should become a reusable public helper or `infractl` CLI candidate.

```text
Use infractl.md and infractl.zip.
Run 0C CLI extraction feedback for this helper/script/workflow issue.
Suggest the extraction note first and wait for confirmation.
```

Use 0C for things like:

```text
We wrote a reusable script.
Codex got confused by a repeated instruction.
A manual step should become an infractl command.
A workflow should be recorded in CLI_EXTRACTION_NOTES.md.
```

---

## Config-Infra CIP path

The current real `infractl.zip` also includes a `config-infra/` path. Use this path when batch or organ work produces configuration, environment, Python/lv, package-stack, bootstrap, account, mount, or workflow-integration implications that need a structured handoff instead of an ad hoc note.

The `config-infra/` path is separate from the normal P1-P6 create/update lanes. It is the Config-Infra lifecycle for turning integration needs into approved manifests, live-state resolution, implementation plans, and carefully gated closeout.

### Config-Infra layout

```text
dots/config-infra/
  CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
  CIP02_rich_integration_request_generation_infractl_prompts_only.dot
  CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
  CIP04_live_config_state_resolution_infractl_prompts_only.dot
  CIP05_config_implementation_planning_infractl_prompts_only.dot
  CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

### When to use CIP

Normal skeleton/organ create/update lanes may produce a rich `INTEGRATION_REQUEST.md`. The CIP path is the follow-on route family for deciding what to do with those requests.

```text
CIP01 = source intake and suitability determination
CIP02 = rich integration request generation or retrofit
CIP03 = manifest aggregation and approval
CIP04 = live config-state resolution
CIP05 = config implementation planning
CIP06 = idempotent application and closeout
```

Typical workflow alignment:

```text
Normal batch create/update
  -> rich INTEGRATION_REQUEST.md

S-T8 / O-T8
  -> CIP03 manifest aggregation and approval

S-T9 / O-T9
  -> CIP04 live config-state resolution
  -> CIP05 config implementation planning
  -> CIP06 manifest-approved application and closeout
```

### Safety model

```text
CIP01-CIP05 are read-only / planning-only.
CIP06 defaults to no mutation.
CIP06 may apply changes only with:
  - manifest approval
  - live config-state snapshot
  - implementation plan
  - exact file touch set
  - explicit confirmation
  - passing safety gates
```

### Config-Infra CIP output root rule

Canonical rule:

```text
For every CIP run, use:
/workspace/runs/cip/<slug-title>/<cip-phase>/
```

where:

```text
- <slug-title> is the CIP topic/run slug, for example batch01_config_infra_cip_alignment_manifest
- <cip-phase> is lowercase cip01, cip02, cip03, cip04, cip05, or cip06
```

Examples:

```text
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip03/INTEGRATION_MANIFEST.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip04/CONFIG_STATE_SNAPSHOT.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip05/CONFIG_INTEGRATION_PLAN.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip06/CONFIG_INTEGRATION_CLOSEOUT_REPORT.md
```

Variable convention:

```text
CIP_RUN_SLUG=<slug-title>
CIP_PHASE_DIR=cip04
CIP_RUN_ROOT=/workspace/runs/cip/${CIP_RUN_SLUG}
OUTPUT_ROOT=${CIP_RUN_ROOT}/${CIP_PHASE_DIR}
```

Phase mapping:

```text
CIP01 -> /workspace/runs/cip/<slug-title>/cip01/
CIP02 -> /workspace/runs/cip/<slug-title>/cip02/
CIP03 -> /workspace/runs/cip/<slug-title>/cip03/
CIP04 -> /workspace/runs/cip/<slug-title>/cip04/
CIP05 -> /workspace/runs/cip/<slug-title>/cip05/
CIP06 -> /workspace/runs/cip/<slug-title>/cip06/
```

Legacy rule:

```text
Legacy CIP artifacts may exist under /workspace/cipXX/<topic>/ or /workspace/runs/cip/cipXX/<topic>/. For new runs, addendums, and future phases, write to /workspace/runs/cip/<slug-title>/cipXX/. Existing legacy outputs should be read as inputs when needed and left in place unless an explicit migration task is approved.
```

### Config-Infra filename contract

```text
Do not infer CIP source-contract filenames from phase titles.
Use the hardcoded CIP source-contract map and registry lookup.
If a mapped file is missing, search hooks.yaml / files.yaml / candidate filenames before declaring it missing.
Do not invent alternate filenames.
```

Compact canonical map:

```text
CIP01:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX01_config_infra_suitability_determiner.md
  hook: HOOK_config_infra_suitability_assessment.md
  outputs: CONFIG_INFRA_SUITABILITY_DECISION.md, CONFIG_INFRA_SUITABILITY_DECISION.json

CIP02:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX02_integration_request_schema.md
  hook: HOOK_config_infra_rich_integration_request.md
  outputs: INTEGRATION_REQUEST.md, INTEGRATION_REQUEST.json

CIP03:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX03_integration_manifest_schema.md
  hook: HOOK_config_infra_manifest_gate.md
  outputs: INTEGRATION_MANIFEST.md, INTEGRATION_MANIFEST.json

CIP04:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX04_config_state_snapshot_schema.md
  hook: HOOK_config_infra_live_resolution_gate.md
  outputs: CONFIG_STATE_SNAPSHOT.md, CONFIG_STATE_SNAPSHOT.json, CIP04_POSTCHECK.md

CIP05:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX05_config_integration_plan_schema.md
  supporting_annex: SPEC_config_infra_integration_pipeline-ANX06_config_patch_classes.md
  hook: HOOK_config_infra_implementation_plan_gate.md
  outputs: CONFIG_INTEGRATION_PLAN.md, CONFIG_INTEGRATION_PLAN.json, CIP05_POSTCHECK.md

CIP06:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX06_config_patch_classes.md
  supporting_annex:
    SPEC_config_infra_integration_pipeline-ANX07_config_integration_implementer_spec.md
    SPEC_config_infra_integration_pipeline-ANX08_config_integration_implementer_runbook.md
    SPEC_config_infra_integration_pipeline-ANX09_codex_pack_template_config_integration.md
  hook: HOOK_config_infra_closeout_snapshot_companion.md
  outputs: CONFIG_INTEGRATION_CLOSEOUT_REPORT.md, CONFIG_INTEGRATION_CLOSEOUT_REPORT.json, CIP06_POSTCHECK.md
```

### CIP router prompt

Use this when you are not sure which Config-Infra phase to run next:

```text
Use infractl.md and infractl.zip.
I need help deciding which Config-Infra CIP phase to use for this request.
Given my current artifacts, tell me whether I should run CIP01, CIP02, CIP03, CIP04, CIP05, or CIP06 next.
Do not execute yet. First return the recommended phase, required files, missing prerequisites, and variable block.
```

### CIP01 — source intake and suitability determination

Use CIP01 for raw source material, new environment/config ideas, or unclear requests where you first need to decide whether the work belongs in Config-Infra.

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP01 source intake and suitability determination.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP01 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
```

### CIP02 — rich integration request generation

Use CIP02 to generate or retrofit a rich `INTEGRATION_REQUEST.md` after suitability has been determined.

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP02 rich integration request generation.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP02 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot
```

### CIP03 — manifest aggregation and approval

Use CIP03 at S-T8 or O-T8 to aggregate one or more integration requests into a manifest and decide what is approved, deferred, blocked, duplicate, or already covered.

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP03 manifest aggregation and approval.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP03 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
```

### CIP04 — live config-state resolution

Use CIP04 after CIP03 to inspect the current real config/tooling state in read-only mode. CIP04 resolves what exists now; it does not apply changes.

```text
CIP04 naming guardrail:
The phase title is "Live config-state resolution", but the canonical ANX file is SPEC_config_infra_integration_pipeline-ANX04_config_state_snapshot_schema.md.
The canonical hook is HOOK_config_infra_live_resolution_gate.md.
The canonical outputs are CONFIG_STATE_SNAPSHOT.md, CONFIG_STATE_SNAPSHOT.json, and CIP04_POSTCHECK.md.
Do not use LIVE_CONFIG_STATE_SNAPSHOT.* or HOOK_config_infra_live_state_resolution.md unless a future registry explicitly changes the contract.
```

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP04 live config-state resolution.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP04 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot
```

### CIP05 — config implementation planning

Use CIP05 after CIP04 to produce the implementation plan and select patch/application classes. CIP05 plans only; it does not apply changes.

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP05 config implementation planning.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP05 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot
```

### CIP06 — idempotent application and closeout

Use CIP06 only after CIP03, CIP04, and CIP05 have passed and the operator explicitly confirms the approved touch set. CIP06 is mutation-default-no and must stop if approval or evidence is missing.

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP06 idempotent application and closeout.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP06 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

---

## P1-P6 phase meanings

Each mode + track route follows the same broad phase shape, but each DOT contains route-specific details.

| Phase | Meaning | Typical output |
|---|---|---|
| P1 | Direction/request generation | Request folder |
| P2 | Request-to-writing | Create/update instruction files |
| P3 | Writing-to-package | Codex package zip |
| P4 | Package-to-Codex / layout gate | Validated pack and Codex execution handoff |
| P5 | Evidence return | Execution evidence, snapshot/export, G17 decision |
| P6 | Next-cycle routing | Choice of next route |

Do not skip phases unless the DOT says the required previous output already exists and the operator confirms re-entry at a later phase.

---

## Required operator behavior

Every prompt-only DOT is designed to be idempotent and confirmation-driven.

The model should always:

```text
1. Read infractl.md.
2. Read the root main v7 DOT.
3. Select exactly one matching prompt-only DOT.
4. Suggest the variable block first.
5. Label variables as user-provided, inferred, default-safe, or unknown.
6. Ask the operator to confirm or correct variables.
7. Stop until confirmation.
8. Execute only the addressed phase/lane.
9. Refuse to overwrite existing outputs unless ALLOW_OVERWRITE=yes.
10. Stop if evidence, bundle, route, or phase prerequisites are missing.
```

The model should not:

```text
- guess between skeleton and organ routes
- guess between create and update routes
- overwrite existing artifacts silently
- run Codex when the lane is ChatGPT-only
- mutate /workspace or /mnt/egress from a webchat-sandbox phase
- treat skeleton evidence as organ evidence
- treat organ R01 as skeleton Batch 01
- continue to the next phase without confirmation when the DOT requires a gate
```

---

## Common commands

### Create skeleton batch 02

```text
Use infractl.md and infractl.zip.

Task:
Create skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P1

Read infractl.md first.
Read the root main v7 DOT next.
Then select the matching prompt-only DOT from:
dots/request-create-skeleton/

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

### Update skeleton batch 01 for workflow smoke automation

```text
Use infractl.md and infractl.zip.

Task:
Update already-run skeleton batch 01 for workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P1
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation
EVIDENCE_REQUIRED=yes

Read infractl.md first.
Read the root main v7 DOT next.
Then select the matching prompt-only DOT from:
dots/request-update-skeleton/

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

### Create organ R01 scaffold

```text
Use infractl.md and infractl.zip.

Task:
Create the organ R01 scaffold.

Route:
MODE=request-create
TRACK=organ
PHASE=P1

Read infractl.md first.
Read the root main v7 DOT next.
Then select the matching prompt-only DOT from:
dots/request-create-organs/

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

### Update an existing organ route

```text
Use infractl.md and infractl.zip.

Task:
Update an already-run organ route.

Route:
MODE=request-update
TRACK=organ
PHASE=P1
EVIDENCE_REQUIRED=yes

Read infractl.md first.
Read the root main v7 DOT next.
Then select the matching prompt-only DOT from:
dots/request-update-organs/

Before continuing, verify that prior organ/R01 evidence exists.
Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

### Decide the next Config-Infra CIP phase

```text
Use infractl.md and infractl.zip.
I need help deciding which Config-Infra CIP phase to use for this request.
Given my current artifacts, tell me whether I should run CIP01, CIP02, CIP03, CIP04, CIP05, or CIP06 next.
Do not execute yet. First return the recommended phase, required files, missing prerequisites, and variable block.
```

---

## What else you may need for a real run

`infractl.zip` and `infractl.md` are only the instruction/router layer.

For a real Infra-Skeleton run, the chat may also need:

```text
- public infractl tool repo or zip
- private agentfield-grn bundle zip
- required evidence files for request-update lanes
- source docs/specs/annex files for 0B expansion lanes
- `INTEGRATION_REQUEST.md`, `INTEGRATION_MANIFEST.md`, `CONFIG_STATE_SNAPSHOT.md`, or `CONFIG_INTEGRATION_PLAN.md` files for CIP routes
- access to the expected /workspace, /mnt/ingress, or /mnt/egress paths if using Codex/WSL
```

If those are missing, the model should stop and report exactly which inputs are missing.

---

## Recommended minimal habit

For normal work, use this pattern:

```text
Use infractl.md and infractl.zip.

Task:
<plain English task>

Route:
MODE=<request-create or request-update>
TRACK=<skeleton or organ>
PHASE=P1

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

For setup/tooling/background tasks, use:

```text
Use infractl.md and infractl.zip.
Run 0A / 0B / 0C.
Suggest variables first and wait for confirmation.
```

For config-infra work, use:

```text
Use infractl.md and infractl.zip.
I need help deciding which Config-Infra CIP phase to use for this request.
Do not execute yet. First return the recommended phase, required files, missing prerequisites, and variable block.
```

---

## Current real-zip note

This README preserves the original 0A/0B/0C and P1-P6 route instructions and adds the `config-infra/` CIP route family found in the current real `infractl.zip`.

Use the updated public export pair together:

```text
infractl.md
infractl.zip
```
