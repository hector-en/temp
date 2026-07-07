# InfraCTL Prompt-Only Flow README

This README explains how to use `infractl.zip` as a prompt-instruction library in a fresh ChatGPT or Codex chat.

Your zip should have this shape:

```text
infractl.zip
└── infractl/
    ├── infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
    ├── zero-abc/
    ├── request-create-skeleton/
    ├── request-update-skeleton/
    ├── request-create-organs/
    ├── request-update-organs/
    └── config-infra/
        ├── CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
        ├── CIP02_rich_integration_request_generation_infractl_prompts_only.dot
        ├── CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
        ├── CIP04_live_config_state_resolution_infractl_prompts_only.dot
        ├── CIP05_config_implementation_planning_infractl_prompts_only.dot
        └── CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

The root DOT file is the canonical main pipeline. The folders contain prompt-only DOTs for the actual route you want to run.

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
2. infractl/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
3. the selected prompt-only DOT for the route and phase, or the selected CIP DOT from `infractl/config-infra/`
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
Then use the 0A DOT from infractl/zero-abc/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
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
Then use the 0B DOT from infractl/zero-abc/.

Suggest the routing and variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/zero-abc/0B_expansion_lane_infractl_prompts_only.dot
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
Then use the 0C DOT from infractl/zero-abc/.

Suggest the extraction note first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot
```

---

# Config-Infra CIP routes

Use these routes when a batch or organ workflow needs structured config/lv/environment integration instead of an ad hoc handoff.

The real uploaded `infractl.zip` includes this folder:

```text
infractl/config-infra/
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
Then use the CIP01 DOT from infractl/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
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
Then use the CIP02 DOT from infractl/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot
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
Then use the CIP03 DOT from infractl/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
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
Then use the CIP04 DOT from infractl/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot
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
Then use the CIP05 DOT from infractl/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot
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
Then use the CIP06 DOT from infractl/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
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
Then use the P1 DOT from infractl/request-create-skeleton/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-skeleton/P1_request_create_skeleton_infractl_prompts_only.dot
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
Then use the P2 DOT from infractl/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-skeleton/P2_create_writing_lane_infractl_prompts_only.dot
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
Then use the P3 DOT from infractl/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-skeleton/P3_create_package_lane_infractl_prompts_only.dot
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
Then use the P4 DOT from infractl/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot
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
Then use the P5 DOT from infractl/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-skeleton/P5_evidence_return_lane_infractl_prompts_only.dot
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
Then use the P6 DOT from infractl/request-create-skeleton/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-skeleton/P6_next_cycle_lane_infractl_prompts_only.dot
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
Then use the P1 DOT from infractl/request-update-skeleton/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-skeleton/P1_request_update_skeleton_infractl_prompts_only.dot
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
Then use the P2 DOT from infractl/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-skeleton/P2_update_writing_lane_infractl_prompts_only.dot
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
Then use the P3 DOT from infractl/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-skeleton/P3_update_package_lane_infractl_prompts_only.dot
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
Then use the P4 DOT from infractl/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-skeleton/P4_package_to_codex_update_skeleton_lane_infractl_prompts_only.dot
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
Then use the P5 DOT from infractl/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-skeleton/P5_evidence_return_update_skeleton_lane_infractl_prompts_only.dot
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
Then use the P6 DOT from infractl/request-update-skeleton/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-skeleton/P6_next_cycle_update_skeleton_lane_infractl_prompts_only.dot
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
Then use the P1 DOT from infractl/request-create-organs/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-organs/P1_request_create_organ_infractl_prompts_only.dot
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
Then use the P2 DOT from infractl/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-organs/P2_create_writing_organ_lane_infractl_prompts_only.dot
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
Then use the P3 DOT from infractl/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-organs/P3_create_package_organ_lane_infractl_prompts_only.dot
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
Then use the P4 DOT from infractl/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-organs/P4_package_to_codex_organ_lane_infractl_prompts_only.dot
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
Then use the P5 DOT from infractl/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-organs/P5_evidence_return_organ_lane_infractl_prompts_only.dot
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
Then use the P6 DOT from infractl/request-create-organs/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-create-organs/P6_next_cycle_organ_lane_infractl_prompts_only.dot
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
Then use the P1 DOT from infractl/request-update-organs/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-organs/P1_request_update_organ_infractl_prompts_only.dot
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
Then use the P2 DOT from infractl/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-organs/P2_update_writing_organ_lane_infractl_prompts_only.dot
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
Then use the P3 DOT from infractl/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-organs/P3_update_package_organ_lane_infractl_prompts_only.dot
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
Then use the P4 DOT from infractl/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-organs/P4_package_to_codex_update_organ_lane_infractl_prompts_only.dot
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
Then use the P5 DOT from infractl/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-organs/P5_evidence_return_update_organ_lane_infractl_prompts_only.dot
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
Then use the P6 DOT from infractl/request-update-organs/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
infractl/request-update-organs/P6_next_cycle_update_organ_lane_infractl_prompts_only.dot
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
