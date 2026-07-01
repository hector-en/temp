# AN1-03 — Make Target State and Markers Target-Owned

Source files to provide with this brief:
- `code_full_summary.txt`
- `AN1_target_user_config_cli_plan.md`
- AN1-01 implementation/postcheck
- AN1-02 implementation/postcheck

## Milestone goal

Ensure all config state created under a target user's home is owned by that target user, even when the operator runs the command through `sudo`.

AN1-02 confirmed that the full target/session context now resolves correctly:

```bash
sudo config --target labuser status
```

resolves to:

```text
TARGET_USER=labuser
TARGET_HOME=/home/labuser
CURRENT_HOME=/home/labuser
BASEDIR=/home/labuser/.local/wsl-mounts
STATE_DIR=/home/labuser/.local/state/config-sh
WSL_USER=labuser
SMB_USER=labuser
```

The next risk is ownership. Because AN1 commands are commonly run with `sudo`, commands like these may create root-owned files under `/home/labuser`:

```bash
sudo config --target labuser status
sudo config --target labuser skip install_dev_env_dotnet_tools
sudo config --target labuser unskip install_dev_env_dotnet_tools
sudo config --target labuser rm install_dev_env_dotnet_tools
sudo config --target labuser bootstrap
```

That is not acceptable for target-user state. State and marker files under `/home/labuser/.local/state/config-sh` should be readable/removable by `labuser` and should not silently become root-owned.

## Desired behavior

After this milestone:

```bash
sudo config --target labuser status
sudo config --target labuser skip install_dev_env_dotnet_tools
```

should leave this path owned by `labuser`:

```text
/home/labuser/.local/state/config-sh
/home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
```

Expected ownership:

```text
labuser:labuser
```

or the primary group returned by:

```bash
id -gn labuser
```

## Scope

Implement AN1-03 only.

In scope:

1. Add target ownership helpers.
2. Ensure `config_runtime_init` creates `STATE_DIR` with target ownership.
3. Ensure marker files created by:
   - `run_once`
   - `config_skip_step`
   - failed-step handling
   - running-step handling
   - log files
   are owned by the target user.
4. Ensure marker cleanup commands still work under `sudo`.
5. Ensure status remains non-destructive and does not create root-owned target state.
6. Preserve AN1-01 and AN1-02 behavior.
7. Add a simple postcheck log.

Out of scope:

- Do not rewrite bootstrap/install steps.
- Do not run package installs.
- Do not run mounts.
- Do not run Docker, Kubernetes, SQL tooling, or destructive package cleanup.
- Do not chown the entire target home.
- Do not chown unrelated files under `/home/labuser`.
- Do not change system package install ownership.
- Do not change config wrappers unless they are broken.

## Required architecture

State paths under `TARGET_HOME` must be treated as target-user data.

This means:

```text
STATE_DIR=/home/labuser/.local/state/config-sh
```

must be created as:

```text
owner=labuser
group=$(id -gn labuser)
mode=700
```

Marker files under it should also be owned by the target user. Examples:

```text
*.done
*.failed
*.running
*.skipped
*.last.log
```

Locks may be directories, but they must also be cleaned up correctly and not leave root-owned stale artifacts where avoidable.

## Required helper functions

Add these helpers to `config.sh` near the state/runtime helpers.

### 1. Target group resolver

```bash
config_target_group() {
  id -gn "$TARGET_USER" 2>/dev/null
}
```

### 2. Target ownership applier

```bash
config_chown_target_path() {
  local path="${1:-}"
  local group=""

  [[ -n "$path" ]] || return 2
  [[ -e "$path" ]] || return 0

  group="$(config_target_group)" || return 1
  chown -R "${TARGET_USER}:${group}" "$path" 2>/dev/null || sudo chown -R "${TARGET_USER}:${group}" "$path"
}
```

Use `sudo chown` only where needed. Since most target flows are run with `sudo`, direct `chown` may already be enough.

### 3. Target-owned directory creation

```bash
config_ensure_target_dir() {
  local dir="${1:-}"
  local group=""

  [[ -n "$dir" ]] || return 2

  group="$(config_target_group)" || return 1

  install -d -m 700 -o "$TARGET_USER" -g "$group" "$dir" 2>/dev/null || {
    mkdir -p -- "$dir" || return 1
    chmod 700 "$dir" 2>/dev/null || true
    chown "$TARGET_USER:$group" "$dir" 2>/dev/null || sudo chown "$TARGET_USER:$group" "$dir"
  }
}
```

### 4. Atomic file ownership helper

For files written via temp file then moved into place, add a helper that can be called after the final file exists:

```bash
config_chown_target_file() {
  local file="${1:-}"
  local group=""

  [[ -n "$file" ]] || return 2
  [[ -e "$file" ]] || return 0

  group="$(config_target_group)" || return 1
  chown "$TARGET_USER:$group" "$file" 2>/dev/null || sudo chown "$TARGET_USER:$group" "$file"
  chmod 600 "$file" 2>/dev/null || true
}
```

For directories such as lock directories:

```bash
config_chown_target_dir() {
  local dir="${1:-}"
  local group=""

  [[ -n "$dir" ]] || return 2
  [[ -d "$dir" ]] || return 0

  group="$(config_target_group)" || return 1
  chown "$TARGET_USER:$group" "$dir" 2>/dev/null || sudo chown "$TARGET_USER:$group" "$dir"
  chmod 700 "$dir" 2>/dev/null || true
}
```

## Required changes

### 1. Update `config_runtime_init`

Current shape is likely:

```bash
config_runtime_init() {
  config_state_dir_refresh
  umask 077
  mkdir -p -- "$STATE_DIR" || return 1
  chmod 700 "$STATE_DIR" 2>/dev/null || true
}
```

Change it so it creates target-owned state:

```bash
config_runtime_init() {
  config_state_dir_refresh
  umask 077
  config_ensure_target_dir "$STATE_DIR" || return 1
}
```

Do not allow `sudo config --target labuser status` to create `/home/labuser/.local/state/config-sh` as `root:root`.

### 2. Update `config_skip_step`

Current skip marker writes directly with shell redirection. Ensure the marker is chowned afterward:

```bash
config_skip_step() {
  ...
  config_runtime_init || return 1
  cat >"$path" <<EOF
...
EOF
  config_chown_target_file "$path" || return 1
  ...
}
```

Also ensure cleanup of `.running` and `.failed` works under sudo.

### 3. Update `run_once`

In `run_once`, ensure these are target-owned:

- `lockdir`
- `running`
- `failed`
- `marker`
- `step_log`
- temp files before/after move where relevant

Recommended minimal approach:

- After creating `lockdir`, call `config_chown_target_dir "$lockdir"`.
- After writing `running`, call `config_chown_target_file "$running"`.
- After creating/truncating `step_log`, call `config_chown_target_file "$step_log"`.
- After moving temp marker to `.done`, call `config_chown_target_file "$marker"`.
- After writing `.failed`, call `config_chown_target_file "$failed"`.

Do not break atomic marker semantics introduced earlier.

### 4. Update marker cleanup

`config_rm_marker`, `config_unskip_step`, and cleanup paths should continue to work under `sudo`.

No requirement that non-root `labuser` can remove markers created by admin, but markers should be owned by `labuser` after creation.

### 5. Keep `status` safe

`status` calls `config_runtime_init`. That means status may create the state directory. That is okay only if it creates it target-owned.

## Acceptance criteria

AN1-03 is complete when all of these are true:

- `config_ensure_target_dir` exists.
- `config_chown_target_file` exists.
- `config_runtime_init` uses target-owned directory creation.
- `sudo config --target labuser status` leaves `STATE_DIR` owned by `labuser`.
- `sudo config --target labuser skip install_dev_env_dotnet_tools` leaves the `.skipped` marker owned by `labuser`.
- `sudo config --target labuser unskip install_dev_env_dotnet_tools` removes the marker successfully.
- `sudo config --target labuser status` still reports correct AN1-02 target/session context.
- `config --target vmuser status` still works.
- No package installs, mounts, Docker, Kubernetes, SQL tools, or destructive package cleanup commands are run during validation.

## Required validation post log

After implementing the patch, create a simple postcheck log at:

```bash
/home/vmuser/.local/patches/AN1_03_target_owned_state_and_markers_postcheck.log
```

Use plain evidence-log style. The log should be readable without re-running the commands.

Use this pattern:

```text
AN1-03 target-owned state and markers postcheck
UTC YYYY-MM-DD HH:MM:SS

Validation after applying patch

[1] Syntax checks
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_ensure_target_dir found: yes
config_chown_target_file found: yes
config_runtime_init uses config_ensure_target_dir: yes
Result: PASS

[3] labuser state directory ownership
Command attempted:
sudo config --target labuser status

Observed behavior:
- STATE_DIR=/home/labuser/.local/state/config-sh
- STATE_DIR owner=<observed owner>
- STATE_DIR group=<observed group>
- Expected owner=labuser
- Expected group=$(id -gn labuser)

Result: PASS

[4] skip marker ownership
Command attempted:
sudo config --target labuser skip install_dev_env_dotnet_tools

Observed behavior:
- Marker path=/home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
- Marker owner=<observed owner>
- Marker group=<observed group>
- Expected owner=labuser
- Expected group=$(id -gn labuser)

Result: PASS

[5] unskip cleanup
Command attempted:
sudo config --target labuser unskip install_dev_env_dotnet_tools

Observed behavior:
- Skipped marker was removed.
- Command exited successfully.

Result: PASS

[6] AN1-02 regression check
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

[7] vmuser regression check
Command attempted:
config --target vmuser status

Observed behavior:
- TARGET_USER=vmuser
- TARGET_HOME=/home/vmuser
- STATE_DIR=/home/vmuser/.local/state/config-sh
- SMB_USER=hector

Result: PASS

Overall
- Target state directory is target-owned.
- Marker files created by sudo target commands are target-owned.
- AN1-01 and AN1-02 behavior remains intact.
- No package installs, mounts, or destructive actions were run.
```

If `labuser` does not exist, mark labuser-specific checks as `Result: SKIP` and explain why. Do not invent successful results.

## Suggested non-destructive checks

Use these or equivalent commands. Keep the final postcheck log simple and human-readable.

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

grep -q 'config_ensure_target_dir' /home/vmuser/.local/bin/config.sh
grep -q 'config_chown_target_file' /home/vmuser/.local/bin/config.sh
grep -q 'config_ensure_target_dir "$STATE_DIR"' /home/vmuser/.local/bin/config.sh

if getent passwd labuser >/dev/null 2>&1; then
  expected_group="$(id -gn labuser)"

  sudo config --target labuser status

  stat -c '%U:%G %a %n' /home/labuser/.local/state/config-sh
  test "$(stat -c '%U' /home/labuser/.local/state/config-sh)" = "labuser"
  test "$(stat -c '%G' /home/labuser/.local/state/config-sh)" = "$expected_group"

  sudo config --target labuser skip install_dev_env_dotnet_tools

  marker=/home/labuser/.local/state/config-sh/install_dev_env_dotnet_tools.skipped
  test -f "$marker"
  stat -c '%U:%G %a %n' "$marker"
  test "$(stat -c '%U' "$marker")" = "labuser"
  test "$(stat -c '%G' "$marker")" = "$expected_group"

  sudo config --target labuser unskip install_dev_env_dotnet_tools
  test ! -e "$marker"

  sudo config --target labuser status
else
  echo '[SKIP] labuser does not exist'
fi

config --target vmuser status
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

Implement only AN1-03.

The goal is to make config state and marker files target-owned when commands are run through `sudo config --target USER ...`.

Focus on `/home/vmuser/.local/bin/config.sh`.

Do not run installers, mounts, package managers, Docker, Kubernetes, SQL tooling, or destructive package cleanup commands.

After patching, create:

```bash
/home/vmuser/.local/patches/AN1_03_target_owned_state_and_markers_postcheck.log
```

Use the simple evidence-log style described in this brief.
