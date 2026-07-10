# InfraCTL Prompt-Only Flow README

This README explains how to use `infractl.zip` as a prompt-instruction library in a fresh ChatGPT or Codex chat.

The current `infractl.zip` should have this shape at the zip root. Do **not** expect an extra nested `infractl/` directory around the DOT router tree. The `infractl/` folder inside the zip is the Python package, not the DOT root.

```text
infractl.zip
├── README.md
├── infractl.md
├── prompt_guide.md
├── workflow.md
├── pyproject.toml
├── infractl/
│   ├── cli.py
│   ├── project.py
│   ├── pack.py
│   ├── evidence.py
│   ├── profiles.py
│   └── render.py
├── dots/
│   ├── infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
│   ├── zero-abc/
│   │   ├── 0A_public_private_contract_infractl_prompts_only.dot
│   │   ├── 0A_public_private_contract_infractl_prompts_only.png
│   │   ├── 0B_expansion_lane_infractl_prompts_only.dot
│   │   ├── 0B_expansion_lane_infractl_prompts_only.png
│   │   ├── 0C_cli_extraction_feedback_infractl_prompts_only.dot
│   │   └── 0C_cli_extraction_feedback_infractl_prompts_only.png
│   ├── request-create-skeleton/
│   ├── request-update-skeleton/
│   ├── request-create-organs/
│   ├── request-update-organs/
│   └── config-infra/
│       ├── CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
│       ├── CIP02_rich_integration_request_generation_infractl_prompts_only.dot
│       ├── CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
│       ├── CIP04_live_config_state_resolution_infractl_prompts_only.dot
│       ├── CIP05_config_implementation_planning_infractl_prompts_only.dot
│       └── CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
├── schemas/
├── scripts/
├── templates/
└── examples/
```

The main DOT is `dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot`. The phase/router DOTs live under `dots/...`.

## Repo-local DOT rule

When operating inside `/workspace/repos/infractl-public`, read DOT files from:

```text
dots/
```

Use repo-local `dots/...` paths for Codex/WSL/local instructions. Keep `infractl.zip` upload wording for fresh webchat sessions, but do not point local operators at `infractl/<lane>/...`.

Zip-tree verification note:

```text
Correct P-lane path: dots/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot
Correct 0-lane path: dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
Correct CIP path: dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
Incorrect for the current zip: infractl/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot
Incorrect for the current zip: infractl/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
Incorrect for the current zip: infractl/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
```

## Zero and Config-Infra path verification

The current `infractl.zip` contains Zero and Config-Infra DOTs directly under `dots/`, not under the Python package folder. Use these exact paths when prompting ChatGPT, Codex, or a WSL/operator session.

Zero lanes:

```text
dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
dots/zero-abc/0B_expansion_lane_infractl_prompts_only.dot
dots/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot
```

Config-Infra CIP lanes:

```text
dots/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
dots/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot
dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
dots/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot
dots/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot
dots/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

Do not use these stale nested forms with the current zip:

```text
infractl/zero-abc/...
infractl/config-infra/...
infractl/request-create-skeleton/...
infractl/request-update-skeleton/...
infractl/request-create-organs/...
infractl/request-update-organs/...
```

The only `infractl/` directory in the current zip is the Python package (`infractl/cli.py`, `infractl/project.py`, etc.). It is not the DOT router root.

## General rule

In a fresh chat, upload:

```text
1. infractl.zip
2. infractl.md
3. the actual input files needed for the route
```

Then tell the model which route to run.

Always tell the model:

```text
Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

The model should read:

```text
1. infractl.md
2. dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
3. the selected prompt-only DOT for the route and phase, or the selected CIP DOT from `dots/config-infra/`
```

---

# 0A / 0B / 0C setup routes

Use these before or beside the normal P1-P6 routes.

## 0A — public/private contract preflight

Use this when you want to check that the public tool and private bundle layout are valid before starting a batch route.

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
agentfield-grn-private_real_v0_bundle.zip
```

Say:

```text
Use infractl.md and infractl.zip.
Run 0A public/private contract preflight.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the 0A DOT from dots/zero-abc/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
```

## 0B — expansion lane

Use this when you have new background files, specs, annexes, workflow notes, or source material that should be routed into the system before creating/updating a batch.

Upload:

```text
infractl.zip
infractl.md
new source files / notes / specs / annex material
```

Say:

```text
Use infractl.md and infractl.zip.
Run 0B expansion lane for the uploaded source files.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the 0B DOT from dots/zero-abc/.

Suggest the routing and variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/zero-abc/0B_expansion_lane_infractl_prompts_only.dot
```

## 0C — CLI extraction feedback

Use this when a repeated manual step, helper script, Codex friction, or workflow gap should be captured for possible public-tool or CLI promotion.

Upload:

```text
infractl.zip
infractl.md
helper script, logs, notes, or description of the repeated manual step
```

Say:

```text
Use infractl.md and infractl.zip.
Run 0C CLI extraction feedback for this helper/script/workflow issue.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the 0C DOT from dots/zero-abc/.

Suggest the extraction note first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot
```

---

# Config-Infra CIP routes

Use these routes when a batch or organ workflow needs structured config/lv/environment integration instead of an ad hoc handoff.

The real uploaded `infractl.zip` includes this folder under `dots/` at the zip root:

```text
dots/config-infra/
  CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
  CIP02_rich_integration_request_generation_infractl_prompts_only.dot
  CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
  CIP04_live_config_state_resolution_infractl_prompts_only.dot
  CIP05_config_implementation_planning_infractl_prompts_only.dot
  CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

## When to use CIP

Normal create/update routes can emit a rich `INTEGRATION_REQUEST.md`. CIP is the follow-on route family for deciding what to do with those requests.

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

Safety model:

```text
CIP01-CIP05 are read-only / planning-only.
CIP06 defaults to no mutation.
CIP06 may apply changes only with manifest approval, live config-state snapshot,
implementation plan, exact file touch set, explicit confirmation, and passing safety gates.
```

## Config-Infra CIP output root rule

For every CIP run, use:

```text
/workspace/runs/cip/<slug-title>/<cip-phase>/
```

where `<slug-title>` is the CIP topic/run slug and `<cip-phase>` is lowercase `cip01`, `cip02`, `cip03`, `cip04`, `cip05`, or `cip06`.

Examples:

```text
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip03/INTEGRATION_MANIFEST.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip04/CONFIG_STATE_SNAPSHOT.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip05/CONFIG_INTEGRATION_PLAN.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip06/CONFIG_INTEGRATION_CLOSEOUT_REPORT.md
```

Preferred variables:

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

Legacy handling:

```text
Legacy CIP outputs may exist under /workspace/cipXX/<topic>/ or /workspace/runs/cip/cipXX/<topic>/. New runs, addendums, and future phases must write under /workspace/runs/cip/<slug-title>/cipXX/. Read legacy paths as inputs only when needed. Do not move or overwrite them unless an explicit migration task is approved.
```

## Config-Infra filename contract

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

## CIP router prompt

Use this when you are not sure which CIP phase to run next:

```text
Use infractl.md and infractl.zip.
I need help deciding which Config-Infra CIP phase to use for this request.
Given my current artifacts, tell me whether I should run CIP01, CIP02, CIP03, CIP04, CIP05, or CIP06 next.
Do not execute yet. First return the recommended phase, required files, missing prerequisites, and variable block.
```

## CIP01 — source intake and suitability determination

Use this for raw source material, a new environment/config idea, or an unclear request where you first need to decide whether it belongs in Config-Infra.

Upload:

```text
infractl.zip
infractl.md
raw source files / notes / config requirement / workflow requirement
```

Say:

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

## CIP02 — rich integration request generation

Use this to generate or retrofit a rich `INTEGRATION_REQUEST.md` after suitability has been determined.

Upload:

```text
infractl.zip
infractl.md
CIP01 suitability decision if available
source files / notes / existing thin integration request if retrofitting
```

Say:

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

## CIP03 — manifest aggregation and approval

Use this at S-T8 or O-T8 to aggregate one or more integration requests into a manifest and decide what is approved, deferred, blocked, duplicate, or already covered.

Upload:

```text
infractl.zip
infractl.md
one or more INTEGRATION_REQUEST.md files
batch/organ evidence and context if available
```

Say:

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

## CIP04 — live config-state resolution

Use this after CIP03 to inspect the current real config/tooling state in read-only mode. CIP04 resolves what exists now; it does not apply changes.

```text
CIP04 naming guardrail:
The phase title is "Live config-state resolution", but the canonical ANX file is SPEC_config_infra_integration_pipeline-ANX04_config_state_snapshot_schema.md.
The canonical hook is HOOK_config_infra_live_resolution_gate.md.
The canonical outputs are CONFIG_STATE_SNAPSHOT.md, CONFIG_STATE_SNAPSHOT.json, and CIP04_POSTCHECK.md.
Do not use LIVE_CONFIG_STATE_SNAPSHOT.* or HOOK_config_infra_live_state_resolution.md unless a future registry explicitly changes the contract.
```

Upload:

```text
infractl.zip
infractl.md
CIP03 INTEGRATION_MANIFEST.md / .json
current config/tooling context or access to the target workspace when running in Codex/WSL
```

Say:

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

## CIP05 — config implementation planning

Use this after CIP04 to produce the implementation plan and select patch/application classes. CIP05 plans only; it does not apply changes.

Upload:

```text
infractl.zip
infractl.md
CIP03 INTEGRATION_MANIFEST.md / .json
CIP04 CONFIG_STATE_SNAPSHOT.md / .json
```

Say:

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

## CIP06 — idempotent application and closeout

Use this only after CIP03, CIP04, and CIP05 have passed and the operator explicitly confirms the approved touch set. CIP06 is mutation-default-no and must stop if approval or evidence is missing.

Upload:

```text
infractl.zip
infractl.md
CIP03 INTEGRATION_MANIFEST.md / .json
CIP04 CONFIG_STATE_SNAPSHOT.md / .json
CIP05 CONFIG_INTEGRATION_PLAN.md / .json
approved exact file touch set / confirmation context
```

Say:

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

# Route 1 — create skeleton batch

Use this to create a new skeleton batch request and carry it through P1-P6.

Example: create skeleton batch 02.

## P1 — request-create skeleton

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
agentfield-grn-private_real_v0_bundle.zip
any extra source files needed for this batch
```

Say:

```text
Use infractl.md and infractl.zip.

Task:
Create skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P1
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P1 DOT from dots/request-create-skeleton/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P1_request_create_skeleton_infractl_prompts_only.dot
```

## P2 — create-writing skeleton

Upload:

```text
infractl.zip
infractl.md
P1 request folder generated from the previous step
```

Say:

```text
Use infractl.md and infractl.zip.
Continue create skeleton batch 02 from P1 output.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P2
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P2 DOT from dots/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P2_create_writing_lane_infractl_prompts_only.dot
```

## P3 — create-package skeleton

Upload:

```text
infractl.zip
infractl.md
P2 create-writing files
```

Say:

```text
Use infractl.md and infractl.zip.
Package the create-writing files for skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P3
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P3 DOT from dots/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P3_create_package_lane_infractl_prompts_only.dot
```

## P4 — package-to-Codex skeleton create

Upload:

```text
infractl.zip
infractl.md
P3 Codex create pack zip
```

Say:

```text
Use infractl.md and infractl.zip.
Consume the Codex create pack for skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P4
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P4 DOT from dots/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot
```

## P5 — evidence-return skeleton create

Upload:

```text
infractl.zip
infractl.md
Codex execution output/evidence
smoke report if produced
```

Say:

```text
Use infractl.md and infractl.zip.
Return and snapshot evidence for skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P5
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P5 DOT from dots/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P5_evidence_return_lane_infractl_prompts_only.dot
```

## P6 — next-cycle skeleton create

Upload:

```text
infractl.zip
infractl.md
P5/G17 decision text
updated private bundle export if available
```

Say:

```text
Use infractl.md and infractl.zip.
Choose the next cycle after creating skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P6
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P6 DOT from dots/request-create-skeleton/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P6_next_cycle_lane_infractl_prompts_only.dot
```

---

# Route 2 — update skeleton batch

Use this to update an already-run skeleton batch. This route requires existing evidence.

Example: update skeleton batch 01 for topic `workflow_smoke_automation`.

## P1 — request-update skeleton

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
agentfield-grn-private_real_v0_bundle.zip
existing skeleton evidence for the batch:
  POSTCHECK.md
  INTEGRATION_REQUEST.md
  SMOKE_REPORT.md
optional extra source files for the update topic
```

Say:

```text
Use infractl.md and infractl.zip.

Task:
Update skeleton batch 01 for topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P1
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation
EVIDENCE_REQUIRED=yes

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P1 DOT from dots/request-update-skeleton/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P1_request_update_skeleton_infractl_prompts_only.dot
```

## P2 — update-writing skeleton

Upload:

```text
infractl.zip
infractl.md
P1 request-update folder
existing evidence check file from P1
```

Say:

```text
Use infractl.md and infractl.zip.
Continue update skeleton batch 01 for topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P2
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P2 DOT from dots/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P2_update_writing_lane_infractl_prompts_only.dot
```

## P3 — update-package skeleton

Upload:

```text
infractl.zip
infractl.md
P2 update-writing files
```

Say:

```text
Use infractl.md and infractl.zip.
Package the update-writing files for skeleton batch 01 topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P3
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P3 DOT from dots/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P3_update_package_lane_infractl_prompts_only.dot
```

## P4 — package-to-Codex skeleton update

Upload:

```text
infractl.zip
infractl.md
P3 Codex update pack zip
```

Say:

```text
Use infractl.md and infractl.zip.
Consume the Codex update pack for skeleton batch 01 topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P4
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P4 DOT from dots/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P4_package_to_codex_update_skeleton_lane_infractl_prompts_only.dot
```

## P5 — evidence-return skeleton update

Upload:

```text
infractl.zip
infractl.md
Codex update evidence output
existing or new smoke report
```

Say:

```text
Use infractl.md and infractl.zip.
Return and snapshot evidence for skeleton batch 01 topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P5
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P5 DOT from dots/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P5_evidence_return_update_skeleton_lane_infractl_prompts_only.dot
```

## P6 — next-cycle skeleton update

Upload:

```text
infractl.zip
infractl.md
P5/G17 decision text
updated private bundle export if available
```

Say:

```text
Use infractl.md and infractl.zip.
Choose the next cycle after updating skeleton batch 01 topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P6
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P6 DOT from dots/request-update-skeleton/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P6_next_cycle_update_skeleton_lane_infractl_prompts_only.dot
```

---

# Route 3 — create organ scaffold

Use this to create the first organ route. Organ creation starts at R01 and must not reuse skeleton batch numbering by accident.

## P1 — request-create organ

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
agentfield-grn-private_real_v0_bundle.zip
organ transition files if not already in the bundle:
  01_B0_transition_to_real_organs_master_v2.md
  01_B1_transition_real_organs_codex_batch_plan_v2.md
  day_to_day_organs_run.md
```

Say:

```text
Use infractl.md and infractl.zip.

Task:
Create organ R01 scaffold.

Route:
MODE=request-create
TRACK=organ
PHASE=P1
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P1 DOT from dots/request-create-organs/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P1_request_create_organ_infractl_prompts_only.dot
```

## P2 — create-writing organ

Upload:

```text
infractl.zip
infractl.md
P1 organ request folder
organ transition files if requested
```

Say:

```text
Use infractl.md and infractl.zip.
Continue organ R01 scaffold from P1 output.

Route:
MODE=request-create
TRACK=organ
PHASE=P2
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P2 DOT from dots/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P2_create_writing_organ_lane_infractl_prompts_only.dot
```

## P3 — create-package organ

Upload:

```text
infractl.zip
infractl.md
P2 organ create-writing files
```

Say:

```text
Use infractl.md and infractl.zip.
Package the organ R01 create-writing files.

Route:
MODE=request-create
TRACK=organ
PHASE=P3
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P3 DOT from dots/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P3_create_package_organ_lane_infractl_prompts_only.dot
```

## P4 — package-to-Codex organ create

Upload:

```text
infractl.zip
infractl.md
P3 organ Codex create pack zip
```

Say:

```text
Use infractl.md and infractl.zip.
Consume the Codex create pack for organ R01.

Route:
MODE=request-create
TRACK=organ
PHASE=P4
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P4 DOT from dots/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P4_package_to_codex_organ_lane_infractl_prompts_only.dot
```

## P5 — evidence-return organ create

Upload:

```text
infractl.zip
infractl.md
Codex organ execution output/evidence
organ smoke/evidence report if produced
```

Say:

```text
Use infractl.md and infractl.zip.
Return and snapshot evidence for organ R01.

Route:
MODE=request-create
TRACK=organ
PHASE=P5
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P5 DOT from dots/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P5_evidence_return_organ_lane_infractl_prompts_only.dot
```

## P6 — next-cycle organ create

Upload:

```text
infractl.zip
infractl.md
P5/G17 organ decision text
updated private bundle export if available
```

Say:

```text
Use infractl.md and infractl.zip.
Choose the next cycle after organ R01 scaffold.

Route:
MODE=request-create
TRACK=organ
PHASE=P6
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P6 DOT from dots/request-create-organs/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P6_next_cycle_organ_lane_infractl_prompts_only.dot
```

---

# Route 4 — update organ scaffold

Use this only after organ R01 or another organ route already exists and has real organ evidence. Do not use this route for skeleton evidence.

## P1 — request-update organ

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
agentfield-grn-private_real_v0_bundle.zip
prior organ/R01 evidence
organ transition files if requested
optional extra source files for the update topic
```

Say:

```text
Use infractl.md and infractl.zip.

Task:
Update organ R01 for topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P1
ORGAN_RUN=R01
TOPIC=<TOPIC>
EVIDENCE_REQUIRED=yes

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P1 DOT from dots/request-update-organs/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P1_request_update_organ_infractl_prompts_only.dot
```

## P2 — update-writing organ

Upload:

```text
infractl.zip
infractl.md
P1 organ request-update folder
prior organ evidence check output
```

Say:

```text
Use infractl.md and infractl.zip.
Continue organ R01 update for topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P2
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P2 DOT from dots/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P2_update_writing_organ_lane_infractl_prompts_only.dot
```

## P3 — update-package organ

Upload:

```text
infractl.zip
infractl.md
P2 organ update-writing files
```

Say:

```text
Use infractl.md and infractl.zip.
Package the organ R01 update-writing files for topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P3
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P3 DOT from dots/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P3_update_package_organ_lane_infractl_prompts_only.dot
```

## P4 — package-to-Codex organ update

Upload:

```text
infractl.zip
infractl.md
P3 organ Codex update pack zip
```

Say:

```text
Use infractl.md and infractl.zip.
Consume the Codex update pack for organ R01 topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P4
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P4 DOT from dots/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P4_package_to_codex_update_organ_lane_infractl_prompts_only.dot
```

## P5 — evidence-return organ update

Upload:

```text
infractl.zip
infractl.md
Codex organ update evidence output
organ smoke/evidence report if produced or reused
```

Say:

```text
Use infractl.md and infractl.zip.
Return and snapshot evidence for organ R01 topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P5
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P5 DOT from dots/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P5_evidence_return_update_organ_lane_infractl_prompts_only.dot
```

## P6 — next-cycle organ update

Upload:

```text
infractl.zip
infractl.md
P5/G17 organ update decision text
updated private bundle export if available
```

Say:

```text
Use infractl.md and infractl.zip.
Choose the next cycle after organ R01 update topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P6
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P6 DOT from dots/request-update-organs/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P6_next_cycle_update_organ_lane_infractl_prompts_only.dot
```

---

# Current real-zip note

This guide preserves the original 0A/0B/0C and P1-P6 route instructions and adds the `config-infra/` CIP route family found in the current real `infractl.zip`.

Use the updated public export pair together:

```text
infractl.md
infractl.zip
```

For Config-Infra work, start with the CIP router prompt unless you already know the exact CIP phase.

---

# Generic precise P1-P6 InfraCTL prompt template

Use this reusable template for any normal InfraCTL P1-P6 phase across create/update, skeleton/organ, and webchat/Codex contexts.

```text
Use the uploaded public InfraCTL files, uploaded private project bundle, and any phase-specific input artifacts.

Task:
Run InfraCTL phase <PHASE> for <TRACK> <BATCH_OR_RUN>.

Route:
MODE=<request-create | request-update>
TRACK=<skeleton | organ>
PHASE=<P1 | P2 | P3 | P4 | P5 | P6>
BATCH_NUMBER=<01 | 02 | 03 | R01 | etc.>
BATCH_SLUG=<batch-or-run-slug>
TOPIC=<topic-or-run-purpose>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Input from previous phase:
Use the completed <PREVIOUS_PHASE> output:

<PATH_OR_FILENAME_OF_PREVIOUS_PHASE_OUTPUT>

Expected previous-phase contents include:

* <required-file-1>
* <required-file-2>
* <required-file-3>
* <optional-file-if-present>

Also use:

* public InfraCTL files / public bundle / public code-analysis output
* private project bundle:
  <PRIVATE_BUNDLE_FILENAME_OR_PATH>
* relevant evidence package, if this is P5 or later:
  <EVIDENCE_PACKAGE_FILENAME_OR_PATH>

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual Pn DOT = exact phase contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected phase DOT:

<SELECTED_PHASE_DOT_PATH>

Examples:

P1 create skeleton:
dots/request-create-skeleton/P1_request_create_skeleton_infractl_prompts_only.dot

P2 create skeleton:
dots/request-create-skeleton/P2_create_writing_lane_infractl_prompts_only.dot

P3 create skeleton:
dots/request-create-skeleton/P3_create_package_lane_infractl_prompts_only.dot

P4 create skeleton:
dots/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot

P5 create skeleton:
dots/request-create-skeleton/P5_evidence_return_lane_infractl_prompts_only.dot

P6 create skeleton:
dots/request-create-skeleton/P6_next_cycle_lane_infractl_prompts_only.dot

P1 update skeleton:
dots/request-update-skeleton/P1_request_update_skeleton_infractl_prompts_only.dot

P2 update skeleton:
dots/request-update-skeleton/P2_update_writing_lane_infractl_prompts_only.dot

P3 update skeleton:
dots/request-update-skeleton/P3_update_package_lane_infractl_prompts_only.dot

P4 update skeleton:
dots/request-update-skeleton/P4_package_to_codex_update_skeleton_lane_infractl_prompts_only.dot

P5 update skeleton:
dots/request-update-skeleton/P5_evidence_return_update_skeleton_lane_infractl_prompts_only.dot

P6 update skeleton:
dots/request-update-skeleton/P6_next_cycle_update_skeleton_lane_infractl_prompts_only.dot

P1 create organ:
dots/request-create-organs/P1_request_create_organ_infractl_prompts_only.dot

P2 create organ:
dots/request-create-organs/P2_create_writing_organ_lane_infractl_prompts_only.dot

P3 create organ:
dots/request-create-organs/P3_create_package_organ_lane_infractl_prompts_only.dot

P4 create organ:
dots/request-create-organs/P4_package_to_codex_organ_lane_infractl_prompts_only.dot

P5 create organ:
dots/request-create-organs/P5_evidence_return_organ_lane_infractl_prompts_only.dot

P6 create organ:
dots/request-create-organs/P6_next_cycle_organ_lane_infractl_prompts_only.dot

P1 update organ:
dots/request-update-organs/P1_request_update_organ_infractl_prompts_only.dot

P2 update organ:
dots/request-update-organs/P2_update_writing_organ_lane_infractl_prompts_only.dot

P3 update organ:
dots/request-update-organs/P3_update_package_organ_lane_infractl_prompts_only.dot

P4 update organ:
dots/request-update-organs/P4_package_to_codex_update_organ_lane_infractl_prompts_only.dot

P5 update organ:
dots/request-update-organs/P5_evidence_return_update_organ_lane_infractl_prompts_only.dot

P6 update organ:
dots/request-update-organs/P6_next_cycle_update_organ_lane_infractl_prompts_only.dot

5. Read the private project-contract files before producing phase output:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* relevant generated/evidence snapshot structure for the selected batch/run, if present

6. Read the previous-phase output or evidence package before producing phase output.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with a different track, mode, zero lane, or CIP route unless the selected phase DOT explicitly routes there.
* Do not treat one batch as another batch.
* Do not continue to the next phase unless the current phase reaches its PASS/WARN condition and I explicitly confirm the next phase.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected Pn DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected Pn DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* Do not run smoke, mutate the private workspace, mutate `/mnt/egress`, or apply changes unless the selected Pn DOT explicitly addresses the correct agent and all required confirmations are present.
* Do not use `/mnt/ingress` as an active validation root unless the current selected DOT explicitly says it is authoritative for this run.
* Treat earlier phase outputs as evidence inputs only, not as permission to skip current-phase gates.

Source-of-truth order:

1. The selected Pn DOT is the phase-specific execution contract.
2. The main DOT is the overall graph/router frame only.
3. The current phase input package/evidence is the phase-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this phase, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* Lane phase: <PHASE>
* What that phase does in plain English
* Which specific selected Pn DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected Pn DOT was used as the phase-specific execution contract.
* No other Pn, organ, skeleton, update, create, zero, or CIP DOT was executed unless the selected DOT explicitly routed there.
* Previous phase outputs were treated as evidence inputs only, not as permission to skip current-phase gates.

Phase expected behavior:

For P1:
* Validate route identity.
* Propose/request the correct batch/update/organ variables.
* Confirm prerequisites.
* Produce the request/create/update direction artifact required by the selected P1 DOT.
* Stop after P1 unless I confirm P2.

For P2:
* Validate P1 output.
* Read required private sources and hooks.
* Produce writing-lane artifacts required by the selected P2 DOT.
* Preserve route identity.
* Stop after P2 unless I confirm P3.

For P3:
* Validate P2 writing artifacts.
* Package the Codex/create/update handoff according to the selected P3 DOT.
* Include all required manifests, requirement files, and handoff prompts.
* Stop after P3 unless I confirm P4.

For P4:
* Validate the P3 handoff pack.
* Validate the embedded Codex implementation pack.
* Validate public/private layout gates.
* Confirm route identity and package completeness.
* Produce the exact Codex/WSL execution handoff prompt if P4 is a handoff phase.
* Stop after P4. Do not run Codex unless the selected P4 DOT explicitly addresses this session as Codex.

For P5:
* Validate returned implementation evidence.
* Confirm required evidence exists.
* Confirm evidence identity matches the route.
* Confirm implementation stayed within scope.
* Confirm no forbidden actions occurred.
* Classify smoke as PASS/WARN/STOP according to the selected P5 DOT.
* Consider G16 snapshot/import only according to the selected P5 DOT and addressed agent.
* Produce P5 evidence-return closeout content.
* Stop after P5 unless I confirm P6.

For P6:
* Validate P5/G17 decision.
* Determine the next route.
* Recommend whether to continue to the next batch, update current batch, generate/update a companion, run CIP, run 0C, or stop.
* Do not start the next route unless I explicitly confirm.

Route identity to validate:

MODE=<request-create | request-update>
TRACK=<skeleton | organ>
PHASE=<P1 | P2 | P3 | P4 | P5 | P6>
BATCH_NUMBER=<batch-number-or-run-id>
BATCH_SLUG=<batch-slug>
TOPIC=<topic>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce phase report text
* produce draft closeout artifact text in the answer
* classify PASS/WARN/STOP from evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate `/mnt/egress`
* mutate public/private source repos
* run implementation
* run new smoke against the real workspace
* import snapshots into the real private bundle
* continue to the next phase without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files or test results

Idempotency:

* If equivalent phase closeout artifacts already exist in the uploaded private bundle, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected DOT provides an alternate versioned-output rule.

Expected output:
Produce the phase closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected phase DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. Phase input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. Phase-specific validation
12. Scope and safety validation
13. Missing / rejected / deferred items
14. Draft phase artifacts or handoff prompt
15. Snapshot/import decision, if applicable
16. G17 / next-phase decision, if applicable
17. Recommended next action
18. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, phase gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected phase DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.
```

---

## Generic precise prompt template for Config-Infra CIP01-CIP06

Use this template for Config-Infra Pipeline phases CIP01 through CIP06. Fill only the route block, selected CIP DOT path, current input artifacts, and expected files.

```text
Use the uploaded public InfraCTL files, uploaded private project bundle, and any CIP phase-specific input artifacts.

Task:
Run InfraCTL Config-Infra phase <CIP_PHASE> for <CIP_TOPIC>.

Route:
MODE=config-infra
TRACK=cip
PHASE=<CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
CIP_RUN_SLUG=<stable-cip-run-slug>
CIP_TOPIC=<topic-or-manifest-name>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>
ALLOW_CONFIG_MUTATION=<no | yes-only-for-CIP06-after-confirmation>

Input from previous phase:
Use the completed <PREVIOUS_CIP_PHASE> output:

<PATH_OR_FILENAME_OF_PREVIOUS_CIP_OUTPUT>

Expected previous-phase contents include:

* <required-file-1>
* <required-file-2>
* <required-file-3>
* <optional-file-if-present>

Also use:

* public InfraCTL files / public bundle / public code-analysis output
* private project bundle:
  <PRIVATE_BUNDLE_FILENAME_OR_PATH>
* relevant batch/organ evidence, integration requests, manifests, snapshots, plans, or closeout files, if this CIP phase requires them:
  <CIP_INPUT_PACKAGE_OR_EVIDENCE_PATH>

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual CIP DOT = exact CIP phase contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected CIP DOT:

<SELECTED_CIP_DOT_PATH>

Examples:

CIP01:
dots/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot

CIP02:
dots/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot

CIP03:
dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot

CIP04:
dots/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot

CIP05:
dots/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot

CIP06:
dots/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot

5. Read the private project-contract files before producing CIP output:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX*.md files required by the selected CIP DOT, if present
* sources/implementation/HOOKS/HOOK_config_infra_*.md file required by the selected CIP DOT, if present
* relevant generated/evidence snapshot structure for the selected run, if present

6. Read the CIP input artifacts before producing CIP output.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, live-state facts, approvals, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with skeleton/organ P1-P6, zero lanes, or a different CIP phase unless the selected CIP DOT explicitly routes there.
* Do not continue to the next CIP phase unless the current CIP phase reaches its PASS/WARN condition and I explicitly confirm the next phase.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected CIP DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected CIP DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* CIP01-CIP05 are read-only / planning-only by default.
* CIP06 is mutation-default-no and may mutate only after manifest approval, live-state snapshot, implementation plan, exact touch set, selected CIP06 DOT, and explicit operator confirmation.
* Do not run bootstrap, mount, pull, push, package installs, Docker, RunPod, paid APIs, broad smoke, live infra, or destructive account actions unless the selected CIP06 DOT explicitly permits the exact action after confirmation.
* Do not read or print credential contents.
* Do not claim live config truth unless CIP04 has produced or supplied a live config-state snapshot.

Source-of-truth order:

1. The selected CIP DOT is the CIP phase-specific execution contract.
2. The main DOT is the overall graph/router frame only.
3. The current CIP input artifacts are the phase-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this CIP phase, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* CIP phase: <CIP_PHASE>
* What that CIP phase does in plain English
* Which specific selected CIP DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected CIP DOT was used as the phase-specific execution contract.
* No skeleton/organ Pn, zero, or other CIP DOT was executed unless the selected DOT explicitly routed there.
* Previous phase outputs were treated as evidence inputs only, not as permission to skip current CIP gates.

CIP phase expected behavior:

For CIP01:
* Perform source intake and suitability determination.
* Apply the config-infra suitability determiner.
* Produce or draft CONFIG_INFRA_SUITABILITY_DECISION.md/json.
* Do not generate INTEGRATION_REQUEST.md unless the selected DOT explicitly permits a combined route and I confirm.

For CIP02:
* Validate CIP01 decision input.
* Generate or retrofit a rich INTEGRATION_REQUEST.md/json according to the selected DOT and source contract.
* Preserve batch-time suitability truth.
* Do not claim live config truth.

For CIP03:
* Validate source INTEGRATION_REQUEST files.
* Aggregate requests into INTEGRATION_MANIFEST.md/json.
* Classify approved, deferred, blocked, duplicate, already covered, or rejected items.
* Do not resolve live config state.

For CIP04:
* Validate manifest context or explicit read-only live-state request.
* Resolve current live config/tooling state in read-only mode only.
* Produce CONFIG_STATE_SNAPSHOT.md/json and CIP04_POSTCHECK.md.
* Do not plan or apply changes.

For CIP05:
* Validate CIP03 manifest and CIP04 snapshot.
* Produce CONFIG_INTEGRATION_PLAN.md/json and CIP05_POSTCHECK.md.
* Select patch/application classes and exact proposed touch set.
* Do not apply changes.

For CIP06:
* Validate manifest approval, live-state snapshot, implementation plan, selected CIP06 DOT, and explicit operator confirmation.
* Apply only the approved exact touch set if the selected DOT and confirmation permit it.
* Produce CONFIG_INTEGRATION_CLOSEOUT_REPORT.md/json and CIP06_POSTCHECK.md.
* Stop on any missing approval, ambiguous touch set, secret/live/destructive risk, or validation failure.

Route identity to validate:

MODE=config-infra
TRACK=cip
PHASE=<CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
CIP_RUN_SLUG=<stable-cip-run-slug>
CIP_TOPIC=<topic-or-manifest-name>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>
ALLOW_CONFIG_MUTATION=<no | yes-only-for-CIP06-after-confirmation>

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce CIP report text
* produce draft CIP artifact text in the answer
* classify PASS/WARN/STOP from evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate /mnt/egress
* mutate public/private source repos
* run bootstrap, mount, pull, push, package installs, Docker, RunPod, paid APIs, broad smoke, or live infra
* read or print credential contents
* apply config changes
* continue to the next CIP phase without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files, live-state facts, approvals, or test results

Idempotency:

* If equivalent CIP closeout artifacts already exist in the uploaded private bundle, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected DOT provides an alternate versioned-output rule.

Expected output:
Produce the CIP closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected CIP DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. CIP input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. CIP-specific validation
12. Config/live-state/safety validation
13. Missing / rejected / deferred items
14. Draft CIP artifacts or handoff prompt
15. Live-state / application decision, if applicable
16. Recommended next action
17. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, CIP gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, live-state truth is asserted without CIP04 evidence, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected CIP DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.
```

---

## Generic precise prompt template for zero-abc lanes 0A/0B/0C

Use this template for setup, expansion, and tooling-feedback lanes. Fill only the zero lane, selected DOT path, input artifacts, and expected files.

```text
Use the uploaded public InfraCTL files, uploaded private project bundle, and any zero-lane-specific input artifacts.

Task:
Run InfraCTL zero lane <ZERO_LANE> for <ZERO_TOPIC>.

Route:
ZERO_LANE=<0A | 0B | 0C>
PHASE=<public-private-contract-preflight | expansion-routing | cli-extraction-feedback>
ZERO_TOPIC=<topic-or-issue>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Input artifacts:
Use these inputs:

* <public bundle or public repo/code-analysis>
* <private project bundle or private repo/code-analysis>
* <source files, notes, specs, annexes, evidence, helper scripts, bug reports, or workflow-friction artifacts>

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual zero DOT = exact zero-lane contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected zero DOT:

<SELECTED_ZERO_DOT_PATH>

Examples:

0A:
dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot

0B:
dots/zero-abc/0B_expansion_lane_infractl_prompts_only.dot

0C:
dots/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot

5. Read the private project-contract files if relevant:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* relevant sources/generated/evidence snapshot structure if the selected zero DOT requires it

6. Read the zero-lane input artifacts before producing output.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, roots, contracts, helper behavior, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with skeleton/organ P1-P6 or CIP routes unless the selected zero DOT explicitly routes there.
* Do not continue to any follow-up route unless the zero lane reaches its PASS/WARN condition and I explicitly confirm the next route.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected zero DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected zero DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* Do not run implementation, smoke, config mutation, batch creation/update, organ creation/update, or snapshot import unless the selected zero DOT explicitly permits it and addresses the correct agent.
* Do not use /mnt/ingress as an active validation root unless the current selected zero DOT explicitly says it is authoritative for this run.

Source-of-truth order:

1. The selected zero DOT is the zero-lane-specific execution contract.
2. The main DOT is the overall graph/router frame only.
3. The zero-lane input artifacts are the lane-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth when applicable.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this zero lane, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* Zero lane: <0A | 0B | 0C>
* What that zero lane does in plain English
* Which specific selected zero DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected zero DOT was used as the lane-specific execution contract.
* No Pn, CIP, skeleton, organ, create, or update DOT was executed unless the selected zero DOT explicitly routed there.
* Prior outputs were treated as evidence inputs only, not as permission to skip current zero-lane gates.

Zero lane expected behavior:

For 0A:
* Validate public/private setup and contract roots.
* Distinguish public tool/router root from private project-contract root.
* Identify missing or contradictory files.
* Validate whether a normal P-lane or CIP route may proceed.
* Do not patch unless the selected 0A DOT explicitly permits a patch route and I confirm.

For 0B:
* Intake new background material, specs, annexes, papers, notes, or source files.
* Classify where the material belongs.
* Recommend whether to create/update specs, hooks, private sources, prompts, P-lane inputs, or CIP artifacts.
* Do not mutate canonical files unless the selected 0B DOT and addressed agent permit it after confirmation.

For 0C:
* Record reusable CLI/helper/workflow extraction opportunities.
* Identify repeated manual friction, helper candidates, router/DOT corrections, packaging helpers, validation helpers, or script candidates.
* Produce a precise extraction note, patch scope, or Codex/WSL prompt if appropriate.
* Do not implement broad CLI changes unless the selected 0C DOT and addressed agent permit it after confirmation.

Route identity to validate:

ZERO_LANE=<0A | 0B | 0C>
PHASE=<public-private-contract-preflight | expansion-routing | cli-extraction-feedback>
ZERO_TOPIC=<topic-or-issue>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce zero-lane report text
* produce draft artifacts or extraction notes in the answer
* classify PASS/WARN/STOP from files/evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate /mnt/egress
* mutate public/private source repos
* run implementation
* run smoke against the real workspace
* import snapshots into the real private bundle
* apply config changes
* continue to a P lane, CIP lane, or next zero route without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files, roots, contracts, helper behavior, or test results

Idempotency:

* If equivalent zero-lane outputs already exist in the uploaded private bundle, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected DOT provides an alternate versioned-output rule.

Expected output:
Produce the zero-lane closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. Zero-lane input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. Zero-lane-specific validation
12. Scope and safety validation
13. Missing / rejected / deferred items
14. Draft zero-lane artifacts or handoff prompt
15. Recommended next route
16. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, zero-lane gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, roots/contracts cannot be trusted, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.
```

---

## Generic precise zero-lane prompt template — 0A / 0B / 0C

Use the uploaded public InfraCTL files, uploaded private project bundle, and any zero-lane-specific input artifacts.

Task:
Run InfraCTL zero lane <ZERO_LANE> for <ZERO_TASK>.

Route:
MODE=zero
TRACK=<0A-public-private-contract | 0B-expansion | 0C-cli-extraction>
ZERO_LANE=<0A | 0B | 0C>
PHASE=<zero-lane phase label>
TOPIC=<topic-or-run-purpose>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Input artifacts:
Use the following input files or folders:

<INPUT_PATH_OR_FILENAME_1>
<INPUT_PATH_OR_FILENAME_2>
<INPUT_PATH_OR_FILENAME_3>

Also use:

* public InfraCTL files / public bundle / public code-analysis output
* private project bundle:
  <PRIVATE_BUNDLE_FILENAME_OR_PATH>
* source/evidence/spec/workflow files relevant to the selected zero lane

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual zero DOT = exact zero-lane contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected zero-lane DOT:

<SELECTED_ZERO_DOT_PATH>

Examples:

0A public/private contract:
dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot

0B expansion lane:
dots/zero-abc/0B_expansion_lane_infractl_prompts_only.dot

0C CLI extraction feedback:
dots/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot

5. Read the private project-contract files before producing zero-lane output, when relevant:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* relevant source/evidence/generated structure, if present

6. Read only the source files, evidence files, specs, workflow notes, or artifacts named in the variable block.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with a P1-P6 batch lane, organ lane, skeleton lane, update lane, create lane, or CIP route unless the selected zero DOT explicitly routes there.
* Do not continue into a batch phase unless this zero lane reaches its PASS/WARN condition and I explicitly confirm the next route.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected zero DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected zero DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* Do not run smoke, mutate the private workspace, mutate `/mnt/egress`, or apply changes unless the selected zero DOT explicitly addresses the correct agent and all required confirmations are present.
* Do not use `/mnt/ingress` as an active validation root unless the current selected DOT explicitly says it is authoritative for this run.
* Treat prior chat summaries as advisory only, not as source-of-truth evidence.

Source-of-truth order:

1. The selected zero DOT is the zero-lane execution contract.
2. The main DOT is the overall graph/router frame only.
3. The current zero-lane input artifacts are the task-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this zero lane, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* Zero lane: <0A | 0B | 0C>
* What that zero lane does in plain English
* Which specific selected zero DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected zero DOT was used as the zero-lane execution contract.
* No P1-P6, organ, skeleton, update, create, or CIP DOT was executed unless the selected zero DOT explicitly routed there.
* Any batch/evidence/source artifacts were treated as inputs only, not as permission to skip zero-lane gates.

Zero-lane expected behavior:

For 0A:
* Validate public/private setup.
* Confirm public tool root and private project root.
* Confirm expected public files, private project files, DOT tree, schemas, scripts, and source maps.
* Identify contract contradictions, missing paths, stale root assumptions, or unsafe routing conditions.
* Produce a public/private contract preflight report.
* Stop after 0A unless I confirm a follow-up lane.

For 0B:
* Route new background material, notes, specs, annexes, papers, workflow text, or source files.
* Decide whether material belongs in private sources, specs, hooks, workflow docs, companions, batch inputs, CIP, or no-op/defer.
* Produce a routing decision and, if allowed, draft/update artifacts.
* Stop after 0B unless I confirm the next lane.

For 0C:
* Record reusable tooling, helper, CLI extraction, workflow friction, repeated manual steps, or router issues.
* Decide whether the issue belongs in public CLI, public docs, DOTs, private workflow notes, CLI_EXTRACTION_NOTES, or a later scoped patch.
* Produce a CLI extraction feedback report or scoped patch prompt.
* Stop after 0C unless I confirm execution of the patch or next route.

Route identity to validate:

MODE=zero
TRACK=<0A-public-private-contract | 0B-expansion | 0C-cli-extraction>
ZERO_LANE=<0A | 0B | 0C>
PHASE=<zero-lane phase label>
TOPIC=<topic>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce zero-lane report text
* produce draft closeout artifact text in the answer
* classify PASS/WARN/STOP from evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate `/mnt/egress`
* mutate public/private source repos
* run implementation
* run new smoke against the real workspace
* import snapshots into the real private bundle
* continue to another lane without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files or test results

Idempotency:

* If equivalent zero-lane closeout artifacts already exist in the uploaded private bundle, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected DOT provides an alternate versioned-output rule.

Expected output:
Produce the zero-lane closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. Zero-lane input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. Zero-lane-specific validation
12. Scope and safety validation
13. Missing / rejected / deferred items
14. Draft zero-lane artifacts or handoff prompt
15. Recommended next action
16. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, zero-lane gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected zero DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.

---

## Generic precise Config-Infra CIP prompt template — CIP01 / CIP02 / CIP03 / CIP04 / CIP05 / CIP06

Use the uploaded public InfraCTL files, uploaded private project bundle, and any Config-Infra CIP input artifacts.

Task:
Run Config-Infra CIP phase <CIP_PHASE> for <CIP_TOPIC>.

Route:
MODE=config-infra
TRACK=cip
PHASE=<CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
CIP_RUN_SLUG=<stable-cip-run-slug>
TOPIC=<topic-or-run-purpose>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Input from previous CIP phase or source:
Use the completed <PREVIOUS_CIP_PHASE_OR_SOURCE> artifact:

<PATH_OR_FILENAME_OF_INPUT_ARTIFACT>

Expected input contents include:

* <required-file-1>
* <required-file-2>
* <required-file-3>
* <optional-file-if-present>

Also use:

* public InfraCTL files / public bundle / public code-analysis output
* private project bundle:
  <PRIVATE_BUNDLE_FILENAME_OR_PATH>
* relevant batch evidence, integration requests, manifests, config snapshots, implementation plans, or operator notes

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual CIP DOT = exact Config-Infra phase contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected CIP DOT:

<SELECTED_CIP_DOT_PATH>

Examples:

CIP01:
dots/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot

CIP02:
dots/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot

CIP03:
dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot

CIP04:
dots/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot

CIP05:
dots/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot

CIP06:
dots/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot

5. Read the private project-contract files before producing CIP output:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* source/spec/hook registry entries relevant to the selected CIP phase

6. Read only the CIP input artifacts named in the variable block.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with a P1-P6 batch lane, organ lane, skeleton lane, update lane, create lane, or zero route unless the selected CIP DOT explicitly routes there.
* Do not continue to the next CIP phase unless the current CIP phase reaches its PASS/WARN condition and I explicitly confirm the next phase.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected CIP DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected CIP DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* Do not run smoke, mutate the private workspace, mutate `/mnt/egress`, mutate live config, run bootstrap, mount, pull, push, install packages, run Docker, run RunPod, call paid APIs, or apply changes unless the selected CIP DOT explicitly addresses the correct agent and all required confirmations are present.
* CIP01-CIP05 are read-only / planning-only by default.
* CIP06 is mutation-default-no and may mutate only after manifest approval, live-state snapshot, implementation plan, exact touch set, selected CIP06 DOT, explicit confirmation, and passing safety gates.
* Do not use `/mnt/ingress` as an active validation root unless the current selected DOT explicitly says it is authoritative for this run.
* Treat earlier CIP or batch outputs as evidence inputs only, not as permission to skip current CIP gates.

Source-of-truth order:

1. The selected CIP DOT is the phase-specific execution contract.
2. The main DOT is the overall graph/router frame only.
3. The current CIP input artifact is the phase-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this CIP phase, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* CIP phase: <CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
* What that CIP phase does in plain English
* Which specific selected CIP DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected CIP DOT was used as the Config-Infra phase-specific execution contract.
* No P1-P6, organ, skeleton, update, create, or zero DOT was executed unless the selected CIP DOT explicitly routed there.
* Previous CIP or batch outputs were treated as evidence inputs only, not as permission to skip current CIP gates.

CIP phase expected behavior:

For CIP01:
* Perform source intake and config-infra suitability determination.
* Apply the CONFIG_INFRA_SUITABILITY_DETERMINER.
* Classify evidence strength, recurrence, role fit, config impact, risk, fate, manifest eligibility, and recommended next route.
* Produce CONFIG_INFRA_SUITABILITY_DECISION.md and optional JSON.
* Do not generate INTEGRATION_REQUEST.md unless the selected CIP01 DOT explicitly permits it and I confirm.

For CIP02:
* Validate CIP01 decision.
* Generate or retrofit a rich INTEGRATION_REQUEST.md using the accepted config-infra schema.
* Preserve batch-time suitability truth.
* Do not approve config mutation or resolve live config state.
* Stop after CIP02 unless I confirm CIP03.

For CIP03:
* Aggregate one or more INTEGRATION_REQUEST artifacts.
* Produce INTEGRATION_MANIFEST.md / JSON.
* Classify items as approved, deferred, blocked, duplicate, already covered, or rejected.
* Do not resolve live config state.
* Stop after CIP03 unless I confirm CIP04.

For CIP04:
* Resolve current live config/tooling state in read-only mode.
* Produce CONFIG_STATE_SNAPSHOT.md / JSON and CIP04_POSTCHECK.md.
* Do not plan implementation or apply changes.
* Stop after CIP04 unless I confirm CIP05.

For CIP05:
* Produce CONFIG_INTEGRATION_PLAN.md / JSON and CIP05_POSTCHECK.md from approved manifest items and live config snapshot.
* Select patch classes, exact touch set, validation plan, rollback/deferral notes, and safety gates.
* Do not apply changes.
* Stop after CIP05 unless I confirm CIP06.

For CIP06:
* Apply only manifest-approved, planned, explicitly confirmed config changes.
* Enforce exact touch set and idempotency.
* Produce CONFIG_INTEGRATION_CLOSEOUT_REPORT.md / JSON, CIP06_POSTCHECK.md, and validation evidence.
* Stop after CIP06 unless I confirm any follow-up route.

Route identity to validate:

MODE=config-infra
TRACK=cip
PHASE=<CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
CIP_RUN_SLUG=<stable-cip-run-slug>
TOPIC=<topic>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>

CIP output root rule:

For real workspace runs, use:

/workspace/runs/cip/<CIP_RUN_SLUG>/<cip-phase>/

where <cip-phase> is:

* cip01
* cip02
* cip03
* cip04
* cip05
* cip06

For webchat runs, produce draft output content in chat or sandbox artifacts only. Do not claim real workspace mutation.

Canonical CIP output filenames:

CIP01:
* CONFIG_INFRA_SUITABILITY_DECISION.md
* CONFIG_INFRA_SUITABILITY_DECISION.json

CIP02:
* INTEGRATION_REQUEST.md
* INTEGRATION_REQUEST.json

CIP03:
* INTEGRATION_MANIFEST.md
* INTEGRATION_MANIFEST.json

CIP04:
* CONFIG_STATE_SNAPSHOT.md
* CONFIG_STATE_SNAPSHOT.json
* CIP04_POSTCHECK.md

CIP05:
* CONFIG_INTEGRATION_PLAN.md
* CONFIG_INTEGRATION_PLAN.json
* CIP05_POSTCHECK.md

CIP06:
* CONFIG_INTEGRATION_CLOSEOUT_REPORT.md
* CONFIG_INTEGRATION_CLOSEOUT_REPORT.json
* CIP06_POSTCHECK.md

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce CIP report text
* produce draft CIP artifact text in the answer
* classify PASS/WARN/STOP from evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate `/mnt/egress`
* mutate live config
* mutate public/private source repos
* run implementation
* run bootstrap, mount, pull, push, package installs, Docker, RunPod, paid APIs, or broad smoke
* read or print credential contents
* import snapshots into the real private bundle
* continue to the next CIP phase without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files or test results

Idempotency:

* If equivalent CIP artifacts already exist in the uploaded private bundle or provided CIP output folder, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected CIP DOT provides an alternate versioned-output rule.

Expected output:
Produce the CIP closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected CIP DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. CIP input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. CIP-specific validation
12. Scope and safety validation
13. Missing / rejected / deferred items
14. Draft CIP artifacts or handoff prompt
15. Recommended next action
16. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, CIP gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected CIP DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected CIP DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.
