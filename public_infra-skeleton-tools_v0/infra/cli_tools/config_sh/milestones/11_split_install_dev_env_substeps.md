# Correction 11: Split `InstallDevEnv` into small idempotent substeps

Source package to paste with this brief: the latest exported VMUser codebase after Correction 10. If your latest export is named `code_full_summary.txt`, paste that file together with this brief.

Backlog position: after Correction 10, before Correction 12

Story Points: 1

Target duration: about 30 minutes

Scope: `/home/vmuser/.local/bin/config.sh` only

## Paste-this brief for a new chat

You are given the current VMUser Linux/WSL configuration export. Please make a minimal, focused patch for Correction 11 only.

The goal is to split the large `InstallDevEnv` function in:

```text
/home/vmuser/.local/bin/config.sh
```

into several small, named, idempotent install functions. This makes retries safer: if Anaconda or Azure CLI fails, the earlier successful pieces do not need to be hidden behind one broad `install_dev_env.done` marker.

The latest expected codebase state already includes these prior corrections:

- `lv.sh` is split out.
- `mounts.sh` exists and the mount workflow is called through `mounts_run`.
- `config.sh` has explicit commands such as `help`, `status`, `mounts`, `bootstrap`, `pull`, and `push`.
- Correction 09 has added safer target-user helpers, including `target_sudo`, `run_as_target`, and `run_as_target_shell`.
- Correction 10 has hardened `run_once` marker behavior and made state target-scoped.

If the pasted codebase does **not** yet contain the safer helper functions from Correction 09, stop and apply Correction 09 first. If the pasted codebase still has the old simple `touch "$STATE_DIR/$name.done"` `run_once`, stop and apply Correction 10 first. Do not mix those corrections into this patch.

## Current problem

`InstallDevEnv` is still one large function that does all of these things in one marker scope:

1. Installs system packages for .NET, Python, build tools, and pyenv support.
2. Appends pyenv and dotnet-tool shell initialization lines.
3. Installs or updates dotnet interactive tools.
4. Upgrades pip and installs `virtualenv` for the target user.
5. Installs pyenv if missing.
6. Installs or updates Anaconda.
7. Adds the Azure CLI apt repository and installs `azure-cli`.
8. Prints verification output.

That means a failure late in the function makes the whole function retry as one unit, while a stale success marker can also hide partial or outdated substeps.

## Goal

Refactor `InstallDevEnv` into named substeps and update `config_run_bootstrap` to call each substep through its own `run_once` marker.

After the patch, bootstrap should be able to progress like this:

```bash
run_once install_dev_env_system_packages InstallDevEnvSystemPackages
run_once install_dev_env_shell_init InstallDevEnvShellInit
run_once install_dev_env_dotnet_tools InstallDevEnvDotnetTools
run_once install_dev_env_python_user_tools InstallDevEnvPythonUserTools
run_once install_dev_env_pyenv InstallDevEnvPyenv
run_once install_dev_env_anaconda InstallDevEnvAnaconda
run_once install_dev_env_azure_cli InstallDevEnvAzureCLI
InstallDevEnvVerify
```

Keep a compatibility wrapper named `InstallDevEnv`, but make it call the new substep functions in order. The main bootstrap path should use the substeps directly.

## Do not change in this correction

Do not implement later backlog items here:

- Do not add new preflight checks. That is Correction 12.
- Do not add download retry wrappers. That is Correction 13.
- Do not fix or rename `install-kubernets`. That is Correction 14.
- Do not change `lv.sh` alias creation. That is Correction 15.
- Do not normalize `.bashrc` include blocks beyond moving the current existing append calls into a substep. That is Correction 16.
- Do not add a full dry-run mode. That is Correction 17.
- Do not add logging or log rotation. That is Correction 18.
- Do not change `mounts.sh`, SMB credentials, or mount behavior.
- Do not change shell startup behavior.
- Do not remove existing `.done` marker files from disk.
- Do not run installers while producing the patch.

## Required implementation

### 1. Add shared dev-env constants

Move the local constants currently inside `InstallDevEnv` into small helper functions or module-level variables near the installer section.

Acceptable minimal pattern:

```bash
DEVENV_ANACONDA_INSTALLER="${DEVENV_ANACONDA_INSTALLER:-Anaconda3-2025.12-2-Linux-x86_64.sh}"
DEVENV_AZURE_REPO_FILE="${DEVENV_AZURE_REPO_FILE:-/etc/apt/sources.list.d/azure-cli.sources}"
DEVENV_MS_KEYRING="${DEVENV_MS_KEYRING:-/etc/apt/keyrings/microsoft.gpg}"
```

Then inside functions, use:

```bash
local anaconda_root="${TARGET_HOME}/anaconda3"
```

Keep these defaults the same as the current code unless there is a syntax problem.

### 2. Create `InstallDevEnvSystemPackages`

Extract only the system package install work:

```bash
InstallDevEnvSystemPackages() {
  sudo apt-get update
  sudo apt-get install -y dotnet-sdk-8.0
  sudo apt-get install -y python3-pip python3-venv
  sudo apt-get install -y \
    make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev \
    libffi-dev liblzma-dev git
}
```

Do not add retry behavior here. Retry wrappers are Correction 13.

### 3. Create `InstallDevEnvShellInit`

Extract the shell-init append operations only:

```bash
InstallDevEnvShellInit() {
  append_once_target "${TARGET_HOME}/.bashrc" 'export PYENV_ROOT="$HOME/.pyenv"'
  append_once_target "${TARGET_HOME}/.bashrc" 'export PATH="$PYENV_ROOT/bin:$HOME/.dotnet/tools:$PATH"'
  append_block_once_target "${TARGET_HOME}/.bashrc" '# >>> pyenv initialize >>>' '# >>> pyenv initialize >>>
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
# <<< pyenv initialize <<<'
}
```

Preserve the current block contents unless a syntax check proves it is malformed.

### 4. Create `InstallDevEnvDotnetTools`

Extract only the dotnet global tool work:

```bash
InstallDevEnvDotnetTools() {
  if run_as_target_shell 'command -v dotnet >/dev/null 2>&1'; then
    run_as_target_shell 'dotnet tool install -g Microsoft.dotnet-interactive 2>/dev/null || dotnet tool update -g Microsoft.dotnet-interactive'
    run_as_target_shell 'dotnet interactive jupyter install'
  else
    echo "[WARN] dotnet not found; skipping dotnet interactive tools" >&2
  fi
}
```

This function should not fail merely because `dotnet` is absent; `InstallDevEnvSystemPackages` should normally install it first, but this warning makes the substep clearer if package availability changes.

### 5. Create `InstallDevEnvPythonUserTools`

Extract only the target-user Python package setup:

```bash
InstallDevEnvPythonUserTools() {
  run_as_target_shell 'python3 -m pip install --upgrade pip'
  run_as_target_shell 'python3 -m pip install --user virtualenv'
}
```

Keep the current behavior. Do not introduce pip retry logic here.

### 6. Create `InstallDevEnvPyenv`

Extract pyenv install behavior:

```bash
InstallDevEnvPyenv() {
  if [[ ! -d "${TARGET_HOME}/.pyenv" ]]; then
    run_as_target_shell 'curl -fsSL https://pyenv.run | bash'
  else
    echo "[INFO] pyenv already exists at ${TARGET_HOME}/.pyenv"
  fi
}
```

Do not add update logic in this correction.

### 7. Create `InstallDevEnvAnaconda`

Extract the existing Anaconda install/update logic:

```bash
InstallDevEnvAnaconda() {
  local anaconda_root="${TARGET_HOME}/anaconda3"

  if [[ -x "$anaconda_root/bin/conda" ]]; then
    run_as_target_shell '"$HOME/anaconda3/bin/conda" update -n base -c defaults conda -y'
  else
    run_as_target_shell "wget -O \"\$HOME/${DEVENV_ANACONDA_INSTALLER}\" \"https://repo.anaconda.com/archive/${DEVENV_ANACONDA_INSTALLER}\"" || return 1
    run_as_target_shell "bash \"\$HOME/${DEVENV_ANACONDA_INSTALLER}\" -b -p \"\$HOME/anaconda3\"" || return 1
    run_as_target_shell "rm -f \"\$HOME/${DEVENV_ANACONDA_INSTALLER}\""
  fi

  run_as_target_shell '"$HOME/anaconda3/bin/conda" config --set auto_activate_base false'
  run_as_target_shell '"$HOME/anaconda3/bin/conda" init bash'
}
```

Preserve the installer filename from the existing code unless the current code already changed it.

### 8. Create `InstallDevEnvAzureCLI`

Extract the Azure CLI repository and package install logic:

```bash
InstallDevEnvAzureCLI() {
  local az_codename

  sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg
  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee "$DEVENV_MS_KEYRING" >/dev/null
  sudo chmod go+r "$DEVENV_MS_KEYRING"

  az_codename="$(lsb_release -cs)"

  sudo tee "$DEVENV_AZURE_REPO_FILE" >/dev/null <<EOF_AZURE_CLI_REPO
Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${az_codename}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: ${DEVENV_MS_KEYRING}
EOF_AZURE_CLI_REPO

  sudo apt-get update
  sudo apt-get install -y azure-cli
}
```

Use a distinct heredoc delimiter such as `EOF_AZURE_CLI_REPO` to avoid accidentally colliding with surrounding script heredocs.

### 9. Create `InstallDevEnvVerify`

Move the verification output to its own function:

```bash
InstallDevEnvVerify() {
  echo "##########################################"
  echo "# Dev environment status.                 #"
  echo "# system: dotnet sdk, python3, azure-cli  #"
  echo "# user: conda, pyenv, dotnet tool, pip    #"
  echo "##########################################"
  echo "[INFO] Verifying ..."

  dotnet --list-sdks || true
  python3 --version || true
  run_as_target_shell 'pyenv --version' 2>/dev/null || echo "[INFO] pyenv shell init not active yet"
  run_as_target_shell '"$HOME/anaconda3/bin/conda" --version' || true
  az version || true
}
```

Verification should not mark the bootstrap as failed just because one reporting command cannot print a version. Its job is observability, not installation.

### 10. Preserve `InstallDevEnv` as a wrapper

Replace the old monolithic `InstallDevEnv` body with:

```bash
InstallDevEnv() {
  InstallDevEnvSystemPackages
  InstallDevEnvShellInit
  InstallDevEnvDotnetTools
  InstallDevEnvPythonUserTools
  InstallDevEnvPyenv
  InstallDevEnvAnaconda
  InstallDevEnvAzureCLI
  InstallDevEnvVerify
}
```

This keeps backwards compatibility for anyone who manually runs `InstallDevEnv` after sourcing `config.sh`.

### 11. Update `config_run_bootstrap`

Replace this broad call:

```bash
run_once install_dev_env InstallDevEnv
```

with substep markers:

```bash
run_once install_dev_env_system_packages InstallDevEnvSystemPackages
run_once install_dev_env_shell_init InstallDevEnvShellInit
run_once install_dev_env_dotnet_tools InstallDevEnvDotnetTools
run_once install_dev_env_python_user_tools InstallDevEnvPythonUserTools
run_once install_dev_env_pyenv InstallDevEnvPyenv
run_once install_dev_env_anaconda InstallDevEnvAnaconda
run_once install_dev_env_azure_cli InstallDevEnvAzureCLI
InstallDevEnvVerify
```

Leave the existing `update_apt`, `standard_apps`, and `install_networking` markers alone.

Do not delete the old `install_dev_env.done` marker from disk. It can remain as historical state; it should no longer control the new substeps.

## Expected final shape

`config.sh` should have one installer section shaped like this:

```bash
# =============================================================================
# Installer functions
# =============================================================================

DEVENV_ANACONDA_INSTALLER="${DEVENV_ANACONDA_INSTALLER:-Anaconda3-2025.12-2-Linux-x86_64.sh}"
DEVENV_AZURE_REPO_FILE="${DEVENV_AZURE_REPO_FILE:-/etc/apt/sources.list.d/azure-cli.sources}"
DEVENV_MS_KEYRING="${DEVENV_MS_KEYRING:-/etc/apt/keyrings/microsoft.gpg}"

UpdateAPT() { ... }
StandardApps() { ... }
InstallNetworking() { ... }

InstallDevEnvSystemPackages() { ... }
InstallDevEnvShellInit() { ... }
InstallDevEnvDotnetTools() { ... }
InstallDevEnvPythonUserTools() { ... }
InstallDevEnvPyenv() { ... }
InstallDevEnvAnaconda() { ... }
InstallDevEnvAzureCLI() { ... }
InstallDevEnvVerify() { ... }
InstallDevEnv() { ... }
```

## Acceptance criteria

The patch is complete when all of these are true:

1. `InstallDevEnv` is no longer a long monolithic function.
2. The new substep functions exist with clear names.
3. `config_run_bootstrap` uses separate `run_once` calls for each install-dev-env substep.
4. The old `InstallDevEnv` function name still exists as a compatibility wrapper.
5. The patch does not modify `lv.sh`, `mounts.sh`, `conda.sh`, `.bash_aliases`, or `.bashrc` directly.
6. The patch does not introduce new shell startup output or startup side effects.
7. The patch does not run installers during patch creation.
8. `bash -n /home/vmuser/.local/bin/config.sh` passes.
9. `bash /home/vmuser/.local/bin/config.sh help` still prints usage text.
10. `bash /home/vmuser/.local/bin/config.sh status` still works and shows state markers.

## Suggested verification commands

Run these after applying the patch:

```bash
bash -n ~/.local/bin/config.sh
bash ~/.local/bin/config.sh help
bash ~/.local/bin/config.sh status

grep -n '^InstallDevEnv' ~/.local/bin/config.sh
grep -n 'install_dev_env_' ~/.local/bin/config.sh
```

Expected `grep` result should show the new functions and these marker names:

```text
install_dev_env_system_packages
install_dev_env_shell_init
install_dev_env_dotnet_tools
install_dev_env_python_user_tools
install_dev_env_pyenv
install_dev_env_anaconda
install_dev_env_azure_cli
```

Optional dry inspection without installing anything:

```bash
sed -n '/^InstallDevEnvSystemPackages()/,/^InstallDevEnv()/p' ~/.local/bin/config.sh
sed -n '/^config_run_bootstrap()/,/^config_run_pull()/p' ~/.local/bin/config.sh
```

## Rollback

If the patch breaks syntax or bootstrap command routing, restore the previous `config.sh` from your backup/export and re-run:

```bash
bash -n ~/.local/bin/config.sh
bash ~/.local/bin/config.sh help
```

Do not remove any existing `.done`, `.failed`, `.running`, or `.lock` state files as part of rollback unless you are deliberately retrying a known failed step.

## Notes for the implementing assistant

- Keep the patch minimal and mechanical.
- Prefer function extraction over behavior changes.
- Preserve existing package lists and URLs.
- Preserve existing output messages except where splitting requires clearer substep messages.
- If the current codebase has already renamed variables or paths, adapt to the current names rather than reintroducing old names.
- If the current codebase still has the old unsafe `run_as_target` helper, do not patch around it here. Tell the user to apply Correction 09 first.
- If the current codebase still has the old simple `run_once`, do not patch around it here. Tell the user to apply Correction 10 first.
