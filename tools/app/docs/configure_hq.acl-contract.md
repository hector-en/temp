# Configure HQ - ACL and Identity Contract

Related planning notes:
- Product and increment intent: `app/docs/configure_hq.increments.md`
- Domain model and increment framing: `app/docs/configure_hq.next.domain.md`

## Topology

- `P50`
  - Hyper-V host
  - runs WSL2
  - not joined to `alkbio.local`
- `HQ` / `alkbio.local`
  - guest VM
  - domain controller
  - hosts the managed data shares

## Ownership Boundary

`HQ` owns the storage security contract.

That means:

- share authorization is defined on `HQ`
- NTFS authorization is defined on `HQ`
- access groups are created and managed on `HQ`
- the dedicated maintenance service account is created and managed on `HQ`

`P50` is a client of that contract, not the authority for it.

## Authentication Model

There is no shared trust between `P50` and `HQ`.

So the lab uses a mirrored-identity model:

- selected human users exist on both `P50` and `HQ`
- the mirrored accounts use the same username and password
- `P50` users authenticate to `HQ` shares by presenting `HQ`-accepted credentials
- authorization on `HQ` is still group-based on the `HQ` side

This is a lab convenience model, not a domain-trust model.

## Authorization Model

Human access is group-based.

The base HQ access groups are:

- `HQ\Lab_RW`
- `HQ\Backups_RW`
- `HQ\ShareDrive_R`
- `HQ\Repository_R`

The dedicated service account is the explicit full-access exception:

- `HQ\svc_lab`

`HQ\svc_lab` is not the normal human access path. It exists for:

- maintenance
- admin tasks
- controlled automation
- controlled WSL2 / parent-VHDX access workflows

## Managed Share Contract

The share names stay role-based, not user-based.

Valid examples:

- `\\10.100.0.10\lab`
- `\\10.100.0.10\repository`
- `\\10.100.0.10\backups`
- `\\10.100.0.10\sharedrive`

The user authenticates to the share; the user name is not the share name.

So the intended access pattern is:

- connect to `\\10.100.0.10\lab`
- authenticate as `HQ\hector`, `HQ\Researcher`, or `HQ\svc_lab`

Not:

- `\\10.100.0.10\hector`
- `\\10.100.0.10\svc_lab`

unless a per-user share is deliberately created, which is not part of this contract.

## Role Paths and Access Intent

1. `W:\lab`
   - Share: `lab`
   - Human group: `HQ\Lab_RW`
   - Human right: modify / change
   - Service right: full control via `HQ\svc_lab`

2. `R:\repository`
   - Share: `repository`
   - Human group: `HQ\Repository_R`
   - Human right: read
   - Service right: full control via `HQ\svc_lab`

3. `B:\backups`
   - Share: `backups`
   - Human group: `HQ\Backups_RW`
   - Human right: modify / change
   - Service right: full control via `HQ\svc_lab`

4. `Z:\share`
   - Share: `sharedrive`
   - Human group: `HQ\ShareDrive_R`
   - Human right: read
   - Service right: full control via `HQ\svc_lab`

## Initial HQ Principal Set

The initial HQ-side users are:

- `HQ\hector`
- `HQ\Researcher`
- `HQ\svc_lab`

Proposed initial group membership:

- `HQ\hector`
  - `HQ\Lab_RW`
  - `HQ\Repository_R`
  - `HQ\Backups_RW`
  - `HQ\ShareDrive_R`
- `HQ\Researcher`
  - `HQ\Lab_RW`
  - `HQ\Repository_R`
  - `HQ\ShareDrive_R`
- `HQ\svc_lab`
  - no human access group membership required
  - receives explicit full-control ACL and share permissions on every managed path

This keeps the service account separate from normal human authorization.

## Mirrored P50 Identity Set

The lab mirror set on `P50` should match the HQ-side names for the identities
that need seamless access:

- `P50\hector`
- `P50\Researcher`
- optionally `P50\svc_lab` when host-side automation or WSL2 workflows need a
  dedicated mirrored maintenance identity

Mirror rule:

- same username
- same password
- authorization still evaluated on the `HQ` side

## WSL2 and Parent-VHDX Access

The accepted lab design is:

- the differentiated child VHDX is used locally by the workflow on `P50` / WSL2
- the parent VHDX lives on the `lab` share on `HQ`
- access to the parent VHDX is performed through an SMB session authenticated
  with an `HQ`-accepted identity

The preferred automation identity for this is `HQ\svc_lab`.

This avoids depending on:

- `P50` domain membership in `HQ`
- `P50\...` principals appearing in `HQ` ACLs
- implicit WSL2 machine identity behavior

## Bootstrap Requirement

Before ACL and SMB publishing work can be considered complete, the workflow
must be able to bootstrap the HQ-side identities.

That bootstrap step must:

1. back up the current HQ local-user / local-group state
2. create any missing HQ groups
3. create any missing HQ mirrored users
4. create the dedicated service account
5. assign the configured group memberships
6. support revert using the recorded backup state

## Backup and Revert Rule

This bootstrap must always support backup and revert.

Required behavior:

- backup before creating users, groups, or memberships
- record only enough state to restore safely
- never store plaintext passwords in backup artifacts
- revert removes only identities and memberships introduced by the bootstrap
- revert preserves anything that already existed before bootstrap

## Implementation Direction

The implementation should stay split into two concerns:

1. identity bootstrap
   - users
   - groups
   - memberships
   - backup / revert

2. storage publication
   - NTFS ACLs
   - SMB shares
   - share permissions

This keeps identity lifecycle changes separate from share creation and makes the
lab easier to reason about and undo.
