# AN1-11 — Split Installer Functions into Trusted Library Module

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Move the actual installer function implementations out of:

```text
/home/vmuser/.local/bin/config.sh
```

into a trusted sourced library module:

```text
/home/vmuser/.local/lib/config-sh/installers.sh
```

Keep `config.sh` as the command/state engine.

Keep `/home/vmuser/.local/etc/config-sh/` as declarative configuration only.

## Why this milestone exists

The codebase is getting large. `config.sh` currently mixes too many responsibilities:

```text
CLI parsing
target selection
config loading
help text
bootstrap plan logic
marker/state management
run_once execution wrapper
pull/push logic
installer function bodies
package install helpers
repo setup helpers
uninstall cleanup logic
```

The installer function bodies are trusted shell code, but they are not the same kind of logic as plan/state/CLI handling.

They should live in a source-code library module, not in config files.

## Desired final layout

```text
/home/vmuser/.local/bin/config
  tiny executable launcher

/home/vmuser/.local/bin/config.sh
  main CLI engine:
    target handling
    config loading
    help
    bootstrap plan/status
    markers
    run_once
    safe dispatch
    pull/push
    mount delegation

/home/vmuser/.local/lib/config-sh/installers.sh
  trusted installer implementation functions:
    UpdateAPT
    StandardApps
    InstallDocker
    InstallTerraform
    InstallDevEnvAnaconda
    ...

/home/vmuser/.local/etc/config-sh/
  editable declarative policy:
    target defaults
    package lists
    versions
    repo paths
    step manifest
    bootstrap profiles

/home/labuser/.local/state/config-sh/
  target runtime state:
    bootstrap.plan
    *.done
    *.skipped
    *.failed
    *.running
```

## Important boundary

Do not move installer shell logic into `/home/vmuser/.local/etc/config-sh`.

`etc` files should stay declarative:

```text
package names
version strings
repo/keyring paths
bootstrap profiles
step metadata
target policy
mount defaults
```

Actual executable shell behavior belongs in trusted source files:

```text
/home/vmuser/.local/bin/*.sh
/home/vmuser/.local/lib/config-sh/*.sh
```

No arbitrary commands from config files.
No `eval`.
No manifest-driven shell command execution.

## Scope

Edit primarily:

```text
/home/vmuser/.local/bin/config.sh
```

Create:

```text
/home/vmuser/.local/lib/config-sh/installers.sh
```

Optionally create directory:

```text
/home/vmuser/.local/lib/config-sh/
```

Do not change:

```text
/home/vmuser/.local/etc/config-sh/*
```

except help text or config-init comments if necessary.

Do not run broad execution:

```text
bootstrap
install
mount
pull
push
apt
docker
kubectl
minikube
sqlcmd
```

## Source module loading

Add library path helpers in `config.sh`:

```bash
CONFIG_LIB_DIR="${CONFIG_LIB_DIR:-/home/vmuser/.local/lib/config-sh}"
CONFIG_INSTALLERS_LIB="${CONFIG_INSTALLERS_LIB:-$CONFIG_LIB_DIR/installers.sh}"
```

Source the installers library after the generic helpers it needs are defined.

Important ordering:

```text
1. target/session helpers
2. config loading helpers
3. run_as_target / append helpers
4. apt retry/helper functions if kept in config.sh
5. source installers.sh
6. bootstrap manifest/plan/dispatch functions
7. CLI dispatch
```

If installer functions need helpers such as `config_apt_install_list`, either:

```text
Option A: keep generic helpers in config.sh before sourcing installers.sh
Option B: move those helpers into installers.sh with the installer functions
```

Preferred:

```text
Move installer-specific apt/package helpers into installers.sh.
Keep generic retry helper in config.sh only if used outside installers.
```

## Move these installer functions

Move these function bodies from `config.sh` into `installers.sh`:

```text
UpdateAPT
StandardApps
InstallNetworking
InstallDevEnvSystemPackages
InstallDevEnvShellInit
InstallDevEnvDotnetTools
InstallDevEnvPythonUserTools
InstallDevEnvPyenv
InstallDevEnvAnaconda
InstallDevEnvAzureCLI
InstallDevEnvVerify
InstallDevEnv
InstallGUISupport
InstallDocker
InstallTerraform
InstallKubernetes
InstallMinikube
InstallSQLServerSupport2004
InstallSQLServerCLITool2204
```

Also move legacy/lowercase compatibility wrappers if they still exist and are used:

```text
install-kubernets
install-minikube
```

If duplicate function definitions exist, consolidate them carefully.

The active canonical names should match the allowlist and manifest:

```text
InstallKubernetes
InstallMinikube
```

## Move installer-specific helpers if appropriate

Move these into `installers.sh` if they are only used by installers:

```text
config_apt_lists_fresh
config_apt_refresh_if_stale
config_apt_install
config_apt_install_list
config_validate_package_list
config_apt_remove_if_installed
config_normalize_azure_cli_repo
config_retry
config_curl_retry
config_wget_retry
```

However, if `config.sh` uses a helper outside installer/uninstaller flows, keep it in `config.sh`.

Be conservative: avoid breaking call order.

## Uninstall cleanup functions

`config_rm_step` calls cleanup behavior.

Move or keep these consistently:

```text
config_uninstall_step
config_rm_marker
```

Preferred split:

```text
config_rm_step      stays in config.sh because it is state/CLI behavior
config_rm_marker    stays in config.sh because it removes marker state
config_uninstall_step moves to installers.sh because it knows installer cleanup behavior
```

That keeps state management in `config.sh` and installer cleanup knowledge in `installers.sh`.

## Keep in config.sh

Do not move these out in this milestone:

```text
config_set_target_user
config_refresh_session_context
config_load_env_file
config_load_config_files
config_init_example_files
config_show
run_once
config_bootstrap_function_allowed
config_bootstrap_step_manifest_rows
config_bootstrap_steps
config_bootstrap_run_step_by_name
config_run_bootstrap_step
config_run_bootstrap
config_bootstrap_plan_*
config_skip_step
config_unskip_step
config_rm_step
CopyConfigFiles
PushConfigFiles
config_run_pull
config_run_push
config_run_mounts
config_run_user
CLI dispatch case block
help functions
```

Rationale:

```text
config.sh remains the engine and orchestration layer.
installers.sh contains trusted install/cleanup behavior.
```

## Library header

Create `installers.sh` with a clear header:

```bash
#!/usr/bin/env bash
# Trusted installer implementation library for config.sh.
#
# This file is source-only. Do not execute it directly.
#
# Responsibilities:
#   - install/update functions called by bootstrap steps
#   - installer-specific package/repo/version helpers
#   - uninstall cleanup behavior used by config rm
#
# Not responsibilities:
#   - CLI parsing
#   - target selection
#   - bootstrap plan/marker state
#   - manifest parsing
#   - arbitrary command execution from config files
```

At bottom:

```bash
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "[ERROR] installers.sh is a source-only library. Use config instead." >&2
  exit 2
fi
```

## Source failure behavior

If `installers.sh` is missing, `config.sh` should fail clearly when installer behavior is needed.

Preferred behavior at startup:

```bash
if [[ -f "$CONFIG_INSTALLERS_LIB" ]]; then
  # shellcheck source=/home/vmuser/.local/lib/config-sh/installers.sh
  source "$CONFIG_INSTALLERS_LIB"
else
  echo "[ERROR] Missing installers library: $CONFIG_INSTALLERS_LIB" >&2
  echo "[INFO] Restore it or reinstall the config tool." >&2
  return 1 2>/dev/null || exit 1
fi
```

Since `config.sh` depends on installer functions for `bootstrap steps`, source it unconditionally after required helpers exist.

## Allowlist must still protect dispatch

Keep this safety rule:

```text
steps.tsv may only map to functions allowed by config_bootstrap_function_allowed.
```

Do not make the allowlist dynamic in this milestone.

`config_bootstrap_function_allowed` should stay in `config.sh`.

Why:

```text
config.sh owns dispatch security.
installers.sh owns implementations.
```

## Manifest relationship

After the split, the relationship should be:

```text
steps.tsv
  says: install_docker -> InstallDocker

config.sh
  validates: InstallDocker is allowlisted
  dispatches: run_once install_docker InstallDocker

installers.sh
  defines: InstallDocker() { ... }

packages.env / versions.env / repos.env
  configure values used by InstallDocker or related helpers
```

Add this explanation to `config help config` or `config help bootstrap` if concise.

## Help update

Update help text where useful:

```text
Architecture:
  config.sh is the CLI/state engine.
  lib/config-sh/installers.sh contains trusted installer functions.
  etc/config-sh contains editable policy and manifests.

To add a new install step:
  1. add the trusted shell function in lib/config-sh/installers.sh
  2. add it to the allowlist in config.sh
  3. add a row to etc/config-sh/bootstrap/steps.tsv
  4. add default states to bootstrap profiles if needed
  5. test with config bootstrap steps and bootstrap step STEP
```

Keep it short in terminal help. The HTML guide can carry the longer explanation.

## Acceptance

- `/home/vmuser/.local/lib/config-sh/installers.sh` exists.
- `installers.sh` is source-only and refuses direct execution.
- Installer function bodies are no longer embedded in the middle of `config.sh`.
- `config.sh` sources `installers.sh` exactly once during startup.
- `config.sh` still owns CLI, target/session, config loading, plan/state, run_once, manifest validation, and dispatch.
- `installers.sh` owns install functions and installer cleanup behavior.
- `config_bootstrap_function_allowed` remains in `config.sh`.
- `config_bootstrap_run_step_by_name` still dispatches through `run_once`.
- `steps.tsv` still maps step names to allowed function names.
- Package/version/repo values still come from `etc/config-sh/install/*.env`.
- `config --target labuser bootstrap steps` still works.
- `sudo config --target labuser bootstrap status` still works.
- `sudo config --target labuser bootstrap step install_dev_env_shell_init` still reaches the same function through `run_once`.
- `sudo config --target labuser rm STEP` still has access to uninstall cleanup behavior.
- No `eval` is introduced.
- No arbitrary command execution from manifests/config.
- Shell syntax passes for both `config.sh` and `installers.sh`.
- No broad bootstrap/install/mount/pull/push/package command is run in postcheck.

## Postcheck log

Create:

```text
/home/vmuser/.local/patches/AN1_11_split_installers_library_postcheck.log
```

Use simple evidence-log style:

```text
AN1-11 split installer functions into trusted library postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Files
Observed:
- /home/vmuser/.local/lib/config-sh/installers.sh exists.
- config.sh sources installers.sh.
- installers.sh refuses direct execution.

Result: PASS

[2] Syntax
Command attempted:
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh

Observed:
- both syntax checks passed.

Result: PASS

[3] Function ownership
Observed:
- installer functions moved to installers.sh.
- config.sh retains dispatch/state/plan functions.
- config_bootstrap_function_allowed remains in config.sh.

Result: PASS

[4] Help/inspection
Command attempted:
config help config
config --target labuser config-show
config --target labuser bootstrap steps

Observed:
- commands worked.
- bootstrap steps still show manifest/fallback data.
- help mentions installers.sh relationship if updated.

Result: PASS

[5] Bootstrap status regression
Command attempted:
sudo config --target labuser bootstrap status

Observed:
- status table printed.
- no installer ran.

Result: PASS

[6] Single-step dispatch static/safe check
Command attempted:
sudo config --target labuser bootstrap step <known skipped or already-done step>

Observed:
- command reached normal run_once gates.
- skipped/done state prevented live install.
- no unrelated step ran.

Result: PASS

[7] rm cleanup access
Command attempted:
sudo config --target labuser rm <safe known step>

Observed:
- config_rm_step could call config_uninstall_step from installers.sh.
- marker cleanup and plan update still worked.
- no broad bootstrap/install command ran.

Result: PASS or SKIP
Reason if SKIP: no safe rm target available; static function lookup verified.

[8] Safety
Observed:
- no eval introduced.
- no arbitrary command execution from config or manifest files.
- no broad bootstrap/install/mount/pull/push command was run.
- no apt/docker/kubectl/minikube/sqlcmd command was run by postcheck.

Result: PASS

Overall
- config.sh is smaller and remains the orchestration engine.
- installers.sh contains trusted installer implementation code.
- etc/config-sh remains declarative policy/configuration only.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh

/home/vmuser/.local/lib/config-sh/installers.sh

config help config
config --target labuser config-show
config --target labuser bootstrap steps
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
```

Use only gated/skipped/already-done step checks unless intentionally testing a real install:

```bash
sudo config --target labuser bootstrap step install_gui_support
```

Do not run broad execution in this milestone:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
sudo config --target labuser mount
sudo config --target labuser pull
sudo config --target labuser push
```
