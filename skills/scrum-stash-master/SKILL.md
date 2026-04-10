---
name: scrum-stash-master
description: Track per-increment code state, blockers, dead ends, and completion checkpoints using git stash conventions plus a YAML ledger. Use when coding work needs temporary preservation, blocker tracking, increment retrospectives, or cross-agent process memory that should persist outside the current chat.
---

# Scrum Stash Master

Act as the process and state-tracking role that stays alongside the coding agent. Use git stash conventions carefully, keep `workflow/authoritative-status.md` and `workflow/stash-memory.yaml` current, and coordinate with `qa-state-analyst` so every important state has explanation and next steps.

Assume the repo bootstrap from `AGENTS.md` is already active for normal repo work. Re-read or restate it only on resume, after interruption, or when the workflow contract is unclear.

Treat the stash history as a time-series experiment log for the codebase, not
just a stack of temporary snapshots. The goal on resume is to reconstruct the
best next code state from what has been learned so far. Sometimes that means
applying one stash. Sometimes it means synthesizing a new working state from
the strongest code fragments, successful tests, and resolved insights across
multiple stashes.

Treat phrases such as `save here`, `record progress`, `stop here`, `continue
later`, `checkpoint this`, or similar pause language as an instruction to
record the current development state and create a real git stash unless the
user explicitly says not to stash.

## Workflow

1. Use the repo bootstrap already defined in `AGENTS.md` as the active session contract; only reread it when the session has resumed or drift needs correction.
2. Read `workflow/authoritative-status.md` and `workflow/stash-memory.yaml`
   before any coding session.
3. Inspect `git status`, `git stash list`, and relevant `git stash show -p` output.
4. Treat the stash list and `stash_entries` ledger as time-series data, not as
   isolated snapshots.
5. On every resumed session, go into `ok lets first see where we at` mode:
   - identify the relevant stashes for the current increment
   - compare their messages, diffs, and test state
   - determine whether one stash is the strongest continuation point or
     whether the next working state should be recomposed from multiple stashes
   - identify which older stashes are still useful history versus resolved or
     obsolete blockers
   - record the continuation rationale explicitly
6. Classify the session state:
   - `wip`
   - `blocked`
   - `dead-end`
   - `done`
7. Use the stash naming convention from [references/stash-conventions.md](references/stash-conventions.md).
8. Read the current QA tags and commentary from `workflow/stash-memory.yaml`.
9. Update `workflow/authoritative-status.md` with the human-facing session
   state, blockers, and next action.
10. Record the same state in `workflow/stash-memory.yaml`.
11. Tell the coding agent and product owner what changed, what is blocked, and
   what should happen next.

When multiple stashes exist for the same increment:
- treat them as a path-dependent learning sequence
- preserve the strongest successful snippets, not just the newest code
- extract the useful code, test shape, and decision logic from each stash
- identify what should be carried forward, what should be ignored, and what
  should be retired
- if needed, create a new recomposed working state and record which stashes
  it was built from

When the user is pausing for later:
- record the current increment slice and test state
- record whether the working tree is intentionally left dirty
- record the exact next resume step
- create an actual git stash by default using the naming convention
- make the stash message plain and meaning-first
- include the current increment and state in short form when they help the next resume
- name the main function being worked on in the stash message when there is one
- pull that increment and state from the workflow files so the stash message matches the recorded status
- add a short file:line hint in the stash message only when one location is clearly the center of the work
- write the resulting stash reference back into the workflow artifacts
- skip stash creation only if the user explicitly asks not to stash

When the user is resuming later:
- inspect the stash timeline first before applying anything
- prefer the most promising continuation for the current increment, not merely
  the most recent stash
- explicitly decide between:
  - `single-stash resume`
  - `recomposed resume`
- require explicit user confirmation before proceeding with a `recomposed resume`
- do not require extra confirmation for a `single-stash resume` once the
  rationale has been explained
- if the code has already been saved into a new single dominant stash, prefer
  that stash and avoid prompting again unless the user asks to compare or
  recombine older checkpoints
- keep older stashes that still represent useful alternatives or audit history
- drop or mark obsolete stashes once their blockers are resolved or their path
  is clearly superseded

## Guardrails

- Do not stash or pop user work silently when the working tree contains changes the user may still be editing.
- Treat the comment-first standard from `AGENTS.md`
  as the expected coding shape when recording or reviewing checkpoints: comments
  should precede the exact code they describe, not float separately above it.
- Prefer `git stash push -m` over older stash forms.
- Use `git stash apply` to inspect a candidate state before `pop` when risk is non-trivial.
- Keep stash messages plain and concrete.
- Do not use workflow jargon in stash messages when plain words will do.
- Use short codes only when they help resume work quickly.
- Do not lead stash messages with coded prefixes that add process data but no developer meaning.
- Keep detailed resume data in the ledger when it would make the stash line too noisy.
- Treat the Markdown file as the stakeholder-readable authority.
- Treat the YAML ledger as the durable structured memory.
- Treat git stash as the temporary code carrier.
- Recording progress normally implies creating a stash entry. If stash creation
  is intentionally skipped, still update the Markdown and YAML artifacts and
  say that no stash was created.
- Do not apply the first stash blindly on resume; justify why it is the best
  continuation point from the available time-series history.
- Do not recombine code casually. If snippets are merged from multiple stashes,
  record exactly which stashes contributed, why they were chosen, and what was
  intentionally left behind.

## Output Contract

Return updates in this order:
1. `Session State`
2. `Stash Timeline Reading`
3. `Continuation Decision`
3. `Ledger Update`
4. `Blockers`
5. `Next Action`

Use:
- [references/stash-conventions.md](references/stash-conventions.md) for naming and lifecycle rules.
- [references/ledger-schema.md](references/ledger-schema.md) for the YAML structure.
- [scripts/record_stash_state.ps1](scripts/record_stash_state.ps1) to append a new ledger entry.


