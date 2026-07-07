# infractl Prompt-Only Execution Router

This file is the human-facing router for the prompt-only Infra-Skeleton workflow bundle.

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

infractl/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

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

## Route folders

### 0-lanes

Folder:

```text
infractl/zero-abc/
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
infractl/request-create-skeleton/
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
infractl/request-update-skeleton/
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
infractl/request-create-organs/
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
infractl/request-update-organs/
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

## Phase selection table

```text
PHASE=P1  -> direction/request generation
PHASE=P2  -> request-to-writing
PHASE=P3  -> writing-to-package
PHASE=P4  -> package-to-Codex/layout-gate
PHASE=P5  -> evidence-return/snapshot/export/phase-decision
PHASE=P6  -> next-cycle routing
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
```

Then ask for one route and one phase at a time.
