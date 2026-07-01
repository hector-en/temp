# Companion Generator Instructions — vmuser Skeleton Implementation

**Purpose:** use this file in a new chat after each Codex implementation run to generate a developer-readable companion version of the current codebase.

The companion is not a replacement for the code. It is a parallel explanation layer that a developer can read while walking through the actual files, especially when the real code has few or no comments.

---


## Project workspace root

The canonical project workspace root for this skeleton work is:

```text
/home/researchscientist/workspace
```

Codex is expected to be launched from inside this folder. Treat this path as the working tree root for relative repository paths, batch files, master files, templates, and implementation commands.

Rules:
- Prefer relative paths from `/home/researchscientist/workspace` when reading or editing project code.
- Do not assume `/workspace` is the project root unless a specific batch explicitly says so.
- If the current working directory is not `/home/researchscientist/workspace`, stop and report the mismatch before editing.
- Keep output roots separate: development recordings go to `/mnt/egress/dev-recordings` and readable companion documentation goes to `/mnt/ingress/infra/skeleton/companion`.

## Path split

Use two separate roots:

```text
/mnt/egress/dev-recordings
```

Codex writes implementation run recordings, postcheck evidence, command logs, changed-file lists, gaps, and TODO notes here.

```text
/mnt/ingress/infra/skeleton/companion
```

The companion generator writes the normal readable companion documentation here, organized by the same skeleton batch slugs.


## Output root hard rule

Normal companion-generation output goes to the ingress platform skeleton documentation tree:

```text
/mnt/ingress/infra/skeleton/companion
```

This is the canonical root for readable companion documentation. The generator must create parent directories if missing. If `/mnt/ingress/infra/skeleton/companion` is not writable, stop and report the problem instead of silently writing somewhere else.

Codex development recordings and post-run evidence are separate and live under:

```text
/mnt/egress/dev-recordings
```

The companion generator may read from `/mnt/egress/dev-recordings`, but it must write normal companion output to `/mnt/ingress/infra/skeleton/companion`.

## Inputs to provide after each run

Upload or provide these together:

```text
1. The relevant Codex batch folder or zip
2. The batch SPEC.md
3. The batch RUN_INSTRUCTIONS.md
4. The batch CODEX_PROMPT.txt
5. The batch POSTCHECK_TEMPLATE.md
6. The filled postlog/postcheck file from Codex
7. The batch INTEGRATION_REQUEST.md, if created
8. The latest codebase analysis output after the run
9. The master skeleton-dummy implementation MD
10. CONFIG_TOOL.md only if config/lv/context is relevant
```

The assistant should treat the batch files and postlog as the run-specific truth, and the codebase upload as the actual implementation truth.

---

## Request template for a new chat

Use this prompt when starting a companion-generation chat:

```text
Read the uploaded batch files, the filled postlog/postcheck file, the integration request if present, and the latest codebase analysis output.

Create or update the companion documentation for this implemented batch.

The companion must explain the actual code that exists now, not just the intended design.

Start with a short overview of what changed in this run.
Then write a developer-readable companion section that can be read alongside the code.
Explain files, folders, CLIs, schemas, contracts, output artifacts, and smoke tests.
Call out gaps between SPEC and implementation.
Summarize any INTEGRATION_REQUEST.md as a later operator/config handoff, not as a completed config change.
Do not invent code behavior that is not visible in the codebase, postlog, or integration request.
Do not modify code.
Return a Markdown companion file.
```

---

## Output location and naming

The companion documentation should be written under the ingress platform skeleton documentation root:

```text
/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md
```

The companion generator should read the batch's Codex development recording folder from:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/
```

This is the canonical companion output root. Do not write companion output under `/workspace/artifacts/companions`, `/mnt/data/companions`, or `/mnt/egress/dev-recordings/companions` unless explicitly told to use a temporary fallback because `/mnt/ingress/infra/skeleton/companion` is unavailable. Each batch should have exactly one main companion file.

---

## Required companion structure

Each generated companion file must use this structure:

```md
# Companion — <batch number> <batch title>

## 1. Short run overview

- What this batch was supposed to build.
- What Codex actually changed.
- What smoke checks/tests were run.
- Whether this batch is complete, partial, or blocked.
- Any important gap between SPEC and code.

## 2. How this fits into the skeleton

Explain where this batch sits in the master skeleton plan.
Name the layer, bundle, step range, and upstream/downstream dependencies.

## 3. Files and folders created or changed

For each important path:

### `<path>`

- Purpose.
- Why it exists.
- Main functions/classes/configs inside.
- What other files call or read it.
- What future real-organ transition will likely replace or extend.

## 4. Runtime or CLI behavior

Explain every command, script, module entrypoint, smoke command, and dryrun command that exists after this batch.


For each command:

```text
command here
```

Explain:
- What it reads.
- What it writes.
- Whether it is dummy/skeleton or real.
- Expected success output.
- Expected failure output.

## 5. Data contracts and artifacts

List schemas, JSON files, YAML files, generated Markdown reports, smoke outputs, logs, and status files.

For each artifact:
- Producer.
- Consumer.
- Required fields.
- Dummy fields in skeleton mode.
- Real-organ replacement expectations.

## 6. Developer walkthrough

Write a guided reading order for the code.

Example:

```text
1. Start at <entrypoint>
2. Read <schema>
3. Read <writer/runner>
4. Run <smoke command>
5. Inspect <output file>
```

## 7. Important design decisions

Explain the design choices in plain language.
Do not over-explain generic Python or shell basics.
Focus on why the implementation is shaped this way.

## 8. Safety and boundaries

Call out anything that must not happen:
- no config-tool edits unless explicitly scoped
- no credential reads
- no broad bootstrap
- no live Runpod launch unless explicitly guarded
- no Paperclip live write unless explicitly guarded
- no vault overwrite
- no empty or partial content inside the nost recent codebase anylysis file (workspace_**_code_analysis_output.txt)
- no empty files, call it out.

## 9. Gaps, TODOs, and transition hooks

List:
- incomplete SPEC items
- TODOs left by Codex
- places where dummy code should later become real code
- open questions for Runpod, Agentfield, Paperclip, OpenClaw, or science modules

## 10. Postcheck summary

Summarize the filled postlog/postcheck:
- Changed files
- Tests run
- Results
- Known failures
- Next recommended batch

## 11. Integration request summary

If `INTEGRATION_REQUEST.md` exists, summarize:
- What later config/platform exposure is requested
- Suggested integration type
- Commands, artifacts, schemas, or health checks to preserve
- Safety boundaries and open questions

Do not decide final config step names here.
Do not modify config.
```

---

## Batch companion folders

Use these exact folder slugs:

```text
skeleton/01-runtime-substrate
skeleton/02-research-workspace
skeleton/03-ai-engineer-workspaces
skeleton/04-pkm-skeleton
skeleton/05-publisher-latex
skeleton/06-nca-art-base
skeleton/07-dummy-science-organs
skeleton/08-mechanism-reporting
skeleton/09-local-smoke
skeleton/10-search-templates
skeleton/11-search-scoring
skeleton/12-search-smoke
skeleton/13-runpod-dryrun
skeleton/14-openclaw-indexes
skeleton/15-openclaw-reasoners
skeleton/16-agentfield-poc
skeleton/17-agentfield-reasoners
skeleton/18-agentfield-hardening-stubs
skeleton/19-paperclip-adapter-core
skeleton/20-paperclip-review-dryrun
skeleton/21-campaign-core
skeleton/22-campaign-agents
skeleton/23-campaign-review-smoke
skeleton/24-campaign-guarded-stubs
```

---

## Companion writing rules

1. Explain the actual implementation, not the imagined implementation.
2. Use the postlog and codebase as source of truth for what changed.
3. Use INTEGRATION_REQUEST.md only as a later operator/config handoff, not as completed work.
4. Use the SPEC and master MD as source of truth for intended behavior.
4. Clearly mark gaps where the implementation differs from the intended behavior.
5. Do not invent missing functions, files, or tests.
6. Do not paste full source files.
7. Quote only short code snippets when necessary.
8. Do not write the Behavior as buletpoints, this is where most develpers will focus on. Write so developers can follow the code.
9. Prefer path-by-path explanations and reading order.
10. Keep a short overview before the deep dive.
11. Write for a future developer who wants to understand the codebase fast.

---

## Cross-batch index

In addition to each batch companion, maintain an optional index:

```text
/workspace/artifacts/companions/skeleton/INDEX.md
```

The index should contain:

```md
# Skeleton Companion Index

| Batch | Companion | Status | Last codebase source | Notes |
|---:|---|---|---|---|
| 01 | skeleton/01-runtime-substrate/COMPANION.md | complete/partial/blocked | <codebase file> | <short note> |
```

Update this index after every companion generation if the user asks for it.

---

## Config tool rule

The config tool is context, not an implementation target for these skeleton companions.

Do not tell Codex or developers to edit:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh
```

unless a dedicated future config-tool milestone explicitly says to modify it.

If an integration request exists, summarize it for the later operator/config pass. Do not turn it into config instructions inside the companion.

For skeleton implementation, project code should live under:

```text
/workspace/repos/*
/workspace/data/*
/workspace/runs/*
/workspace/artifacts/*
/workspace/models/*
/workspace/checkpoints/*
```
