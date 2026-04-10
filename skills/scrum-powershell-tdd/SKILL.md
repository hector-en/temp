---
name: scrum-powershell-tdd
description: Deliver PowerShell infrastructure changes in small increments using strict red-green-refactor and Pester tests. Use when implementing or refactoring PowerShell scripts where behavior must be verified, mocked, and safe to rerun.
---

# Scrum Powershell Tdd

Implement one behavior slice at a time. Keep external side effects isolated behind functions that can be mocked in tests.

## Workflow

1. Define one behavior slice with a failing test first.
2. Write the minimum implementation to pass the test.
3. Refactor for readability and idempotence without changing behavior.
4. Repeat for the next slice.
5. Run the full test file after each slice.

## TDD Contract

- Write tests under `tests/` using Pester syntax compatible with the local version.
- Mock system cmdlets (`Get-Disk`, `Set-Disk`, `Enable-DedupVolume`, `New-SmbShare`) in unit tests.
- Keep functions pure where possible; inject policy/config as parameters.
- Avoid direct `Write-Host` in business functions; return objects for assertions.

Use [references/pester3-cheatsheet.md](references/pester3-cheatsheet.md) for local compatibility notes.
Use [scripts/new-increment.ps1](scripts/new-increment.ps1) to scaffold test and implementation files.

## Guardrails

- Fail fast when assumptions are violated (missing disk mappings, missing features).
- Keep each commit limited to one behavior slice plus tests.
- Keep the type and scope prefix in commit messages, such as `feat(identity):` or `docs(workflow):`.
- Write the rest of the commit message in plain language.
- Make the rest of the commit message say the main idea this segment solves.
- Name the main function in the commit message when one function makes that idea clearer.
- Add a commit body with `Summary`, `Details`, and `Next Steps` sections.
- Do not use workflow jargon in commit messages when plain words will do.
- Do not make the rest of the commit message read like a status note.
- Pull relevant details from `workflow/authoritative-status.md` and `workflow/stash-memory.yaml` when they help explain the commit.
- In `Summary`, state the change in one short plain-language paragraph of one or two lines.
- In `Details`, include only the useful context: idea, main function or file, checks run, blockers, or limits.
- In `Next Steps`, state the next clear move in plain language and explain it clearly enough for someone returning later in one or two lines, or say `none`.
- Write `Summary` and `Next Steps` in the same plain style as the stash messages.
- Do not use bullets in `Summary` or `Next Steps`.
- Keep `Summary` and `Next Steps` focused on meaning, not narration.
- Keep each `Details` bullet to one or two lines.
- Prefer object output over console output for testability.
