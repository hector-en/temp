# InfraCTL Exhaustive Workflow-State Audit Prompt

Use the uploaded public InfraCTL files and private project bundle to determine the current workflow position.

## Task

Perform a **read-only, exhaustive workflow-state audit** of the uploaded private bundle and report where the project currently stands.

Do not execute a route, create files, mutate evidence, or recommend the next phase until the current state has been verified from the complete archive.

## Inputs

```text
infractl.md
infractl.zip
<selected private project bundle>
```

Treat the explicitly selected private bundle as authoritative. If multiple private bundles are uploaded, identify each candidate and stop until one authoritative bundle is selected. Do not silently choose based only on filename recency.

## Required read order

1. Read `infractl.md`.
2. Inspect the public `infractl.zip` structure.
3. Read:

   ```text
   dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
   ```

4. Inspect the private bundle's complete archive tree before drawing conclusions.
5. Read the private registries, where present:

   ```text
   project.yaml
   batches.yaml
   files.yaml
   hooks.yaml
   layers.yaml
   ```

6. Read all phase, evidence, decision, and closeout artifacts relevant to the latest active or completed route.

## Mandatory anti-omission protocol

Before stating that a phase has not run, an artifact is missing, or a route remains open, perform all of the following.

### A. Full archive inventory

List or search the entire private archive recursively. Do not inspect only registry-listed paths or expected directories.

Search directory names and filenames case-insensitively for:

```text
p1
p2
p3
p4
p5
p6
phase
closeout
decision
next_cycle
next-cycle
g17
postcheck
evidence
smoke
snapshot
export
accepted
complete
completed
closed
warn
pass
stop
```

Account for spelling variants, underscores, hyphens, capitalization, and nested locations.

Examples that must be detected include:

```text
p6_closeout/
P6_BATCH05_UPDATE_CLOSEOUT.md
next-cycle/
phase_decision.md
G17_DECISION.md
```

### B. Content search

Search file contents for status markers, including:

```text
P6_RESULT
PASS
WARN
WARN-ACCEPTED
STOP
CLOSED
BATCH_UPDATE_CLOSED
NEXT_ROUTE
WORKFLOW_DIRECTION
G17
```

Do not rely solely on filenames.

### C. Registry-versus-artifact reconciliation

Compare:

```text
registry state
directory tree
phase artifacts
evidence artifacts
closeout decisions
```

A registry summary is not sufficient evidence that a phase is incomplete.

When a direct phase closeout artifact conflicts with a registry or summary:

1. Report the conflict.
2. Quote or summarize the direct artifact's decisive status fields.
3. Classify the registry as current, stale, incomplete, or ambiguous.
4. Do not silently prefer the registry.

### D. Negative-claim gate

Do not state any of the following until the archive inventory and content search are complete:

```text
P6 has not run
the batch is still open
the next route is Batch 06
the closeout folder is missing
no evidence exists
the workflow is blocked
```

Use this wording when verification is incomplete:

```text
I have not yet located the artifact; this is not evidence that it is absent.
```

### E. Latest-state precedence

Determine current workflow state using this order:

1. Explicit phase closeout or next-cycle decision artifact
2. Returned execution evidence and postchecks
3. Current private registries
4. Generated request/package artifacts
5. Prior summaries or chat context

Do not infer the current state solely from what earlier phases normally require.

## Required checks

For every active or recently completed batch or organ route, identify:

```text
route mode
track
batch or organ ID
topic
highest phase with direct evidence
phase result
whether the route is formally closed
immediate next route
optional later routes
deferred work
whether snapshot/export was performed
whether registries agree with the closeout artifact
```

Specifically verify whether any `p6_closeout`, P6 decision, G17 decision, or equivalent next-cycle artifact exists before describing the route as awaiting P6.

## Output format

Return a concise report in this order:

1. **Selected authoritative public bundle**
2. **Selected authoritative private bundle**
3. **Archive scan performed**
   - key search terms used
   - relevant phase and closeout paths found
4. **Current canonical workflow state**
5. **Latest decisive artifact**
   - exact path
   - decisive status fields
6. **Registry reconciliation**
7. **Open, deferred, or optional work**
8. **Immediate next route**
9. **Confidence and unresolved ambiguity**
10. **PASS / WARN / STOP**

For every material conclusion, cite the exact source path or uploaded-file citation.

## Accuracy rules

```text
Do not invent missing states.
Do not equate "not found in the first inspected directory" with "absent."
Do not stop after reading registries.
Do not assume the normal phase sequence reveals the actual completed phase.
Do not recommend Batch 06 merely because it is registered.
Do not omit nested closeout folders.
Correct earlier assumptions explicitly when direct evidence disproves them.
```

End with a one-sentence statement distinguishing:

```text
formal current route
immediate next route
optional future routes
```
