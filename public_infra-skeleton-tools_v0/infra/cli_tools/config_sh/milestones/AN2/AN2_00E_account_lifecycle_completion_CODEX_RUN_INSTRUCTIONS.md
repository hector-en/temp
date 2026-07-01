# AN2-00E — Account Lifecycle Completion — Codex Run Instructions

Use this file as the short instruction file you give to Codex.

Pair it with:

```text
AN2_00E_account_lifecycle_completion_SPEC.md
```

Codex should read the spec file for implementation details, but each run should execute only one small task.

## Stable context pack

```text
You are working in /home/vmuser/.local.

Current codebase status:
- /home/vmuser/.local/bin/config.sh is the CLI, account/profile, target policy, bootstrap, and state engine.
- /home/vmuser/.local/lib/config-sh/installers.sh contains trusted installer functions.
- /home/vmuser/.local/bin/create-cifs-credentials-files.sh creates SMB credential files.
- /home/vmuser/.local/bin/mounts.sh implements mount behavior.
- /home/vmuser/.local/etc/config-sh/accounts/profiles.tsv is the account profile source of truth.
- /home/vmuser/.local/etc/config-sh/accounts/smb-profiles.tsv is the SMB profile source of truth.
- /home/vmuser/.local/etc/config-sh/accounts/mount-profiles.tsv is the mount profile source of truth.
- /home/vmuser/.local/etc/config-sh/targets/USER.env is generated/reconciled target policy.
- /home/USER/.local/state/config-sh is target-owned runtime state.
- /home/USER/.local/share/wsl-mounts contains target-owned SMB credential files.

Already implemented:
- create-target/create-operator profile resolution exists.
- account profile, SMB profile, and mount profile readers exist.
- target env reconciliation exists.
- target env files are restored to operator owner/group and mode 600.
- targets directory is restored to operator owner/group and mode 700.
- interactive account creation can ask whether to run passwd USER after creating a new user.
- non-interactive account creation prints the later sudo passwd USER command.
- credentials helper supports per-share files including research and publish.

Remaining AN2-00E scope:
- make password policy explicit in dry-run/help and optionally support first-login expiry.
- add conservative remove-target.
- add highly guarded remove-operator.
- do not touch AN2-01 role installers.
- do not touch AN2-02 Python env profile work.
- do not change SMB credentials content.
- do not print passwords.
- do not read credential files.
- do not run broad bootstrap/install/mount/pull/push.

Safety:
- Use targeted inspection only.
- Do not print full file contents.
- Make the smallest safe change for the selected task.
- Preserve existing behavior unless this spec explicitly changes it.
- Stop before deleting credential files, research data, unpublished datasets, private PKM/vault content, or manuscript text.

Output rules:
- At the end, summarize changed files and tests run.
- Do not paste full source files.
- Use exact shell commands for validation.

Expected final answer format:
Changed files:
- path/to/file

Tests run:
- command

Notes:
- one or two short bullets

Task:
```

## Tasks

### Task 1 — Complete explicit password policy

```text
Read /home/vmuser/.local/bin/config.sh.

Make the smallest safe change to complete explicit account password policy.

Current behavior already includes an interactive passwd prompt after a newly-created user.

Requirements:
- Keep existing interactive prompt behavior.
- Keep existing non-interactive no-prompt behavior.
- Add --expire-password support to create-target/create-operator.
- If password was set during interactive creation and --expire-password was provided, run:
  chage -d 0 USER
- If password was not set, do not run chage blindly.
- Print:
  Password was not set, so first-login expiry was not applied.
  Set the password first:
    sudo passwd USER
  Then expire it:
    sudo chage -d 0 USER
- Update dry-run output to show:
  password policy:
    password prompt: interactive only
    non-interactive: no prompt
    expire at first login: yes/no
- Update help text for create-target/create-operator.
- Do not accept password values on the command line.
- Do not print password values.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

### Task 2 — Add conservative remove-target

```text
Read /home/vmuser/.local/bin/config.sh.

Add a conservative remove-target command.

Desired commands:
  sudo config --remove-target --name USER --dry-run
  sudo config --remove-target --name USER --keep-home
  sudo config --remove-target --name USER --remove-home
  sudo config --remove-target --name USER --purge-config
  sudo config remove-target --name USER --dry-run

Requirements:
- Default behavior removes only the Linux user account.
- Default keeps /home/USER.
- Default keeps /home/vmuser/.local/etc/config-sh/targets/USER.env.
- Default keeps /home/USER/.local/state/config-sh.
- Default keeps /home/USER/.local/share/wsl-mounts/*.credentials.
- --keep-home is the default and may be explicit.
- --remove-home removes /home/USER only after confirmation unless --non-interactive is explicit.
- --purge-config removes /home/vmuser/.local/etc/config-sh/targets/USER.env only after confirmation unless --non-interactive is explicit.
- Do not delete credential files in this task.
- Refuse to remove vmuser through remove-target.
- Refuse to remove the currently active target if it is the operator account.
- Add help text.
- Add command dispatch entries for --remove-target and remove-target.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

### Task 3 — Add guarded remove-operator

```text
Read /home/vmuser/.local/bin/config.sh.

Add a highly guarded remove-operator command.

Desired commands:
  sudo config --remove-operator --name USER --dry-run
  sudo config --remove-operator --name USER --keep-home
  sudo config remove-operator --name USER --dry-run

Requirements:
- This command must be intentionally harder to use than remove-target.
- Refuse to remove the currently logged-in operator user.
- Refuse to remove vmuser unless --force-remove-operator is provided.
- Default keeps home, config root, target envs, state, and credentials.
- Do not implement broad purge behavior for operator.
- Print a clear warning that removing the operator can break orchestration.
- Do not delete credential files.
- Add help text.
- Add command dispatch entries for --remove-operator and remove-operator.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

### Task 4 — Add account lifecycle status/help polish

```text
Read /home/vmuser/.local/bin/config.sh.

Polish account lifecycle help and status output only.

Requirements:
- Add help topic:
  config help remove-target
  config help remove-operator
- Include examples for:
  create-target
  create-operator
  remove-target
  remove-operator
  --expire-password
- Ensure config help account summarizes create and remove lifecycle.
- Ensure dry-run output for remove-target/remove-operator is clear and non-destructive.
- Do not change execution behavior except help/status text.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

## Recommended execution order

Run the tasks in this order:

```text
Task 1
Task 2
Task 3
Task 4
```

Commit after each task if the tests pass.

Suggested commit messages:

```bash
git commit -m "feat: add first-login password expiry policy"
git commit -m "feat: add conservative target account removal"
git commit -m "feat: add guarded operator account removal"
git commit -m "docs: clarify account lifecycle help"
```
