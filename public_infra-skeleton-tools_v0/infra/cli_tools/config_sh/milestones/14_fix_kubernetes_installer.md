# Correction 14: Fix Kubernetes installer

## Purpose

Fix the Kubernetes installer so it is correctly named, configurable, retry-friendly, and safer to rerun.

This is a small follow-up correction after the download/retry helper work. Do not refactor unrelated installers in this step.

## Context from current codebase

The current plan lists Correction 14 as: rename `install-kubernets`, make the Kubernetes version configurable, and validate repo setup.

The current `config.sh` still contains a misspelled Kubernetes installer function named `install-kubernets`. It hardcodes Kubernetes repository path `v1.35`, writes `/etc/apt/sources.list.d/kubernetes.list`, then installs `kubectl`. The bootstrap runner still references the misspelled name in a commented optional `run_once install_kubernets install-kubernets` line.

## Scope

Change only the Kubernetes installer area and the optional bootstrap reference for it.

### In scope

- Rename function `install-kubernets` to `InstallKubernetes`.
- Keep a backwards-compatible shim named `install-kubernets` that calls `InstallKubernetes`, but mark it deprecated in a comment.
- Add configurable variables near the installer:
  - `KUBERNETES_MINOR_VERSION`, defaulting to the current hardcoded minor version if present.
  - `KUBERNETES_APT_KEYRING`, defaulting to `/etc/apt/keyrings/kubernetes-apt-keyring.gpg`.
  - `KUBERNETES_APT_SOURCE`, defaulting to `/etc/apt/sources.list.d/kubernetes.list`.
- Replace hardcoded `v1.35` URL fragments with `v${KUBERNETES_MINOR_VERSION}`.
- Validate `KUBERNETES_MINOR_VERSION` format before using it.
- Use existing retry/download helpers from Correction 13 if they exist.
- Use `config_apt_refresh_if_stale` if it exists; otherwise fall back to `sudo apt-get update`.
- Update the commented optional bootstrap line to use a correctly spelled marker and function name:
  - `# run_once install_kubernetes InstallKubernetes`

### Out of scope

- Do not enable Kubernetes installation by default.
- Do not change Docker, minikube, Terraform, SQL Server, or Azure CLI installers.
- Do not change the `run_once` implementation.
- Do not install Kubernetes during this correction.
- Do not change the global plan file unless explicitly asked.

## Required implementation details

### 1. Add configurable defaults

Near the Kubernetes installer, add defaults like this:

```bash
KUBERNETES_MINOR_VERSION="${KUBERNETES_MINOR_VERSION:-1.35}"
KUBERNETES_APT_KEYRING="${KUBERNETES_APT_KEYRING:-/etc/apt/keyrings/kubernetes-apt-keyring.gpg}"
KUBERNETES_APT_SOURCE="${KUBERNETES_APT_SOURCE:-/etc/apt/sources.list.d/kubernetes.list}"
```

Use the version currently hardcoded in the uploaded file as the default. If the uploaded file uses a different Kubernetes minor version, preserve that version instead of forcing `1.35`.

### 2. Add a small validator

Add a helper such as:

```bash
config_validate_kubernetes_minor_version() {
  case "$KUBERNETES_MINOR_VERSION" in
    [0-9]*.[0-9]*) return 0 ;;
    *)
      echo "[ERROR] KUBERNETES_MINOR_VERSION must look like 1.35, got: $KUBERNETES_MINOR_VERSION" >&2
      return 2
      ;;
  esac
}
```

Prefer a stricter regex if the script already uses Bash regex checks elsewhere.

### 3. Implement `InstallKubernetes`

Replace the misspelled function body with a correctly named function:

```bash
InstallKubernetes() {
  config_validate_kubernetes_minor_version || return 1

  if declare -F config_apt_refresh_if_stale >/dev/null 2>&1; then
    config_apt_refresh_if_stale || return 1
  else
    sudo apt-get update || return 1
  fi

  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg || return 1
  sudo mkdir -p -m 755 /etc/apt/keyrings || return 1

  # download key with retry helper if available
  # write source using v${KUBERNETES_MINOR_VERSION}
  # apt update
  # apt install kubectl
  # verify kubectl version --client
}
```

For the key download:

- If Correction 13 added `config_curl_retry`, use it.
- Otherwise use `curl -fsSL` directly, but keep the call isolated so it can be upgraded later.

Example acceptable pattern:

```bash
local key_url="https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_MINOR_VERSION}/deb/Release.key"

if declare -F config_curl_retry >/dev/null 2>&1; then
  config_curl_retry "$key_url" | sudo gpg --dearmor -o "$KUBERNETES_APT_KEYRING" || return 1
else
  curl -fsSL "$key_url" | sudo gpg --dearmor -o "$KUBERNETES_APT_KEYRING" || return 1
fi
```

Write the apt source with variables:

```bash
printf 'deb [signed-by=%s] https://pkgs.k8s.io/core:/stable:/v%s/deb/ /\n' \
  "$KUBERNETES_APT_KEYRING" \
  "$KUBERNETES_MINOR_VERSION" | sudo tee "$KUBERNETES_APT_SOURCE" >/dev/null
```

Then:

```bash
sudo chmod 644 "$KUBERNETES_APT_SOURCE" || return 1
sudo apt-get update || return 1
sudo apt-get install -y kubectl || return 1
kubectl version --client || return 1
```

### 4. Keep compatibility shim

After `InstallKubernetes`, add:

```bash
# Deprecated compatibility shim. Prefer InstallKubernetes.
install-kubernets() {
  InstallKubernetes "$@"
}
```

This avoids breaking any older command or marker reference while allowing new code to use the corrected name.

### 5. Update optional bootstrap reference

Change this old commented line if present:

```bash
# run_once install_kubernets install-kubernets
```

to:

```bash
# run_once install_kubernetes InstallKubernetes
```

Do not uncomment it.

## Acceptance criteria

- `bash -n ~/.local/bin/config.sh` passes.
- `grep -n "InstallKubernetes" ~/.local/bin/config.sh` finds the new canonical function.
- `grep -n "install-kubernets" ~/.local/bin/config.sh` finds only the deprecated compatibility shim and no bootstrap `run_once` reference.
- `grep -n "v1.35" ~/.local/bin/config.sh` should not find hardcoded Kubernetes repository URLs unless `1.35` appears only inside the default variable assignment.
- `config status` still works.
- Kubernetes install remains optional and disabled by default.

## Suggested verification commands

```bash
bash -n ~/.local/bin/config.sh
config status

grep -n "InstallKubernetes\|install-kubernets\|KUBERNETES_MINOR_VERSION" ~/.local/bin/config.sh

grep -n "run_once install_kubernetes" ~/.local/bin/config.sh
```

Do not run `InstallKubernetes` as part of this correction unless the user explicitly asks to install Kubernetes.

## Definition of Done

This correction is done when the Kubernetes installer has a correctly named canonical function, a deprecated compatibility shim, a configurable minor version, variable-based repo/keyring paths, and an updated optional bootstrap reference.
