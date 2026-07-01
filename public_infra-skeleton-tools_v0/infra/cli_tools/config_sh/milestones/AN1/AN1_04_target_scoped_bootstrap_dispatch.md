# AN1-04 — Validate Target-Scoped Bootstrap Dispatch

Source files to provide with this brief:
- `code_full_summary.txt`
- `AN1_target_user_config_cli_plan.md`
- AN1-01 implementation/postcheck
- AN1-02 implementation/postcheck
- AN1-03 implementation/postcheck

## Milestone goal

Make the `bootstrap` / `install` command path explicitly target-scoped and safely inspectable before any real install work is run.

AN1-01 through AN1-03 established:

- `sudo config --target labuser ...` reaches the correct config engine.
- Target/session context resolves to `labuser`, not `root`.
- Target state directories and marker files are target-owned.

AN1-04 should now harden the bootstrap dispatch layer so the operator can verify what would run for a target user without triggering package installs, mounts, Docker, Kubernetes, SQL tooling, or other destructive/long-running actions.

The key goal is to make target bootstrap state visible and predictable before running:

```bash
sudo config --target labuser bootstrap
```

## Why this milestone exists

The current bootstrap path already uses `run_once` markers and target-scoped `STATE_DIR`. But before we allow full target-user bootstrapping, we need a safe command that answers:

```text
For this target user, which bootstrap steps are done, skipped, failed, running, or pending?
```

This is needed because `vmuser` may already have many `.done` markers, while `labuser` may have a different set. The operator must be able to inspect the target-specific plan before running installers.

## Desired operator behavior

These commands should be safe and non-destructive:

```bash
sudo config --target labuser bootstrap status
sudo config --target labuser bootstrap plan
sudo config --target labuser install status
sudo config --target labuser install plan
```

They should print the same target-scoped bootstrap summary that `config_run_bootstrap` currently prints before running preflight/install steps, but they must not run:

- preflight network checks
- apt
- installers
- mounts
- Docker
- Kubernetes
- SQL tooling
- cleanup commands

They should report values based only on the selected target's state directory:

```text
STATE_DIR=/home/labuser/.local/state/config-sh
```

not `/home/vmuser/.local/state/config-sh`.

## Scope

Implement AN1-04 only.

In scope:

1. Add bootstrap subcommands:
   - `bootstrap status`
   - `bootstrap plan`
   - `install status`
   - `install plan`
2. Keep plain `bootstrap` and plain `install` behavior unchanged for now.
3. Ensure plan/status output is target-scoped.
4. Ensure plan/status initializes target-owned state safely through AN1-03 helpers.
5. Ensure `config_run_bootstrap` command parsing can distinguish:
   - no args: run existing bootstrap
   - `status`: print target-scoped summary only
   - `plan`: print target-scoped summary only
   - unknown arg: fail clearly
6. Add simple postcheck log.

Out of scope:

- Do not run package installs.
- Do not run full bootstrap.
- Do not run mounts.
- Do not change individual installer functions.
- Do not change `run_once` marker semantics.
- Do not add dry-run execution for each step yet.
- Do not change `skip`, `unskip`, or `rm` semantics except as needed for status checks.
- Do not rework CopyConfigFiles or PushConfigFiles.

## Current-code context

The existing dispatcher maps both commands to the same function:

```bash
bootstrap|install)
  config_run_bootstrap "$@"
  ;;
```

The existing `config_run_bootstrap` currently does this conceptually:

```bash
config_run_bootstrap() {
  config_runtime_init
  config_bootstrap_summary
  config_run_preflight_checks || return $?
  run_once update_apt UpdateAPT || return $?
  run_once standard_apps StandardApps || return $?
  ...
}
```

The summary already exists and should be reused:

```bash
config_bootstrap_summary
```

The problem is that the only way to reach the summary through `bootstrap` currently also continues into preflight and install steps.

## Required implementation

### 1. Add a bootstrap command helper

Refactor `config_run_bootstrap` into a parser-style wrapper.

Recommended shape:

```bash
config_run_bootstrap() {
  local subcmd="${1:-run}"

  case "$subcmd" in
    run)
      shift || true
      config_run_bootstrap_execute "$@"
      ;;
    status|plan)
      shift || true
      if (($#)); then
        echo "[ERROR] Unknown bootstrap ${subcmd} argument: $1" >&2
        config_bootstrap_usage >&2
        return 2
      fi
      config_runtime_init || return 1
      config_bootstrap_summary
      ;;
    help|-h|--help)
      config_bootstrap_usage
      ;;
    *)
      echo "[ERROR] Unknown bootstrap command: $subcmd" >&2
      config_bootstrap_usage >&2
      return 2
      ;;
  esac
}
```

Then move the current run behavior into:

```bash
config_run_bootstrap_execute() {
  config_runtime_init
  config_bootstrap_summary
  config_run_preflight_checks || return $?
  run_once update_apt UpdateAPT || return $?
  ...
}
```

### 2. Preserve no-arg behavior

This must still run the existing bootstrap workflow:

```bash
sudo config --target labuser bootstrap
sudo config --target labuser install
```

Do not change actual install order in this milestone.

### 3. Add bootstrap usage

Add a helper:

```bash
config_bootstrap_usage() {
  cat <<'EOF'
Usage: config bootstrap [run|status|plan|help]
       config install   [run|status|plan|help]

Commands:
  run       Run the existing bootstrap workflow
  status    Show target-scoped bootstrap step state only
  plan      Same as status; safe alias for inspection
  help      Show this help

Examples:
  sudo config --target labuser bootstrap status
  sudo config --target labuser install plan
  sudo config --target labuser bootstrap
EOF
}
```

Also update the main `config_usage` line for bootstrap/install minimally:

```text
bootstrap, install Run or inspect install/bootstrap workflow; see `config bootstrap help`
```

### 4. Ensure plan/status is non-destructive

`bootstrap status` and `bootstrap plan` may call:

```bash
config_runtime_init
config_bootstrap_summary
```

They must not call:

```bash
config_run_preflight_checks
run_once
UpdateAPT
StandardApps
Install*
mounts_run
CopyConfigFiles
PushConfigFiles
```

### 5. Confirm target-scoped output

The summary must reflect only the selected target's state directory.

If `labuser` has only:

```text
/home/labuser/.local/state/config-sh/update_apt.done
/home/labuser/.local/state/config-sh/standard_apps.done
```

then `sudo config --target labuser bootstrap status` should not list vmuser's markers.

## Acceptance criteria

AN1-04 is complete when all of these are true:

- `config_bootstrap_usage` exists.
- `config_run_bootstrap` accepts `status`, `plan`, `run`, and `help`.
- Existing no-arg `bootstrap` and `install` dispatch remains supported.
- `sudo config --target labuser bootstrap status` prints bootstrap state without running preflight or installers.
- `sudo config --target labuser bootstrap plan` behaves like `status`.
- `sudo config --target labuser install status` behaves like `bootstrap status`.
- Unknown bootstrap subcommands fail clearly with exit code `2`.
- Target/session context from AN1-02 remains correct.
- State ownership from AN1-03 remains correct.
- No package installs, mounts, Docker, Kubernetes, SQL tools, or destructive cleanup commands are run during validation.

## Required validation post log

After implementing the patch, create a simple postcheck log at:

```bash
/home/vmuser/.local/patches/AN1_04_target_scoped_bootstrap_dispatch_postcheck.log
```

Use plain evidence-log style. The log should be readable without re-running the commands.

Use this pattern:

```text
AN1-04 target-scoped bootstrap dispatch postcheck
UTC YYYY-MM-DD HH:MM:SS

Validation after applying patch

[1] Syntax checks
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_bootstrap_usage found: yes
config_run_bootstrap_execute found: yes
config_run_bootstrap supports status/plan/run/help: yes
Result: PASS

[3] bootstrap status is safe
Command attempted:
sudo config --target labuser bootstrap status

Observed behavior:
- Command printed target-scoped bootstrap summary.
- Command did not run preflight checks.
- Command did not run apt/installers/mounts.
- STATE_DIR remained /home/labuser/.local/state/config-sh.

Result: PASS

[4] bootstrap plan is safe
Command attempted:
sudo config --target labuser bootstrap plan

Observed behavior:
- Command printed target-scoped bootstrap summary.
- Command behaved like bootstrap status.
- Command did not run preflight checks or installers.

Result: PASS

[5] install status alias
Command attempted:
sudo config --target labuser install status

Observed behavior:
- Command printed the same style target-scoped bootstrap summary.
- Command did not run preflight checks or installers.

Result: PASS

[6] unknown bootstrap subcommand
Command attempted:
sudo config --target labuser bootstrap does-not-exist

Observed behavior:
- Command failed clearly.
- Exit code was 2.
- Help/usage was shown.

Result: PASS

[7] AN1-02 context regression
Command attempted:
sudo config --target labuser status

Observed behavior:
- TARGET_USER=labuser
- TARGET_HOME=/home/labuser
- CURRENT_HOME=/home/labuser
- BASEDIR=/home/labuser/.local/wsl-mounts
- STATE_DIR=/home/labuser/.local/state/config-sh
- WSL_USER=labuser
- SMB_USER=labuser

Result: PASS

[8] AN1-03 ownership regression
Command attempted:
stat -c '%U:%G %a %n' /home/labuser/.local/state/config-sh

Observed behavior:
- Owner was labuser.
- Group was labuser or the primary group from id -gn labuser.
- Mode was 700.

Result: PASS

Overall
- Target bootstrap state can be inspected safely.
- plan/status do not run installers or preflight.
- Existing bootstrap/install execution path is preserved.
- AN1-02 and AN1-03 regressions passed.
- No package installs, mounts, or destructive actions were run.
```

If `labuser` does not exist, mark labuser-specific checks as `Result: SKIP` and explain why. Do not invent successful results.

## Suggested non-destructive checks

Use these or equivalent commands. Keep the final postcheck log simple and human-readable.

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

grep -q 'config_bootstrap_usage' /home/vmuser/.local/bin/config.sh
grep -q 'config_run_bootstrap_execute' /home/vmuser/.local/bin/config.sh

if getent passwd labuser >/dev/null 2>&1; then
  sudo config --target labuser bootstrap status >/tmp/an1-04-bootstrap-status.out
  grep -q 'Bootstrap plan:' /tmp/an1-04-bootstrap-status.out
  ! grep -q 'Preflight checks:' /tmp/an1-04-bootstrap-status.out

  sudo config --target labuser bootstrap plan >/tmp/an1-04-bootstrap-plan.out
  grep -q 'Bootstrap plan:' /tmp/an1-04-bootstrap-plan.out
  ! grep -q 'Preflight checks:' /tmp/an1-04-bootstrap-plan.out

  sudo config --target labuser install status >/tmp/an1-04-install-status.out
  grep -q 'Bootstrap plan:' /tmp/an1-04-install-status.out
  ! grep -q 'Preflight checks:' /tmp/an1-04-install-status.out

  set +e
  sudo config --target labuser bootstrap does-not-exist >/tmp/an1-04-unknown.out 2>/tmp/an1-04-unknown.err
  rc=$?
  set -e
  test "$rc" -eq 2
  grep -q 'Unknown bootstrap command' /tmp/an1-04-unknown.err

  sudo config --target labuser status >/tmp/an1-04-context.out
  grep -q '^TARGET_USER=labuser$' /tmp/an1-04-context.out
  grep -q '^CURRENT_HOME=/home/labuser$' /tmp/an1-04-context.out
  grep -q '^WSL_USER=labuser$' /tmp/an1-04-context.out
  grep -q '^SMB_USER=labuser$' /tmp/an1-04-context.out

  expected_group="$(id -gn labuser)"
  test "$(stat -c '%U' /home/labuser/.local/state/config-sh)" = "labuser"
  test "$(stat -c '%G' /home/labuser/.local/state/config-sh)" = "$expected_group"
else
  echo '[SKIP] labuser does not exist'
fi
```

Do not run:

```bash
config bootstrap
config install
config mount
config all
apt-get install
docker
kubectl
minikube
sqlcmd
```

## Codex instruction

Implement only AN1-04.

Add safe target-scoped bootstrap inspection subcommands:

```bash
config bootstrap status
config bootstrap plan
config install status
config install plan
```

These must print the target-scoped bootstrap summary only and must not run preflight checks or installers.

Preserve existing no-argument `bootstrap` and `install` behavior.

Focus on `/home/vmuser/.local/bin/config.sh`.

Do not run installers, mounts, package managers, Docker, Kubernetes, SQL tooling, or destructive cleanup commands.

After patching, create:

```bash
/home/vmuser/.local/patches/AN1_04_target_scoped_bootstrap_dispatch_postcheck.log
```

Use the simple evidence-log style described in this brief.
