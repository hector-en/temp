# AN2 Current Codebase Assessment — 2026-06-16 15:53 upload

Source inspected:

```text
/mnt/data/vmuser_20260616155302_code_analysis_output.txt
```

## Result

```text
AN1: complete enough
AN2-00D: implemented
AN2-00E: implemented enough for current lifecycle scope
AN2-01: still not implemented
AN2-02: still not implemented
```

## Evidence flags from the uploaded code summary

```text
has_python_env_profiles_tsv=False
has_python_env_vars=False
has_resolve_target_python_env=False
has_install_python_packages_into_target_env=False
has_remove_target=True
has_remove_operator=True
has_account_kind_validation=True
has_expire_password=True
has_ml_role_steps=False
ai_engineer_plan_is_lab_clone=True
research_plan_is_lab_clone=True
publisher_plan_is_lab_clone=True
```

## Interpretation

AN2-00E is now materially done:
- remove-target exists.
- remove-operator exists.
- expire-password exists.
- account profile kind validation exists.

AN2-02 is still missing:
- no python-env-profiles.tsv in the TOC.
- no PYTHON_ENV variables in config target env generation.
- no ResolveTargetPythonEnv helper.
- no InstallPythonPackagesIntoTargetEnv helper.

AN2-01 is still missing:
- steps.tsv remains legacy bootstrap steps only.
- no install_ml_base_python_stack / install_llm_stack / install_api_stack.
- no install_grn_research_python_stack.
- no install_publisher_base_tools.
- ai-engineer/research-scientist/publisher plan bodies are still assigned to the conservative lab plan body in config-init.

## Correct order

Do not map old aliases into package-installing role workflows until Python env policy exists.

```text
1. AN2-02A — Python environment profile policy and resolver
2. AN2-01B — Alias-to-managed role workflow mapping
```
