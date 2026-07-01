# AN2-01B — Alias-to-Managed Role Install Workflow Mapping SPEC

Regenerated against:

```text
vmuser_20260619201628_code_analysis_output.txt
```

## Purpose

Map the old alias-based `labuser` workflow and current `lv`/conda helper model into managed role-specific install workflows.

Old control plane:

```text
alias/source helper -> current shell -> current python/conda/venv -> ad-hoc install/check
```

New control plane:

```text
role profile -> bootstrap plan -> trusted step -> trusted function -> explicit target Python env
```

## Current codebase assessment

This upload shows:
- AN2-00E lifecycle/account correction work is now present.
- role-specific Python workflow steps are not present.
- `config_bootstrap_function_allowed` still allowlists only legacy functions.
- `config_bootstrap_builtin_step_rows` and config-init `steps_body` are legacy step lists.
- `ai_engineer_plan_body="$lab_plan_body"`.
- `research_scientist_plan_body="$lab_plan_body"`.
- `publisher_plan_body="$lab_plan_body"`.

Therefore AN2-01 remains not implemented.

## Prerequisite status

AN2-02A is now implemented enough.

Required helpers are available in lib/config-sh/installers.sh:

ResolveTargetPythonEnv
InstallPythonPackagesIntoTargetEnv

AN2-01B role-specific Python package functions must use InstallPythonPackagesIntoTargetEnv and must not perform their own conda/venv discovery.

## Old alias/helper intent to map

### From old ML helper intent

| Old intent | New step | New function | Profile |
|---|---|---|---|
| machine-learning-install-base | install_ml_base_python_stack | InstallMLBasePythonStack | ai-engineer |
| machine-learning-install-pytorch | install_pytorch_stack | InstallPytorchStack | ai-engineer |
| machine-learning-install-llm-stack | install_llm_stack | InstallLLMStack | ai-engineer |
| machine-learning-install-api-stack | install_api_stack | InstallAPIStack | ai-engineer |
| machine-learning-install-dev-tools | install_ml_dev_tools | InstallMLDevTools | ai-engineer |
| runtime-check-gpu-availability | check_gpu_availability | CheckGPUAvailability | ai-engineer |
| runtime-check-pytorch-cuda | check_pytorch_cuda | CheckPytorchCuda | ai-engineer |

### From old lab/OpenClaw/infra helper intent

| Old intent | New step | New function | Profile |
|---|---|---|---|
| openclaw-check-base-requirements | check_openclaw_base_requirements | CheckOpenClawBaseRequirements | ai-engineer |
| openclaw-install-full-stack | install_openclaw_full_stack | InstallOpenClawFullStack | ai-engineer |
| openclaw-run-agent | check_openclaw_agent_workspace | CheckOpenClawAgentWorkspace | ai-engineer |
| docker-list-running-containers/images | check_docker_access | CheckDockerAccess | ai-engineer/operator |
| terraform-check-installation | check_terraform_installation | CheckTerraformInstallation | ai-engineer/operator |
| kubernetes-check-access | check_kubernetes_access | CheckKubernetesAccess | ai-engineer/operator |

### From current lv helper model

`bin/lv.sh` should remain an interactive/dashboard helper for:
- listing aliases
- inspecting conda envs
- inspecting venvs
- creating/deleting/cloning envs manually

Do not turn `lv` into the managed install backend. Managed installers should have their own resolver/helpers in `installers.sh`.

## Research Scientist workflow map

Research Scientist is not just AIEngineer without Docker. It needs scientific computing, notebook, and parameter-search tooling.

| Intended workflow | New step | New function | Package var |
|---|---|---|---|
| numerics/scientific Python | install_research_numeric_python_stack | InstallResearchNumericPythonStack | PIP_RESEARCH_NUMERIC_STACK |
| optimization/search | install_research_optimization_stack | InstallResearchOptimizationStack | PIP_RESEARCH_OPTIMIZATION_STACK |
| notebooks/reproducibility | install_research_notebook_stack | InstallResearchNotebookStack | PIP_RESEARCH_NOTEBOOK_STACK |
| GRN/Turing workflow | install_grn_research_python_stack | InstallGRNResearchPythonStack | combined helpers |
| parameter search | install_parameter_search_tooling | InstallParameterSearchTooling | optimization stack |

Suggested package defaults:

```bash
PIP_RESEARCH_NUMERIC_STACK="numpy pandas scipy matplotlib seaborn scikit-learn sympy"
PIP_RESEARCH_OPTIMIZATION_STACK="optuna scikit-optimize deap SALib"
PIP_RESEARCH_NOTEBOOK_STACK="ipython jupyter ipykernel nbconvert"
```

Do not include:
- raw datasets
- private paths
- manuscript text
- vault paths
- API keys

## Publisher workflow map

Publisher should focus on notebook/export/publishing tooling.

| Intended workflow | New step | New function | Package var |
|---|---|---|---|
| base publishing Python | install_publisher_base_tools | InstallPublisherBaseTools | PIP_PUBLISHER_BASE_STACK |
| notebook/export stack | install_publisher_notebook_stack | InstallPublisherNotebookStack | PIP_PUBLISHER_NOTEBOOK_STACK |
| Pandoc/Obsidian support | install_pandoc_obsidian_tools | InstallPandocObsidianTools | apt/check/stub |

Suggested packages:

```bash
PIP_PUBLISHER_BASE_STACK="jupyter nbconvert matplotlib pandas"
PIP_PUBLISHER_NOTEBOOK_STACK="jupyterlab notebook nbconvert ipykernel"
```

Do not include:
- private vault paths
- manuscript content
- publisher credentials
- tokens

## Package defaults

Add to:

```text
/home/vmuser/.local/etc/config-sh/install/packages.env
```

and to config-init `packages_body`:

```bash
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
```

## steps.tsv additions

Add rows to both:
- actual `etc/config-sh/bootstrap/steps.tsv`
- config-init `steps_body`

Use the existing tab-separated column format.

Minimum new rows:

```text
install_ml_base_python_stack
install_pytorch_stack
install_llm_stack
install_api_stack
install_ml_dev_tools
check_gpu_availability
check_pytorch_cuda

install_research_numeric_python_stack
install_research_optimization_stack
install_research_notebook_stack
install_grn_research_python_stack
install_parameter_search_tooling

install_publisher_base_tools
install_publisher_notebook_stack
install_pandoc_obsidian_tools

check_openclaw_base_requirements
install_openclaw_full_stack
check_openclaw_agent_workspace

check_docker_access
check_terraform_installation
check_kubernetes_access
```

Scope guidance:
- `target` for Python env package steps.
- `system` for non-mutating system checks.
- `mixed` only if a function changes both system and target.

Network flag:
- `1` for package install steps.
- `0` for local checks.

## Allowlist updates

Add all new trusted functions to `config_bootstrap_function_allowed`.

This is mandatory because the manifest should not dispatch arbitrary function names.

## Function behavior rules

Python install functions:
- call `InstallPythonPackagesIntoTargetEnv`.
- print target user/role/env.
- use package var by name.
- skip cleanly if package var is empty.
- never use sudo pip.
- never rely on active env.

Check functions:
- must not mutate system state.
- must not install packages.
- should suggest the corresponding install step if a tool is missing.

OpenClaw:
- do not run `main.py`.
- do not start an agent.
- use `OPENCLAW_WORKSPACE` only if configured.
- skip clearly if not configured.

Infra checks:
- do not run `docker run hello-world`.
- do not modify kube context.
- do not create Kubernetes clusters.
- do not install Terraform/Docker/Kubernetes here.

## Role plan defaults

### ai-engineer.plan

Pending:

```text
install_ml_base_python_stack
install_pytorch_stack
install_llm_stack
install_api_stack
install_ml_dev_tools
```

Skipped:

```text
check_gpu_availability
check_pytorch_cuda
check_openclaw_base_requirements
install_openclaw_full_stack
check_openclaw_agent_workspace
check_docker_access
check_terraform_installation
check_kubernetes_access
research-specific steps
publisher-specific steps
```

### research-scientist.plan

Pending:

```text
install_research_numeric_python_stack
install_research_optimization_stack
install_research_notebook_stack
install_grn_research_python_stack
install_parameter_search_tooling
```

Skipped:
- AI platform steps
- publisher steps
- infra checks unless explicitly needed

### publisher.plan

Pending:

```text
install_publisher_base_tools
install_publisher_notebook_stack
```

Skipped:

```text
install_pandoc_obsidian_tools
AI platform steps
research optimization steps
infra checks
```

### operator.plan

Prefer skipped for role-specific Python stacks unless the operator directly uses them.

## Existing target plan migration

Changing profile templates does not rewrite existing runtime plans.

After this milestone, existing targets may need one of:

```bash
sudo config --target aiengineer bootstrap plan-file
sudoedit "$(sudo config --target aiengineer bootstrap plan-file)"

sudo config --target aiengineer bootstrap plan-apply --skips-only
```

Do not force overwrite target runtime plans during config-init.

## Validation

Syntax:

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
```

Registry checks:

```bash
config --target aiengineer bootstrap steps | grep -E 'install_ml_base_python_stack|install_llm_stack|install_api_stack'
config --target researchscientist bootstrap steps | grep -E 'install_grn_research_python_stack|install_parameter_search_tooling'
config --target publisher bootstrap steps | grep -E 'install_publisher_base_tools|install_publisher_notebook_stack'
```

Allowlist checks:

```bash
grep -n "InstallMLBasePythonStack" /home/vmuser/.local/bin/config.sh
grep -n "InstallGRNResearchPythonStack" /home/vmuser/.local/bin/config.sh
grep -n "InstallPublisherBaseTools" /home/vmuser/.local/bin/config.sh
```

Profile checks:

```bash
grep -n "install_ml_base_python_stack" /home/vmuser/.local/etc/config-sh/bootstrap/profiles/ai-engineer.plan
grep -n "install_grn_research_python_stack" /home/vmuser/.local/etc/config-sh/bootstrap/profiles/research-scientist.plan
grep -n "install_publisher_base_tools" /home/vmuser/.local/etc/config-sh/bootstrap/profiles/publisher.plan
```

Inspection only:

```bash
config --target aiengineer config-show | grep -E 'PYTHON_ENV|TARGET_ROLE|ACCOUNT_PROFILE'
sudo config --target aiengineer bootstrap status
```

Do not run broad bootstrap.

## Acceptance criteria

- Old alias intent is mapped to managed functions and steps.
- Python-installing functions use the AN2-02A helper.
- Role-specific steps exist in steps.tsv and config-init steps_body.
- Role plans are no longer conservative lab clones.
- AIEngineer gets AI platform stack defaults.
- ResearchScientist gets research/GRN/search stack defaults.
- Publisher gets publishing/notebook stack defaults.
- OpenClaw behavior is mapped as checks/install steps but does not auto-run agents.
- Infra aliases are mapped as check steps, not mutating installs.
- Help/docs explain old aliases are now managed steps.
- `lv` remains an inspection/manual env helper, not the managed install backend.
- no credentials/private data are read or printed.
