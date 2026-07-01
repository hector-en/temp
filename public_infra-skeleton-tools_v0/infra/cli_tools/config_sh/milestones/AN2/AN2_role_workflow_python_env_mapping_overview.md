# Updated AN2 Role Workflow and Python Environment Mapping Overview

Regenerated after uploading:

```text
vmuser_20260616155302_code_analysis_output.txt
```

## Updated assessment

```text
AN1: complete enough
AN2-00D: implemented
AN2-00E: implemented enough for current lifecycle scope
AN2-01: still not implemented
AN2-02: still not implemented
```

## What changed since the previous assessment

AN2-00E is no longer only partially implemented. The current upload shows:
- `--expire-password`
- `remove-target`
- `remove-operator`
- `config_validate_account_plan_kind`
- profile mismatch suggestions

So the account lifecycle work can be treated as done enough for now.

## What is still missing

AN2-02 is still missing:
- no `python-env-profiles.tsv`
- no `PYTHON_ENV*` in target env reconciliation
- no `ResolveTargetPythonEnv`
- no `InstallPythonPackagesIntoTargetEnv`

AN2-01 is still missing:
- no role-specific managed install steps
- no AI/research/publisher package workflow functions
- `ai_engineer_plan_body`, `research_scientist_plan_body`, and `publisher_plan_body` still clone `lab_plan_body`

## Correct order

```text
1. AN2-02A — Python environment profile policy
2. AN2-01B — Alias-to-managed role workflow mapping
```

## Why AN2-02A first

The old labuser model had useful aliases and env helpers, but package installs ran through the currently active shell Python. The new managed system must route package work through an explicit target env policy.

Do not implement role package steps until these exist:

```text
ResolveTargetPythonEnv
InstallPythonPackagesIntoTargetEnv
python-env-profiles.tsv
PYTHON_ENV* target env policy
```

## Immediate Codex prompt

```text
Read AN2_02A_python_environment_profile_policy_CODEX_RUN_INSTRUCTIONS.md and AN2_02A_python_environment_profile_policy_SPEC.md.

Follow the stable context and output rules.

Execute only Task 1.

Do not execute role workflow mapping yet.
Do not add ML/research/publisher install steps yet.
```

## After AN2-02A is done

```text
Read AN2_01B_alias_to_role_managed_install_workflows_CODEX_RUN_INSTRUCTIONS.md and AN2_01B_alias_to_role_managed_install_workflows_SPEC.md.

Follow the stable context and output rules.

Execute only Task 1.

Do not execute package installation.
Do not run broad bootstrap/install/mount/pull/push.
```
