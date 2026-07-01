# AN1-06 — Target and Mounts Interaction

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Harden how `--target USER` interacts with mount/session identity.

Principle:

```text
--target controls the Linux account being configured.
mount controls WSL/session mount points and SMB identity.
```

After AN1-05/05A/05B, pull/push are target-aware, sudo-only, and manifest scoped. AN1-06 should now make mount identity visible and prevent silent root or wrong-user mount behavior.

## Scope

Edit only what is needed:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/bin/mounts.sh
```

Do not run:

```text
bootstrap
install
all
apt
docker
kubectl
minikube
sqlcmd
```

Do not run live mounts unless explicitly safe.

## Current state to preserve

- `config --target labuser status` context is correct.
- `pull` and `push` require sudo.
- `pull` and `push` print target path context.
- `labuser` sync is user-only by default.
- `vmuser` sync includes user + system items by default.
- `CopyConfigFiles` / `PushConfigFiles` are manifest based.
- Existing `mounts.sh` remains source-safe.

## Required behavior

### Mount context must be visible

This command:

```bash
sudo config --target labuser mount
```

must print a mount context before mount workflow starts:

```text
Mount context:
  TARGET_USER=labuser
  TARGET_HOME=/home/labuser
  CURRENT_HOME=/home/labuser
  BASEDIR=/home/labuser/.local/wsl-mounts
  WSL_USER=labuser
  SMB_USER=labuser
  SMB_USER_INGRESS=labuser
  SMB_USER_EGRESS=labuser
```

For `vmuser`, preserve:

```text
SMB_USER=hector
```

unless explicit SMB overrides are set.

### No root identity leakage

Under:

```bash
sudo config --target labuser mount ...
```

the mount context must not silently show:

```text
WSL_USER=root
SMB_USER=root
```

### Pull/push mount guards should be mount-specific

AN1-05 already has path guards. Refine only if needed so missing mounts are clearer:

```text
missing /mnt/distrohome:
  tell operator to run sudo config mount or sudo config mount --all

missing /mnt/egress:
  tell operator to run sudo config mount --egress or sudo config mount --all
```

## Required helpers

Add to `config.sh` near mount/pull/push helpers:

```bash
config_print_mount_context() {
  echo "Mount context:"
  printf "  TARGET_USER=%s\n" "$TARGET_USER"
  printf "  TARGET_HOME=%s\n" "$TARGET_HOME"
  printf "  CURRENT_HOME=%s\n" "$CURRENT_HOME"
  printf "  BASEDIR=%s\n" "$BASEDIR"
  printf "  WSL_USER=%s\n" "$WSL_USER"
  printf "  SMB_USER=%s\n" "$SMB_USER"
  printf "  SMB_USER_INGRESS=%s\n" "$SMB_USER_INGRESS"
  printf "  SMB_USER_EGRESS=%s\n" "$SMB_USER_EGRESS"
}

config_require_mount_path() {
  local path="${1:-}"
  local hint="${2:-Run: sudo config mount or sudo config mount --all}"

  [[ -n "$path" ]] || return 2

  if [[ ! -d "$path" ]]; then
    echo "[ERROR] Required mount path is missing: $path" >&2
    echo "[INFO] $hint" >&2
    return 1
  fi
}
```

## Required changes

### 1. Update `config_run_mounts`

Make `config_run_mounts` refresh config context and print mount context before calling `mounts_run`.

Recommended shape:

```bash
config_run_mounts() {
  case "${1:-}" in
    help|-h|--help)
      mounts_usage
      return 0
      ;;
  esac

  config_runtime_init || return 1
  config_refresh_session_context
  config_print_mount_context

  mounts_run "$@" || return 1
}
```

If preserving the zero-arg branch is preferred, still ensure both branches call:

```bash
config_refresh_session_context
config_print_mount_context
```

before `mounts_run`.

### 2. Harden `mounts_init_session_vars`

Ensure `mounts_init_session_vars` respects config-provided context and never defaults to root under sudo target runs.

Preferred behavior:

```bash
mounts_init_session_vars() {
  DISTRONAME="${DISTRONAME:-jepabio-Ubuntu-22.04}"

  WSL_USER="${WSL_USER:-${TARGET_USER:-$(id -un)}}"

  case "$WSL_USER" in
    vmuser) SMB_USER="${SMB_USER:-hector}" ;;
    labuser) SMB_USER="${SMB_USER:-labuser}" ;;
    *) SMB_USER="${SMB_USER:-$WSL_USER}" ;;
  esac

  SMB_USER_INGRESS="${SMB_USER_INGRESS:-labuser}"
  SMB_USER_EGRESS="${SMB_USER_EGRESS:-labuser}"

  export DISTRONAME WSL_USER SMB_USER SMB_USER_INGRESS SMB_USER_EGRESS
}
```

Do not prompt for `WSL_USER` here when config has already exported it.

### 3. Refine pull/push mount guards if needed

If current guards only check final source/destination, make messages more explicit.

Suggested pull guard:

```bash
config_require_pull_source() {
  local root="${DISTROHOME:-/mnt/distrohome}"
  local src

  config_require_mount_path "$root" "Run: sudo config mount or sudo config mount --all" || return 1

  src="$(config_pull_source_dir)"
  [[ -d "$src" ]] || {
    echo "[ERROR] Pull source not found for target $TARGET_USER: $src" >&2
    echo "[INFO] Expected: $root/.configfiles/$TARGET_USER" >&2
    return 1
  }
}
```

Suggested push guard:

```bash
config_require_push_destination_parent() {
  config_require_mount_path "/mnt/egress" "Run: sudo config mount --egress or sudo config mount --all"
}
```

Do not change manifest sync scope from AN1-05B.

## Help update

Update mount help minimally:

```text
--target USER selects the Linux account being configured.
mount manages WSL/session mount points and SMB identity.
Use MOUNTS_* and SMB_USER_* overrides for mount credentials/identity.
The effective mount context is printed before mount work starts.
```

Main help may say:

```text
mount, mounts       Run mount workflow; prints target/mount identity first
```

## Acceptance

- `config_print_mount_context` exists.
- `config_require_mount_path` exists.
- `sudo config --target labuser mount help` works.
- `sudo config --target labuser mount` prints mount context before mount workflow, or this is validated with a safe/stubbed call.
- Mount context for labuser does not show `WSL_USER=root` or `SMB_USER=root`.
- Mount context for vmuser preserves `SMB_USER=hector` unless overridden.
- Pull missing `/mnt/distrohome` tells operator to run `sudo config mount` or `sudo config mount --all`.
- Push missing `/mnt/egress` tells operator to run `sudo config mount --egress` or `sudo config mount --all`.
- AN1-05A sudo-only guard still passes.
- AN1-05B manifest scope still passes.
- No bootstrap/install/package commands are run.
- No live mount commands are required for validation.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_06_target_mount_interactions_postcheck.log
```

Use simple evidence-log style:

```text
AN1-06 target and mounts interaction postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
mounts.sh syntax exit=0
Result: PASS

[2] Helper presence
config_print_mount_context found: yes
config_require_mount_path found: yes
Result: PASS

[3] Mount help
Command attempted:
sudo config --target labuser mount help

Observed:
- Help was shown.
- Help distinguishes target user from mount/SMB identity.

Result: PASS

[4] Mount context
Command attempted:
sudo config --target labuser mount <safe/stubbed/no-live-mount validation if available>

Observed:
- Mount context printed before mount workflow.
- TARGET_USER=labuser
- TARGET_HOME=/home/labuser
- WSL_USER was not root
- SMB_USER was not root

Result: PASS or SKIP
Reason if SKIP: live mount workflow intentionally not run.

[5] Missing mount guard messages
Observed:
- Missing /mnt/distrohome says to run sudo config mount or sudo config mount --all.
- Missing /mnt/egress says to run sudo config mount --egress or sudo config mount --all.

Result: PASS

[6] AN1-05A regression
config --target vmuser push without sudo blocked: yes
config --target labuser push without sudo blocked: yes
Result: PASS

[7] AN1-05B regression
sudo config --target labuser push skips system items: yes
sudo config --target vmuser push includes system items: yes
Result: PASS or SKIP
Reason if SKIP: live egress/distrohome fixture intentionally not run.

[8] Context regression
sudo config --target labuser status context correct: yes
sudo config --target labuser bootstrap status non-destructive: yes
Result: PASS

Overall
- Target identity and mount identity are explicit.
- No root identity leaked into target mount context.
- Missing mount dependencies fail clearly.
- AN1-05A/05B behavior remains intact.
- No bootstrap/install/package commands were run.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/mounts.sh

sudo config --target labuser status
sudo config --target labuser mount help
sudo config --target labuser bootstrap status

config --target vmuser push
config --target labuser push
```

Do not run live mount workflow unless the environment is safe and intended:

```bash
sudo config --target labuser mount
sudo config --target labuser mount --all
```
