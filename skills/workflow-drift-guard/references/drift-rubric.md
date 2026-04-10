# Drift Rubric

Score each axis from `0` to `3`.

- `0`
  - compliant
  - no meaningful drift
- `1`
  - slight drift
  - small shortcut or wording miss, but the workflow intent is still intact
- `2`
  - moderate drift
  - a real workflow boundary was skipped or blurred, but the session can be
    corrected without backing out major work
- `3`
  - strong drift
  - the session materially violated the active mode or init contract and should
    be recalibrated before more coding

Recommended interpretation:

- `0-2 total`
  - healthy
- `3-6 total`
  - noticeable drift
- `7+ total`
  - strong drift; stop and recalibrate

Important axes:

1. Init Discipline
   - Was the repo bootstrap from `AGENTS.md` active or restated when the session actually required recalibration?
2. Mode Compliance
   - Did the session actually follow the requested mode?
3. Top-to-Local Comment Structure
   - Does each section start with a clear top comment that says what problem
     the section solves?
   - Do the following local comments clearly support that top comment?
   - Is the top comment kept as its own block above the wider section, rather
     than merged with all later local comments into one stacked comment
     block?
   - Does the top comment precede the relevant code block and all other
     comments in that section?
4. Comment-to-Code Adjacency
   - Do comments precede the exact code they describe?
   - Does each local comment sit above its own meaningful code segment, rather
     than being collected with other local comments at the top?
   - Are the comments written in plain language instead of workflow jargon?
5. Approval Boundary
   - Did implementation jump ahead of an involved-mode pause?
6. Interruption Handling
   - After an interruption or resume, was the workflow contract restated?
7. Pause/Stash Discipline
   - When pausing or checkpointing, were workflow artifacts and stash rules
     followed?



