# AN1-10 — Self-Documenting Config Files and Declarative Install Manifests

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Extend AN1-09 so configuration and installation policy are easier to manage without editing shell scripts.

There are two related goals:

```text
1. Make generated config files self-documenting with clear comments.
2. Move installation definitions out of config.sh/mounts.sh into editable manifest files.
```

The scripts should become engines:

```text
config.sh  = parser, validator, executor, state manager
mounts.sh  = mount executor
*.env      = target/user defaults
*.steps    = bootstrap step order and default plan state
*.manifest = installation package/command definitions
```

A normal operator or future companion should be able to understand what to edit by reading the config files.

## Why this milestone exists

The current implementation still hard-codes too much inside shell scripts:

```text
bootstrap step list
default step states
apt package lists
installer URLs
tool versions
repo/keyring paths
which steps are network-dependent
which steps are system-level vs target-user-level
mount identity defaults
```

That makes every operational change require editing shell code.

The desired direction is:

```text
Change policy/configuration by editing files.
Change execution behavior by editing shell scripts.
```

## Scope

Edit primarily:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/bin/mounts.sh
```

Create config/manifest files under:

```text
/home/vmuser/.local/etc/config-sh/
```

Recommended layout:

```text
/home/vmuser/.local/etc/config-sh/
  config.env
  targets/
    vmuser.env
    labuser.env
  bootstrap/
    steps.tsv
    profiles/
      default.plan
      admin.plan
      lab.plan
  install/
    packages.env
    commands.env
    versions.env
    repos.env
  mounts/
    mounts.env
```

Keep the layout simple. It is acceptable to use fewer files if implementation stays clean.

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

## Part A — Self-documenting config files

### 1. Improve `config config-init`

When `config config-init` creates files, each generated file must include comments explaining:

```text
what the file controls
which values are safe to edit
which values should not contain secrets
how the file participates in precedence
example values
```

The comments should guide a companion or future operator.

### 2. Global config file template

Generate or update the template for:

```text
/home/vmuser/.local/etc/config-sh/config.env
```

Example content:

```bash
# config-sh global defaults
#
# This file controls defaults shared by all target users.
# It is safe to edit these values.
#
# Load order:
#   1. built-in script defaults
#   2. this global config file
#   3. targets/USER.env
#   4. environment variables
#   5. command-line options
#
# Do not put passwords or SMB secrets in this file.
# Use credentials files under ~/.local/share/wsl-mounts instead.

# Users that are allowed to sync system-level files during pull/push.
# Space-separated list.
CONFIG_ADMIN_TARGETS="vmuser"

# Default behavior for syncing /etc/resolv.conf.
# 0 = exclude unless explicitly requested
# 1 = include by default
CONFIG_SYNC_RESOLV_CONF_DEFAULT="0"

# Default SMB username mapping.
# Per-target files may override these with SMB_USER_DEFAULT.
CONFIG_DEFAULT_SMB_USER_VMUSER="hector"
CONFIG_DEFAULT_SMB_USER_LABUSER="labuser"

# Default ingress/egress SMB identities.
SMB_USER_INGRESS_DEFAULT="labuser"
SMB_USER_EGRESS_DEFAULT="labuser"

# Default WSL distro name used by mount templates if DISTRONAME is unset.
MOUNTS_DISTRONAME_DEFAULT="jepabio-Ubuntu-22.04"

# Default bootstrap profile used when a target file does not set one.
BOOTSTRAP_PROFILE_DEFAULT="default"
```

### 3. Per-target config template

Generate:

```text
/home/vmuser/.local/etc/config-sh/targets/labuser.env
/home/vmuser/.local/etc/config-sh/targets/vmuser.env
```

Example `labuser.env`:

```bash
# Target config for labuser
#
# This file controls defaults used when running:
#   config --target labuser ...
#
# Safe to edit:
#   TARGET_ROLE
#   SMB_USER_DEFAULT
#   BOOTSTRAP_PROFILE
#   SYNC_SYSTEM_ITEMS
#
# Do not put passwords here.

TARGET_ROLE="lab"
SMB_USER_DEFAULT="labuser"
SMB_USER_INGRESS_DEFAULT="labuser"
SMB_USER_EGRESS_DEFAULT="labuser"
BOOTSTRAP_PROFILE="lab"
SYNC_SYSTEM_ITEMS="0"
```

Example `vmuser.env`:

```bash
# Target config for vmuser
#
# vmuser is the administrative target by default.

TARGET_ROLE="admin"
SMB_USER_DEFAULT="hector"
SMB_USER_INGRESS_DEFAULT="labuser"
SMB_USER_EGRESS_DEFAULT="labuser"
BOOTSTRAP_PROFILE="admin"
SYNC_SYSTEM_ITEMS="1"
```

### 4. Config help

Update:

```bash
config help config
config help howto
config help menu
```

to mention that generated config files are commented and intended to be edited.

## Part B — Declarative bootstrap step definitions

### 5. Externalize bootstrap step order

Current `config_bootstrap_steps` hard-codes the step list.

Add support for:

```text
/home/vmuser/.local/etc/config-sh/bootstrap/steps.tsv
```

Suggested format:

```text
# state is not stored here; this file defines known steps and execution metadata.
# columns:
#   step_name<TAB>function_name<TAB>scope<TAB>network<TAB>description

update_apt<TAB>UpdateAPT<TAB>system<TAB>1<TAB>Refresh apt metadata and upgrade packages
standard_apps<TAB>StandardApps<TAB>system<TAB>1<TAB>Install common system tools
install_networking<TAB>InstallNetworking<TAB>system<TAB>1<TAB>Install network and CIFS tools
install_dev_env_system_packages<TAB>InstallDevEnvSystemPackages<TAB>system<TAB>1<TAB>Install system packages for developer tools
install_dev_env_shell_init<TAB>InstallDevEnvShellInit<TAB>target<TAB>0<TAB>Update target shell init files
install_dev_env_dotnet_tools<TAB>InstallDevEnvDotnetTools<TAB>target<TAB>1<TAB>Install dotnet interactive tools
install_dev_env_python_user_tools<TAB>InstallDevEnvPythonUserTools<TAB>target<TAB>1<TAB>Install target Python user tools
install_dev_env_pyenv<TAB>InstallDevEnvPyenv<TAB>target<TAB>1<TAB>Install pyenv under target home
install_dev_env_anaconda<TAB>InstallDevEnvAnaconda<TAB>target<TAB>1<TAB>Install Anaconda under target home
install_dev_env_azure_cli<TAB>InstallDevEnvAzureCLI<TAB>system<TAB>1<TAB>Install Azure CLI
install_dev_env_verify<TAB>InstallDevEnvVerify<TAB>mixed<TAB>0<TAB>Verify developer environment
install_gui_support<TAB>InstallGUISupport<TAB>mixed<TAB>1<TAB>Install GUI/X11 support
install_docker<TAB>InstallDocker<TAB>system<TAB>1<TAB>Install Docker engine and grant target access
install_terraform<TAB>InstallTerraform<TAB>system<TAB>1<TAB>Install Terraform
install_kubernets<TAB>InstallKubernetes<TAB>system<TAB>1<TAB>Install Kubernetes tools
install_minikube<TAB>InstallMinikube<TAB>system<TAB>1<TAB>Install minikube
install_sqlserver_support_2004<TAB>InstallSQLServerSupport2004<TAB>system<TAB>1<TAB>Install SQL Server ODBC support
install_sqlserver_cli_tool_2204<TAB>InstallSQLServerCLITool2204<TAB>system<TAB>1<TAB>Install SQL Server CLI tools
```

Real file should contain actual tab characters, not the literal string `<TAB>`.

### 6. Safe validation for step manifest

Add a parser that validates:

```text
- exactly 5 columns
- step_name matches ^[A-Za-z0-9_.-]+$
- function_name matches ^[A-Za-z_][A-Za-z0-9_]*$
- scope is system|target|mixed
- network is 0|1
- function_name is in an allowlist
```

Do not execute arbitrary function names from the file.

Important security rule:

```text
Manifest files select from known allowed functions.
They must not allow arbitrary shell commands.
```

Implement allowlist helper:

```bash
config_bootstrap_function_allowed() {
  case "$1" in
    UpdateAPT|StandardApps|InstallNetworking|InstallDevEnvSystemPackages|InstallDevEnvShellInit|InstallDevEnvDotnetTools|InstallDevEnvPythonUserTools|InstallDevEnvPyenv|InstallDevEnvAnaconda|InstallDevEnvAzureCLI|InstallDevEnvVerify|InstallGUISupport|InstallDocker|InstallTerraform|InstallKubernetes|InstallMinikube|InstallSQLServerSupport2004|InstallSQLServerCLITool2204)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
```

### 7. Keep built-in fallback

If `steps.tsv` is missing or invalid, fall back to the built-in step list with a warning.

Do not break existing systems.

### 8. Refactor step helpers to use manifest

Update these to read from step manifest where possible:

```bash
config_bootstrap_steps
config_bootstrap_step_is_known
config_bootstrap_step_needs_network
config_bootstrap_run_step_by_name
```

`config_bootstrap_run_step_by_name` must still dispatch safely through an allowlist.

Preferred implementation:

```bash
function_name="$(config_bootstrap_function_for_step "$step")"
config_bootstrap_function_allowed "$function_name" || return 1
run_once "$step" "$function_name"
```

Only if function allowlist passes.

## Part C — Declarative plan profiles

### 9. Externalize default plan states

Add profile files:

```text
/home/vmuser/.local/etc/config-sh/bootstrap/profiles/default.plan
/home/vmuser/.local/etc/config-sh/bootstrap/profiles/admin.plan
/home/vmuser/.local/etc/config-sh/bootstrap/profiles/lab.plan
```

Format:

```text
# columns:
#   state STEP_NAME
pending update_apt
pending standard_apps
pending install_networking
...
skipped install_docker
```

These files are templates used by:

```bash
config bootstrap plan-init
```

only when `bootstrap.plan` is missing.

Existing target `bootstrap.plan` files must not be rewritten.

### 10. Profile selection

Target config controls profile:

```bash
BOOTSTRAP_PROFILE="lab"
```

Plan init resolves:

```text
profiles/$BOOTSTRAP_PROFILE.plan
```

If missing:

```text
profiles/default.plan
```

If still missing:

```text
built-in fallback
```

### 11. Validate profile plan

Reuse existing plan validation:

```text
state must be next|pending|skipped
step must be known
```

## Part D — Externalize package/version/repo definitions

### 12. Add install metadata files

Create:

```text
/home/vmuser/.local/etc/config-sh/install/packages.env
/home/vmuser/.local/etc/config-sh/install/versions.env
/home/vmuser/.local/etc/config-sh/install/repos.env
```

These are not full arbitrary scripts. They are config values consumed by existing install functions.

Examples:

```bash
# versions.env
DEVENV_ANACONDA_INSTALLER="Anaconda3-2025.12-2-Linux-x86_64.sh"
CONFIG_DOTNET_INTERACTIVE_VERSION="1.0.522904"
CONFIG_KUBERNETES_MINOR_VERSION="v1.36"
```

```bash
# repos.env
DEVENV_AZURE_REPO_FILE="/etc/apt/sources.list.d/azure-cli.sources"
DEVENV_MS_KEYRING="/etc/apt/keyrings/microsoft.gpg"
```

For package groups, use simple whitespace-separated package names:

```bash
# packages.env
APT_STANDARD_APPS="cmatrix dos2unix ccze rs reminiscence xfce4 xfce4-terminal zsh"
APT_NETWORKING="ethtool net-tools wslu cifs-utils"
APT_DEVENV_SYSTEM="dotnet-sdk-8.0 python3-pip python3-venv make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev git"
APT_GUI_SUPPORT="mesa-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev"
```

### 13. Refactor package install functions

Change package install functions to use config values with built-in fallback:

```bash
StandardApps() {
  config_apt_refresh_if_stale || return 1
  config_apt_install_list APT_STANDARD_APPS "cmatrix dos2unix ccze rs reminiscence xfce4 xfce4-terminal zsh"
}
```

Add helper:

```bash
config_apt_install_list() {
  local var_name="$1"
  local fallback="$2"
  local value="${!var_name:-$fallback}"
  local -a packages=()

  read -r -a packages <<< "$value"
  config_validate_package_list "$var_name" "${packages[@]}" || return 1
  config_apt_install "${packages[@]}"
}
```

Validate package lists before using:

```text
package token allowed pattern: ^[A-Za-z0-9.+:_-]+$
```

### 14. No arbitrary command manifests yet

Do not implement arbitrary external shell commands in this milestone.

Important:

```text
Do not let manifests contain shell command lines to execute.
Do not add eval.
Do not source command files.
Do not run arbitrary commands from config.
```

The first safe step is:

```text
externalize metadata and package lists,
but keep execution functions in code.
```

A later milestone can add a more powerful declarative action engine if needed.

## Part E — Config/manifest status and inspection

### 15. Add config inspection

Add command:

```bash
config config-show
```

Output:

```text
Config files:
  global: /home/vmuser/.local/etc/config-sh/config.env
  target: /home/vmuser/.local/etc/config-sh/targets/labuser.env
  steps:  /home/vmuser/.local/etc/config-sh/bootstrap/steps.tsv
  profile:/home/vmuser/.local/etc/config-sh/bootstrap/profiles/lab.plan

Effective target policy:
  TARGET_USER=labuser
  TARGET_HOME=/home/labuser
  TARGET_ROLE=lab
  BOOTSTRAP_PROFILE=lab
  SYNC_SYSTEM_ITEMS=0
  SMB_USER=labuser
  SMB_USER_INGRESS=labuser
  SMB_USER_EGRESS=labuser

Install metadata:
  CONFIG_KUBERNETES_MINOR_VERSION=v1.36
  CONFIG_DOTNET_INTERACTIVE_VERSION=1.0.522904
  DEVENV_ANACONDA_INSTALLER=...
```

Do not print secrets or credential file contents.

### 16. Add bootstrap steps inspection

Add command:

```bash
config bootstrap steps
```

Output:

```text
Bootstrap steps:
  Step                               Scope   Network  Function                         Description
  update_apt                         system  yes      UpdateAPT                         Refresh apt metadata and upgrade packages
  install_dev_env_shell_init         target  no       InstallDevEnvShellInit            Update target shell init files
```

This helps operators understand what is available without opening scripts.

## Help update

Update:

```bash
config help
config help config
config help menu
config help howto
config help bootstrap
```

Add:

```text
config config-init     Create commented config and manifest templates
config config-show     Show effective config without secrets
config bootstrap steps Show known bootstrap steps from manifest
```

Mention:

```text
Edit config files to change policy.
Edit shell scripts only to change execution logic.
```

## Acceptance

- `config config-init` creates commented config files.
- Config files clearly explain what they control.
- Target config files clearly explain safe values and no-secret rule.
- `bootstrap/steps.tsv` exists and is commented.
- `bootstrap/profiles/*.plan` exist and are commented.
- `install/packages.env`, `install/versions.env`, and `install/repos.env` exist and are commented.
- Existing systems still work if config files are missing.
- Unsafe config/env lines are rejected or ignored and not executed.
- Unsafe package tokens are rejected before apt install.
- `config bootstrap steps` shows known steps from manifest or fallback.
- `config config-show` shows effective config without secrets.
- `config_bootstrap_steps` uses manifest or fallback.
- `config_bootstrap_step_needs_network` uses manifest metadata or fallback.
- `config_bootstrap_run_step_by_name` uses manifest metadata only through an allowlist.
- `config bootstrap plan-init` uses selected profile when creating a missing plan.
- Existing target `bootstrap.plan` files are not overwritten.
- Existing plan-apply, skip, unskip, rm, and bootstrap step behavior remains intact.
- No arbitrary command execution from manifests.
- No `eval` introduced.
- Shell syntax passes.
- No broad bootstrap/install/mount/package command is run in postcheck.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_10_self_documenting_config_and_install_manifests_postcheck.log
```

Use simple evidence-log style:

```text
AN1-10 self-documenting config and declarative install manifests postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
mounts.sh syntax exit=0
create-cifs-credentials-files.sh syntax exit=0 or SKIP if unchanged
Result: PASS

[2] Config init templates
Command attempted:
config config-init

Observed:
- Created/kept config.env with comments.
- Created/kept targets/vmuser.env with comments.
- Created/kept targets/labuser.env with comments.
- Created/kept bootstrap/steps.tsv with comments.
- Created/kept bootstrap/profiles/default.plan with comments.
- Created/kept bootstrap/profiles/admin.plan with comments.
- Created/kept bootstrap/profiles/lab.plan with comments.
- Created/kept install/packages.env with comments.
- Created/kept install/versions.env with comments.
- Created/kept install/repos.env with comments.
- Existing files were not overwritten.

Result: PASS

[3] Config inspection
Command attempted:
config --target labuser config-show

Observed:
- Effective target policy printed.
- Loaded config/manifest paths printed.
- No secrets printed.

Result: PASS

[4] Bootstrap steps inspection
Command attempted:
config --target labuser bootstrap steps

Observed:
- Step table printed.
- Scope, network flag, function, and description shown.
- Data came from steps.tsv or fallback with clear source.

Result: PASS

[5] Manifest validation
Setup:
Temporary invalid steps.tsv with unknown function or unsafe step name.

Observed:
- Manifest was rejected or fallback was used with warning.
- No arbitrary function or command was executed.

Result: PASS

[6] Package list validation
Setup:
Temporary unsafe package token in packages.env.

Observed:
- Package list validation rejected the unsafe token.
- No apt command was run.

Result: PASS

[7] Profile plan-init behavior
Command attempted on safe missing-plan fixture:
sudo config --target labuser bootstrap plan-init

Observed:
- Selected profile from BOOTSTRAP_PROFILE.
- Created bootstrap.plan from profile.
- Existing live plan was not overwritten.

Result: PASS or SKIP
Reason if SKIP: live target already had plan; static/profile validation verified.

[8] Regression
Observed:
- config help works.
- config help config works.
- bootstrap status works.
- bootstrap plan works.
- plan-apply works.
- skip/unskip/rm dispatch works.
- bootstrap step dispatch works.

Result: PASS

[9] Safety
Observed:
- No broad bootstrap/install/mount command was run.
- No apt/docker/kubectl/minikube/sqlcmd command was run.
- No eval was introduced for config/manifest execution.
- No secrets were printed.

Result: PASS

Overall
- Config files are self-documenting.
- Installation metadata and bootstrap step policy are manageable outside shell scripts.
- Shell scripts remain safe execution engines.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/mounts.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/create-cifs-credentials-files.sh

config config-init
config --target labuser config-show
config --target labuser status
config --target labuser bootstrap steps
config --target labuser bootstrap status
config help config
config help bootstrap
config help howto
config help menu
```

Do not run broad execution in this milestone:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
sudo config --target labuser mount
sudo config --target labuser pull
sudo config --target labuser push
```
