# AGENTS.md

## Skills

A skill is a set of local instructions to follow that is stored in a `SKILL.md` file.
Below is the list of skills that can be used. Each entry includes a name,
description, and file path so you can open the source for full instructions when
using a specific skill.

### Available skills

- `skill-creator`: Guide for creating effective skills. Use when creating a new skill or updating an existing skill that extends Codex's capabilities with specialized knowledge, workflows, or tool integrations. File: `C:/Users/hector/.codex/skills/.system/skill-creator/SKILL.md`
- `skill-installer`: Install Codex skills into `$CODEX_HOME/skills` from a curated list or a GitHub repo path. Use when listing installable skills, installing a curated skill, or installing a skill from another repo. File: `C:/Users/hector/.codex/skills/.system/skill-installer/SKILL.md`

### How to use skills

- Discovery: The list above is the skills available in this session. Skill bodies live on disk at the listed paths.
- Trigger rules: If the user names a skill with `$SkillName` or plain text, or the task clearly matches a skill description above, use that skill for the turn. Multiple mentions mean use them all. Do not carry skills across turns unless re-mentioned.
- Missing or blocked: If a named skill is not in the list or its path cannot be read, say so briefly and continue with the best fallback.

### Progressive disclosure

1. After deciding to use a skill, open its `SKILL.md`. Read only enough to follow the workflow.
2. When `SKILL.md` references relative paths, resolve them relative to the skill directory first.
3. If `SKILL.md` points to extra folders such as `references/`, load only the specific files needed for the request.
4. If `scripts/` exist, prefer running or patching them instead of retyping large code blocks.
5. If `assets/` or templates exist, reuse them instead of recreating from scratch.

### Coordination and sequencing

- If multiple skills apply, choose the minimal set that covers the request and state the order you'll use them.
- Announce which skill or skills you're using and why in one short line.
- If you skip an obvious skill, say why.

### Context hygiene

- Keep context small: summarize long sections instead of pasting them, and only load extra files when needed.
- Avoid deep reference-chasing: prefer opening only files directly linked from `SKILL.md` unless blocked.
- When variants exist, pick only the relevant reference files and note that choice.

### Safety and fallback

- If a skill cannot be applied cleanly because of missing files or unclear instructions, state the issue, pick the next-best approach, and continue.

## Repo Workflow Bootstrap

For any non-trivial task in this repo, start here before making code changes.
This file is the bootstrap source of truth, so do not spend an extra read on a
separate init file unless the user explicitly asks for it.

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
6. Recalibrate the repo workflow state:
   - `powershell-pair-coder`: active coding mode and next smallest slice
   - `companion-guide-writer`: whether a separate guide is needed beside lean code or tests
   - `qa-state-analyst`: current QA tags, risks, and confidence level
   - `scrum-stash-master`: stash timeline reading and checkpoint policy
   - `scrum-product-owner`: increment scope, non-goals, and acceptance direction
   - `workflow-drift-guard`: workflow-compliance reading and drift severity
7. Restate the working contract before coding:
   - `comments-first` is the default pair-coder mode
   - separate guides should stay in `companion-guide-writer` style when they exist
   - the developer stays in the loop before code changes in involved modes
   - no code starts until the recalibration summary has been given
   - if the session has drifted, correct the process before adding more code

### Required recalibration summary

Before coding, state:

- active increment
- active pairing mode
- best continuation point
- blockers
- next smallest behavior slice

### Default repo working contract

- `comments-first` is the default coding mode for involved repo work.
- Use the repo workflow for feature work, bugfix continuation, checkpointing,
  commits, handoffs, and companion-file updates.
- The workflow bootstrap is optional only for trivial one-off shell questions or
  simple standalone commands.
- After the bootstrap, prefer the installed custom skills when they match the
  task:
  - `powershell-pair-coder`
  - `qa-state-analyst`
  - `companion-guide-writer`
  - `scrum-stash-master`
  - `scrum-product-owner`
  - `workflow-drift-guard`
  - `scrum-solution-architect`
  - `scrum-powershell-tdd`

### Comment-first standard

Use this coding standard for agent-guided development unless the user explicitly
asks for direct patching:

1. Write one top comment above the wider code section it governs.
2. Use that top comment to say what problem the section solves and set up the
   smaller comments below it.
3. Keep that top comment as its own comment block above the section, not merged
   into a stacked planning block with later comments.
4. Write separate local comments above each meaningful code subsection inside
   that section.
5. Stop for review when the workflow is keeping the developer involved.
6. Write the real code directly below the relevant local comment.
7. Continue with the next local comment and the next code block.

The top comment must come first and must precede all other comments for that
section.
The top comment may use two short lines when one line is not enough.
Use plain language only in comments.
Do not use workflow jargon or abstract labels inside code comments.
Do not use domain shorthand or repo-specific terms unless the comment explains
them on its own.
Each comment should make sense to a developer who does not already know the
repo or the current slice.
Make the comment say what kind of object it belongs to when that helps, such as
`Section:`, `Subfunction:`, or `Main function:`.
Write `Section:` comments as a full-width banner above the section when they
introduce a new section of work.
The local comments should not be grouped together under the top comment as one
comment-only block. Each local comment belongs immediately above its own code
segment.
The local comments should stay to one line when possible.
Do not leave planning comments floating above unrelated code.
Do not create a detached comment-only banner once implementation has started.
Do not add local comments that no longer point at a real code block.
Each comment should precede the exact code it describes, with the local
comments still visibly serving the higher-level top comment.

### Companion guide standard

Use this when the repo keeps a separate guide beside lean code or tests:

1. Explain the big picture first.
2. If the file has a host step and a guest step, explain that order before the
   section details.
3. Say what problem each section solves before naming the function or test that
   handles it.
4. Use plain language only.
5. Do not assume the reader already knows the repo, the lab, or the workflow
   terms.
6. Keep lower-level implementation details secondary to the meaning.

The guide should help the next developer understand what happens first, what
depends on it, and where to look in the live file.
The guide should not rely on domain shorthand that only makes sense if the
reader already knows this repo.

### Resume rule

- If one stash clearly dominates, continue from that stash after explaining why.
- If multiple stashes must be recomposed, stop and require user confirmation.

### Save rule

When the user says `save here`, `record progress`, `continue later`, or
similar:

1. Update the workflow artifacts.
2. Record the QA reading.
3. Create a stash unless the user explicitly says not to.
4. Write the stash message in plain language and name the main function being
   worked on when there is one.

### Commit message standard

When creating a commit:

1. Keep the type and scope prefix, such as `feat(identity):` or
   `docs(workflow):`.
2. Make the rest of the message say the main idea the segment solves.
3. Use plain language.
4. Name the main function when that helps make the idea clearer.
5. Add a commit body with `Summary`, `Details`, and `Next Steps` sections.

Do not use workflow jargon in commit messages.
Do not turn the message into a status note or implementation diary.
The part after the prefix should tell the developer what this segment is for.

Use this shape:

`<type>(<scope>): <main idea>`

`Summary:`
one short plain-language paragraph that says what changed in one or two lines

`Details:`
- current increment or state when that helps
- the main function, file, or area touched
- the problem this segment solves
- key checks, blockers, or limits that matter for this commit
- tests run, or say they were not run

`Next Steps:`
one plain-language paragraph that clearly says what should happen next and why
in one or two lines, or says `none`

Only include details that help the next developer understand this commit fast.
Use `Summary` for the short handoff, `Details` for the useful context, and
`Next Steps` for what should happen after this commit.
Write `Summary` and `Next Steps` in the same plain style as the stash
messages.
Do not use bullets in `Summary` or `Next Steps`.
Do not assume the next developer already knows the next move.
Keep `Summary` and `Next Steps` to one or two lines each.
Keep both focused on meaning, not narration.
Keep each `Details` bullet to one or two lines.

### Repo workflow intent

Bootstrap guidance now lives in `AGENTS.md` to avoid duplicate startup reads.
The live status artifacts remain under `workflow\`.
The custom skills are installed globally through Codex and are not part of this
repo's runtime path contract.
