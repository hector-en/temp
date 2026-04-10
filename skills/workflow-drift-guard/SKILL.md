---
name: workflow-drift-guard
description: Detect workflow drift against the repo's init, checkpoint, and comment-first rules. Use when a session resumes, after interruptions, before moving from comments or red to code or green, or whenever the team wants a severity-rated compliance check.
---

# Workflow Drift Guard

Act as the workflow-compliance role that inspects whether the current session is
still following the repo contract. Focus on process drift, not product design or
code quality in the abstract.

Treat the repo bootstrap defined in `AGENTS.md` as the baseline contract. Assume it is already active for normal repo work, and only require a re-read when the session has resumed, drift is suspected, or the user explicitly asks for recalibration. When relevant, also read the currently active role instructions such as `powershell-pair-coder`, `companion-guide-writer`, `qa-state-analyst`, or `scrum-stash-master`.

## Workflow

1. Use the repo bootstrap already defined in `AGENTS.md` as the contract baseline; reread it only when the session has resumed or the workflow contract is unclear.
2. Read the active role instruction that governs the current mode.
3. Inspect the recent diff, recent commits, and the latest assistant/user
   interaction that established the mode.
4. Check for drift across these axes:
   - init discipline
   - active mode compliance
   - top-to-local comment structure
   - comment-to-code adjacency
   - companion guide clarity when relevant
   - approval/checkpoint compliance
   - interruption/restart handling
   - stash/pause discipline when relevant
5. Score each axis with the rubric in
   [references/drift-rubric.md](references/drift-rubric.md).
6. Report the strongest violations first and recommend the smallest correction
   that restores compliance.
7. If the drift is recurring, propose a guardrail update in the relevant skill,
   README section, or workflow file.

## Output Contract

Return updates in this order:
1. `Contract Baseline`
2. `Drift Assessment`
3. `Severity`
4. `Corrections`
5. `Guardrail Update`

Use:
- [references/drift-rubric.md](references/drift-rubric.md) for scoring.

## Guardrails

- Distinguish workflow drift from code-quality issues.
- Call out the strongest violation first instead of listing every minor miss.
- Prefer the smallest corrective action that gets the session back on-policy.
- If no meaningful drift is present, say so explicitly.
- Treat detached comments or code that leaps past a required pause as a serious
  workflow violation in involved modes.
- Treat a missing top comment, or local comments that do not clearly support
  the top comment, as real drift rather than a cosmetic issue.
- Treat a stacked comment block where the top comment and all local comments
  are grouped together above the section, instead of distributing the local
  comments to their own code segments, as workflow drift.
- Treat jargon-heavy comments as drift when the same meaning could be said more
  plainly.
- Treat a companion guide that jumps into low-level details before explaining
  the host flow, guest flow, or bigger problem as workflow drift when that
  guide is meant to help a returning developer.





