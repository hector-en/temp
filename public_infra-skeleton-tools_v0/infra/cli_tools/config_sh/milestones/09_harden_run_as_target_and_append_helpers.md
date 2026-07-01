# Correction 09: Harden `run_as_target` and append helpers

Source package to paste with this brief: the latest exported VMUser code summary after Correction 08. If your latest export is named `code_full_summary.txt`, paste that file together with this brief.

Backlog position: after Correction 08, before Correction 10

Story Points: 1

Target duration: about 30 minutes

Scope: helper hardening in `config.sh` only

## Paste-this brief for a new chat

You are given the current VMUser Linux/WSL configuration export. Please make a minimal, focused patch for Correction 09 only.

The goal is to harden the target-user execution helpers in:

```text
/home/vmuser/.local/bin/config.sh
```

The current updated codebase has already separated shell startup, `lv.sh`, and the mount workflow. It still has fragile helper functions in `config.sh` shaped approximately like this:

```bash
run_as_target() {
  sudo -u "${TARGET_USER}" -H env HOME="${TARGET_HOME}" bash -lc "$*"
}

append_once_target() {
  local file="$1" line="$2"
  sudo -u "${TARGET_USER}" -H env HOME="${TARGET_HOME}" bash -lc \
    "grep -qxF '$line' '$file' 2>/dev/null || echo '$line' >> '$file'"
}

append_block_once_target() {
  local file="$1" marker="$2" block="$3"
  sudo -u "${TARGET_USER}" -H env HOME="${TARGET_HOME}" bash -lc \
    "grep -qF '$marker' '$file' 2>/dev/null || cat >> '$file' <<'EOF'
$block
EOF"
}
```

These helpers interpolate user-controlled or file-content strings into shell code. They break on single quotes, can mis-handle `$`, backticks, semicolons, and newlines, and make later installer work harder to reason about.

## Goal

Replace the fragile helper pattern with safer, explicit helpers:

1. A low-level target-user command runner that accepts an argument vector.
2. A clearly named shell-snippet escape hatch for existing complex call sites.
3. Append helpers that pass file paths and content as arguments/stdin, not by interpolating them into `bash -lc` strings.

Keep the patch small. This correction is not intended to rewrite the whole installer.

## Do not change in this correction

Do not implement later backlog items here:

- Do not redesign `run_once` markers. That is Correction 10.
- Do not split `InstallDevEnv` into substeps. That is Correction 11.
- Do not add preflight checks. That is Correction 12.
- Do not add download retry helpers. That is Correction 13.
- Do not fix the Kubernetes installer. That is Correction 14.
- Do not fix `lv.sh` alias quoting or `eval` usage. That is Correction 15.
- Do not change mount credentials behavior from Correction 08.
- Do not edit `.bashrc`, `.bash_aliases`, `conda.sh`, `shell-loader.sh`, `lv.sh`, or `mounts.sh` unless a syntax check proves a direct dependency.
- Do not make shell startup run any command, prompt, `sudo`, mount, apt, network, or filesystem write.

## Required implementation

### 1. Replace the helper block in `config.sh`

Replace the current helper block under this comment:

```bash
# -----------------------------------------------------------------------------
# Helpers for running commands as TARGET_USER
# -----------------------------------------------------------------------------
```

with a safer version like this:

```bash
target_sudo() {
  (($#)) || { echo "[ERROR] target_sudo requires a command" >&2; return 2; }
  sudo -u "${TARGET_USER}" -H env HOME="${TARGET_HOME}" "$@"
}

run_as_target() {
  (($#)) || { echo "[ERROR] run_as_target requires a command" >&2; return 2; }
  target_sudo "$@"
}

run_as_target_shell() {
  local script="${1:-}"
  [[ -n "$script" ]] || { echo "[ERROR] run_as_target_shell requires a script string" >&2; return 2; }
  target_sudo bash -lc "$script"
}

append_once_target() {
  local file="$1" line="$2"

  target_sudo bash -s -- "$file" "$line" <<'BASH'
set -euo pipefail
file="$1"
line="$2"
mkdir -p -- "$(dirname -- "$file")"
touch -- "$file"
grep -qxF -- "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
BASH
}

append_block_once_target() {
  local file="$1" marker="$2" block="$3"

  printf '%s\n' "$block" | target_sudo bash -c '
set -euo pipefail
file="$1"
marker="$2"
block="$(cat)"
mkdir -p -- "$(dirname -- "$file")"
touch -- "$file"
if ! grep -qF -- "$marker" "$file" 2>/dev/null; then
  printf "%s\n" "$block" >> "$file"
fi
' bash "$file" "$marker"
}
```

This keeps `bash -lc` available only through `run_as_target_shell`, where its use is explicit and easy to audit.

### 2. Update existing shell-snippet call sites

After changing `run_as_target` to accept an argument vector, existing string-style uses must be updated.

In `config.sh`, change existing shell-snippet call sites like:

```bash
run_as_target 'command -v dotnet >/dev/null 2>&1'
run_as_target 'dotnet tool install -g Microsoft.dotnet-interactive 2>/dev/null || dotnet tool update -g Microsoft.dotnet-interactive'
run_as_target 'curl -fsSL https://pyenv.run | bash'
run_as_target "wget -O \"\$HOME/${anaconda_installer}\" \"https://repo.anaconda.com/archive/${anaconda_installer}\""
run_as_target 'sqlcmd -?'
```

to:

```bash
run_as_target_shell 'command -v dotnet >/dev/null 2>&1'
run_as_target_shell 'dotnet tool install -g Microsoft.dotnet-interactive 2>/dev/null || dotnet tool update -g Microsoft.dotnet-interactive'
run_as_target_shell 'curl -fsSL https://pyenv.run | bash'
run_as_target_shell "wget -O \"\$HOME/${anaconda_installer}\" \"https://repo.anaconda.com/archive/${anaconda_installer}\""
run_as_target_shell 'sqlcmd -?'
```

Use this rule for the whole file:

- If the call depends on shell features such as `|`, `||`, redirection, `$HOME` expansion inside the target user shell, or complex quoting, use `run_as_target_shell`.
- If the call is a simple command with fixed arguments, it may use `run_as_target`, but do not spend time rewriting every command in this correction.
- Do not leave old string-style calls to `run_as_target`.

### 3. Preserve append helper call sites

Do not change call sites like:

```bash
append_once_target "${TARGET_HOME}/.bashrc" 'export PYENV_ROOT="$HOME/.pyenv"'
append_block_once_target "${TARGET_HOME}/.bashrc" '# >>> pyenv initialize >>>' '...'
```

The point of this correction is that the helper implementation becomes safe while the caller API stays stable.

### 4. Keep source safety

Sourcing `config.sh` must still only define functions and load helper libraries. The new helper functions must not run `sudo`, create files, or append anything until explicitly called.

## Acceptance criteria

The correction is done when all of the following are true:

- `config.sh` contains `target_sudo`, `run_as_target`, and `run_as_target_shell`.
- `run_as_target` no longer uses `bash -lc "$*"`.
- Existing shell-snippet uses of `run_as_target` are renamed to `run_as_target_shell`.
- `append_once_target` no longer interpolates `$file` or `$line` into a `bash -lc` command string.
- `append_block_once_target` no longer interpolates `$file`, `$marker`, or `$block` into a `bash -lc` command string.
- Append helpers handle lines containing spaces, single quotes, `$`, backticks, and semicolons as literal text.
- Append helpers remain idempotent.
- Sourcing `config.sh` remains quiet and side-effect free.
- No mount workflow, credential behavior, or bootstrap step ordering is changed.

## Required checks

Run syntax checks:

```bash
bash -n "$HOME/.local/bin/config.sh"
[[ -f "$HOME/.local/bin/mounts.sh" ]] && bash -n "$HOME/.local/bin/mounts.sh"
[[ -f "$HOME/.local/bin/lv.sh" ]] && bash -n "$HOME/.local/bin/lv.sh"
```

Check source-safety:

```bash
bash -lc 'source "$HOME/.local/bin/config.sh" >/tmp/config-source.out 2>/tmp/config-source.err; wc -c /tmp/config-source.out /tmp/config-source.err; cat /tmp/config-source.out; cat /tmp/config-source.err'
```

Expected result: no prompt and no meaningful output.

Check that old `run_as_target` string-style calls are gone:

```bash
! grep -nE "run_as_target[[:space:]]+['\"]" "$HOME/.local/bin/config.sh"
```

Check that `bash -lc` is centralized:

```bash
grep -n 'bash -lc' "$HOME/.local/bin/config.sh"
```

Expected result: only the `run_as_target_shell` implementation should contain `bash -lc`. If a comment also mentions it, that is fine.

Check that old append interpolation is gone:

```bash
! grep -nE "bash -lc.*grep -qxF|bash -lc.*cat >>" "$HOME/.local/bin/config.sh"
```

Check idempotent single-line append with literal special characters:

```bash
tmpfile="$(mktemp)"
bash -lc 'source "$HOME/.local/bin/config.sh"; TARGET_USER="$(id -un)"; TARGET_HOME="$HOME"; append_once_target "$1" "literal value with spaces, single quote '\'' and literal \$HOME ; echo no-run"; append_once_target "$1" "literal value with spaces, single quote '\'' and literal \$HOME ; echo no-run"' bash "$tmpfile"
cat "$tmpfile"
wc -l "$tmpfile"
rm -f "$tmpfile"
```

Expected result: the line appears once and is not executed.

Check idempotent block append:

```bash
tmpfile="$(mktemp)"
bash -lc 'source "$HOME/.local/bin/config.sh"; TARGET_USER="$(id -un)"; TARGET_HOME="$HOME"; append_block_once_target "$1" "# >>> test marker >>>" "# >>> test marker >>>
echo literal \$HOME no-run
# <<< test marker <<<"; append_block_once_target "$1" "# >>> test marker >>>" "# >>> test marker >>>
echo literal \$HOME no-run
# <<< test marker <<<"' bash "$tmpfile"
cat "$tmpfile"
grep -c '# >>> test marker >>>' "$tmpfile"
rm -f "$tmpfile"
```

Expected result: the marker appears once and the block content is not executed.

If the test environment prompts for `sudo`, stop and do not alter the implementation just to bypass `sudo`. The existing system already uses `sudo` for target-user writes; this correction only makes the command construction safer.

## Rollback plan

If the patch breaks bootstrap behavior:

1. Restore the previous `config.sh` from backup or version control.
2. Re-run:

```bash
bash -n "$HOME/.local/bin/config.sh"
bash "$HOME/.local/bin/config.sh" status
```

3. Re-apply this correction in smaller pieces: first add `run_as_target_shell`, then update call sites, then replace append helpers.

## Request for the implementing chat

Please produce a minimal patch for Correction 09 only. Harden `run_as_target`, add an explicit `run_as_target_shell` escape hatch, rewrite the append helpers to pass data safely as arguments/stdin, update existing shell-snippet call sites, and do not change mount, credentials, bootstrap marker, or installer behavior beyond what is required for this helper hardening.
