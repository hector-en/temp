# AN2-00E — Account Lifecycle Completion SPEC

## Purpose

This milestone completes the account lifecycle layer for the current `vmuser` config tool.

The current code already has strong profile-driven account creation, target env reconciliation, SMB/mount profile integration, target env ownership restoration, and a basic password prompt. This milestone finishes the missing lifecycle operations:

```text
1. explicit first-login password expiry policy
2. conservative remove-target
3. highly guarded remove-operator
4. lifecycle help/status polish
```

## Current baseline

The current codebase already has:

```text
config_run_create_account
config_apply_account_plan
config_reconcile_target_env_file
config_target_env_storage_owner_group
config_account_profiles_file
config_smb_profiles_file
config_mount_profiles_file
config_resolve_account_profile
config_account_profile_to_target_env
```

Known implemented behavior:

```text
- create-target/create-operator can resolve account profiles.
- interactive account creation prompts before applying the plan.
- if a Linux user is newly created in interactive mode, config asks whether to run passwd USER.
- non-interactive mode does not prompt for password.
- target env files are written under /home/vmuser/.local/etc/config-sh/targets.
- target env files are restored to operator owner/group and mode 600.
- targets directory is restored to operator owner/group and mode 700.
```

Known missing behavior:

```text
- --expire-password is not implemented.
- remove-target is not implemented.
- remove-operator is not implemented.
- account lifecycle help does not yet fully cover removal and first-login expiry.
```

## Non-goals

Do not implement these in AN2-00E:

```text
- AN2-01 role-managed installer functions
- AN2-02 Python environment profile source of truth
- Python env package installation helpers
- SMB credential deletion
- broad operator purge behavior
- automated deletion of research data, PKM content, manuscripts, or datasets
- broad bootstrap/install/mount/pull/push changes
```

## Password policy

### Desired behavior

For a newly-created Linux user:

Interactive:

```bash
sudo config --create-target --profile AIEngineer --name aiengineer --interactive
```

After user creation:

```text
Set Linux password for aiengineer now? [y/N]
```

If yes:

```bash
passwd aiengineer
```

If no:

```text
Set it later with: sudo passwd aiengineer
```

Non-interactive:

```bash
sudo config --create-target --profile AIEngineer --name aiengineer --non-interactive
```

Must not prompt. It should print:

```text
Set it later with: sudo passwd aiengineer
```

### First-login expiry

Add:

```text
--expire-password
```

Meaning:

```bash
chage -d 0 USER
```

Apply it only after a password exists or was just set.

If the user declined password setup or non-interactive did not set it, print:

```text
Password was not set, so first-login expiry was not applied.
Set the password first:
  sudo passwd USER
Then expire it:
  sudo chage -d 0 USER
```

### Password safety rules

Do not:

```text
- accept password values on command line
- write passwords to config files
- print passwords
- pipe plaintext passwords into chpasswd
- put password values in variables, logs, target env files, TSV files, or bootstrap plans
```

## remove-target

### Commands

Add:

```bash
sudo config --remove-target --name USER --dry-run
sudo config --remove-target --name USER --keep-home
sudo config --remove-target --name USER --remove-home
sudo config --remove-target --name USER --purge-config

sudo config remove-target --name USER --dry-run
```

### Default behavior

The default should be conservative:

```text
remove Linux user account only
keep /home/USER
keep /home/vmuser/.local/etc/config-sh/targets/USER.env
keep /home/USER/.local/state/config-sh
keep /home/USER/.local/share/wsl-mounts/*.credentials
```

### Flags

`--dry-run`

```text
Show intended actions only.
Do not remove anything.
```

`--keep-home`

```text
Explicit version of the default.
Remove Linux user account but keep /home/USER.
```

`--remove-home`

```text
Remove /home/USER as well.
Requires confirmation unless --non-interactive is provided.
```

`--purge-config`

```text
Remove /home/vmuser/.local/etc/config-sh/targets/USER.env.
Requires confirmation unless --non-interactive is provided.
```

`--non-interactive`

```text
No prompts.
Only safe if destructive flags are explicit.
```

### Refusals

remove-target must refuse:

```text
USER=vmuser
USER=root
empty USER
current operator user
```

It should tell the operator to use remove-operator for operator removal.

### Credential safety

Do not delete:

```text
/home/USER/.local/share/wsl-mounts/*.credentials
```

in AN2-00E.

If home is removed with `--remove-home`, then credential files under that home naturally disappear as part of home deletion. Before doing that, output should clearly state that removing home also removes target-owned state and credential files under that home.

## remove-operator

### Commands

Add:

```bash
sudo config --remove-operator --name USER --dry-run
sudo config --remove-operator --name USER --keep-home

sudo config remove-operator --name USER --dry-run
```

### Default behavior

The default is conservative:

```text
remove Linux user account only
keep /home/USER
keep config root
keep target env files
keep state
keep credentials
```

### Strong guardrails

remove-operator must:

```text
- refuse to remove the currently logged-in operator user
- refuse to remove vmuser unless --force-remove-operator is provided
- warn that removing the operator can break config orchestration
- avoid broad purge behavior
```

Do not implement:

```text
--remove-home
--purge-config-root
--purge-credentials
```

for operator in this milestone.

## Suggested helper design

Add small functions in `config.sh` rather than one large block.

Suggested names:

```text
config_remove_account_usage
config_remove_target_usage
config_remove_operator_usage
config_run_remove_account
config_print_remove_account_plan
config_apply_remove_account_plan
config_confirm_destructive_account_action
```

A shared `config_run_remove_account kind "$@"` can handle both target and operator, with stricter guardrails for operator.

## Expected dry-run output

For target removal:

```text
Remove target account plan:
  Linux user: aiengineer
  account kind: target
  home: /home/aiengineer
  target env: /home/vmuser/.local/etc/config-sh/targets/aiengineer.env

Planned actions:
  remove Linux user: yes
  remove home: no
  purge target env: no
  remove credentials: no
  remove state: no
```

For destructive target removal:

```text
Planned actions:
  remove Linux user: yes
  remove home: yes
  purge target env: yes
  remove credentials: yes, because they are under removed home
  remove state: yes, because it is under removed home
```

For operator removal:

```text
Remove operator account plan:
  Linux user: oldoperator
  account kind: operator

WARNING:
  Removing an operator can break config orchestration.

Planned actions:
  remove Linux user: yes
  remove home: no
  purge config root: no
  remove credentials: no
```

## Help updates

Update:

```text
config_usage
config_help_menu
config_account_usage
config_help all
```

Add topics:

```text
config help remove-target
config help remove-operator
```

Mention:

```text
config --create-target --profile PROFILE --name USER [--interactive|--non-interactive] [--expire-password]
config --remove-target --name USER [--dry-run] [--keep-home|--remove-home] [--purge-config]
config --remove-operator --name USER [--dry-run] [--keep-home] [--force-remove-operator]
```

## Validation

Syntax:

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

Non-destructive dry-runs:

```bash
sudo config --remove-target --name aiengineer --dry-run
sudo config remove-target --name researchscientist --dry-run
sudo config --remove-operator --name vmuser --dry-run
```

Expected:

```text
remove-target dry-runs show plan and do not delete anything
remove-operator vmuser without force refuses or warns clearly
syntax check passes
```

Check existing account creation still parses:

```bash
sudo config --create-target --profile AIEngineer --name aiengineer --dry-run
sudo config --create-target --profile AIEngineer --name aiengineer --dry-run --expire-password
```

## Acceptance criteria

- `--expire-password` is parsed for create-target/create-operator.
- chage is only run after a password exists or was just set.
- dry-run shows password policy.
- remove-target exists.
- remove-target is conservative by default.
- remove-target refuses vmuser/root/current operator path.
- remove-target does not delete credentials directly.
- remove-operator exists.
- remove-operator is highly guarded.
- help text includes lifecycle commands.
- syntax check passes.
- no broad bootstrap/install/mount/pull/push is run.
- no passwords or credential file contents are printed.

## Postcheck log

Create:

```text
/home/vmuser/.local/patches/AN2_00E_account_lifecycle_completion_postcheck.log
```

Include:

```text
changed files
syntax check result
dry-run results
password policy summary
remove-target summary
remove-operator guardrail summary
confirmation that no credential files were read or printed
confirmation that no broad bootstrap/install/mount/pull/push was run
```
