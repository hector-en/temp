# infra-skeleton-tools / infractl real-v0

Public reusable deterministic CLI engine. It contains no private project specs, prompts, annexes, evidence, or batch maps.

## Public/private split

- Public: this repository/folder (`infra-skeleton-tools_real_v0`) with `infractl/`, `templates/`, `schemas/`, and public examples.
- Private: a separate project bundle such as `agentfield-grn-private_real_v0/` with `project.yaml`, `layers.yaml`, `batches.yaml`, `hooks.yaml`, `files.yaml`, `sources/`, `evidence_snapshots/`, and `generated/`.

## Profiles

- `webchat-sandbox`: ChatGPT container artifact generation only.
- `cli-dry-run`: local preview only.
- `codex-pack`: package already-created ChatGPT outputs.
- `workspace`: deterministic checks/request generation in the real workspace; still does not mutate `/workspace` by itself.

## Example

```bash
cd infra-skeleton-tools_real_v0
python -m infractl.cli list-batches --project ../agentfield-grn-private_real_v0
python -m infractl.cli request-update --project ../agentfield-grn-private_real_v0 --track skeleton --batch 01 --topic workflow_smoke_automation --profile webchat-sandbox --out /mnt/data/generated_real_v0
```
