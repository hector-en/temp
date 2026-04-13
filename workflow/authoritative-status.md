# Configure HQ Authoritative Status

This file is the human-facing source of truth for active development.
Agents update it during planning, QA review, coding, and increment closeout so
stakeholders can read one document instead of reconstructing state from chats,
tests, or stash history.

## Current Snapshot

- Current focus: `iscsi-tool-lab-vhdx-discovery`
- Overall status: `active`
- Last reviewed: `2026-04-10`
- Active branch: `feat/iscsi`
- Structured backing store: `workflow/stash-memory.yaml`

## Current Increment

### iscsi-tool-lab-vhdx-discovery

- Status: `active`
- Owner: `powershell-pair-coder`
- Goal: discover safe Lab child and parent VHDX choices before any creation or iSCSI target publication work

## Hotfix Track

### bugfix

- Status: `merged`
- Head checkpoint: `3758619`
- Base checkpoint: `daf202d`
- Goal: harden HQ-local identity restore when `LocalAccounts` cmdlets cannot see or manage existing local SAM principals on the guest

### Current Progress

- Active development lives under `app/`
- Increment 3 is complete and tagged as `configure-hq-increment-3`
- Increment 4 now has real code and tests for:
  - managed role ACL definitions and NTFS ACL orchestration helpers
  - required HQ principal definitions for mirrored users, ACL groups, and `HQ\svc_lab`
  - guest-side principal state export and wrapper entrypoint via `-ExportSecurityPrincipalState`
  - create-or-detect handling for missing required HQ users and groups
  - required group membership handling for existing HQ users
  - optional identity restore during activation via `-RunIdentityRestore`
  - ACL application inside activation after the final workflow rows are built
  - saved-state cleanup planning for added group links and principals
  - explicit identity cleanup via `-RunIdentityCleanup`, including link removal, planned-removal review, and confirmed user and group deletion in one pass
  - comment-first cleanup so intent comments sit on the exact code and tests they describe
- The Hyper-V host `P50` is not joined to `HQ`, so ACL and SMB policy must be authored in terms of HQ-local principals rather than `P50\...` identities
- WSL2 access from `P50` is expected to arrive through an SMB session authenticated with HQ-local credentials
- Latest increment-4 checkpoint is commit `daf202d` tagged as `configure-hq-increment-4`
- The merged bugfix track on `dev` includes refreshed post-activation drive-letter discovery, stricter stale-ADSI cleanup planning, tolerant duplicate-create handling for hidden existing principals, and restore-time hidden-local-SAM verification
- Guest reruns and the finished SMB closeout established a clean handoff into a separate iSCSI tool boundary
- A new design-only iSCSI note now defines how an optional block publication mode would work for a writable child VHDX while keeping the parent VHDX read-only
- A dedicated iSCSI test file now exists at `app/tests/configure_hq.iscsi.Tests.ps1`
- `code_full_summary.txt` now shows `Get-HqLabVhdDiscoveryChoices` implemented and returning both child and parent choice sets with `CreateNew` defaults plus discovered `UseExisting` VHDX entries
- A follow-up fix is captured in `patches/iscsi-discovery-fix.patch` to preserve choice object creation while removing the premature sort stage
- The current safe checkpoint is therefore no longer the original missing-function red boundary; it is an implementation-present, verification-pending boundary
- The current discovery slice remains limited to:
  - existing child VHDX candidates under `\\10.100.0.10\lab\virtual hdds frontends`
  - existing parent VHDX candidates under `\\10.100.0.10\lab\virtual hdds`
  - a default create-new option for both child and parent choice sets
- This slice still does not create folders, create VHDX files, or publish iSCSI targets
- Historical SMB and increment-2 checkpoints remain available for lineage and rollback analysis

### QA Reading

- Tags: `needs-observation`, `hypothesis`, `risk-identified`
- Commentary: the discovery helper is present in the summarized codebase, and a small follow-up patch already adjusts its enumeration pipeline. The remaining uncertainty is no longer missing implementation; it is whether the latest helper and test file are green together on the real tree.
- Next steps:
  - run the dedicated iSCSI Pester file against the current branch state
  - confirm `Get-HqLabVhdDiscoveryChoices` still returns the expected create-new defaults and discovered VHDX entries after the fix patch
  - keep the next green slice limited to discovery validation or a dedicated execution switch, not target publication
- Quality risks:
  - real share enumeration may expose folder-layout or naming variations beyond the first discovery test
  - the Windows iSCSI target support boundary for publishing a differencing child disk is still unverified
  - operator selection is not yet implemented; only discovery output is defined

### Blockers

- no blocker prevents the discovery helper itself
- the iSCSI publication path is intentionally split into a separate upcoming tool and still needs its own implementation plan
- the later iSCSI publication path still depends on validating the Windows differencing-disk support boundary

### Open Questions

- Resolved: use `V:\VHDs\disks\sharedisk.vhdx` as the `ShareDrive` VHD path.
- Resolved: guest activation consumes a host-generated metadata module instead of relying only on guest-visible heuristics.
- Resolved: manual VM selection replaces auto-detection as the preferred host workflow.
- Resolved: increment 3 ends at dedup execution, missing-feature handling, and execution-mode guarding.
- Resolved: increment 4 will use HQ-local groups plus `HQ\svc_lab` instead of abstract domain groups or `Everyone`.
- Resolved: WSL2 access from `P50` will be modeled through HQ-authenticated SMB sessions rather than direct `P50\...` principals.
- Open: should the next slice stop at validation of the discovery helper, or immediately add the separate execution switch once the dedicated iSCSI test file is green?

## Increment Ledger

| Increment | Status | Summary | Owner | Release Tag |
| --- | --- | --- | --- | --- |
| `increment-1` | `complete` | Disk discovery and activation implemented, tested, tagged, and merged. | `product-owner` | `configure-hq-increment-1` |
| `increment-2` | `complete` | Host can export VM inventory or selected-VM metadata; guest activation imports the selected metadata module and reports validation status. | `powershell-pair-coder` | `configure-hq-increment-2` |
| `increment-3` | `complete` | Dedup execution is wired into the guest workflow with feature checks, optional installation, and clear operator feedback. | `powershell-pair-coder` | `configure-hq-increment-3` |
| `increment-4` | `complete` | ACL helpers, HQ principal-state backup, standalone and optional identity restore, and the full `-RunIdentityCleanup` confirmation flow are implemented and tested. | `powershell-pair-coder` | `configure-hq-increment-4` |
| `increment-5` | `complete` | SMB share provisioning is complete from the managed-folder contract and has been verified on the guest after ACL setup. | `powershell-pair-coder` | |
| `iscsi-tool-lab-vhdx-discovery` | `active` | Discovery helper and dedicated test both exist in the summarized codebase; the current checkpoint is verification of the implemented helper before widening the tool. | `powershell-pair-coder` | |

## Stakeholder Feedback

- Latest feedback: when the user says `save here` or equivalent, the agent suite must record the real progress state and create a stash before ending the session.
- Latest feedback: comment-first drift should be corrected before widening the next slice.
- Latest feedback: `AGENTS.md` should bootstrap the repo workflow automatically for non-trivial work so the user does not need to keep restating it.
- Latest progress report: increment 4 now includes ACL helper code, HQ principal-state backup/export, required identity restore, and green lab-aligned tests.
- Latest progress report: identity restore now runs only when `-RunIdentityRestore` is set, and ACL application now runs inside activation after the storage work is finished.
- Latest progress report: saved principal state now produces a cleanup plan for principals that were absent before restore work ran.
- Latest progress report: saved principal state now produces a cleanup plan for both added group links and added principals.
- Latest progress report: `-RunIdentityCleanup` now executes planned group-link cleanup through the guest wrapper.
- Latest progress report: `-RunIdentityRestore` now works as a standalone guest action and prints live restore and cleanup status output.
- Latest progress report: `-RunIdentityCleanup` now keeps the whole flow in one command by showing planned removals and asking for confirmed user and group deletion after link cleanup.
- Latest progress report: increment 4 is closed out at commit `daf202d` and tagged as `configure-hq-increment-4`.
- Latest progress report: branch `bugfix` now carries commit `94316ef` to harden local HQ identity restore against hidden local SAM principals that `LocalAccounts` cmdlets do not surface reliably.
- Latest progress report: the current `bugfix` working slice hardens `-RunIdentityCleanup` so already-missing local users and groups are treated as already removed when Windows returns a direct `...was not found` delete error.
- Latest progress report: guest reruns confirmed that `-RunIdentityCleanup` no longer repeats phantom group removals, and the current working slice adds the remaining restore fixes for refreshed drive letters, hidden-principal duplicate creates, and restore-time hidden-local-SAM verification.
- Latest progress report: `bugfix` has been merged into `dev` through merge commit `b2b64d1`.
- Latest progress report: increment 5 has resumed with SMB share provisioning after ACL setup, and `app/tests/configure_hq.Tests.ps1` is green with 79 passing tests.
- Latest progress report: commit `5e6fb94` saves the legacy SMB publication alignment, the repo-bootstrap move into `AGENTS.md`, and the `configure_hq` doc move into `app/docs`.
- Latest progress report: the code summary now shows the iSCSI discovery helper implemented, with a follow-up helper fix recorded in `patches/iscsi-discovery-fix.patch`; the remaining work is live verification on the current tree.
