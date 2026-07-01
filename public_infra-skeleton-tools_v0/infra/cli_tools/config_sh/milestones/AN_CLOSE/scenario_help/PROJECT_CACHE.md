# Project cache for Codex

Repo root:
`/home/vmuser/.local`

Open these first, only as needed:
- `bin/config.sh` — CLI parser, help text, bootstrap command, scenario help target.
- `bin/lv.sh` — Python environment cockpit help; inspect only if wording must stay aligned.
- `lib/config-sh/installers.sh` — installer function names; inspect only to confirm step/function names.
- `etc/config-sh/bootstrap/steps.tsv` — step names and function links.
- `etc/config-sh/install/packages.env` — package stack variables.
- `etc/config-sh/install/python-env-profiles.tsv` — target env policy.
- `etc/config-sh/bootstrap/profiles/*.plan` — role defaults.
- `etc/config-sh/targets/*.env` — role target defaults.

Known current scenarios/roles:
- operator: `vmuser`
- research scientist target: `researchscientist`
- AI engineer target: `aiengineer`
- publisher target: `publisher`

Known current managed steps:
- `install_grn_research_python_stack`
- `install_parameter_search_tooling`
- `install_research_numeric_python_stack`
- `install_research_optimization_stack`
- `install_research_notebook_stack`
- `install_ml_base_python_stack`
- `install_pytorch_stack`
- `install_llm_stack`
- `install_api_stack`
- `install_ml_dev_tools`
- `install_publisher_base_tools`
- `install_publisher_notebook_stack`
- `install_pandoc_obsidian_tools`
- `check_openclaw_base_requirements`
- `install_openclaw_full_stack`
- `check_openclaw_agent_workspace`
- `check_docker_access`
- `check_terraform_installation`
- `check_kubernetes_access`

Known policy files:
- package policy: `/home/vmuser/.local/etc/config-sh/install/packages.env`
- Python env profiles: `/home/vmuser/.local/etc/config-sh/install/python-env-profiles.tsv`
- step registry: `/home/vmuser/.local/etc/config-sh/bootstrap/steps.tsv`
- installers: `/home/vmuser/.local/lib/config-sh/installers.sh`
- dispatch allowlist: `/home/vmuser/.local/bin/config.sh`
- role plans: `/home/vmuser/.local/etc/config-sh/bootstrap/profiles/*.plan`

Do not modify state marker files except writing the requested postcheck log under `patches/`.
