# AN1-07A — Declarative Bootstrap/Install State Files

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Add target-scoped config files that declare bootstrap/install step state and desired execution order.

The operator should be able to declare, per target:

```text
pending
next
skipped
```

and have `config bootstrap` / `config install` read those files in addition to existing marker files and existing commands:

```bash
sudo config --target labuser skip STEP_NAME
sudo config --target labuser unskip STEP_NAME
sudo config --target labuser rm STEP_NAME
```

Existing marker-based behavior must remain compatible.

## Why this exists

Current state is mostly marker-driven:

```text
.done
.failed
.running
.skipped
```

That works for completed/failed runtime state, but it is awkward for planning what should be run next.

We need a declarative target-local file so the operator can say:

```text
these steps are pending
this step is next
these steps are skipped but not done
```

without manually creating/removing marker files.

## Placement in AN1

Insert this as:

```text
AN1-07A — Declarative Bootstrap/Install State Files
```

between:

```text
AN1-07 target-aware bootstrap/install execution
AN1-08 target-scoped bootstrap step execution
```

Do not renumber AN1-08 unless the plan is updated later.

## Scope

Edit only what is needed, primarily:

```text
/home/vmuser/.local/bin/config.sh
```

Do not run:

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

Do not run broad live bootstrap.

## Required target-scoped state file

Create one canonical target-local plan file:

```bash
$STATE_DIR/bootstrap.plan
```

Example for `labuser`:

```text
# config bootstrap/install target plan
# target_user=labuser
# target_home=/home/labuser
#
# Valid states:
#   next STEP_NAME
#   pending STEP_NAME
#   skipped STEP_NAME
#
# Notes:
# - done/failed/running are runtime marker states, not declared here.
# - blank lines and # comments are ignored.
# - step names must be known bootstrap steps.

next install_dev_env_shell_init
pending install_dev_env_dotnet_tools
pending install_dev_env_python_user_tools
skipped install_docker
skipped install_minikube
```

Keep the format line-oriented and shell-safe. Do not source the file.

## State model

Runtime markers still have priority for runtime facts:

```text
.done      = done
.failed    = failed
.running   = running
.skipped   = skipped marker
```

Declarative file adds desired/planned state:

```text
next STEP      = explicitly next to run
pending STEP   = intended to run when reached
skipped STEP   = skipped by plan, not done
```

Resolution order for status display:

```text
done marker      -> done
failed marker    -> failed
running marker   -> running
.skipped marker  -> skipped
plan skipped     -> skipped
plan next        -> next
plan pending     -> pending
otherwise        -> pending
```

Important: `skipped` in the plan should behave like a skip marker for execution. It must prevent broad bootstrap from running that step.

## Required helpers

Add small helpers near bootstrap/status helpers.

### Known steps

If not already centralised, create a single list helper:

```bash
config_bootstrap_steps() {
  printf '%s\n' \
    update_apt \
    standard_apps \
    install_networking \
    install_dev_env_system_packages \
    install_dev_env_shell_init \
    install_dev_env_dotnet_tools \
    install_dev_env_python_user_tools \
    install_dev_env_pyenv \
    install_dev_env_anaconda \
    install_dev_env_azure_cli \
    install_dev_env_verify \
    install_gui_support \
    install_docker \
    install_terraform \
    install_kubernets \
    install_minikube \
    install_sqlserver_support_2004 \
    install_sqlserver_cli_tool_2204
}
```

Use this helper in summaries where practical. Do not rename existing marker spelling `install_kubernets` in this milestone.

### Plan path

```bash
config_bootstrap_plan_file() {
  printf '%s\n' "$STATE_DIR/bootstrap.plan"
}
```

### Step validation

```bash
config_bootstrap_step_is_known() {
  local step="${1:-}"
  [[ -n "$step" ]] || return 1
  config_bootstrap_steps | grep -qxF -- "$step"
}
```

### Plan parser

Add a parser that prints tab-separated rows:

```text
state<TAB>step
```

Required behavior:

- Ignore blank lines.
- Ignore `#` comments.
- Accept only:
  - `next STEP`
  - `pending STEP`
  - `skipped STEP`
- Reject unknown states.
- Reject invalid step names.
- Reject unknown bootstrap steps.
- Reject extra fields.
- Do not source/eval the file.
- Return non-zero on malformed file.

Suggested shape:

```bash
config_bootstrap_plan_rows() {
  local file
  local line state step extra lineno=0

  file="$(config_bootstrap_plan_file)"
  [[ -f "$file" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))

    line="${line%%#*}"
    line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    [[ -n "$line" ]] || continue

    read -r state step extra <<< "$line"

    case "$state" in
      next|pending|skipped) ;;
      *)
        echo "[ERROR] Invalid bootstrap plan state at $file:$lineno: $state" >&2
        return 1
        ;;
    esac

    [[ -n "${step:-}" && -z "${extra:-}" ]] || {
      echo "[ERROR] Invalid bootstrap plan row at $file:$lineno: $line" >&2
      return 1
    }

    [[ "$step" =~ ^[A-Za-z0-9_.-]+$ ]] || {
      echo "[ERROR] Invalid bootstrap step name at $file:$lineno: $step" >&2
      return 1
    }

    config_bootstrap_step_is_known "$step" || {
      echo "[ERROR] Unknown bootstrap step in plan at $file:$lineno: $step" >&2
      return 1
    }

    printf '%s\t%s\n' "$state" "$step"
  done < "$file"
}
```

### Plan state lookup

```bash
config_bootstrap_plan_state_for_step() {
  local wanted="${1:-}"
  local state step found=""

  [[ -n "$wanted" ]] || return 2

  while IFS=$'\t' read -r state step; do
    [[ "$step" == "$wanted" ]] || continue

    if [[ "$state" == "next" ]]; then
      found="next"
    elif [[ -z "$found" ]]; then
      found="$state"
    fi
  done < <(config_bootstrap_plan_rows) || return 1

  [[ -n "$found" ]] && printf '%s\n' "$found"
}
```

If duplicate rows exist:
- `next` wins for display.
- Otherwise first non-empty state can win.
- Do not fail duplicates in this milestone unless implementation prefers strictness.

### Plan initialization

Add a command or helper to create a starter file if missing:

```bash
config_bootstrap_plan_init() {
  local file
  file="$(config_bootstrap_plan_file)"
  config_runtime_init || return 1

  if [[ -f "$file" ]]; then
    echo "[INFO] Bootstrap plan already exists: $file"
    return 0
  fi

  cat > "$file" <<EOF
# config bootstrap/install target plan
# target_user=$TARGET_USER
# target_home=$TARGET_HOME
#
# Valid states:
#   next STEP_NAME
#   pending STEP_NAME
#   skipped STEP_NAME
#
# done/failed/running are runtime marker states, not declared here.

pending update_apt
pending standard_apps
pending install_networking
pending install_dev_env_system_packages
pending install_dev_env_shell_init
pending install_dev_env_dotnet_tools
pending install_dev_env_python_user_tools
pending install_dev_env_pyenv
pending install_dev_env_anaconda
pending install_dev_env_azure_cli
pending install_dev_env_verify
skipped install_gui_support
skipped install_docker
skipped install_terraform
skipped install_kubernets
skipped install_minikube
skipped install_sqlserver_support_2004
skipped install_sqlserver_cli_tool_2204
EOF

  config_chown_target_file "$file" || return 1
  echo "[INFO] Created bootstrap plan: $file"
}
```

The exact default pending/skipped split may be adjusted, but keep risky optional/system-heavy steps skipped by default if unsure.

## Required command additions

Extend:

```bash
config bootstrap ...
config install ...
```

with:

```bash
plan-init
plan-file
plan-validate
```

Required behavior:

```bash
sudo config --target labuser bootstrap plan-init
```

creates:

```text
/home/labuser/.local/state/config-sh/bootstrap.plan
```

target-owned.

```bash
sudo config --target labuser bootstrap plan-file
```

prints the file path only.

```bash
sudo config --target labuser bootstrap plan-validate
```

parses the plan and fails clearly if malformed.

Aliases:

```bash
sudo config --target labuser install plan-init
sudo config --target labuser install plan-file
sudo config --target labuser install plan-validate
```

should behave the same.

## Required integration

### Status/plan summary

Update `config_bootstrap_step_status STEP` to include declarative state.

Suggested behavior:

```bash
config_bootstrap_step_status() {
  local name="$1"
  local plan_state=""

  if [[ -f "$STATE_DIR/$name.skipped" ]]; then
    echo "skipped"
    return 0
  fi

  if [[ -f "$STATE_DIR/$name.done" ]]; then
    printf 'done'
  elif [[ -f "$STATE_DIR/$name.running" ]]; then
    printf 'running'
  elif [[ -f "$STATE_DIR/$name.failed" ]]; then
    printf 'failed'
  else
    plan_state="$(config_bootstrap_plan_state_for_step "$name" 2>/dev/null || true)"
    case "$plan_state" in
      next|pending|skipped) printf '%s' "$plan_state" ;;
      *) printf 'pending' ;;
    esac
  fi
}
```

### Execution skip behavior

Broad bootstrap must skip plan-skipped steps.

`run_once STEP FUNC` currently skips `.skipped` markers. Extend it so it also skips if the plan declares:

```text
skipped STEP
```

Suggested helper:

```bash
config_bootstrap_step_plan_skipped() {
  [[ "$(config_bootstrap_plan_state_for_step "${1:-}" 2>/dev/null || true)" == "skipped" ]]
}
```

Then in `run_once`, after `.skipped` marker check:

```bash
if config_bootstrap_step_plan_skipped "$name"; then
  echo "[SKIP] $name skipped by bootstrap plan"
  return 0
fi
```

Do not mark it `.done`.

### `next` behavior

For this milestone, `next` is primarily display/planning state.

Do not force broad bootstrap to run only the `next` step.

Actual single-step execution remains AN1-08.

## Existing commands compatibility

Keep these commands working:

```bash
sudo config --target labuser skip STEP_NAME
sudo config --target labuser unskip STEP_NAME
sudo config --target labuser rm STEP_NAME
```

For now, they operate marker files exactly as before.

Do not make them rewrite `bootstrap.plan` in this milestone unless trivial and safe.

Preferred behavior:

```text
skip/unskip/rm = runtime marker controls
bootstrap.plan = declarative operator plan
```

Later milestone may add:

```bash
config bootstrap plan-set STEP STATE
```

but not required now.

## Acceptance

- `config_bootstrap_plan_file` exists.
- `config_bootstrap_plan_rows` exists.
- `config_bootstrap_plan_state_for_step` exists.
- `config_bootstrap_plan_init` exists.
- `sudo config --target labuser bootstrap plan-init` creates `$STATE_DIR/bootstrap.plan`.
- Created plan file is target-owned.
- `sudo config --target labuser bootstrap plan-file` prints the path.
- `sudo config --target labuser bootstrap plan-validate` validates the file.
- Invalid state fails clearly.
- Unknown step fails clearly.
- `bootstrap status` / `bootstrap plan` display `next`, `pending`, or `skipped` from the plan when no runtime marker overrides it.
- `.done`, `.failed`, `.running`, `.skipped` markers still take precedence over plan state.
- Broad bootstrap skips plan-skipped steps without marking them done.
- Existing `skip`, `unskip`, and `rm` commands still work.
- No broad bootstrap/install/package/mount commands are run during validation.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_07A_declarative_bootstrap_plan_postcheck.log
```

Use simple evidence-log style:

```text
AN1-07A declarative bootstrap/install state files postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_bootstrap_plan_file found: yes
config_bootstrap_plan_rows found: yes
config_bootstrap_plan_state_for_step found: yes
config_bootstrap_plan_init found: yes
Result: PASS

[3] Plan init
Command attempted:
sudo config --target labuser bootstrap plan-init

Observed:
- Created or preserved /home/labuser/.local/state/config-sh/bootstrap.plan
- File is owned by labuser primary group
- File contains pending/skipped declarations

Result: PASS

[4] Plan file path
Command attempted:
sudo config --target labuser bootstrap plan-file

Observed:
- Printed /home/labuser/.local/state/config-sh/bootstrap.plan

Result: PASS

[5] Plan validation
Command attempted:
sudo config --target labuser bootstrap plan-validate

Observed:
- Valid plan parsed successfully.

Result: PASS

[6] Invalid plan validation
Command attempted:
temporary malformed plan with invalid state or unknown step

Observed:
- Validation failed clearly.
- Error included file and line number.

Result: PASS

[7] Status/plan integration
Command attempted:
sudo config --target labuser bootstrap plan
sudo config --target labuser bootstrap status

Observed:
- Steps with plan next displayed as next when no marker overrides.
- Steps with plan pending displayed as pending when no marker overrides.
- Steps with plan skipped displayed as skipped when no marker overrides.
- Runtime markers still override plan state.

Result: PASS

[8] Execution skip integration
Observed:
- run_once skips plan-skipped steps.
- Plan-skipped steps are not marked done.
- Existing .skipped marker behavior still works.

Result: PASS

[9] Existing command regression
sudo config --target labuser skip install_dev_env_dotnet_tools works: yes
sudo config --target labuser unskip install_dev_env_dotnet_tools works: yes
sudo config --target labuser rm install_dev_env_anaconda works or fails only because uninstall target unsupported/environment-specific: yes
Result: PASS

[10] Safety regression
config --target labuser bootstrap without sudo blocked if AN1-07 applied: yes
sudo config --target labuser bootstrap status non-destructive: yes
sudo config --target labuser install plan non-destructive: yes
Result: PASS

Overall
- Target-scoped declarative bootstrap plan file exists.
- Plan file can declare next/pending/skipped.
- Runtime markers still represent actual state.
- Plan-skipped steps are skipped but not marked done.
- Existing skip/unskip/rm marker commands remain compatible.
- No broad bootstrap/install/package/mount commands were run.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

sudo config --target labuser bootstrap plan-init
sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap plan-validate
sudo config --target labuser bootstrap plan
sudo config --target labuser bootstrap status

sudo config --target labuser install plan-file
sudo config --target labuser install plan-validate
```

Do not run broad execution in this milestone unless explicitly intended:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```
