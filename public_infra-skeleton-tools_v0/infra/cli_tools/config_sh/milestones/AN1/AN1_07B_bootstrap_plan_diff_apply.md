# AN1-07B — Bootstrap Plan Diff and Safe Apply

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Extend the declarative bootstrap/install plan system from AN1-07A with safe reconciliation tooling.

Add:

```bash
sudo config --target labuser bootstrap plan-diff
sudo config --target labuser bootstrap plan-apply --skips-only
```

and improve:

```bash
sudo config --target labuser bootstrap plan-validate
```

so it warns about plan/header/runtime-marker divergence without mutating anything.

## Core principle

```text
plan-validate = read-only syntax and consistency check
plan-diff     = read-only comparison of bootstrap.plan vs marker state
plan-apply    = explicit mutation, but only in safe modes
```

Do not make `plan-validate` change marker files.

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

## Existing state to preserve

AN1-07A added target-scoped plan file support:

```bash
$STATE_DIR/bootstrap.plan
```

Supported rows:

```text
next STEP_NAME
pending STEP_NAME
skipped STEP_NAME
```

Existing commands must continue to work:

```bash
sudo config --target labuser bootstrap plan-init
sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap plan-validate
sudo config --target labuser bootstrap plan
sudo config --target labuser bootstrap status
```

Existing runtime marker commands must continue to work:

```bash
sudo config --target labuser skip STEP_NAME
sudo config --target labuser unskip STEP_NAME
sudo config --target labuser rm STEP_NAME
```

## Required behavior

### 1. Header mismatch warnings

`plan-validate` should warn if comments in `bootstrap.plan` disagree with active target context.

Recognize these optional header comment lines:

```text
# target_user=labuser
# target_home=/home/labuser
```

If present and mismatched:

```text
[WARN] Plan header target_user=vmuser does not match active TARGET_USER=labuser
[WARN] Plan header target_home=/home/vmuser does not match active TARGET_HOME=/home/labuser
```

These are warnings only, not validation failures.

Do not require the headers to exist.

### 2. Marker divergence warnings in `plan-validate`

After syntax validation, compare plan state with runtime marker state and warn on notable divergence.

Runtime marker state:

```text
done
failed
running
skipped
none
```

Plan state:

```text
next
pending
skipped
none
```

Warnings should include cases like:

```text
[WARN] Plan says pending update_apt, but marker state is done
[WARN] Plan says skipped install_dev_env_shell_init, but no .skipped marker exists
[WARN] Plan says next install_dev_env_shell_init, but marker state is done
[WARN] Plan has no row for install_docker, marker state is skipped
```

Do not warn for every harmless case if output becomes noisy. Minimum useful warnings:

- plan says `skipped`, marker is not `skipped`
- plan says `pending` or `next`, marker is `skipped`
- plan says `next`, marker is `done`
- header mismatch

`plan-validate` must remain exit 0 if syntax is valid, even with warnings.

It must return non-zero only for malformed plan rows, invalid states, unknown steps, invalid names, parser errors, or unreadable file.

### 3. Add `plan-diff`

Add command:

```bash
sudo config --target labuser bootstrap plan-diff
sudo config --target labuser install plan-diff
```

Output a stable table:

```text
Bootstrap plan diff:
  Step                              Plan      Marker
  update_apt                        pending   done
  standard_apps                     pending   done
  install_networking                pending   done
  install_dev_env_system_packages   skipped   skipped
  install_dev_env_shell_init        skipped   none
```

Rules:

- List all known bootstrap steps in canonical order.
- `Plan` column is one of:
  - `next`
  - `pending`
  - `skipped`
  - `none`
- `Marker` column is one of:
  - `done`
  - `failed`
  - `running`
  - `skipped`
  - `none`
- Do not mutate anything.

### 4. Add `plan-apply --skips-only`

Add command:

```bash
sudo config --target labuser bootstrap plan-apply --skips-only
sudo config --target labuser install plan-apply --skips-only
```

This is the only apply mode required now.

Behavior:

For each known step:

```text
plan skipped:
  create/update STEP.skipped marker
  remove STEP.running and STEP.failed if present
  do not remove STEP.done

plan pending or next:
  remove STEP.skipped marker if present
  do not remove STEP.done
  do not remove STEP.failed
  do not remove STEP.running

plan none:
  do nothing
```

Important:

- Never remove `.done`.
- Never remove `.failed`, except for plan-skipped steps where skipping a step should clear failed/running state.
- Never remove `.running`, except for plan-skipped steps.
- Never create `.done`.
- Never run any bootstrap step.
- Created `.skipped` markers must be target-owned.

If the plan file is invalid, `plan-apply` must fail before changing anything.

### 5. Reject unsafe apply modes

These should fail clearly:

```bash
sudo config --target labuser bootstrap plan-apply
sudo config --target labuser bootstrap plan-apply --reset-to-plan
sudo config --target labuser bootstrap plan-apply --reset-done
```

Expected:

```text
[ERROR] plan-apply requires an explicit supported mode.
[INFO] Supported mode: --skips-only
```

or:

```text
[ERROR] Unsupported plan-apply mode: --reset-done
[INFO] Supported mode: --skips-only
```

## Required helpers

Add helpers near AN1-07A plan helpers.

### Marker state helper

```bash
config_bootstrap_marker_state_for_step() {
  local step="${1:-}"

  [[ -n "$step" ]] || return 2

  if [[ -f "$STATE_DIR/$step.done" ]]; then
    printf 'done'
  elif [[ -f "$STATE_DIR/$step.failed" ]]; then
    printf 'failed'
  elif [[ -f "$STATE_DIR/$step.running" ]]; then
    printf 'running'
  elif [[ -f "$STATE_DIR/$step.skipped" ]]; then
    printf 'skipped'
  else
    printf 'none'
  fi
}
```

### Plan header check

Suggested shape:

```bash
config_bootstrap_plan_warn_header_mismatch() {
  local file
  local header_user=""
  local header_home=""

  file="$(config_bootstrap_plan_file)"
  [[ -f "$file" ]] || return 0

  header_user="$(sed -n 's/^[[:space:]]*#[[:space:]]*target_user=//p' "$file" | head -n1)"
  header_home="$(sed -n 's/^[[:space:]]*#[[:space:]]*target_home=//p' "$file" | head -n1)"

  if [[ -n "$header_user" && "$header_user" != "$TARGET_USER" ]]; then
    echo "[WARN] Plan header target_user=$header_user does not match active TARGET_USER=$TARGET_USER" >&2
  fi

  if [[ -n "$header_home" && "$header_home" != "$TARGET_HOME" ]]; then
    echo "[WARN] Plan header target_home=$header_home does not match active TARGET_HOME=$TARGET_HOME" >&2
  fi
}
```

### Plan divergence warnings

Suggested shape:

```bash
config_bootstrap_plan_warn_marker_divergence() {
  local step plan_state marker_state

  while IFS= read -r step; do
    [[ -n "$step" ]] || continue
    plan_state="$(config_bootstrap_plan_state_for_step "$step" 2>/dev/null || true)"
    marker_state="$(config_bootstrap_marker_state_for_step "$step")"
    [[ -n "$plan_state" ]] || plan_state="none"

    case "$plan_state:$marker_state" in
      skipped:skipped|pending:none|next:none|none:none)
        ;;
      skipped:*)
        echo "[WARN] Plan says skipped $step, but marker state is $marker_state" >&2
        ;;
      pending:skipped|next:skipped)
        echo "[WARN] Plan says $plan_state $step, but marker state is skipped" >&2
        ;;
      next:done)
        echo "[WARN] Plan says next $step, but marker state is done" >&2
        ;;
    esac
  done < <(config_bootstrap_steps)
}
```

### Plan validation wrapper

If not already present as a function, add:

```bash
config_bootstrap_plan_validate() {
  config_runtime_init || return 1
  config_bootstrap_plan_rows >/dev/null || return 1
  config_bootstrap_plan_warn_header_mismatch
  config_bootstrap_plan_warn_marker_divergence
}
```

### Diff function

```bash
config_bootstrap_plan_diff() {
  local step plan_state marker_state

  config_runtime_init || return 1
  config_bootstrap_plan_rows >/dev/null || return 1

  echo "Bootstrap plan diff:"
  printf "  %-34s %-9s %s\n" "Step" "Plan" "Marker"

  while IFS= read -r step; do
    [[ -n "$step" ]] || continue
    plan_state="$(config_bootstrap_plan_state_for_step "$step" 2>/dev/null || true)"
    [[ -n "$plan_state" ]] || plan_state="none"
    marker_state="$(config_bootstrap_marker_state_for_step "$step")"
    printf "  %-34s %-9s %s\n" "$step" "$plan_state" "$marker_state"
  done < <(config_bootstrap_steps)
}
```

### Safe apply function

```bash
config_bootstrap_plan_apply_skips_only() {
  local step plan_state path

  config_runtime_init || return 1
  config_bootstrap_plan_rows >/dev/null || return 1

  while IFS= read -r step; do
    [[ -n "$step" ]] || continue
    plan_state="$(config_bootstrap_plan_state_for_step "$step" 2>/dev/null || true)"
    path="$STATE_DIR/$step.skipped"

    case "$plan_state" in
      skipped)
        cat > "$path" <<EOF
name=$step
status=skipped
target_user=$TARGET_USER
target_home=$TARGET_HOME
skipped_at=$(date -Is)
source=bootstrap.plan
EOF
        config_chown_target_file "$path" || return 1
        rm -f "$STATE_DIR/$step.running" "$STATE_DIR/$step.failed"
        echo "[INFO] Applied plan skip: $step"
        ;;
      pending|next)
        if [[ -f "$path" ]]; then
          rm -f "$path"
          echo "[INFO] Removed skipped marker from plan $plan_state step: $step"
        fi
        ;;
      ""|none)
        ;;
      *)
        echo "[ERROR] Unexpected plan state for $step: $plan_state" >&2
        return 1
        ;;
    esac
  done < <(config_bootstrap_steps)
}
```

## Command dispatch changes

Extend `config_run_bootstrap` subcommands:

```bash
plan-validate)
  shift || true
  if (($#)); then
    echo "[ERROR] Unknown plan-validate argument: $1" >&2
    config_bootstrap_usage >&2
    return 2
  fi
  config_bootstrap_plan_validate
  ;;
plan-diff)
  shift || true
  if (($#)); then
    echo "[ERROR] Unknown plan-diff argument: $1" >&2
    config_bootstrap_usage >&2
    return 2
  fi
  config_bootstrap_plan_diff
  ;;
plan-apply)
  shift || true
  case "${1:-}" in
    --skips-only)
      shift || true
      if (($#)); then
        echo "[ERROR] Unknown plan-apply argument: $1" >&2
        return 2
      fi
      config_bootstrap_plan_apply_skips_only
      ;;
    "")
      echo "[ERROR] plan-apply requires an explicit supported mode." >&2
      echo "[INFO] Supported mode: --skips-only" >&2
      return 2
      ;;
    *)
      echo "[ERROR] Unsupported plan-apply mode: $1" >&2
      echo "[INFO] Supported mode: --skips-only" >&2
      return 2
      ;;
  esac
  ;;
```

Ensure `install` alias works because it routes through `config_run_bootstrap`.

## Help update

Update `config_bootstrap_usage` minimally:

```text
plan-init       Create target bootstrap.plan if missing
plan-file       Print target bootstrap.plan path
plan-validate   Validate plan and warn about divergence
plan-diff       Show plan state vs runtime marker state
plan-apply      Apply safe plan changes; currently supports --skips-only
```

Examples:

```bash
sudo config --target labuser bootstrap plan-diff
sudo config --target labuser bootstrap plan-apply --skips-only
```

## Acceptance

- `sudo config --target labuser bootstrap plan-validate` remains read-only.
- `plan-validate` warns on header target mismatch.
- `plan-validate` warns on important plan/marker divergence.
- `plan-validate` returns 0 for valid plan with warnings.
- `plan-validate` returns non-zero for malformed plan.
- `sudo config --target labuser bootstrap plan-diff` prints all known steps in canonical order.
- `plan-diff` shows Plan and Marker columns.
- `sudo config --target labuser bootstrap plan-apply` fails because no mode was provided.
- `sudo config --target labuser bootstrap plan-apply --reset-done` fails as unsupported.
- `sudo config --target labuser bootstrap plan-apply --skips-only` creates target-owned `.skipped` markers for plan-skipped steps.
- `plan-apply --skips-only` removes `.skipped` markers for plan `pending` and `next` steps.
- `plan-apply --skips-only` never removes `.done`.
- `plan-apply --skips-only` never creates `.done`.
- `plan-apply --skips-only` does not run bootstrap steps.
- `install plan-diff` and `install plan-apply --skips-only` behave as aliases.
- Existing `skip`, `unskip`, `rm` still work.
- No broad bootstrap/install/package/mount commands are run.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_07B_bootstrap_plan_diff_apply_postcheck.log
```

Use simple evidence-log style:

```text
AN1-07B bootstrap plan diff and safe apply postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_bootstrap_marker_state_for_step found: yes
config_bootstrap_plan_warn_header_mismatch found: yes
config_bootstrap_plan_warn_marker_divergence found: yes
config_bootstrap_plan_validate found: yes
config_bootstrap_plan_diff found: yes
config_bootstrap_plan_apply_skips_only found: yes
Result: PASS

[3] Validate read-only warnings
Command attempted:
sudo config --target labuser bootstrap plan-validate

Observed:
- Valid plan returned exit 0.
- Header mismatch warnings shown if header disagreed with active target.
- Plan/marker divergence warnings shown where applicable.
- No marker files were changed.

Result: PASS

[4] Invalid plan validation
Command attempted:
temporary malformed plan with invalid state or unknown step

Observed:
- Validation failed non-zero.
- Error included file and line number.
- No marker files were changed.

Result: PASS

[5] Plan diff
Command attempted:
sudo config --target labuser bootstrap plan-diff

Observed:
- Printed Bootstrap plan diff table.
- Listed all known steps in canonical order.
- Included Plan and Marker columns.

Result: PASS

[6] Unsafe apply rejection
Command attempted:
sudo config --target labuser bootstrap plan-apply
sudo config --target labuser bootstrap plan-apply --reset-done

Observed:
- Both failed with exit 2.
- Help text showed supported mode --skips-only.
- No marker files were changed.

Result: PASS

[7] Safe apply skips-only
Command attempted:
sudo config --target labuser bootstrap plan-apply --skips-only

Observed:
- Plan-skipped steps received .skipped markers.
- Plan pending/next steps had .skipped markers removed if present.
- .done markers were not removed.
- .done markers were not created.
- No bootstrap steps were executed.
- Created .skipped markers were target-owned.

Result: PASS

[8] Install alias
Command attempted:
sudo config --target labuser install plan-diff
sudo config --target labuser install plan-apply --skips-only

Observed:
- install alias behaved like bootstrap for plan-diff and plan-apply.

Result: PASS

[9] Existing command regression
sudo config --target labuser skip install_dev_env_dotnet_tools works: yes
sudo config --target labuser unskip install_dev_env_dotnet_tools works: yes
sudo config --target labuser bootstrap plan works: yes
sudo config --target labuser bootstrap status works: yes

Result: PASS

[10] Safety regression
config --target labuser bootstrap without sudo blocked if AN1-07 applied: yes
sudo config --target labuser bootstrap status non-destructive: yes
No broad bootstrap/install/package/mount commands were run: yes

Result: PASS

Overall
- plan-validate is read-only and warns about divergence.
- plan-diff shows plan vs runtime marker state.
- plan-apply --skips-only safely reconciles skipped markers only.
- done/failed/running are not dangerously reset.
- Existing marker commands remain compatible.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

sudo config --target labuser bootstrap plan-validate
sudo config --target labuser bootstrap plan-diff
sudo config --target labuser bootstrap plan-apply
sudo config --target labuser bootstrap plan-apply --reset-done
sudo config --target labuser bootstrap plan-apply --skips-only

sudo config --target labuser install plan-diff
sudo config --target labuser install plan-apply --skips-only

sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
```

Do not run broad execution in this milestone unless explicitly intended:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```
