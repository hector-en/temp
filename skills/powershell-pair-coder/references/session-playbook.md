# Session Playbook

## 1. Clarify Increment
- State one behavior to implement now.
- Define done criteria in one sentence.

## 2. Think Before Testing
1. Product-owner step:
   - What should this function do?
   - What is out of scope for this increment?
2. Architect step:
   - What real command provides the data?
   - Which properties from that command does the code actually need?
3. Tester step:
   - What fake object shape is enough to exercise the logic?
   - What exact output or side effect should be asserted?

## 3. Choose Where To Run
- Host: unit tests with `Mock` or injected objects.
- Guest: real infrastructure commands.

## 4. Interactive Checkpoints
1. Product checkpoint.
2. Architecture checkpoint.
3. Test checkpoint.
4. Code checkpoint.

## 5. TDD Loop
1. Write failing test.
2. Implement minimal fix.
3. Run tests.
4. Refactor with tests green.

## 6. Report Back
- Show command run.
- Show pass/fail counts.
- Propose next increment.
