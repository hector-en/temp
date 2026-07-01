# Correction 15: Fix alias creation/update quoting

## Purpose

Make the `lv alias` and environment-alias helpers safe for commands that contain spaces, quotes, `$`, backslashes, pipes, semicolons, or shell metacharacters.

This is a small, focused correction. Do **not** refactor the whole `lv.sh` file and do **not** change the larger bootstrap, mount, or installer workflows.

## Current problem

The current `lv.sh` alias-writing paths build shell alias lines with direct string interpolation. Examples from the current codebase include patterns like:

```bash
alias "$name=$cmd"
printf "alias %s='%s'\n" "$name" "$cmd" >> "$HOME/.local/.bash_aliases"
alias_line="alias ${name}='${cmd}'"
```

These are fragile because an alias command such as any of the following can break the file or change meaning:

```bash
echo "hello world"
python -c 'print("x")'
cd "$HOME/project dir"
grep 'foo|bar' file.txt
```

The goal is to centralize alias-line generation so every alias written to disk is shell-escaped consistently.

## Target files

Primary target:

- `/home/vmuser/.local/bin/lv.sh`

Possible secondary target only if needed:

- `/home/vmuser/.local/.bash_aliases`

Do not modify `config.sh`, `mounts.sh`, or installer functions in this correction unless absolutely required for syntax compatibility.

## Scope

Implement a small helper in `lv.sh` for rendering alias definitions safely.

Recommended helper shape:

```bash
_lv_alias_render_line() {
  local name="$1"
  shift
  local cmd="$*"

  [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]] || {
    echo "Invalid alias name: $name" >&2
    return 2
  }

  printf 'alias %s=%q\n' "$name" "$cmd"
}
```

Then use this helper everywhere `lv.sh` writes alias lines.

At minimum, update:

- `_lv_create_new()` for `kind=alias`
- `_lv_alias_set()`
- `_lv_alias_unset()` only if the matching logic needs to align with the alias-name validator

## Required behavior

After this correction:

1. Alias names must be validated before writing.
2. Alias command bodies must be shell-escaped using a single shared helper.
3. Creating an alias with spaces or quotes in the command must not corrupt `.bash_aliases` or `conda.sh`.
4. Existing simple aliases must remain unchanged in behavior.
5. The correction must not add shell startup output.
6. The correction must not run installers, mounts, `apt`, network commands, or `sudo` during shell startup.

## Suggested implementation details

### 1. Add an alias-name validator

Add this near the existing alias helper functions in `lv.sh`:

```bash
_lv_alias_name_is_valid() {
  [[ "${1:-}" =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]]
}
```

### 2. Add a single alias-rendering helper

```bash
_lv_alias_render_line() {
  local name="${1:-}"
  shift || true
  local cmd="$*"

  if ! _lv_alias_name_is_valid "$name"; then
    echo "Invalid alias name: $name" >&2
    return 2
  fi

  if [[ -z "$cmd" ]]; then
    echo "Alias command is empty for: $name" >&2
    return 2
  fi

  printf 'alias %s=%q\n' "$name" "$cmd"
}
```

### 3. Update `_lv_create_new()` alias branch

Replace direct alias writing with the helper.

Expected behavior:

```bash
alias_line="$(_lv_alias_render_line "$name" "$cmd")" || return 1
alias "$name=$cmd"
printf '%s\n' "$alias_line" >> "$HOME/.local/.bash_aliases"
echo "Created alias: $name"
```

### 4. Update `_lv_alias_set()`

Replace:

```bash
alias_line="alias ${name}='${cmd}'"
```

with:

```bash
alias_line="$(_lv_alias_render_line "$name" "$cmd")" || return 1
```

Keep the surrounding `awk` update logic narrow, but make sure it writes the fully rendered alias line from `alias_line`.

### 5. Keep deletion simple but validated

At the start of alias deletion/update functions, reject invalid names rather than using them in regexes:

```bash
_lv_alias_name_is_valid "$name" || {
  echo "Invalid alias name: $name" >&2
  return 2
}
```

Apply this to functions that use alias names inside `sed`, `awk`, or regex matching.

## Validation commands

Run these checks after patching:

```bash
bash -n ~/.local/bin/lv.sh
bash -n ~/.local/bin/shell-loader.sh
bash -n ~/.local/bin/config.sh
```

Then test alias rendering without permanently editing real aliases:

```bash
source ~/.local/bin/lv.sh
_lv_alias_render_line test_simple 'echo hello'
_lv_alias_render_line test_quotes 'python -c '\''print("hello world")'\'''
_lv_alias_render_line test_path 'cd "$HOME/project dir"'
```

Expected: each command prints exactly one valid alias line and returns exit code `0`.

Optional manual round-trip test:

```bash
tmp_aliases="$(mktemp)"
_lv_alias_render_line test_quotes 'python -c '\''print("hello world")'\''' > "$tmp_aliases"
bash -n "$tmp_aliases"
rm -f "$tmp_aliases"
```

## Definition of Done

This correction is complete when:

- `lv.sh` has one shared alias rendering helper.
- `_lv_create_new()` no longer writes `printf "alias %s='%s'..."` directly.
- `_lv_alias_set()` no longer builds `alias ${name}='${cmd}'` directly.
- Invalid alias names are rejected before they reach `awk`, `sed`, or alias files.
- `bash -n ~/.local/bin/lv.sh` succeeds.
- A command containing spaces and quotes can be rendered as a valid alias line.

## Out of scope

Do not address these in this correction:

- Making `lv` fully non-interactive.
- Refactoring environment cloning.
- Changing Conda or venv install logic.
- Changing `config.sh` bootstrap state markers.
- Adding logging or dry-run support.

