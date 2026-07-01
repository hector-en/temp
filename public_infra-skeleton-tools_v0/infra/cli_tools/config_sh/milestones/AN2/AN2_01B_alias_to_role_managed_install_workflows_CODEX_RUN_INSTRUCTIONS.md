# AN2-01B — Alias-to-Managed Role Install Workflow Mapping — Codex Run Instructions

Use this file as the short, cache-stable instruction file for Codex.

Pair it with:

```text
AN2_01B_alias_to_role_managed_install_workflows_SPEC.md
```

Refreshed against the 2026-06-19 current `vmuser` codebase upload.

Prerequisite status:

AN2-02A is implemented enough for AN2-01B:
- python-env-profiles.tsv exists.
- target env files contain PYTHON_ENV* policy.
- ResolveTargetPythonEnv exists in lib/config-sh/installers.sh.
- InstallPythonPackagesIntoTargetEnv exists in lib/config-sh/installers.sh.
- role-specific Python install functions must call InstallPythonPackagesIntoTargetEnv.
- do not reimplement conda/venv discovery in AN2-01B.
- do not parse human-facing lv output.02A Python environment profile policy must be implemented first.
```

## Current status from 2026-06-19 upload:

```text
AN2-02A is complete enough.

AN2-01B is still missing:
- no PIP_ML_BASE_STACK / role PIP stack variables in packages.env.
- no install_ml_base_python_stack.
- no install_pytorch_stack.
- no install_llm_stack.
- no install_api_stack.
- no install_grn_research_python_stack.
- no install_publisher_base_tools.
- config_bootstrap_function_allowed still only allowlists legacy bootstrap functions.
- config_bootstrap_builtin_step_rows and config-init steps_body still only contain legacy bootstrap rows.
- ai_engineer_plan_body="$lab_plan_body"
- research_scientist_plan_body="$lab_plan_body"
- publisher_plan_body="$lab_plan_body"

Therefore proceed with AN2-01B Task 1 only.
```

## Stable context pack

```text
You are working in /home/vmuser/.local.

The old labuser/operator model used:
- bin/conda.sh for conda activation aliases and shell aliases.
- bin/lv.sh for alias/conda/venv discovery, creation, deletion, clone, inspection.
- old labuser bin/env.sh for environment summary checks.
- old labuser bin/lab-env.sh for OpenClaw, Docker, Terraform, Kubernetes alias checks.
- old labuser bin/ml-env.sh for ML, PyTorch, LLM, API, dev tools, GPU, CUDA alias checks.

New architecture:
- trusted implementation belongs in lib/config-sh/installers.sh.
- safe dispatch/allowlist belongs in bin/config.sh.
- step metadata belongs in etc/config-sh/bootstrap/steps.tsv.
- role default intent belongs in etc/config-sh/bootstrap/profiles/*.plan.
- package lists belong in etc/config-sh/install/packages.env.
- Python env policy comes from python-env-profiles.tsv and target PYTHON_ENV variables.
- Python-installing steps must call InstallPythonPackagesIntoTargetEnv from AN2-02A.

Safety:
- Do not run broad bootstrap/install/mount/pull/push.
- Do not read or print credential files.
- Do not put shell code in env/tsv/plan files.
- Do not use eval for config-driven execution.
- Do not use sudo pip.
- Do not rely on whichever shell env is active.
- Make each task small and commit separately.

Output:
Changed files:
Tests run:
Notes:
```

## Tasks

### Task 1 — Add package variables for managed role stacks

```text
Read:
- /home/vmuser/.local/etc/config-sh/install/packages.env
- /home/vmuser/.local/bin/lv.sh for env discovery context only
- old labuser alias intent if available from code summary

Implement only Task 1.

Add package variables only. Do not add installer functions yet.

Add or extend packages.env with safe package-list variables:
- PIP_ML_BASE_STACK
- PIP_PYTORCH_STACK
- PIP_LLM_STACK
- PIP_API_STACK
- PIP_ML_DEV_TOOLS
- PIP_OPENCLAW_BASE
- PIP_OPENCLAW_FULL_STACK
- PIP_RESEARCH_NUMERIC_STACK
- PIP_RESEARCH_OPTIMIZATION_STACK
- PIP_RESEARCH_NOTEBOOK_STACK
- PIP_PUBLISHER_BASE_STACK
- PIP_PUBLISHER_NOTEBOOK_STACK

Suggested values:
PIP_ML_BASE_STACK="numpy pandas matplotlib seaborn scikit-learn"
PIP_PYTORCH_STACK="torch torchvision torchaudio"
PIP_LLM_STACK="transformers accelerate datasets peft bitsandbytes"
PIP_API_STACK="fastapi uvicorn"
PIP_ML_DEV_TOOLS="rich typer ipython jupyter pytest"
PIP_OPENCLAW_BASE="requests"
PIP_OPENCLAW_FULL_STACK="fastapi uvicorn transformers accelerate datasets"
PIP_RESEARCH_NUMERIC_STACK="numpy pandas scipy matplotlib seaborn scikit-learn sympy"
PIP_RESEARCH_OPTIMIZATION_STACK="optuna scikit-optimize deap SALib"
PIP_RESEARCH_NOTEBOOK_STACK="ipython jupyter ipykernel nbconvert"
PIP_PUBLISHER_BASE_STACK="jupyter nbconvert matplotlib pandas"
PIP_PUBLISHER_NOTEBOOK_STACK="jupyterlab notebook nbconvert ipykernel"

Requirements:
- Add comments mapping each variable to old alias intent.
- Do not include private data, tokens, manuscripts, vault paths, or research datasets.
- Update config-init packages_body so new installs get these defaults.
- Do not install anything.
- Run:
  bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
  grep -n 'PIP_ML_BASE_STACK\|PIP_RESEARCH_NUMERIC_STACK\|PIP_PUBLISHER_BASE_STACK' /home/vmuser/.local/etc/config-sh/install/packages.env
  grep -n 'PIP_ML_BASE_STACK\|PIP_RESEARCH_NUMERIC_STACK\|PIP_PUBLISHER_BASE_STACK' /home/vmuser/.local/bin/config.sh
```

### Task 2 — Add AI Engineer managed Python workflow functions

```text
Implement only Task 2.

Add functions to lib/config-sh/installers.sh:
- InstallMLBasePythonStack
- InstallPytorchStack
- InstallLLMStack
- InstallAPIStack
- InstallMLDevTools
- CheckGPUAvailability
- CheckPytorchCuda

Requirements:
- Python package functions use InstallPythonPackagesIntoTargetEnv.
- Check functions do not install unless their name says install.
- CheckPytorchCuda should use resolved target env.
- CheckGPUAvailability can check nvidia-smi at system level and report only.
- Add allowlist mappings in config.sh.
- Add steps.tsv rows:
  install_ml_base_python_stack
  install_pytorch_stack
  install_llm_stack
  install_api_stack
  install_ml_dev_tools
  check_gpu_availability
  check_pytorch_cuda
- Add config-init steps_body rows too.
- Add ai-engineer.plan defaults:
  pending install_ml_base_python_stack
  pending install_pytorch_stack
  pending install_llm_stack
  pending install_api_stack
  pending install_ml_dev_tools
  skipped check_gpu_availability
  skipped check_pytorch_cuda
- Keep other profiles skipped for AI-specific steps unless shared.
- Run syntax checks only.
```

### Task 3 — Add Research Scientist managed workflow functions

```text
Implement only Task 3.

Add functions:
- InstallResearchNumericPythonStack
- InstallResearchOptimizationStack
- InstallResearchNotebookStack
- InstallGRNResearchPythonStack
- InstallParameterSearchTooling

Mapping:
- InstallResearchNumericPythonStack -> PIP_RESEARCH_NUMERIC_STACK
- InstallResearchOptimizationStack -> PIP_RESEARCH_OPTIMIZATION_STACK
- InstallResearchNotebookStack -> PIP_RESEARCH_NOTEBOOK_STACK
- InstallGRNResearchPythonStack should call numeric + optimization + notebook helpers.
- InstallParameterSearchTooling should focus on optimization/search packages.

Add steps.tsv and config-init steps_body:
- install_research_numeric_python_stack
- install_research_optimization_stack
- install_research_notebook_stack
- install_grn_research_python_stack
- install_parameter_search_tooling

Profile defaults:
- research-scientist.plan:
  pending install_research_numeric_python_stack
  pending install_research_optimization_stack
  pending install_research_notebook_stack
  pending install_grn_research_python_stack
  pending install_parameter_search_tooling
- ai-engineer.plan:
  skipped research-specific steps
- publisher.plan:
  skipped research-specific steps

Do not put raw research data, unpublished datasets, manuscript text, or vault paths in config files or logs.
Run syntax checks only.
```

### Task 4 — Add Publisher managed workflow functions

```text
Implement only Task 4.

Add functions:
- InstallPublisherBaseTools
- InstallPublisherNotebookStack
- InstallPandocObsidianTools

Mapping:
- InstallPublisherBaseTools -> PIP_PUBLISHER_BASE_STACK
- InstallPublisherNotebookStack -> PIP_PUBLISHER_NOTEBOOK_STACK
- InstallPandocObsidianTools may install/check safe system packages only if existing apt helper patterns exist; otherwise leave as check/stub with clear TODO.

Add steps.tsv and config-init steps_body:
- install_publisher_base_tools
- install_publisher_notebook_stack
- install_pandoc_obsidian_tools

Profile defaults:
- publisher.plan:
  pending install_publisher_base_tools
  pending install_publisher_notebook_stack
  skipped install_pandoc_obsidian_tools unless system apt behavior is safely implemented
- other profiles:
  skipped publisher-specific steps

Do not include private vault/manuscript paths.
Run syntax checks only.
```

### Task 5 — Add OpenClaw / AI platform helper workflow mapping

```text
Implement only Task 5.

Old alias intent:
- openclaw-check-base-requirements
- openclaw-install-full-stack
- openclaw-run-agent

New managed functions:
- CheckOpenClawBaseRequirements
- InstallOpenClawFullStack
- CheckOpenClawAgentWorkspace

Steps:
- check_openclaw_base_requirements
- install_openclaw_full_stack
- check_openclaw_agent_workspace

Profile defaults:
- ai-engineer.plan:
  skipped check_openclaw_base_requirements
  skipped install_openclaw_full_stack
  skipped check_openclaw_agent_workspace
- other profiles:
  skipped

Rules:
- CheckOpenClawAgentWorkspace should not assume a repo path unless configured.
- If no OPENCLAW_WORKSPACE is set, skip clearly.
- Do not run an agent automatically in bootstrap.
- Do not execute main.py.
- Run syntax checks only.
```

### Task 6 — Add infra check workflow mapping

```text
Implement only Task 6.

Old alias intent:
- docker-list-running-containers
- docker-list-images
- docker-run-test-container
- terraform-check-installation
- kubernetes-check-access

New managed check functions:
- CheckDockerAccess
- CheckTerraformInstallation
- CheckKubernetesAccess

Steps:
- check_docker_access
- check_terraform_installation
- check_kubernetes_access

Profile defaults:
- ai-engineer.plan:
  skipped check_docker_access
  skipped check_terraform_installation
  skipped check_kubernetes_access
- operator.plan:
  skipped or pending depending existing operator convention, prefer skipped if uncertain
- research-scientist.plan and publisher.plan:
  skipped

Rules:
- Check functions must not mutate system state.
- Do not run docker hello-world automatically.
- Do not modify kube context.
- Do not install Docker/Terraform/Kubernetes here; legacy install_docker/install_terraform/install_kubernets already exist.
- Run syntax checks only.
```

### Task 7 — Replace lab-clone role profile templates

```text
Implement only Task 7.

Current code has:
  ai_engineer_plan_body="$lab_plan_body"
  research_scientist_plan_body="$lab_plan_body"
  publisher_plan_body="$lab_plan_body"

Replace these with actual role-managed plan bodies.

Requirements:
- Existing files are not overwritten unless config-init --force.
- ai-engineer plan gets AI Python workflow defaults.
- research-scientist plan gets research workflow defaults.
- publisher plan gets publisher workflow defaults.
- legacy base steps can remain skipped or pending according to role.
- Do not force runtime target bootstrap.plan changes here.
- Explain that existing targets may need plan-init/plan-apply or manual plan migration.
- Run syntax checks only.
```

### Task 8 — Help/docs for alias migration

```text
Implement only Task 8.

Requirements:
- Help should explain:
  old aliases are now managed steps
  Python stacks install into PYTHON_ENV
  use config bootstrap steps/status before running
  run one step at a time
  lv remains an inspection/dashboard helper, not the package install control plane
- Add examples for:
  config --target aiengineer bootstrap step install_ml_base_python_stack
  config --target researchscientist bootstrap step install_grn_research_python_stack
  config --target publisher bootstrap step install_publisher_base_tools
- Run syntax checks only.
```

## Recommended order

```text
Task 1
Task 2
Task 3
Task 4
Task 5
Task 6
Task 7
Task 8
```

Suggested commits:

```bash
git commit -m "chore: add role Python package stack defaults"
git commit -m "feat: add AI engineer managed Python workflow steps"
git commit -m "feat: add research scientist managed workflow steps"
git commit -m "feat: add publisher managed workflow steps"
git commit -m "feat: add OpenClaw managed workflow checks"
git commit -m "feat: add managed infrastructure check steps"
git commit -m "feat: add role-managed bootstrap profile templates"
git commit -m "docs: map legacy aliases to managed role workflows"
```
