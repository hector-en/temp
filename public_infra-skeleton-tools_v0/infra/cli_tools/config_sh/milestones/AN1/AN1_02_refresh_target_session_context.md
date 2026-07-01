# AN1-02 — Centralize Target and Session Context

Source files to provide with this brief:
- `code_full_summary.txt`
- `AN1_target_user_config_cli_plan.md`
- The implemented AN1-01 patch
- The AN1-01A sudo-safe launcher fix, if tracked separately

## Milestone goal

Centralize both target-user context and session context so `sudo config --target USER ...` behaves like an admin-controlled configuration run for `USER`, not like a root-user configuration run with only `TARGET_USER` changed.

AN1-01 proved that the global target parser works. The latest observed status output shows the remaining problem:

```text
sudo config --target labuser status

TARGET_USER=labuser
TARGET_HOME=/home/labuser
CURRENT_HOME=/root
BASEDIR=/root/.local/wsl-mounts
STATE_DIR=/home/labuser/.local/state/config-sh
WSL_USER=root
SMB_USER=root
```

The target fields are correct, but session-derived fields are still root-based because the command is executed through `sudo`.

After this milestone, the same command should resolve all target/session fields coherently:

```text
TARGET_USER=labuser
TARGET_HOME=/home/labuser
CURRENT_HOME=/home/labuser
BASEDIR=/home/labuser/.local/wsl-mounts
STATE_DIR=/home/labuser/.local/state/config-sh
WSL_USER=labuser
SMB_USER=labuser
```

For `vmuser`, the existing SMB mapping should remain:

```text
TARGET_USER=vmuser
TARGET_HOME=/home/vmuser
CURRENT_HOME=/home/vmuser
BASEDIR=/home/vmuser/.local/wsl-mounts
STATE_DIR=/home/vmuser/.local/state/config-sh
WSL_USER=vmuser
SMB_USER=hector
```

## Why this milestone exists

`sudo config --target labuser status` now starts correctly and applies `TARGET_USER=labuser`, but some values are still initialized from root process state:

- `CURRENT_HOME=/root`
- `BASEDIR=/root/.local/wsl-mounts`
- `WSL_USER=root`
- `SMB_USER=root`

Those values are unsafe for target-user administration. They would make mount/session files land under `/root` and can cause target-user operations to use the wrong SMB identity.

This milestone must fix that by making target context the source of truth for config-managed session variables.

## Current-code context

`config.sh` currently sets target fields near the top:

```bash
if [[ "$(id -u)" -ne 0 ]]; then
  TARGET_USER="$(id -un)"
else
  TARGET_USER="${TARGET_USER:-${SUDO_USER:-vmuser}}"
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
export TARGET_USER TARGET_HOME
```

AN1-01 added:

```bash
config_parse_global_args
config_apply_target_user
```

and global options:

```bash
--target USER
-t USER
--user USER
```

`mounts.sh` currently initializes session fields when sourced:

```bash
CURRENT_HOME="${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}"
BASEDIR="${CURRENT_HOME}/.local/wsl-mounts"
LOCAL_WSL_USER="${WSL_USER:-$(whoami)}"
WSL_USER="$LOCAL_WSL_USER"
SMB_USER="${SMB_USER:-$LOCAL_WSL_USER}"

case "$LOCAL_WSL_USER" in
  vmuser) SMB_USER="hector" ;;
esac
```

Under `sudo`, this makes session context root-based. AN1-02 must correct this.

## Scope

Implement AN1-02 only.

In scope:

1. Add canonical target resolver/setter helpers.
2. Add canonical session-context refresh helper.
3. Ensure target changes refresh:
   - `TARGET_USER`
   - `TARGET_HOME`
   - `CURRENT_HOME`
   - `BASEDIR`
   - `CONFIG_STATE_DIR`
   - `STATE_DIR`
   - `WSL_USER`
   - `SMB_USER`
   - `SMB_USER_INGRESS`
   - `SMB_USER_EGRESS`
4. Ensure `sudo config --target labuser status` no longer reports root session values.
5. Ensure `config --target vmuser status` keeps vmuser/hector behavior.
6. Keep `config user --as USER ...` behavior intact.
7. Keep AN1-01 parser behavior intact.
8. Keep `/usr/local/bin/config` launcher behavior intact if already implemented.

Out of scope:

- Do not rewrite bootstrap/install logic.
- Do not run package installs.
- Do not run mounts.
- Do not change SMB credential-file creation.
- Do not change CopyConfigFiles or PushConfigFiles beyond using corrected context values.
- Do not remove `config user --as`.
- Do not copy or chown vmuser config files to labuser as a substitute for target context.

## Required architecture

Target context must become the source of truth.

For config-managed commands:

```text
TARGET_USER -> TARGET_HOME -> CURRENT_HOME, BASEDIR, STATE_DIR, WSL_USER, SMB_USER
```

Do not derive config-managed session identity from `whoami` after the target is selected.

Under `sudo`, `whoami` may be `root`. That should not cause config to use root as the target/session user.

## Required helper functions

Add or refactor toward these helpers in `config.sh`.

### 1. Home resolver

```bash
config_resolve_home_for_user() {
  local user="${1:-}"
  [[ -n "$user" ]] || return 2
  getent passwd "$user" | cut -d: -f6
}
```

### 2. SMB user mapping

```bash
config_default_smb_user_for_target() {
  local user="${1:-}"

  case "$user" in
    vmuser) printf '%s\n' 'hector' ;;
    labuser) printf '%s\n' 'labuser' ;;
    *) printf '%s\n' "$user" ;;
  esac
}
```

This preserves existing behavior where `vmuser` maps to SMB user `hector`.

### 3. Session context refresh

```bash
config_refresh_session_context() {
  CURRENT_HOME="$TARGET_HOME"
  BASEDIR="${CURRENT_HOME}/.local/wsl-mounts"

  CONFIG_STATE_DIR="${TARGET_HOME}/.local/state/config-sh"
  STATE_DIR="$CONFIG_STATE_DIR"

  WSL_USER="$TARGET_USER"
  SMB_USER="${SMB_USER_OVERRIDE:-$(config_default_smb_user_for_target "$TARGET_USER")}"
  SMB_USER_INGRESS="${SMB_USER_INGRESS_OVERRIDE:-labuser}"
  SMB_USER_EGRESS="${SMB_USER_EGRESS_OVERRIDE:-labuser}"

  export CURRENT_HOME BASEDIR
  export CONFIG_STATE_DIR STATE_DIR
  export WSL_USER SMB_USER SMB_USER_INGRESS SMB_USER_EGRESS
}
```

Important: preserve a deliberate SMB override, but avoid accidentally preserving `SMB_USER=root` from `sudo`.

A safe approach is to use explicit override names for this milestone:

```text
SMB_USER_OVERRIDE
SMB_USER_INGRESS_OVERRIDE
SMB_USER_EGRESS_OVERRIDE
```

and document that ordinary `SMB_USER` is recomputed from target context.

### 4. Canonical target setter

Replace the AN1-01 `config_apply_target_user` helper with or wrap it around:

```bash
config_set_target_user() {
  local user="${1:-}"
  local home=""

  [[ -n "$user" ]] || {
    echo "[ERROR] Missing target user" >&2
    return 2
  }

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
  export TARGET_USER TARGET_HOME

  config_refresh_session_context
}
```

For compatibility, it is acceptable to keep `config_apply_target_user` as a wrapper:

```bash
config_apply_target_user() {
  config_set_target_user "$@"
}
```

## Required initial target setup

Replace the initial target setup with:

```bash
if [[ "$(id -u)" -ne 0 ]]; then
  CONFIG_INITIAL_TARGET_USER="${TARGET_USER:-$(id -un)}"
else
  CONFIG_INITIAL_TARGET_USER="${TARGET_USER:-${SUDO_USER:-vmuser}}"
fi

config_set_target_user "$CONFIG_INITIAL_TARGET_USER" || {
  rc=$?
  return "$rc" 2>/dev/null || exit "$rc"
}
```

This preserves existing defaults:

- Normal `config status` as `vmuser` targets `vmuser`.
- `sudo config status` targets `vmuser` through `SUDO_USER`.
- `sudo TARGET_USER=labuser config status` targets `labuser`.
- `sudo config --target labuser status` targets `labuser`.

## Required parser integration

If AN1-01 currently calls:

```bash
config_apply_target_user "$CONFIG_TARGET_USER"
```

replace or wrap it so the parser ultimately calls:

```bash
config_set_target_user "$CONFIG_TARGET_USER"
```

The parser must not duplicate target-home or session-context logic.

## Required mounts.sh adjustment

`mounts.sh` must not permanently lock root-derived values when it is sourced by `config.sh`.

Acceptable minimal fix:

1. Keep `mounts.sh` source-safe.
2. Modify its top-level defaults to respect pre-exported config context:

```bash
CURRENT_HOME="${CURRENT_HOME:-${TARGET_HOME:-${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}}}"
BASEDIR="${BASEDIR:-${CURRENT_HOME}/.local/wsl-mounts}"

LOCAL_WSL_USER="${WSL_USER:-${TARGET_USER:-$(whoami)}}"
WSL_USER="$LOCAL_WSL_USER"
SMB_USER="${SMB_USER:-$(case "$LOCAL_WSL_USER" in vmuser) echo hector ;; labuser) echo labuser ;; *) echo "$LOCAL_WSL_USER" ;; esac)}"
```

Better fix:

- Move root/session derivation into a `mounts_refresh_session_context` or make `mounts_init_session_vars` respect the already-exported config context.
- Ensure `config_refresh_session_context` is called after sourcing `mounts.sh` and after every target change.

Do not run mounts as part of validation.

## Required status output behavior

After implementation:

### Default vmuser

```bash
config --target vmuser status
```

Expected:

```text
TARGET_USER=vmuser
TARGET_HOME=/home/vmuser
CURRENT_HOME=/home/vmuser
BASEDIR=/home/vmuser/.local/wsl-mounts
STATE_DIR=/home/vmuser/.local/state/config-sh
WSL_USER=vmuser
SMB_USER=hector
```

### Target labuser under sudo

```bash
sudo config --target labuser status
```

Expected:

```text
TARGET_USER=labuser
TARGET_HOME=/home/labuser
CURRENT_HOME=/home/labuser
BASEDIR=/home/labuser/.local/wsl-mounts
STATE_DIR=/home/labuser/.local/state/config-sh
WSL_USER=labuser
SMB_USER=labuser
```

### Target labuser without sudo

```bash
config --target labuser status
```

Acceptable result:

```text
permission denied creating /home/labuser/.local/state/config-sh
```

This is acceptable because non-root `vmuser` should not be expected to manage `/home/labuser`.

## Acceptance criteria

AN1-02 is complete when all of these are true:

- `config_set_target_user` exists.
- `config_refresh_session_context` exists.
- `config_default_smb_user_for_target` exists.
- Initial target setup uses `config_set_target_user`.
- AN1-01 global parser ultimately uses `config_set_target_user`.
- `TARGET_USER`, `TARGET_HOME`, `CURRENT_HOME`, `BASEDIR`, `CONFIG_STATE_DIR`, `STATE_DIR`, `WSL_USER`, and `SMB_USER` refresh together.
- `sudo config --target labuser status` does not report `/root` for `CURRENT_HOME`.
- `sudo config --target labuser status` does not report `/root/.local/wsl-mounts` for `BASEDIR`.
- `sudo config --target labuser status` does not report `WSL_USER=root`.
- `sudo config --target labuser status` does not report `SMB_USER=root`.
- `config --target vmuser status` preserves `SMB_USER=hector`.
- `sudo TARGET_USER=labuser config status` still targets labuser.
- `config user --as labuser --shell-command 'printf "%s\n" "$HOME"'` still works.
- No installers, mounts, package managers, Docker, Kubernetes, SQL tools, or destructive cleanup commands are run during validation.

## Required validation post log

After implementing the patch, create a simple postcheck log at:

```bash
/home/vmuser/.local/patches/AN1_02_refresh_target_session_context_postcheck.log
```

Use plain evidence-log style. The log should be readable without re-running the commands.

Use this pattern:

```text
AN1-02 refresh target and session context postcheck
UTC YYYY-MM-DD HH:MM:SS

Validation after applying patch

[1] Syntax checks
config.sh syntax exit=0
mounts.sh syntax exit=0
Result: PASS

[2] Helper presence
config_set_target_user found: yes
config_refresh_session_context found: yes
config_default_smb_user_for_target found: yes
Result: PASS

[3] vmuser target context
Command attempted:
config --target vmuser status

Observed behavior:
- TARGET_USER=vmuser
- TARGET_HOME=/home/vmuser
- CURRENT_HOME=/home/vmuser
- BASEDIR=/home/vmuser/.local/wsl-mounts
- STATE_DIR=/home/vmuser/.local/state/config-sh
- WSL_USER=vmuser
- SMB_USER=hector

Result: PASS

[4] labuser target context under sudo
Command attempted:
sudo config --target labuser status

Observed behavior:
- TARGET_USER=labuser
- TARGET_HOME=/home/labuser
- CURRENT_HOME=/home/labuser
- BASEDIR=/home/labuser/.local/wsl-mounts
- STATE_DIR=/home/labuser/.local/state/config-sh
- WSL_USER=labuser
- SMB_USER=labuser

Result: PASS

[5] Root leakage regression check
Command attempted:
sudo config --target labuser status

Observed behavior:
- CURRENT_HOME was not /root.
- BASEDIR was not /root/.local/wsl-mounts.
- WSL_USER was not root.
- SMB_USER was not root.

Result: PASS

[6] TARGET_USER environment compatibility
Command attempted:
sudo TARGET_USER=labuser config status

Observed behavior:
- TARGET_USER=labuser
- TARGET_HOME=/home/labuser
- CURRENT_HOME=/home/labuser
- STATE_DIR=/home/labuser/.local/state/config-sh

Result: PASS

[7] config user compatibility
Command attempted:
sudo config --target labuser user --shell-command 'printf "%s\n" "$HOME"'

Observed behavior:
- Command still runs through existing config user path.
- HOME resolves to /home/labuser.

Result: PASS

[8] Non-root cross-target behavior
Command attempted:
config --target labuser status

Observed behavior:
- Command may fail because vmuser cannot create state under /home/labuser.
- This is acceptable unless it corrupts state or writes under /root.

Result: PASS

Overall
- Target context is centralized.
- Session context no longer leaks root values under sudo.
- Target-dependent paths are refreshed together.
- No package installs, mounts, or destructive actions were run.
```

If `labuser` does not exist, mark labuser-specific checks as `Result: SKIP` and explain why. Do not invent successful results.

## Suggested non-destructive checks

Use these or equivalent commands. Keep the final postcheck log simple and human-readable.

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/mounts.sh

grep -q 'config_set_target_user' /home/vmuser/.local/bin/config.sh
grep -q 'config_refresh_session_context' /home/vmuser/.local/bin/config.sh
grep -q 'config_default_smb_user_for_target' /home/vmuser/.local/bin/config.sh

config --target vmuser status

if getent passwd labuser >/dev/null 2>&1; then
  sudo config --target labuser status
  sudo TARGET_USER=labuser config status
  sudo config --target labuser user --shell-command 'printf "%s\n" "$HOME"'
else
  echo '[SKIP] labuser does not exist'
fi
```

Do not run:

```bash
config bootstrap
config install
config mount
config all
apt-get install
docker
kubectl
minikube
sqlcmd
```

## Codex instruction

Implement only AN1-02.

Update the current AN1-01 implementation so target and session context are centralized. `sudo config --target labuser status` must no longer show root-derived session fields.

Focus on `config.sh` and, only if needed, the top-level/session initialization behavior in `mounts.sh`.

Do not run installers, mounts, package managers, Docker, Kubernetes, SQL tooling, or destructive cleanup commands.

After patching, create:

```bash
/home/vmuser/.local/patches/AN1_02_refresh_target_session_context_postcheck.log
```

Use the simple evidence-log style described in this brief.
