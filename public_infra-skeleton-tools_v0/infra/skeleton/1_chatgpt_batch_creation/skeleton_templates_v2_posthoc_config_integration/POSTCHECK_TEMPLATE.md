# <BATCH_ID> postcheck
Canonical path: /mnt/egress/dev-recordings/<batch-slug>/POSTCHECK.md

Date: <YYYY-MM-DD>
Status: PASS|FAIL

## Changed files

- <path>

## Tasks executed

- Task 1 — <title>
- Task 2 — <title>

## Tests run

- `<command>`
- `<command>`

## Results

- PASS|FAIL

## Safety confirmations

- No config tool internals were edited.
- No broad bootstrap/install/mount/pull/push commands were run.
- No account mutations were run.
- No Docker builds, Kubernetes applies, Runpod jobs, OpenClaw agents, training, or inference jobs were run.
- No credentials, private notes, vault contents, datasets, API keys, or manuscript text were read or printed.
- Existing user files were not overwritten.

## Integration request

- Created: yes|no|not-needed
- Path: `/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md`
- Config integration needed: yes|no|deferred
- Config integration category: workspace-root|python-env|role-workflow|health-check|launcher|dryrun-hook|organ-transition|none
- Operator/config follow-up batch suggested: `<config-integration/NN-name>` or `none`

### Commands or capabilities to expose later

- `<command or capability name>` — `<why config/lv/workflow should expose it, or why it should stay project-only>`

### Packages or environment policy discovered

- `<package/env requirement>` — `<target role and reason>`

### Config-tool boundary confirmation

- The implementation batch did not edit config internals.
- Any future config/lv/workflow integration must be done by a separate operator-side config-integration batch after reviewing this request.

## Notes

- <notes>
