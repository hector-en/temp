# Configure HQ - iSCSI Publication Design

Related planning notes:
- Product and increment intent: `app/docs/configure_hq.increments.md`
- Current domain baseline: `app/docs/configure_hq.next.domain.md`
- Current ACL and SMB contract: `app/docs/configure_hq.acl-contract.md`

This note describes a possible design extension for `configure_hq.ps1`.
It does not replace the current SMB contract yet. Its purpose is to define a
safe block-storage publication model that we can later turn into an
implementation plan.

## Domain Language
- Parent VHDX:
  - The immutable base disk file stored on `HQ` that must never be published as
    the writable runtime disk.
- Child VHDX:
  - The differencing disk file stored on `HQ` that records the writable runtime
    changes against the parent.
- Publication Mode:
  - The storage delivery model used for one role, such as `SMB` or `iSCSI`.
- Block Publication:
  - A publication mode where `P50` receives a disk-like device rather than a
    file share.
- iSCSI Virtual Disk:
  - The disk file path that the Windows iSCSI target service exposes to an
    initiator.
- iSCSI Target:
  - The named server-side endpoint on `HQ` that grants one initiator access to
    the published disk.
- Initiator:
  - The client system that connects to the iSCSI target, in this design
    `P50`.
- Initiator IQN:
  - The initiator identifier used to allow or deny access to the iSCSI target.
- Single-Writer Session:
  - The rule that only one active client owns the writable child disk at a
    time.
- Local Attach Exclusion:
  - The rule that `HQ` does not mount the child disk locally while it is
    published through iSCSI.

## Bounded Contexts
1. Role Publication Policy
   - Responsibility:
     - Decide whether a role stays on SMB publication or opts into iSCSI
       publication.
   - Inputs:
     - Role name, source VHD path, expected drive letter, publication mode
       metadata.
   - Outputs:
     - One normalized publication definition per eligible role.

2. Child Disk Eligibility
   - Responsibility:
     - Confirm that the published disk is the writable child and not the parent
       base image.
   - Inputs:
     - Candidate VHDX path, differencing metadata, expected role.
   - Outputs:
     - A validated child-disk publication candidate or a hard failure.

3. iSCSI Target Provisioning
   - Responsibility:
     - Ensure the Windows iSCSI target service, virtual disk definition, and
       target object exist in the intended state.
   - Inputs:
     - Virtual disk path, target name, target portal policy, allowed initiator
       IQN, optional authentication reference.
   - Outputs:
     - A stable target definition that `P50` can connect to.

4. Publication Exclusivity
   - Responsibility:
     - Prevent one role from being simultaneously treated as an SMB share path
       and a live writable iSCSI disk.
   - Inputs:
     - Normalized publication definitions, current share definitions, current
       iSCSI definitions.
   - Outputs:
     - One clear publication decision per role and warnings for skipped
       conflicting paths.

5. Guest Consumption
   - Responsibility:
     - Define what `P50` and WSL2 are expected to do after the HQ side has
       published the disk.
   - Inputs:
     - Target portal address, target name, expected initiator, disk ownership
       rules.
   - Outputs:
     - A manual or scripted connection flow for Windows iSCSI Initiator and
       `wsl --mount`.

## Invariants
1. The parent VHDX is never the published writable device.
   - Why it matters:
     - The parent is the shared read-only base and must stay immutable.
   - Validation method:
     - Reject publication definitions that point at a known parent path or a
       non-differencing disk when the role expects a child.

2. The child VHDX has exactly one active writer.
   - Why it matters:
     - Concurrent writers across `HQ`, `P50`, or both would risk filesystem
       corruption.
   - Validation method:
     - Treat `P50` as the sole allowed initiator and do not also mount the
       child volume locally on `HQ`.

3. A role uses either SMB publication or iSCSI publication, not both as the
   primary writable path.
   - Why it matters:
     - The ACL/share contract and the block-device contract have different
       ownership and safety rules.
   - Validation method:
     - Normalize one `PublicationMode` per role and skip conflicting steps in
       orchestration.

4. iSCSI publication must be idempotent.
   - Why it matters:
     - Rerunning `configure_hq.ps1` should verify and converge the target state
       rather than duplicating target objects.
   - Validation method:
     - Query existing target, mapping, and initiator definitions before any
       create action.

5. Secrets and authentication references are never stored in source-controlled
   metadata.
   - Why it matters:
     - CHAP secrets or any future authentication material must stay out of the
       repo.
   - Validation method:
     - Accept only non-secret references in metadata and resolve any secret at
       runtime from Windows-backed storage.

6. The HQ-side iSCSI publication logic stays separate from the P50-side
   connection logic.
   - Why it matters:
     - `configure_hq.ps1` runs on `HQ`; it should not assume control over the
       initiator state on `P50`.
   - Validation method:
     - Keep the target-provisioning functions on the HQ side and treat
       initiator connection steps as a separate workflow.

## Security Contract Shift
The current SMB design uses two HQ-side enforcement layers:

1. NTFS ACLs on the managed role folders
2. SMB share permissions on the published shares

That model fits file publication from `HQ`.

An iSCSI-published role does not keep that same access contract.

For an iSCSI role, the security model splits into two different concerns:

1. HQ Host Protection
   - Protect the parent and child VHDX files on `HQ`
   - Protect the folder that stores those disk files
   - Protect the iSCSI target configuration on `HQ`
   - Restrict target access to the intended initiator, initially `P50`
   - Optionally require CHAP or another runtime-resolved authentication method

2. Consumer Filesystem Protection
   - The mounted filesystem inside the published child disk is enforced by the
     system that consumes it
   - If `P50` mounts it in Windows, Windows filesystem permissions apply there
   - If WSL2 mounts it as a Linux filesystem, Linux ownership and mode bits
     apply there

That means the current HQ local role groups such as `HQ\Lab_RW` and
`HQ\Repository_R` no longer act as the direct runtime file-access gate for an
`iSCSI` role in the same way they do for an `SMB` role.

Instead:

- HQ local groups and service identities still matter for protecting the VHDX
  files and the target administration boundary on `HQ`
- initiator allow-listing becomes the first publication gate
- the live filesystem permissions move to the consumer side after attach

Implementation consequence for `configure_hq.ps1`:

- `SMB` roles keep the current ACL and share workflow
- `iSCSI` roles must skip SMB share publishing
- `iSCSI` roles must not treat the managed-path NTFS ACL contract as the
  end-user access contract for the published disk
- `iSCSI` roles should instead validate or enforce host-side protection for the
  backing VHDX paths and report the consumer-side filesystem contract
- one role must not be treated as both the active SMB file path and the active
  writable iSCSI disk at the same time

## Interface Contracts
1. `Get-HqRolePublicationDefinitions`
   - Input contract:
     - Read imported metadata and return one normalized publication definition
       per role, including `PublicationMode`, share details when applicable,
       and iSCSI details when applicable.
   - Output contract:
     - A list of objects with stable fields such as `RoleName`,
       `PublicationMode`, `ManagedPath`, `ShareName`, `IscsiVirtualDiskPath`,
       `IscsiTargetName`, and `AllowedInitiator`.
   - Failure behavior:
     - Throw when a role definition is ambiguous or mixes incompatible
       publication modes.

2. `Test-HqIscsiChildDiskEligibility`
   - Input contract:
     - Accept one role publication definition and inspect the candidate disk
       path before publication.
   - Output contract:
     - Return a validated publication candidate that is safe to hand to the
       target-provisioning layer.
   - Failure behavior:
     - Throw when the candidate points at a parent disk, a missing path, or a
       path that does not match the expected role.

3. `Ensure-HqIscsiTargetPublication`
   - Input contract:
     - Accept one validated iSCSI publication definition for one role.
   - Output contract:
     - Return a result row with fields such as `RoleName`, `PublicationMode`,
       `IscsiTargetName`, `IscsiVirtualDiskPath`, `AllowedInitiator`, and
       `IscsiAction`.
   - Failure behavior:
     - Throw when the target service, virtual disk definition, or target
       mapping cannot be created or verified.

4. `Ensure-HqRolePublication`
   - Input contract:
     - Accept final workflow rows after disk activation and dedup decisions.
   - Output contract:
     - Append either SMB publication results or iSCSI publication results for
       each role, based on the normalized publication mode.
   - Failure behavior:
     - Throw on conflicting publication definitions and stop before a partial
       mixed-mode publish can hide the problem.

5. `Show-HqRunSummary`
   - Input contract:
     - Accept workflow rows that may contain SMB or iSCSI publication fields.
   - Output contract:
     - Print a publication summary table that makes the publication mode clear
       per role.
   - Failure behavior:
     - Do not fail only because one publication section is empty; show the
       sections that actually apply.

## Risk Register
- Risk:
  - Windows iSCSI Target may not support the exact differencing-disk backing
    model we want for the child disk.
  - Mitigation:
    - Validate the support boundary in a lab spike before adding code, and keep
      a flatten-to-standalone-VHDX fallback if needed.

- Risk:
  - The current SMB-first docs and code could drift from a future hybrid
    publication model.
  - Mitigation:
    - Keep iSCSI as an explicit alternate `PublicationMode` rather than
      silently overloading the current share definitions.

- Risk:
  - Operators could mount the child disk locally on `HQ` while `P50` is still
    attached over iSCSI.
  - Mitigation:
    - Document single-writer ownership clearly and add runtime warnings before
      any local attach logic is introduced.

- Risk:
  - `P50` initiator setup is outside the current script boundary, so the target
    could be published correctly but still unused.
  - Mitigation:
    - Treat HQ publication and P50 consumption as separate acceptance steps in
      the implementation plan.

- Risk:
  - Increment 5 is currently centered on SMB. Expanding directly into iSCSI
    could blur the acceptance criteria.
  - Mitigation:
    - Plan iSCSI as a separate design-backed slice with its own acceptance
      criteria, verification steps, and non-goals.
