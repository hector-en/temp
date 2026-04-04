# `configure_hq.Tests.ps1` guide

This file tests the script in the same order the script grows.
Read it as a record of what the script must keep doing, not just as a pile of isolated checks.

If you are new here, start with one simple idea.
The tests protect the host step, the guest step, and the later identity and access rules that sit on top of those earlier steps.

## Read the test file in this order

- Disk discovery and activation start at `app/tests/configure_hq.Tests.ps1:1`
- Role mapping starts at `app/tests/configure_hq.Tests.ps1:164`
- Host metadata module tests start at `app/tests/configure_hq.Tests.ps1:228`
- Dedup tests start at `app/tests/configure_hq.Tests.ps1:354`
- ACL, SMB, and identity tests start at `app/tests/configure_hq.Tests.ps1:435`

## The first tests protect the guest disk step

The opening section at `app/tests/configure_hq.Tests.ps1:1` covers the guest path that finds the data disks and makes them usable.
This is the first thing the real workflow has to get right.

`Get-HqAttachedDataDisks` is tested first because the rest of the workflow depends on targeting the right disks.
If this part is wrong, everything later is working on the wrong target.

`Bring-HqDisksOnline` is tested next because the script needs writable disks before it can do anything useful with them.
That block now also checks that drive letters are refreshed after a disk is brought online, because later dedup and ACL work reads the post-activation state, not the stale pre-change snapshot.
`Invoke-HqDiskActivation` then checks the combined path that turns discovered disks into role-aware workflow rows.

`Start-HqConfiguration` sits at the end of this first block because it is the first real shared guest entrypoint.
That part now also checks that the workflow calls SMB publishing after ACL work has prepared the managed paths.

## The next tests protect role naming

The next section starts at `app/tests/configure_hq.Tests.ps1:164`.
These tests answer one question.
Once the guest has the disks, can it correctly tell which one is `Lab`, `Repository`, `Backups`, or `ShareDrive`?

That is why the tests cover both the strong path and the fallback path.
The strong path uses the VHD path from the host.
The fallback path uses the guest drive letter when the VHD path is not there.

There is also a failure test here.
That matters because stopping on an unknown disk is safer than letting later steps guess.

## The host metadata tests come next because the guest depends on them

The host metadata module section starts at `app/tests/configure_hq.Tests.ps1:228`.
This is the test block that protects the host side of the script.

The host does not activate disks.
Its job is to read the VM attachments and write the small module the guest will later import.

These tests check:

- the host command guard
- the VM selection path
- the explicit VM name path
- the guest import of the generated module

This matters because the guest role mapping is only as good as the metadata the host wrote.

## The dedup tests only check the narrower dedup rules

The dedup section starts at `app/tests/configure_hq.Tests.ps1:354`.
By the time the script reaches this point, disk activation and role mapping should already be working.

So these tests stay focused on a smaller question.
Given the activation rows, does the script limit dedup to the right roles and stop cleanly when the needed dedup conditions are not present?

That is why this block checks:

- only dedup-enabled roles move forward
- the expected drive letter must really be there
- missing dedup commands fail clearly
- the feature-install path behaves as expected

## The ACL, SMB, and identity tests protect the later layers of the script

The increment 4 block starts at `app/tests/configure_hq.Tests.ps1:435`.
This part sits later in the file because it depends on the earlier ideas already being in place.

The script first needs to know which disk belongs to which role.
Only after that does it make sense to talk about managed folders, SMB shares, users, groups, and group links.

This block is split into two kinds of checks.
One kind protects the folder and share publishing rules.
The other kind protects the identity contract and the saved-state path.

## The ACL tests check the managed folders and the principals on them

The ACL test starts at `app/tests/configure_hq.Tests.ps1:460`.
Its job is to make sure a role like `Lab` turns into the right managed path and the right ACL entries.

This is not just testing file system commands.
It is testing that the role contract and the identity contract meet in the right place.

## The SMB tests check the managed shares that sit on top of those folders

The SMB share tests start at `app/tests/configure_hq.Tests.ps1:908`.
They stay close to the ACL and workflow tests because the share step only makes sense after the managed folder and identity rules are already known.

These checks stay narrow on purpose.
They verify that the workflow publishes the expected shares, grants the expected rights, and does not recreate a share that already exists.

## The identity state tests check what HQ looks like before repair

The state tests start at `app/tests/configure_hq.Tests.ps1:496`.
These tests make sure the script can read the current users, groups, and group links without crashing when some expected objects are still missing.

That is why the tests cover both of these cases:

- read from Active Directory when the guest exposes AD commands
- still record missing users as missing instead of failing the backup

This section matters because later repair work needs a clear picture of what is already there.

## The last tests now cover identity state, restore, and cleanup as separate actions

The final section starts at `app/tests/configure_hq.Tests.ps1:753`.
These are the newest tests, and they are split on purpose so each identity action stays easy to reason about.

The first wrapper test checks that the guest can export the current identity state without mixing that work into activation.
The next wrapper test checks that the guest can run cleanup from the saved identity state as its own explicit action.
Then the cleanup-plan tests check two separate cases: whole principals added after the saved state, and group links added after the saved state.
After that, the cleanup runner tests check both cleanup outcomes: one test keeps whole principal removal planned when the operator declines deletion, and another test confirms that the same command can continue into confirmed user and group deletion when the operator agrees.
The final restore tests still stay split in two: one for creating missing users and groups, and one for adding missing group links.
This section now also covers the local-account edge cases that came out of guest verification: hidden local SAM principals that still need to verify during restore, and already-missing local users or groups that cleanup should treat as already removed.

Keeping these checks split makes the meaning clearer.
One group of tests records what existed before change.
One group of tests plans or runs cleanup from that saved record.
The last group repairs missing users, groups, and links.

## What this test file tells the next developer

This file says more than "the code passes."
It shows the order the system depends on.

The host writes the disk map first.
The guest uses that map to prepare disks.
Then the guest can apply dedup, access rules, and SMB publishing on the right targets.
Identity snapshot, identity cleanup, and identity restore are tested as separate actions so they do not get mixed together by accident.

If you are changing the script, read the tests in that same order.
It will usually show you which earlier assumption your change depends on.
