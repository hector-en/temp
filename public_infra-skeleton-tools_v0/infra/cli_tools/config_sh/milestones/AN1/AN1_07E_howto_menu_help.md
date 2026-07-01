# AN1-07E — Add How-To and Menu Help Topics

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Add two user-friendly help topics:

```bash
config help howto
config help menu
```

These should help a normal operator understand common workflows without reading the detailed bootstrap implementation notes.

This is a help/documentation milestone only.

## Current context

AN1-07D improves `config bootstrap help` with clearer plan-file language.

This milestone adds companion top-level help topics:

```text
howto = task-oriented workflows
menu  = compact command map
```

## Scope

Edit only:

```text
/home/vmuser/.local/bin/config.sh
```

Likely functions to update/add:

```bash
config_help
config_help_all
config_usage
config_help_howto
config_help_menu
```

Do not change bootstrap execution, plan reconciliation, marker logic, mount logic, pull/push logic, or run-as-target behavior.

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

Add these commands:

```bash
config help howto
config help menu
```

Also support:

```bash
config howto
config menu
```

if that fits the current command dispatch cleanly. If not, keep only `config help howto` and `config help menu`.

Update help topic list to include:

```text
all
howto
menu
bootstrap
install
mount
pull
push
run
```

## Add `config_help_howto`

Create a new helper:

```bash
config_help_howto() {
  cat <<'EOF'
...
EOF
}
```

Use this text, adapting spacing if needed:

```text
Common workflows:

  See who config will affect:
    config status
    sudo config --target labuser status

  Open the bootstrap checklist:
    sudo config --target labuser bootstrap plan-file
    sudoedit "$(sudo config --target labuser bootstrap plan-file)"

  Apply the checklist safely:
    sudo config --target labuser bootstrap plan-apply --skips-only

  Check what bootstrap will do:
    sudo config --target labuser bootstrap plan

  Run allowed bootstrap steps:
    sudo config --target labuser bootstrap

  Skip a step for now:
    sudo config --target labuser skip STEP_NAME

  Allow a skipped step to run again:
    sudo config --target labuser unskip STEP_NAME

  Remove a step's saved state:
    sudo config --target labuser rm STEP_NAME

  Make the checklist match saved history:
    sudo config --target labuser bootstrap plan-apply --markers-win

  Make saved state follow the checklist:
    sudo config --target labuser bootstrap plan-apply --plan-wins

  Re-run completed steps from the checklist:
    sudo config --target labuser bootstrap plan-apply --plan-wins --reset-done
    sudo config --target labuser bootstrap

  Mount required shares:
    sudo config --target labuser mount
    sudo config --target labuser mount --all

  Pull config files for a target user:
    sudo config --target labuser pull

  Push config files for a target user:
    sudo config --target labuser push

  Run a command as the target user:
    config --target labuser run --shell-command 'echo $HOME'

Safe order for bootstrap:
  1. edit bootstrap.plan
  2. run plan-apply
  3. check bootstrap plan
  4. run bootstrap

Important:
  plan-apply never installs anything.
  bootstrap/install runs the allowed steps.
  --reset-done can make completed steps run again.
```

## Add `config_help_menu`

Create a new helper:

```bash
config_help_menu() {
  cat <<'EOF'
...
EOF
}
```

Use this text, adapting spacing if needed:

```text
Command menu:

  help TOPIC        Show help. Topics: howto, menu, bootstrap, mount, pull, push, run
  status            Show current target, paths, and saved state
  bootstrap         Run or inspect bootstrap/install workflow
  install           Alias for bootstrap
  mount             Run mount workflow
  pull              Pull config files into target home
  push              Push target config files to /mnt/egress
  skip STEP         Block a bootstrap step from running
  unskip STEP       Allow a skipped bootstrap step to run
  rm STEP           Remove saved state and uninstall/cleanup where supported
  run               Run a command or shell file as TARGET_USER

Target selection:

  --target USER     Configure USER instead of the current/default user
  -t USER           Short form of --target
  --user USER       Alias of --target

Bootstrap plan commands:

  bootstrap plan-file
      Print the checklist path.

  bootstrap plan-init
      Create the checklist if missing.

  bootstrap plan
      Show the current step table.

  bootstrap status
      Same current step table as plan.

  bootstrap plan-apply
      Compare checklist with saved history and reconcile.

  bootstrap plan-apply --skips-only
      Safest apply mode. Only sync skipped/not-skipped state.

  bootstrap plan-apply --plan-wins
      Make saved skip state follow bootstrap.plan.

  bootstrap plan-apply --markers-win
      Rewrite bootstrap.plan from saved marker history.

  bootstrap plan-apply --plan-wins --reset-done
      Allow completed steps to be reset and run again.

Examples:

  sudo config --target labuser status
  sudo config --target labuser bootstrap plan-file
  sudo config --target labuser bootstrap plan-apply --skips-only
  sudo config --target labuser bootstrap plan
  sudo config --target labuser bootstrap
  sudo config --target labuser skip install_docker
  sudo config --target labuser unskip install_docker
  config --target labuser run --shell-command 'echo $HOME'
```

## Update `config_help`

Add cases:

```bash
howto)
  config_help_howto
  ;;
menu|commands)
  config_help_menu
  ;;
```

Update unknown topic message to include:

```text
Available help topics: all, howto, menu, bootstrap, install, pull, push, run, mount
```

## Update `config_help_all`

Include the new sections in a useful order:

```bash
config_usage
config_help_menu
config_help_howto
config_pull_push_usage
config_bootstrap_usage
config_user_usage
mounts_usage
```

Add blank lines between sections.

## Update `config_usage`

Add a short help-topic block:

```text
Help topics:
  config help howto     Common workflows
  config help menu      Compact command menu
  config help bootstrap Bootstrap/install plan workflow
  config help mount     Mount workflow
  config help pull      Pull sync
  config help push      Push sync
  config help run       Run command as target user
```

Add examples:

```bash
config help howto
config help menu
config help bootstrap
```

## Optional direct commands

If straightforward, support:

```bash
config howto
config menu
```

by adding dispatch cases:

```bash
howto)
  config_help_howto
  ;;
menu|commands)
  config_help_menu
  ;;
```

If adding direct commands risks clutter, skip this and keep help topics only.

## Acceptance

- `config help howto` prints the task-oriented workflow help.
- `config help menu` prints the compact command menu.
- `config help all` includes both new sections.
- `config help` lists `howto` and `menu` topics.
- `config help unknown-topic` lists the new topics in the available topics message.
- If implemented, `config howto` and `config menu` work.
- Shell syntax passes.
- No behavior changes to bootstrap/plan/apply/markers.
- No package, mount, or broad bootstrap commands are run.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_07E_howto_menu_help_postcheck.log
```

Use simple evidence-log style:

```text
AN1-07E howto/menu help postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Help topics
Command attempted:
config help howto
config help menu
config help all

Observed:
- howto help printed common workflows.
- menu help printed compact command map.
- help all included both sections.

Result: PASS

[3] Main help topic list
Command attempted:
config help

Observed:
- howto and menu topics were listed.
- bootstrap/install plan workflow was still referenced.

Result: PASS

[4] Unknown topic message
Command attempted:
config help does-not-exist

Observed:
- Failed with exit 2.
- Available topics included all, howto, menu, bootstrap, install, pull, push, run, mount.

Result: PASS

[5] Optional direct commands
Command attempted:
config howto
config menu

Observed:
- Worked if implemented, otherwise skipped by design.

Result: PASS or SKIP

[6] Safety
Observed:
- No bootstrap/install/mount/package commands were run.
- No marker or plan state was changed.

Result: PASS

Overall
- Normal users now have a task-oriented help page and a compact command menu.
- Help remains safe and non-destructive.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

config help
config help howto
config help menu
config help all
config help does-not-exist
```

Do not run broad execution in this milestone:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
sudo config --target labuser mount
```
