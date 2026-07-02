# public_infra-skeleton-tools_v0

Public reusable deterministic CLI engine for the Infra-Skeleton workflow.

This folder is public-safe. It contains the `infractl` command implementation, lightweight schemas, public examples, and starter workflow prompts. It must not contain private project SPECs, annexes, hooks, evidence, generated batch packs, or codebase snapshots.

## Public/private split

Public repo folder:

```text
public_infra-skeleton-tools_v0/
  infractl/
    cli.py
    project.py
    render.py
    pack.py
    evidence.py
    profiles.py
  schemas/
  templates/
  examples/
  README.md
  instructions.md
  NEW_CHAT_PROMPT_update_infra.md
```

Private bundle, uploaded separately in ChatGPT or stored outside the public repo:

```text
agentfield-grn-private_real_v0/
  project.yaml
  layers.yaml
  batches.yaml
  hooks.yaml
  files.yaml
  sources/
  evidence_snapshots/
  generated/
```

Never push the private bundle to this public repo.

## Profiles

```text
webchat-sandbox  # ChatGPT container artifact generation only
cli-dry-run      # local preview only
codex-pack       # package ChatGPT-produced Codex pack files
workspace        # deterministic checks/request generation against a real workspace
```

## Fresh ChatGPT start

Use this starter line in a new chat:

```text
Read the public infractl tool from https://github.com/hector-en/temp/tree/main/public_infra-skeleton-tools_v0, then ask me for my private agentfield-grn-private_real_v0 bundle zip, validate both, and start the workflow in webchat-sandbox mode without treating extra sources as authoritative until routed through EXTRA_SOURCE_ROUTING.md.
```

## Webchat sandbox example

After the private bundle is uploaded/unpacked to `/mnt/data/agentfield-grn-private_real_v0`:

```bash
cd /mnt/data/public_infra-skeleton-tools_v0

python -m infractl.cli profiles

python -m infractl.cli list-batches \
  --project /mnt/data/agentfield-grn-private_real_v0

python -m infractl.cli check-required-files \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --track skeleton

python -m infractl.cli request-update \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --track skeleton \
  --batch 01 \
  --topic workflow_smoke_automation \
  --profile webchat-sandbox \
  --out /mnt/data/generated_real_v0
```

## Real workspace validation

In your real workspace, your private infra planning/control tree lives at:

```text
/mnt/ingress/infra
```

Therefore `--repo-root` should be the parent folder:

```bash
cd /workspace/repos/public_infra-skeleton-tools_v0

python -m infractl.cli validate-real-layout \
  --project /workspace/private/agentfield-grn-private_real_v0 \
  --repo-root /mnt/ingress
```

This is the real workspace preflight gate. If any `required: true` source in `files.yaml` is missing from the real tree under `--repo-root`, `validate-real-layout` exits non-zero with `MISSING_REQUIRED_REAL_PATHS`.

Inside ChatGPT/webchat only, where `/mnt/ingress/infra` is not mounted, use bundle fallback validation instead:

```bash
python -m infractl.cli validate-real-layout \
  --project /mnt/data/agentfield-grn-private_real_v0 \
  --repo-root /mnt/data/agentfield-grn-private_real_v0 \
  --allow-bundle-fallback
```

Do not use `/workspace/repos/public_infra-skeleton-tools_v0` as `--repo-root`; that is the public CLI folder, not the private infra tree.

## Scope of v0

- Skeleton-active up to Batch 04.
- Organ-aware for R01 scaffold only.
- Deterministic only: no OpenAI API calls, no Codex execution, no smoke execution, no `/workspace` mutation, no `/mnt/egress` mutation.
- Keep `CLI_EXTRACTION_NOTES.md` active until after Batch 04.

## Infra/tool update line

For future public/private v1/v2 updates, use:

```text
NEW_CHAT_PROMPT_update_infra.md
```

It tells ChatGPT to start from this public repo, ask for the private bundle and latest private codebase analysis, produce a delta plan first, and only generate updated public/private artifacts after confirmation.
