# Organs timeline file ledger - named-file prompts

Canonical rule for prompts in this ledger: prompt the agent to read and follow named files. Do not paste or repeat the full instructions from those files unless the file is missing, being repaired, or intentionally being regenerated.

## Step O-T1 - Create organ batch in ChatGPT

| Field | Exact content |
|---|---|
| Step owner | ChatGPT only. Codex is not used in this step. |
| When | After the relevant skeleton contract is stable and skeleton-complete or group-level readiness is acceptable. |
| ChatGPT prompt | Read and follow general_new_chat_organ_batch_generation_prompt.md. Set BATCH_NUMBER=<RNN or N>. Use the organ master, organ batch plan, templates, and skeleton companion contract named below. Produce one Codex-ready organ batch package. Do not repeat template prompts manually; use the uploaded files. |
| Upload to ChatGPT | general_new_chat_organ_batch_generation_prompt.md; 00_transition_to_real_organs_master.md; transition_real_organs_codex_batch_plan.md; CODEX_PROMPT.txt; PROJECT_CACHE.md; SPEC.md; RUN_INSTRUCTIONS.md; POSTCHECK_TEMPLATE.md; CONFIG_TOOL.md for context only; relevant skeleton COMPANION.md or skeleton contract summary; optional latest organ COMPANION.md/INDEX.md; optional latest organ dev-recordings summary. |
| ChatGPT creates | codex_organ_batch_<N>_<slug>.zip; batch CODEX_PROMPT.txt; PROJECT_CACHE.md; SPEC.md; RUN_INSTRUCTIONS.md; POSTCHECK_TEMPLATE.md; optional batch README/checklist; optional missing-file report. |
| Codex must have access to | Not applicable during this step. The created zip is for O-T2/O-T3. |
| Codex prompt | Not applicable. Do not run Codex yet. |
| Codex may run | Nothing. |
| Codex creates/updates | Nothing. |
| Codex must not create | Project code; organ evidence; companion docs; integration manifest; config/lv/workflow edits. |

## Step O-T2 - Stage organ batch for Codex

| Field | Exact content |
|---|---|
| Step owner | Human or Codex for extraction/staging. ChatGPT only for optional sanity check. |
| When | Immediately after O-T1 creates the organ batch zip. |
| ChatGPT prompt | Optional only: inspect this organ batch file list against expected batch package files and skeleton contract inputs. Do not regenerate instructions unless required files are missing. |
| Upload to ChatGPT | Optional: zip file listing; generated CODEX_PROMPT.txt; SPEC.md; RUN_INSTRUCTIONS.md; relevant skeleton COMPANION.md; file listing. |
| ChatGPT creates | Optional pre-run sanity checklist; optional missing-file list. |
| Codex must have access to | codex_organ_batch_<N>_<slug>.zip or extracted folder; /workspace with completed skeleton; batch CODEX_PROMPT.txt; PROJECT_CACHE.md; SPEC.md; RUN_INSTRUCTIONS.md; POSTCHECK_TEMPLATE.md; CODEX_ORGAN_RECORDING_INSTRUCTIONS.md if not included; writable /mnt/egress/organs/dev-recordings/organs/<batch-slug>/. |
| Codex prompt | Extract/stage the generated organ batch. Confirm these files exist: CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, and the relevant skeleton companion/contract. Do not execute implementation yet unless O-T3 is explicitly started. |
| Codex may run | unzip/list/test -f/cat/head/find/tree; mkdir -p for required organ evidence folder. |
| Codex creates/updates | Extracted organ batch folder; optional staging log; required evidence folder if missing. |
| Codex must not create | Project implementation changes; POSTCHECK.md; INTEGRATION_REQUEST.md; companion docs; config/lv/workflow edits; live outputs. |

## Step O-T3 - Run organ Codex implementation

| Field | Exact content |
|---|---|
| Step owner | Codex as researchscientist. |
| When | After O-T2 staging confirms batch and skeleton contract files are present. |
| ChatGPT prompt | Not normally used. Use ChatGPT only if Codex reports missing files, skeleton contract ambiguity, or safety-gate ambiguity. |
| Upload to ChatGPT | Optional troubleshooting only: exact Codex error; batch CODEX_PROMPT.txt; SPEC.md; RUN_INSTRUCTIONS.md; relevant skeleton COMPANION.md; file listing; relevant logs. |
| ChatGPT creates | Optional fix prompt or missing-file report. No normal project files. |
| Codex must have access to | /workspace; generated/extracted organ batch folder; CODEX_PROMPT.txt; PROJECT_CACHE.md; SPEC.md; RUN_INSTRUCTIONS.md; POSTCHECK_TEMPLATE.md; CODEX_ORGAN_RECORDING_INSTRUCTIONS.md if external; relevant skeleton COMPANION.md/contract; writable /mnt/egress/organs/dev-recordings/organs/<batch-slug>/. |
| Codex prompt | Open and follow CODEX_PROMPT.txt, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, CODEX_ORGAN_RECORDING_INSTRUCTIONS.md if present, and the relevant skeleton COMPANION.md/contract. Use those files as the source of truth. Work under /workspace and write evidence to /mnt/egress/organs/dev-recordings/organs/<batch-slug>/. |
| Codex may run | Commands explicitly allowed/listed in RUN_INSTRUCTIONS.md; safe dry-run/guarded checks; local file inspection; dependency checks; mkdir/test/cat/find/grep/git diff style commands. |
| Codex creates/updates | Organ project code under /workspace; organ modules/tests/scripts; /mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md; /mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md; optional implementation logs. |
| Codex must not create | Ungated live actions; config/lv/workflow edits; skeleton companion docs; organ companion docs; INTEGRATION_MANIFEST.md; broken skeleton output contracts. |

## Step O-T4 - Run idempotent smoke after every organ batch

| Field | Exact content |
|---|---|
| Step owner | Codex runs the smoke command. ChatGPT only if smoke script is missing/broken. |
| When | After every completed organ batch, before starting the next organ batch. |
| ChatGPT prompt | Only if creating/repairing smoke: read IDEMPOTENT_SMOKETEST.md and the current smoke script, then produce a corrected smoke_current_state.sh. Do not repeat the whole smoke spec in the prompt. |
| Upload to ChatGPT | Only if creating/repairing smoke: IDEMPOTENT_SMOKETEST.md; /workspace/scripts/smoke_current_state.sh if present; latest organ SPEC.md; latest organ RUN_INSTRUCTIONS.md; relevant skeleton contract; current smoke error output. |
| ChatGPT creates | Optional corrected smoke_current_state.sh content; optional PASS/WARN/FAIL clarification; optional missing-file list. |
| Codex must have access to | /workspace/scripts/smoke_current_state.sh; /workspace current code; /workspace/runs/smoke/ writable path; /mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md; /mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md; BATCH_SLUG value. |
| Codex prompt | Run the reusable smoke script for the just-completed organ batch. Use exactly: BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress. Then record the resulting SMOKE_REPORT.md path in POSTCHECK.md. |
| Codex may run | BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress; test -f; cat/tail SMOKE_REPORT.md; no live actions unless RUN_INSTRUCTIONS.md explicitly gates them and the smoke script calls them safely. |
| Codex creates/updates | /workspace/runs/smoke/<timestamp>-organ-progress/SMOKE_REPORT.md; optional stdout/stderr logs; POSTCHECK.md update with smoke path and result. |
| Codex must not create | Config edits; companion docs; integration manifest; destructive cleanup; overwritten old smoke reports; ungated live outputs. |

## Step O-T5 - Read organ smoke report and decide PASS/WARN/FAIL

| Field | Exact content |
|---|---|
| Step owner | Human or ChatGPT for interpretation. Codex only supplies files or applies fixes. |
| When | Immediately after O-T4 smoke finishes. |
| ChatGPT prompt | Read SMOKE_REPORT.md, POSTCHECK.md, INTEGRATION_REQUEST.md, SPEC.md, RUN_INSTRUCTIONS.md, and the skeleton companion/contract. Classify PASS/WARN/FAIL. If FAIL, create a Codex fix prompt naming exact files and the exact smoke command to rerun. Do not invent missing files. |
| Upload to ChatGPT | Latest organ SMOKE_REPORT.md; latest organ POSTCHECK.md; latest organ INTEGRATION_REQUEST.md; organ SPEC.md; organ RUN_INSTRUCTIONS.md; relevant skeleton COMPANION.md; failing stdout/stderr log if present; optional code diff. |
| ChatGPT creates | PASS/WARN/FAIL decision; exact missing-file list; exact Codex fix prompt; optional POSTCHECK.md update text. |
| Codex must have access to | Only if fixes are required: /workspace; relevant source files named by ChatGPT; latest SMOKE_REPORT.md; POSTCHECK.md; INTEGRATION_REQUEST.md; SPEC.md; RUN_INSTRUCTIONS.md; skeleton companion/contract. |
| Codex prompt | Apply only the fixes named by ChatGPT. Re-run exactly: BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress. Update POSTCHECK.md with the new report path and result. |
| Codex may run | File fixes within batch scope; same O-T4 smoke command; safe local checks named by RUN_INSTRUCTIONS.md. |
| Codex creates/updates | Bugfixes under /workspace if required; updated POSTCHECK.md; updated INTEGRATION_REQUEST.md only if the request changed; new timestamped SMOKE_REPORT.md. |
| Codex must not create | Config integration; companion docs unless O-T6 is explicitly started; integration manifests; hidden manual overrides; ungated live actions. |

## Step O-T6 - Update organ companion after a checked organ state

| Field | Exact content |
|---|---|
| Step owner | Usually ChatGPT drafts the organ companion content; Codex may write it to ingress. |
| When | After an organ logical group, after an organ safety/output contract change, or after organ-complete smoke passes/warns acceptably. Logical groups: O-G1 real-organ bridge R01-R03; O-G2 core GRN/DSL/sim R04-R06; O-G3 data/experiments/reporting R07-R09; O-G4 guarded live/handoff R10-R12. |
| ChatGPT prompt | Read ORGAN_COMPANION_GENERATOR_INSTRUCTIONS.md and use the named evidence files. Update organ COMPANION.md for the checked real-organ state. Preserve skeleton output contracts. Do not repeat the generator instructions in the prompt. Do not invent missing evidence. |
| Upload to ChatGPT | ORGAN_COMPANION_GENERATOR_INSTRUCTIONS.md; latest organ POSTCHECK.md; latest organ INTEGRATION_REQUEST.md; latest organ SMOKE_REPORT.md; latest codebase analysis output; existing organ COMPANION.md if present; existing organ INDEX.md if present; relevant skeleton COMPANION.md or skeleton contract summary; relevant organ batch SPEC.md and RUN_INSTRUCTIONS.md if exact commands are needed. |
| ChatGPT creates | Updated organ COMPANION.md content; optional organ INDEX.md update text; optional missing-file report; optional safety-gate checklist; optional Codex write prompt. |
| Codex must have access to | /workspace; /mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md; /mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md; latest SMOKE_REPORT.md; /mnt/ingress/infra/organs/companion/<batch-slug>/; ChatGPT-created COMPANION.md content or patch. |
| Codex prompt | Write the provided ChatGPT organ companion content to /mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md. Update INDEX.md only if ChatGPT provided exact INDEX.md content. Do not edit config, project code, or skeleton companion docs. |
| Codex may run | mkdir -p; file write commands; test -f; cat/head/tail; optional dry-run/smoke only if explicitly requested. |
| Codex creates/updates | /mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md; optional /mnt/ingress/infra/organs/companion/INDEX.md; optional write log. |
| Codex must not create | Config/lv/workflow edits; skeleton companion docs; invented integration manifests; live outputs. |

## Step O-T7 - Organ-complete checkpoint and final organ smoke

| Field | Exact content |
|---|---|
| Step owner | Codex runs organ-complete smoke; ChatGPT reviews readiness if needed. |
| When | After final organ batch R12 or the final planned organ batch and required companions are complete. |
| ChatGPT prompt | Read organ-complete SMOKE_REPORT.md, latest organ companion docs, skeleton companion contract, and completed organ evidence. Decide whether operator/config integration may start. If blocked, name exact files/commands to fix. Do not create config batch instructions if organ-complete smoke fails. |
| Upload to ChatGPT | organ-complete SMOKE_REPORT.md; latest organ COMPANION.md/INDEX.md; relevant skeleton COMPANION.md; final or representative organ POSTCHECK.md files; final or representative organ INTEGRATION_REQUEST.md files; latest codebase analysis; final organ SPEC.md/RUN_INSTRUCTIONS.md if applicable. |
| ChatGPT creates | Organ-complete readiness decision; blocker list; optional config-start checklist; optional Codex fix prompt. |
| Codex must have access to | /workspace/scripts/smoke_current_state.sh; /workspace; all organ evidence folders under /mnt/egress/organs/dev-recordings/organs/; organ companion docs; relevant skeleton companion docs. |
| Codex prompt | Run the organ-complete smoke checkpoint with: bash /workspace/scripts/smoke_current_state.sh organ-complete. Preserve previous smoke reports. Do not edit config unless O-T9 is explicitly started. Do not run ungated live actions. |
| Codex may run | bash /workspace/scripts/smoke_current_state.sh organ-complete; test/cat/tail report; safe local commands called by the smoke script. |
| Codex creates/updates | /workspace/runs/smoke/<timestamp>-organ-complete/SMOKE_REPORT.md; optional readiness note in dev-recordings; optional POSTCHECK.md update with organ-complete result. |
| Codex must not create | Config integration edits; INTEGRATION_MANIFEST.md unless O-T8 is explicitly started; new live outputs. |

## Step O-T8 - Create organ integration manifest in ChatGPT

| Field | Exact content |
|---|---|
| Step owner | ChatGPT plans integration from completed evidence. |
| When | After organ-complete smoke is PASS or accepted WARN and before vmuser/operator config integration. |
| ChatGPT prompt | Read INTEGRATION_MANIFEST_TEMPLATE.md, CONFIG_TOOL.md, completed organ INTEGRATION_REQUEST.md files, organ POSTCHECK.md files, organ companion docs, skeleton companion contract, and smoke reports. Produce INTEGRATION_MANIFEST.md or organ manifest slice. Do not repeat the manifest template in the prompt; follow the file. |
| Upload to ChatGPT | INTEGRATION_MANIFEST_TEMPLATE.md; CONFIG_TOOL.md; completed organ INTEGRATION_REQUEST.md files; completed organ POSTCHECK.md files; organ COMPANION.md/INDEX.md; relevant skeleton COMPANION.md; organ-complete SMOKE_REPORT.md; relevant codebase analysis; optional PROJECT_CACHE.md/SPEC.md/RUN_INSTRUCTIONS.md for exact commands. |
| ChatGPT creates | Organ INTEGRATION_MANIFEST.md content or manifest slice; optional operator Codex batch prompt; missing-evidence report if required files are absent. |
| Codex must have access to | Only if asked to save the manifest: approved output folder; ChatGPT-created INTEGRATION_MANIFEST.md content. |
| Codex prompt | Optional only: write the provided organ INTEGRATION_MANIFEST.md or manifest slice to the approved planning/evidence location. Do not edit config yet. |
| Codex may run | File write and test -f only if asked to save the manifest. |
| Codex creates/updates | Optional saved organ INTEGRATION_MANIFEST.md or manifest slice; optional write log. |
| Codex must not create | Config/lv/workflow edits during planning; new organ implementation outputs; invented evidence. |

## Step O-T9 - Run vmuser/operator organ config integration and post-config smoke

| Field | Exact content |
|---|---|
| Step owner | ChatGPT may generate operator batch; Codex as vmuser/operator executes it. |
| When | After O-T8 manifest exists. This is the organ step where config/lv/workflow edits may occur. |
| ChatGPT prompt | Read general_new_chat_config_integration_batch_generation_prompt.md if available, organ INTEGRATION_MANIFEST.md, CONFIG_TOOL.md, organ companion docs, and skeleton companion contract. Generate a vmuser/operator config-integration Codex batch. Do not repeat config prompt text manually; use the files as instructions. |
| Upload to ChatGPT | general_new_chat_config_integration_batch_generation_prompt.md if present; organ INTEGRATION_MANIFEST.md; CONFIG_TOOL.md; organ COMPANION.md/INDEX.md; relevant skeleton COMPANION.md; organ-complete SMOKE_REPORT.md; optional current config file list; optional existing lv/workflow snippets. |
| ChatGPT creates | Operator organ config-integration CODEX_PROMPT.txt; PROJECT_CACHE.md; SPEC.md; RUN_INSTRUCTIONS.md; POSTCHECK_TEMPLATE.md; exact post-config smoke instruction; optional missing-file report. |
| Codex must have access to | Generated operator config-integration batch files; /workspace or config repo; approved config/lv/workflow files; organ INTEGRATION_MANIFEST.md; CONFIG_TOOL.md; /workspace/scripts/smoke_current_state.sh; previous organ/skeleton evidence folders. |
| Codex prompt | Open and follow generated operator CODEX_PROMPT.txt, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, organ INTEGRATION_MANIFEST.md, and CONFIG_TOOL.md. Apply only manifest-approved config/lv/workflow changes. Then run post-config smoke. |
| Codex may run | Approved config edit commands from RUN_INSTRUCTIONS.md; safe validation commands; bash /workspace/scripts/smoke_current_state.sh post-config; config health checks named by RUN_INSTRUCTIONS.md. |
| Codex creates/updates | Approved config/lv/workflow files; operator integration POSTCHECK.md; /workspace/runs/smoke/<timestamp>-post-config/SMOKE_REPORT.md; optional config health-check logs. |
| Codex must not create | Unapproved science rewrites; ungated live actions; undocumented aliases; config changes not present in the manifest. |
