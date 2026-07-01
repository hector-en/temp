# Scenario content source

Implement these inside CLI help. Keep them compact. These are content targets, not external docs.

## daily-loop
Scenario: daily-loop
Most sessions should follow the same rhythm. Check the role, inspect the environment, decide whether this is setup or real work, run the smallest managed change, then verify.

What this does for the work.
Prevents installing into the wrong Python environment and prevents broad setup when one missing capability is enough.

# Inspect the role from the operator seat.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
config --target researchscientist bootstrap steps

# Inspect Python environments with lv.
lv
lv conda researchscientist

# Run one specific managed setup step only when needed.
sudo config --target researchscientist bootstrap step install_grn_research_python_stack

# Verify again.
lv conda researchscientist
sudo config --target researchscientist bootstrap status

## operator-target
Scenario: operator-target
Use `vmuser` for managed setup and policy changes. Switch to the target account only when doing interactive research, development, writing, or local environment exploration.

What this does for the work.
Keeps administration reproducible while still letting each role own its real working shell.

# From vmuser: inspect and change setup for a target.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
sudo config --target researchscientist bootstrap step install_parameter_search_tooling

# As the target: do real work inside that user's home and environment.
su - researchscientist
lv
lv conda researchscientist

# Return to vmuser before changing managed setup again.
exit
sudo config --target researchscientist bootstrap status

## python-env
Scenario: python-env
Use `lv` as the Python environment cockpit. `config` decides what should be installed. `lv` helps you inspect, create, clone, remove, and verify environments.

What this does for the work.
Keeps experiments separated from stable role environments and makes package landing visible.

# Inspect all known environments.
lv

# Inspect the target role environment.
lv conda researchscientist
lv conda aiengineer
lv conda publisher

# Create a prototype env before promoting packages into policy.
lv conda grn-5node-prototype -new
lv conda grn-5node-prototype

# Remove throwaway envs only after exporting anything important.
lv conda grn-5node-prototype -del

## package
Scenario: package
You found a package that may help simulation, plotting, parameter search, inference, API serving, writing, or export. Prototype it first; promote it only when it becomes stable role policy.

What this does for the work.
Gives freedom to experiment without polluting the stable research, AI engineering, or publisher environments.

# Explore as the target user.
su - researchscientist
lv conda grn-5node-prototype -new
conda run -n grn-5node-prototype python -m pip install optuna
conda run -n grn-5node-prototype python -c "import optuna; print(optuna.__version__)"

# Promote only useful packages into managed policy.
exit
sudoedit /home/vmuser/.local/etc/config-sh/install/packages.env

# Install through the relevant managed step.
sudo config --target researchscientist bootstrap step install_parameter_search_tooling

# Verify the target environment.
su - researchscientist
lv conda researchscientist

## package-step
Scenario: package-step
A package stack becomes real only when a managed step runs. The chain is package policy, target role, Python environment, trusted installer, step marker, then inspection.

What this does for the work.
Makes package installation repeatable, inspectable, and tied to the role that needs it.

# Inspect package recipes and target Python policy.
grep -n 'PIP_RESEARCH' /home/vmuser/.local/etc/config-sh/install/packages.env
grep -n 'ResearchScientist' /home/vmuser/.local/etc/config-sh/install/python-env-profiles.tsv
config --target researchscientist config-show

# Run one managed step.
sudo config --target researchscientist bootstrap step install_grn_research_python_stack

# Verify marker and environment.
sudo config --target researchscientist bootstrap status
lv conda researchscientist

## managed-step
Scenario: managed-step
A managed step is a friendly step name connected to a trusted shell function. Use this when you need to trace, change, or create a repeatable setup action.

What this does for the work.
Lets you understand or extend the tool without turning editable policy files into arbitrary shell execution.

# Trace an existing research step.
grep -n 'install_grn_research_python_stack' /home/vmuser/.local/etc/config-sh/bootstrap/steps.tsv
grep -n 'InstallGRNResearchPythonStack' /home/vmuser/.local/lib/config-sh/installers.sh
grep -n 'InstallGRNResearchPythonStack' /home/vmuser/.local/bin/config.sh
grep -n 'install_grn_research_python_stack' /home/vmuser/.local/etc/config-sh/bootstrap/profiles/*.plan

# Create a new repeatable step only after the action is stable.
sudoedit /home/vmuser/.local/etc/config-sh/install/packages.env
sudoedit /home/vmuser/.local/lib/config-sh/installers.sh
sudoedit /home/vmuser/.local/etc/config-sh/bootstrap/steps.tsv
sudoedit /home/vmuser/.local/bin/config.sh
sudoedit /home/vmuser/.local/etc/config-sh/bootstrap/profiles/research-scientist.plan

# Validate before using it.
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
config --target researchscientist bootstrap steps | grep 'install_research_visualization_stack'

## research-grn
Scenario: research-grn
Use this for GRN simulation, five-node NCA-ART exploration, parameter search, notebooks, and reproducible research runs under the Research Scientist role.

What this does for the work.
Builds the numerical, optimisation, notebook, and GRN package base without mixing it with AI engineering or publishing work.

# Inspect research role setup.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
config --target researchscientist bootstrap steps

# Install only the research capabilities needed.
sudo config --target researchscientist bootstrap step install_research_numeric_python_stack
sudo config --target researchscientist bootstrap step install_research_optimization_stack
sudo config --target researchscientist bootstrap step install_research_notebook_stack
sudo config --target researchscientist bootstrap step install_grn_research_python_stack
sudo config --target researchscientist bootstrap step install_parameter_search_tooling

# Work as the role.
su - researchscientist
lv conda researchscientist

## ai-prototype
Scenario: ai-prototype
Use this when building model prototypes, local inference helpers, FastAPI services, LLM tooling, or agent runtime experiments under the AI Engineer role.

What this does for the work.
Separates ML/LLM/API tooling from the biological research environment, so prototypes can move faster without destabilising research runs.

# Inspect AI engineer role setup.
config --target aiengineer config-show
sudo config --target aiengineer bootstrap status
config --target aiengineer bootstrap steps

# Add one AI capability at a time.
sudo config --target aiengineer bootstrap step install_ml_base_python_stack
sudo config --target aiengineer bootstrap step install_pytorch_stack
sudo config --target aiengineer bootstrap step install_llm_stack
sudo config --target aiengineer bootstrap step install_api_stack
sudo config --target aiengineer bootstrap step install_ml_dev_tools

# Work as AI engineer.
su - aiengineer
lv conda aiengineer

## publisher-paper
Scenario: publisher-paper
Use this when turning notebooks, PKM notes, figures, and analysis outputs into a manuscript workflow under the Publisher role.

What this does for the work.
Keeps publishing tools close to the paper and away from the training environment, while still letting research outputs be exported cleanly.

# Inspect publisher setup.
config --target publisher config-show
sudo config --target publisher bootstrap status
config --target publisher bootstrap steps

# Prepare notebook and export tooling.
sudo config --target publisher bootstrap step install_publisher_base_tools
sudo config --target publisher bootstrap step install_publisher_notebook_stack
sudo config --target publisher bootstrap step install_pandoc_obsidian_tools

# Work as publisher.
su - publisher
lv conda publisher

## remote-compute
Scenario: remote-compute
Use this before remote training or infrastructure work. Check Docker, Terraform, and Kubernetes readiness without starting jobs or mutating clusters.

What this does for the work.
Confirms the machine can support remote compute orchestration before expensive GPU work is attempted.

# Inspect non-mutating infra checks.
config --target aiengineer bootstrap steps | grep -E 'docker|terraform|kubernetes'

# Run readiness checks only.
sudo config --target aiengineer bootstrap step check_docker_access
sudo config --target aiengineer bootstrap step check_terraform_installation
sudo config --target aiengineer bootstrap step check_kubernetes_access

# Verify status.
sudo config --target aiengineer bootstrap status

## openclaw-pkm
Scenario: openclaw-pkm
Use this when checking OpenClaw prerequisites or a configured PKM/workspace path without running agents or dumping private notes.

What this does for the work.
Lets local model or PKM-assisted reasoning be prepared safely before it is allowed to touch actual notes, manuscript material, or research state.

# Inspect target policy and OpenClaw steps.
config --target publisher config-show
config --target publisher bootstrap steps | grep -i openclaw

# Check prerequisites and workspace safely.
sudo config --target publisher bootstrap step check_openclaw_base_requirements
sudo config --target publisher bootstrap step check_openclaw_agent_workspace

# Install OpenClaw stack only when you intend to use it.
sudo config --target publisher bootstrap step install_openclaw_full_stack

# Verify environment.
su - publisher
lv conda publisher

## sync-mounts
Scenario: sync-mounts
Use this when you need to inspect mount identity, available shares, pull/push paths, or sync state without accidentally overwriting work.

What this does for the work.
Protects research data, manuscript material, ingress, and egress from broad unintended sync actions.

# Inspect target mount and sync policy.
config --target researchscientist config-show
sudo config --target researchscientist status

# Review mount help before mounting.
config help mount

# Do not pull or push until the target and paths are clear.
config help pull
config help push

# Run only when intentionally syncing.
# sudo config --target researchscientist pull
# sudo config --target researchscientist push

## account-lifecycle
Scenario: account-lifecycle
Use this when creating, checking, or removing role accounts. Always dry-run first.

What this does for the work.
Keeps role users, groups, mount policies, SMB profiles, and Python env policies explicit before changing the system.

# Inspect available profiles.
config profiles

# Dry-run account creation.
sudo config --create-target --profile ResearchScientist --name researchscientist --dry-run
sudo config --create-target --profile AIEngineer --name aiengineer --dry-run
sudo config --create-target --profile Publisher --name publisher --dry-run

# Dry-run removal before any destructive action.
sudo config --remove-target --name researchscientist --dry-run

## runpod-prototype
Scenario: runpod-prototype
Use this for the first portable Runpod test. Start with a stable base image and let config apply role, environment, and workspace policy after the pod starts.

What this does for the work.
Avoids reinstalling everything manually on every pod and keeps GPU experiments reproducible.

# On the local machine: inspect the intended role and package stack.
config --target researchscientist config-show
config --target researchscientist bootstrap steps
lv conda researchscientist

# Future setup steps to add, not current commands:
# prepare_runpod_workspace
# prepare_nca_art_workspace
# check_gpu_runtime

# Current safe readiness checks.
sudo config --target researchscientist bootstrap step check_docker_access
sudo config --target researchscientist bootstrap step check_gpu_availability

## runpod-training
Scenario: runpod-training
Use this when the first NCA-ART training loop is ready to move from local prototype to a Runpod GPU pod.

What this does for the work.
Separates stable container base, mounted experiment workspace, target Python env, and training outputs so GPU hours are not wasted by drift.

# Before remote training, inspect package and role policy locally.
config --target researchscientist config-show
grep -n 'PIP_RESEARCH' /home/vmuser/.local/etc/config-sh/install/packages.env
sudo config --target researchscientist bootstrap status

# Verify the env that should be mirrored or recreated remotely.
lv conda researchscientist

# Future training steps to add, not current commands:
# prepare_runpod_training_env
# check_runpod_volume_layout
# run_nca_art_training_smoke_test

## runpod-inference
Scenario: runpod-inference
Use this after a model or candidate-scoring pipeline exists and you want cheaper, repeatable inference or scoring jobs.

What this does for the work.
Turns trained or configured models into repeatable candidate scoring without mixing inference services with research setup.

# Inspect AI engineer API and LLM tooling.
config --target aiengineer config-show
sudo config --target aiengineer bootstrap step install_api_stack
sudo config --target aiengineer bootstrap step install_llm_stack

# Verify API/inference env.
su - aiengineer
lv conda aiengineer

# Future inference steps to add, not current commands:
# prepare_runpod_inference_endpoint
# check_inference_model_cache
# smoke_test_candidate_scoring_api

## nca-art-research
Scenario: nca-art-research
Use this for the scientific loop that connects PDE/ODE simulation, NCA surrogate work, ART prototype discovery, and symbolic GRN extraction.

What this does for the work.
Keeps the architecture testable: simulator generates behavior, ART summarises it, NCA accelerates or tests local rules, and symbolic DSL candidates are verified back against the simulator.

# Prepare research and parameter-search foundations.
sudo config --target researchscientist bootstrap step install_grn_research_python_stack
sudo config --target researchscientist bootstrap step install_parameter_search_tooling

# Explore as research scientist.
su - researchscientist
lv conda researchscientist

# Future steps to add, not current commands:
# prepare_nca_art_workspace
# run_pde_ode_smoke_test
# run_art_prototype_smoke_test
# export_symbolic_grn_candidate

## grn-parameter-search
Scenario: grn-parameter-search
Use this when testing LHS, evolutionary search, Bayesian optimisation, robustness checks, or comparison methods for five-node GRN candidates.

What this does for the work.
Makes parameter-search tooling explicit and keeps candidate comparison reproducible across seeds, architectures, and perturbations.

# Install current search tooling.
sudo config --target researchscientist bootstrap step install_parameter_search_tooling

# Prototype comparison packages before promotion.
su - researchscientist
lv conda grn-search-prototype -new
conda run -n grn-search-prototype python -m pip install optuna scikit-optimize deap SALib

# Future reminder:
# Watch the PhD parameter-search video and compare LHS, evolutionary, Bayesian, and sweep methods before freezing the search stack.

## agentfield-runtime
Scenario: agentfield-runtime
Use this when moving from manual experiments to an experiment-aware Agentfield layer. Config prepares users, environments, mounts, and packages; Agentfield should own experiment lifecycle later.

What this does for the work.
Keeps machine setup below the controller and lets Agentfield coordinate experiments only after the target environment is trustworthy.

# Prepare the role first.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap step install_grn_research_python_stack
sudo config --target researchscientist bootstrap step install_parameter_search_tooling
lv conda researchscientist

# Future Agentfield runtime steps to add, not current commands:
# prepare_agentfield_workspace
# check_agentfield_controller_config
# check_agent_registry
# smoke_test_grnexperiment_status_write

## agentfield-controller
Scenario: agentfield-controller
Use this when designing the future ExperimentAwareController. The CRD should describe intent, the controller should select stages and agents, and status should record results.

What this does for the work.
Prevents agents from becoming an untracked script pile. The experiment becomes inspectable, resumable, and explainable.

# Current config layer: prove the target environment first.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status

# Future controller artifacts to add, not current commands:
# GRNExperiment CRD
# agent registry policy
# reasoner profile policy
# experiment profile policy
# status/result writer smoke test

## obsidian-writing-machine
Scenario: obsidian-writing-machine
Use this when the Publisher role turns PKM notes, Obsidian vault material, notebook outputs, and paper sections into a writing workflow.

What this does for the work.
Keeps writing, note retrieval, and export tooling under Publisher so research and training environments remain focused.

# Prepare publisher tooling.
config --target publisher config-show
sudo config --target publisher bootstrap step install_publisher_base_tools
sudo config --target publisher bootstrap step install_publisher_notebook_stack
sudo config --target publisher bootstrap step install_pandoc_obsidian_tools

# Check OpenClaw/PKM prerequisites without running agents.
sudo config --target publisher bootstrap step check_openclaw_base_requirements
sudo config --target publisher bootstrap step check_openclaw_agent_workspace

# Work as publisher.
su - publisher
lv conda publisher

## pkm-local-model
Scenario: pkm-local-model
Use this when a local or remote model helps reason over PKM notes, research logs, theory notes, and manuscript structure.

What this does for the work.
Keeps model access behind a thin interface and prevents raw PKM data from being dumped into setup logs.

# Inspect the publisher and AI engineer environments.
config --target publisher config-show
config --target aiengineer config-show
lv conda publisher
lv conda aiengineer

# Future local-model steps to add, not current commands:
# check_ollama_runtime
# prepare_pkm_reasoner_profile
# smoke_test_pkm_query_without_dumping_notes

## paper-latex-export
Scenario: paper-latex-export
Use this when figures, notebooks, and PKM summaries need to become a structured manuscript draft using a prepared LaTeX template.

What this does for the work.
Makes paper production repeatable instead of manually copying notebook output, figures, and text fragments.

# Prepare export tooling.
sudo config --target publisher bootstrap step install_publisher_base_tools
sudo config --target publisher bootstrap step install_publisher_notebook_stack
sudo config --target publisher bootstrap step install_pandoc_obsidian_tools

# Work as publisher.
su - publisher
lv conda publisher

# Future paper steps to add, not current commands:
# check_latex_template
# export_notebook_results
# build_manuscript_draft

## experiment-cost-control
Scenario: experiment-cost-control
Use this before running many GPU experiments. Cost grows with candidates, seeds, architecture variants, runtime, storage, and forgotten idle pods.

What this does for the work.
Forces a cheap proof first, then small sweeps, then serious sweeps only after the pipeline is comparable and resumable.

# Inspect readiness before spending GPU hours.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
lv conda researchscientist

# Current readiness checks.
sudo config --target researchscientist bootstrap step check_gpu_availability
sudo config --target aiengineer bootstrap step check_docker_access

# Future cost-control steps to add, not current commands:
# estimate_runpod_budget
# check_experiment_output_root
# check_resume_metadata
# check_idle_pod_guard

## agentic-platform-layer
Scenario: agentic-platform-layer
Use this when the project graduates from manual runs to an agentic research platform. Config stays responsible for environments; Agentfield owns experiment lifecycle; agents perform staged work.

What this does for the work.
Creates a clean ladder from local prototype to repeatable experiment control without losing inspectability.

# Current base: prove roles and envs first.
config --target researchscientist config-show
config --target aiengineer config-show
config --target publisher config-show
lv

# Current managed setup foundations.
sudo config --target researchscientist bootstrap step install_grn_research_python_stack
sudo config --target aiengineer bootstrap step install_api_stack
sudo config --target publisher bootstrap step install_publisher_base_tools

# Future platform steps to add, not current commands:
# prepare_agentfield_project_profile
# prepare_agent_registry
# prepare_reasoner_profiles
# prepare_grnexperiment_examples
# smoke_test_experiment_controller_loop
