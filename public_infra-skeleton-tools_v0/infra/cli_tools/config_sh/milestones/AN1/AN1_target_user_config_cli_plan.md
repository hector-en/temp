# AN1 Target-User Config CLI Plan

Source package: latest uploaded `code_full_summary.txt`

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

Aliases may also be supported:

```bash
sudo config -t labuser bootstrap
sudo config --user labuser status
```

`--target USER` should be a global option accepted before the subcommand.

## Current-code observations

The latest codebase already has several required pieces:

- `TARGET_USER` and `TARGET_HOME` are resolved near the top of `config.sh`.
- State is already target-home based through `CONFIG_STATE_DIR="${TARGET_HOME}/.local/state/config-sh"`.
- `run_once` supports `done`, `failed`, `running`, `skipped`, lock files, and target metadata.
- `skip`, `unskip`, `rm`, `status`, `bootstrap/install`, `pull`, and `push` already exist as top-level commands.
- `config user --as USER ...` exists for one-off commands.
- The missing piece is a first-class global target selector that updates all target-dependent variables before command-specific logic runs.

## Design decision

Use one global option:

```bash
config --target USER COMMAND [ARGS...]
```

The option must:

1. Validate that `USER` exists.
2. Set `TARGET_USER`.
3. Resolve and set `TARGET_HOME`.
4. Refresh `CONFIG_STATE_DIR` and `STATE_DIR`.
5. Ensure target-user file operations, shell snippets, state markers, and copy/push paths point at the selected account.
6. Leave system-level package operations system-wide, while recording per-target step state where appropriate.

## Non-goals

This AN1 plan should not:

- Rewrite all installer functions.
- Add a package-manager abstraction.
- Remove existing `TARGET_USER=labuser config ...` compatibility.
- Replace `config user --as USER ...`; that remains useful for one-off commands.
- Change mount credential handling unless required for target selection.

## Backlog of AN1 correction briefs

| ID | Planned brief file | Story Points | Target duration | Correction |
|---:|---|---:|---:|---|
| AN1-01 | `AN1_01_add_global_target_option.md` | 1 | ~30 min | Add global `--target/-t/--user USER` parsing before command dispatch. |
| AN1-02 | `AN1_02_refresh_target_context.md` | 1 | ~30 min | Centralize target resolution in `config_set_target_user` and refresh derived paths/state. |
| AN1-03 | `AN1_03_target_status_and_markers.md` | 1 | ~30 min | Make `status`, `skip`, `unskip`, and `rm` explicitly target-aware. |
| AN1-04 | `AN1_04_target_bootstrap_install.md` | 1 | ~30 min | Ensure `bootstrap/install` run from vmuser/sudo but apply user-level work to the selected target. |
| AN1-05 | `AN1_05_target_pull_push.md` | 1 | ~30 min | Make `pull` and `push` target-aware for `/mnt/distrohome/.configfiles/$TARGET_USER` and `/mnt/egress/$TARGET_USER`. |
| AN1-06 | `AN1_06_target_mount_interactions.md` | 1 | ~30 min | Define target selection interaction with mounts, `WSL_USER`, SMB users, and `mounts.sh`. |
| AN1-07 | `AN1_07_target_cli_help_examples.md` | 1 | ~30 min | Update help text, examples, and aliases for target-user workflows. |
| AN1-08 | `AN1_08_target_cli_safety_guards.md` | 1 | ~30 min | Add guardrails for root, missing users, invalid usernames, and accidental self-targeting. |
| AN1-09 | `AN1_09_target_cli_smoke_tests.md` | 1 | ~30 min | Add paste-ready smoke tests for `vmuser -> labuser` workflows. |
| AN1-10 | `AN1_10_target_cli_runbook.md` | 1 | ~30 min | Add final usage runbook for administering `labuser` from `vmuser`. |

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

### Implementation notes

Add a function like:

```bash
config_parse_global_args() {
  CONFIG_TARGET_USER=""
  while (($#)); do
    case "$1" in
      --target|-t|--user)
        shift
        [[ -n "${1:-}" ]] || { echo "[ERROR] Missing value after --target" >&2; return 2; }
        CONFIG_TARGET_USER="$1"
        ;;
      --)
        shift
        break
        ;;
      -*)
        break
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ -n "$CONFIG_TARGET_USER" ]]; then
    config_set_target_user "$CONFIG_TARGET_USER" || return $?
  fi

  CONFIG_COMMAND="${1:-help}"
  shift || true
  CONFIG_COMMAND_ARGS=("$@")
}
```

Then dispatch using `CONFIG_COMMAND` and `CONFIG_COMMAND_ARGS`.

### Definition of Done

- `config --target labuser status` is parsed as command `status`.
- `config -t labuser bootstrap` is parsed as command `bootstrap`.
- Existing `config status` behavior remains unchanged.
- Existing `sudo TARGET_USER=labuser config status` remains supported.
- Unknown options still fail clearly.

## AN1-02: Refresh target context

### Scope

Create one canonical target resolver.

### Required behavior

`config_set_target_user labuser` must update:

```bash
TARGET_USER=labuser
TARGET_HOME=/home/labuser
CONFIG_STATE_DIR=/home/labuser/.local/state/config-sh
STATE_DIR=/home/labuser/.local/state/config-sh
```

### Implementation notes

Add or refactor:

```bash
config_resolve_home_for_user() {
  getent passwd "$1" | cut -d: -f6
}

config_set_target_user() {
  local user="$1"
  local home=""

  [[ "$user" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || {
    echo "[ERROR] Invalid target user: $user" >&2
    return 2
  }

  home="$(config_resolve_home_for_user "$user")"
  [[ -n "$home" && -d "$home" ]] || {
    echo "[ERROR] Could not resolve home for target user: $user" >&2
    return 1
  }

  TARGET_USER="$user"
  TARGET_HOME="$home"
  CONFIG_STATE_DIR="${TARGET_HOME}/.local/state/config-sh"
  STATE_DIR="$CONFIG_STATE_DIR"

  export TARGET_USER TARGET_HOME CONFIG_STATE_DIR STATE_DIR
}
```

### Definition of Done

- All target-dependent variables agree.
- `config_runtime_init` no longer accidentally resets state under `/root` or `/home/vmuser` when targeting `labuser`.
- `target_sudo`, `run_as_target`, append helpers, `CopyConfigFiles`, `PushConfigFiles`, and marker functions use the selected target.

## AN1-03: Target-aware status, skip, unskip, rm

### Scope

Make state commands visibly target-aware.

### Required commands

```bash
sudo config --target labuser status
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo config --target labuser rm install_dev_env_anaconda
```

### Definition of Done

- `skip` writes `/home/labuser/.local/state/config-sh/<step>.skipped`.
- `unskip` removes the marker from labuser's state dir.
- `rm` removes labuser's marker state and any user-level artifacts under `/home/labuser`.
- Commands print the selected target before making changes.

## AN1-04: Target-aware bootstrap/install

### Scope

Ensure `bootstrap` and `install` from `vmuser` configure the selected target user.

### Required commands

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```

### Rules

- System packages remain installed system-wide.
- User tools install under `TARGET_HOME`.
- Shell snippets are appended to `TARGET_HOME` dotfiles.
- pyenv and Anaconda install under `TARGET_HOME`.
- dotnet global tools run with `HOME=TARGET_HOME`.
- markers are written under `TARGET_HOME/.local/state/config-sh`.

### Definition of Done

- `sudo config --target labuser bootstrap` does not write per-user tools under `/root` or `/home/vmuser`.
- `config --target labuser status` shows labuser's markers.
- Re-running bootstrap skips completed labuser steps.

## AN1-05: Target-aware pull and push

### Scope

Make `pull` and `push` explicitly target-account operations.

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

### Definition of Done

- `CopyConfigFiles` uses `$TARGET_USER` and `$TARGET_HOME`.
- `PushConfigFiles` uses `$TARGET_USER` and `$TARGET_HOME`.
- File ownership after `pull` is `labuser:<labuser primary group>` for home files.
- `push` does not accidentally copy `/home/vmuser` when targeting `labuser`.

## AN1-06: Target and mounts interaction

### Scope

Define how `--target` interacts with `mounts.sh`.

### Design recommendation

Treat mounts as host/session-level operations, not strictly target-user installs. However, when `config --target labuser pull` needs `/mnt/distrohome`, it may call mount initialization using safe non-interactive defaults.

### Required clarification in code/help

- `--target` controls user configuration and state.
- `mount` controls WSL/session mount points.
- `MOUNTS_*` and `SMB_USER_*` still control SMB identity.
- `WSL_USER` should not silently become `labuser` just because `--target labuser` was selected, unless a specific mount flag requests that.

### Definition of Done

- `config --target labuser pull` works after mounts exist.
- If mounts are missing, error messages tell the operator to run `config mount` or `config mount --all`.
- `config --target labuser mount` does not unexpectedly rewrite SMB identities without explicit mount flags.

## AN1-07: Help and examples

### Scope

Update help text and `.bash_aliases` examples.

### Required help examples

```text
sudo config --target labuser status
sudo config --target labuser bootstrap
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo config --target labuser rm install_dev_env_anaconda
sudo config --target labuser pull
sudo config --target labuser push
```

### Optional aliases

```bash
alias config-lab-status='sudo config --target labuser status'
alias config-lab-bootstrap='sudo config --target labuser bootstrap'
```

### Definition of Done

- `config help` documents global options before commands.
- `config user help` remains separate and still documents one-off command execution.
- Examples distinguish `--target` from `user --as`.

## AN1-08: Safety guards

### Scope

Prevent common operator mistakes.

### Guards

- Reject invalid usernames.
- Reject missing users.
- Warn when running target operations without sudo and the selected target differs from current user.
- Never default target to root merely because command was run with sudo.
- Show current effective target before destructive commands like `rm`.

### Definition of Done

- `sudo config --target doesnotexist status` fails clearly.
- `config --target labuser bootstrap` without sufficient permissions fails early with a clear sudo message.
- `sudo config rm STEP` without `--target` clearly targets the sudo owner or current default target and prints it.

## AN1-09: Smoke tests

### Scope

Create paste-ready smoke tests that do not run destructive package installs.

### Test examples

```bash
bash -n "$HOME/.local/bin/config.sh"
sudo config --target labuser status
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo test -f /home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo test ! -f /home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
sudo config --target labuser user --shell-command 'printf "%s\n" "$HOME"'
```

### Definition of Done

- Tests verify parser behavior, target context, state directory, and non-destructive user command execution.
- Tests avoid `apt`, `mount`, Docker, Kubernetes, and SQL installs.

## AN1-10: Final operator runbook

### Scope

Create a concise admin runbook.

### Required sections

- Configure a new user account.
- Skip a problematic step.
- Re-enable a skipped step.
- Remove one user-level install.
- Pull config from distrohome.
- Push config to egress.
- Check status and logs.
- Recover from failed markers or stale locks.

### Definition of Done

The runbook should be sufficient for:

```bash
sudo config --target labuser pull
sudo config --target labuser skip install_docker
sudo config --target labuser bootstrap
sudo config --target labuser status
sudo config --target labuser push
```

## Recommended implementation order

1. AN1-01 global parser.
2. AN1-02 target context refresh.
3. AN1-03 state commands.
4. AN1-04 bootstrap/install.
5. AN1-05 pull/push.
6. AN1-06 mount interaction docs/guards.
7. AN1-07 help examples.
8. AN1-08 safety guards.
9. AN1-09 smoke tests.
10. AN1-10 final runbook.

## Full AN1 Definition of Done

AN1 is complete when all of these commands work predictably from `vmuser`:

```bash
sudo config --target labuser status
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo config --target labuser rm install_dev_env_anaconda
sudo config --target labuser pull
sudo config --target labuser push
sudo config --target labuser bootstrap
sudo config --target labuser install
```

And all of these are true:

- Target-specific state is under the selected target home.
- Target-specific user tools are installed under the selected target home.
- System package installs remain system-wide.
- The command output always makes the effective target visible.
- Existing `TARGET_USER=labuser config ...` compatibility remains intact.
- Existing `config user --as labuser ...` behavior remains intact.
