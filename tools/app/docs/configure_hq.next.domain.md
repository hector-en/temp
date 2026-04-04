# Configure HQ Next - Domain Design

Related planning notes:
- Product and increment intent: `app/docs/configure_hq.increments.md`
- ACL and identity contract: `app/docs/configure_hq.acl-contract.md`
- Optional block-publication design: `app/docs/configure_hq.iscsi-design.md`

## Domain Language
- Attached Disk: A disk visible to the VM through `Get-Disk`.
- Data Disk: An attached disk that is neither boot nor system.
- Provisioning Policy: Rules that describe how a disk should be prepared and shared.
- Online Transition: State change from offline/read-only to writable online.
- Managed Role Path: The folder root on a role volume that HQ automation owns
  and permissions explicitly, for example `W:\lab`.
- HQ Local Principal: A local user or group created on the HQ guest and used as
  the source of truth for NTFS and SMB authorization.
- Mirrored Identity: A user account intentionally created on both `P50` and
  `HQ` with the same username and password so the lab can authenticate across
  the non-trusted boundary.
- Service Account: A dedicated HQ-local account with full access for automation
  and controlled fallback access paths, initially `HQ\svc_lab`.
- Credential Reference: A non-secret identifier such as a Credential Manager
  target or DPAPI-protected credential path that runtime code can resolve to a
  usable `PSCredential`.

## Bounded Contexts
1. Disk Discovery
   - Read attached disks and select target data disks.
2. Disk Activation
   - Bring selected disks online and clear read-only state.
3. Data Optimization
   - Enable deduplication for configured volumes.
4. ACL Application
   - Ensure required HQ users, groups, and memberships exist.
   - Ensure managed role folders exist.
   - Apply NTFS permissions for HQ-local groups and the service account.
5. Share Publishing
   - Create or update SMB shares for configured paths.

## Invariants
1. Never modify system or boot disks.
2. Activation is idempotent: reruns do not break already online disks.
3. Every side-effect command is mockable in tests.
4. Orchestration emits object output that can be asserted.
5. ACL and share policy use HQ-local principals because the Hyper-V host `P50`
   is not joined to `HQ`.
6. Human access is group-based; the service account is the explicit full-access
   exception.
7. Selected human users may be mirrored across `P50` and `HQ`, but
   authorization is still evaluated against `HQ` groups and `HQ` ACLs.
8. Shares remain role-based rather than user-based; the user authenticates to
   `\\host\share`, not to a per-user share path.
9. WSL2 access from `P50` is expected to arrive through an SMB session
   authenticated with `HQ` credentials, not `P50` principals.
10. Secrets are never stored in source-controlled files; service credentials are
   resolved only from encrypted Windows-backed storage at runtime.

## Current Next Increment Scope
1. Define and implement the HQ-side identity bootstrap for required users,
   groups, and memberships with backup and revert support.
2. Implement ACL Application for managed role folders.
3. Preserve `SYSTEM` and `Administrators`.
4. Grant `HQ\svc_lab` FullControl on each managed role folder.
5. Keep Share Publishing separate so SMB access and validation can evolve
   without coupling to NTFS ACL mechanics.
6. When Share Publishing is implemented, accept credential references rather
   than plaintext secrets.
