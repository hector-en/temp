# AN2-02A — Python Environment Profile Policy — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
AN2_02A_python_environment_profile_policy_SPEC.md
```

This file is regenerated against the 2026-06-16 15:53 current `vmuser` codebase upload.

## Current status from uploaded codebase

```text
AN2-00E lifecycle work is now implemented enough:
- --expire-password is present.
- remove-target is present.
- remove-operator is present.
- account profile kind validation is present.

AN2-02 is still missing:
- no python-env-profiles.tsv in current TOC.
- no PYTHON_ENV* target env policy reconciliation.
- no ResolveTargetPythonEnv helper.
- no InstallPythonPackagesIntoTargetEnv helper.

AN2-01 role workflow mapping is still blocked until AN2-02A exists:
- role-specific Python install steps are not present.
- ai-engineer/research-scientist/publisher config-init plans still clone lab_plan_body.
```

## Stable context pack

```text
You are working in /home/vmuser/.local.

Current architecture:
- bin/config.sh is the CLI/state/account/profile/target/bootstrap engine.
- lib/config-sh/installers.sh contains trusted executable installer functions.
- etc/config-sh contains editable policy and manifests.
- etc/config-sh/accounts/profiles.tsv maps account profiles to roles/bootstrap profiles.
- etc/config-sh/accounts/smb-profiles.tsv maps SMB identities.
- etc/config-sh/accounts/mount-profiles.tsv maps mount policy.
- etc/config-sh/targets/USER.env is generated/reconciled target policy.
- etc/config-sh/bootstrap/steps.tsv is the trusted step registry.
- etc/config-sh/bootstrap/profiles/*.plan are role bootstrap profile templates.
- /home/USER/.local/state/config-sh/bootstrap.plan is the runtime target plan.
- bin/lv.sh is a source-safe helper/dashboard for aliases, conda envs, and venvs.

Legacy labuser/operator model to preserve:
- aliases and lv helpers let the user inspect alias/conda/venv state.
- old ML aliases installed/check packages in whichever Python was active.
- the managed system must not rely on whichever env is active.

Goal:
- Add profile-aligned Python environment policy.
- Reconcile that policy into target env files.
- Add safe env resolver and package-install helper for future role workflows.
- Do not add role-specific ML/research/publisher workflow steps in this milestone.

Safety:
- Do not print passwords or credential files.
- Do not read SMB credential contents.
- Do not run broad bootstrap/install/mount/pull/push.
- Do not use sudo pip.
- Do not silently fall back to system Python.
- Do not rely on current conda activation or current VIRTUAL_ENV.
- Preserve existing behavior unless explicitly changed.

Output rules:
- At the end, summarize changed files and tests run.
- Do not paste full source files.
- Use exact validation commands.
```

## Tasks

### Task 1 — Add python-env-profiles.tsv source of truth

```text
Read:
- /home/vmuser/.local/bin/config.sh
- /home/vmuser/.local/etc/config-sh/accounts/profiles.tsv if present
- /home/vmuser/.local/etc/config-sh/install/packages.env if present

Implement only Task 1.

Requirements:
- Create/generate:
  /home/vmuser/.local/etc/config-sh/install/python-env-profiles.tsv
- Add config-init generation for this file.
- Add it to config-show file listing.
- Use columns:
  profile_name
  target_role
  python_env
  env_manager
  create_missing
  allow_system
  description
- Add rows:
  DefaultOperator     operator            operator           auto  0  0  Operator Python tools
  DefaultTarget       target              target             auto  0  0  Generic target Python tools
  AIEngineer          ai-engineer         aiengineer         auto  0  0  AI Engineer Python environment
  ResearchScientist   research-scientist  researchscientist  auto  0  0  Research Scientist Python environment
  Publisher           publisher           publisher          auto  0  0  Publisher Python environment
- Include comments explaining:
  Functions are global, Python packages are env-specific.
  Do not rely on whichever shell env is active.
  create_missing=0 means the env must exist before package installs.
  allow_system=0 means do not install into system Python.
- Do not change installer behavior yet.
- Do not add package install steps yet.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

### Task 2 — Add Python env profile readers

```text
Read:
- /home/vmuser/.local/bin/config.sh
- /home/vmuser/.local/etc/config-sh/install/python-env-profiles.tsv

Implement only Task 2.

Requirements:
- Add path helper:
  config_python_env_profiles_file
- Add row helper:
  config_python_env_profile_rows
- Add find helper:
  config_find_python_env_profile
- Add resolver:
  config_resolve_python_env_profile_for_account_profile
- Resolve by ACCOUNT_PROFILE first, then TARGET_ROLE if needed.
- Parse exactly:
  profile_name target_role python_env env_manager create_missing allow_system description
- Validate rows; fail clearly on bad column count.
- Add profile listing:
  config profiles should show Python env profiles or a compact Python env section.
  config help profiles should mention the file.
- Do not install packages.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

### Task 3 — Reconcile Python env policy into target env files

```text
Read:
- /home/vmuser/.local/bin/config.sh
- config_account_profile_to_target_env
- config_reconcile_target_env_file
- config_clear_loaded_policy_vars
- config_show

Implement only Task 3.

Requirements:
- When create-target/create-operator reconciles targets/USER.env, include:
  PYTHON_ENV_PROFILE="PROFILE"
  PYTHON_ENV="ENV_NAME"
  PYTHON_ENV_MANAGER="auto|conda|venv"
  PYTHON_ENV_CREATE_MISSING="0|1"
  PYTHON_ENV_ALLOW_SYSTEM="0|1"
- Values come from python-env-profiles.tsv.
- For AIEngineer, target env should get:
  PYTHON_ENV_PROFILE="AIEngineer"
  PYTHON_ENV="aiengineer"
  PYTHON_ENV_MANAGER="auto"
  PYTHON_ENV_CREATE_MISSING="0"
  PYTHON_ENV_ALLOW_SYSTEM="0"
- config_clear_loaded_policy_vars must unset PYTHON_ENV* variables.
- config-show must display effective Python env policy.
- Preserve existing target env ownership:
  owner/group derived from config target storage
  file mode 600
  directory mode 700
- Preserve managed block strip/rewrite behavior.
- Do not install packages.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
- Dry-run:
  sudo config --create-target --profile AIEngineer --name aiengineer --dry-run
  sudo config --create-target --profile ResearchScientist --name researchscientist --dry-run
  sudo config --create-target --profile Publisher --name publisher --dry-run
```

### Task 4 — Add ResolveTargetPythonEnv helper in installers.sh

```text
Read:
- /home/vmuser/.local/lib/config-sh/installers.sh
- /home/vmuser/.local/bin/config.sh
- /home/vmuser/.local/bin/lv.sh only for env discovery inspiration; do not depend on sourcing lv internals.

Implement only Task 4.

Requirements:
- Add a reusable helper in installers.sh:
  ResolveTargetPythonEnv
- Inputs:
  optional explicit env name
- Resolution order:
  1. explicit function argument
  2. PYTHON_ENV
  3. CONFIG_PYTHON_ENV_DEFAULT if present
  4. fail clearly
- It must print/log:
  target user
  target role
  target Python env
  env manager
  create_missing
  allow system
- It must not silently use currently active shell env.
- It must not use system Python unless PYTHON_ENV_ALLOW_SYSTEM=1.
- It must detect likely conda envs and venv paths.
- For conda:
  prefer conda run -n ENV python ...
- For venv:
  prefer /home/USER/.virtualenvs/ENV/bin/python or /home/USER/.local/venvs/ENV/bin/python.
- If env is missing and PYTHON_ENV_CREATE_MISSING=0, fail or skip clearly.
- If env is missing and PYTHON_ENV_CREATE_MISSING=1, create only the env, not package stacks.
- Do not install role package stacks here.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

### Task 5 — Add safe Python package install helper

```text
Read:
- /home/vmuser/.local/lib/config-sh/installers.sh
- package/default env conventions in packages.env

Implement only Task 5.

Requirements:
- Add helper:
  InstallPythonPackagesIntoTargetEnv
- It accepts:
  env name or empty to resolve
  package variable name, e.g. PIP_ML_BASE_STACK
  optional label
- It resolves env via ResolveTargetPythonEnv.
- It installs as TARGET_USER with HOME=TARGET_HOME.
- It must not use sudo pip.
- It must not install into system Python unless PYTHON_ENV_ALLOW_SYSTEM=1.
- It must print the resolved env and package variable name.
- Empty package variable should skip cleanly.
- Do not add role-specific workflow steps yet.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
```

## Recommended order

```text
Task 1
Task 2
Task 3
Task 4
Task 5
```

Commit after each task.

Suggested commit messages:

```bash
git commit -m "feat: add Python environment profile policy"
git commit -m "feat: read Python environment profiles"
git commit -m "feat: reconcile Python env policy into targets"
git commit -m "feat: resolve target Python environments"
git commit -m "feat: add safe target Python package installer"
```
