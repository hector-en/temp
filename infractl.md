# infractl Prompt-Only Execution Router

This file is the human-facing router for the prompt-only Infra-Skeleton workflow bundle.

When operating inside `/workspace/repos/infractl-public`, read DOT files from:

```text
dots/
```

Use repo-local `dots/...` paths for Codex/WSL/local instructions. Keep `infractl.zip` upload wording for fresh webchat sessions, but do not point repo-local operators at `infractl/<lane>/...`.

It is intended to be uploaded together with:

```text
infractl.zip
```

where the zip root is:

```text
infractl/
```

and the canonical main pipeline DOT is saved at the root level of that folder.

Expected root-level layout:

```text
infractl/
  infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
  zero-abc/
  request-create-skeleton/
  request-update-skeleton/
  request-create-organs/
  request-update-organs/
  config-infra/
```

## Purpose

Use this bundle to start a fresh ChatGPT or Codex session and run exactly one Infra-Skeleton prompt-only lane at a time.

The bundle is not itself the public `infractl` tool and is not itself the private project bundle. It is an execution-instruction library. The model must read the canonical main DOT plus the selected prompt-only DOT, determine whether it is the addressed agent, suggest missing variables, ask for confirmation, and only then proceed.

## Cold-start instruction to paste into a new chat

Use this when starting a fresh ChatGPT/Codex session:

```text
I uploaded infractl.zip and infractl.md.

Read infractl.md first.
Then inspect infractl.zip.
Use the root-level canonical main DOT:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

Then choose the correct prompt-only DOT for the lane I request.

Do not execute anything immediately.
First:
1. Tell me which lane you selected.
2. Tell me which DOT file you will use.
3. Suggest the variable block from available context.
4. Label each variable as user-provided, inferred, default-safe, or unknown.
5. Ask me to confirm or correct the variables.

Only proceed after I explicitly confirm or say "go with these suggested values".
If the selected DOT is addressed to another agent, stop and tell me which agent should run it.
```

## Required execution rules

Every prompt-only DOT must be treated as a self-executable instruction file, but only after the model has read the main v7 DOT and confirmed that the selected lane matches the operator's request.

The model must obey these rules:

```text
1. Always read this infractl.md first.
2. Always read the canonical main v7 DOT second.
3. Read exactly one selected prompt-only DOT third.
4. Do not mix lanes unless the selected DOT explicitly routes to another lane.
5. Do not skip the variable confirmation gate.
6. Do not overwrite existing artifacts unless ALLOW_OVERWRITE=yes.
7. Do not run Codex-only steps inside ChatGPT unless the DOT says ChatGPT is the addressed agent.
8. Do not run ChatGPT-only planning steps inside Codex unless the DOT says Codex is the addressed agent.
9. Stop if the public tool, private bundle, evidence files, or required route files are missing.
10. Use webchat-sandbox boundaries unless the selected DOT and the operator explicitly authorize another mode.
```

## Variable-block behavior

The model must help the operator. It must not give the operator an empty form when values can be inferred.

For every selected lane, the model must first propose a variable block:

```text
VARIABLE=value  # status: user-provided | inferred | default-safe | unknown
```

The model should infer values from:

```text
- the selected route folder
- the selected DOT filename
- the canonical main v7 DOT
- the uploaded zip layout
- the selected CIP phase when MODE=config-infra and TRACK=cip
- previously supplied operator text
- batch mapping files if available
- evidence paths if available
```

Then it must ask:

```text
Confirm these variables, or provide corrections. I will not execute until confirmed.
```

If variables are unknown, the model should ask only for the missing or unsafe values, not for everything.

## Agent-addressing rules

Each prompt-only DOT contains addressing gates for ChatGPT, Codex, and the WSL/operator environment.

The model must identify whether the selected lane is currently addressed to:

```text
- ChatGPT/webchat
- Codex
- WSL/operator shell
```

If the wrong agent is being asked to execute a step, the model must stop and output the exact handoff prompt or command for the correct agent.

## Config-Infra CIP output root rule

For every CIP run, use:

```text
/workspace/runs/cip/<slug-title>/<cip-phase>/
```

where:

```text
- <slug-title> is the CIP topic/run slug
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
Legacy CIP artifacts may exist under /workspace/cipXX/<topic>/ or /workspace/runs/cip/cipXX/<topic>/. For new runs, addendums, and future phases, write to /workspace/runs/cip/<slug-title>/cipXX/. Read legacy paths as inputs only when needed. Do not move or overwrite them unless an explicit migration task is approved.
```

## Route folders

### 0-lanes

Folder:

```text
dots/zero-abc/
```

Expected files:

```text
0A_public_private_contract_infractl_prompts_only.dot
0B_expansion_lane_infractl_prompts_only.dot
0C_cli_extraction_feedback_infractl_prompts_only.dot
```

Use these when:

```text
0A: You need to validate public/private contract and real layout before running a route.
0B: You need to ingest new notes, specs, annexes, hooks, or knowledge-expansion material.
0C: You need to record CLI/tooling extraction feedback, reusable helper scripts, Codex friction, or candidates for public-tool promotion.
```

### request-create + skeleton

Folder:

```text
dots/request-create-skeleton/
```

Use this route when:

```text
MODE=request-create
TRACK=skeleton
```

Expected lane files:

```text
P1_request_create_skeleton_infractl_prompts_only.dot
P2_create_writing_lane_infractl_prompts_only.dot
P3_create_package_lane_infractl_prompts_only.dot
P4_package_to_codex_lane_infractl_prompts_only.dot
P5_evidence_return_lane_infractl_prompts_only.dot
P6_next_cycle_lane_infractl_prompts_only.dot
```

Route summary:

```text
P1: Generate the request folder for a new skeleton batch.
P2: Convert the request folder into Codex create-writing files.
P3: Package the create-writing files into a Codex-ready create pack.
P4: Validate real layout and hand the pack to Codex.
P5: Collect execution evidence, snapshot/export, and make the G17 phase decision.
P6: Choose the next route after the completed cycle.
```

### request-update + skeleton

Folder:

```text
dots/request-update-skeleton/
```

Use this route when:

```text
MODE=request-update
TRACK=skeleton
```

Expected lane files:

```text
P1_request_update_skeleton_infractl_prompts_only.dot
P2_update_writing_lane_infractl_prompts_only.dot
P3_update_package_lane_infractl_prompts_only.dot
P4_package_to_codex_update_skeleton_lane_infractl_prompts_only.dot
P5_evidence_return_update_skeleton_lane_infractl_prompts_only.dot
P6_next_cycle_update_skeleton_lane_infractl_prompts_only.dot
```

Route summary:

```text
P1: Generate the update request only after verifying existing skeleton evidence.
P2: Convert the request folder into Codex update-writing files.
P3: Package the update-writing files into a Codex-ready update pack.
P4: Validate real layout and hand the update pack to Codex.
P5: Collect update evidence, snapshot/export, and make the G17 phase decision.
P6: Choose the next route after the completed update cycle.
```

### request-create + organs

Folder:

```text
dots/request-create-organs/
```

Use this route when:

```text
MODE=request-create
TRACK=organ
```

Expected lane files:

```text
P1_request_create_organ_infractl_prompts_only.dot
P2_create_writing_organ_lane_infractl_prompts_only.dot
P3_create_package_organ_lane_infractl_prompts_only.dot
P4_package_to_codex_organ_lane_infractl_prompts_only.dot
P5_evidence_return_organ_lane_infractl_prompts_only.dot
P6_next_cycle_organ_lane_infractl_prompts_only.dot
```

Route summary:

```text
P1: Generate the organ/R01 scaffold request.
P2: Convert the organ request folder into Codex create-writing files.
P3: Package the organ create-writing files into a Codex-ready create pack.
P4: Validate real layout and hand the organ create pack to Codex.
P5: Collect organ scaffold evidence, snapshot/export, and make the G17 phase decision.
P6: Choose the next route after the organ scaffold cycle.
```

Important organ-context rules:

```text
- Organ creation starts at R01; do not treat it as skeleton Batch 01.
- Do not substitute skeleton metadata for organ metadata.
- Use organ transition context from 01_B0, 01_B1, and day_to_day_organs_run.md when available.
```

### request-update + organs

Folder:

```text
dots/request-update-organs/
```

Use this route when:

```text
MODE=request-update
TRACK=organ
```

Expected lane files:

```text
P1_request_update_organ_infractl_prompts_only.dot
P2_update_writing_organ_lane_infractl_prompts_only.dot
P3_update_package_organ_lane_infractl_prompts_only.dot
P4_package_to_codex_update_organ_lane_infractl_prompts_only.dot
P5_evidence_return_update_organ_lane_infractl_prompts_only.dot
P6_next_cycle_update_organ_lane_infractl_prompts_only.dot
```

Route summary:

```text
P1: Generate an organ update request only after prior organ/R01 evidence exists.
P2: Convert the organ update request folder into Codex update-writing files.
P3: Package the organ update-writing files into a Codex-ready update pack.
P4: Validate real layout and hand the organ update pack to Codex.
P5: Collect organ update evidence, snapshot/export, and make the G17 phase decision.
P6: Choose the next route after the organ update cycle.
```

Blocking organ-update rules:

```text
- STOP if no prior organ/R01 evidence exists.
- STOP if only skeleton evidence exists.
- STOP if R01 scaffold has not been completed.
- STOP if the operator is trying to update skeleton evidence through the organ lane.
```

### config-infra + CIP

Folder:

```text
dots/config-infra/
```

Use this route when:

```text
MODE=config-infra
TRACK=cip
PHASE=CIP01|CIP02|CIP03|CIP04|CIP05|CIP06
```

Expected CIP files:

```text
CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
CIP02_rich_integration_request_generation_infractl_prompts_only.dot
CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
CIP04_live_config_state_resolution_infractl_prompts_only.dot
CIP05_config_implementation_planning_infractl_prompts_only.dot
CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

Route summary:

```text
CIP01: Source intake and suitability determination.
CIP02: Rich integration request generation or retrofit.
CIP03: Manifest aggregation and approval.
CIP04: Live config-state resolution.
CIP05: Config implementation planning.
CIP06: Idempotent application and closeout.
```

Use CIP when a batch or organ workflow produces configuration, environment, Python/lv, package-stack, bootstrap, account, mount, or workflow-integration implications that need structured handoff instead of an ad hoc note. Normal skeleton/organ create/update lanes may produce a rich `INTEGRATION_REQUEST.md`; the CIP path is the follow-on route family for deciding what to do with those requests.

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

CIP safety model:

```text
CIP01-CIP05 are read-only / planning-only.
CIP06 defaults to no mutation.
CIP06 may apply changes only after manifest approval, live config-state snapshot, implementation plan, exact file touch set, explicit confirmation, and passing safety gates.
ALLOW_CONFIG_MUTATION=no unless CIP06 and all explicit gates pass.
```

Config-Infra source-contract rule:

```text
Do not infer CIP source-contract filenames from phase titles.
Use the hardcoded CIP source-contract map and registry lookup.
If a mapped file is missing, search hooks.yaml / files.yaml / candidate filenames before declaring it missing.
Do not invent alternate filenames.
```

Config-Infra hardcoded source-contract map:

```text
CIP01:
  phase_title: Source intake and suitability determination
  spec_annex:
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX01_config_infra_suitability_determiner.md
  hook:
    sources/implementation/HOOKS/HOOK_config_infra_suitability_assessment.md
  primary_output:
    CONFIG_INFRA_SUITABILITY_DECISION.md
    CONFIG_INFRA_SUITABILITY_DECISION.json

CIP02:
  phase_title: Rich integration request generation
  spec_annex:
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX02_integration_request_schema.md
  hook:
    sources/implementation/HOOKS/HOOK_config_infra_rich_integration_request.md
  primary_output:
    INTEGRATION_REQUEST.md
    INTEGRATION_REQUEST.json

CIP03:
  phase_title: Manifest aggregation and approval
  spec_annex:
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX03_integration_manifest_schema.md
  hook:
    sources/implementation/HOOKS/HOOK_config_infra_manifest_gate.md
  primary_output:
    INTEGRATION_MANIFEST.md
    INTEGRATION_MANIFEST.json

CIP04:
  phase_title: Live config-state resolution
  spec_annex:
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX04_config_state_snapshot_schema.md
  hook:
    sources/implementation/HOOKS/HOOK_config_infra_live_resolution_gate.md
  primary_output:
    CONFIG_STATE_SNAPSHOT.md
    CONFIG_STATE_SNAPSHOT.json
  postcheck:
    CIP04_POSTCHECK.md

CIP05:
  phase_title: Config implementation planning
  spec_annex:
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX05_config_integration_plan_schema.md
  supporting_annex:
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX06_config_patch_classes.md
  hook:
    sources/implementation/HOOKS/HOOK_config_infra_implementation_plan_gate.md
  primary_output:
    CONFIG_INTEGRATION_PLAN.md
    CONFIG_INTEGRATION_PLAN.json
  postcheck:
    CIP05_POSTCHECK.md

CIP06:
  phase_title: Idempotent application and closeout
  spec_annex:
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX06_config_patch_classes.md
  supporting_annex:
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX07_config_integration_implementer_spec.md
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX08_config_integration_implementer_runbook.md
    sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX09_codex_pack_template_config_integration.md
  hook:
    sources/implementation/HOOKS/HOOK_config_infra_closeout_snapshot_companion.md
  primary_output:
    CONFIG_INTEGRATION_CLOSEOUT_REPORT.md
    CONFIG_INTEGRATION_CLOSEOUT_REPORT.json
  postcheck:
    CIP06_POSTCHECK.md
```

Registry lookup rule:

```text
For every CIP phase:
1. Resolve the phase through the hardcoded CIP source-contract map.
2. If a private bundle or real workspace is available, read hooks.yaml and files.yaml before declaring a file missing.
3. Verify the mapped spec annex and hook exist.
4. If a mapped file is missing, search for candidate files by CIP phase number, hook id, and output schema name.
5. Report registry drift separately from a true missing file.
6. Stop rather than inventing alternate filenames.
```

CIP phase inputs:

```text
CIP01: raw source files, notes, config requirements, or workflow requirements.
CIP02: CIP01 suitability decision if available, source material, or an existing thin integration request to retrofit.
CIP03: one or more INTEGRATION_REQUEST.md files plus batch/organ evidence and context if available.
CIP04: CIP03 INTEGRATION_MANIFEST.md/json plus current config/tooling context or target workspace access when running in Codex/WSL.
CIP05: CIP03 INTEGRATION_MANIFEST.md/json plus CIP04 CONFIG_STATE_SNAPSHOT.md/json.
CIP06: CIP03 manifest, CIP04 snapshot, CIP05 CONFIG_INTEGRATION_PLAN.md/json, and approved exact file touch set / confirmation context.
```

CIP04 naming guardrail:

```text
The phase title is "Live config-state resolution", but the canonical ANX file is:
  SPEC_config_infra_integration_pipeline-ANX04_config_state_snapshot_schema.md
and the canonical hook is:
  HOOK_config_infra_live_resolution_gate.md
The canonical outputs are:
  CONFIG_STATE_SNAPSHOT.md
  CONFIG_STATE_SNAPSHOT.json
  CIP04_POSTCHECK.md
Do not use LIVE_CONFIG_STATE_SNAPSHOT.* or HOOK_config_infra_live_state_resolution.md unless a future registry explicitly changes the contract.
```

Blocking CIP rules:

```text
- STOP if a required prior CIP artifact is missing.
- STOP if the operator asks CIP06 to mutate without manifest approval, live state snapshot, implementation plan, exact touch set, and explicit confirmation.
- STOP if the request needs live config truth but the selected phase is CIP01, CIP02, or CIP03.
- STOP if the selected DOT is not exactly one CIP phase DOT from dots/config-infra/.
- STOP if the route tries to mix CIP phases in one run.
```

## How to ask for a run

Use one of these forms.

### Start a route from P1

```text
Use infractl.md and infractl.zip.
Run the prompt-only route:
MODE=request-update
TRACK=skeleton
PHASE=P1

First suggest variables and ask me to confirm.
Do not execute until confirmed.
```

### Continue a route from a later phase

```text
Use infractl.md and infractl.zip.
Continue the prompt-only route:
MODE=request-update
TRACK=skeleton
PHASE=P3

Use the relevant P3 DOT only.
First suggest variables and ask me to confirm.
Do not execute until confirmed.
```

### Run a 0-lane

```text
Use infractl.md and infractl.zip.
Run 0C CLI extraction feedback.

First suggest variables and ask me to confirm.
Do not execute until confirmed.
```

### Run a Config-Infra CIP lane

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP03 manifest aggregation and approval.

Read infractl.md first.
Read the root main v7 DOT next.
Then use exactly one selected CIP DOT from:
dots/config-infra/

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until confirmed.
```

### Decide the next Config-Infra CIP phase

```text
Use infractl.md and infractl.zip.
I need help deciding which Config-Infra CIP phase to use for this request.
Given my current artifacts, tell me whether I should run CIP01, CIP02, CIP03, CIP04, CIP05, or CIP06 next.
Do not execute yet. First return the recommended phase, required files, missing prerequisites, and variable block.
```

## Phase selection table

```text
PHASE=P1  -> direction/request generation
PHASE=P2  -> request-to-writing
PHASE=P3  -> writing-to-package
PHASE=P4  -> package-to-Codex/layout-gate
PHASE=P5  -> evidence-return/snapshot/export/phase-decision
PHASE=P6  -> next-cycle routing

PHASE=CIP01 -> source intake and suitability determination
PHASE=CIP02 -> rich integration request generation or retrofit
PHASE=CIP03 -> manifest aggregation and approval
PHASE=CIP04 -> live config-state resolution
PHASE=CIP05 -> config implementation planning
PHASE=CIP06 -> idempotent application and closeout
```

## Safety boundaries

Unless the selected DOT and operator explicitly say otherwise, the model must assume:

```text
PROFILE=webchat-sandbox
ALLOW_OVERWRITE=no
NO_LIVE_INFRA=yes
NO_MODEL_API_CALLS=yes
NO_SMOKE_RERUN_UNLESS_EXPLICIT=yes
NO_HISTORICAL_EVIDENCE_OVERWRITE=yes
ALLOW_CONFIG_MUTATION=no
```

For ChatGPT/webchat lanes, the model should generate files, instructions, commands, or validation reports in the current sandbox only.

For Codex lanes, the model should not pretend to execute Codex from ChatGPT. It must provide the Codex handoff prompt and wait for returned Codex evidence.

For WSL/operator shell lanes, the model should output commands for the operator to run, then wait for pasted output.

## Success criteria

A lane run is successful only when the selected prompt-only DOT reaches its PASS condition.

The model must end every run with:

```text
Selected route:
Selected DOT:
Addressed agent:
Variables confirmed:
Actions performed:
Files created or checked:
Evidence status:
Next DOT:
PASS / WARN / STOP:
```

## What this bundle does not do

This bundle does not replace:

```text
- the public infractl tool repository
- the private project bundle
- real evidence files
- Codex execution
- WSL/operator shell execution
```

It only tells a fresh ChatGPT/Codex session how to route and execute the correct prompt-only lane safely.

## Minimal operator reminder

When in doubt, upload:

```text
1. infractl.zip
2. infractl.md
3. the public tool zip or repository access
4. the private project bundle zip
5. any required evidence zip/files for update lanes
6. INTEGRATION_REQUEST.md / INTEGRATION_MANIFEST.md / CONFIG_STATE_SNAPSHOT.md / CONFIG_INTEGRATION_PLAN.md when running CIP phases
```

Then ask for one route and one phase at a time.

## Current Config-Infra note

The current real `infractl.zip` includes the active `config-infra/` route family. The main DOT contains the native CIP router, while `README.md` and `prompt_guide.md` provide longer operator examples. This `infractl.md` remains the compact router and must be kept next to the zip in fresh chats.

For Config-Infra work, start with the CIP router prompt unless you already know the exact CIP phase.
