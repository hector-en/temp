# Configure HQ - Product Notes

These notes capture the intended business and operational meaning of the HQ
disks. They are source information for increment planning, not an
implementation template.

Related planning notes:
- ACL and identity contract: `app/docs/configure_hq.acl-contract.md`
- Optional block-publication design: `app/docs/configure_hq.iscsi-design.md`

## Outcome

Prepare the HQ VM data disks so they can be activated, optimized, permissioned,
and published in a repeatable way for ALKBIO research and backup workflows.

## Disk Intent

1. `W:` -> `Lab`
   - Purpose: Deduplicated Lab data storage.
   - Deduplication: Yes.
   - Share: `lab`
   - Managed path: `W:\lab`
   - Access intent: Modify access for `HQ\Lab_RW`.
   - Service access: FullControl for `HQ\svc_lab`.

2. `Z:` -> `ShareDrive`
   - Purpose: General shared disk for inter-VM data.
   - Deduplication: No.
   - Share: `sharedrive`
   - Managed path: `Z:\share`
   - Access intent: ReadAndExecute access for `HQ\ShareDrive_R`.
   - Service access: FullControl for `HQ\svc_lab`.

3. `R:` -> `Repository`
   - Purpose: Read-only archive of 7z snapshots.
   - Deduplication: No.
   - Share: `repository`
   - Managed path: `R:\repository`
   - Access intent: ReadAndExecute access for `HQ\Repository_R`.
   - Service access: FullControl for `HQ\svc_lab`.

4. `B:` -> `Backups`
   - Purpose: Writable backup destination for job services.
   - Deduplication: No.
   - Share: `backups`
   - Managed path: `B:\backups`
   - Access intent: Modify access for `HQ\Backups_RW`.
   - Service access: FullControl for `HQ\svc_lab`.

## Required HQ Local Principals

- `HQ\Lab_RW`
- `HQ\Backups_RW`
- `HQ\ShareDrive_R`
- `HQ\Repository_R`
- `HQ\svc_lab`

## Access Model Notes

- The Hyper-V host `P50` is not joined to `HQ`, so ACL and SMB policy must use
  principals owned by `HQ`.
- `P50\...` users are not the policy principals for HQ resources. Clients on
  `P50` access HQ shares by authenticating with matching `HQ` local credentials
  or another `HQ`-accepted credential.
- The intended lab pattern is mirrored identities across `P50` and `HQ` for
  selected users such as `hector` and `Researcher`: same username, same
  password, with authorization still evaluated on the `HQ` side.
- The dedicated service account `HQ\svc_lab` is the full-access fallback for
  automation and controlled WSL2 access.
- The service account may also be mirrored onto `P50` when host-side automation
  or WSL2 workflows need a stable non-human identity.
- Human users should normally receive rights through the per-role `HQ\...`
  local groups rather than direct ACL entries.
- Preserve `SYSTEM` and `Administrators` with FullControl when applying NTFS
  ACLs.
- Shares remain role-based, not user-based. The target pattern is
  `\\10.100.0.10\lab` authenticated as an `HQ`-accepted user, not
  `\\10.100.0.10\hector`.

## Secret Handling Requirements

- No passwords, secure strings, or reusable tokens may be hard coded in
  scripts, generated modules, tests, docs, or committed configuration files.
- Credentials for `HQ\svc_lab` or any future service identity must be resolved
  at runtime from encrypted Windows-backed storage.
- Acceptable storage mechanisms are:
  - Windows Credential Manager
  - DPAPI-protected `PSCredential` material such as `Export-Clixml` used on the
    same machine and under the intended account context
  - a SecretManagement-backed vault if introduced later
- Generated artifacts such as `HqDiskMetadata.psm1` must never contain
  plaintext credentials.
- Increment 5 should accept credential references such as a target name or
  credential path, not a plaintext password value.

## Increment Notes

1. Increment 1: Disk discovery and activation
   - Detect attached non-system data disks.
   - Bring offline and read-only disks online.

2. Increment 2: Role mapping
   - Map activated disks to their intended HQ roles (`Lab`, `ShareDrive`, `Repository`, `Backups`).
   - Fail clearly if expected disks or drive letters are missing.

3. Increment 3: Deduplication
   - Enable deduplication only for `W:` / `DiffData`.

4. Increment 4: ACL application
   - Identity bootstrap is a prerequisite: required HQ users, groups, and
     memberships must exist before ACL application starts.
   - Ensure the managed role folders exist.
   - Apply NTFS permissions according to the access intent above.
   - Preserve `SYSTEM` and `Administrators`.
   - Grant `HQ\svc_lab` FullControl on every managed role folder.
   - Keep a backup and revert path for the identity bootstrap.

5. Increment 5: SMB publishing
   - Create and configure shares for the managed role folders.
   - Apply share permissions using the same `HQ` local group model.
   - Allow `P50` clients and WSL2 workflows to connect by using `HQ` local
     credentials rather than `P50` principals.
   - Resolve any service-account credential from encrypted storage at runtime.
