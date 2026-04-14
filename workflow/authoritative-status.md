# Configure HQ Authoritative Status

This file is the human-facing source of truth for active development.
Agents update it during planning, QA review, coding, and increment closeout so
stakeholders can read one document instead of reconstructing state from chats,
tests, or stash history.

## Current Snapshot

- Current focus: `iscsi-tool-lab-vhdx-operator-selection`
- Overall status: `active`
- Last reviewed: `2026-04-13`
- Active branch: `feat/iscsi`
- Structured backing store: `workflow/stash-memory.yaml`

## Current Increment

### iscsi-tool-lab-vhdx-operator-selection

- Status: `active`
- Owner: `powershell-pair-coder`
- Goal: let the operator choose a discovered Lab child and parent VHDX entry, while keeping creation and iSCSI publication out of scope

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
- `Get-HqLabVhdDiscoveryChoices` is implemented and returns both child and parent choice sets with `CreateNew` defaults plus discovered `UseExisting` VHDX entries
- `configure_hq.ps1` already exposes the standalone discovery entrypoint through `[switch]$DiscoverLabVhdChoices`
- The dedicated iSCSI Pester file now has discovery green and operator selection red, with the remaining failure being the missing `ParentChoice` property on the returned selection object
- The discovery increment is therefore complete at the verified helper-and-switch boundary
- The next active slice is now limited to:
  - mapping discovered child and parent choice rows into an operator-facing selection flow
  - preserving the existing create-new placeholders without creating folders or VHDX files yet
  - returning the selected choice objects cleanly for a later execution or publication step
- Running the Windows-local script as `P50\labuser` now successfully enumerates the Lab child and parent VHDX shares after moving the discovery entry block below the function definitions and main invocation block
- This next slice still does not create folders, create VHDX files, or publish iSCSI targets
- Historical SMB and increment-2 checkpoints remain available for lineage and rollback analysis

### QA Reading

- Tags: `ready-for-green`, `needs-observation`, `risk-identified`
- Commentary: the discovery helper and standalone discovery switch are verified on the real tree, and the Windows-local script now works as `P50\labuser` once the discovery entrypoint runs after the function definitions. The remaining green fix is to return the missing `ParentChoice` property from `Resolve-HqLabVhdOperatorSelection`.
- Next steps:
  - add the missing `ParentChoice` property to `Resolve-HqLabVhdOperatorSelection`
  - preserve the reordered script entry flow so discovery runs after function definitions are loaded
  - preserve `-DiscoverLabVhdChoices` as the non-destructive inspection path
- Quality risks:
  - real share enumeration may expose folder-layout or naming variations beyond the first discovery test
  - the Windows iSCSI target support boundary for publishing a differencing child disk is still unverified
  - selection UX may drift into creation or publication logic unless the slice boundary stays explicit

### Blockers

- no blocker prevents the operator-selection slice itself
- the iSCSI publication path is intentionally split into a separate upcoming tool and still needs its own implementation plan
- the later iSCSI publication path still depends on validating the Windows differencing-disk support boundary

### Open Questions

- Resolved: use `V:\VHDs\disks\sharedisk.vhdx` as the `ShareDrive` VHD path.
- Resolved: guest activation consumes a host-generated metadata module instead of relying only on guest-visible heuristics.
- Resolved: manual VM selection replaces auto-detection as the preferred host workflow.
- Resolved: increment 3 ends at dedup execution, missing-feature handling, and execution-mode guarding.
- Resolved: increment 4 will use HQ-local groups plus `HQ\svc_lab` instead of abstract domain groups or `Everyone`.
- Resolved: WSL2 access from `P50` will be modeled through HQ-authenticated SMB sessions rather than direct `P50\...` principals.
- Resolved: the standalone discovery switch already exists as `-DiscoverLabVhdChoices`.
- Open: should operator selection use index-based choice input, path-based choice input, or support both in the first slice?

## Increment Ledger

| Increment | Status | Summary | Owner | Release Tag |
| --- | --- | --- | --- | --- |
| `increment-1` | `complete` | Disk discovery and activation implemented, tested, tagged, and merged. | `product-owner` | `configure-hq-increment-1` |
| `increment-2` | `complete` | Host can export VM inventory or selected-VM metadata; guest activation imports the selected metadata module and reports validation status. | `powershell-pair-coder` | `configure-hq-increment-2` |
| `increment-3` | `complete` | Dedup execution is wired into the guest workflow with feature checks, optional installation, and clear operator feedback. | `powershell-pair-coder` | `configure-hq-increment-3` |
| `increment-4` | `complete` | ACL helpers, HQ principal-state backup, standalone and optional identity restore, and the full `-RunIdentityCleanup` confirmation flow are implemented and tested. | `powershell-pair-coder` | `configure-hq-increment-4` |
| `increment-5` | `complete` | SMB share provisioning is complete from the managed-folder contract and has been verified on the guest after ACL setup. | `powershell-pair-coder` | |
| `iscsi-tool-lab-vhdx-discovery` | `complete` | Discovery helper is implemented, the standalone discovery switch exists, and the dedicated iSCSI test is green on the current tree. | `powershell-pair-coder` | |
| `iscsi-tool-lab-vhdx-operator-selection` | `active` | Next slice starts at selecting discovered child and parent VHDX choices without widening into create or publication behavior. | `powershell-pair-coder` | |

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
- Latest progress report: the code summary shows the iSCSI discovery helper implemented, with a follow-up helper fix recorded in `patches/iscsi-discovery-fix.patch`.
- Latest progress report: `Invoke-Pester .\app\tests\configure_hq.iscsi.Tests.ps1` is green with `Passed: 1 Failed: 0`, so the discovery increment is complete at the verified helper boundary.
- Latest progress report: the standalone discovery entrypoint already exists as `[switch]$DiscoverLabVhdChoices`, so the next slice has shifted to operator selection.
- Latest progress report: running the Windows-local script as `P50\labuser` now enumerates both Lab child and parent VHDX shares successfully after moving the discovery entry block below the function definitions and main invocation block.
- Latest progress report: the current operator-selection red-to-green boundary is the missing `ParentChoice` property on the object returned by `Resolve-HqLabVhdOperatorSelection`.
