# Stash Conventions

Use git stash as a temporary code carrier, not as the only project memory.

## Message Format

Use:
`<increment>/<state>: <function-or-area> - <plain summary>`

Optional:
`<increment>/<state>: <function-or-area> - <plain summary> @ <path:line>`

Examples:
- `inc4/wip: Ensure-HqSecurityPrincipals - add missing user and group creation`
- `inc4/blocked: Invoke-HqDedupVolume - blocked by Get-WindowsFeature on host`
- `inc2/dead-end: Get-HqDiskRoleMap - path fallback was wrong`
- `inc2/done: Update-HqDiskMetadataModule - host flow ready for review`
- `inc4/wip: Ensure-HqSecurityPrincipals - add missing user and group creation @ app/configure_hq.ps1:1278`

## Message Anatomy

Example:
`inc4/wip: Ensure-HqSecurityPrincipals - add missing user and group creation`

Meaning:
- `inc4` = current increment from the workflow files
- `wip` = current state from the workflow files
- `Ensure-HqSecurityPrincipals` = main function or work area
- `add missing user and group creation` = short plain summary of what this checkpoint represents

Read stash messages as:
`<increment>/<state>: <function-or-area> - <plain checkpoint summary>`

## Writing Style

- Use plain language.
- Say what changed or what is blocked.
- Use short codes where they help, such as `inc4` or `wip`.
- Name the main function being worked on when there is one.
- If no single function fits, name the file area instead.
- Add `@ path:line` only when one file or line is the clear center of the work.
- Keep file hints short and only use the most useful one or two.
- Do not use workflow jargon like `slice`, `seam`, `green`, `red`, or `bootstrap`.
- Do not add coded prefixes that add no meaning, such as role names that the developer does not need in the stash list.
- Keep the summary short, but make it meaningful without opening the stash.

## Where Status Lives

- Take increment and state from `workflow/authoritative-status.md` and
  `workflow/stash-memory.yaml`.
- Keep the stash message focused on what the developer needs to read fast, but
  carry the current increment and state when they help with resume decisions.
- Pull these extra points from the authoritative files when they help:
  - current blockers
  - current QA tags
  - next resume step
  - the main file or function being changed
  - the most useful file:line reference

## What Belongs In The Ledger

The stash line should stay short. Put the richer context in the ledger entry:

- `notes`: short resume note in plain language
- `focus_refs`: key file or function references such as `app/configure_hq.ps1:1278`
- `qa_tags_snapshot`: the QA tags that mattered at save time
- `blockers_snapshot`: blockers that mattered at save time
- `next_step`: the next action the developer should take after restore

## Status Meanings

- `wip`: incomplete but worth preserving temporarily
- `blocked`: cannot proceed without a decision, dependency, or user input
- `dead-end`: explored path that should not be continued
- `done`: candidate increment state that has passed its checks

These states still belong in the workflow ledger even when the stash message
only shows the short code form.

## Command Guidance

- Inspect: `git stash list`
- Diff: `git stash show -p stash@{n}`
- Save: `git stash push -m "<message>"`
- Apply safely: `git stash apply stash@{n}`
- Remove after intentional discard or successful apply: `git stash drop stash@{n}`

Prefer `apply` plus explicit `drop` over `pop` when the risk of loss is non-trivial.

## Time-Series Use

Treat multiple stashes for the same increment as a timeline of coding intent
and progress.

On resume:
- inspect the relevant stashes for the active increment
- compare their messages, diffs, test state, and blocker status
- decide whether the best continuation is:
  - a single stash
  - a recomposed working state built from multiple stashes
- keep stashes that still represent useful history or alternatives
- drop or mark stashes whose blockers are resolved or whose path is clearly obsolete

## Recomposition Use

If no single stash represents the best way forward, treat the stash history as
an experiment series and synthesize the next state intentionally.

For each relevant stash, identify:
- useful code snippets to keep
- useful test snippets to keep
- decisions or insights learned
- blockers or dead ends to leave behind

When recomposing:
- record the source stashes
- record which snippets or ideas were selected from each
- explain why the recomposed state is stronger than resuming any single stash
- prefer creating a new working state plus a new stash/ledger entry over
  silently mutating history
