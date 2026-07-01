# AN2-02A — Python Environment Profile Policy SPEC

Regenerated against:

```text
vmuser_20260616155302_code_analysis_output.txt
```

## Purpose

This milestone adds the missing Python environment policy layer before old alias workflows are converted into managed role install steps.

The old model was:

```text
alias/source helper -> current shell -> current python/conda/venv -> ad-hoc install/check
```

The new model must be:

```text
account profile -> target role -> Python env profile -> target env -> trusted installer helper -> explicit env install
```

Core rule:

```text
Functions are global.
Python packages are environment-specific.
```

## Current codebase assessment

This updated codebase now has the account lifecycle pieces from AN2-00E:
- `--expire-password`
- `remove-target`
- `remove-operator`
- `config_validate_account_plan_kind`

But AN2-02 is still missing:
- no `etc/config-sh/install/python-env-profiles.tsv` in the current TOC.
- `config_load_config_files` still loads only global config, mounts, target env, `packages.env`, `versions.env`, and `repos.env`.
- target env generation does not write `PYTHON_ENV*`.
- `config_show` does not display Python env policy.
- no `ResolveTargetPythonEnv`.
- no `InstallPythonPackagesIntoTargetEnv`.

## Non-goals

Do not implement role-specific package workflows here.

Do not add:
- `install_ml_base_python_stack`
- `install_llm_stack`
- `install_api_stack`
- `install_grn_research_python_stack`
- `install_publisher_base_tools`

Those belong to AN2-01B after this substrate exists.

## Source-of-truth file

Create:

```text
/home/vmuser/.local/etc/config-sh/install/python-env-profiles.tsv
```

Columns:

```text
profile_name<TAB>target_role<TAB>python_env<TAB>env_manager<TAB>create_missing<TAB>allow_system<TAB>description
```

Rows:

```text
DefaultOperator	operator	operator	auto	0	0	Operator Python tools
DefaultTarget	target	target	auto	0	0	Generic target Python tools
AIEngineer	ai-engineer	aiengineer	auto	0	0	AI Engineer Python environment
ResearchScientist	research-scientist	researchscientist	auto	0	0	Research Scientist Python environment
Publisher	publisher	publisher	auto	0	0	Publisher Python environment
```

## Config-init integration

`config_init_example_files` currently creates:
- account profiles
- SMB profiles
- mount profiles
- steps manifest
- profile plan templates
- packages.env
- versions.env
- repos.env
- mounts.env

Add:
- `python_env_profiles_file="$install_dir/python-env-profiles.tsv"`
- `python_env_profiles_body=...`
- `config_write_example_config_file "$python_env_profiles_file" "$python_env_profiles_body" "Python environment profile file" "$force"`

Do not overwrite existing file unless `--force`.

## Reader helpers

Add:

```bash
config_python_env_profiles_file()
config_python_env_profile_rows()
config_find_python_env_profile()
config_resolve_python_env_profile_for_account_profile()
config_list_python_env_profiles()
```

Do not `source` the TSV file.

Use existing TSV helper patterns:
- `config_tsv_data_rows`
- `config_find_tsv_row_by_first_column`

## Plan variables

Add account-plan variables:

```bash
ACCOUNT_PLAN_PYTHON_ENV_PROFILE
ACCOUNT_PLAN_PYTHON_ENV
ACCOUNT_PLAN_PYTHON_ENV_MANAGER
ACCOUNT_PLAN_PYTHON_ENV_CREATE_MISSING
ACCOUNT_PLAN_PYTHON_ENV_ALLOW_SYSTEM
```

Clear them in `config_account_plan_clear`.

Set them in `config_resolve_account_profile`.

## Target env reconciliation

Extend `config_account_profile_to_target_env` with:

```bash
PYTHON_ENV_PROFILE="${ACCOUNT_PLAN_PYTHON_ENV_PROFILE}"
PYTHON_ENV="${ACCOUNT_PLAN_PYTHON_ENV}"
PYTHON_ENV_MANAGER="${ACCOUNT_PLAN_PYTHON_ENV_MANAGER}"
PYTHON_ENV_CREATE_MISSING="${ACCOUNT_PLAN_PYTHON_ENV_CREATE_MISSING}"
PYTHON_ENV_ALLOW_SYSTEM="${ACCOUNT_PLAN_PYTHON_ENV_ALLOW_SYSTEM}"
```

Example AIEngineer target env managed block should include:

```bash
PYTHON_ENV_PROFILE="AIEngineer"
PYTHON_ENV="aiengineer"
PYTHON_ENV_MANAGER="auto"
PYTHON_ENV_CREATE_MISSING="0"
PYTHON_ENV_ALLOW_SYSTEM="0"
```

## Loaded-policy cleanup

Extend `config_clear_loaded_policy_vars`:

```bash
unset PYTHON_ENV_PROFILE PYTHON_ENV PYTHON_ENV_MANAGER
unset PYTHON_ENV_CREATE_MISSING PYTHON_ENV_ALLOW_SYSTEM
unset CONFIG_PYTHON_ENV_DEFAULT
```

## config-show

Add file listing:

```text
python env profiles: /home/vmuser/.local/etc/config-sh/install/python-env-profiles.tsv
```

Add effective policy section:

```text
Python environment:
  PYTHON_ENV_PROFILE=AIEngineer
  PYTHON_ENV=aiengineer
  PYTHON_ENV_MANAGER=auto
  PYTHON_ENV_CREATE_MISSING=0
  PYTHON_ENV_ALLOW_SYSTEM=0
```

## Env manager semantics

`env_manager=auto`:

```text
1. detect conda env named PYTHON_ENV
2. detect venv at /home/USER/.virtualenvs/PYTHON_ENV
3. detect venv at /home/USER/.local/venvs/PYTHON_ENV
4. fail/skip clearly
```

`env_manager=conda`:
- only conda.

`env_manager=venv`:
- only venv.

## Resolver helper

Add to `installers.sh`:

```text
ResolveTargetPythonEnv
```

It should resolve:

```text
explicit argument > PYTHON_ENV > CONFIG_PYTHON_ENV_DEFAULT > error
```

It should not use:
- active conda env
- active VIRTUAL_ENV
- system Python

unless explicitly configured.

Expected output shape:

```text
Python environment context:
  target user: aiengineer
  target role: ai-engineer
  target Python env: aiengineer
  env manager: auto
  create missing: 0
  allow system: 0
  resolved mode: conda
  python command: conda run -n aiengineer python
```

## Package helper

Add to `installers.sh`:

```text
InstallPythonPackagesIntoTargetEnv ENV_NAME PACKAGE_VAR LABEL
```

Example future call:

```bash
InstallPythonPackagesIntoTargetEnv "" PIP_ML_BASE_STACK "ML base stack"
```

Rules:
- resolve env first.
- read package var by name.
- empty package var skips.
- run as `TARGET_USER` with `HOME=TARGET_HOME`.
- never use `sudo pip`.
- never install system Python unless `PYTHON_ENV_ALLOW_SYSTEM=1`.
- print env and package var before install.

## Validation

Syntax:

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
```

Config-init:

```bash
config config-init
test -f /home/vmuser/.local/etc/config-sh/install/python-env-profiles.tsv
```

Profile listing:

```bash
config profiles
config help profiles
```

Dry-run target generation:

```bash
sudo config --create-target --profile AIEngineer --name aiengineer --dry-run | grep -E 'PYTHON_ENV|ACCOUNT_PROFILE|TARGET_ROLE'
sudo config --create-target --profile ResearchScientist --name researchscientist --dry-run | grep -E 'PYTHON_ENV|ACCOUNT_PROFILE|TARGET_ROLE'
sudo config --create-target --profile Publisher --name publisher --dry-run | grep -E 'PYTHON_ENV|ACCOUNT_PROFILE|TARGET_ROLE'
```

Config-show:

```bash
config --target aiengineer config-show | grep -E 'PYTHON_ENV|Python environment|TARGET_ROLE|ACCOUNT_PROFILE'
```

## Acceptance criteria

- `python-env-profiles.tsv` exists and is generated by `config config-init`.
- It is read as TSV, not sourced.
- target env reconciliation writes `PYTHON_ENV*`.
- `config profiles` or `config help profiles` exposes Python env profile info.
- `config-show` displays effective Python env policy.
- `installers.sh` has `ResolveTargetPythonEnv`.
- `installers.sh` has `InstallPythonPackagesIntoTargetEnv`.
- no role package workflow steps are added yet.
- no broad bootstrap/install/mount/pull/push is run.
- no credentials are read or printed.
