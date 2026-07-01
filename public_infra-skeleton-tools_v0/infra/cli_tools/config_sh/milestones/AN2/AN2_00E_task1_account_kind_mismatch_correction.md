# AN2-00E Task 1 Correction — Enforce Account Kind for create-operator/create-target

## Problem

This dry-run is wrong:

```bash
config --create-operator --profile AIEngineer --name testengineer --dry-run --expire-password
```

Observed output:

```text
You selected AIEngineer:
...
target role: ai-engineer
...
ACCOUNT_KIND="target"
ACCOUNT_PROFILE="AIEngineer"
```

The command path is `--create-operator`, but the selected profile is `AIEngineer`, whose profile kind is `target`.

That means the command name and the profile kind disagree:

```text
command kind: operator
profile kind: target
```

This must not silently produce a target account from the operator command.

## Required correction

Update:

```text
/home/vmuser/.local/bin/config.sh
```

In `config_run_create_account`, after resolving/loading the account profile, validate:

```text
ACCOUNT_PLAN_ACCOUNT_KIND == kind
```

Where:

```text
kind=operator for --create-operator / create-operator
kind=target   for --create-target / create-target
```

## Desired behavior

This should fail:

```bash
config --create-operator --profile AIEngineer --name testengineer --dry-run --expire-password
```

Expected output shape:

```text
[ERROR] Profile kind mismatch.
[ERROR] Command kind: operator
[ERROR] Profile AIEngineer has account_kind=target
[INFO] Use create-target for target profiles, or choose an operator profile such as DefaultOperator.
```

This should still work:

```bash
sudo config --create-operator --profile DefaultOperator --name vmuser --dry-run
```

This should still work:

```bash
sudo config --create-target --profile AIEngineer --name testengineer --dry-run --expire-password
```

## Requirements

- Do not change account profile TSV format.
- Do not auto-convert target profiles into operator profiles.
- Do not auto-convert operator profiles into target profiles.
- Fail clearly when command kind and profile kind do not match.
- Apply the validation to both interactive and non-interactive paths.
- In interactive mode, if the operator chooses a profile of the wrong kind, fail with the same clear error.
- Keep `--expire-password` behavior unchanged.
- Keep password prompt behavior unchanged.
- Keep target env ownership behavior unchanged.
- Do not touch remove-target/remove-operator tasks.
- Do not touch AN2-01 or AN2-02 work.

## Suggested implementation

Add a helper such as:

```bash
config_validate_account_plan_kind() {
  local expected_kind="${1:-}"
  if [[ "${ACCOUNT_PLAN_ACCOUNT_KIND:-}" != "$expected_kind" ]]; then
    echo "[ERROR] Profile kind mismatch." >&2
    echo "[ERROR] Command kind: $expected_kind" >&2
    echo "[ERROR] Profile ${ACCOUNT_PLAN_PROFILE_NAME:-unknown} has account_kind=${ACCOUNT_PLAN_ACCOUNT_KIND:-unset}" >&2
    if [[ "$expected_kind" == "operator" ]]; then
      echo "[INFO] Use create-target for target profiles, or choose an operator profile such as DefaultOperator." >&2
    else
      echo "[INFO] Use create-operator for operator profiles, or choose a target profile such as DefaultTarget, AIEngineer, ResearchScientist, or Publisher." >&2
    fi
    return 1
  fi
}
```

Call it immediately after each successful `config_resolve_account_profile ...` call in `config_run_create_account`.

## Validation

Run:

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

Negative test:

```bash
config --create-operator --profile AIEngineer --name testengineer --dry-run --expire-password
```

Expected: fails with profile kind mismatch.

Positive tests:

```bash
sudo config --create-operator --profile DefaultOperator --name vmuser --dry-run
sudo config --create-target --profile AIEngineer --name testengineer --dry-run --expire-password
```

Expected: both still dry-run normally.

## Commit message

```bash
git commit -m "fix: reject account profile kind mismatches"
```
