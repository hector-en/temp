# AN1 Target-User Config CLI Plan — Updated

Source package:
- latest `code_full_summary.txt`
- prior `AN1_target_user_config_cli_plan.md`
- AN1-01 through AN1-04 implementation/postcheck logs
- generated target-scoped bootstrap step execution brief, preserved here as a later usability milestone

## Goal

Implement a clean `config` CLI model that lets the administrative `vmuser` account configure another target account, such as `labuser`, without manually exporting `TARGET_USER` for every command.

Desired operator experience:

```bash
sudo config --target labuser status
sudo config --target labuser bootstrap
sudo config --target labuser install
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo config --target labuser rm install_dev_env_anaconda
sudo config --target labuser pull
sudo config --target labuser push
```

Aliases are also supported:

```bash
sudo config -t labuser bootstrap
sudo config --user labuser status
```

`--target USER` is a global option accepted before the subcommand.

## Updated planning note

The original AN1 plan was correct in direction:

1. Add target selection.
2. Refresh target context.
3. Make status/markers target-aware.
4. Make bootstrap/install target-aware.
5. Make pull/push target-aware.
6. Clarify mounts.
7. Add help, guards, smoke tests, runbook.

During implementation, we discovered two useful extra capabilities:

1. `bootstrap status` / `bootstrap plan`
   - Safe, non-destructive target-scoped inspection.
   - Lets the operator see what is done, skipped, failed, running, or pending before running bootstrap.

2. `bootstrap step STEP_NAME`
   - Safe, controlled single-step execution.
   - Lets the operator run or retry exactly one target-scoped bootstrap step without launching the whole chain.

These are worth keeping, but they should not replace the original AN1-05 pull/push milestone.

Therefore this updated plan preserves the original path and inserts the new usability work as dedicated bootstrap-control milestones.

## Current confirmed state

The current codebase has already moved significantly toward the AN1 model.

Confirmed by current code and postcheck logs:

- `/home/vmuser/.local/bin/config` is sudo-safe and execs `/home/vmuser/.local/bin/config.sh`.
- Global target options exist:
  - `--target USER`
  - `-t USER`
  - `--user USER`
- `config_set_target_user` exists.
- `config_refresh_session_context` exists.
- `config_default_smb_user_for_target` exists.
- `sudo config --target labuser status` resolves:
  - `TARGET_USER=labuser`
  - `TARGET_HOME=/home/labuser`
  - `CURRENT_HOME=/home/labuser`
  - `BASEDIR=/home/labuser/.local/wsl-mounts`
  - `STATE_DIR=/home/labuser/.local/state/config-sh`
  - `WSL_USER=labuser`
  - `SMB_USER=labuser`
- `sudo TARGET_USER=labuser config status` remains compatible.
- `sudo config --target labuser user --shell-command 'printf "%s\n" "$HOME"'` resolves `HOME=/home/labuser`.
- Target state directory and markers created under sudo are target-owned.
- `bootstrap status` and `bootstrap plan` exist and are non-destructive.

## Design principles

### 1. Target context is canonical

Target-user operations must derive from:

```text
TARGET_USER -> TARGET_HOME -> CURRENT_HOME, STATE_DIR, user shell commands, copy/push paths
```

When using:

```bash
sudo config --target labuser ...
```

the effective process user may be `root`, but the config target must remain `labuser`.

### 2. Admin/root runs orchestration; target user owns user state

`vmuser` or `root` orchestrates the run, but target-user data belongs to the target account.

Examples:

```text
/home/labuser/.local/state/config-sh
/home/labuser/.bashrc
/home/labuser/.pyenv
/home/labuser/anaconda3
/home/labuser/.dotnet/tools
```

must not silently become root-owned.

### 3. System installs remain system-wide

System-level operations remain system-wide:

```text
apt packages
Docker engine
Terraform binary/repo
kubectl/minikube binaries
SQL ODBC/sqlcmd packages
/etc config
/mnt mountpoints
```

But their marker state should still be target-scoped so the operator can know whether this target workflow has considered that step.

### 4. Inspection comes before execution

Before running a broad bootstrap, the operator should be able to inspect target-specific state:

```bash
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
```

This reduces accidental full installs and makes target administration safer.

### 5. Narrow execution is valuable

The generated target-scoped bootstrap step execution was a useful addition. It should remain in the plan as a later milestone:

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init
sudo config --target labuser install step install_dev_env_shell_init
```

But it should not replace pull/push as AN1-05.

## Updated backlog of AN1 correction briefs

| ID | Planned brief file | Status | Correction |
|---:|---|---|---|
| AN1-01 | `AN1_01_add_global_target_option.md` | Done | Add global `--target/-t/--user USER` parsing before command dispatch. |
| AN1-01A | `AN1_01A_sudo_safe_global_launcher.md` | Done | Make `/usr/local/bin/config` or the active config wrapper sudo-safe and independent of `$HOME`. |
| AN1-02 | `AN1_02_refresh_target_session_context.md` | Done | Centralize target and session context so sudo does not leak `/root`, `WSL_USER=root`, or `SMB_USER=root`. |
| AN1-03 | `AN1_03_target_owned_state_and_markers.md` | Done | Ensure target state directories and marker files are target-owned under sudo. |
| AN1-04 | `AN1_04_target_scoped_bootstrap_dispatch.md` | Done | Add safe target-scoped `bootstrap status/plan` and `install status/plan` inspection. |
| AN1-05 | `AN1_05_target_pull_push.md` | Next | Validate and harden target-aware `pull` and `push`. |
| AN1-06 | `AN1_06_target_mount_interactions.md` | Planned | Define target selection interaction with mounts, `WSL_USER`, SMB users, and `mounts.sh`. |
| AN1-07 | `AN1_07_target_bootstrap_install_execution.md` | Planned | Validate real target-aware bootstrap/install execution path without root/user context drift. |
| AN1-08 | `AN1_08_target_scoped_bootstrap_step.md` | Planned | Add controlled single-step execution: `bootstrap step STEP_NAME` and `install step STEP_NAME`. |
| AN1-09 | `AN1_09_target_cli_help_examples.md` | Planned | Update help text, examples, and aliases for target-user workflows. |
| AN1-10 | `AN1_10_target_cli_safety_guards.md` | Planned | Add guardrails for root, missing users, invalid usernames, accidental cross-target operations, and destructive commands. |
| AN1-11 | `AN1_11_target_cli_smoke_tests.md` | Planned | Add paste-ready smoke tests for `vmuser -> labuser` workflows. |
| AN1-12 | `AN1_12_target_cli_runbook.md` | Planned | Add final operator runbook. |

## AN1-01: Add global target option

### Scope

Add a small global-argument parser before the existing command dispatch.

### Desired CLI

```bash
config --target labuser status
config --target labuser bootstrap
config -t labuser skip install_dev_env_dotnet_tools
config --user labuser pull
```

### Definition of Done

- `config --target labuser status` is parsed as command `status`.
- `config -t labuser bootstrap` is parsed as command `bootstrap`.
- Existing `config status` behavior remains unchanged.
- Existing `sudo TARGET_USER=labuser config status` remains supported.
- Unknown options fail clearly.

## AN1-01A: Sudo-safe global launcher

### Scope

Ensure `sudo config ...` reaches the real implementation and does not resolve paths through `/root`.

### Desired wrapper

```bash
#!/usr/bin/env bash
exec /home/vmuser/.local/bin/config.sh "$@"
```

### Definition of Done

- `sudo config --target labuser status` reaches `/home/vmuser/.local/bin/config.sh`.
- The active wrapper does not use `$HOME`.
- The active wrapper does not look for `/root/.local/bin/config.sh`.
- The wrapper is executable and root-owned if installed under `/usr/local/bin`.

## AN1-02: Refresh target and session context

### Scope

Create one canonical target/session resolver.

### Required behavior

`config_set_target_user labuser` updates:

```bash
TARGET_USER=labuser
TARGET_HOME=/home/labuser
CURRENT_HOME=/home/labuser
BASEDIR=/home/labuser/.local/wsl-mounts
CONFIG_STATE_DIR=/home/labuser/.local/state/config-sh
STATE_DIR=/home/labuser/.local/state/config-sh
WSL_USER=labuser
SMB_USER=labuser
```

For `vmuser`, preserve:

```bash
SMB_USER=hector
```

### Definition of Done

- All target/session variables agree.
- `sudo config --target labuser status` does not report `/root`.
- `target_sudo`, `run_as_target`, append helpers, `CopyConfigFiles`, `PushConfigFiles`, and marker functions use the selected target.
- `config user --as USER ...` remains compatible.

## AN1-03: Target-owned state and markers

### Scope

Ensure `status`, `skip`, `unskip`, `rm`, and `run_once` marker handling are target-aware and target-owned.

### Required commands

```bash
sudo config --target labuser status
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo config --target labuser rm install_dev_env_anaconda
```

### Definition of Done

- `STATE_DIR` for labuser is `/home/labuser/.local/state/config-sh`.
- State directory is owned by `labuser:<primary group>`.
- `.done`, `.failed`, `.running`, `.skipped`, `.last.log`, and lock artifacts are not left root-owned where they are target-user state.
- `unskip` and `rm` operate on the selected target's state.

## AN1-04: Target-scoped bootstrap dispatch inspection

### Scope

Add safe inspection before broad bootstrap execution.

### Required commands

```bash
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser install status
sudo config --target labuser install plan
```

### Required behavior

These commands must show target-scoped bootstrap state without running:

```text
preflight
apt
installers
mounts
Docker
Kubernetes
SQL tooling
destructive cleanup
```

### Definition of Done

- `bootstrap status` and `bootstrap plan` print target-scoped step state.
- `install status` and `install plan` behave as aliases.
- Unknown bootstrap subcommands fail with exit code `2`.
- Plain `bootstrap` and `install` behavior remains unchanged.

## AN1-05: Target-aware pull and push

### Scope

Validate and harden `pull` and `push` as explicit target-account operations.

This is the next milestone.

### Desired paths

For `labuser`:

```text
pull source: /mnt/distrohome/.configfiles/labuser
pull target: /home/labuser

push source: /home/labuser
push target: /mnt/egress/labuser
```

### Required commands

```bash
sudo config --target labuser pull
sudo config --target labuser push
```

### Important current-code note

The current code already appears to use target-aware paths:

```bash
CopyConfigFiles:
  user_root="$distrohome/.configfiles/$TARGET_USER"
  root_home="${TARGET_HOME}"

PushConfigFiles:
  root_home="${TARGET_HOME}"
  target_root="$egress_root/$TARGET_USER"
```

So AN1-05 may be mostly validation plus small hardening.

### Risks to check

1. `config_run_pull` and `config_run_push` call `mounts_init_session_vars`.
   - Confirm this does not override target/session context incorrectly.
   - Confirm it does not reintroduce `root` or `vmuser` when targeting `labuser`.

2. `pull` must not accidentally copy from:
   - `/mnt/distrohome/.configfiles/vmuser`

3. `push` must not accidentally copy:
   - `/home/vmuser`
   - `/root`

4. Pull ownership must be correct:
   - files copied into `/home/labuser` should be owned by `labuser:<primary group>` where they are user-home files.

5. Push should be explicit about destination:
   - `/mnt/egress/labuser`

### Definition of Done

- `CopyConfigFiles` uses `$TARGET_USER` and `$TARGET_HOME`.
- `PushConfigFiles` uses `$TARGET_USER` and `$TARGET_HOME`.
- `sudo config --target labuser pull` reads from `/mnt/distrohome/.configfiles/labuser`.
- `sudo config --target labuser pull` writes to `/home/labuser`.
- User-home files written by pull are owned by `labuser:<primary group>`.
- `sudo config --target labuser push` reads from `/home/labuser`.
- `sudo config --target labuser push` writes to `/mnt/egress/labuser`.
- Neither command accidentally uses `/home/vmuser` or `/root` as the target home.
- If mounts are missing, error messages are clear and do not silently fall back to the wrong paths.

## AN1-06: Target and mounts interaction

### Scope

Define how `--target` interacts with `mounts.sh`.

### Design recommendation

Treat mounts as host/session-level operations, not purely target-user installs.

However, `pull` and `push` may depend on mount availability:

```text
/mnt/distrohome
/mnt/egress
```

### Required clarification

- `--target` controls user configuration and state.
- `mount` controls WSL/session mount points.
- `MOUNTS_*` and `SMB_USER_*` control SMB identity.
- `config --target labuser pull` should not unexpectedly rewrite SMB identity without explicit mount flags.
- `config --target labuser mount` should clearly show which mount identity it is using.

### Definition of Done

- `config --target labuser pull` works after mounts exist.
- If mounts are missing, error messages tell the operator to run `config mount` or `config mount --all`.
- `config --target labuser mount` does not silently mutate SMB identity in an unexpected way.
- Mount help distinguishes target user from mount/SMB user.

## AN1-07: Target-aware bootstrap/install execution

### Scope

Validate the actual execution path for:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```

### Rules

- System packages remain installed system-wide.
- User-level tools install under `TARGET_HOME`.
- Shell snippets are appended to `TARGET_HOME` dotfiles.
- pyenv and Anaconda install under `TARGET_HOME`.
- dotnet global tools run with `HOME=TARGET_HOME`.
- markers are written under `TARGET_HOME/.local/state/config-sh`.

### Definition of Done

- Broad bootstrap/install runs with the correct target context.
- User-level writes do not land under `/root` or `/home/vmuser` when targeting `labuser`.
- System-level package installs remain system-wide.
- Re-running bootstrap skips completed labuser steps.
- Logs and markers are target-scoped and target-owned.

## AN1-08: Target-scoped bootstrap step execution

### Scope

Preserve and implement the generated usability improvement:

```bash
sudo config --target labuser bootstrap step STEP_NAME
sudo config --target labuser install step STEP_NAME
```

This was originally generated as AN1-05, but in the updated plan it becomes AN1-08 so original pull/push AN1-05 is not lost.

### Desired commands

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init
sudo config --target labuser install step install_dev_env_shell_init
```

### Required design

Add a whitelist mapping from step names to existing functions.

Example:

```bash
config_bootstrap_step_function() {
  local step="${1:-}"

  case "$step" in
    update_apt) printf '%s\n' 'UpdateAPT' ;;
    standard_apps) printf '%s\n' 'StandardApps' ;;
    install_networking) printf '%s\n' 'InstallNetworking' ;;
    install_dev_env_system_packages) printf '%s\n' 'InstallDevEnvSystemPackages' ;;
    install_dev_env_shell_init) printf '%s\n' 'InstallDevEnvShellInit' ;;
    install_dev_env_dotnet_tools) printf '%s\n' 'InstallDevEnvDotnetTools' ;;
    install_dev_env_python_user_tools) printf '%s\n' 'InstallDevEnvPythonUserTools' ;;
    install_dev_env_pyenv) printf '%s\n' 'InstallDevEnvPyenv' ;;
    install_dev_env_anaconda) printf '%s\n' 'InstallDevEnvAnaconda' ;;
    install_dev_env_azure_cli) printf '%s\n' 'InstallDevEnvAzureCLI' ;;
    install_dev_env_verify) printf '%s\n' 'InstallDevEnvVerify' ;;
    install_gui_support) printf '%s\n' 'InstallGUISupport' ;;
    install_docker) printf '%s\n' 'InstallDocker' ;;
    install_terraform) printf '%s\n' 'InstallTerraform' ;;
    install_kubernets) printf '%s\n' 'InstallKubernetes' ;;
    install_minikube) printf '%s\n' 'InstallMinikube' ;;
    install_sqlserver_support_2004) printf '%s\n' 'InstallSQLServerSupport2004' ;;
    install_sqlserver_cli_tool_2204) printf '%s\n' 'InstallSQLServerCLITool2204' ;;
    *) return 1 ;;
  esac
}
```

Keep the existing `install_kubernets` marker spelling unless a later migration explicitly renames it.

### Definition of Done

- `bootstrap step STEP_NAME` runs exactly one whitelisted step through `run_once`.
- `install step STEP_NAME` works as an alias.
- Unknown steps fail clearly with exit code `2`.
- Extra arguments after the step name fail clearly with exit code `2`.
- Markers remain target-scoped and target-owned.
- `bootstrap status/plan` remain non-destructive.

## AN1-09: Help and examples

### Scope

Update help text and `.bash_aliases` examples.

### Required help examples

```text
sudo config --target labuser status
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser bootstrap
sudo config --target labuser bootstrap step install_dev_env_shell_init
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo config --target labuser rm install_dev_env_anaconda
sudo config --target labuser pull
sudo config --target labuser push
```

### Optional aliases

```bash
alias config-lab-status='sudo config --target labuser status'
alias config-lab-plan='sudo config --target labuser bootstrap plan'
alias config-lab-bootstrap='sudo config --target labuser bootstrap'
```

### Definition of Done

- `config help` documents global options before commands.
- `config help bootstrap` documents `status`, `plan`, and `step`.
- `config user help` remains separate and documents one-off command execution.
- Examples distinguish `--target` from `user --as`.

## AN1-10: Safety guards

### Scope

Prevent common operator mistakes.

### Guards

- Reject invalid usernames.
- Reject missing users.
- Warn when running target operations without sudo and the selected target differs from current user.
- Never default target to root merely because command was run with sudo.
- Show current effective target before destructive commands like `rm`.
- For `pull` and `push`, fail clearly if source/destination mounts are missing.
- For broad `bootstrap` / `install`, show the selected target before starting execution.

### Definition of Done

- `sudo config --target doesnotexist status` fails clearly.
- `config --target labuser bootstrap` without sufficient permissions fails early with a clear sudo/permission message.
- `sudo config rm STEP` without `--target` clearly shows which target is affected.
- `sudo config --target labuser rm STEP` prints target and marker paths before making changes.

## AN1-11: Smoke tests

### Scope

Create paste-ready smoke tests that avoid destructive package installs.

### Test examples

```bash
bash -n "$HOME/.local/bin/config.sh"
sudo config --target labuser status
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo test -f /home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo test ! -f /home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
sudo config --target labuser user --shell-command 'printf "%s\n" "$HOME"'
```

Optional after AN1-08:

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init
```

### Definition of Done

- Tests verify parser behavior, target context, state directory, ownership, and non-destructive user command execution.
- Tests avoid broad `bootstrap`, `install`, `apt`, `mount`, Docker, Kubernetes, and SQL installs unless explicitly testing those later.

## AN1-12: Final operator runbook

### Scope

Create a concise admin runbook.

### Required sections

- Configure a new user account.
- Inspect target bootstrap state.
- Run a safe single step.
- Skip a problematic step.
- Re-enable a skipped step.
- Remove one user-level install.
- Pull config from distrohome.
- Push config to egress.
- Check status and logs.
- Recover from failed markers or stale locks.
- Understand target user vs mount/SMB user.

### Definition of Done

The runbook should be sufficient for:

```bash
sudo config --target labuser pull
sudo config --target labuser bootstrap plan
sudo config --target labuser skip install_docker
sudo config --target labuser bootstrap
sudo config --target labuser status
sudo config --target labuser push
```

## Updated recommended implementation order

1. AN1-01 global parser.
2. AN1-01A sudo-safe launcher.
3. AN1-02 target/session context refresh.
4. AN1-03 target-owned state and markers.
5. AN1-04 bootstrap/install safe inspection.
6. AN1-05 target-aware pull/push.
7. AN1-06 mount interaction clarification and guards.
8. AN1-07 broad bootstrap/install execution validation.
9. AN1-08 target-scoped single bootstrap step execution.
10. AN1-09 help examples.
11. AN1-10 safety guards.
12. AN1-11 smoke tests.
13. AN1-12 final runbook.

## Full AN1 Definition of Done

AN1 is complete when all of these commands work predictably from `vmuser`:

```bash
sudo config --target labuser status
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo config --target labuser rm install_dev_env_anaconda
sudo config --target labuser pull
sudo config --target labuser push
sudo config --target labuser bootstrap
sudo config --target labuser install
sudo config --target labuser user --shell-command 'printf "%s\n" "$HOME"'
```

After AN1-08, this should also work:

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init
sudo config --target labuser install step install_dev_env_shell_init
```

And all of these are true:

- Target-specific state is under the selected target home.
- Target-specific state is target-owned.
- Target-specific user tools are installed under the selected target home.
- System package installs remain system-wide.
- Pull reads from `/mnt/distrohome/.configfiles/$TARGET_USER`.
- Pull writes to `$TARGET_HOME`.
- Push reads from `$TARGET_HOME`.
- Push writes to `/mnt/egress/$TARGET_USER`.
- The command output always makes the effective target visible before meaningful changes.
- Existing `TARGET_USER=labuser config ...` compatibility remains intact.
- Existing `config user --as labuser ...` behavior remains intact.
- Mount behavior is documented and does not unexpectedly confuse target identity with SMB identity.
