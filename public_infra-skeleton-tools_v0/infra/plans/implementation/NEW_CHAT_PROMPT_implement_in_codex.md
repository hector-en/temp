# NEW_CHAT_PROMPT_IMPLEMENT_IN_CODEX.md

Use this file at the start of a new ChatGPT chat when you want ChatGPT to turn the current discussion, uploaded plans, or current codebase analysis into a cache-stable Codex implementation pack.

The goal is to idempotently create the same style of implementation instructions we have been using:

```text
<WORK_ID>_SPEC.md
<WORK_ID>_CODEX_RUN_INSTRUCTIONS.md
<WORK_ID>_CODEX_PROMPT.txt
optional: <WORK_ID>_codex_pack.zip
```

This file is not a Codex prompt by itself. It is a ChatGPT prompt for creating the files that Codex will later consume.

---

## 1. What to upload to the new ChatGPT chat

Upload the current context files that define the work.

Use as many as apply:

```text
1. Current codebase analysis output for /workspace or /home/vmuser/.local.
2. Current plan file or roadmap file.
3. Existing SPEC/RUN_INSTRUCTIONS/PROMPT examples to match style.
4. Existing project docs that Codex must treat as read-only.
5. Current POSTCHECK.md or INTEGRATION_REQUEST.md evidence if this continues prior work.
6. Current companion docs if the implementation depends on established contracts.
7. Any user correction about canonical paths, owners, roles, or safety boundaries.
```

Do not ask ChatGPT to recreate docs that already exist in the project. Instead, tell ChatGPT which docs already exist and where Codex must read them.

Example:

```text
These already exist and must be read-only Codex inputs:
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
```

---

## 2. Prompt to paste into ChatGPT

```text
Create a cache-stable Codex implementation pack from the current chat context and uploaded files.

Use the same style as the attached SPEC/RUN_INSTRUCTIONS/CODEX_PROMPT examples.

Create these output files:

1. <WORK_ID>_SPEC.md
2. <WORK_ID>_CODEX_RUN_INSTRUCTIONS.md
3. <WORK_ID>_CODEX_PROMPT.txt
4. optional zip containing all three files

Replace <WORK_ID> with a short stable identifier for this milestone.

Important requirements:

- Do not create or overwrite documents that are ChatGPT/operator-authored and already exist in the project.
- If an already-created doc is required, list it as a required read-only input for Codex.
- If a required read-only input is missing at Codex runtime, Codex must stop and ask the operator to place it there.
- Split implementation into small numbered tasks.
- Each task must say: Implement only Task N.
- Each task must name exactly which files Codex should read.
- Each task must name exactly which files Codex may create or edit.
- Each task must name exact validation commands.
- Each task must include stop conditions for missing required files.
- Use /workspace as the shared project workspace root.
- Use /home/<role> only for role-local settings, private scratch, caches, or user-specific config.
- Do not let implementation batches edit config/lv/workflow integration unless this is explicitly a config-integration milestone.
- If config integration is needed later, make Codex write INTEGRATION_REQUEST.md instead.
- Do not invent missing code, paths, evidence, or runtime state.
- Keep PROJECT_CACHE/context sections compact and stable.
- Avoid repeating long prompt content already present inside referenced files.
- Prompts should name the files to read, not duplicate their full contents.

Output files must follow this design:

A. SPEC.md
- Purpose
- Current codebase assessment
- Required read-only inputs
- Control model / architecture
- Canonical paths
- What Codex may create/update
- What Codex must not create/update
- Safety contract
- Idempotency contract
- Acceptance criteria
- Validation overview

B. CODEX_RUN_INSTRUCTIONS.md
- Short cache-stable instruction file for Codex
- Pair it with the SPEC file
- Stable context pack
- Prerequisite status
- Stop conditions
- Numbered tasks
- For each task:
  - Implement only Task N
  - Read:
  - Create/update:
  - Do not create/update:
  - Requirements:
  - Validation:
  - Output:
- Recommended order
- Suggested commits if useful

C. CODEX_PROMPT.txt
- Very short prompt for Codex
- It must tell Codex to read the SPEC and RUN_INSTRUCTIONS first
- It must contain a placeholder:
  <PASTE EXACT TASK NUMBER AND TITLE HERE>
- It must repeat only the critical safety constraints
- It must require Codex to end with:
  Changed files:
  Tests run:
  Notes:

Use the current chat context to fill in the specific milestone name, file paths, tasks, and validation commands.

Return links to the created files.
```

---

## 3. Required structure for the generated SPEC

ChatGPT should generate a SPEC using this shape:

```markdown
# <WORK_ID> — <Milestone Name> SPEC

## Purpose

<what this milestone creates or changes>

## Current codebase assessment

<what the uploaded codebase analysis or current evidence shows>

## Required read-only inputs

| Path | Owner | Purpose | Codex behavior if missing |
|---|---|---|---|
| <path> | ChatGPT/operator/project | <purpose> | stop and list missing path |

## Final control model

```text
<path>
    <meaning>
```

## Canonical paths

```text
Shared project workspace: /workspace
Skeleton evidence: /mnt/egress/dev-recordings/skeleton/<batch-slug>/
Organ evidence: /mnt/egress/organs/dev-recordings/organs/<batch-slug>/
Skeleton companion: /mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md
Organ companion: /mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md
```

## What Codex may create/update

```text
<exact paths>
```

## What Codex must not create/update

```text
<exact paths>
```

## Safety contract

Codex may:

```text
- read project files
- run safe local checks
- write only scoped outputs
```

Codex must not:

```text
- print credentials
- run live provider calls
- deploy/apply/mutate infrastructure
- edit config unless explicitly scoped
- overwrite ChatGPT/operator-authored docs
```

## Idempotency contract

Repeated runs must not corrupt state or duplicate conflicting artifacts.

## Acceptance criteria

- <criterion>
- <criterion>

## Validation overview

```bash
<commands>
```
```

---

## 4. Required structure for the generated CODEX_RUN_INSTRUCTIONS

ChatGPT should generate run instructions using this shape:

```markdown
# <WORK_ID> — <Milestone Name> — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
<WORK_ID>_SPEC.md
```

## Stable context pack

```text
You are working in /workspace.

<short stable context only>

Do not create or overwrite ChatGPT/operator-authored docs.
Do not edit config/lv/workflow unless this milestone explicitly says so.
Do not run broad bootstrap/install/mount/pull/push.
Do not deploy or call live external systems.
Do not read or print credential files.

Output at the end of each task:
Changed files:
Tests run:
Notes:
```

## Task 0 — Preflight only

Implement only Task 0.

Read:
- <SPEC file>
- <required read-only input 1>
- <required read-only input 2>

Do not create or edit files unless preflight evidence is explicitly scoped.

Run:

```bash
test -f <required-file>
```

If any required file is missing, stop and report:

```text
Missing required input(s):
- <path>
```

## Task 1 — <small task title>

Implement only Task 1.

Read:
- <exact path>

Create/update:
- <exact path>

Do not create/update:
- <exact path>

Requirements:
- <requirement>

Validation:

```bash
<safe validation commands>
```

## Task 2 — <small task title>

Implement only Task 2.

...

## Recommended order

```text
Task 0
Task 1
Task 2
...
```
```

---

## 5. Required structure for the generated CODEX_PROMPT

ChatGPT should generate the Codex prompt using this shape:

```text
You are Codex working on <WORK_ID>.

Read these files first:
- <WORK_ID>_SPEC.md
- <WORK_ID>_CODEX_RUN_INSTRUCTIONS.md

Required read-only project inputs:
- <path>
- <path>

If any required input is missing, stop and ask the operator to place it there.
Do not invent missing files.
Do not create or overwrite ChatGPT/operator-authored docs.

Implement only this task:

<PASTE EXACT TASK NUMBER AND TITLE HERE>

Constraints:
- Work in /workspace.
- Keep the task small.
- Do not edit config/lv/workflow integration unless the selected task explicitly says so.
- Do not run broad bootstrap/install/mount/pull/push.
- Do not deploy.
- Do not run live organs.
- Do not call live external APIs.
- Do not read or print credential files.
- Write outputs only to the paths allowed by the SPEC and selected task.

At the end, return exactly:

Changed files:
Tests run:
Notes:
```

---

## 6. Task sizing rules

When ChatGPT creates the run instructions, it must split work so Codex can complete each task with low context and low risk.

Good task boundaries:

```text
Task 0: preflight only
Task 1: create folders / skeleton files only
Task 2: implement one runner or one small helper
Task 3: implement one domain module or one feature family
Task 4: add validation/reporting only
Task 5: write POSTCHECK and INTEGRATION_REQUEST only
```

Bad task boundaries:

```text
Task 1: implement the whole platform
Task 1: update code, config, docs, tests, and integrations all together
Task 1: generate all batches and run all smoke checks
```

Preferred rule:

```text
One task = one logical change set = one small Codex run = one reviewable diff.
```

---

## 7. File ownership rules

Use these categories in every generated SPEC/RUN_INSTRUCTIONS pair.

| File category | Owner | Codex behavior |
|---|---|---|
| ChatGPT/operator docs | ChatGPT/operator | read-only unless user explicitly asks to regenerate them |
| Codex implementation files | Codex | may create/update only inside scoped paths |
| Evidence files | Codex | may write POSTCHECK.md and INTEGRATION_REQUEST.md in scoped egress path |
| Companion docs | ChatGPT/operator/companion generator | Codex must not write unless explicitly scoped |
| Config/lv/workflow files | vmuser/operator config-integration | implementation Codex must not edit unless selected milestone is config-integration |
| Smoke reports | smoke runner | may create timestamped reports only |

---

## 8. Evidence rules

For implementation milestones, Codex should usually write:

```text
POSTCHECK.md
INTEGRATION_REQUEST.md
```

Skeleton evidence path:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

Organ evidence path:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

If no config integration is needed, `INTEGRATION_REQUEST.md` should still exist and say:

```text
Suggested integration type: none
```

---

## 9. Config integration rule

Default rule:

```text
Skeleton/organ/platform implementation batches do not edit config/lv/workflow files.
```

Instead, they write `INTEGRATION_REQUEST.md` with:

```text
implemented paths
commands
packages
environment variables
smoke commands
outputs
health checks
role owner
suggested integration type
safety boundaries
open questions
```

Only a dedicated vmuser/operator config-integration milestone may edit:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/bin/lv.sh
/home/vmuser/.local/etc/config-sh/...
```

---

## 10. Missing-file behavior

Every generated instruction pack must tell Codex:

```text
If a required file is missing:
1. stop;
2. list the exact missing path;
3. classify it as required or optional;
4. do not guess;
5. ask the operator to place the file before continuing.
```

Optional evidence can be missing, but Codex must document the missing optional input and continue only if enough required context exists.

---

## 11. Validation command rules

Use safe validation only.

Allowed examples:

```bash
bash --noprofile --norc -n <script.sh>
test -f <path>
grep -n '<literal>' <file>
python -m py_compile <file.py>
python <safe-local-smoke.py>
bash /workspace/scripts/smoke.sh current-state
```

Forbidden by default:

```bash
terraform apply
kubectl apply
helm install
helm upgrade
docker run with side effects
broad bootstrap/install/mount/pull/push
live RunPod creation
live AgentField/OpenClaw/Paperclip execution
pip install inside a smoke/test task
printing secrets
```

---

## 12. How to ask for one implementation pack from a new chat

Paste this after uploading the relevant files:

```text
Use NEW_CHAT_PROMPT_IMPLEMENT_IN_CODEX.md.

Create a cache-stable Codex implementation pack for this current chat context.

I uploaded the current codebase analysis and plan files.
Use the attached template examples only for style and structure.
Do not copy their old milestone content unless it applies.

Create:
- <WORK_ID>_SPEC.md
- <WORK_ID>_CODEX_RUN_INSTRUCTIONS.md
- <WORK_ID>_CODEX_PROMPT.txt
- optional zip

Make the tasks small and digestible for Codex.
Make prompts name the files to read instead of repeating long prompt content already inside those files.
Clearly separate:
- files uploaded to ChatGPT
- files ChatGPT creates
- files Codex must have access to
- files Codex may create/update
- files Codex must not create/update

Return download links.
```

---

## 13. Quick checklist before accepting generated files

```text
[ ] SPEC names all required read-only inputs.
[ ] RUN_INSTRUCTIONS has Task 0 preflight.
[ ] Every task says Implement only Task N.
[ ] Every task names files to read.
[ ] Every task names files Codex may create/update.
[ ] Every task has validation commands.
[ ] CODEX_PROMPT is short and has <PASTE EXACT TASK NUMBER AND TITLE HERE>.
[ ] No ChatGPT/operator-created docs are assigned to Codex to recreate.
[ ] /workspace is used as shared project root.
[ ] Config edits are forbidden unless explicitly a config-integration milestone.
[ ] Evidence paths are correct.
[ ] Missing-file behavior is explicit.
```
