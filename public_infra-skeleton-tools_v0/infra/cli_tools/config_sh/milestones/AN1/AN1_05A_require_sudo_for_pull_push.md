# AN1-05A — Require Sudo for Pull/Push

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Make `pull` and `push` sudo-only admin sync commands.

These must fail before copying anything when run without sudo:

```bash
config --target vmuser pull
config --target vmuser push
config --target labuser pull
config --target labuser push
```

Required form:

```bash
sudo config --target vmuser pull
sudo config --target vmuser push
sudo config --target labuser pull
sudo config --target labuser push
```

## Why

`pull` and `push` can touch privileged/shared paths:

```text
/mnt/distrohome/.configfiles/$TARGET_USER
/mnt/egress/$TARGET_USER
/etc/netplan
/etc/resolv.conf
$TARGET_HOME
```

Non-sudo execution already allowed:

```bash
config -t vmuser push
```

to write to:

```text
/mnt/egress/vmuser
```

That should be blocked.

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

## Required helper

Add near the pull/push helpers:

```bash
config_require_sudo_for_admin_sync() {
  local action="${1:-operation}"

  if [[ "$(id -u)" -ne 0 ]]; then
    echo "[ERROR] config $action requires sudo." >&2
    echo "[INFO] Re-run as: sudo config --target ${TARGET_USER} $action" >&2
    return 1
  fi
}
```

## Required changes

Call the helper at the top of both pull/push runners, before path checks, marker deletion, or copying.

```bash
config_run_pull() {
  config_require_sudo_for_admin_sync pull || return 1

  # existing AN1-05 pull logic follows
}
```

```bash
config_run_push() {
  config_require_sudo_for_admin_sync push || return 1

  # existing AN1-05 push logic follows
}
```

The guard must run after global target parsing has applied `--target`, so the suggested command includes the correct target user.

## Acceptance

- `config --target vmuser push` fails before copying files.
- `config --target vmuser pull` fails before copying files.
- `config --target labuser push` fails before copying files.
- `config --target labuser pull` fails before copying files.
- Error clearly says the command requires sudo.
- Error suggests:
  - `sudo config --target vmuser push`
  - `sudo config --target vmuser pull`
  - `sudo config --target labuser push`
  - `sudo config --target labuser pull`
- Sudo versions still reach the existing AN1-05 path/mount guards.
- AN1-05 path output remains intact for sudo runs.
- No files are copied during non-sudo guard tests.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_05A_require_sudo_for_pull_push_postcheck.log
```

Use simple evidence-log style:

```text
AN1-05A require sudo for pull/push postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_require_sudo_for_admin_sync found: yes
config_run_pull calls sudo guard before copying: yes
config_run_push calls sudo guard before copying: yes
Result: PASS

[3] Non-sudo vmuser push guard
Command attempted:
config --target vmuser push

Observed:
- Command failed before copying files.
- Error said config push requires sudo.
- Error suggested sudo config --target vmuser push.

Result: PASS

[4] Non-sudo vmuser pull guard
Command attempted:
config --target vmuser pull

Observed:
- Command failed before copying files.
- Error said config pull requires sudo.
- Error suggested sudo config --target vmuser pull.

Result: PASS

[5] Non-sudo labuser push guard
Command attempted:
config --target labuser push

Observed:
- Command failed before copying files.
- Error said config push requires sudo.
- Error suggested sudo config --target labuser push.

Result: PASS

[6] Non-sudo labuser pull guard
Command attempted:
config --target labuser pull

Observed:
- Command failed before copying files.
- Error said config pull requires sudo.
- Error suggested sudo config --target labuser pull.

Result: PASS

[7] Sudo path still reaches AN1-05 logic
Command attempted:
sudo config --target labuser push
sudo config --target labuser pull

Observed:
- Sudo commands were not blocked by sudo guard.
- They reached existing AN1-05 path/mount/source guards or safe fixture behavior.
- Path output still showed TARGET_USER and TARGET_HOME.

Result: PASS or SKIP
Reason if SKIP: live sudo pull/push fixture/mount was intentionally not run.

[8] Regression
sudo config --target labuser status context correct: yes
sudo config --target labuser bootstrap status non-destructive: yes
Result: PASS

Overall
- pull/push are sudo-only.
- Non-sudo attempts fail before copying.
- Sudo attempts continue into existing AN1-05 behavior.
- No bootstrap/install/mount/package commands were run.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

config --target vmuser push
config --target vmuser pull
config --target labuser push
config --target labuser pull

sudo config --target labuser status
sudo config --target labuser bootstrap status
```

Only run live sudo pull/push if fixture paths are present and safe:

```bash
[[ -d /mnt/distrohome/.configfiles/labuser && -d /mnt/egress ]] && sudo config --target labuser pull || true
[[ -d /mnt/egress ]] && sudo config --target labuser push || true
```
