---
name: patch-crafter
description: Create or revise minimal unified diff patch files for this repo. Use when the user asks for a .patch file, red/green patch pair, diff -u output, or a surgical code update that must preserve existing surrounding lines and be anchored to confirmed real file contents.
---
# Unified Patch Crafter

Create patch files only after confirming the exact current file lines that the patch will touch.

## When to use this skill

Use this skill when the deliverable is any of:

- a `.patch` file
- a red patch or green patch
- unified diff output from `diff -u` or `patch` workflows
- a minimal hunk update rather than a full-file rewrite
- a repo code change where the user explicitly cares about preserving surrounding lines and patch applicability

For normal PowerShell coding, pair with `powershell-pair-coder`. This skill owns the patch-generation step.

## Required workflow

1. Confirm the target files.
2. Confirm the exact current lines before writing any diff header or `@@` hunk.
3. Prefer local numbered output over GitHub when possible.
4. Use the smallest possible unified diff.
5. Preserve unchanged surrounding lines exactly.
6. Do not replace whole file contents unless the user explicitly wants that.

## How to confirm anchors

Prefer one of these:

```bash
nl -ba path/to/file | sed -n 'START,ENDp'
nl -ba path/to/file | tail -n 80
```
or output all commands into a log file like in this template:
```bash
mkdir -p patches/logs
{
  echo "=== authoritative-status head ==="
  nl -ba workflow/authoritative-status.md | sed -n '1,220p'
  echo
  echo "=== authoritative-status tail ==="
  nl -ba workflow/authoritative-status.md | tail -n 120
  echo
  echo "=== stash-memory head ==="
  nl -ba workflow/stash-memory.yaml | sed -n '1,260p'
  echo
  echo "=== stash-memory tail ==="
  nl -ba workflow/stash-memory.yaml | tail -n 180
} > patches/logs/workflow-line-anchors.log
```

If the local repo output is not available, inspect the GitHub file and then ask the user for the numbered local snippet before finalizing the patch.

Before writing the patch, restate:

- file to edit
- exact confirmed anchor lines
- whether the patch is additive, replacement, or deletion

If those anchors are not confirmed, stop and ask.

## Patch rules

- Use unified diff format.
- Keep hunks tight.
- Add only the lines that changed.
- Do not collapse multiple independent edits into one giant hunk when smaller hunks are possible.
- Do not normalize formatting outside the requested behavior slice.
- Preserve original indentation, spacing style, and surrounding comments unless the change itself requires otherwise.
- If the user requests separate red and green phases, produce two separate patch files.

## Repo-specific behavior

For this repo:

- patch work should follow the bootstrap contract in `AGENTS.md`
- when PowerShell code or tests are involved, use `powershell-pair-coder` for the behavior slice and this skill for the final patch output
- when tests drive the slice, coordinate with `scrum-powershell-tdd`
- if patch creation drifts from the confirmed current file contents, stop and correct the anchors before continuing

## Output contract

Return patch work in this order:

1. `Confirmed Anchors`
2. `Patch Shape`
3. `Unified Diff`
4. `Apply Command`
5. `Verification Command`

## Guardrails

- Never invent line anchors.
- Never emit a hunk header based on guessed line numbers.
- Never rewrite a full file when a local surgical diff is enough.
- When the user says the patch must be minimal, treat that as mandatory.
- If the patch failed to apply once, re-read the real current lines before writing the next version.
