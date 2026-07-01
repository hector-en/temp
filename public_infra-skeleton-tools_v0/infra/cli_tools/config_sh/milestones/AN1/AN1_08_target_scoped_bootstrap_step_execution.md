# AN1-08 — Target-Scoped Bootstrap Step Execution

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Add a safe way to execute one bootstrap/install step for a selected target user.

New operator workflow:

```bash
sudo config --target labuser bootstrap step STEP_NAME
sudo config --target labuser install step STEP_NAME
```

Example:

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init
sudo config --target labuser bootstrap step install_dev_env_python_user_tools
```

This avoids running the entire bootstrap chain when the operator only wants one step.

## Why this milestone exists

The plan file now lets the operator declare:

```text
pending STEP
next STEP
skipped STEP
```

But broad bootstrap still walks the whole chain.

This milestone adds single-step execution so the operator can:

```text
1. edit bootstrap.plan
2. apply the plan
3. run one specific step
```

without risking unrelated installers.

## Scope

Edit primarily:

```text
/home/vmuser/.local/bin/config.sh
```

Do not edit `mounts.sh` unless absolutely necessary.

Do not run live heavy installers in postcheck:

```text
apt
docker
terraform
kubectl
minikube
sqlcmd
pyenv install
anaconda install/download
```

Use safe/stubbed/static checks where possible.

## Preserve

- AN1-07 plan file helpers
- AN1-07C plan-authority behavior
- AN1-07D/07E help improvements
- Existing broad bootstrap behavior
- Existing `run_once` marker behavior
- Existing skip/unskip/rm commands
- Existing `install` alias for `bootstrap`
- Sudo guard for broad bootstrap/install
- Target context safety:
  - no `/root` target home
  - no accidental `/home/vmuser` when target is `labuser`

## Required command

Add:

```bash
config bootstrap step STEP_NAME
config install step STEP_NAME
```

Required examples:

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init
sudo config --target labuser install step install_dev_env_shell_init
```

## Required behavior

### 1. Validate step name

The step must be known in `config_bootstrap_steps`.

Invalid:

```bash
sudo config --target labuser bootstrap step does_not_exist
```

Expected:

```text
[ERROR] Unknown bootstrap step: does_not_exist
[INFO] See: config --target labuser bootstrap plan
```

Return non-zero.

### 2. Require sudo for actual execution

Single-step execution can run package/system/user installers, so require sudo.

Non-sudo:

```bash
config --target labuser bootstrap step install_dev_env_shell_init
```

Expected:

```text
[ERROR] config bootstrap/install requires sudo.
[INFO] Re-run as: sudo config --target labuser bootstrap step install_dev_env_shell_init
```

Return non-zero before running anything.

### 3. Print execution context

Before running the step, print:

```text
Bootstrap step execution context:
  TARGET_USER=labuser
  TARGET_HOME=/home/labuser
  STATE_DIR=/home/labuser/.local/state/config-sh
  CURRENT_HOME=/home/labuser
  STEP_NAME=install_dev_env_shell_init
```

### 4. Honor plan and marker gates

Single-step execution must use the existing `run_once STEP FUNC` path where possible.

That means:

```text
STEP.done       -> skip as already done
STEP.skipped    -> skip
plan skipped    -> skip
otherwise       -> run selected function
```

Do not bypass `run_once`.

### 5. Do not run preflight for every single safe user step unless needed

Broad bootstrap currently runs global preflight.

For single-step execution:

- Validate target context.
- Run network preflight only if the selected step needs network.
- Use existing `config_bootstrap_step_needs_network STEP`.

Suggested behavior:

```bash
if config_bootstrap_step_needs_network "$step"; then
  config_run_preflight_checks || return $?
else
  echo "[INFO] Skipping network preflight for non-network step: $step"
fi
```

This prevents a local shell-init step from failing because unrelated DNS checks fail.

### 6. Add a step dispatcher

Add a helper that maps step names to functions.

Suggested:

```bash
config_bootstrap_run_step_by_name() {
  local step="${1:-}"

  case "$step" in
    update_apt) run_once update_apt UpdateAPT ;;
    standard_apps) run_once standard_apps StandardApps ;;
    install_networking) run_once install_networking InstallNetworking ;;
    install_dev_env_system_packages) run_once install_dev_env_system_packages InstallDevEnvSystemPackages ;;
    install_dev_env_shell_init) run_once install_dev_env_shell_init InstallDevEnvShellInit ;;
    install_dev_env_dotnet_tools) run_once install_dev_env_dotnet_tools InstallDevEnvDotnetTools ;;
    install_dev_env_python_user_tools) run_once install_dev_env_python_user_tools InstallDevEnvPythonUserTools ;;
    install_dev_env_pyenv) run_once install_dev_env_pyenv InstallDevEnvPyenv ;;
    install_dev_env_anaconda) run_once install_dev_env_anaconda InstallDevEnvAnaconda ;;
    install_dev_env_azure_cli) run_once install_dev_env_azure_cli InstallDevEnvAzureCLI ;;
    install_dev_env_verify) run_once install_dev_env_verify InstallDevEnvVerify ;;
    install_gui_support) run_once install_gui_support InstallGUISupport ;;
    install_docker) run_once install_docker InstallDocker ;;
    install_terraform) run_once install_terraform InstallTerraform ;;
    install_kubernets) run_once install_kubernets InstallKubernetes ;;
    install_minikube) run_once install_minikube InstallMinikube ;;
    install_sqlserver_support_2004) run_once install_sqlserver_support_2004 InstallSQLServerSupport2004 ;;
    install_sqlserver_cli_tool_2204) run_once install_sqlserver_cli_tool_2204 InstallSQLServerCLITool2204 ;;
    *)
      echo "[ERROR] Unknown bootstrap step: $step" >&2
      return 2
      ;;
  esac
}
```

### 7. Add step command wrapper

Suggested:

```bash
config_run_bootstrap_step() {
  local step="${1:-}"

  [[ -n "$step" ]] || {
    echo "[ERROR] Missing bootstrap step name" >&2
    echo "[INFO] Usage: config bootstrap step STEP_NAME" >&2
    return 2
  }

  config_bootstrap_step_is_known "$step" || {
    echo "[ERROR] Unknown bootstrap step: $step" >&2
    echo "[INFO] See: config --target ${TARGET_USER} bootstrap plan" >&2
    return 2
  }

  config_require_sudo_for_bootstrap_step "$step" || return 1
  config_bootstrap_validate_target_context || return 1
  config_runtime_init || return 1
  config_print_bootstrap_step_execution_context "$step"

  if config_bootstrap_step_needs_network "$step"; then
    config_run_preflight_checks || return $?
  else
    echo "[INFO] Skipping network preflight for non-network step: $step"
  fi

  config_bootstrap_run_step_by_name "$step"
}
```

You may reuse `config_require_sudo_for_bootstrap`, but improve the rerun hint so it includes `step STEP_NAME`.

### 8. Add helper for context banner

```bash
config_print_bootstrap_step_execution_context() {
  local step="${1:-}"
  echo "Bootstrap step execution context:"
  printf "  TARGET_USER=%s
" "$TARGET_USER"
  printf "  TARGET_HOME=%s
" "$TARGET_HOME"
  printf "  STATE_DIR=%s
" "$STATE_DIR"
  printf "  CURRENT_HOME=%s
" "$CURRENT_HOME"
  printf "  STEP_NAME=%s
" "$step"
}
```

### 9. Command dispatch

Update `config_run_bootstrap`:

```bash
step)
  shift || true
  config_run_bootstrap_step "$@"
  ;;
```

Reject extra arguments:

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init extra
```

Expected:

```text
[ERROR] Unknown bootstrap step argument: extra
```

### 10. Help update

Update `config_bootstrap_usage` to include:

```text
step STEP_NAME
    Run one bootstrap step through the normal target-scoped run_once path.
    Honors .done, .skipped, and bootstrap.plan skipped state.
```

Add examples:

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init
sudo config --target labuser bootstrap step install_dev_env_python_user_tools
sudo config --target labuser install step install_dev_env_shell_init
```

Update `config help howto` if present:

```text
Run one bootstrap step:
  sudo config --target labuser bootstrap step STEP_NAME
```

Update `config help menu` if present:

```text
bootstrap step STEP
    Run one selected bootstrap step
```

## Acceptance

- `config bootstrap help` documents `step STEP_NAME`.
- `config help howto` documents single-step execution if that help exists.
- `config help menu` documents single-step execution if that help exists.
- `config --target labuser bootstrap step` fails clearly with missing step error.
- `config --target labuser bootstrap step does_not_exist` fails clearly with unknown step error.
- Non-sudo `config --target labuser bootstrap step install_dev_env_shell_init` fails before execution with sudo hint.
- `sudo config --target labuser bootstrap step install_dev_env_shell_init` prints target step execution context.
- Target step execution context shows `/home/labuser`, not `/root` or `/home/vmuser`.
- Single-step execution uses `run_once`.
- `.done` marker causes selected step to skip as already done.
- `.skipped` marker causes selected step to skip.
- `bootstrap.plan` skipped state causes selected step to skip.
- Non-network steps do not require the full network preflight.
- Network steps still run relevant preflight before execution.
- `install step STEP_NAME` behaves as alias.
- Broad bootstrap behavior is unchanged.
- No broad bootstrap/install/package/mount command is run during postcheck.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_08_target_scoped_bootstrap_step_execution_postcheck.log
```

Use simple evidence-log style:

```text
AN1-08 target-scoped bootstrap step execution postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_run_bootstrap_step found: yes
config_bootstrap_run_step_by_name found: yes
config_print_bootstrap_step_execution_context found: yes
Result: PASS

[3] Help
Command attempted:
config help bootstrap
config help howto
config help menu

Observed:
- bootstrap step STEP_NAME documented.
- Examples show target-scoped single-step execution.

Result: PASS

[4] Missing and unknown step validation
Command attempted:
config --target labuser bootstrap step
config --target labuser bootstrap step does_not_exist

Observed:
- Missing step failed clearly.
- Unknown step failed clearly.
- No execution occurred.

Result: PASS

[5] Sudo guard
Command attempted:
config --target labuser bootstrap step install_dev_env_shell_init

Observed:
- Failed before execution.
- Error required sudo.
- Hint included bootstrap step install_dev_env_shell_init.

Result: PASS

[6] Context and safe skipped-step path
Command attempted:
sudo config --target labuser bootstrap step <known skipped safe step>

Observed:
- Printed Bootstrap step execution context.
- TARGET_USER=labuser
- TARGET_HOME=/home/labuser
- STATE_DIR=/home/labuser/.local/state/config-sh
- CURRENT_HOME=/home/labuser
- STEP_NAME=<step>
- Step skipped through run_once due to marker or plan state.
- No package/install command executed.

Result: PASS

[7] Done marker path
Command attempted on a step already done:
sudo config --target labuser bootstrap step update_apt

Observed:
- Step skipped as already done.
- No apt command executed.

Result: PASS

[8] Install alias
Command attempted:
sudo config --target labuser install step <known skipped safe step>

Observed:
- Same behavior as bootstrap step.

Result: PASS

[9] Preflight behavior
Observed:
- Non-network selected step skips network preflight.
- Network selected step retains preflight path.

Result: PASS or SKIP
Reason if SKIP: live network step not run; static check confirms branch.

[10] Regression
Observed:
- bootstrap status still works.
- bootstrap plan still works.
- plan-apply still works.
- broad bootstrap command path unchanged.

Result: PASS

Overall
- One selected bootstrap/install step can now be run for a target user.
- Single-step execution is sudo-gated, target-scoped, and uses run_once.
- No unrelated broad bootstrap steps were run.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

config help bootstrap
config help howto
config help menu

config --target labuser bootstrap step
config --target labuser bootstrap step does_not_exist
config --target labuser bootstrap step install_dev_env_shell_init

sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser bootstrap step install_gui_support
sudo config --target labuser install step install_gui_support
```

Only run a real pending step if intentionally selected:

```bash
sudo config --target labuser bootstrap step install_dev_env_shell_init
sudo config --target labuser bootstrap step install_dev_env_python_user_tools
```

Do not run broad execution in this milestone:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```
