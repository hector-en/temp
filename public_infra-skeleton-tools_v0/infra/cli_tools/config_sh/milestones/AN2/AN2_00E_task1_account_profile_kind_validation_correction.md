# AN2-00E Task 1 Correction — Enforce Account Kind and Suggest Valid Profiles

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

If they do not match, fail clearly and show which profiles are valid for the requested command kind.

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
[INFO] Use create-target for target profiles, or choose one of these operator profiles:
  - DefaultOperator
```

This should also fail:

```bash
config --create-target --profile DefaultOperator --name testoperator --dry-run
```

Expected output shape:

```text
[ERROR] Profile kind mismatch.
[ERROR] Command kind: target
[ERROR] Profile DefaultOperator has account_kind=operator
[INFO] Use create-operator for operator profiles, or choose one of these target profiles:
  - DefaultTarget
  - AIEngineer
  - ResearchScientist
  - Publisher
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
- Do not hard-code the profile suggestions if they can be read from `accounts/profiles.tsv`.
- Prefer reading `accounts/profiles.tsv` and listing profiles whose second column `account_kind` matches the requested command kind.
- Do not auto-convert target profiles into operator profiles.
- Do not auto-convert operator profiles into target profiles.
- Fail clearly when command kind and profile kind do not match.
- The error must show:
  - requested command kind
  - selected profile name
  - selected profile account_kind
  - valid profiles for the requested kind
- Apply the validation to both interactive and non-interactive paths.
- In interactive mode, if the operator chooses a profile of the wrong kind, fail with the same clear error and suggestions.
- Keep `--expire-password` behavior unchanged.
- Keep password prompt behavior unchanged.
- Keep target env ownership behavior unchanged.
- Do not touch remove-target/remove-operator tasks.
- Do not touch AN2-01 or AN2-02 work.

## Suggested implementation

Add helper functions such as:

```bash
config_account_profiles_by_kind() {
  local wanted_kind="${1:-}"
  local row name account_kind rest

  [[ -n "$wanted_kind" ]] || return 2

  while IFS= read -r row; do
    IFS=$'\t' read -r name account_kind rest <<< "$row"
    [[ "$account_kind" == "$wanted_kind" ]] || continue
    printf '%s\n' "$name"
  done < <(config_account_profile_rows)
}

config_print_account_profiles_by_kind() {
  local wanted_kind="${1:-}"
  local profile
  local found=0

  while IFS= read -r profile; do
    [[ -n "$profile" ]] || continue
    printf '  - %s\n' "$profile" >&2
    found=1
  done < <(config_account_profiles_by_kind "$wanted_kind")

  (( found )) || printf '  (none found)\n' >&2
}
```

Then add:

```bash
config_validate_account_plan_kind() {
  local expected_kind="${1:-}"
  local actual_kind="${ACCOUNT_PLAN_ACCOUNT_KIND:-}"
  local profile_name="${ACCOUNT_PLAN_PROFILE_NAME:-unknown}"

  if [[ "$actual_kind" != "$expected_kind" ]]; then
    echo "[ERROR] Profile kind mismatch." >&2
    echo "[ERROR] Command kind: $expected_kind" >&2
    echo "[ERROR] Profile $profile_name has account_kind=${actual_kind:-unset}" >&2

    if [[ "$expected_kind" == "operator" ]]; then
      echo "[INFO] Use create-target for target profiles, or choose one of these operator profiles:" >&2
      config_print_account_profiles_by_kind operator
    else
      echo "[INFO] Use create-operator for operator profiles, or choose one of these target profiles:" >&2
      config_print_account_profiles_by_kind target
    fi

    return 1
  fi
}
```

Call it immediately after each successful `config_resolve_account_profile ...` call in `config_run_create_account`.

## Placement guidance

The validation should run after:

```bash
config_resolve_account_profile "$resolved_profile" ...
```

and before:

```bash
config_print_account_plan_summary
config_print_account_plan_actions
config_reconcile_target_env_file ...
config_apply_account_plan ...
```

In interactive mode, there are two resolve calls. Validate after the final resolved profile is selected and profile overrides are applied. It is acceptable to validate after both resolve calls for clearer early failure.

## Validation

Run:

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

Negative test 1:

```bash
config --create-operator --profile AIEngineer --name testengineer --dry-run --expire-password
```

Expected: fails with profile kind mismatch and suggests operator profiles.

Negative test 2:

```bash
config --create-target --profile DefaultOperator --name testoperator --dry-run
```

Expected: fails with profile kind mismatch and suggests target profiles.

Positive tests:

```bash
sudo config --create-operator --profile DefaultOperator --name vmuser --dry-run
sudo config --create-target --profile AIEngineer --name testengineer --dry-run --expire-password
```

Expected: both still dry-run normally.

Profile suggestion check:

```bash
config profiles
```

Confirm the suggested profile names match `accounts/profiles.tsv`.

## Commit message

```bash
git commit -m "fix: reject account profile kind mismatches"
```
