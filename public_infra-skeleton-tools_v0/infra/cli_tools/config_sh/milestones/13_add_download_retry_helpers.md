# Correction 13: Add bounded download and repository retry helpers

## Purpose

Add a small, reusable retry layer for transient network and repository failures in the bootstrap installer. The current codebase already has preflight work and split `InstallDevEnv*` steps, but several operations still call `curl`, `wget`, and `apt-get update` directly. This correction should make those operations more resilient without hiding permanent failures or changing the overall bootstrap workflow.

## Context from the current codebase

The latest uploaded `code_full_summary.txt` shows these relevant patterns:

- `UpdateAPT`, `StandardApps`, `InstallNetworking`, and `InstallDevEnvSystemPackages` use `config_apt_refresh_if_stale` before package installation.
- `InstallDevEnvPyenv` still downloads via `curl -fsSL https://pyenv.run | bash`.
- `InstallDevEnvAnaconda` still downloads the Anaconda installer with `wget -O ...`.
- `InstallDevEnvAzureCLI`, `InstallDocker`, `InstallTerraform`, `install-kubernets`, `install-minikube`, and SQL Server install helpers still use direct `curl`, `wget`, and `sudo apt-get update` calls.
- Earlier VSCodium logs showed network/DNS failures such as `getaddrinfo EAI_AGAIN`, so transient download failures are a real operational risk.

## Story size

Story Points: 1  
Target duration: about 30 minutes

## Scope

Implement only the retry helper primitives and apply them to the obvious direct network/repository calls. Do not redesign installers, rename Kubernetes functions, change package lists, or alter marker semantics in this correction.

## Required changes

### 1. Add generic retry helpers near the existing config helper functions

Add these functions near the other `config_*` helpers in `config.sh`:

```bash
config_retry() {
  local attempts="${CONFIG_RETRY_ATTEMPTS:-3}"
  local delay="${CONFIG_RETRY_DELAY_SECONDS:-3}"
  local label="${1:-command}"
  shift || true

  (($#)) || { echo "[ERROR] config_retry requires a command" >&2; return 2; }

  local i rc
  for ((i = 1; i <= attempts; i++)); do
    echo "[INFO] $label: attempt $i/$attempts"
    "$@"
    rc=$?
    if (( rc == 0 )); then
      return 0
    fi
    if (( i < attempts )); then
      echo "[WARN] $label failed with exit $rc; retrying in ${delay}s" >&2
      sleep "$delay"
    fi
  done

  echo "[ERROR] $label failed after $attempts attempts" >&2
  return "$rc"
}

config_curl_to_stdout() {
  local url="$1"
  config_retry "curl $url" curl -fsSL "$url"
}

config_wget_to_file() {
  local dest="$1" url="$2"
  config_retry "wget $url" wget -O "$dest" "$url"
}

config_wget_to_stdout() {
  local url="$1"
  config_retry "wget $url" wget -O- "$url"
}

config_apt_update() {
  config_retry "apt-get update" sudo apt-get update
}
```

Keep the helpers simple. They should:

- retry a bounded number of times;
- print which attempt is running;
- return the real final non-zero exit code;
- not swallow errors;
- not use infinite loops;
- not require external dependencies beyond standard shell tools.

### 2. Route stale apt refresh through the retry helper

If `config_apt_refresh_if_stale` exists, change its internal `sudo apt-get update` call to:

```bash
config_apt_update
```

If `config_apt_refresh_if_stale` does not exist in the pasted code, add it as a small wrapper and make it call `config_apt_update`:

```bash
config_apt_refresh_if_stale() {
  local stamp="${STATE_DIR:-$HOME/.local/state/config-sh}/apt-update.stamp"
  local max_age_seconds="${CONFIG_APT_REFRESH_MAX_AGE_SECONDS:-21600}"
  local now last

  mkdir -p -- "$(dirname -- "$stamp")"
  now="$(date +%s)"
  last="0"
  [[ -f "$stamp" ]] && last="$(stat -c %Y "$stamp" 2>/dev/null || echo 0)"

  if (( now - last < max_age_seconds )); then
    echo "[INFO] apt metadata is fresh enough; skipping apt-get update"
    return 0
  fi

  config_apt_update || return 1
  touch "$stamp"
}
```

Do not force every package install to run a fresh `apt-get update`; the existing stale-refresh behavior should remain.

### 3. Replace direct `sudo apt-get update` calls that still remain

Replace remaining direct calls like this:

```bash
sudo apt-get update
```

with:

```bash
config_apt_update
```

or, if the function is a normal package-install function that can use the stale cache:

```bash
config_apt_refresh_if_stale || return 1
```

Use the following rule:

- use `config_apt_refresh_if_stale` before ordinary package installs;
- use `config_apt_update` immediately after adding or changing a repository file, because apt must refresh immediately after repository changes.

### 4. Replace direct curl key downloads

Replace patterns like:

```bash
curl -fsSL URL | sudo tee FILE >/dev/null
```

with:

```bash
config_curl_to_stdout "URL" | sudo tee FILE >/dev/null
```

Replace patterns like:

```bash
curl -fsSL URL | gpg --dearmor | sudo tee FILE >/dev/null
```

with:

```bash
config_curl_to_stdout "URL" | gpg --dearmor | sudo tee FILE >/dev/null
```

Replace patterns like:

```bash
curl -fsSL URL | sudo gpg --dearmor -o FILE
```

with:

```bash
config_curl_to_stdout "URL" | sudo gpg --dearmor -o FILE
```

Do not retry the `gpg` part separately in this correction.

### 5. Replace direct wget downloads

Replace Anaconda-style downloads:

```bash
wget -O "$HOME/$DEVENV_ANACONDA_INSTALLER" "https://repo.anaconda.com/archive/$DEVENV_ANACONDA_INSTALLER"
```

with the retry helper, preserving execution as the target user. For example:

```bash
run_as_target_shell "$(cat <<'EOS'
config_wget_to_file "$HOME/${DEVENV_ANACONDA_INSTALLER}" "https://repo.anaconda.com/archive/${DEVENV_ANACONDA_INSTALLER}"
EOS
)"
```

If passing shell functions into `run_as_target_shell` is awkward, use a minimal retry loop inside the target-user command for this one call. Do not make this correction large by redesigning `run_as_target_shell`.

Replace stdout downloads like:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

with:

```bash
config_wget_to_stdout "https://apt.releases.hashicorp.com/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

### 6. Replace direct curl binary downloads

Replace minikube-style downloads:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 || return 1
```

with a retry helper variant. Either add this helper:

```bash
config_curl_download_here() {
  local url="$1"
  config_retry "curl download $url" curl -fL -O "$url"
}
```

and then use:

```bash
config_curl_download_here "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64" || return 1
```

or use `config_retry` directly.

## Constraints

- Do not change command names exposed to the user.
- Do not rename `install-kubernets` here; that is Correction 14.
- Do not add third-party retry tools.
- Do not retry destructive commands such as `rm`, `usermod`, or `groupadd`.
- Do not retry `sudo apt-get install` yet unless the retry wrapper is clearly safe and narrowly applied. This correction is primarily for metadata refreshes and downloads.
- Keep all new helpers safe to source: defining the functions must not run network calls, apt, sudo, or filesystem writes.

## Suggested implementation order

1. Add `config_retry`, download helpers, and `config_apt_update`.
2. Wire `config_apt_refresh_if_stale` through `config_apt_update`.
3. Replace direct repository-key downloads in Azure CLI, Docker, Terraform, Kubernetes, and SQL Server helpers.
4. Replace direct `sudo apt-get update` after repo file creation with `config_apt_update`.
5. Replace Anaconda and minikube direct downloads if this can be done cleanly within the 30-minute scope.
6. Run syntax and grep checks.

## Validation commands

Run these after patching:

```bash
bash -n ~/.local/bin/config.sh
bash ~/.local/bin/config.sh help >/tmp/config-help.out
bash ~/.local/bin/config.sh status >/tmp/config-status.out

grep -n "sudo apt-get update" ~/.local/bin/config.sh || true
grep -n "curl -fsSL" ~/.local/bin/config.sh || true
grep -n "wget -O" ~/.local/bin/config.sh || true
```

Expected results:

- `bash -n` passes.
- `help` and `status` still work.
- Remaining direct `curl`/`wget`/`apt-get update` lines are either intentionally left for a later correction or documented with a comment.
- Sourcing `config.sh` remains quiet:

```bash
bash -lc 'source ~/.local/bin/config.sh' >/tmp/source-config.out 2>/tmp/source-config.err
wc -c /tmp/source-config.out /tmp/source-config.err
```

The output/error byte counts should be zero or only contain known harmless shell diagnostics.

## Definition of Done

- A reusable bounded retry helper exists.
- `apt-get update` goes through `config_apt_update` or stale-refresh logic.
- Repository-key downloads use retry helpers.
- Installer downloads for pyenv, Anaconda, and minikube are either retried or explicitly marked as remaining work with comments.
- No helper executes network work when `config.sh` is sourced.
- `config.sh help` and `config.sh status` continue to run successfully.

## Paste request for the implementation chat

Use this request after uploading the latest `code_full_summary.txt` or `code_full_text.txt`:

> Apply Correction 13 only. Add bounded retry helpers for apt repository refreshes and download commands in `config.sh`. Replace direct `sudo apt-get update`, `curl -fsSL`, and `wget` repository/download calls where safe. Keep this change small and do not rename Kubernetes functions or redesign installer structure. Provide a minimal patch and validation commands.
