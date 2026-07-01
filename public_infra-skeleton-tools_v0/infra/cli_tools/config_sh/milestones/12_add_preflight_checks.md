# Correction 12: Add preflight checks for bootstrap and mount workflows

Source package to paste with this brief: the latest exported VMUser codebase after Correction 11. If your latest export is named `code_full_summary.txt`, paste that file together with this brief.

Backlog position: after Correction 11, before Correction 13

Story Points: 1

Target duration: about 30 minutes

Scope: `/home/vmuser/.local/bin/config.sh` only

## Paste-this brief for a new chat

You are given the current VMUser Linux/WSL configuration export. Please make a minimal, focused patch for Correction 12 only.

The goal is to add read-only preflight checks before expensive or state-changing workflows run. The checks should catch common environment problems early: unsupported OS, missing `sudo`, missing core commands, no cached sudo access, DNS failure, and missing mount helpers.

The latest expected codebase state already includes these prior corrections:

- `lv.sh` is split out.
- `mounts.sh` exists and the mount workflow is called through `mounts_run`.
- `config.sh` has explicit commands such as `help`, `status`, `mounts`, `bootstrap`, `pull`, `push`, and `user`.
- Correction 09 added safer target-user helpers, including `target_sudo`, `run_as_target`, and `run_as_target_shell`.
- Correction 10 hardened `run_once` marker behavior and added richer marker states such as `.done`, `.running`, `.failed`, and `.skipped`.
- Correction 11 split `InstallDevEnv` into substeps such as `InstallDevEnvSystemPackages`, `InstallDevEnvAnaconda`, and `InstallDevEnvAzureCLI`, and `config_run_bootstrap` now runs those substeps independently.
- The current code already has `config_apt_refresh_if_stale`; do not replace it in this correction.

If the pasted codebase still has a single broad `run_once install_dev_env InstallDevEnv` in `config_run_bootstrap`, stop and apply Correction 11 first. Do not mix Correction 11 into this patch.

## Current problem

The bootstrap and mount workflows still start doing real work before they validate the host environment.

Examples:

- Bootstrap may call `apt-get`, add repositories, run `curl`, run `wget`, or use `gpg` before the user gets a clear early report about DNS, sudo, or missing system tools.
- Mounts may reach `sudo mount -t cifs` before confirming that `mount`, `umount`, `mountpoint`, and CIFS support are available.
- Failures happen mid-flow and can leave `.failed` markers even when the root cause was predictable before starting.
- `config status` shows marker state, but there is no explicit command that says “is this machine ready to run bootstrap/mounts?”

## Goal

Add a small preflight framework to `config.sh` that can be run manually and is called automatically before bootstrap and mount workflows.

After the patch, these commands should work:

```bash
config preflight
config preflight all
config preflight bootstrap
config preflight mounts
config bootstrap
config mounts
```

Expected behavior:

- `config preflight` defaults to `all`.
- `config preflight bootstrap` checks OS, sudo, core bootstrap commands, and DNS for known external bootstrap hosts.
- `config preflight mounts` checks sudo, core mount commands, and CIFS mount helper availability.
- `config bootstrap` runs the bootstrap preflight once before executing the `run_once` bootstrap steps.
- `config mounts` runs the mount preflight once before executing `mounts_run`.
- Preflight is read-only. It must not install packages, mount anything, clear markers, create `.done` files, or prompt for input.

## Do not change in this correction

Do not implement later backlog items here:

- Do not add download retry wrappers. That is Correction 13.
- Do not rename or redesign `install-kubernets`. That is Correction 14.
- Do not fix `lv.sh` alias creation. That is Correction 15.
- Do not normalize `.bashrc` or `.profile` include blocks. That is Correction 16.
- Do not add a full dry-run mode. That is Correction 17.
- Do not add logging or log rotation. That is Correction 18.
- Do not change SMB credential handling; that was Correction 08.
- Do not change `mounts.sh` behavior except by calling preflight before `mounts_run` from `config.sh`.
- Do not run package managers while producing the patch.
- Do not make preflight depend on network downloads. DNS checks are enough for this correction.

## Required implementation

### 1. Add a `preflight` command to usage

Update `config_usage` so it includes:

```text
  preflight [scope]   Run read-only checks; scope is all, bootstrap, or mounts
```

Keep the rest of the usage text intact.

### 2. Add small preflight output helpers

Add these helpers near the other `config_*` helper functions, before `config_usage` or near `config_runtime_init`.

Use simple counters so the final result is easy to understand:

```bash
CONFIG_PREFLIGHT_ERRORS=0
CONFIG_PREFLIGHT_WARNINGS=0

config_preflight_reset() {
  CONFIG_PREFLIGHT_ERRORS=0
  CONFIG_PREFLIGHT_WARNINGS=0
}

config_preflight_ok() {
  printf '[OK] %s\n' "$*"
}

config_preflight_warn() {
  CONFIG_PREFLIGHT_WARNINGS=$((CONFIG_PREFLIGHT_WARNINGS + 1))
  printf '[WARN] %s\n' "$*" >&2
}

config_preflight_error() {
  CONFIG_PREFLIGHT_ERRORS=$((CONFIG_PREFLIGHT_ERRORS + 1))
  printf '[ERROR] %s\n' "$*" >&2
}
```

These helpers must not exit directly. The main `config_preflight` function should decide the final return code.

### 3. Add command-check helpers

Add helpers for required and optional commands:

```bash
config_preflight_require_command() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    config_preflight_ok "command available: $cmd"
  else
    config_preflight_error "missing required command: $cmd"
  fi
}

config_preflight_warn_command() {
  local cmd="$1" note="${2:-}"
  if command -v "$cmd" >/dev/null 2>&1; then
    config_preflight_ok "command available: $cmd"
  else
    if [[ -n "$note" ]]; then
      config_preflight_warn "missing optional/future command: $cmd ($note)"
    else
      config_preflight_warn "missing optional/future command: $cmd"
    fi
  fi
}
```

Use `command -v`, not package-manager queries.

### 4. Add sudo preflight without prompting

Add a sudo check that never blocks for a password:

```bash
config_preflight_check_sudo() {
  config_preflight_require_command sudo

  if command -v sudo >/dev/null 2>&1; then
    if sudo -n true 2>/dev/null; then
      config_preflight_ok "sudo non-interactive check passed"
    else
      config_preflight_error "sudo is not currently non-interactive; run 'sudo -v' in a terminal, then retry"
    fi
  fi
}
```

Do not use plain `sudo true`, because it can prompt and hang in automation.

### 5. Add OS and apt preflight

Add a function that checks the OS file and apt availability.

Minimal acceptable implementation:

```bash
config_preflight_check_os() {
  local os_id="" version_id="" pretty=""

  if [[ ! -f /etc/os-release ]]; then
    config_preflight_error "/etc/os-release is missing; cannot identify OS"
    return 0
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  os_id="${ID:-}"
  version_id="${VERSION_ID:-}"
  pretty="${PRETTY_NAME:-$os_id $version_id}"

  config_preflight_ok "OS detected: $pretty"

  case "$os_id" in
    ubuntu|debian)
      config_preflight_ok "OS family supports apt-style bootstrap"
      ;;
    *)
      config_preflight_error "unsupported OS family '$os_id'; this bootstrap expects Ubuntu/Debian with apt-get"
      ;;
  esac

  case "$os_id:$version_id" in
    ubuntu:20.04|ubuntu:22.04|ubuntu:24.04|debian:*)
      config_preflight_ok "OS version is known or Debian-compatible: $os_id $version_id"
      ;;
    *)
      config_preflight_warn "OS version has not been explicitly validated by this script: $os_id $version_id"
      ;;
  esac

  config_preflight_require_command apt-get
  config_preflight_require_command dpkg
}
```

It is acceptable for unsupported OS to be an error. The script uses apt repositories, Ubuntu package names, and `/etc/apt` paths.

### 6. Add DNS preflight

Add a small helper that uses `getent hosts` only. Do not use `curl`, `wget`, or `ping` here.

```bash
config_preflight_check_dns_host() {
  local host="$1"
  if getent hosts "$host" >/dev/null 2>&1; then
    config_preflight_ok "DNS resolves: $host"
  else
    config_preflight_error "DNS failed for: $host"
  fi
}
```

Then add a bootstrap DNS check:

```bash
config_preflight_check_bootstrap_dns() {
  local hosts=(
    archive.ubuntu.com
    security.ubuntu.com
    packages.microsoft.com
    repo.anaconda.com
    pyenv.run
    download.docker.com
    apt.releases.hashicorp.com
    pkgs.k8s.io
    storage.googleapis.com
  )
  local host

  config_preflight_require_command getent

  for host in "${hosts[@]}"; do
    config_preflight_check_dns_host "$host"
  done
}
```

If the local system uses a mirror or custom apt source, `archive.ubuntu.com` and `security.ubuntu.com` still provide a useful baseline DNS test. Do not parse apt sources in this correction.

### 7. Add bootstrap preflight

Add a function that checks the base commands needed before bootstrap starts.

Suggested implementation:

```bash
config_preflight_bootstrap() {
  local required=(
    bash
    awk
    sed
    grep
    find
    sort
    head
    date
    mkdir
    touch
    chmod
    rm
    tee
    getent
    id
  )
  local cmd

  echo "Preflight scope: bootstrap"

  config_preflight_check_os
  config_preflight_check_sudo

  for cmd in "${required[@]}"; do
    config_preflight_require_command "$cmd"
  done

  # These are installed or refreshed by bootstrap substeps, but later functions use them.
  # Warn now so the user knows what later steps will need.
  config_preflight_warn_command curl "used later by pyenv, Docker, Azure, Kubernetes, and repository setup"
  config_preflight_warn_command wget "used later by Anaconda and repository setup"
  config_preflight_warn_command gpg "used later by apt repository key setup"
  config_preflight_warn_command lsb_release "used later by Azure CLI repository setup"

  config_preflight_check_bootstrap_dns
}
```

Do not require `curl`, `wget`, `gpg`, or `lsb_release` as hard failures at this stage, because the bootstrap flow can install some of them before they are used.

### 8. Add mounts preflight

Add a function that checks mount prerequisites.

Suggested implementation:

```bash
config_preflight_mounts() {
  local required=(
    bash
    awk
    sed
    grep
    mkdir
    rm
    getent
    id
    mount
    umount
    mountpoint
  )
  local cmd

  echo "Preflight scope: mounts"

  config_preflight_check_sudo

  for cmd in "${required[@]}"; do
    config_preflight_require_command "$cmd"
  done

  if command -v mount.cifs >/dev/null 2>&1; then
    config_preflight_ok "CIFS helper available: mount.cifs"
  else
    config_preflight_error "missing CIFS helper: mount.cifs; install cifs-utils or run bootstrap networking step first"
  fi

  if [[ -d /mnt ]]; then
    config_preflight_ok "/mnt exists"
  else
    config_preflight_error "/mnt does not exist"
  fi
}
```

Do not attempt to connect to `//172.27.240.1/...` in this correction. That would be a real network/mount behavior check and belongs in a later health-check or dry-run correction.

### 9. Add the main `config_preflight` dispatcher

Add a dispatcher that defaults to `all` and returns failure if there are any errors.

Suggested implementation:

```bash
config_preflight() {
  local scope="${1:-all}"

  config_runtime_init || return 1
  config_preflight_reset

  case "$scope" in
    all)
      config_preflight_bootstrap
      config_preflight_mounts
      ;;
    bootstrap|install)
      config_preflight_bootstrap
      ;;
    mounts|mount)
      config_preflight_mounts
      ;;
    help|-h|--help)
      cat <<'EOF_PREFLIGHT_HELP'
Usage: config.sh preflight [all|bootstrap|mounts]

Runs read-only checks before bootstrap or mount workflows.
EOF_PREFLIGHT_HELP
      return 0
      ;;
    *)
      echo "[ERROR] Unknown preflight scope: $scope" >&2
      return 2
      ;;
  esac

  printf 'Preflight summary: %s error(s), %s warning(s)\n' "$CONFIG_PREFLIGHT_ERRORS" "$CONFIG_PREFLIGHT_WARNINGS"

  if (( CONFIG_PREFLIGHT_ERRORS > 0 )); then
    return 1
  fi
  return 0
}
```

Do not write preflight markers. The point is to keep it read-only.

### 10. Call preflight from bootstrap and mounts

Update `config_run_bootstrap` so the first real check after runtime init is:

```bash
config_preflight bootstrap || return $?
```

For example:

```bash
config_run_bootstrap() {
  config_runtime_init
  config_preflight bootstrap || return $?
  config_bootstrap_summary
  run_once update_apt UpdateAPT || return $?
  ...
}
```

Update `config_run_mounts` similarly:

```bash
config_run_mounts() {
  config_runtime_init
  config_preflight mounts || return $?
  mounts_run "$@" || return 1
}
```

If the current `config_run_mounts` has special handling for `help|-h|--help`, preserve that handling so `config mount help` does not run preflight.

### 11. Add the command to the main dispatcher

In the bottom `case "$cmd" in` block, add:

```bash
preflight)
  config_preflight "$@"
  ;;
```

Place it near `status` or before `mounts|mount`.

### 12. Keep source-time behavior quiet

After the patch, sourcing `config.sh` must still be quiet and must not run preflight.

This must remain true:

```bash
bash -lc 'source "$HOME/.local/bin/config.sh" >/tmp/config-source.out 2>/tmp/config-source.err; wc -c /tmp/config-source.out /tmp/config-source.err'
```

Expected result: both files are zero bytes, except for unrelated shell-init behavior outside `config.sh`.

## Validation commands

Run only syntax and read-only checks. Do not run installers.

```bash
bash -n "$HOME/.local/bin/config.sh"
bash -n "$HOME/.local/bin/mounts.sh"
bash -n "$HOME/.local/bin/lv.sh"

config preflight help
config preflight bootstrap
config preflight mounts
config preflight all
config status
```

If `config preflight bootstrap` fails because sudo is not cached, run this manually in a terminal and retry:

```bash
sudo -v
config preflight bootstrap
```

Do not run `config bootstrap` as part of producing the patch unless explicitly asked by the user.

## Definition of Done

This correction is done when:

- `config_usage` documents `preflight [scope]`.
- `config preflight`, `config preflight all`, `config preflight bootstrap`, and `config preflight mounts` are accepted commands.
- Preflight is read-only and does not write `.done`, `.running`, `.failed`, or `.skipped` markers.
- Preflight never prompts for a sudo password; it uses `sudo -n true` and explains how to fix the failure.
- Bootstrap preflight checks OS family, apt availability, core shell utilities, non-interactive sudo, and DNS for known bootstrap hosts.
- Mount preflight checks mount utilities, non-interactive sudo, `/mnt`, and `mount.cifs`.
- `config bootstrap` calls bootstrap preflight before any `run_once` install steps.
- `config mounts` calls mount preflight before `mounts_run`, except when showing mount help.
- Sourcing `config.sh` remains quiet and side-effect free.

## Expected follow-up

Correction 13 should build on this by adding bounded retry helpers for `curl`, `wget`, repository-key downloads, and apt repository refreshes. Do not implement those retries in Correction 12.
