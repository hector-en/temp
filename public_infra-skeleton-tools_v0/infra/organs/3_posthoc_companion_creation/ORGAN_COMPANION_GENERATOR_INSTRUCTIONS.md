# Companion Generator Instructions — vmuser Real-Organ Transition

**Purpose:** use this file in a new chat after each transition-to-real-organs Codex implementation run to generate a developer-readable companion version of the current real-organ codebase.

The companion is not a replacement for the code. It is a parallel explanation layer that a developer can read while walking through the actual files, especially when the real code has few or no comments.

---

## Project workspace root

The canonical project workspace root for this real-organ work is:

```text
/home/researchscientist/workspace
```

Codex is expected to be launched from inside this folder. Treat this path as the working tree root for relative repository paths, batch files, master files, templates, and implementation commands.

Rules:
- Prefer relative paths from `/home/researchscientist/workspace` when reading project code.
- Do not assume `/workspace` is the project root unless a specific batch explicitly says so.
- If the current working directory is not `/home/researchscientist/workspace`, report the mismatch before editing or generating location-sensitive output.
- Keep output roots separate: development recordings go to `/mnt/egress/organs/dev-recordings` and readable companion documentation goes to `/mnt/ingress/infra/organs/companion`.

---

## Path split

Use two separate roots:

```text
/mnt/egress/organs/dev-recordings
```

Codex writes real-organ implementation run recordings, postcheck evidence, command logs, changed-file lists, gaps, TODO notes, contract changes, and real-organ evidence here.

```text
/mnt/ingress/infra/organs/companion
```

The companion generator writes the normal readable real-organ companion documentation here, organized by the same organ batch slugs.

---

## Output root hard rule

Normal companion-generation output goes to the ingress organ companion documentation tree:

```text
/mnt/ingress/infra/organs/companion
```

This is the canonical root for readable real-organ companion documentation. The generator must create parent directories if missing. If `/mnt/ingress/infra/organs/companion` is not writable, stop and report the problem instead of silently writing somewhere else.

Codex development recordings and post-run evidence are separate and live under:

```text
/mnt/egress/organs/dev-recordings
```

The companion generator may read from `/mnt/egress/organs/dev-recordings`, but it must write normal companion output to `/mnt/ingress/infra/organs/companion`.

---

## Inputs to provide after each real-organ run

Upload or provide these together:

```text
1. The relevant real-organ Codex batch folder or zip
2. The batch SPEC.md
3. The batch RUN_INSTRUCTIONS.md
4. The batch CODEX_PROMPT.txt
5. The batch POSTCHECK_TEMPLATE.md
6. The filled postlog/postcheck file from Codex
7. The batch INTEGRATION_REQUEST.md, if created
8. The latest codebase analysis output after the run
9. The transition-to-real-organs master MD
10. The skeleton-dummy master MD or relevant skeleton companion docs
11. CONFIG_TOOL.md only if config/lv/context is relevant
12. Prior real-organ companion docs if this batch continues previous work
```

The assistant should treat the batch files and postlog as the run-specific truth, and the codebase upload as the actual implementation truth.

---

## Request template for a new chat

Use this prompt when starting a real-organ companion-generation chat:

```text
Read the uploaded real-organ batch files, the filled postlog/postcheck file, and the latest codebase analysis output.

Create or update the real-organ companion documentation for this implemented batch.

The companion must explain the actual code that exists now, not just the intended design.

Start with a short overview of what changed in this run.
Then write a developer-readable companion section that can be read alongside the code.
Explain files, folders, CLIs, schemas, contracts, output artifacts, smoke tests, contract changes, and remaining skeleton/dummy behavior.
Call out gaps between SPEC and implementation.
Call out preserved skeleton contracts and any intentional contract revisions.
Summarize any INTEGRATION_REQUEST.md as a later operator/config handoff, not as work done by this companion step.
Do not invent code behavior that is not visible in the codebase, postlog, or integration request.
Do not modify code.
Return a Markdown companion file.
```

---

## Output location and naming

The companion documentation should be written under the ingress organ companion documentation root:

```text
/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md
```

The companion generator should read the batch's Codex development recording folder from:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/
```

This is the canonical companion output root. Do not write companion output under `/mnt/ingress/infra/skeleton/companion`, `/workspace/artifacts/companions`, `/mnt/data/companions`, or `/mnt/egress/organs/dev-recordings/companions` unless explicitly told to use a temporary fallback because `/mnt/ingress/infra/organs/companion` is unavailable. Each batch should have exactly one main companion file.

---

## Required companion structure

Each generated companion file must use this structure:

```md
# Companion — <real-organ batch number> <batch title>

## 1. Short run overview

- What this real-organ batch was supposed to replace or build.
- What Codex actually changed.
- What smoke checks/tests were run.
- Whether this batch is complete, partial, or blocked.
- Any important gap between SPEC and code.
- Whether any skeleton contracts changed.

## 2. How this fits into the real-organ transition

Explain where this batch sits in the transition-to-real-organs plan.
Name the real-organ batch, dependent skeleton batch(es), upstream/downstream dependencies, and what skeleton behavior this batch replaces.

## 3. Files and folders created or changed

For each important path:

### `<path>`

- Purpose.
- Why it exists.
- Main functions/classes/configs inside.
- What other files call or read it.
- Which skeleton/dummy behavior it replaces.
- What future hardening or live integration will likely extend.

## 4. Runtime or CLI behavior

Explain every command, script, module entrypoint, smoke command, dry-run command, and guarded live command that exists after this batch.

For each command:

```text
command here
```

Explain:
- What it reads.
- What it writes.
- Whether it is real local, guarded real, dry-run, or still dummy.
- Expected success output.
- Expected failure output.
- Whether live/provider actions are possible and how they are gated.

## 5. Data contracts, artifacts, and contract preservation

List schemas, JSON files, YAML files, generated Markdown reports, smoke outputs, logs, and status files.

For each artifact:
- Producer.
- Consumer.
- Required fields.
- Preserved skeleton fields.
- New real-organ fields.
- Any intentional contract revision and where it was approved.

## 6. Developer walkthrough

Write a guided reading order for the code.

Example:

```text
1. Start at <entrypoint>
2. Read <schema>
3. Read <real organ module>
4. Read <writer/runner>
5. Run <smoke command>
6. Inspect <output file>
```

## 7. Important design decisions

Explain the design choices in plain language.
Do not over-explain generic Python or shell basics.
Focus on why the implementation is shaped this way and how it preserves skeleton contracts while replacing dummy internals.

## 8. Safety and live-action boundaries

Call out anything that must not happen:
- no config-tool edits unless explicitly scoped
- no credential reads
- no broad bootstrap
- no live Runpod launch unless explicitly guarded
- no Paperclip live write unless explicitly guarded
- no Agentfield live submission unless explicitly guarded
- no OpenClaw/model call unless explicitly guarded
- no vault overwrite

## 9. Gaps, TODOs, and remaining skeleton hooks

List:
- incomplete SPEC items
- TODOs left by Codex
- skeleton/dummy code still present
- places where first-pass real code should later be hardened
- open questions for Runpod, Agentfield, Paperclip, OpenClaw, or science modules

## 10. Postcheck summary

Summarize the filled postlog/postcheck:
- Changed files
- Tests run
- Results
- Known failures
- Contract changes
- Next recommended batch

## 11. Integration request summary

If `INTEGRATION_REQUEST.md` exists, summarize:
- Suggested integration type
- Actual commands/outputs/packages requested
- Safety boundaries
- Open questions
- Whether config integration should remain deferred
```

---

## Real-organ companion folders

Use these exact folder slugs:

```text
organs/R01-contract-audit
organs/R02-real-grn-dsl-simulator
organs/R03-real-nca-local-rule
organs/R04-real-art2-artmap
organs/R05-real-mechanism-report
organs/R06-real-parameter-search
organs/R07-real-runpod-boundary
organs/R08-real-openclaw-pkm-bridge
organs/R09-real-agentfield-experiment
organs/R10-real-paperclip-adapter
organs/R11-real-campaign-orchestration
organs/R12-end-to-end-real-local-smoke
```

---

## Companion writing rules

1. Explain the actual implementation, not the imagined implementation.
2. Use the postlog and codebase as source of truth for what changed.
3. Use the SPEC and transition master MD as source of truth for intended real-organ behavior.
4. Use `INTEGRATION_REQUEST.md` only as a later operator/config handoff, not as proof that config was changed.
5. Use skeleton companion/master material as source of truth for contracts that should be preserved.
6. Clearly mark gaps where the implementation differs from the intended behavior.
7. Clearly mark any skeleton/dummy behavior that remains.
8. Do not invent missing functions, files, or tests.
9. Do not paste full source files.
10. Quote only short code snippets when necessary.
11. Prefer path-by-path explanations and reading order.
12. Keep a short overview before the deep dive.
13. Write for a future developer who wants to understand the real-organ codebase fast.

---

## Cross-batch index

In addition to each batch companion, maintain an optional index:

```text
/mnt/ingress/infra/organs/companion/INDEX.md
```

The index should contain:

```md
# Real-Organ Companion Index

| Batch | Companion | Status | Last codebase source | Notes |
|---:|---|---|---|---|
| R01 | organs/R01-contract-audit/COMPANION.md | complete/partial/blocked | <codebase file> | <short note> |
```

Update this index after every companion generation if the user asks for it.

---

## Config tool rule

The config tool is context, not an implementation target for these real-organ companions.

Do not tell Codex or developers to edit:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh
```

unless a dedicated future config-tool milestone explicitly says to modify it.

For real-organ implementation, project code should live under the project workspace tree rooted at:

```text
/home/researchscientist/workspace
```

Use the selected batch SPEC and the transition master to determine exact repository and output paths.
