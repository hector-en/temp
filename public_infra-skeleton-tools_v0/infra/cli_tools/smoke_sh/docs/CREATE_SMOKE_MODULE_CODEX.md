# CREATE_SMOKE_MODULE_CODEX.md — Create or Extend a Dynamic Smoke Module

Use this file as the short, cache-stable Codex instruction when a completed skeleton, organ, platform, infra, or config batch needs a new smoke module.

This file is ChatGPT/operator-authored. Codex may read it. Codex must not overwrite it.

Pair it with:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
```

## Purpose

Create or update exactly one safe dynamic smoke module under:

```text
/workspace/tests/smoke.d/<NN-domain>.smoke.sh
```

The module must be discovered and run by:

```text
/workspace/scripts/smoke_current_state.sh
```

The module must be safe, idempotent, local-first, phase-aware, and evidence-aware.

## Required read-only inputs

Codex must read these if present:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/
```

Codex must also read the batch-specific evidence for the current work:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
```

or:

```text
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

If this is a config/operator integration batch, Codex must read the provided integration manifest or config batch SPEC/RUN_INSTRUCTIONS instead of guessing.

## Stop conditions

Stop and report exact missing files if any required input is missing:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/scripts/smoke_current_state.sh
```

Stop if the requested smoke module would require any forbidden action:

```text
terraform apply
kubectl apply
helm install
helm upgrade
docker run with external side effects
RunPod pod creation
live organ execution
live model/provider spending
credential printing
config mutation
vault overwrite
Paperclip production write
```

## Task scope

Implement only one smoke module per Codex run.

Do not refactor the orchestrator unless the user explicitly requested an orchestrator repair task.

Do not create ChatGPT/operator docs.

Do not create or edit:

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
```

## Module naming

Use one of these naming patterns:

```text
00-core.smoke.sh
10-skeleton.smoke.sh
20-organs.smoke.sh
30-config.smoke.sh
40-kubernetes.smoke.sh
50-terraform.smoke.sh
60-agentfield.smoke.sh
70-runpod.smoke.sh
80-grn.smoke.sh
90-custom-<domain>.smoke.sh
```

If a module already exists for the domain, update it instead of creating a duplicate.

## Required module interface

The module must support:

```bash
bash /workspace/tests/smoke.d/<module>.smoke.sh detect
bash /workspace/tests/smoke.d/<module>.smoke.sh run <phase> <report_dir>
bash /workspace/tests/smoke.d/<module>.smoke.sh describe
bash /workspace/tests/smoke.d/<module>.smoke.sh list-files
```

Minimum required commands are `detect` and `run`.

Recommended commands are `describe` and `list-files`.

## Exit code contract

```text
0  = PASS
10 = SKIP
20 = WARN
30 = FAIL
40 = BLOCKED
```

The module must print one final result line:

```text
SMOKE_RESULT status=<PASS|SKIP|WARN|FAIL|BLOCKED> module=<module-name> message="<short reason>"
```

## Detect behavior

`detect` must decide whether the domain exists.

Examples:

```text
Kubernetes: k8s/, charts/, Helm chart, Kubernetes YAML, kubectl-related files
Terraform: *.tf files or terraform/ folder
AgentField: agentfield package, agentfield_grn repo, AgentField configs/fixtures
RunPod: runpod templates, runpod target config, pod manifest generator
GRN: nca_art_grn package, GRN DSL/simulator modules, mechanism report contract
Skeleton: /mnt/egress/dev-recordings/skeleton or skeleton project package
Organs: /mnt/egress/organs/dev-recordings/organs or organ-specific modules
Config: /home/vmuser/.local/bin/config.sh or config integration evidence
```

If the domain is absent, exit `10` and do not fail the whole smoke run.

## Run behavior

`run <phase> <report_dir>` must perform safe local checks only.

Allowed examples:

```text
file existence checks
schema parse checks
Python import checks
small deterministic local dry-run
terraform fmt -check
terraform validate only where already initialized
kubectl --dry-run=client
helm template
JSON/YAML parse
CLI --help
non-live status command
```

Forbidden examples:

```text
terraform apply
kubectl apply
helm install/upgrade
live RunPod launch
live organ run
broad bootstrap
package install unless this smoke module is explicitly an installer smoke and user requested it
credential read/print
config/lv/workflow mutation
```

## Phase awareness

The module must treat phases differently when appropriate:

```text
skeleton-progress
skeleton-complete
organ-progress
organ-complete
pre-config
post-config
current-state
```

Examples:

```text
Before organs exist, an organ module should SKIP or WARN, not FAIL.
Before config integration, a config module should check evidence and manifests, not require final aliases.
After config integration, a config module may check non-live smoke command resolution.
```

## Required output behavior

The module may write only inside the supplied report directory or under `/workspace/runs/smoke/...`.

The module must not delete older smoke reports.

The module should write any detailed generated check output under:

```text
<report_dir>/raw/
```

or a module subfolder under:

```text
<report_dir>/<module-name>/
```

## Validation commands

After creating or updating the module, run syntax checks:

```bash
bash --noprofile --norc -n /workspace/tests/smoke.d/<module>.smoke.sh
bash --noprofile --norc /workspace/tests/smoke.d/<module>.smoke.sh detect
```

Then run the orchestrator for the requested phase:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh <phase>
```

If there is no batch slug for this smoke module, run:

```bash
bash /workspace/scripts/smoke_current_state.sh current-state
```

## Evidence update

If the current batch has a POSTCHECK file, append or update:

```text
Smoke module path:
Smoke phase:
Smoke command:
Smoke report path:
Smoke status:
Forbidden actions preserved:
```

If the current batch has an INTEGRATION_REQUEST.md, include or update:

```text
Smoke module path:
Safe command:
Expected output:
Forbidden actions:
Config integration needed: yes/no
```

Do not invent missing evidence.

## Response format

End with:

```text
Changed files:
- ...

Tests run:
- ...

Smoke report:
- ...

Notes:
- ...
```
