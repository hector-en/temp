# AN1-05B — Manifest-Based User/System Sync Scope

Codex-only brief. Use the current working tree/context. Do not re-read or re-summarize the whole codebase.

## Goal

Refactor `pull` / `push` sync selection so it is manifest/list based and scope-aware.

Default policy:

```text
TARGET_USER=vmuser:
  sync user items + system items

TARGET_USER!=vmuser:
  sync user items only
```

This keeps `labuser` and other non-admin accounts from syncing system files like:

```text
/etc/netplan
/etc/resolv.conf
```

while preserving `vmuser` as the admin/system-sync target.

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

Do not implement `--include-system` yet. Structure the code so that can be added later.

## Current problem

After AN1-05, this works but is too broad for non-admin targets:

```bash
sudo config --target labuser push
```

It currently exports both user and system files:

```text
/home/labuser/.local/bin              -> /mnt/egress/labuser/bin
/home/labuser/.bashrc                 -> /mnt/egress/labuser/home/.bashrc
/etc/netplan                          -> /mnt/egress/labuser/etc/netplan
/etc/resolv.conf                      -> /mnt/egress/labuser/etc/resolv.conf/resolv.conf
```

For `labuser`, default push/pull should be user-scope only.

## Required design

Introduce sync scope helpers and item lists.

### Policy helpers

```bash
config_sync_is_admin_target() {
  [[ "$TARGET_USER" == "vmuser" ]]
}

config_sync_include_system_items() {
  config_sync_is_admin_target
}
```

### Item format

Use tab-separated item rows.

For push:

```text
kind<TAB>source<TAB>destination
```

For pull:

```text
kind<TAB>source<TAB>destination<TAB>owner_scope
```

Supported `kind`:

```text
tree
file
```

Supported `owner_scope` for pull:

```text
target
root
```

## Required item list helpers

Add helpers near `CopyConfigFiles` / `PushConfigFiles`.

### Push item lists

```bash
config_push_user_items() {
  local egress_root="${1:-/mnt/egress}"
  local target_root="$egress_root/$TARGET_USER"

  printf '%s\t%s\t%s\n' "tree" "${TARGET_HOME}/.local/bin" "$target_root/bin"
  printf '%s\t%s\t%s\n' "file" "${TARGET_HOME}/.bashrc" "$target_root/home/.bashrc"
}

config_push_system_items() {
  local egress_root="${1:-/mnt/egress}"
  local target_root="$egress_root/$TARGET_USER"

  printf '%s\t%s\t%s\n' "tree" "/etc/netplan" "$target_root/etc/netplan"
  printf '%s\t%s\t%s\n' "file" "/etc/resolv.conf" "$target_root/etc/resolv.conf/resolv.conf"
}
```

### Pull item lists

```bash
config_pull_user_items() {
  local distrohome="${1:-${DISTROHOME:-/mnt/distrohome}}"
  local user_root="$distrohome/.configfiles/$TARGET_USER"

  printf '%s\t%s\t%s\t%s\n' "tree" "$user_root/bin" "${TARGET_HOME}/.local/bin" "target"
  printf '%s\t%s\t%s\t%s\n' "file" "$user_root/home/.bashrc" "${TARGET_HOME}/.bashrc" "target"
}

config_pull_system_items() {
  local distrohome="${1:-${DISTROHOME:-/mnt/distrohome}}"
  local user_root="$distrohome/.configfiles/$TARGET_USER"

  printf '%s\t%s\t%s\t%s\n' "tree" "$user_root/etc/netplan" "/etc/netplan" "root"
  printf '%s\t%s\t%s\t%s\n' "file" "$user_root/etc/resolv.conf/resolv.conf" "/etc/resolv.conf" "root"
}
```

## Required executor behavior

Refactor existing `CopyConfigFiles` and `PushConfigFiles` to consume item lists.

Keep existing behavior for copying, chmod, chown, and warnings, but stop hard-coding each file directly in the main body.

### Push execution

`PushConfigFiles` should:

1. Always process `config_push_user_items`.
2. Process `config_push_system_items` only when `config_sync_include_system_items` returns true.
3. Print skipped system scope for non-admin targets:

```text
[INFO] Skipping system sync items for non-admin target: labuser
```

4. Continue using existing `push_tree_contents` and `push_file` style logic.

### Pull execution

`CopyConfigFiles` should:

1. Always process `config_pull_user_items`.
2. Process `config_pull_system_items` only when `config_sync_include_system_items` returns true.
3. Print skipped system scope for non-admin targets:

```text
[INFO] Skipping system sync items for non-admin target: labuser
```

4. For owner scope:
   - `target`: chown to `$TARGET_USER:$(id -gn "$TARGET_USER")`
   - `root`: chown to `root:root`
5. Continue normalizing bin modes for target bin files after user bin pull.

## Required defaults

### For labuser

```bash
sudo config --target labuser push
```

must include only:

```text
/home/labuser/.local/bin -> /mnt/egress/labuser/bin
/home/labuser/.bashrc    -> /mnt/egress/labuser/home/.bashrc
```

and must skip:

```text
/etc/netplan
/etc/resolv.conf
```

with an info line.

```bash
sudo config --target labuser pull
```

must include only:

```text
/mnt/distrohome/.configfiles/labuser/bin          -> /home/labuser/.local/bin
/mnt/distrohome/.configfiles/labuser/home/.bashrc -> /home/labuser/.bashrc
```

and must skip system items.

### For vmuser

```bash
sudo config --target vmuser push
```

must include user + system items:

```text
/home/vmuser/.local/bin -> /mnt/egress/vmuser/bin
/home/vmuser/.bashrc    -> /mnt/egress/vmuser/home/.bashrc
/etc/netplan            -> /mnt/egress/vmuser/etc/netplan
/etc/resolv.conf        -> /mnt/egress/vmuser/etc/resolv.conf/resolv.conf
```

```bash
sudo config --target vmuser pull
```

must include user + system items from:

```text
/mnt/distrohome/.configfiles/vmuser
```

## Extendability rule

After this patch, adding a future sync item must require adding one row to one helper, not editing control flow.

Examples:

```bash
# user item
printf '%s\t%s\t%s\n' "file" "${TARGET_HOME}/.profile" "$target_root/home/.profile"

# system item
printf '%s\t%s\t%s\n' "file" "/etc/wsl.conf" "$target_root/etc/wsl.conf"
```

## Acceptance

- `config_sync_is_admin_target` exists.
- `config_sync_include_system_items` exists.
- `config_push_user_items` exists.
- `config_push_system_items` exists.
- `config_pull_user_items` exists.
- `config_pull_system_items` exists.
- `sudo config --target labuser push` does not sync `/etc/netplan`.
- `sudo config --target labuser push` does not sync `/etc/resolv.conf`.
- `sudo config --target labuser push` prints that system items are skipped for non-admin target.
- `sudo config --target labuser pull` does not apply system items.
- `sudo config --target labuser pull` prints that system items are skipped for non-admin target.
- `sudo config --target vmuser push` still includes system items.
- `sudo config --target vmuser pull` still includes system items.
- Pull ownership for user items remains target-owned.
- Pull ownership for system items remains root-owned when system items are included.
- AN1-05A sudo-only guard remains intact.
- AN1-05 path output remains intact.
- No bootstrap/install/mount/package commands are run.

## Postcheck log

Create:

```bash
/home/vmuser/.local/patches/AN1_05B_manifest_based_sync_scope_postcheck.log
```

Use simple evidence-log style:

```text
AN1-05B manifest-based user/system sync scope postcheck
UTC YYYY-MM-DD HH:MM:SS

[1] Syntax
config.sh syntax exit=0
Result: PASS

[2] Helper presence
config_sync_is_admin_target found: yes
config_sync_include_system_items found: yes
config_push_user_items found: yes
config_push_system_items found: yes
config_pull_user_items found: yes
config_pull_system_items found: yes
Result: PASS

[3] labuser push scope
Command attempted:
sudo config --target labuser push

Observed:
- User item synced: /home/labuser/.local/bin -> /mnt/egress/labuser/bin
- User item synced: /home/labuser/.bashrc -> /mnt/egress/labuser/home/.bashrc
- System items skipped for non-admin target.
- /etc/netplan was not synced for labuser.
- /etc/resolv.conf was not synced for labuser.

Result: PASS or SKIP
Reason if SKIP: missing safe egress fixture/mount

[4] labuser pull scope
Command attempted:
sudo config --target labuser pull

Observed:
- User item considered: /mnt/distrohome/.configfiles/labuser/bin -> /home/labuser/.local/bin
- User item considered: /mnt/distrohome/.configfiles/labuser/home/.bashrc -> /home/labuser/.bashrc
- System items skipped for non-admin target.
- /etc/netplan was not applied for labuser.
- /etc/resolv.conf was not applied for labuser.

Result: PASS or SKIP
Reason if SKIP: missing safe distrohome fixture/mount

[5] vmuser push scope
Command attempted:
sudo config --target vmuser push

Observed:
- User items included.
- System items included.
- /etc/netplan included for vmuser.
- /etc/resolv.conf included for vmuser.

Result: PASS or SKIP
Reason if SKIP: missing safe egress fixture/mount

[6] vmuser pull scope
Command attempted:
sudo config --target vmuser pull

Observed:
- User items included.
- System items included.
- /etc/netplan included for vmuser.
- /etc/resolv.conf included for vmuser.

Result: PASS or SKIP
Reason if SKIP: missing safe distrohome fixture/mount

[7] Sudo-only regression
config --target vmuser push without sudo blocked: yes
config --target labuser push without sudo blocked: yes
Result: PASS

[8] Context regression
sudo config --target labuser status context correct: yes
sudo config --target labuser bootstrap status non-destructive: yes
Result: PASS

Overall
- Sync is manifest/list based.
- User items are default for all targets.
- System items are included only for vmuser by default.
- Non-admin targets no longer push/pull system files.
- No bootstrap/install/mount/package commands were run.
```

## Safe commands

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

config --target vmuser push
config --target labuser push

sudo config --target labuser status
sudo config --target labuser bootstrap status
```

Only run live sudo pull/push if fixture paths are present and safe:

```bash
[[ -d /mnt/egress ]] && sudo config --target labuser push || true
[[ -d /mnt/distrohome/.configfiles/labuser ]] && sudo config --target labuser pull || true
[[ -d /mnt/egress ]] && sudo config --target vmuser push || true
[[ -d /mnt/distrohome/.configfiles/vmuser ]] && sudo config --target vmuser pull || true
```
