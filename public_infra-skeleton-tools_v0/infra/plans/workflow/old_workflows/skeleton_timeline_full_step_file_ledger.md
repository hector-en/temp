# Skeleton timeline file ledger - named-file prompts

Canonical rule for prompts in this ledger: prompt the agent to read and follow named files. Do not paste or repeat the full instructions from those files unless the file is missing, being repaired, or intentionally being regenerated.

## Step S-T1 - Create skeleton batch in ChatGPT

| Field | Exact content |
|---|---|
| Step owner | ChatGPT only. Codex is not used in this step. |
| When | At the start of each skeleton batch number, before any Codex implementation run. |
| ChatGPT prompt | Read and follow general_new_chat_batch_generation_prompt.md. Set BATCH_NUMBER=&lt;N&gt;. Use the skeleton master, skeleton batch plan, and templates named below. Produce one Codex-ready skeleton batch package. Do not repeat the template prompts manually; use the uploaded files as source instructions. |
| Upload to ChatGPT | general_new_chat_batch_generation_prompt.md; 00_skeleton_dummy_master_implementation_companion.md; skeleton_dummy_codex_batch_plan.md; CODEX_PROMPT.txt; PROJECT_CACHE.md; SPEC.md; RUN_INSTRUCTIONS.md; POSTCHECK_TEMPLATE.md; CONFIG_TOOL.md for context only; optional latest skeleton COMPANION.md or INDEX.md; optional latest dev-recordings summary. |
| ChatGPT creates | codex_skeleton_batch_&lt;N&gt;_&lt;slug&gt;.zip; batch CODEX_PROMPT.txt; batch PROJECT_CACHE.md; batch SPEC.md; batch RUN_INSTRUCTIONS.md; batch POSTCHECK_TEMPLATE.md; optional batch README/checklist; optional missing-file report. |
| Codex must have access to | Not applicable during this step. The created zip is for S-T2/S-T3. |
| Codex prompt | Not applicable. Do not run Codex yet. |
| Codex may run | Nothing. |
| Codex creates/updates | Nothing. |
| Codex must not create | Project code; dev-recordings; companion docs; integration manifest; config/lv/workflow edits. |

## Step S-T2 - Stage skeleton batch for Codex

| Field | Exact content |
|---|---|
| Step owner | Human or Codex only for extraction/staging. ChatGPT only if a sanity check is requested. |
| When | Immediately after S-T1 creates the skeleton batch zip. |
| ChatGPT prompt | Optional only: inspect this batch file list against the expected skeleton batch package files. Do not regenerate instructions unless required files are missing. |
| Upload to ChatGPT | Optional: zip file listing; batch folder listing; generated CODEX_PROMPT.txt; SPEC.md; RUN_INSTRUCTIONS.md if doing a sanity check. |
| ChatGPT creates | Optional pre-run sanity checklist; optional missing-file list. |
| Codex must have access to | codex_skeleton_batch_&lt;N&gt;_&lt;slug&gt;.zip or extracted folder; /workspace; batch CODEX_PROMPT.txt; batch PROJECT_CACHE.md; batch SPEC.md; batch RUN_INSTRUCTIONS.md; batch POSTCHECK_TEMPLATE.md; CODEX_RECORDING_INSTRUCTIONS.md if not included in batch; writable /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/. |
| Codex prompt | Extract/stage the generated skeleton batch. Confirm these files exist: CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md. Do not execute implementation yet unless S-T3 is explicitly started. |
| Codex may run | unzip/list/test -f/cat/head/find/tree; mkdir -p for required evidence folder. |
| Codex creates/updates | Extracted batch folder; optional staging log; required evidence folder if missing. |
| Codex must not create | Project implementation changes; POSTCHECK.md; INTEGRATION_REQUEST.md; companion docs; config/lv/workflow edits. |

## Step S-T3 - Run skeleton Codex implementation

| Field | Exact content |
|---|---|
| Step owner | Codex as researchscientist. |
| When | After S-T2 staging confirms the batch files are present. |
| ChatGPT prompt | Not normally used. Use ChatGPT only if Codex reports missing files or ambiguity. |
| Upload to ChatGPT | Optional troubleshooting only: exact Codex error; batch CODEX_PROMPT.txt; SPEC.md; RUN_INSTRUCTIONS.md; file listing; relevant logs. |
| ChatGPT creates | Optional fix prompt or missing-file report. No normal project files. |
| Codex must have access to | /workspace; generated/extracted skeleton batch folder; CODEX_PROMPT.txt; PROJECT_CACHE.md; SPEC.md; RUN_INSTRUCTIONS.md; POSTCHECK_TEMPLATE.md; CODEX_RECORDING_INSTRUCTIONS.md if external; writable /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/. |
| Codex prompt | Open and follow CODEX_PROMPT.txt, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, and CODEX_RECORDING_INSTRUCTIONS.md if present. Use those files as the source of truth. Do not paste their contents into the prompt. Work under /workspace and write evidence to /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/. |
| Codex may run | Commands explicitly allowed/listed in RUN_INSTRUCTIONS.md; safe local file inspection; dependency checks; unit-level local checks; mkdir/test/cat/find/grep/git diff style commands. |
| Codex creates/updates | Project code under /workspace; batch-defined scripts/modules/tests; /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/POSTCHECK.md; /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/INTEGRATION_REQUEST.md; optional implementation logs. |
| Codex must not create | Config/lv/workflow edits; companion docs; INTEGRATION_MANIFEST.md; organ live outputs; project source under /home/&lt;role&gt; except role-local scratch. |

## Step S-T4 - Run idempotent smoke after every skeleton batch

| Field | Exact content |
|---|---|
| Step owner | Codex runs the smoke command. ChatGPT only if smoke script is missing/broken. |
| When | After every completed skeleton batch, before starting the next skeleton batch. |
| ChatGPT prompt | Only if creating/repairing smoke: read IDEMPOTENT_SMOKETEST.md and the current smoke script, then produce a corrected smoke_current_state.sh. Do not repeat the whole smoke spec in the prompt. |
| Upload to ChatGPT | Only if creating/repairing smoke: IDEMPOTENT_SMOKETEST.md; /workspace/scripts/smoke_current_state.sh if present; latest batch SPEC.md; latest RUN_INSTRUCTIONS.md; current smoke error output. |
| ChatGPT creates | Optional corrected smoke_current_state.sh content; optional PASS/WARN/FAIL clarification; optional missing-file list. |
| Codex must have access to | /workspace/scripts/smoke_current_state.sh; /workspace current code; /workspace/runs/smoke/ writable path; /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/POSTCHECK.md; /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/INTEGRATION_REQUEST.md; BATCH_SLUG value. |
| Codex prompt | Run the reusable smoke script for the just-completed skeleton batch. Use exactly: BATCH_SLUG=&quot;&lt;batch-slug&gt;&quot; bash /workspace/scripts/smoke_current_state.sh skeleton-progress. Then record the resulting SMOKE_REPORT.md path in POSTCHECK.md. |
| Codex may run | BATCH_SLUG=&quot;&lt;batch-slug&gt;&quot; bash /workspace/scripts/smoke_current_state.sh skeleton-progress; test -f; cat/tail the SMOKE_REPORT.md; no other tests unless named by the smoke script or RUN_INSTRUCTIONS.md. |
| Codex creates/updates | /workspace/runs/smoke/&lt;timestamp&gt;-skeleton-progress/SMOKE_REPORT.md; optional stdout/stderr logs; POSTCHECK.md update with smoke path and result. |
| Codex must not create | Config edits; companion docs; integration manifest; destructive cleanup; overwritten old smoke reports; real organ/live outputs. |

## Step S-T5 - Read smoke report and decide PASS/WARN/FAIL

| Field | Exact content |
|---|---|
| Step owner | Human or ChatGPT for interpretation. Codex only supplies files or applies fixes. |
| When | Immediately after S-T4 smoke finishes. |
| ChatGPT prompt | Read SMOKE_REPORT.md, POSTCHECK.md, INTEGRATION_REQUEST.md, SPEC.md, and RUN_INSTRUCTIONS.md. Classify PASS/WARN/FAIL. If FAIL, create a Codex fix prompt naming the exact files to edit and the exact smoke command to rerun. Do not invent missing files. |
| Upload to ChatGPT | Latest SMOKE_REPORT.md; latest POSTCHECK.md; latest INTEGRATION_REQUEST.md; batch SPEC.md; batch RUN_INSTRUCTIONS.md; failing stdout/stderr log if present; optional code diff. |
| ChatGPT creates | PASS/WARN/FAIL decision; exact missing-file list; exact Codex fix prompt; optional POSTCHECK.md update text. |
| Codex must have access to | Only if fixes are required: /workspace; relevant source files named by ChatGPT; latest SMOKE_REPORT.md; POSTCHECK.md; INTEGRATION_REQUEST.md; SPEC.md; RUN_INSTRUCTIONS.md. |
| Codex prompt | Apply only the fixes named by ChatGPT. Re-run exactly: BATCH_SLUG=&quot;&lt;batch-slug&gt;&quot; bash /workspace/scripts/smoke_current_state.sh skeleton-progress. Update POSTCHECK.md with the new report path and result. |
| Codex may run | File fixes within batch scope; same S-T4 smoke command; safe local checks named by RUN_INSTRUCTIONS.md. |
| Codex creates/updates | Bugfixes under /workspace if required; updated POSTCHECK.md; updated INTEGRATION_REQUEST.md only if the request changed; new timestamped SMOKE_REPORT.md. |
| Codex must not create | Config integration; companion docs unless S-T6 is explicitly started; integration manifests; hidden manual overrides. |

## Step S-T6 - Update skeleton companion after a checked skeleton state

| Field | Exact content |
|---|---|
| Step owner | Usually ChatGPT drafts the companion content; Codex may write it to ingress. |
| When | After a logical skeleton group, after a skeleton output contract change, or after skeleton-complete smoke passes/warns acceptably. Logical groups: S-G1 runtime/filesystem/scaffold; S-G2 dummy science contract and outputs; S-G3 orchestration/CLI/reporting; S-G4 validation/handoff before organs. |
| ChatGPT prompt | Read COMPANION_GENERATOR_INSTRUCTIONS.md and use the named evidence files. Update skeleton COMPANION.md for the checked state. Do not repeat the companion generator instructions in the prompt. Do not invent missing evidence. |
| Upload to ChatGPT | COMPANION_GENERATOR_INSTRUCTIONS.md; latest skeleton POSTCHECK.md; latest skeleton INTEGRATION_REQUEST.md; latest skeleton SMOKE_REPORT.md; latest codebase analysis output; existing skeleton COMPANION.md if present; existing skeleton INDEX.md if present; relevant batch SPEC.md and RUN_INSTRUCTIONS.md if exact commands changed. |
| ChatGPT creates | Updated skeleton COMPANION.md content; optional skeleton INDEX.md update text; optional missing-file report; optional contract checklist; optional Codex write prompt. |
| Codex must have access to | /workspace; /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/POSTCHECK.md; /mnt/egress/dev-recordings/skeleton/&lt;batch-slug&gt;/INTEGRATION_REQUEST.md; latest SMOKE_REPORT.md; /mnt/ingress/infra/skeleton/companion/&lt;batch-slug&gt;/; ChatGPT-created COMPANION.md content or patch. |
| Codex prompt | Write the provided ChatGPT companion content to /mnt/ingress/infra/skeleton/companion/&lt;batch-slug&gt;/COMPANION.md. Update INDEX.md only if ChatGPT provided exact INDEX.md content. Do not edit config or project code. |
| Codex may run | mkdir -p; file write commands; test -f; cat/head/tail; optional smoke command only if explicitly requested. |
| Codex creates/updates | /mnt/ingress/infra/skeleton/companion/&lt;batch-slug&gt;/COMPANION.md; optional /mnt/ingress/infra/skeleton/companion/INDEX.md; optional write log. |
| Codex must not create | Organ companion docs; config/lv/workflow edits; INTEGRATION_MANIFEST.md; invented evidence; project code changes unless specifically requested. |

## Step S-T7 - Skeleton-complete checkpoint and final skeleton smoke

| Field | Exact content |
|---|---|
| Step owner | Codex runs skeleton-complete smoke; ChatGPT reviews readiness if needed. |
| When | After skeleton batch 24 or the final planned skeleton batch and required companions are complete. |
| ChatGPT prompt | Read the skeleton-complete SMOKE_REPORT.md, latest skeleton companion docs, and completed evidence files. Decide whether organ batches may start. If blocked, name the exact files/commands that must be fixed. Do not create organ batch instructions yet if skeleton-complete smoke fails. |
| Upload to ChatGPT | skeleton-complete SMOKE_REPORT.md; latest skeleton COMPANION.md/INDEX.md; final or representative POSTCHECK.md files; final or representative INTEGRATION_REQUEST.md files; latest codebase analysis; final skeleton SPEC.md/RUN_INSTRUCTIONS.md if applicable. |
| ChatGPT creates | Skeleton-complete readiness decision; blocker list; optional organ-start checklist; optional Codex fix prompt. |
| Codex must have access to | /workspace/scripts/smoke_current_state.sh; /workspace; all skeleton evidence folders under /mnt/egress/dev-recordings/skeleton/; skeleton companion docs. |
| Codex prompt | Run the skeleton-complete smoke checkpoint with: bash /workspace/scripts/smoke_current_state.sh skeleton-complete. Preserve previous smoke reports. Do not edit config and do not run organ actions. |
| Codex may run | bash /workspace/scripts/smoke_current_state.sh skeleton-complete; test/cat/tail report; safe local commands called by the smoke script. |
| Codex creates/updates | /workspace/runs/smoke/&lt;timestamp&gt;-skeleton-complete/SMOKE_REPORT.md; optional readiness note in dev-recordings; optional POSTCHECK.md update with skeleton-complete result. |
| Codex must not create | Organ implementation outputs; config integration edits; INTEGRATION_MANIFEST.md unless S-T8 is explicitly started. |

## Step S-T8 - Create skeleton integration manifest in ChatGPT

| Field | Exact content |
|---|---|
| Step owner | ChatGPT plans integration from completed evidence. |
| When | After skeleton-complete smoke is PASS or accepted WARN and before vmuser/operator config integration. |
| ChatGPT prompt | Read INTEGRATION_MANIFEST_TEMPLATE.md, CONFIG_TOOL.md, completed skeleton INTEGRATION_REQUEST.md files, POSTCHECK.md files, companion docs, and smoke reports. Produce INTEGRATION_MANIFEST.md. Do not repeat the manifest template in the prompt; follow the file. |
| Upload to ChatGPT | INTEGRATION_MANIFEST_TEMPLATE.md; CONFIG_TOOL.md; completed skeleton INTEGRATION_REQUEST.md files; completed skeleton POSTCHECK.md files; skeleton COMPANION.md/INDEX.md; skeleton-complete SMOKE_REPORT.md; relevant codebase analysis; optional PROJECT_CACHE.md/SPEC.md/RUN_INSTRUCTIONS.md for exact commands. |
| ChatGPT creates | INTEGRATION_MANIFEST.md content; optional manifest slices; optional operator Codex batch prompt; missing-evidence report if required files are absent. |
| Codex must have access to | Only if asked to save the manifest: approved output folder; ChatGPT-created INTEGRATION_MANIFEST.md content. |
| Codex prompt | Optional only: write the provided INTEGRATION_MANIFEST.md to the approved planning/evidence location. Do not edit config yet. |
| Codex may run | File write and test -f only if asked to save the manifest. |
| Codex creates/updates | Optional saved INTEGRATION_MANIFEST.md; optional write log. |
| Codex must not create | Config/lv/workflow edits during planning; organ outputs; invented evidence. |

## Step S-T9 - Run vmuser/operator skeleton config integration and post-config smoke

| Field | Exact content |
|---|---|
| Step owner | ChatGPT may generate operator batch; Codex as vmuser/operator executes it. |
| When | After S-T8 manifest exists. This is the first skeleton step where config/lv/workflow edits may occur. |
| ChatGPT prompt | Read general_new_chat_config_integration_batch_generation_prompt.md if available, INTEGRATION_MANIFEST.md, and CONFIG_TOOL.md. Generate a vmuser/operator config-integration Codex batch. Do not repeat config prompt text manually; use the files as instructions. |
| Upload to ChatGPT | general_new_chat_config_integration_batch_generation_prompt.md if present; INTEGRATION_MANIFEST.md; CONFIG_TOOL.md; relevant companion docs; skeleton-complete SMOKE_REPORT.md; optional current config file list; optional existing lv/workflow snippets. |
| ChatGPT creates | Operator config-integration CODEX_PROMPT.txt; PROJECT_CACHE.md; SPEC.md; RUN_INSTRUCTIONS.md; POSTCHECK_TEMPLATE.md; exact post-config smoke instruction; optional missing-file report. |
| Codex must have access to | Generated operator config-integration batch files; /workspace or config repo; approved config/lv/workflow files; INTEGRATION_MANIFEST.md; CONFIG_TOOL.md; /workspace/scripts/smoke_current_state.sh; previous evidence folders. |
| Codex prompt | Open and follow the generated operator CODEX_PROMPT.txt, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md, INTEGRATION_MANIFEST.md, and CONFIG_TOOL.md. Apply only manifest-approved config/lv/workflow changes. Then run post-config smoke. |
| Codex may run | Approved config edit commands from RUN_INSTRUCTIONS.md; safe validation commands; bash /workspace/scripts/smoke_current_state.sh post-config; config health checks named by RUN_INSTRUCTIONS.md. |
| Codex creates/updates | Approved config/lv/workflow files; operator integration POSTCHECK.md; /workspace/runs/smoke/&lt;timestamp&gt;-post-config/SMOKE_REPORT.md; optional config health-check logs. |
| Codex must not create | Unapproved science rewrites; new organ live actions; undocumented aliases; config changes not present in the manifest. |
