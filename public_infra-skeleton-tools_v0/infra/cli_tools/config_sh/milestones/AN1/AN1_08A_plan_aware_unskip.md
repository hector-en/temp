# AN1-08A — Plan-Aware Unskip Behavior

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Fix the operator confusion around `unskip`.

Current behavior:

```bash
sudo config --target labuser unskip install_gui_support
```

only removes:

```text
STATE_DIR/install_gui_support.skipped
```

But with the new plan-authority model, a step can still be blocked by:

```text
skipped install_gui_support
```

inside:

```text
STATE_DIR/bootstrap.plan
```

So the command can say:

```text
[INFO] Step was not skipped: install_gui_support
```

even though the step is still effectively skipped by `bootstrap.plan`.

This milestone makes `unskip` plan-aware.

## Desired user model

A normal user expects:

```bash
sudo config --target labuser unskip STEP_NAME
```

to mean:

```text
Allow this step to run again.
```

Therefore `unskip` should clear both skip gates:

```text
1. Remove STEP.skipped marker if present.
2. Change bootstrap.plan row from `skipped STEP` to `pending STEP`.
```

After that, this should work if the step is otherwise not done/failed/running:

```bash
sudo config --target labuser bootstrap step STEP_NAME
```

## Scope

Edit only:

```text
/home/vmuser/.local/bin/config.sh
```

Do not change bootstrap execution, broad bootstrap, mount, pull, or push behavior.

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

## Required behavior

### 1. Validate step name for skip/unskip/rm

Before changing state, `skip`, `unskip`, and `rm` should reject unknown bootstrap steps.

Required:

```bash
sudo config --target labuser unskip does_not_exist
```

Expected:

```text
[ERROR] Unknown bootstrap step: does_not_exist
[INFO] See: sudo config --target labuser bootstrap plan
```

Return non-zero.

If this is too broad, at minimum validate inside `config_unskip_step`.

### 2. Make `unskip` update bootstrap.plan

When running:

```bash
sudo config --target labuser unskip install_gui_support
```

do:

```text
- remove STATE_DIR/install_gui_support.skipped if present
- if bootstrap.plan contains `skipped install_gui_support`, rewrite that row to:
  pending install_gui_support
- preserve comments and other plan rows as much as practical
- keep bootstrap.plan target-owned
```

If the plan file does not exist:

```text
- remove marker if present
- print that no plan file was found
- suggest plan-init if needed
```

Suggested message:

```text
[INFO] Removed skipped marker: install_gui_support
[INFO] Updated bootstrap.plan: skipped -> pending for install_gui_support
```

If no marker existed but plan was skipped:

```text
[INFO] Step had no skipped marker: install_gui_support
[INFO] Updated bootstrap.plan: skipped -> pending for install_gui_support
```

If neither marker nor plan skip existed:

```text
[INFO] Step is already allowed by marker and plan: install_gui_support
```

### 3. Add helper to update one plan row

Add a helper near plan functions:

```bash
config_bootstrap_plan_set_step_state() {
  local step="${1:-}"
  local new_state="${2:-}"
  local file tmp line state row_step extra changed=0 found=0

  # validate state: next|pending|skipped
  # validate known step
  # if file missing, return 3 or create? For unskip, do not create automatically.
  # rewrite only active plan rows, preserving comments/blank lines
}
```

Required behavior:

- Accept only `next`, `pending`, `skipped`.
- Reject unknown steps.
- Do not source or eval the plan file.
- Preserve blank lines and comments.
- For active non-comment rows:
  - if row step matches requested step, replace state.
  - if no matching row exists, append `pending STEP` or `skipped STEP` depending on requested state.
- Return success if changed or already matching.
- Keep file target-owned.

A simple implementation is acceptable.

### 4. Add helper to inspect effective skip reason

Add:

```bash
config_bootstrap_step_skip_reason() {
  local step="${1:-}"

  if [[ -f "$STATE_DIR/$step.skipped" ]]; then
    printf '%s\n' "marker"
    return 0
  fi

  if [[ "$(config_bootstrap_plan_state_for_step "$step" 2>/dev/null || true)" == "skipped" ]]; then
    printf '%s\n' "plan"
    return 0
  fi

  printf '%s\n' "none"
}
```

Use this in messaging if helpful.

### 5. Improve `skip` symmetry if low-risk

Current `skip STEP` creates only the marker.

With plan-authority, preferably:

```bash
sudo config --target labuser skip STEP
```

should:

```text
- create/update STEP.skipped marker
- change bootstrap.plan row to `skipped STEP` if plan exists
```

Preferred behavior:

```text
skip STEP:
  marker -> skipped
  plan row -> skipped

unskip STEP:
  marker -> removed
  plan row -> pending
```

If this is too much for this mini-milestone, at least update `unskip`.

### 6. Do not touch `.done` by default

`unskip` must not remove:

```text
STEP.done
STEP.failed
STEP.running
```

If the step is `.done`, then after unskip it may still be skipped by done marker during execution:

```text
[SKIP] STEP already done
```

That is correct.

If the user wants rerun, they should use:

```bash
sudo config --target labuser rm STEP
```

or the plan reset-done workflow.

### 7. Better blocked-by-plan message in `run_once`

If not already done, make the plan skip message actionable.

Current:

```text
[SKIP] install_gui_support skipped by bootstrap plan
```

Improve to:

```text
[SKIP] install_gui_support skipped by bootstrap.plan
[INFO] To allow it: sudo config --target labuser unskip install_gui_support
```

After this milestone, that hint is correct because `unskip` updates the plan row.

### 8. Help update

Update `config help`, `config help bootstrap`, `config help howto`, or `config help menu` where relevant.

Explain:

```text
skip STEP
    Block a step by writing STEP.skipped and marking the plan row skipped.

unskip STEP
    Allow a step by removing STEP.skipped and changing the plan row to pending.

rm STEP
    Remove saved state and uninstall/cleanup where supported.
    Use rm when you want a completed step to run again.
```

## Acceptance

- `sudo config --target labuser unskip does_not_exist` fails clearly.
- `sudo config --target labuser skip does_not_exist` fails clearly if validation is added for skip.
- `sudo config --target labuser unskip install_gui_support` removes `.skipped` marker if present.
- If `bootstrap.plan` has `skipped install_gui_support`, `unskip` changes it to `pending install_gui_support`.
- If no marker exists but plan says skipped, `unskip` reports the marker was absent and updates the plan.
- If neither marker nor plan skip exists, `unskip` reports the step is already allowed.
- `unskip` does not remove `.done`.
- `unskip` does not run any bootstrap step.
- `skip install_gui_support` creates `.skipped` marker and, if implemented, changes plan row to skipped.
- `bootstrap step install_gui_support` no longer says plan skipped after `unskip`, unless another state such as `.done` blocks it.
- Plan file remains target-owned.
- Existing `plan-apply` behavior still works.
- No broad bootstrap/install/package/mount commands are run.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_08A_plan_aware_unskip_postcheck.log
```

Use simple evidence-log style:

```text
AN1-08A plan-aware unskip postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_bootstrap_plan_set_step_state found: yes
config_bootstrap_step_skip_reason found: yes/no
Result: PASS

[3] Unknown step validation
Command attempted:
sudo config --target labuser unskip does_not_exist

Observed:
- Failed clearly.
- Reported unknown bootstrap step.
- No marker or plan file changed.

Result: PASS

[4] Unskip plan-only skip
Setup:
- bootstrap.plan contains skipped install_gui_support
- no install_gui_support.skipped marker exists

Command attempted:
sudo config --target labuser unskip install_gui_support

Observed:
- Reported no skipped marker or equivalent.
- Updated bootstrap.plan to pending install_gui_support.
- Plan file remained target-owned.
- No .done marker removed.
- No bootstrap step executed.

Result: PASS

[5] Unskip marker-and-plan skip
Setup:
- bootstrap.plan contains skipped install_gui_support
- install_gui_support.skipped marker exists

Command attempted:
sudo config --target labuser unskip install_gui_support

Observed:
- Removed install_gui_support.skipped marker.
- Updated bootstrap.plan to pending install_gui_support.
- No .done marker removed.
- No bootstrap step executed.

Result: PASS

[6] Already allowed
Setup:
- bootstrap.plan contains pending install_gui_support
- no install_gui_support.skipped marker exists

Command attempted:
sudo config --target labuser unskip install_gui_support

Observed:
- Reported step already allowed by marker and plan.
- No files changed except harmless timestamp-free no-op if implementation rewrites identically.

Result: PASS

[7] Optional skip symmetry
Command attempted:
sudo config --target labuser skip install_gui_support

Observed:
- Created install_gui_support.skipped marker.
- Updated bootstrap.plan to skipped install_gui_support if symmetry implemented.
- Plan file remained target-owned.

Result: PASS or SKIP
Reason if SKIP: skip symmetry intentionally left for later.

[8] Step execution gate message
Command attempted:
sudo config --target labuser bootstrap step install_gui_support when plan says skipped

Observed:
- Message explains skipped by bootstrap.plan.
- Hint says to run sudo config --target labuser unskip install_gui_support.

Result: PASS

[9] Regression
Observed:
- bootstrap plan still works.
- bootstrap status still works.
- plan-apply still works.
- skip/unskip/rm command dispatch still works.

Result: PASS

[10] Safety
Observed:
- No broad bootstrap/install/package/mount commands were run.
- No apt/docker/kubectl/minikube/sqlcmd commands were run.

Result: PASS

Overall
- unskip now means allow this step to run again.
- marker skip and plan skip no longer confuse the operator.
- bootstrap.plan remains the operator authority for desired state.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap plan
sudo config --target labuser unskip does_not_exist
sudo config --target labuser unskip install_gui_support
sudo config --target labuser bootstrap plan
sudo config --target labuser bootstrap step install_gui_support
```

Do not run broad execution in this milestone:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```
