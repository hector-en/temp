# AN1-05 — Target-Aware Pull/Push

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Harden target-aware `pull` and `push`:

```bash
sudo config --target labuser pull
sudo config --target labuser push
```

Required paths for `labuser`:

```text
pull source: /mnt/distrohome/.configfiles/labuser
pull target: /home/labuser

push source: /home/labuser
push target: /mnt/egress/labuser
```

Do not allow pull/push to drift to `/root` or `/home/vmuser` when `--target labuser` is selected.

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

## Required helpers

Add small helpers near pull/push code:

```bash
config_print_pull_push_context() {
  local action="${1:-operation}"
  echo "Target ${action} context:"
  printf "  TARGET_USER=%s\n" "$TARGET_USER"
  printf "  TARGET_HOME=%s\n" "$TARGET_HOME"
  printf "  CURRENT_HOME=%s\n" "$CURRENT_HOME"
  printf "  STATE_DIR=%s\n" "$STATE_DIR"
  printf "  WSL_USER=%s\n" "$WSL_USER"
  printf "  SMB_USER=%s\n" "$SMB_USER"
}

config_pull_source_dir() {
  local distrohome="${1:-${DISTROHOME:-/mnt/distrohome}}"
  printf '%s\n' "$distrohome/.configfiles/$TARGET_USER"
}

config_push_destination_dir() {
  local egress_root="${1:-/mnt/egress}"
  printf '%s\n' "$egress_root/$TARGET_USER"
}

config_require_pull_source() {
  local src
  src="$(config_pull_source_dir)"
  [[ -d "$src" ]] || {
    echo "[ERROR] Pull source not found for target $TARGET_USER: $src" >&2
    echo "[INFO] Ensure /mnt/distrohome is mounted and contains .configfiles/$TARGET_USER." >&2
    return 1
  }
}

config_require_push_destination_parent() {
  [[ -d /mnt/egress ]] || {
    echo "[ERROR] Push destination parent is missing: /mnt/egress" >&2
    echo "[INFO] Ensure /mnt/egress is mounted before running push." >&2
    return 1
  }
}
```

## Required changes

### `config_run_pull`

Make it follow this shape:

```bash
config_run_pull() {
  local marker="$STATE_DIR/copy_config_files.done"

  config_runtime_init || return 1
  config_print_pull_push_context "pull"

  echo "Pull paths:"
  printf "  source=%s\n" "$(config_pull_source_dir)"
  printf "  target_home=%s\n" "$TARGET_HOME"

  config_require_pull_source || return 1

  rm -f "$marker"

  mounts_init_session_vars
  config_refresh_session_context

  CopyConfigFiles
}
```

### `config_run_push`

Make it follow this shape:

```bash
config_run_push() {
  config_runtime_init || return 1
  config_print_pull_push_context "push"

  echo "Push paths:"
  printf "  source_home=%s\n" "$TARGET_HOME"
  printf "  destination=%s\n" "$(config_push_destination_dir)"

  config_require_push_destination_parent || return 1

  mounts_init_session_vars
  config_refresh_session_context

  PushConfigFiles
}
```

If `mounts_init_session_vars` is unnecessary or causes drift, remove it only if safe. Otherwise keep it and refresh config context immediately after it.

## Verify existing copy helpers

Ensure these remain target-aware:

```bash
CopyConfigFiles:
  user_root="$distrohome/.configfiles/$TARGET_USER"
  root_home="${TARGET_HOME}"

PushConfigFiles:
  root_home="${TARGET_HOME}"
  target_root="$egress_root/$TARGET_USER"
```

For pull into target home, user-home files must be owned by:

```text
$TARGET_USER:$(id -gn "$TARGET_USER")
```

Do not chown system paths such as `/etc/netplan` or `/etc/resolv.conf` to target user.

## Acceptance

- `sudo config --target labuser pull` prints:
  - `TARGET_USER=labuser`
  - `TARGET_HOME=/home/labuser`
  - `source=/mnt/distrohome/.configfiles/labuser`
  - `target_home=/home/labuser`
- `sudo config --target labuser push` prints:
  - `TARGET_USER=labuser`
  - `TARGET_HOME=/home/labuser`
  - `source_home=/home/labuser`
  - `destination=/mnt/egress/labuser`
- Pull does not target `/root` or `/home/vmuser`.
- Push does not source `/root` or `/home/vmuser`.
- Missing `/mnt/distrohome/.configfiles/labuser` fails clearly.
- Missing `/mnt/egress` fails clearly.
- AN1-02 context still passes.
- AN1-03 state ownership still passes.
- AN1-04 `bootstrap status` still stays non-destructive.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_05_target_pull_push_postcheck.log
```

Use simple evidence-log style:

```text
AN1-05 target-aware pull and push postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_print_pull_push_context found: yes
config_pull_source_dir found: yes
config_push_destination_dir found: yes
config_require_pull_source found: yes
config_require_push_destination_parent found: yes
Result: PASS

[3] Static path check
CopyConfigFiles uses /mnt/distrohome/.configfiles/$TARGET_USER: yes
CopyConfigFiles uses TARGET_HOME: yes
PushConfigFiles uses TARGET_HOME: yes
PushConfigFiles uses /mnt/egress/$TARGET_USER: yes
Result: PASS

[4] Pull path behavior
Command attempted:
sudo config --target labuser pull

Observed:
- TARGET_USER=labuser
- TARGET_HOME=/home/labuser
- source=/mnt/distrohome/.configfiles/labuser
- target_home=/home/labuser
- no /root target
- no /home/vmuser target

Result: PASS or SKIP
Reason if SKIP: missing safe fixture/mount

[5] Push path behavior
Command attempted:
sudo config --target labuser push

Observed:
- TARGET_USER=labuser
- TARGET_HOME=/home/labuser
- source_home=/home/labuser
- destination=/mnt/egress/labuser
- no /root source
- no /home/vmuser source

Result: PASS or SKIP
Reason if SKIP: missing safe fixture/mount

[6] Regression
sudo config --target labuser status context correct: yes
sudo config --target labuser bootstrap status non-destructive: yes
state dir owner remains labuser: yes
Result: PASS

Overall
- Pull/push are target-aware.
- Missing mounts/sources fail clearly.
- No bootstrap/install/mount/package commands were run.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

sudo config --target labuser status
sudo config --target labuser bootstrap status
stat -c '%U:%G %a %n' /home/labuser/.local/state/config-sh
```

Only run live pull/push if fixture paths are present and safe:

```bash
[[ -d /mnt/distrohome/.configfiles/labuser && -d /mnt/egress ]] && sudo config --target labuser pull || true
[[ -d /mnt/egress ]] && sudo config --target labuser push || true
```
