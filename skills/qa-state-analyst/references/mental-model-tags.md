# Mental Model Tags

Use these tags to describe the quality and understanding state of the codebase.
Each tag must be accompanied by commentary and next steps.

## Tag Catalog

- `exploring`
  - Meaning: The team is still building a basic understanding of the code or behavior.
  - Commentary prompt: What is still being learned?
  - Next step prompt: What artifact or observation would reduce uncertainty?

- `needs-criteria`
  - Meaning: Acceptance criteria are too weak or missing.
  - Commentary prompt: Which expected behaviors are not yet measurable?
  - Next step prompt: What criteria should the product owner define?

- `needs-observation`
  - Meaning: Real system behavior or command output has not been observed yet.
  - Commentary prompt: What real data is missing?
  - Next step prompt: Which command, log, or environment check should be run?

- `hypothesis`
  - Meaning: The current direction is based on an unverified assumption.
  - Commentary prompt: What assumption is currently driving the design?
  - Next step prompt: How can the assumption be tested cheaply?

- `risk-identified`
  - Meaning: A concrete technical or operational risk has been found.
  - Commentary prompt: What might break or mislead the team?
  - Next step prompt: What mitigation should happen before more coding?

- `regression-risk`
  - Meaning: Existing behavior may be broken by the current change.
  - Commentary prompt: Which current behaviors are at risk?
  - Next step prompt: Which tests or manual checks should be added?

- `test-gap`
  - Meaning: There is insufficient test coverage for the decision being made.
  - Commentary prompt: What important behavior is not asserted?
  - Next step prompt: Which failing test should be added first?

- `stakeholder-review`
  - Meaning: The implementation direction needs stakeholder confirmation.
  - Commentary prompt: Which product or usage assumption needs validation?
  - Next step prompt: What specific question should be asked?

- `ready-for-red`
  - Meaning: The team understands enough to write the next failing test.
  - Commentary prompt: Why is the next behavior slice now testable?
  - Next step prompt: What is the next `It` block?

- `ready-for-green`
  - Meaning: The failing test is clear and the implementation approach is bounded.
  - Commentary prompt: What is the minimal implementation?
  - Next step prompt: What exact code boundary should be changed?

- `ready-for-merge`
  - Meaning: The increment appears coherent, tested, and reviewable.
  - Commentary prompt: Why is this increment stable enough to integrate?
  - Next step prompt: What verification or review remains?

- `risk-accepted`
  - Meaning: A known risk remains, but the team has consciously decided to proceed.
  - Commentary prompt: What risk is being carried intentionally?
  - Next step prompt: How should it be monitored or revisited later?
