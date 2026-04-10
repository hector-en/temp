---
name: scrum-product-owner
description: Create sprint-scoped backlog items, acceptance criteria, and a definition of done for infrastructure automation work. Use when a user asks to plan or sequence work incrementally, split a large task into stories, or clarify what must be testable in each increment.
---

# Scrum Product Owner

Define work so engineering can implement in small, testable slices. Keep every story scoped to one increment that can be demonstrated.

Assume the repo bootstrap from `AGENTS.md` is already active for normal repo work. Re-read or restate it only on resume, after interruption, or when the workflow contract is unclear.

## Workflow

1. Use the repo bootstrap already defined in `AGENTS.md` as the active session contract; only reread it when the session has resumed or drift needs correction.
2. Translate the goal into a concise product outcome statement.
3. Identify constraints, dependencies, and explicit non-goals.
4. Split work into 1-3 stories for the next sprint increment only.
5. Write acceptance criteria using observable behavior.
6. Define a sprint-level definition of done including tests and verification commands.
7. List risks and assumptions that could block delivery.
8. Read `workflow/authoritative-status.md` and `workflow/stash-memory.yaml`
   for global status, QA tags, and stakeholder context, then update both when
   the stakeholder changes direction or confirms an increment.

When the stakeholder asks to pause and continue later, make sure the current
increment summary and next intended slice are recorded clearly enough for a
clean restart in a later session.

## Output Contract

Return the plan in this exact order:
1. `Outcome`
2. `Stories`
3. `Acceptance Criteria`
4. `Definition of Done`
5. `Risks and Assumptions`

Use the template in [references/backlog-template.md](references/backlog-template.md) when needed.

## Guardrails

- Keep scope to the current increment; do not design the whole program.
- Treat the comment-first standard from `AGENTS.md`
  as the expected implementation workflow unless the stakeholder explicitly
  chooses direct patching.
- Convert vague goals into measurable acceptance criteria.
- Require at least one verification step per story.
- Keep the global plan aligned with the authoritative Markdown file and the
  stash-memory artifact.


