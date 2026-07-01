# Correction 10: Make `run_once` atomic and target-scoped

Source package to paste with this brief: the latest exported VMUser code summary after Correction 09. If your latest export is named `code_full_summary.txt`, paste that file together with this brief.

Backlog position: after Correction 09, before Correction 11

Story Points: 1

Target duration: about 30 minutes

Scope: `config.sh` state-marker handling only

## Paste-this brief for a new chat

You are given the current VMUser Linux/WSL configuration export. Please make a minimal, focused patch for Correction 10 only.

The goal is to make bootstrap state markers safer and more useful in:

```text
/home/vmuser/.local/bin/config.sh
```

The latest expected codebase state already includes these prior corrections:

- `lv.sh` is split out.
- `mounts.sh` exists and the mount workflow is called through `mounts_run`.
- `config.sh` has explicit commands such as `help`, `status`, `mounts`, `bootstrap`, `pull`, and `push`.
- Correction 09 has added `target_sudo`, `run_as_target`, and `run_as_target_shell`.

If the pasted codebase does **not** yet contain `target_sudo` and `run_as_target_shell`, stop and apply Correction 09 first. Do not mix Correction 09 and Correction 10 in one patch.

The current state-marker code is still shaped approximately like this:

```bash
run_once() {
  local name="$1"
  shift
  local marker="$STATE_DIR/$name.done"
  [[ -f "$marker" ]] && return 0
  if "$@"; then
    touch "$marker"
  else
    echo "Step failed: $name" >&2
    return 1
  fi
}

config_runtime_init() {
  mkdir -p "$STATE_DIR"
  umask 077
}

# ...
STATE_DIR="$HOME/.local/state/config-sh"
```

This works for happy-path use, but it has important weaknesses:

1. Markers are scoped to the invoking shell's `$HOME`, not explicitly to `TARGET_HOME`.
2. A concurrent or interrupted run can leave ambiguous state.
3. Failure leaves no structured evidence except terminal output.
4. `config status` lists only `.done` markers, so partial failure and in-progress states are hard to see.
5. Marker writes are simple `touch` operations, with no metadata and no atomic write path.

## Goal

Replace the fragile `run_once` marker handling with a small atomic marker system:

- State directory belongs to `TARGET_HOME`, not whichever `$HOME` invoked the script.
- Successful steps write `.done` markers atomically via a temporary file and `mv`.
- Failed steps write `.failed` metadata but do not block a retry.
- Running steps write `.running` metadata while the command is active.
- Concurrent runs are protected by a simple atomic `mkdir` lock directory.
- `config status` shows done, failed, and running markers.

Keep the patch small. This correction is not intended to split installer steps or redesign bootstrap.

## Do not change in this correction

Do not implement later backlog items here:

- Do not split `InstallDevEnv` into substeps. That is Correction 11.
- Do not add preflight checks. That is Correction 12.
- Do not add download retry helpers. That is Correction 13.
- Do not fix the Kubernetes installer. That is Correction 14.
- Do not change alias creation in `lv.sh`. That is Correction 15.
- Do not normalize `.bashrc` includes. That is Correction 16.
- Do not add a full dry-run system. That is Correction 17.
- Do not add log rotation. That is Correction 18.
- Do not change SMB credentials behavior.
- Do not change mount option parsing.
- Do not edit `conda.sh`, `lv.sh`, `mounts.sh`, or `.bash_aliases` unless a syntax check proves a direct dependency.
- Do not make shell startup run any command, prompt, `sudo`, mount, apt, network, or filesystem write.

## Required implementation

### 1. Make state directory target-scoped

Replace the current fixed state path:

```bash
STATE_DIR="$HOME/.local/state/config-sh"
```

with a target-home based default, while allowing a test override:

```bash
CONFIG_STATE_DIR="${CONFIG_STATE_DIR:-${TARGET_HOME}/.local/state/config-sh}"
STATE_DIR="$CONFIG_STATE_DIR"
export CONFIG_STATE_DIR STATE_DIR
```

Then update `config_runtime_init` so it refreshes `STATE_DIR` from the current `TARGET_HOME` and creates the directory only when an explicit command runs:

```bash
config_state_dir_refresh() {
  CONFIG_STATE_DIR="${CONFIG_STATE_DIR:-${TARGET_HOME}/.local/state/config-sh}"
  STATE_DIR="$CONFIG_STATE_DIR"
  export CONFIG_STATE_DIR STATE_DIR
}

config_runtime_init() {
  config_state_dir_refresh
  umask 077
  mkdir -p -- "$STATE_DIR" || return 1
  chmod 700 "$STATE_DIR" 2>/dev/null || true
}
```

Important: sourcing `config.sh` must still be quiet and must not create the state directory. `config_runtime_init` should be called only from explicit commands such as `status`, `mounts`, `bootstrap`, `pull`, `push`, and from `run_once` as a safety guard.

### 2. Replace `run_once` with atomic marker handling

Replace the current `run_once` implementation with a small robust version.

Use this shape as the target behavior, adapting only if needed for the surrounding file:

```bash
run_once() {
  local name="${1:-}"
  shift || true

  [[ -n "$name" ]] || { echo "[ERROR] run_once requires a step name" >&2; return 2; }
  [[ "$name" =~ ^[A-Za-z0-9_.-]+$ ]] || { echo "[ERROR] Invalid run_once step name: $name" >&2; return 2; }
  (($#)) || { echo "[ERROR] run_once requires a command for step: $name" >&2; return 2; }

  config_runtime_init || return 1

  local marker="$STATE_DIR/$name.done"
  local failed="$STATE_DIR/$name.failed"
  local running="$STATE_DIR/$name.running"
  local lockdir="$STATE_DIR/$name.lock"
  local tmp=""
  local start="" end="" rc=0

  if [[ -f "$marker" ]]; then
    echo "[SKIP] $name already done"
    return 0
  fi

  if ! mkdir -- "$lockdir" 2>/dev/null; then
    echo "[ERROR] Step already running or stale lock exists: $name ($lockdir)" >&2
    echo "[INFO] If no config/bootstrap process is active, remove the stale lock manually." >&2
    return 1
  fi

  start="$(date -Is 2>/dev/null || date)"
  tmp="$(mktemp "$STATE_DIR/.${name}.done.XXXXXX")" || {
    rmdir -- "$lockdir" 2>/dev/null || true
    return 1
  }

  {
    printf 'name=%s\n' "$name"
    printf 'status=running\n'
    printf 'target_user=%s\n' "$TARGET_USER"
    printf 'target_home=%s\n' "$TARGET_HOME"
    printf 'started_at=%s\n' "$start"
    printf 'pid=%s\n' "$$"
  } > "$running"

  rm -f -- "$failed"

  if "$@"; then
    rc=0
    end="$(date -Is 2>/dev/null || date)"
    {
      printf 'name=%s\n' "$name"
      printf 'status=done\n'
      printf 'target_user=%s\n' "$TARGET_USER"
      printf 'target_home=%s\n' "$TARGET_HOME"
      printf 'started_at=%s\n' "$start"
      printf 'finished_at=%s\n' "$end"
      printf 'exit_code=0\n'
    } > "$tmp" && mv -f -- "$tmp" "$marker" || rc=$?

    rm -f -- "$running" "$tmp"
    rmdir -- "$lockdir" 2>/dev/null || true

    if ((rc != 0)); then
      echo "[ERROR] Step succeeded but marker write failed: $name" >&2
      return "$rc"
    fi

    echo "[DONE] $name"
    return 0
  else
    rc=$?
    end="$(date -Is 2>/dev/null || date)"
    {
      printf 'name=%s\n' "$name"
      printf 'status=failed\n'
      printf 'target_user=%s\n' "$TARGET_USER"
      printf 'target_home=%s\n' "$TARGET_HOME"
      printf 'started_at=%s\n' "$start"
      printf 'finished_at=%s\n' "$end"
      printf 'exit_code=%s\n' "$rc"
    } > "$failed" 2>/dev/null || true

    rm -f -- "$running" "$tmp"
    rmdir -- "$lockdir" 2>/dev/null || true

    echo "[FAIL] Step failed: $name (exit $rc)" >&2
    return "$rc"
  fi
}
```

Notes:

- `.failed` markers must not block retries.
- `.running` markers must be removed on normal success or failure.
- `.lock` directories must be removed on normal success or failure.
- If a shell is killed with `SIGKILL`, a stale `.lock` may remain. That is acceptable as long as the error message explains the manual cleanup path.
- Do not write secrets or full command lines into markers. Step name, target user, target home, timestamps, PID, and exit code are enough.

### 3. Update `config_status` to show done, failed, and running state

Modify `config_status` so it calls `config_runtime_init` first and prints the target-scoped state directory.

Add a small helper to list marker types without failing when no markers exist:

```bash
config_status_list_markers() {
  local label="$1" suffix="$2" marker found=0

  echo "$label markers:"
  shopt -s nullglob
  for marker in "$STATE_DIR"/*."$suffix"; do
    printf '  %s\n' "$(basename "$marker")"
    if [[ -s "$marker" ]]; then
      sed 's/^/    /' "$marker" | head -n 8
    fi
    found=1
  done
  shopt -u nullglob

  ((found)) || echo "  (none)"
}
```

Then in `config_status`, replace the old `Done markers:` loop with:

```bash
config_runtime_init || return 1

# existing printf lines can stay here

config_status_list_markers "Done" "done"
config_status_list_markers "Failed" "failed"
config_status_list_markers "Running" "running"
```

Keep the output simple and readable. This is not the full status/dry-run redesign from Correction 17.

### 4. Preserve existing call sites

Leave existing `run_once` call sites intact:

```bash
run_once update_apt UpdateAPT
run_once standard_apps StandardApps
run_once install_networking InstallNetworking
run_once install_dev_env InstallDevEnv
```

If the current codebase also has `run_once ensure_shared_group ...` in the mount path, do not change it unless needed for syntax.

Do not add or remove bootstrap steps in this correction.

## Acceptance criteria

The correction is done when all of the following are true:

- `STATE_DIR` defaults to `${TARGET_HOME}/.local/state/config-sh`, not `$HOME/.local/state/config-sh`.
- `CONFIG_STATE_DIR` can override the state directory for tests.
- Sourcing `config.sh` does not create the state directory.
- `config_runtime_init` creates the state directory with restrictive permissions when an explicit command runs.
- `run_once` validates the step name.
- `run_once` refuses to run without a command.
- `run_once` skips a step when the `.done` marker exists.
- `run_once` writes `.done` markers via a temp file plus `mv`.
- `run_once` writes `.failed` metadata when the wrapped command fails.
- A `.failed` marker does not block a retry.
- `run_once` writes `.running` while the command is active and removes it on normal success/failure.
- Concurrent runs for the same step are blocked by an atomic `.lock` directory.
- `config status` lists done, failed, and running markers.
- No installer step is split or reordered.
- No mount behavior changes.
- No shell startup behavior changes.

## Required checks

Run syntax checks:

```bash
bash -n "$HOME/.local/bin/config.sh"
[[ -f "$HOME/.local/bin/mounts.sh" ]] && bash -n "$HOME/.local/bin/mounts.sh"
[[ -f "$HOME/.local/bin/lv.sh" ]] && bash -n "$HOME/.local/bin/lv.sh"
```

Check source safety:

```bash
before="$(find "$HOME/.local/state" -maxdepth 2 -type d 2>/dev/null | sort)"
bash -lc 'source "$HOME/.local/bin/config.sh" >/tmp/config-source.out 2>/tmp/config-source.err; wc -c /tmp/config-source.out /tmp/config-source.err; cat /tmp/config-source.out; cat /tmp/config-source.err'
after="$(find "$HOME/.local/state" -maxdepth 2 -type d 2>/dev/null | sort)"
printf 'before:\n%s\nafter:\n%s\n' "$before" "$after"
```

Expected result: no prompt, no meaningful output, and no new state directory created merely by sourcing.

Check target-scoped state path:

```bash
bash -lc 'source "$HOME/.local/bin/config.sh"; config_runtime_init; printf "TARGET_HOME=%s\nSTATE_DIR=%s\n" "$TARGET_HOME" "$STATE_DIR"; [[ "$STATE_DIR" == "$TARGET_HOME/.local/state/config-sh" ]]'
```

Check successful `run_once` runs only once:

```bash
tmpstate="$(mktemp -d)"
CONFIG_STATE_DIR="$tmpstate" bash -lc '
  source "$HOME/.local/bin/config.sh"
  fake_success() { echo run >> "$CONFIG_STATE_DIR/count"; return 0; }
  run_once test_success fake_success
  run_once test_success fake_success
  test -f "$CONFIG_STATE_DIR/test_success.done"
  test "$(wc -l < "$CONFIG_STATE_DIR/count")" -eq 1
  find "$CONFIG_STATE_DIR" -maxdepth 1 -type f -o -type d | sort
'
rm -rf "$tmpstate"
```

Check failed `run_once` leaves retryable failure metadata:

```bash
tmpstate="$(mktemp -d)"
CONFIG_STATE_DIR="$tmpstate" bash -lc '
  source "$HOME/.local/bin/config.sh"
  fake_fail() { echo run >> "$CONFIG_STATE_DIR/count"; return 7; }
  set +e
  run_once test_fail fake_fail
  rc=$?
  set -e
  test "$rc" -eq 7
  test ! -f "$CONFIG_STATE_DIR/test_fail.done"
  test -f "$CONFIG_STATE_DIR/test_fail.failed"
  test ! -e "$CONFIG_STATE_DIR/test_fail.running"
  test ! -e "$CONFIG_STATE_DIR/test_fail.lock"
  cat "$CONFIG_STATE_DIR/test_fail.failed"
'
rm -rf "$tmpstate"
```

Check a failure can be retried successfully:

```bash
tmpstate="$(mktemp -d)"
CONFIG_STATE_DIR="$tmpstate" bash -lc '
  source "$HOME/.local/bin/config.sh"
  attempts_file="$CONFIG_STATE_DIR/attempts"
  flaky() {
    n=0
    [[ -f "$attempts_file" ]] && n="$(cat "$attempts_file")"
    n=$((n + 1))
    echo "$n" > "$attempts_file"
    [[ "$n" -ge 2 ]]
  }
  set +e
  run_once test_retry flaky
  first_rc=$?
  set -e
  test "$first_rc" -ne 0
  run_once test_retry flaky
  test -f "$CONFIG_STATE_DIR/test_retry.done"
  test -f "$CONFIG_STATE_DIR/test_retry.failed" || true
  cat "$CONFIG_STATE_DIR/test_retry.done"
'
rm -rf "$tmpstate"
```

Check same-step concurrency is blocked:

```bash
tmpstate="$(mktemp -d)"
CONFIG_STATE_DIR="$tmpstate" bash -lc '
  source "$HOME/.local/bin/config.sh"
  slow_step() { sleep 2; }
  run_once test_lock slow_step &
  pid=$!
  sleep 0.2
  set +e
  run_once test_lock true
  second_rc=$?
  set -e
  wait "$pid"
  test "$second_rc" -ne 0
  test -f "$CONFIG_STATE_DIR/test_lock.done"
'
rm -rf "$tmpstate"
```

Check status output includes all marker categories:

```bash
tmpstate="$(mktemp -d)"
CONFIG_STATE_DIR="$tmpstate" bash -lc '
  source "$HOME/.local/bin/config.sh"
  fake_fail() { return 3; }
  fake_success() { return 0; }
  run_once status_done fake_success
  set +e; run_once status_failed fake_fail; set -e
  config_status
' | tee /tmp/config-status-check.out
grep -q 'Done markers:' /tmp/config-status-check.out
grep -q 'Failed markers:' /tmp/config-status-check.out
grep -q 'Running markers:' /tmp/config-status-check.out
rm -rf "$tmpstate"
```

## Rollback plan

If the patch breaks bootstrap state handling:

1. Restore the previous `run_once`, `config_runtime_init`, `config_status`, and `STATE_DIR` lines from backup or version control.
2. Run:

```bash
bash -n "$HOME/.local/bin/config.sh"
bash "$HOME/.local/bin/config.sh" status
```

3. Inspect state directories before retrying bootstrap:

```bash
find "$HOME/.local/state/config-sh" -maxdepth 1 -type f -o -type d 2>/dev/null | sort
find "$TARGET_HOME/.local/state/config-sh" -maxdepth 1 -type f -o -type d 2>/dev/null | sort
```

4. If a stale lock was created by an interrupted run and no matching process is active, remove only that stale lock directory:

```bash
rm -rf "$TARGET_HOME/.local/state/config-sh/<step-name>.lock"
```

Do not delete `.done` markers unless you intentionally want to rerun that bootstrap step.

## Request for the implementing chat

Please produce a minimal patch for Correction 10 only. Make `run_once` atomic and retry-friendly, move state defaults to `TARGET_HOME`, add test override support through `CONFIG_STATE_DIR`, improve `config status` to show done/failed/running markers, and do not change installer step ordering, mount behavior, credential handling, or shell startup behavior.
