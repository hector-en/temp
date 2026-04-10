# Review Sequence

Use this order before assigning QA tags.

## 1. Read With Intent
- Identify the current increment goal.
- Identify the expected user or operator behavior.

## 2. Inspect Artifacts
- Code under change
- Tests that prove the change
- Related docs and workflow memory
- Current git diff or stash state if relevant

## 3. Build a Mental Model
- What is known?
- What is assumed?
- What is missing?
- What is risky?

## 4. Assign Tags
- Choose the fewest tags that explain the current state.
- Add commentary and next steps for every tag.

## 5. Feed the Team
- Product owner gets criteria gaps and stakeholder-review items.
- Pair coder gets test-gap, ready-for-red, and ready-for-green items.
- Stash master gets blocked, dead-end, or ready-for-merge implications.
