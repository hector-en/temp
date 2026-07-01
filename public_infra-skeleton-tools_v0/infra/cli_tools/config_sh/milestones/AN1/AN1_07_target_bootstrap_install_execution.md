# AN1-07 — Target-Aware Bootstrap/Install Execution

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Validate and harden the real execution path for:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```

The goal is not to redesign bootstrap. The goal is to prove and guard that broad execution keeps target/user/system boundaries correct.

## Core rules

```text
root/sudo:
  orchestrates system-level operations

TARGET_USER:
  owns target home files, state, markers, user tools, and user shell config

system installs:
  remain system-wide

target-user installs:
  must land under TARGET_HOME, not /root or /home/vmuser
```

For `labuser`:

```text
TARGET_USER=labuser
TARGET_HOME=/home/labuser
STATE_DIR=/home/labuser/.local/state/config-sh
```

## Scope

Edit only what is needed, primarily:

```text
/home/vmuser/.local/bin/config.sh
```

Possibly inspect but avoid changing unless needed:

```text
/home/vmuser/.local/bin/mounts.sh
```

Do not run the full broad bootstrap during validation unless the operator explicitly intends it.

Do not run live package installers during postcheck unless they are already safely skipped by markers.

Avoid live:

```text
apt
docker
terraform
kubectl
minikube
sqlcmd
anaconda download/install
pyenv install
```

## Current behavior to preserve

- `bootstrap status` and `bootstrap plan` are non-destructive.
- `install` aliases `bootstrap`.
- `run_once` is target-scoped and target-owned.
- Target user helpers exist:
  - `target_sudo`
  - `run_as_target`
  - `run_as_target_shell`
  - `append_once_target`
  - `append_block_once_target`
- Pull/push behavior from AN1-05/05A/05B remains intact.

## Required work

### 1. Add execution context banner

Before broad bootstrap/install execution starts, print the selected target clearly.

In `config_run_bootstrap_execute`, before preflight or first `run_once`, print:

```text
Bootstrap execution context:
  TARGET_USER=labuser
  TARGET_HOME=/home/labuser
  STATE_DIR=/home/labuser/.local/state/config-sh
  CURRENT_HOME=/home/labuser
```

Add helper if useful:

```bash
config_print_bootstrap_execution_context() {
  echo "Bootstrap execution context:"
  printf "  TARGET_USER=%s\n" "$TARGET_USER"
  printf "  TARGET_HOME=%s\n" "$TARGET_HOME"
  printf "  STATE_DIR=%s\n" "$STATE_DIR"
  printf "  CURRENT_HOME=%s\n" "$CURRENT_HOME"
}
```

### 2. Add sudo guard for broad bootstrap/install

Broad bootstrap/install must require sudo, because it can install system packages and edit `/etc`.

Add:

```bash
config_require_sudo_for_bootstrap() {
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "[ERROR] config bootstrap/install requires sudo." >&2
    echo "[INFO] Re-run as: sudo config --target ${TARGET_USER} bootstrap" >&2
    return 1
  fi
}
```

Call it only for execution, not for status/plan/help.

Required:

```bash
config --target labuser bootstrap
```

fails early with a clear sudo message.

Allowed without sudo if permissions allow reading state:

```bash
config --target labuser bootstrap status
config --target labuser bootstrap plan
config --target labuser install status
config --target labuser install plan
```

If status/plan need target state creation and fail due to permissions, keep error clear; do not force broad execution.

### 3. Audit target-user writes

Check existing bootstrap functions and fix only obvious target drift.

Target-user writes must use:

```bash
TARGET_HOME
append_once_target
append_block_once_target
run_as_target
run_as_target_shell
target_sudo
```

Watch especially:

```text
InstallDevEnvShellInit
InstallDevEnvDotnetTools
InstallDevEnvPythonUserTools
InstallDevEnvPyenv
InstallDevEnvAnaconda
InstallDevEnvVerify
InstallGUISupport
InstallSQLServerSupport2004
InstallSQLServerCLITool2204
InstallDocker group assignment
```

Do not rewrite whole functions unless needed.

### 4. Fix any obvious current helper bug

Inspect calls to `append_once_target`.

Correct signature is:

```bash
append_once_target FILE LINE
```

If any call has arguments reversed, fix it.

Known pattern to check:

```bash
append_once_target 'export PATH="$PATH:/opt/mssql-tools18/bin"' "$TARGET_HOME/.bashrc"
```

should be:

```bash
append_once_target "$TARGET_HOME/.bashrc" 'export PATH="$PATH:/opt/mssql-tools18/bin"'
```

### 5. Add safe execution dry-check support if minimal

If easy and low-risk, add a lightweight pre-execution validation helper:

```bash
config_bootstrap_validate_target_context() {
  [[ -n "$TARGET_USER" && -n "$TARGET_HOME" && "$TARGET_HOME" != "/root" ]] || {
    echo "[ERROR] Invalid target context for bootstrap" >&2
    return 1
  }

  [[ -d "$TARGET_HOME" ]] || {
    echo "[ERROR] TARGET_HOME does not exist: $TARGET_HOME" >&2
    return 1
  }
}
```

Call it before broad execution.

Do not add a full dry-run system in this milestone.

## Acceptance

- `sudo config --target labuser bootstrap status` remains non-destructive.
- `sudo config --target labuser bootstrap plan` remains non-destructive.
- `sudo config --target labuser install status` remains non-destructive.
- `sudo config --target labuser install plan` remains non-destructive.
- `config --target labuser bootstrap` without sudo fails before preflight/install steps.
- `sudo config --target labuser bootstrap` prints execution context before preflight or first step.
- Execution context does not show `/root`.
- Execution context does not show `/home/vmuser` when target is `labuser`.
- User-level functions reference `TARGET_HOME`, not hard-coded `/home/vmuser`.
- Target-user command execution uses `run_as_target*` / `target_sudo`.
- Shell append helpers write into target dotfiles.
- Marker state remains under `$TARGET_HOME/.local/state/config-sh`.
- AN1-05/05A/05B pull/push behavior still passes.
- AN1-06 mount context behavior still passes if already implemented.
- No live broad package installs are required for validation.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_07_target_bootstrap_install_execution_postcheck.log
```

Use simple evidence-log style:

```text
AN1-07 target-aware bootstrap/install execution postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_print_bootstrap_execution_context found: yes
config_require_sudo_for_bootstrap found: yes
config_bootstrap_validate_target_context found: yes/no
Result: PASS

[3] Non-destructive inspection
Command attempted:
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser install status
sudo config --target labuser install plan

Observed:
- Commands showed target-scoped state/plan.
- No bootstrap/install/package/mount execution occurred.

Result: PASS

[4] Non-sudo broad execution guard
Command attempted:
config --target labuser bootstrap

Observed:
- Command failed before preflight/install steps.
- Error said bootstrap/install requires sudo.
- Suggested sudo config --target labuser bootstrap.

Result: PASS

[5] Execution context banner
Command attempted:
sudo config --target labuser bootstrap <safe/stubbed/marker-skipped validation if available>

Observed:
- Bootstrap execution context printed before preflight or first run_once step.
- TARGET_USER=labuser
- TARGET_HOME=/home/labuser
- STATE_DIR=/home/labuser/.local/state/config-sh
- No /root drift.
- No /home/vmuser target-home drift.

Result: PASS or SKIP
Reason if SKIP: broad bootstrap intentionally not run.

[6] Target-user write audit
Observed:
- Shell init writes use TARGET_HOME and append_once_target/append_block_once_target.
- User tool commands use run_as_target_shell/target_sudo.
- append_once_target argument order checked.
- No hard-coded /home/vmuser user write found in bootstrap target-user functions.

Result: PASS

[7] Marker ownership/context
Observed:
- run_once still creates target-scoped markers under /home/labuser/.local/state/config-sh.
- Markers/logs are target-owned.

Result: PASS

[8] Pull/push regression
config --target labuser push without sudo blocked: yes
sudo config --target labuser push uses user-only manifest: yes or SKIP
sudo config --target vmuser push includes system manifest: yes or SKIP
Result: PASS or SKIP
Reason if SKIP: live fixture/mount intentionally not run.

[9] Mount regression
sudo config --target labuser mount help works: yes
Mount context helper exists if AN1-06 applied: yes
Result: PASS or SKIP

Overall
- Broad bootstrap/install execution has explicit target context.
- Non-sudo broad execution is blocked.
- Target-user writes remain target-scoped.
- System installs remain system-wide.
- No root/user context drift was found.
- No unintended package/mount/bootstrap work was run during validation.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

sudo config --target labuser status
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser install status
sudo config --target labuser install plan

config --target labuser bootstrap
```

Only run broad execution if the operator explicitly intends it and current markers/skips make it safe:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```
