# AN1-01 — Add Global Target Option Parsing

## Purpose

Implement the first milestone of the AN1 target-user CLI work: add a small global-option parser so the `config` wrapper can accept a target user before the command.

The operator should be able to run commands like:

```bash
sudo config --target labuser status
sudo config -t labuser bootstrap
sudo config --user labuser skip install_dev_env_dotnet_tools
```

This milestone is intentionally narrow. It should add global parsing and minimal target selection only. Later AN1 milestones will harden target context, status/marker behavior, bootstrap behavior, pull/push behavior, mount interactions, safety guards, tests, and runbook docs.

## Source Context

Use this brief together with the latest uploaded `code_full_summary.txt` and the AN1 plan file `AN1_target_user_config_cli_plan.md`.

The current codebase already has these relevant structures:

- `/home/vmuser/.local/bin/config` is a thin wrapper that executes `$HOME/.local/bin/config.sh "$@"`.
- `/home/vmuser/.local/bin/config.sh` resolves `TARGET_USER` and `TARGET_HOME` near the top.
- `CONFIG_STATE_DIR` and `STATE_DIR` already default under `TARGET_HOME`.
- The existing command dispatch is near the bottom of `config.sh` and currently looks conceptually like:

```bash
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  cmd="${1:-help}"
  shift || true

  case "$cmd" in
    help|-h|--help)
      config_usage
      ;;
    preflight)
      config_run_preflight_checks
      ;;
    status)
      config_status
      ;;
    skip)
      ...
      ;;
    ...
  esac
fi
```

The missing piece is a global parser that runs before this dispatch and handles:

```bash
--target USER
-t USER
--user USER
--
```

## Milestone Scope

### In scope

Modify only `/home/vmuser/.local/bin/config.sh`.

Add a first-pass global parser before command dispatch.

Add a minimal target resolver/helper if needed by the parser.

Update the bottom dispatch to use parsed variables instead of directly consuming `$1` and `$@`.

Keep existing commands and behavior unchanged when no global target option is supplied.

### Out of scope

Do not rewrite installer functions.

Do not change `mounts.sh`.

Do not change `CopyConfigFiles` or `PushConfigFiles` behavior beyond whatever naturally follows from setting `TARGET_USER` and `TARGET_HOME`.

Do not redesign marker files.

Do not add destructive tests.

Do not add aliases yet.

Do not implement the full AN1-02 target-context refactor beyond the minimal helper needed for this parser to work.

## Required CLI Behavior

These commands must parse correctly:

```bash
config status
config --target labuser status
config -t labuser status
config --user labuser status
config --target labuser bootstrap
config -t labuser skip install_dev_env_dotnet_tools
config --user labuser pull
config --target labuser -- status
```

Existing environment-variable compatibility must remain:

```bash
TARGET_USER=labuser config status
sudo TARGET_USER=labuser config status
```

The global target option must be accepted only before the subcommand. This milestone does not need to support global options after the subcommand.

Good:

```bash
config --target labuser status
```

Not required in this milestone:

```bash
config status --target labuser
```

## Implementation Instructions

### 1. Add parser state variables

Near the existing CLI/helper section in `config.sh`, add globals similar to:

```bash
CONFIG_COMMAND=""
CONFIG_COMMAND_ARGS=()
CONFIG_TARGET_USER=""
```

These variables should be set by `config_parse_global_args`.

### 2. Add a minimal target resolver

Add a helper before command dispatch.

Suggested implementation:

```bash
config_resolve_home_for_user() {
  getent passwd "$1" | cut -d: -f6
}

config_apply_target_user() {
  local user="${1:-}"
  local home=""

  [[ -n "$user" ]] || {
    echo "[ERROR] Empty target user" >&2
    return 2
  }

  home="$(config_resolve_home_for_user "$user")"
  [[ -n "$home" ]] || {
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

Notes:

- Keep this helper small. AN1-02 will harden username validation and centralize the final target context model.
- Do not default to root just because the command is run with `sudo`.
- Preserve the current top-of-file `TARGET_USER` fallback behavior for no-option execution.

### 3. Add `config_parse_global_args`

Add this function before command dispatch:

```bash
config_parse_global_args() {
  CONFIG_COMMAND=""
  CONFIG_COMMAND_ARGS=()
  CONFIG_TARGET_USER=""

  while (($#)); do
    case "$1" in
      --target|-t|--user)
        shift
        [[ -n "${1:-}" ]] || {
          echo "[ERROR] Missing value after --target" >&2
          return 2
        }
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
    config_apply_target_user "$CONFIG_TARGET_USER" || return $?
  fi

  CONFIG_COMMAND="${1:-help}"
  shift || true
  CONFIG_COMMAND_ARGS=("$@")
}
```

Important behavior:

- `config --target labuser status` should leave `CONFIG_COMMAND=status`.
- `config -t labuser skip install_dev_env_dotnet_tools` should leave `CONFIG_COMMAND=skip` and `CONFIG_COMMAND_ARGS=(install_dev_env_dotnet_tools)`.
- `config --target labuser -- status` should parse as `status`.
- `config --target` should fail with exit code `2`.
- Unknown options before a command should still fail clearly through existing unknown-command behavior or explicit parser handling.

### 4. Update command dispatch

Replace the direct bottom-of-file dispatch setup:

```bash
cmd="${1:-help}"
shift || true
```

with:

```bash
config_parse_global_args "$@" || exit $?
cmd="$CONFIG_COMMAND"
set -- "${CONFIG_COMMAND_ARGS[@]}"
```

Then leave the existing `case "$cmd" in ... esac` structure mostly unchanged.

This allows the existing command implementations to keep using `$1`, `$@`, and the existing helper functions.

### 5. Update help text minimally

In `config_usage`, add a short global-options section before the command list:

```text
Usage: config.sh [global options] [command]

Global options:
  --target USER, -t USER, --user USER
                       Configure USER instead of the default TARGET_USER
```

Also add examples:

```text
Examples:
  sudo config --target labuser status
  sudo config --target labuser bootstrap
  sudo config -t labuser skip install_dev_env_dotnet_tools
```

Keep `config user help` separate. Do not blur `--target USER` with `config user --as USER`; the first selects the account being configured, the second runs one-off commands as a user.

## Expected Minimal Patch Shape

The patch should be small and centered around these areas:

1. A minimal target resolver/helper.
2. `config_parse_global_args`.
3. The bottom dispatch initialization.
4. `config_usage` text.

Do not touch unrelated installer internals.

## Acceptance Criteria

The following must be true after the patch:

```bash
bash -n "$HOME/.local/bin/config.sh"
```

passes.

```bash
config status
```

still works as before.

```bash
sudo config --target labuser status
```

prints a status using:

```text
TARGET_USER=labuser
TARGET_HOME=/home/labuser
STATE_DIR=/home/labuser/.local/state/config-sh
```

assuming `labuser` exists.

```bash
sudo config -t labuser status
```

works the same as `--target`.

```bash
sudo config --user labuser status
```

works the same as `--target`.

```bash
sudo config -t labuser skip install_dev_env_dotnet_tools
```

writes or attempts to write the skipped marker under:

```text
/home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
```

assuming permissions allow it.

```bash
sudo TARGET_USER=labuser config status
```

still works.

```bash
config --target
```

fails clearly with a message like:

```text
[ERROR] Missing value after --target
```

and exits nonzero, preferably exit code `2`.

Unknown commands still fail with exit code `2`.

## Non-Destructive Smoke Tests

Run these after patching. These tests should avoid package installs, mounts, Docker, Kubernetes, and SQL tooling.

```bash
set -euo pipefail

CONFIG_BIN="${HOME}/.local/bin/config.sh"

bash -n "$CONFIG_BIN"

bash --noprofile --norc "$CONFIG_BIN" help >/tmp/an1-01-help.out
grep -q -- "--target USER" /tmp/an1-01-help.out

bash --noprofile --norc "$CONFIG_BIN" status >/tmp/an1-01-status-default.out
grep -q '^TARGET_USER=' /tmp/an1-01-status-default.out
grep -q '^TARGET_HOME=' /tmp/an1-01-status-default.out
grep -q '^STATE_DIR=' /tmp/an1-01-status-default.out

if getent passwd labuser >/dev/null 2>&1; then
  sudo bash --noprofile --norc "$CONFIG_BIN" --target labuser status >/tmp/an1-01-status-target.out
  grep -q '^TARGET_USER=labuser$' /tmp/an1-01-status-target.out
  grep -q '^TARGET_HOME=/home/labuser$' /tmp/an1-01-status-target.out
  grep -q '^STATE_DIR=/home/labuser/.local/state/config-sh$' /tmp/an1-01-status-target.out

  sudo bash --noprofile --norc "$CONFIG_BIN" -t labuser status >/tmp/an1-01-status-short.out
  grep -q '^TARGET_USER=labuser$' /tmp/an1-01-status-short.out

  sudo bash --noprofile --norc "$CONFIG_BIN" --user labuser status >/tmp/an1-01-status-user-alias.out
  grep -q '^TARGET_USER=labuser$' /tmp/an1-01-status-user-alias.out
else
  echo "[SKIP] labuser does not exist on this test host"
fi

set +e
bash --noprofile --norc "$CONFIG_BIN" --target >/tmp/an1-01-missing-target.out 2>/tmp/an1-01-missing-target.err
rc=$?
set -e
test "$rc" -ne 0
grep -q "Missing value" /tmp/an1-01-missing-target.err
```

Optional parser smoke test with a harmless marker operation:

```bash
if getent passwd labuser >/dev/null 2>&1; then
  sudo bash --noprofile --norc "$CONFIG_BIN" -t labuser skip install_dev_env_dotnet_tools
  sudo test -f /home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
  sudo bash --noprofile --norc "$CONFIG_BIN" -t labuser unskip install_dev_env_dotnet_tools
  sudo test ! -f /home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
fi
```

## Codex Prompt

Use the following as the exact instruction to Codex:

```text
Implement milestone AN1-01 only.

You are given the current codebase summary in code_full_summary.txt and this milestone brief.

Modify only /home/vmuser/.local/bin/config.sh.

Goal: add global option parsing so config accepts --target USER, -t USER, and --user USER before the subcommand. The parser must run before the existing command dispatch. It must set TARGET_USER, TARGET_HOME, CONFIG_STATE_DIR, and STATE_DIR for the selected target, then dispatch the existing command unchanged.

Keep this patch small. Do not rewrite installers, mounts, CopyConfigFiles, PushConfigFiles, run_once, or marker logic. Do not implement later AN1 milestones.

Preserve existing behavior for config status and TARGET_USER=labuser config status.

Update config_usage with the new global options and examples.

After patching, run the non-destructive smoke tests from this brief and report the results.
```

## Definition of Done

AN1-01 is complete when Codex provides a minimal patch that:

- Adds a global parser for `--target`, `-t`, and `--user`.
- Applies the selected target before command dispatch.
- Keeps existing commands working without `--target`.
- Keeps existing `TARGET_USER=... config ...` compatibility working.
- Updates help text.
- Passes syntax and non-destructive parser/status smoke tests.
