# Ledger Schema

Use `workflow/stash-memory.yaml` as the durable process memory.

## Top-Level Keys

- `schema_version`
- `project`
- `global`
- `qa_state_catalog`
- `increments`
- `stash_entries`

## Global

- `current_focus`
- `overall_status`
- `last_reviewed`
- `stakeholder_feedback`

## Increments

Each increment entry should capture:
- `id`
- `status`
- `summary`
- `owner`
- `tag`
- `qa_tags`
- `qa_commentary`
- `qa_next_steps`
- `quality_risks`
- `blockers`
- `open_questions`

## Stash Entries

Each stash entry should capture:
- `timestamp`
- `increment`
- `status`
- `stash_ref`
- `message`
- `notes`

Helpful optional stash entry fields:
- `focus_refs`
- `qa_tags_snapshot`
- `blockers_snapshot`
- `next_step`
