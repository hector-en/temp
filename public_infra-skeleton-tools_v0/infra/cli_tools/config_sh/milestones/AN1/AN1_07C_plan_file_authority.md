# AN1-07C — Plan File as Bootstrap Authority

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Make the target-local bootstrap plan file the authoritative desired state.

Public command surface should become simple:

```bash
sudo config --target labuser bootstrap plan-init
sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap plan-apply
```

and same through `install` alias:

```bash
sudo config --target labuser install plan-init
sudo config --target labuser install plan-file
sudo config --target labuser install plan-apply
```

Internal helpers may still validate, diff, compare markers, and reconcile state, but the operator should not need separate public commands like:

```text
plan-validate
plan-diff
plan-apply --skips-only
```

unless they remain hidden/internal or backward-compatible aliases.

## New authority rule

```text
bootstrap.plan = desired operator state
marker files   = runtime evidence/state
```

When they diverge, the plan file wins only after `plan-apply` confirms or is invoked with an explicit non-interactive mode.

## Public command model

Keep only these as primary documented commands:

```text
plan-init   Create target bootstrap.plan if missing
plan-file   Print target bootstrap.plan path
plan-apply  Validate, compare, reconcile, and apply plan authority
```

Optional backward compatibility:

```text
plan-validate
plan-diff
plan-apply --skips-only
```

may keep working, but mark as legacy/internal in help or stop documenting them.

## Required plan format

Keep existing AN1-07A format:

```text
next STEP_NAME
pending STEP_NAME
skipped STEP_NAME
```

Meaning:

```text
next:
  desired to run next or via future single-step flow.
  For current broad bootstrap behavior, treated as runnable/pending.

pending:
  desired runnable step.

skipped:
  desired skipped step.
```

## Desired state semantics

For each step:

### Plan = skipped

After apply:

```text
STEP.skipped exists
STEP.done is removed only if explicit reset mode is chosen
STEP.failed is removed
STEP.running is removed
```

Default behavior should not remove `.done` unless the operator explicitly selects plan authority reset.

### Plan = pending or next

After apply:

```text
STEP.skipped is removed
STEP.failed may be kept by default, unless explicit retry/reset mode is selected
STEP.running is not removed unless stale-reset mode is selected
STEP.done is not removed by default
```

If a step is `done` but the plan says `pending`, that is a divergence. The operator must choose whether to:

```text
keep marker done and update/accept current state
or
let plan win and remove .done so the step can run again
```

Do not silently delete `.done`.

## Required apply workflow

`plan-apply` should perform these phases:

```text
1. Validate plan syntax and known steps.
2. Check header target_user/target_home against active target.
3. Build internal plan-vs-marker diff.
4. If no drift:
     apply safe marker sync and exit.
5. If drift exists:
     show drift summary.
     ask operator what authority to use, unless non-interactive mode supplied.
6. Apply selected reconciliation.
7. Print final plan/marker summary.
```

## Drift categories

Detect and report at least:

```text
header_target_mismatch
plan_skipped_marker_done
plan_skipped_marker_none
plan_pending_marker_skipped
plan_pending_marker_done
plan_next_marker_done
plan_none_marker_present
```

Example output:

```text
Bootstrap plan drift:
  Step                              Plan      Marker    Meaning
  update_apt                        skipped   done      plan wants skipped, marker says already done
  install_dev_env_shell_init        pending   skipped   plan wants runnable, marker blocks it
```

## Interactive choices

When drift exists and stdin is interactive, prompt:

```text
Plan and marker state diverge for target labuser.

Choose reconciliation:
  [p] plan wins          apply bootstrap.plan to marker state
  [m] markers win        rewrite bootstrap.plan from current markers
  [s] safe skips only    only sync .skipped markers; never remove .done
  [a] abort              make no changes

Selection [a]:
```

Default is abort.

### Plan wins

`plan-apply --plan-wins` or interactive `p`.

This means:

```text
plan skipped:
  ensure .skipped
  remove .failed and .running
  remove .done only if explicit --reset-done is also supplied OR after interactive confirmation

plan pending/next:
  remove .skipped
  remove .done only after explicit confirmation or --reset-done
  do not run anything
```

Because deleting `.done` can cause re-execution, make it explicit.

Recommended safest implementation:

- `--plan-wins` does not remove `.done` automatically.
- If `.done` conflicts with plan pending/next/skipped, print warning and leave `.done`.
- Add optional flag:

```bash
--reset-done
```

only valid with `--plan-wins`.

So:

```bash
sudo config --target labuser bootstrap plan-apply --plan-wins
```

syncs skip markers but preserves `.done`.

```bash
sudo config --target labuser bootstrap plan-apply --plan-wins --reset-done
```

allows removing `.done` markers where they conflict with plan.

### Markers win

`plan-apply --markers-win` or interactive `m`.

This rewrites `bootstrap.plan` to reflect current marker state.

Mapping:

```text
done -> skipped
skipped -> skipped
failed -> pending
running -> pending
none -> pending
```

This produces a conservative plan that does not rerun completed or skipped work.

### Safe skips only

`plan-apply --skips-only` or interactive `s`.

This is existing AN1-07B safe mode:

```text
plan skipped:
  create/update .skipped
  clear .failed/.running
  keep .done

plan pending/next:
  remove .skipped
  keep .done/.failed/.running

plan none:
  no change
```

No `.done` deletion.

### Abort

No changes.

## Non-interactive behavior

If drift exists and stdin is not interactive:

```text
plan-apply must abort unless an explicit mode is supplied.
```

Allowed explicit modes:

```bash
sudo config --target labuser bootstrap plan-apply --plan-wins
sudo config --target labuser bootstrap plan-apply --plan-wins --reset-done
sudo config --target labuser bootstrap plan-apply --markers-win
sudo config --target labuser bootstrap plan-apply --skips-only
```

No bare non-interactive apply with drift.

If no drift exists, bare `plan-apply` may apply safe sync and exit.

## Execution behavior after apply

Broad execution remains:

```bash
sudo config --target labuser bootstrap
```

`plan-apply` itself must never execute bootstrap steps.

After applying a plan where desired steps are `pending`, the corresponding `.skipped` markers should be gone, so broad bootstrap can run them.

If future AN1-08 is implemented, execution can be narrower:

```bash
sudo config --target labuser bootstrap step STEP_NAME
```

## Required helper changes

### 1. Internalize validate/diff

Keep helper functions but route public usage through `plan-apply`.

Suggested helpers:

```bash
config_bootstrap_plan_validate_internal
config_bootstrap_plan_diff_rows
config_bootstrap_plan_print_diff
config_bootstrap_plan_has_drift
config_bootstrap_plan_prompt_reconciliation
config_bootstrap_plan_apply_skips_only
config_bootstrap_plan_apply_plan_wins
config_bootstrap_plan_apply_markers_win
config_bootstrap_plan_rewrite_from_markers
```

### 2. Marker state helper

Ensure this exists:

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

### 3. Plan apply dispatcher

Implement:

```bash
config_bootstrap_plan_apply() {
  local mode=""
  local reset_done=0
  local has_drift=0
  local selection=""

  config_runtime_init || return 1
  config_bootstrap_plan_validate_internal || return 1

  # parse args:
  #   --plan-wins
  #   --markers-win
  #   --skips-only
  #   --reset-done only with --plan-wins

  # print diff if drift exists
  # if mode empty and drift and terminal, prompt
  # if mode empty and drift and non-interactive, abort
  # execute selected reconciliation
}
```

## Required command dispatch

In `config_run_bootstrap`, support:

```text
plan-init
plan-file
plan-apply [--plan-wins|--markers-win|--skips-only] [--reset-done]
```

Primary documented command:

```bash
sudo config --target labuser bootstrap plan-apply
```

Legacy/internal commands may still work:

```text
plan-validate
plan-diff
```

but should not be required for the normal operator workflow.

## Help update

Update `config_bootstrap_usage` to show:

```text
plan-init     Create target bootstrap.plan if missing
plan-file     Print target bootstrap.plan path
plan-apply    Validate plan, compare with markers, and reconcile
```

Examples:

```bash
sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap plan-apply
sudo config --target labuser bootstrap plan-apply --plan-wins
sudo config --target labuser bootstrap plan-apply --markers-win
sudo config --target labuser bootstrap plan-apply --skips-only
sudo config --target labuser bootstrap plan-apply --plan-wins --reset-done
```

Add safety note:

```text
plan-apply never runs bootstrap steps.
Run `sudo config --target USER bootstrap` after apply to execute runnable pending steps.
```

## Acceptance

- `plan-init` still creates target-owned `bootstrap.plan`.
- `plan-file` prints the target-specific plan path.
- Bare `plan-apply` validates plan and computes diff.
- Bare interactive `plan-apply` prompts when plan and markers diverge.
- Bare non-interactive `plan-apply` aborts when drift exists.
- `plan-apply --skips-only` keeps current safe skip-only behavior.
- `plan-apply --plan-wins` makes plan states authoritative for skip markers but does not remove `.done`.
- `plan-apply --plan-wins --reset-done` may remove conflicting `.done` markers.
- `plan-apply --markers-win` rewrites `bootstrap.plan` from current marker state.
- `plan-apply` never runs bootstrap/install steps.
- `plan-apply` never runs package/mount work.
- `plan-apply` prints final diff/summary after changes.
- `bootstrap plan` / `bootstrap status` continue to display resolved state.
- Existing `skip`, `unskip`, and `rm` commands still work.
- `install plan-apply ...` behaves as alias.
- Invalid plan fails before any marker or plan rewrite.
- Header mismatch is shown before apply decisions.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_07C_plan_file_authority_postcheck.log
```

Use simple evidence-log style:

```text
AN1-07C plan file as bootstrap authority postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Public command surface
bootstrap plan-init works: yes
bootstrap plan-file works: yes
bootstrap plan-apply works: yes
install plan-apply works as alias: yes
Result: PASS

[3] Bare apply drift behavior
Command attempted:
sudo config --target labuser bootstrap plan-apply

Observed:
- Validated bootstrap.plan.
- Printed drift summary when plan and markers diverged.
- Prompted in interactive mode or aborted in non-interactive mode.
- No changes were made on abort.

Result: PASS

[4] Safe skips-only mode
Command attempted:
sudo config --target labuser bootstrap plan-apply --skips-only

Observed:
- Plan skipped created/updated .skipped markers.
- Plan pending/next removed .skipped markers.
- .done markers were not removed.
- No bootstrap steps were run.

Result: PASS

[5] Plan wins mode without reset-done
Command attempted:
sudo config --target labuser bootstrap plan-apply --plan-wins

Observed:
- Plan states were applied to skip markers.
- Conflicting .done markers were preserved.
- Warnings were printed for done conflicts.
- No bootstrap steps were run.

Result: PASS

[6] Plan wins mode with reset-done
Command attempted on safe fixture:
sudo config --target labuser bootstrap plan-apply --plan-wins --reset-done

Observed:
- Conflicting .done markers were removed only where plan required.
- No bootstrap steps were run.

Result: PASS or SKIP
Reason if SKIP: destructive marker reset not tested on live target.

[7] Markers win mode
Command attempted on safe fixture or backed-up plan:
sudo config --target labuser bootstrap plan-apply --markers-win

Observed:
- bootstrap.plan was rewritten from marker state.
- done -> skipped
- skipped -> skipped
- failed/running/none -> pending
- Plan file remained target-owned.

Result: PASS or SKIP
Reason if SKIP: plan rewrite tested only on temp fixture.

[8] Invalid plan safety
Command attempted:
temporary invalid bootstrap.plan, then plan-apply --plan-wins

Observed:
- Apply failed before changes.
- No marker files changed.
- Plan file was not rewritten.

Result: PASS

[9] Existing command regression
sudo config --target labuser skip STEP works: yes
sudo config --target labuser unskip STEP works: yes
sudo config --target labuser bootstrap status works: yes
sudo config --target labuser bootstrap plan works: yes

Result: PASS

[10] Safety regression
plan-apply never ran bootstrap/install/package/mount work: yes
config --target labuser bootstrap without sudo still blocked if AN1-07 applied: yes
Result: PASS

Overall
- bootstrap.plan is the authoritative desired state after explicit apply.
- marker state remains runtime evidence.
- apply validates/diffs internally.
- operator can choose plan wins, markers win, or safe skips only.
- no dangerous marker reset occurs without explicit mode.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap plan-apply
sudo config --target labuser bootstrap plan-apply --skips-only
sudo config --target labuser bootstrap plan-apply --plan-wins
sudo config --target labuser bootstrap plan-apply --markers-win

sudo config --target labuser install plan-apply --skips-only
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
```

Use `--reset-done` only on a safe fixture or after intentional operator confirmation:

```bash
sudo config --target labuser bootstrap plan-apply --plan-wins --reset-done
```

Do not run broad execution in this milestone unless explicitly intended:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```
