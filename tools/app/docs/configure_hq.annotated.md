# `configure_hq.ps1` guide

This file is used in two places.

On the Hyper-V host, it figures out which VM you mean and writes a small metadata module for that VM.
On the HQ guest, it does the real work on the disks, dedup, access rules, required identities, and now SMB share publishing.

If you are new to this file, keep that split in mind first.
The host prepares context. The guest uses that context to make the machine match the lab design.

## Read the file in this order

Start here if you want the big picture.

- Disk work starts at `app/configure_hq.ps1:14`
- Role mapping starts at `app/configure_hq.ps1:605`
- Main workflow and dedup start at `app/configure_hq.ps1:683`
- Folder access rules start at `app/configure_hq.ps1:857`
- Identity contract starts at `app/configure_hq.ps1:902`
- Saved state and cleanup start at `app/configure_hq.ps1:1168`
- Identity restore starts at `app/configure_hq.ps1:1486`
- The script entry choices are at `app/configure_hq.ps1:1552`

## Host work comes first

The guest cannot safely guess which attached disk is meant to be the lab disk, the backup disk, or the shared disk.
That is why the host writes `HqDiskMetadata.psm1` first.

The host side of this file lives around `app/configure_hq.ps1:162` through `app/configure_hq.ps1:398`.
That part reads the VM disk attachments and writes a small module that tells the guest which VHD belongs to which role.

That metadata module now also carries the ACL contract and the required identity contract for the guest.
That means the guest still reads one generated source of truth instead of rebuilding those contracts from scratch.

If that host step has not happened yet, the guest side does not have the full map it needs.

## Guest work starts with safe disk handling

The guest side starts by finding only the data disks and leaving the system disk alone.
That work is in `app/configure_hq.ps1:403`, `app/configure_hq.ps1:489`, and `app/configure_hq.ps1:549`.

The meaning of this section is simple.
Before the script can talk about roles like `Lab` or `Repository`, it first has to make sure the right disks are online and writable.

`Get-HqAttachedDataDisks` limits the target set.
`Bring-HqDisksOnline` makes the minimum disk changes needed.
`Invoke-HqDiskActivation` turns those disk results into workflow rows that later sections can reuse.

One small but important bugfix now lives here too.
After a disk changes from offline or read-only, the script refreshes the live partition view so later dedup and ACL work sees the real drive letters instead of the pre-activation snapshot.

## The next step is to name each disk by its role

Once the guest has the data disks, it still only knows disk numbers and paths.
The next problem is to turn those into the roles the rest of the script cares about.

That happens in `app/configure_hq.ps1:600` and `app/configure_hq.ps1:603`.
The script prefers the host VHD path because that is the clearest identity.
If that path is not available, it falls back to the drive letter the guest can see.

This section matters because every later step depends on role names, not raw disk numbers.
If a disk cannot be matched, the script stops there instead of guessing.

## The main guest workflow then runs in order

The main guest path starts at `app/configure_hq.ps1:666` and `app/configure_hq.ps1:681`.
This is where the file stops being a set of helpers and becomes a run order.

Right now that run order is:

1. activate and map the disks
2. optionally restore required identities when the operator asks for that step
3. run dedup only on the roles that asked for it
4. apply the folder access rules to the final workflow rows
5. publish SMB shares for the managed role folders

That fifth step is the new increment-5 boundary.
The workflow no longer stops at ACLs.

`Enable-HqDiskDeduplication` at `app/configure_hq.ps1:732` stays narrow on purpose.
It only looks at rows already marked as dedup-enabled and checks that the expected drive is really there before it calls the dedup command.

## Folder access rules come after the disks are known

The folder access rule section starts at `app/configure_hq.ps1:841`.
This part answers a different question from the disk work.

The disk work says where the data lives.
The access rule work says which managed folder should exist on that role and who should be allowed to use it.

`Get-HqRoleAclDefinitions` at `app/configure_hq.ps1:849` keeps that contract in one place.
`Ensure-HqRoleAcl` at `app/configure_hq.ps1:1019` uses the workflow rows from the earlier disk step to create the managed folders and apply the expected ACL entries.

This comes later for a reason.
The script needs to know the right role and the right drive before it can safely create `W:\lab` or `R:\repository`.

## The identity contract says which users and groups HQ should have

The identity contract starts at `app/configure_hq.ps1:889`.
This part is not about disks at all.
It is about the users and groups the later access rules depend on.

`Get-HqRequiredSecurityPrincipalDefinitions` at `app/configure_hq.ps1:894` builds the required set.
That set includes the ACL groups, the mirrored users, and the service account.

`Get-HqExpectedSecurityPrincipalMemberships` at `app/configure_hq.ps1:926` keeps the expected user-to-group links in one place.
That matters because backup, restore, and access setup all need to read the same contract.

## The saved-state helpers record what HQ looks like now

The saved-state path starts at `app/configure_hq.ps1:1168`.
This part exists so the script can record what is already on the guest before later repair or cleanup work changes anything.

`Get-HqSecurityPrincipalStateEntry` reads the current state of one user or group.
It prefers Active Directory when the guest exposes AD commands.
If that is not available, it falls back to local account checks.

The local-account logic here is stricter than it used to be.
Cleanup planning now avoids stale deleted principals that some local SAM fallback paths could still surface after removal.

`Export-HqSecurityPrincipalState` at `app/configure_hq.ps1:1221` writes the current state to JSON.
`Import-HqSecurityPrincipalState` at `app/configure_hq.ps1:1255` reads it back in the same shape.
`Invoke-HqSecurityPrincipalStateBackup` at `app/configure_hq.ps1:1275` is the thin operator path that calls that export.

The point of this section is not complexity.
It is to keep one shared record shape so later work can compare "what should exist" with "what existed before we changed anything."

## The saved-state cleanup path uses that record to undo later identity changes

The cleanup path starts at `app/configure_hq.ps1:1287`.
This part exists so the guest can undo identity work from a saved baseline instead of guessing what was original.

`Invoke-HqSecurityPrincipalStateCleanup` at `app/configure_hq.ps1:1287` is the thin operator path.
`Get-HqSecurityPrincipalCleanupPlan` at `app/configure_hq.ps1:1302` compares the saved state with the current guest state.
`Invoke-HqSecurityPrincipalCleanup` now runs the whole cleanup flow in one command.

That flow matters.
The script removes added group links first, prints the planned whole-principal removals in a table, then asks whether to continue with confirmed user deletion and confirmed group deletion.
If the operator says no, those principals stay planned instead of being removed automatically.

This section also now handles already-missing local users and groups more gracefully.
If Windows reports that a local principal was not found during cleanup, the script treats that as already removed and keeps going.

## The identity restore step fixes missing users, groups, and links

The restore section starts at `app/configure_hq.ps1:1486`.
This is the part that closes the gap between the contract and the real machine.

The problem it solves is straightforward.
Later access work cannot rely on `HQ\\Lab_RW` or `HQ\\svc_lab` if those objects do not exist yet.
The same is true if `HQ\\hector` exists but is still missing one of the required group links.

`New-HqSecurityPrincipalGroup` at `app/configure_hq.ps1:1345` creates missing groups.
`New-HqSecurityPrincipalUser` at `app/configure_hq.ps1:1361` creates missing users.
`Add-HqSecurityPrincipalToGroup` at `app/configure_hq.ps1:1377` adds a missing group link for a user.

`Ensure-HqSecurityPrincipals` at `app/configure_hq.ps1:1486` ties those steps together.
It reads the required contract, checks the current state, creates what is missing, adds missing links, and returns one result row per principal.

The latest bugfix work matters here too.
Restore can now accept hidden local SAM principals as real when Windows create operations report that the user or group already exists, even if the stricter cleanup-oriented lookup path does not show them cleanly.

## The new SMB step publishes the managed role folders

The first increment-5 slice adds SMB publishing after ACL setup.

That new section derives share policy from the same managed-folder contract the ACL step already uses.
That keeps the first SMB slice small and coherent.

`Ensure-HqSmbShares` creates or verifies a share for each managed role folder, checks that an existing share still points to the right path, and grants the expected share access to the role principal and the service account.

This means the guest workflow now finishes by publishing folders like `W:\lab` and `R:\repository` through SMB instead of stopping at NTFS ACLs alone.

## The bottom of the file chooses the operator path

The final branch starts at `app/configure_hq.ps1:1552`.
It keeps four ways of using the file in one place.

If you run `-ExportSecurityPrincipalState`, the guest writes the current identity snapshot.
If you run `-RunIdentityCleanup`, the guest runs cleanup from that saved snapshot and handles the confirmation flow for planned deletions inside that same command.
If you run `-RunActivation`, the guest runs the disk workflow, can also restore required identities when `-RunIdentityRestore` is included, and now publishes SMB shares after the ACL step.
If you run it with no switch on the host, it updates the metadata module.

That is the full shape of the file.
The host prepares the map. The guest uses that map to prepare disks, apply later rules on the right targets, run identity actions only when the operator asks for them, and now publish the managed folders through SMB.
