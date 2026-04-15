# Configure HQ Authoritative Status

This file is the human-facing source of truth for active development.
Agents update it during planning, QA review, coding, and increment closeout so
stakeholders can read one document instead of reconstructing state from chats,
tests, or stash history.

## Current Snapshot

- Current focus: `iscsi-parent-chain-discovery`
- Overall status: `active`
- Last reviewed: `2026-04-15`
- Active branch: `fix/child-parent-chain-dicovery`
- Structured backing store: `workflow/stash-memory.yaml`

## Current Increment

### iscsi-parent-chain-discovery

- Status: `active`
- Owner: `powershell-pair-coder`
- Goal: discover Lab child VHDX entries first and show each existing child's Hyper-V-style parent chain, while deferring parent selection until the later new-child creation slice

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
- `Get-HqLabVhdDiscoveryChoices` is implemented and now returns child choices with `CreateNew` plus discovered `UseExisting` VHDX entries, while attaching best-effort parent-chain context per existing child row
- `configure_hq.ps1` already exposes the standalone discovery entrypoint through `[switch]$DiscoverLabVhdChoices`
- The previous operator-selection direction is now superseded because the current iSCSI publication step should select only an existing child VHDX or create a new child, while flat parent enumeration also does not match Hyper-V differencing-disk lineage
- The next active bugfix slice is now limited to:
  - discovering child VHDX candidates first
  - following each existing child disk's linked parent path step by step
  - continuing each walk until the final main parent is reached
  - showing the resolved parent chain as context for each child choice
  - keeping parent selection out of this slice unless a later new-child creation flow needs it
  - returning lineage-aware child-first discovery data without creating folders, creating VHDX files, or publishing iSCSI targets yet
- Live execution now shows child-only discovery output correctly, while parent-chain inspection currently falls back to `ParentChainStatus = Unavailable` for `P50\labuser` when `Get-VHD` cannot inspect lineage under the current permissions
- Historical SMB and increment-2 checkpoints remain available for lineage and rollback analysis

### QA Reading

- Tags: `needs-observation`, `risk-identified`, `test-gap`
- Commentary: the current discovery helper now exposes child-first output and attaches best-effort parent-chain state per child row, but real parent linkage is still not observable under `P50\labuser` because `Get-VHD` inspection currently falls back to `ParentChainStatus = Unavailable`. The next slice should preserve the child-first contract while making the blocked lineage inspection state explicit and testable.
- Next steps:
  - record the current blocked lineage-inspection behavior in tests and workflow state
  - capture or surface the actual per-child inspection error when parent-chain lookup is unavailable
  - keep creation and iSCSI publication out of scope while the discovery contract is corrected
- Quality risks:
  - share enumeration alone may confuse unrelated parent VHDX files with the true parent lineage of a selected child
  - parent lookup may require reading VHD metadata rather than inferring lineage from folder layout alone
  - the discovery output may become noisy unless parent-chain context stays attached to child choices rather than reviving a flat parent-choice list

### Blockers

- no blocker prevents the parent-chain discovery bugfix itself
- the iSCSI publication path is intentionally split into a separate upcoming tool and still needs its own implementation plan
- the exact metadata source for reading a child VHDX parent link still needs validation in the Windows host environment

### Open Questions

- Resolved: use `V:\VHDs\disks\sharedisk.vhdx` as the `ShareDrive` VHD path.
- Resolved: guest activation consumes a host-generated metadata module instead of relying only on guest-visible heuristics.
- Resolved: manual VM selection replaces auto-detection as the preferred host workflow.
- Resolved: increment 3 ends at dedup execution, missing-feature handling, and execution-mode guarding.
- Resolved: increment 4 will use HQ-local groups plus `HQ\svc_lab` instead of abstract domain groups or `Everyone`.
- Resolved: WSL2 access from `P50` will be modeled through HQ-authenticated SMB sessions rather than direct `P50\...` principals.
- Resolved: the standalone discovery switch already exists as `-DiscoverLabVhdChoices`.
- Open: should parent-chain discovery read the parent link through Hyper-V/VHD metadata commands directly, or through another local inspection method when Hyper-V cmdlets are unavailable?
- Open: should the child-first output show the full parent-chain path list inline on each choice row, or summarize it there and print the detailed chain below?

## Increment Ledger

| Increment | Status | Summary | Owner | Release Tag |
| --- | --- | --- | --- | --- |
| `increment-1` | `complete` | Disk discovery and activation implemented, tested, tagged, and merged. | `product-owner` | `configure-hq-increment-1` |
| `increment-2` | `complete` | Host can export VM inventory or selected-VM metadata; guest activation imports the selected metadata module and reports validation status. | `powershell-pair-coder` | `configure-hq-increment-2` |
| `increment-3` | `complete` | Dedup execution is wired into the guest workflow with feature checks, optional installation, and clear operator feedback. | `powershell-pair-coder` | `configure-hq-increment-3` |
| `increment-4` | `complete` | ACL helpers, HQ principal-state backup, standalone and optional identity restore, and the full `-RunIdentityCleanup` confirmation flow are implemented and tested. | `powershell-pair-coder` | `configure-hq-increment-4` |
| `increment-5` | `complete` | SMB share provisioning is complete from the managed-folder contract and has been verified on the guest after ACL setup. | `powershell-pair-coder` | |
| `iscsi-tool-lab-vhdx-discovery` | `complete` | Discovery helper is implemented, the standalone discovery switch exists, and the dedicated iSCSI test is green on the current tree. | `powershell-pair-coder` | |
| `iscsi-tool-lab-vhdx-operator-selection` | `superseded` | Flat discovery and early operator-selection work exposed that parent discovery must follow the selected child disk's actual lineage before selection flow can be finalized. | `powershell-pair-coder` | |
| `iscsi-parent-chain-discovery` | `active` | Child-first discovery should attach each existing child VHDX to its resolved parent chain and defer parent selection until the later new-child creation flow. | `powershell-pair-coder` | |

## Stakeholder Feedback

- Latest feedback: when the user says `save here` or equivalent, the agent suite must record the real progress state and create a stash before ending the session.
- Latest feedback: comment-first drift should be corrected before widening the next slice.
- Latest feedback: `AGENTS.md` should bootstrap the repo workflow automatically for non-trivial work so the user does not need to keep restating it.
- Latest feedback: Lab VHDX discovery should follow each existing child disk's real parent chain instead of treating all parent VHDX files as flat candidates.
- Latest feedback: the current iSCSI disk-selection step should select only an existing child VHDX or create a new child; parent selection belongs to the later new-child creation flow.
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
- Latest progress report: the standalone discovery entrypoint already exists as `[switch]$DiscoverLabVhdChoices`.
- Latest progress report: live child-only discovery output now works, but `Get-VHD` lineage inspection currently returns `ParentChainStatus = Unavailable` for `P50\labuser` under the present permissions.
- Latest progress report: the previous operator-selection direction is now superseded until child-first lineage-aware discovery is corrected first and parent selection is deferred to the later new-child creation flow.
