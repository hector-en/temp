# AN1-08B — Plan-Aware rm and Source-Aware Bootstrap Status

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Fix the confusing behavior after:

```bash
sudo config --target labuser rm install_gui_support
```

Current observed behavior:

```text
[INFO] Removed marker state for: install_gui_support
```

Then:

```bash
sudo config --target labuser bootstrap status
```

shows:

```text
install_gui_support                pending
```

This happens because `rm` removed marker state, then `bootstrap status` fell back to the existing `bootstrap.plan` row, which was `pending`.

For the operator, `rm STEP` should mean:

```text
Remove this step's runtime state and return it to a safe skipped/not-runnable state.
```

So after:

```bash
sudo config --target labuser rm install_gui_support
```

the step should show as:

```text
install_gui_support                skipped
```

unless the operator explicitly changes the plan back to pending later.

This milestone also improves status output so the operator can see whether a state comes from a marker or from `bootstrap.plan`.

## Scope

Edit only:

```text
/home/vmuser/.local/bin/config.sh
```

Do not change broad bootstrap execution, mount, pull, push, package installers, or run-as-target behavior.

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

## Desired model

Use this simple user model:

```text
skip STEP
  Block the step.
  Writes STEP.skipped and marks bootstrap.plan as skipped.

unskip STEP
  Allow the step.
  Removes STEP.skipped and marks bootstrap.plan as pending.

rm STEP
  Remove runtime evidence/state.
  Then mark bootstrap.plan as skipped so the step does not unexpectedly run.
```

Important:

```text
rm STEP should not leave the step effectively pending unless the operator explicitly asks for that.
```

## Required behavior

### 1. Make `rm` plan-aware

After `config_rm_step STEP` removes marker state and performs any uninstall/cleanup, it should update `bootstrap.plan`:

```text
STEP -> skipped
```

So:

```bash
sudo config --target labuser rm install_gui_support
```

should result in:

```text
bootstrap.plan contains:
skipped install_gui_support
```

Then:

```bash
sudo config --target labuser bootstrap status
```

should show:

```text
install_gui_support                skipped
```

### 2. Clear status output during rm

Improve `rm` output so the operator sees what happened.

Example desired output:

```text
Remove step state:
  TARGET_USER=labuser
  TARGET_HOME=/home/labuser
  STATE_DIR=/home/labuser/.local/state/config-sh
  STEP_NAME=install_gui_support

[INFO] Cleanup/uninstall completed or not required: install_gui_support
[INFO] Removed marker: install_gui_support.done
[INFO] Removed marker: install_gui_support.failed
[INFO] Removed marker: install_gui_support.running
[INFO] Removed marker: install_gui_support.skipped
[INFO] Removed marker: install_gui_support.last.log
[INFO] Removed marker: install_gui_support.lock
[INFO] Updated bootstrap.plan: install_gui_support -> skipped
[INFO] Step is now blocked from running until you unskip it.
```

If no markers existed:

```text
[INFO] No marker state found for: install_gui_support
[INFO] Updated bootstrap.plan: install_gui_support -> skipped
[INFO] Step is now blocked from running until you unskip it.
```

### 3. Reuse plan row helper

If AN1-08A added this helper, use it:

```bash
config_bootstrap_plan_set_step_state STEP skipped
```

If it does not exist yet, add it in this milestone.

Minimum helper behavior:

```text
- accepts only next|pending|skipped
- validates known step
- rewrites matching active row
- appends row if missing
- preserves comments and blank lines where practical
- keeps bootstrap.plan target-owned
```

### 4. Validate step name for rm

Before uninstall or marker removal:

```bash
sudo config --target labuser rm does_not_exist
```

should fail clearly:

```text
[ERROR] Unknown bootstrap step: does_not_exist
[INFO] See: sudo config --target labuser bootstrap plan
```

Do not alter plan or markers for unknown steps.

### 5. Do not accidentally run installers

`rm` may already call uninstall helpers for supported steps. Keep existing behavior, but do not add any broad execution.

For no-op cleanup steps such as `install_gui_support`, it is fine to report:

```text
[INFO] Cleanup/uninstall completed or not required: install_gui_support
```

If a step has a destructive uninstall helper, preserve current behavior.

### 6. Improve bootstrap status/plan table

Current output:

```text
Bootstrap plan:
  install_gui_support                pending
```

This hides where the state came from.

Change `config_bootstrap_summary` or related helpers to show source.

Suggested output:

```text
Bootstrap plan:
  Step                               State      Source
  update_apt                         skipped    plan
  standard_apps                      done       marker:done
  install_gui_support                skipped    plan
  install_docker                     skipped    marker:skipped
```

Or compact equivalent:

```text
Bootstrap plan:
  update_apt                         skipped    plan
  standard_apps                      done       marker
  install_gui_support                skipped    plan
  install_docker                     skipped    marker
```

Preferred detailed source labels:

```text
marker:done
marker:failed
marker:running
marker:skipped
plan:pending
plan:next
plan:skipped
default:pending
```

This makes it obvious why a step is pending/skipped/done.

### 7. Add helper for status source

Add a helper:

```bash
config_bootstrap_step_status_source() {
  local name="${1:-}"
  local marker_state=""
  local plan_state=""

  marker_state="$(config_bootstrap_marker_state_for_step "$name")"

  case "$marker_state" in
    done|failed|running|skipped)
      printf '%s\tmarker:%s\n' "$marker_state" "$marker_state"
      return 0
      ;;
  esac

  plan_state="$(config_bootstrap_plan_state_for_step "$name" 2>/dev/null || true)"

  case "$plan_state" in
    next|pending|skipped)
      printf '%s\tplan:%s\n' "$plan_state" "$plan_state"
      ;;
    *)
      printf 'pending\tdefault:pending\n'
      ;;
  esac
}
```

Then `config_bootstrap_step_status` can remain for compatibility, or call this helper and print only the first field.

### 8. Make `status` and `plan` both show source

Both commands currently call `config_bootstrap_summary`.

Keep that behavior, but update the table to include source.

Required:

```bash
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
```

both show the source-aware table.

### 9. Help update

Update help text where relevant:

```text
rm STEP
    Remove runtime state/cleanup where supported, then mark the plan row skipped.
    Use unskip STEP later if you want to allow it to run again.
```

Update `config help howto` if present:

```text
Remove a step's saved state and block it from running:
  sudo config --target labuser rm STEP_NAME

Allow it again later:
  sudo config --target labuser unskip STEP_NAME
```

Update status/plan explanation:

```text
status and plan show the resolved step table.
Source tells you where the state came from:
  marker:done      saved runtime marker
  plan:skipped     bootstrap.plan row
  default:pending  no marker and no plan row
```

## Acceptance

- `sudo config --target labuser rm does_not_exist` fails clearly before changing anything.
- `sudo config --target labuser rm install_gui_support` removes runtime marker state.
- After `rm install_gui_support`, `bootstrap.plan` contains `skipped install_gui_support`.
- After `rm install_gui_support`, `bootstrap status` shows `install_gui_support skipped`.
- `rm` output explains:
  - target context
  - step name
  - marker removal results
  - plan update result
  - that the step is blocked until unskipped
- `rm` does not remove unrelated step markers.
- `rm` does not run broad bootstrap/install.
- `rm` does not run package/mount workflows except existing per-step uninstall cleanup already supported by `config_uninstall_step`.
- `bootstrap status` shows source for each state.
- `bootstrap plan` shows source for each state.
- Source values distinguish marker state from plan state.
- Existing `skip`, `unskip`, `plan-apply`, and `bootstrap step` still work.
- Plan file remains target-owned.
- Shell syntax passes.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_08B_plan_aware_rm_status_sources_postcheck.log
```

Use simple evidence-log style:

```text
AN1-08B plan-aware rm and source-aware status postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_bootstrap_plan_set_step_state found: yes
config_bootstrap_step_status_source found: yes
Result: PASS

[3] Unknown rm target
Command attempted:
sudo config --target labuser rm does_not_exist

Observed:
- Failed clearly.
- Reported unknown bootstrap step.
- No marker or plan files changed.

Result: PASS

[4] rm output and plan update
Command attempted:
sudo config --target labuser rm install_gui_support

Observed:
- Printed remove step context.
- Removed marker state or reported none found.
- Updated bootstrap.plan to skipped install_gui_support.
- Reported that step is blocked until unskipped.
- No broad bootstrap/install command ran.

Result: PASS

[5] Status after rm
Command attempted:
sudo config --target labuser bootstrap status

Observed:
- install_gui_support showed skipped.
- Source column showed plan:skipped or equivalent.
- Other rows showed marker:* or plan:* source.

Result: PASS

[6] Plan after rm
Command attempted:
sudo config --target labuser bootstrap plan

Observed:
- Same source-aware table.
- install_gui_support showed skipped from plan.

Result: PASS

[7] Unskip regression
Command attempted:
sudo config --target labuser unskip install_gui_support

Observed:
- Plan row changed back to pending.
- Skipped marker removed if present.
- No .done marker removed.

Result: PASS

[8] Skip regression
Command attempted:
sudo config --target labuser skip install_gui_support

Observed:
- Skipped marker created.
- Plan row changed to skipped if AN1-08A symmetry exists.
- No broad execution occurred.

Result: PASS

[9] Safety
Observed:
- No broad bootstrap/install/mount command was run.
- No apt/docker/kubectl/minikube/sqlcmd commands were run by the postcheck.

Result: PASS

Overall
- rm now leaves the step safe/skipped instead of unexpectedly pending.
- status/plan now explain whether each state comes from markers or bootstrap.plan.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan

sudo config --target labuser rm does_not_exist
sudo config --target labuser rm install_gui_support
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
```

Do not run broad execution in this milestone:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```
