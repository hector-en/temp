# CLI_EXTRACTION_NOTES.md

Purpose: collect repeated manual steps from the Infra-Skeleton new-chat workflow so they can later be converted into a reusable CLI (`infractl`) around Batch 04/05.

Use this file after each manual batch-creation, batch-update, hook/annex, smoke, or evidence workflow. Do not over-design yet. Only record patterns that actually happened.

## Extraction rule

```text
Seen once  -> keep as markdown/manual note.
Seen twice -> mark as candidate template.
Seen three times -> move into CLI/template/schema.
```

## What should become CLI later

CLI candidates are steps that are:

```text
repeated
predictable
path-based
filename-based
registry-based
validation-based
template-fillable
safe to automate without interpretation
```

Examples:

```text
checking required files
resolving batch slugs
creating output folders
updating hook registries
creating batch/update request files
checking evidence paths
summarizing smoke status
packaging generated Codex files
```

## What should stay LLM-assisted

Keep LLM involvement for steps that require interpretation:

```text
classifying messy background notes
resolving contradictory specs
writing human-readable SPEC/ANX prose
deciding batch/layer placement for ambiguous content
summarizing research context
creating nuanced Codex instructions
```

---

# Batch / workflow extraction log

## Entry template

Copy this section after each manual workflow.

```markdown
## <DATE> — <WORKFLOW_TYPE> — <BATCH_OR_TOPIC>

### Context

Track:
Batch / slug:
Mode: creation | update | hook-annex | smoke | evidence | companion | other
Topic:

### Files uploaded / read

Required files:
- 

Optional files:
- 

Missing or inaccessible files:
- none

### Repeated boilerplate

Things I had to say, paste, check, or edit manually again:
- 

### Manual filename/path edits

Paths, slugs, dates, batch numbers, or filenames that were predictable:
- 

### Hook / annex decisions

Which hooks applied?
- 

Which deep annexes were requested?
- 

Was the decision obvious or did it require reasoning?
- 

### Evidence and smoke checks

Evidence paths checked or created:
- 

Smoke command / phase:
- 

Smoke report path:
- 

Status: PASS | SKIP | WARN accepted | FAIL | unknown

### Mistakes or friction

What was confusing, duplicated, or error-prone?
- 

### Candidate YAML fields

Data that could become `project.yaml`, `layers.yaml`, `batches.yaml`, or `hooks.yaml`:
- 

### Candidate templates

Text blocks or file structures that could become templates:
- 

### Candidate CLI commands

Possible future commands:
- infractl 

### Do not automate yet

Parts that still feel unstable or require judgment:
- 

### CLI extraction verdict

Classify this pattern:
- seen once
- seen twice
- seen three times / ready for CLI
```

---

# Running CLI candidate list

Use this section to accumulate likely `infractl` commands.

```text
infractl list-batches
infractl explain-batch --track skeleton --batch <N>
infractl check-required-files --mode batch-creation --batch <N>
infractl check-required-files --mode batch-update --batch <N> --topic <topic>
infractl create-batch-request --track skeleton --batch <N>
infractl update-batch-request --track skeleton --batch <N> --topic <topic>
infractl check-evidence --track skeleton --batch <N>
infractl smoke-command --track skeleton --batch <N>
infractl status
```

---

# Data model candidates

## project.yaml candidates

```yaml
project:
  id:
  name:
  workspace_root: /workspace

paths:
  skeleton_evidence_root: /mnt/egress/dev-recordings/skeleton
  organ_evidence_root: /mnt/egress/organs/dev-recordings/organs
  skeleton_companion_root: /mnt/ingress/infra/skeleton/companion
  organ_companion_root: /mnt/ingress/infra/organs/companion
  smoke_root: /workspace/runs/smoke
  smoke_runner_current: /workspace/scripts/smoke.sh
  smoke_runner_canonical: /workspace/scripts/smoke_current_state.sh
```

## batches.yaml candidates

```yaml
batches:
  - id:
    track:
    slug:
    layer:
    scope:
    smoke_phase:
    smoke_domains: []
    required_evidence:
      - POSTCHECK.md
      - INTEGRATION_REQUEST.md
      - SMOKE_REPORT.md
```

## hooks.yaml candidates

```yaml
hooks:
  - id:
    number:
    creation_hook:
    update_hook:
    deep_annex:
    applies_to:
      skeleton:
        required: []
        recommended: []
      organs:
        required: []
        recommended: []
```

---

# Stabilization checklist before building `infractl`

Do not start CLI implementation until most of these are stable:

```text
batch pack format
update pack format
required evidence files
evidence roots
update evidence roots
hook naming convention
annex naming convention
creation vs update behavior
skeleton vs organ behavior
smoke phase names
smoke runner compatibility rule
missing-file stop behavior
registry update behavior
```
