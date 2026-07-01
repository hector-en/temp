# AN1-07D — Bootstrap Plan Help and Operator Context

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Current codebase status

AN1-07C appears implemented.

Current code has the bootstrap plan helpers, diff helpers, marker-state helpers, apply modes, and command dispatch for:

```bash
plan-init
plan-file
plan-validate
plan-diff
plan-apply
```

Current `config_bootstrap_usage` is too terse and slightly misleading for the new workflow. It still presents `plan-validate` and `plan-diff` as first-class operator commands and does not give enough context for:

```text
bootstrap.plan
marker files
plan-apply default behavior
--plan-wins
--markers-win
--skips-only
--reset-done
when bootstrap actually executes
```

This milestone is documentation/help only.

## Goal

Update help text so an operator can safely understand and use the declarative bootstrap plan workflow without needing external notes.

Primary user-facing commands should be:

```bash
sudo config --target labuser bootstrap plan-init
sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap plan-apply
sudo config --target labuser bootstrap
```

and the same through the `install` alias.

## Scope

Edit only:

```text
/home/vmuser/.local/bin/config.sh
```

Specifically improve:

```bash
config_usage
config_bootstrap_usage
```

Optionally improve wording/error text inside:

```bash
config_bootstrap_plan_apply
config_bootstrap_plan_diff
config_bootstrap_plan_validate
```

Do not change plan reconciliation behavior unless needed for wording/help consistency.

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

## Required help design

### 1. Main `config help`

Update the main usage examples to include the safe plan workflow.

Add or reference:

```bash
sudo config --target labuser bootstrap plan-file
sudo config --target labuser bootstrap plan-apply --skips-only
sudo config --target labuser bootstrap
```

Main help should make this clear:

```text
Use `config bootstrap help` for plan-file / plan-apply details.
```

### 2. Bootstrap help should explain the model

Replace the current terse `config_bootstrap_usage` with a richer but concise help section.

Required concepts:

```text
bootstrap.plan = desired operator state
marker files   = runtime evidence/state
plan-apply     = reconcile plan and markers
bootstrap      = execute runnable steps
```

Explain that `plan-apply` never runs installers.

### 3. Public commands

Document these as primary:

```text
run / no subcommand
status
plan
plan-init
plan-file
plan-apply
help
```

Keep these as legacy/debug if still supported:

```text
plan-validate
plan-diff
```

Suggested wording:

```text
Legacy/debug:
  plan-validate  Parse plan and print warnings; no changes
  plan-diff      Show plan state vs marker state; no changes
```

Do not remove them in this milestone.

### 4. Explain apply modes

Help must clearly explain:

```text
plan-apply
  Default behavior. Validates the plan, shows drift, and applies the current default reconciliation.
  In the current implementation, bare plan-apply adopts marker state into bootstrap.plan when drift exists.

plan-apply --skips-only
  Safe mode. Syncs only skipped/not-skipped intent:
  - plan skipped -> create/update .skipped
  - plan pending/next -> remove .skipped
  - never removes .done
  - never runs bootstrap steps

plan-apply --plan-wins
  Applies bootstrap.plan to marker state for skip/runnable intent.
  Preserves .done markers unless --reset-done is also provided.

plan-apply --plan-wins --reset-done
  Dangerous mode. Allows removing .done markers so steps may run again.

plan-apply --markers-win
  Rewrites bootstrap.plan from current marker state.
  Conservative mapping:
  - done/skipped -> skipped
  - failed/running/none -> pending
```

### 5. Explain states

Include a compact state explanation:

```text
Plan states:
  pending STEP   desired runnable
  next STEP      desired next/runnable; single-step execution comes later
  skipped STEP   desired skipped

Marker states:
  .done          completed runtime evidence
  .failed        previous failure evidence
  .running       in-progress/stale evidence
  .skipped       marker-level skip gate
```

### 6. Explain the operator workflows

Add examples for the three common workflows.

#### Safe review workflow

```bash
sudo config --target labuser bootstrap plan-file
sudoedit "$(sudo config --target labuser bootstrap plan-file)"
sudo config --target labuser bootstrap plan-apply --skips-only
sudo config --target labuser bootstrap plan
```

#### Execute runnable pending steps

```bash
sudo config --target labuser bootstrap plan-apply --skips-only
sudo config --target labuser bootstrap
```

#### Make plan fully authoritative and allow rerun

```bash
sudo config --target labuser bootstrap plan-apply --plan-wins --reset-done
sudo config --target labuser bootstrap
```

Warn that this can rerun installers.

### 7. Clarify `status` vs `plan`

Current `status` and `plan` both call `config_bootstrap_summary`.

Help should say that for now both show the same resolved bootstrap table.

Suggested wording:

```text
status and plan currently show the same resolved step table.
The table prefers runtime marker evidence where present, then falls back to bootstrap.plan.
```

### 8. Add execution warning

Make it explicit:

```text
`plan-apply` never executes installers.
`config bootstrap` / `config install` executes runnable steps.
Broad bootstrap can run apt, downloads, Docker, Kubernetes, SQL, pyenv, Anaconda, or other installers depending on the plan and markers.
```

### 9. Help topic list

Update unknown help topic text if needed:

```text
Available help topics: all, bootstrap, install, pull, push, run, mount
```

## Suggested replacement for `config_bootstrap_usage`

Codex may adapt formatting, but preserve the substance:

```bash
config_bootstrap_usage() {
  cat <<'EOF'
Usage:
  config bootstrap [run|status|plan|plan-init|plan-file|plan-apply|help]
  config install   [run|status|plan|plan-init|plan-file|plan-apply|help]

Model:
  bootstrap.plan is the desired operator state for TARGET_USER.
  Marker files under STATE_DIR are runtime evidence/state.
  plan-apply reconciles bootstrap.plan and marker files.
  plan-apply never runs bootstrap/install steps.
  bootstrap/install run executes runnable steps.

Plan states in bootstrap.plan:
  pending STEP    Desired runnable step
  next STEP       Desired next/runnable step; single-step execution comes later
  skipped STEP    Desired skipped step

Marker states:
  STEP.done       Step completed before
  STEP.failed     Step failed before
  STEP.running    Step is or was running
  STEP.skipped    Marker-level skip gate

Commands:
  run             Run the bootstrap workflow; default when no subcommand is given
  status          Show resolved step table; non-destructive
  plan            Same resolved step table as status for now; non-destructive
  plan-init       Create target bootstrap.plan if missing
  plan-file       Print target bootstrap.plan path
  plan-apply      Validate, compare with markers, then reconcile
  help            Show this help

plan-apply modes:
  plan-apply
      Current default reconciliation. If drift exists, adopts marker state into
      bootstrap.plan in the current implementation.

  plan-apply --skips-only
      Safest mode. Syncs only skip intent:
        plan skipped      -> create/update STEP.skipped
        plan pending/next -> remove STEP.skipped
      Never removes STEP.done. Never runs bootstrap steps.

  plan-apply --plan-wins
      Applies bootstrap.plan skip/runnable intent to marker state.
      Preserves STEP.done unless --reset-done is also provided.

  plan-apply --plan-wins --reset-done
      Dangerous reset mode. May remove STEP.done so a step can run again.

  plan-apply --markers-win
      Rewrites bootstrap.plan from current marker state:
        done/skipped        -> skipped
        failed/running/none -> pending

Legacy/debug commands:
  plan-validate   Parse plan and print warnings; no changes
  plan-diff       Show plan state vs marker state; no changes

Typical safe workflow:
  sudo config --target labuser bootstrap plan-file
  sudoedit "$(sudo config --target labuser bootstrap plan-file)"
  sudo config --target labuser bootstrap plan-apply --skips-only
  sudo config --target labuser bootstrap plan

Execute runnable pending steps:
  sudo config --target labuser bootstrap plan-apply --skips-only
  sudo config --target labuser bootstrap

Make plan fully authoritative and allow reruns:
  sudo config --target labuser bootstrap plan-apply --plan-wins --reset-done
  sudo config --target labuser bootstrap

Safety:
  plan-apply never runs installers.
  bootstrap/install can run apt, downloads, Docker, Kubernetes, SQL tools,
  pyenv, Anaconda, and other installers depending on plan and marker state.
  Use status/plan before broad execution.
EOF
}
```

## Acceptance

- `config help bootstrap` explains:
  - bootstrap.plan
  - markers
  - plan-apply
  - plan-apply modes
  - when actual execution happens
- `config help install` shows the same improved help.
- `config help all` includes the improved bootstrap help.
- Main `config help` points users toward `config bootstrap help`.
- Help no longer makes `plan-validate` / `plan-diff` look like the normal operator workflow.
- Help says `status` and `plan` are non-destructive.
- Help says `plan-apply` is non-executing.
- Help says `bootstrap` / `install` are executing commands.
- Help clearly distinguishes:
  - `--skips-only`
  - `--plan-wins`
  - `--markers-win`
  - `--reset-done`
- Help warns that `--reset-done` can make steps run again.
- Help warns broad bootstrap can run package installers.
- No behavior changes to plan reconciliation logic unless needed for wording consistency.
- No package/mount/bootstrap execution is run in postcheck.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_07D_bootstrap_plan_help_context_postcheck.log
```

Use simple evidence-log style:

```text
AN1-07D bootstrap plan help/context postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Help topic routing
Command attempted:
config help bootstrap
config help install
config help all

Observed:
- bootstrap/install help printed successfully.
- help all included the improved bootstrap section.

Result: PASS

[3] Help content
Observed help mentions:
- bootstrap.plan is desired operator state
- marker files are runtime evidence/state
- plan-apply reconciles plan and markers
- plan-apply never runs bootstrap/install steps
- bootstrap/install run executes runnable steps
- --skips-only
- --plan-wins
- --markers-win
- --reset-done
- --reset-done can make steps run again

Result: PASS

[4] Main help
Command attempted:
config help

Observed:
- Main help points users to config bootstrap help.
- Main examples include a safe plan-file / plan-apply workflow or reference bootstrap help.

Result: PASS

[5] Non-destructive checks
Command attempted:
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser bootstrap plan-file

Observed:
- Commands remained non-destructive.
- No apt/mount/bootstrap execution occurred.

Result: PASS

[6] Regression
Command attempted:
sudo config --target labuser bootstrap plan-apply --skips-only
sudo config --target labuser bootstrap plan-apply --markers-win
sudo config --target labuser bootstrap plan-apply --plan-wins

Observed:
- Existing command parsing still works.
- No bootstrap/install steps were executed by plan-apply.

Result: PASS or SKIP
Reason if SKIP: marker/plan mutation intentionally not run on live target.

Overall
- Help now matches the plan-authority workflow.
- Operator can understand plan-init, plan-file, plan-apply, and bootstrap execution order from built-in help.
- No live package/mount/bootstrap work was run.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

config help
config help bootstrap
config help install
config help all

sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser bootstrap plan-file
```

Do not run broad execution in this milestone:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```
