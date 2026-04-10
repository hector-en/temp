# AGENTS.md

## What this file is for

This file is the repo bootstrap and workflow contract for this branch.

Use it to initialize non-trivial work in this repo, restate the current working
contract, and decide which installed skills to load from `skills/`.

Keep repo-level rules here. Keep detailed role procedures in each
`skills/<name>/SKILL.md`.

## Agentic System Bootstrap

For any non-trivial task in this repo, start here before making code changes.

### Bootstrap procedure

1. Read `workflow/authoritative-status.md`.
2. Read `workflow/stash-memory.yaml`.
3. Inspect `git status`.
4. Inspect `git stash list`.
5. Identify:
   - active increment
   - current blockers
   - latest saved checkpoint
   - whether the next move is a single-stash resume or a recomposed resume
6. Recalibrate the repo workflow state with the installed skills that apply.
7. Restate the working contract before coding.

## Required Recalibration Summary

Before coding, state:

- active increment
- active pairing mode
- best continuation point
- blockers
- next smallest behavior slice

Do not start code changes until this summary has been given.

## Default Repo Working Contract

- `comments-first` is the default coding mode for involved repo work
- use the repo workflow for feature work, bugfix continuation, checkpointing,
  commits, handoffs, and companion-file updates
- the workflow bootstrap is optional only for trivial one-off shell questions or
  simple standalone commands
- if the session has drifted, correct the process before adding more code

## Installed Repo Skills

Use the installed skills from `skills/` when they match the task.

### Core repo skills

- `powershell-pair-coder`  
  Use for PowerShell implementation, refactors, and comments-first pairing.

- `qa-state-analyst`  
  Use to read current QA state, risks, confidence, and test readiness.

- `companion-guide-writer`  
  Use when the repo needs a separate plain-language guide beside lean code or tests.

- `scrum-stash-master`  
  Use for save points, stash policy, resume flow, and checkpoint interpretation.

- `scrum-product-owner`  
  Use to clarify scope, non-goals, acceptance direction, and smallest useful slice.

- `workflow-drift-guard`  
  Use to detect workflow drift, missing bootstrap steps, or process breakdown.

- `scrum-solution-architect`  
  Use when the next move needs design structure, boundaries, or interface planning.

- `scrum-powershell-tdd`  
  Use when the current slice should be driven or checked through PowerShell tests.

### Support skills

- `skill-creator`
- `skill-installer`

These support the skill system itself and are not part of the normal repo coding
loop unless the task is about creating or installing skills.

## Default Skill Orchestration

For non-trivial repo work, prefer this order when it fits the task:

1. bootstrap from `workflow/`
2. `scrum-product-owner` for scope and smallest slice
3. `scrum-solution-architect` when design boundaries need to be clarified
4. `qa-state-analyst` for current test and risk reading
5. `workflow-drift-guard` if the session resumed, drifted, or skipped steps
6. `powershell-pair-coder` for implementation
7. `scrum-powershell-tdd` when tests should drive or validate the slice
8. `companion-guide-writer` only when a separate guide is truly needed
9. `scrum-stash-master` for save, resume, or handoff points

Use the minimal set of skills that covers the task.

## When to Use Direct Patch Instead of Involved Mode

Use `comments-first` by default.

Direct patching is acceptable when:

- the change is trivial and low-risk
- the task is patch-only maintenance
- the user explicitly asks to move fast without the full involved workflow
- the edit does not need a staged review conversation

When the work is non-trivial, return to the normal bootstrap and comments-first flow.

## Comments-First Standard

Use this coding standard for agent-guided development unless the user explicitly
asks for direct patching.

1. Write one top comment above the wider code section it governs.
2. Use that top comment to say what problem the section solves and set up the
   smaller comments below it.
3. Keep that top comment as its own comment block above the section.
4. Write separate local comments above each meaningful code subsection inside
   that section.
5. Write the real code directly below the relevant local comment.
6. Continue with the next local comment and the next code block.
7. Stop for review when the workflow is keeping the developer involved.

### Comment rules

- use plain language only
- do not use workflow jargon inside code comments
- each comment should make sense to a developer who does not already know the repo
- say what kind of object the comment belongs to when that helps, such as
  `Section:`, `Subfunction:`, or `Main function:`
- write `Section:` comments as a full-width banner when introducing a new section
- each local comment must sit directly above the exact code it describes
- do not leave detached planning comments above unrelated code

## Companion Guide Standard

Use this when the repo keeps a separate guide beside lean code or tests.

1. Explain the big picture first.
2. If the file has a host step and a guest step, explain that order before the
   section details.
3. Say what problem each section solves before naming the function or test.
4. Use plain language only.
5. Do not assume the reader already knows the repo, the lab, or the workflow terms.
6. Keep lower-level implementation details secondary to meaning.

The guide should help the next developer understand what happens first, what
depends on it, and where to look in the live file.

## Resume Rule

- If one stash clearly dominates, continue from that stash after explaining why.
- If multiple stashes must be recomposed, stop and require user confirmation.

## Save Rule

When the user says `save here`, `record progress`, `continue later`, or similar:

1. Update the workflow artifacts.
2. Record the QA reading.
3. Create a stash unless the user explicitly says not to.
4. Write the stash message in plain language and name the main function being
   worked on when there is one.

## Drift Rule

Run a drift check when:

- the session resumes after interruption
- the workflow summary was skipped
- implementation started before scope or QA was restated
- the process feels blurred, widened, or out of order

Correct workflow drift before adding more code.

## Commit Message Standard

When creating a commit:

1. Keep the type and scope prefix, such as `feat(identity):` or `docs(workflow):`.
2. Make the rest of the message say the main idea the segment solves.
3. Use plain language.
4. Name the main function when that helps make the idea clearer.
5. Add a commit body with `Summary`, `Details`, and `Next Steps`.

Do not use workflow jargon in commit messages.

### Commit body shape

`<type>(<scope>): <plain-language subject>`

`Summary:` one short plain-language paragraph that says what changed in one or
two lines

`Details:`
- current increment or state when that helps
- the main function, file, or area touched
- the problem this segment solves
- key checks, blockers, or limits that matter for this commit
- tests run, or say they were not run

`Next Steps:` one plain-language paragraph that clearly says what should happen
next and why in one or two lines, or says `none`

## Repo Workflow Intent

Bootstrap guidance lives in `AGENTS.md` so startup does not depend on a second
init file.

The live workflow state stays under `workflow/`.

The detailed role procedures stay under `skills/*/SKILL.md`.