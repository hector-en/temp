# AN1-09 — Externalize Config Defaults and Target Policy

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Reduce hard-coded policy inside:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/bin/mounts.sh
/home/vmuser/.local/bin/create-cifs-credentials-files.sh
```

by introducing small, safe, editable config files.

The scripts should remain the execution engine.

The config files should hold target/user-specific defaults such as:

```text
default SMB user mapping
mount SMB identities
bootstrap default plan states
optional sync behavior
default network/share settings
```

This makes the system easier to manage without repeatedly editing shell code.

## Why this milestone exists

The current code has too many operational choices embedded in shell functions.

Examples of hard-coded policy:

```bash
vmuser -> hector
labuser -> labuser
SMB_USER_INGRESS=labuser
SMB_USER_EGRESS=labuser
default bootstrap.plan states
admin target is vmuser
sync user/system scope
credential file defaults
DISTRONAME default in mounts.sh
```

Those choices are policy/configuration, not core program logic.

## Desired model

Use layered configuration:

```text
1. Built-in safe defaults in code
2. Global config file
3. Per-target config file
4. Environment variable overrides
5. CLI options
```

Later layers win.

Recommended files:

```text
/home/vmuser/.local/etc/config-sh/config.env
/home/vmuser/.local/etc/config-sh/targets/vmuser.env
/home/vmuser/.local/etc/config-sh/targets/labuser.env
```

For target-owned local overrides, optionally support later:

```text
$TARGET_HOME/.local/etc/config-sh/config.env
```

Do not require that target-local file in this milestone unless easy.

## Scope

Edit primarily:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/bin/mounts.sh
```

Optionally update:

```text
/home/vmuser/.local/bin/create-cifs-credentials-files.sh
```

Create config directory/files if missing:

```text
/home/vmuser/.local/etc/config-sh/
/home/vmuser/.local/etc/config-sh/targets/
```

Do not change bootstrap step implementation logic unless needed to read config.

Do not run live broad commands:

```text
bootstrap
install
mount
all
apt
docker
kubectl
minikube
sqlcmd
```

## Config file format

Use simple shell-compatible `KEY=value` files.

Example:

```bash
# /home/vmuser/.local/etc/config-sh/config.env
CONFIG_ADMIN_TARGETS="vmuser"
CONFIG_SYNC_RESOLV_CONF_DEFAULT="0"

CONFIG_DEFAULT_SMB_USER_VMUSER="hector"
CONFIG_DEFAULT_SMB_USER_LABUSER="labuser"

SMB_USER_INGRESS_DEFAULT="labuser"
SMB_USER_EGRESS_DEFAULT="labuser"

MOUNTS_DISTRONAME_DEFAULT="jepabio-Ubuntu-22.04"
```

Example:

```bash
# /home/vmuser/.local/etc/config-sh/targets/labuser.env
TARGET_ROLE="lab"
SMB_USER_DEFAULT="labuser"
SMB_USER_INGRESS_DEFAULT="labuser"
SMB_USER_EGRESS_DEFAULT="labuser"
BOOTSTRAP_PROFILE="lab"
SYNC_SYSTEM_ITEMS="0"
```

Example:

```bash
# /home/vmuser/.local/etc/config-sh/targets/vmuser.env
TARGET_ROLE="admin"
SMB_USER_DEFAULT="hector"
SMB_USER_INGRESS_DEFAULT="labuser"
SMB_USER_EGRESS_DEFAULT="labuser"
BOOTSTRAP_PROFILE="admin"
SYNC_SYSTEM_ITEMS="1"
```

Keep file syntax deliberately simple.

No arrays.
No command substitutions.
No functions.
No `source` of arbitrary uncontrolled user input unless validated.

## Safe config loading requirement

Do not blindly source untrusted config files.

Implement a constrained loader that accepts only safe assignments:

```text
KEY=value
KEY="value"
KEY='value'
blank lines
comments
```

Reject or ignore lines containing shell execution syntax, for example:

```text
$(
`;
|
&
<
>
function
()
```

Suggested helper:

```bash
config_load_env_file() {
  local file="${1:-}"
  local line key value lineno=0

  [[ -f "$file" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))

    # trim whitespace
    # skip blank/comment
    # require KEY=VALUE
    # KEY must match ^[A-Za-z_][A-Za-z0-9_]*$
    # reject unsafe characters in value
    # strip simple matching quotes
    # export "$key=$value"
  done < "$file"
}
```

This protects against config accidentally becoming executable code.

## Load order

Add helpers:

```bash
config_global_config_dir() {
  printf '%s\n' "/home/vmuser/.local/etc/config-sh"
}

config_target_config_file() {
  printf '%s\n' "$(config_global_config_dir)/targets/${TARGET_USER}.env"
}

config_load_config_files() {
  local base
  base="$(config_global_config_dir)"

  config_load_env_file "$base/config.env"
  config_load_env_file "$base/targets/${TARGET_USER}.env"

  # optional if implemented:
  # config_load_env_file "$TARGET_HOME/.local/etc/config-sh/config.env"
}
```

Call this after `config_set_target_user` resolves `TARGET_USER` / `TARGET_HOME`, but before deriving SMB defaults and sync policy.

Be careful to avoid recursion:

```text
config_set_target_user -> resolve home -> load config -> refresh session context
```

Avoid calling config refresh from the loader if that causes loops.

## Refactor target defaults

### 1. SMB user mapping

Current:

```bash
config_default_smb_user_for_target() {
  case "$user" in
    vmuser) printf 'hector' ;;
    labuser) printf 'labuser' ;;
    *) printf "$user" ;;
  esac
}
```

Move policy to config variables.

Suggested behavior:

```bash
config_default_smb_user_for_target() {
  local user="${1:-}"
  local var=""

  case "$user" in
    vmuser)
      printf '%s\n' "${CONFIG_DEFAULT_SMB_USER_VMUSER:-hector}"
      ;;
    labuser)
      printf '%s\n' "${CONFIG_DEFAULT_SMB_USER_LABUSER:-labuser}"
      ;;
    *)
      printf '%s\n' "${SMB_USER_DEFAULT:-$user}"
      ;;
  esac
}
```

If per-target file has:

```bash
SMB_USER_DEFAULT="customname"
```

then use that before hard-coded fallback.

Preferred precedence:

```text
SMB_USER_OVERRIDE env
SMB_USER_DEFAULT from target config
CONFIG_DEFAULT_SMB_USER_<USER> from global config
fallback to username
```

### 2. Ingress/egress users

Current:

```bash
SMB_USER_INGRESS="${SMB_USER_INGRESS_OVERRIDE:-labuser}"
SMB_USER_EGRESS="${SMB_USER_EGRESS_OVERRIDE:-labuser}"
```

Change to:

```bash
SMB_USER_INGRESS="${SMB_USER_INGRESS_OVERRIDE:-${SMB_USER_INGRESS_DEFAULT:-labuser}}"
SMB_USER_EGRESS="${SMB_USER_EGRESS_OVERRIDE:-${SMB_USER_EGRESS_DEFAULT:-labuser}}"
```

### 3. Admin/system sync policy

Current:

```bash
config_sync_is_admin_target() {
  [[ "$TARGET_USER" == "vmuser" ]]
}
```

Move to config.

Support:

```bash
SYNC_SYSTEM_ITEMS="1"
```

in target config.

Also support global:

```bash
CONFIG_ADMIN_TARGETS="vmuser"
```

Suggested:

```bash
config_sync_is_admin_target() {
  if [[ "${SYNC_SYSTEM_ITEMS:-}" == "1" ]]; then
    return 0
  fi
  if [[ "${SYNC_SYSTEM_ITEMS:-}" == "0" ]]; then
    return 1
  fi

  case " ${CONFIG_ADMIN_TARGETS:-vmuser} " in
    *" ${TARGET_USER} "*) return 0 ;;
    *) return 1 ;;
  esac
}
```

### 4. Default bootstrap plan profile

Current `config_bootstrap_plan_init` hard-codes pending/skipped rows.

Introduce profile helper:

```bash
config_bootstrap_default_state_for_step() {
  local step="${1:-}"

  case "${BOOTSTRAP_PROFILE:-default}" in
    lab)
      case "$step" in
        update_apt|standard_apps|install_networking)
          printf '%s\n' "skipped"
          ;;
        *)
          printf '%s\n' "skipped"
          ;;
      esac
      ;;
    admin|full)
      case "$step" in
        install_gui_support|install_docker|install_terraform|install_kubernets|install_minikube|install_sqlserver_support_2004|install_sqlserver_cli_tool_2204)
          printf '%s\n' "skipped"
          ;;
        *)
          printf '%s\n' "pending"
          ;;
      esac
      ;;
    *)
      # preserve current default
      case "$step" in
        install_gui_support|install_docker|install_terraform|install_kubernets|install_minikube|install_sqlserver_support_2004|install_sqlserver_cli_tool_2204)
          printf '%s\n' "skipped"
          ;;
        *)
          printf '%s\n' "pending"
          ;;
      esac
      ;;
  esac
}
```

Then `plan-init` loops over `config_bootstrap_steps`:

```bash
while read -r step; do
  printf '%s %s\n' "$(config_bootstrap_default_state_for_step "$step")" "$step"
done < <(config_bootstrap_steps)
```

Do not change existing plan files. This only affects newly created plans.

### 5. Mount defaults

In `mounts.sh`, remove hard-coded defaults where possible.

Current examples:

```bash
DISTRONAME="${DISTRONAME:-jepabio-Ubuntu-22.04}"
SMB_USER_INGRESS="${SMB_USER_INGRESS:-labuser}"
SMB_USER_EGRESS="${SMB_USER_EGRESS:-labuser}"
```

Change to use loaded/exported defaults:

```bash
DISTRONAME="${DISTRONAME:-${MOUNTS_DISTRONAME_DEFAULT:-jepabio-Ubuntu-22.04}}"
SMB_USER_INGRESS="${SMB_USER_INGRESS:-${SMB_USER_INGRESS_DEFAULT:-labuser}}"
SMB_USER_EGRESS="${SMB_USER_EGRESS:-${SMB_USER_EGRESS_DEFAULT:-labuser}}"
```

`config.sh` should export these before calling mount workflow.

### 6. Credentials helper defaults

In `create-cifs-credentials-files.sh`, if easy, use same config defaults.

Current:

```bash
DISTROHOME_USER="hector"
SCRIPTING_USER="hector"
INGRESS_USER="labuser"
EGRESS_USER="labuser"
```

Make overridable by environment/config:

```bash
DISTROHOME_USER="${DISTROHOME_USER:-${SMB_USER_DEFAULT:-hector}}"
SCRIPTING_USER="${SCRIPTING_USER:-${SMB_USER_DEFAULT:-hector}}"
INGRESS_USER="${INGRESS_USER:-${SMB_USER_INGRESS_DEFAULT:-labuser}}"
EGRESS_USER="${EGRESS_USER:-${SMB_USER_EGRESS_DEFAULT:-labuser}}"
```

Do not overcomplicate this script.

## Config creation command

Add a safe helper command to initialize example config files.

Suggested command:

```bash
sudo config config-init
```

or:

```bash
sudo config settings init
```

Keep it simple. Preferred:

```bash
config config-init
```

Behavior:

```text
- create /home/vmuser/.local/etc/config-sh/config.env if missing
- create targets/vmuser.env if missing
- create targets/labuser.env if missing
- do not overwrite existing files unless --force is supplied
- chmod 600 files
- chmod 700 dirs
```

Add help text.

Example output:

```text
[INFO] Created config directory: /home/vmuser/.local/etc/config-sh
[INFO] Created config file: /home/vmuser/.local/etc/config-sh/config.env
[INFO] Created target config: /home/vmuser/.local/etc/config-sh/targets/labuser.env
[INFO] Existing file kept: /home/vmuser/.local/etc/config-sh/targets/vmuser.env
```

## Status output

Update `config status` to show which config files were loaded:

```text
CONFIG_DIR=/home/vmuser/.local/etc/config-sh
CONFIG_FILES_LOADED:
  /home/vmuser/.local/etc/config-sh/config.env
  /home/vmuser/.local/etc/config-sh/targets/labuser.env
BOOTSTRAP_PROFILE=lab
SYNC_SYSTEM_ITEMS=0
SMB_USER_DEFAULT=labuser
```

Do not leak secrets.

Do not print password or credential file content.

## Help update

Update:

```bash
config help
config help menu
config help howto
config help all
```

Add a help topic if useful:

```bash
config help config
```

Suggested concise help:

```text
Config files:
  Global defaults:
    /home/vmuser/.local/etc/config-sh/config.env

  Per-target defaults:
    /home/vmuser/.local/etc/config-sh/targets/USER.env

  Initialize examples:
    config config-init

  Later layers override earlier ones:
    built-in defaults < global config < target config < environment < CLI
```

## Acceptance

- `config config-init` creates global and target config files if missing.
- Existing config files are not overwritten by default.
- Config files use safe `KEY=value` syntax.
- Unsafe config lines are rejected or ignored with a warning.
- `config --target labuser status` shows config dir/files loaded and target policy values.
- `SMB_USER_DEFAULT` from `targets/labuser.env` affects `SMB_USER`.
- `SMB_USER_INGRESS_DEFAULT` and `SMB_USER_EGRESS_DEFAULT` affect mount context.
- `SYNC_SYSTEM_ITEMS=0` makes labuser skip system sync.
- `SYNC_SYSTEM_ITEMS=1` makes vmuser include system sync.
- `BOOTSTRAP_PROFILE` controls newly generated `bootstrap.plan` defaults.
- Existing `bootstrap.plan` files are not rewritten by this milestone.
- Existing `plan-apply`, `skip`, `unskip`, `rm`, and `bootstrap step` behavior remains unchanged.
- No secrets are printed in status.
- Shell syntax passes.
- No broad bootstrap/install/mount/package commands are run in postcheck.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_09_externalized_config_defaults_postcheck.log
```

Use simple evidence-log style:

```text
AN1-09 externalized config defaults postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
mounts.sh syntax exit=0
create-cifs-credentials-files.sh syntax exit=0 or SKIP if unchanged
Result: PASS

[2] Config init
Command attempted:
config config-init

Observed:
- Created or kept /home/vmuser/.local/etc/config-sh/config.env
- Created or kept targets/vmuser.env
- Created or kept targets/labuser.env
- Existing files were not overwritten.

Result: PASS

[3] Config loading
Command attempted:
config --target labuser status

Observed:
- CONFIG_DIR shown.
- Loaded config files shown.
- BOOTSTRAP_PROFILE shown.
- SMB_USER_DEFAULT/SMB_USER shown.
- SYNC_SYSTEM_ITEMS shown.
- No secrets printed.

Result: PASS

[4] Target SMB defaults
Setup:
targets/labuser.env contains SMB_USER_DEFAULT=labuser

Observed:
config --target labuser status shows SMB_USER=labuser.

Result: PASS

[5] Admin sync policy
Observed:
- labuser target has SYNC_SYSTEM_ITEMS=0 or equivalent.
- vmuser target has SYNC_SYSTEM_ITEMS=1 or equivalent.
- Pull/push system item decision still matches policy.

Result: PASS

[6] Bootstrap plan profile
Command attempted on safe temp/missing plan fixture:
sudo config --target labuser bootstrap plan-init

Observed:
- New plan used BOOTSTRAP_PROFILE defaults.
- Existing plans were not overwritten.

Result: PASS or SKIP
Reason if SKIP: live target already had plan; static helper verified.

[7] Mount defaults
Command attempted:
sudo config --target labuser mount help

Observed:
- Syntax/help worked.
- Mount defaults are sourced from exported config variables where applicable.
- No live mount was run.

Result: PASS

[8] Unsafe config line handling
Setup:
Temporary config file with unsafe line such as BAD=$(id)

Observed:
- Loader rejected or ignored unsafe line with warning.
- Did not execute command substitution.

Result: PASS

[9] Regression
Observed:
- config help works.
- bootstrap status works.
- bootstrap plan works.
- plan-apply help/dispatch still works.
- skip/unskip/rm dispatch still works.
- bootstrap step dispatch still works.

Result: PASS

[10] Safety
Observed:
- No broad bootstrap/install/mount command was run.
- No apt/docker/kubectl/minikube/sqlcmd command was run.
- No secrets were printed.

Result: PASS

Overall
- Target/user policy is now editable through config files.
- config.sh remains the execution engine.
- Hard-coded defaults are reduced but safe fallbacks remain.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/mounts.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/create-cifs-credentials-files.sh

config config-init
config help config
config --target labuser status
config --target vmuser status
sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap status
```

Do not run broad execution in this milestone:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
sudo config --target labuser mount
sudo config --target labuser pull
sudo config --target labuser push
```
