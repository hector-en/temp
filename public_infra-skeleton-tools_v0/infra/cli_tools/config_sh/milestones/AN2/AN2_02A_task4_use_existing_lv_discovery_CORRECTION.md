# AN2-02A Task 4 Correction — Use Existing lv Discovery Helpers

## Problem

The previous Task 4 wording treated `lv.sh` mostly as inspiration. That is too conservative.

The current codebase already has:

```text
/home/vmuser/.local/bin/lv.sh
```

and `config.sh` sources `lv.sh` before sourcing `installers.sh`.

Therefore `ResolveTargetPythonEnv` should reuse existing lv environment-discovery helpers where available instead of duplicating discovery logic.

## Required correction

In Task 4 / `ResolveTargetPythonEnv`:

- Use `_lv_find_conda_path "$env_name"` to detect conda envs when available.
- Use `_lv_find_venv_path "$env_name"` to detect venvs when available.
- Use `_lv_workon_home` for the default venv base when available.
- Use `_lv_shortpath` only for display if useful.
- Do not call the formatted dashboard command `lv` and parse its output.
- Do not call `lv conda ENV` or `lv venv ENV` and parse human-readable output.
- Add fallback discovery only if the `_lv_*` helpers are not loaded.

## Architecture boundary

```text
lv.sh:
  discovery, dashboard, manual env inspection

installers.sh:
  managed execution, package installation into resolved target env

config.sh:
  target/session policy, dispatch, allowlist, bootstrap state
```

## Suggested resolver flow

```bash
ResolveTargetPythonEnv() {
  local requested_env="${1:-}"
  local env_name="${requested_env:-${PYTHON_ENV:-${CONFIG_PYTHON_ENV_DEFAULT:-}}}"
  local manager="${PYTHON_ENV_MANAGER:-auto}"
  local conda_path=""
  local venv_path=""

  [[ -n "$env_name" ]] || {
    echo "[ERROR] No target Python env resolved." >&2
    return 1
  }

  case "$manager" in
    auto|conda)
      if declare -F _lv_find_conda_path >/dev/null 2>&1; then
        conda_path="$(_lv_find_conda_path "$env_name" 2>/dev/null || true)"
      else
        conda_path="$(conda env list 2>/dev/null | awk -v n="$env_name" '$1==n{print $NF; exit}')"
      fi
      if [[ -n "$conda_path" ]]; then
        RESOLVED_PYTHON_ENV_KIND="conda"
        RESOLVED_PYTHON_ENV_NAME="$env_name"
        RESOLVED_PYTHON_ENV_PATH="$conda_path"
        RESOLVED_PYTHON_COMMAND=(conda run -n "$env_name" python)
        return 0
      fi
      ;;
  esac

  case "$manager" in
    auto|venv)
      if declare -F _lv_find_venv_path >/dev/null 2>&1; then
        venv_path="$(_lv_find_venv_path "$env_name" 2>/dev/null || true)"
      fi
      if [[ -z "$venv_path" ]]; then
        for candidate in           "$TARGET_HOME/.virtualenvs/$env_name"           "$TARGET_HOME/.local/venvs/$env_name"; do
          [[ -x "$candidate/bin/python" ]] && { venv_path="$candidate"; break; }
        done
      fi
      if [[ -n "$venv_path" && -x "$venv_path/bin/python" ]]; then
        RESOLVED_PYTHON_ENV_KIND="venv"
        RESOLVED_PYTHON_ENV_NAME="$env_name"
        RESOLVED_PYTHON_ENV_PATH="$venv_path"
        RESOLVED_PYTHON_COMMAND=("$venv_path/bin/python")
        return 0
      fi
      ;;
  esac

  echo "[ERROR] Python env not found: $env_name" >&2
  echo "[INFO] lv can inspect available envs: lv conda $env_name or lv venv $env_name" >&2
  return 1
}
```

## Validation

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/lv.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

timeout 10s bash --noprofile --norc -c '. /home/vmuser/.local/bin/config.sh; type _lv_find_conda_path; type _lv_find_venv_path'
```

## Commit

```bash
git commit -m "fix: reuse lv environment discovery in Python env resolver"
```
