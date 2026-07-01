# Workflow content source

Implement these as compact `config workflow NAME` outputs. These are CLI help bodies, not external docs.

## research-daily
Workflow: research-daily
This is the normal operator-to-target working rhythm. Use it at the start of a session, after changing packages, or before running research code.

What this does for the work.
It keeps role context, Python environment, and setup state visible before you spend time writing code or running experiments.

Scenarios used:
  daily-loop -> operator-target -> python-env

# Inspect the role from the operator seat.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
config --target researchscientist bootstrap steps

# Inspect Python environments with lv.
lv
lv conda researchscientist

# If setup is missing, run one managed step only.
sudo config --target researchscientist bootstrap step install_grn_research_python_stack

# Work as the target only for real research work.
su - researchscientist
lv conda researchscientist

## prototype-to-policy
Workflow: prototype-to-policy
Use this when you discover a package or repeatable setup action. First prototype it, then decide whether it belongs in stable policy, then trace or create the managed step.

What this does for the work.
It prevents one-off experiments from polluting stable role environments while still letting useful discoveries become reproducible setup.

Scenarios used:
  package -> package-step -> managed-step

# Prototype inside a named environment.
su - researchscientist
lv conda grn-5node-prototype -new
conda run -n grn-5node-prototype python -m pip install optuna
conda run -n grn-5node-prototype python -c "import optuna; print(optuna.__version__)"
exit

# Promote stable package policy only after the package proves useful.
sudoedit /home/vmuser/.local/etc/config-sh/install/packages.env

# Trace the managed step before running or editing it.
grep -n 'install_parameter_search_tooling' /home/vmuser/.local/etc/config-sh/bootstrap/steps.tsv
grep -n 'InstallParameterSearchTooling' /home/vmuser/.local/lib/config-sh/installers.sh
grep -n 'InstallParameterSearchTooling' /home/vmuser/.local/bin/config.sh

# Run the smallest relevant managed step.
sudo config --target researchscientist bootstrap step install_parameter_search_tooling

# Verify.
lv conda researchscientist
sudo config --target researchscientist bootstrap status

## grn-discovery-local
Workflow: grn-discovery-local
Use this for local GRN discovery before automation: PDE/ODE simulation, NCA or NCA-like prototype work, ART prototype discovery, parameter search, notebooks, and result comparison.

What this does for the work.
It gives the Research Scientist role the numerical, optimisation, notebook, and GRN tooling needed to prove the research loop before moving to Runpod or Agentfield.

Scenarios used:
  research-grn -> nca-art-research -> grn-parameter-search

# Prepare the research role.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
sudo config --target researchscientist bootstrap step install_research_numeric_python_stack
sudo config --target researchscientist bootstrap step install_research_optimization_stack
sudo config --target researchscientist bootstrap step install_research_notebook_stack
sudo config --target researchscientist bootstrap step install_grn_research_python_stack
sudo config --target researchscientist bootstrap step install_parameter_search_tooling

# Work as research scientist.
su - researchscientist
lv conda researchscientist

# Future research steps to add, not current commands:
# run_pde_ode_smoke_test
# run_art_prototype_smoke_test
# export_symbolic_grn_candidate

# Reminder: compare LHS, evolutionary, Bayesian, and sweep methods before freezing search policy.

## runpod-grn-campaign
Workflow: runpod-grn-campaign
Use this after the local GRN loop works and you need GPU training, candidate scoring, inference, or many comparable runs on Runpod.

What this does for the work.
It separates Docker as the stable machine base from config as the role/environment policy layer, so remote GPU work is repeatable and less likely to waste GPU hours.

Scenarios used:
  runpod-prototype -> runpod-training -> runpod-inference -> experiment-cost-control

# Local readiness before remote work.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
lv conda researchscientist

# Current non-mutating readiness checks.
sudo config --target researchscientist bootstrap step check_gpu_availability
sudo config --target aiengineer bootstrap step check_docker_access

# Inspect package policy before mirroring or recreating remotely.
grep -n 'PIP_RESEARCH' /home/vmuser/.local/etc/config-sh/install/packages.env

# Future Runpod steps to add, not current commands:
# prepare_runpod_workspace
# check_runpod_volume_layout
# prepare_runpod_training_env
# run_nca_art_training_smoke_test
# prepare_runpod_inference_endpoint
# estimate_runpod_budget
# check_idle_pod_guard

## ai-infra-prototype
Workflow: ai-infra-prototype
Use this when building the AI Engineer side: ML base stack, PyTorch, LLM tooling, API serving, local/remote inference helpers, and infrastructure checks.

What this does for the work.
It keeps AI engineering separate from biological research so APIs, local models, and infrastructure experiments can evolve without destabilising GRN research.

Scenarios used:
  ai-prototype -> remote-compute -> runpod-prototype

# Prepare AI Engineer stack one capability at a time.
config --target aiengineer config-show
sudo config --target aiengineer bootstrap status
sudo config --target aiengineer bootstrap step install_ml_base_python_stack
sudo config --target aiengineer bootstrap step install_pytorch_stack
sudo config --target aiengineer bootstrap step install_llm_stack
sudo config --target aiengineer bootstrap step install_api_stack
sudo config --target aiengineer bootstrap step install_ml_dev_tools

# Non-mutating infra checks.
sudo config --target aiengineer bootstrap step check_docker_access
sudo config --target aiengineer bootstrap step check_terraform_installation
sudo config --target aiengineer bootstrap step check_kubernetes_access

# Work as AI Engineer.
su - aiengineer
lv conda aiengineer

## publishing-machine
Workflow: publishing-machine
Use this when turning notebooks, figures, PKM notes, experiment summaries, and a prepared LaTeX template into a manuscript draft.

What this does for the work.
It keeps publishing and export tooling under Publisher while research and training environments stay focused on experiments.

Scenarios used:
  publisher-paper -> obsidian-writing-machine -> paper-latex-export

# Prepare publisher tooling.
config --target publisher config-show
sudo config --target publisher bootstrap status
sudo config --target publisher bootstrap step install_publisher_base_tools
sudo config --target publisher bootstrap step install_publisher_notebook_stack
sudo config --target publisher bootstrap step install_pandoc_obsidian_tools

# Work as Publisher.
su - publisher
lv conda publisher

# Future paper steps to add, not current commands:
# check_latex_template
# export_notebook_results
# build_manuscript_draft

## pkm-openclaw-writing
Workflow: pkm-openclaw-writing
Use this when OpenClaw or a local model should reason about PKM notes, research logs, biological theory, infrastructure notes, and paper structure.

What this does for the work.
It lets PKM-assisted reasoning be checked safely before agents touch private notes or manuscript material.

Scenarios used:
  openclaw-pkm -> pkm-local-model -> obsidian-writing-machine -> publisher-paper

# Check Publisher and AI Engineer contexts.
config --target publisher config-show
config --target aiengineer config-show
lv conda publisher
lv conda aiengineer

# Check OpenClaw prerequisites without running agents.
sudo config --target publisher bootstrap step check_openclaw_base_requirements
sudo config --target publisher bootstrap step check_openclaw_agent_workspace

# Install only when you intend to use it.
sudo config --target publisher bootstrap step install_openclaw_full_stack

# Future PKM/local model steps to add, not current commands:
# check_ollama_runtime
# prepare_pkm_reasoner_profile
# smoke_test_pkm_query_without_dumping_notes

## agentfield-platform
Workflow: agentfield-platform
Use this when moving from manual controlled experiments toward the future Agentfield layer: experiment-aware controller, agent registry, reasoner profiles, GRNExperiment intent, and status/results.

What this does for the work.
It keeps config responsible for machine/role setup while Agentfield later owns experiment lifecycle, agents, results, and resumability.

Scenarios used:
  agentfield-runtime -> agentfield-controller -> agentic-platform-layer

# Prove the base roles and environments first.
config --target researchscientist config-show
config --target aiengineer config-show
config --target publisher config-show
lv

# Current managed setup foundations.
sudo config --target researchscientist bootstrap step install_grn_research_python_stack
sudo config --target researchscientist bootstrap step install_parameter_search_tooling
sudo config --target aiengineer bootstrap step install_api_stack
sudo config --target publisher bootstrap step install_publisher_base_tools

# Future Agentfield steps to add, not current commands:
# prepare_agentfield_project_profile
# prepare_agent_registry
# prepare_reasoner_profiles
# prepare_grnexperiment_examples
# smoke_test_experiment_controller_loop

## safe-sync-and-accounts
Workflow: safe-sync-and-accounts
Use this before account changes, mount work, pull/push, or cleanup. It is the safety workflow for role boundaries and data movement.

What this does for the work.
It protects research data, publishing material, credentials, and target homes from broad accidental changes.

Scenarios used:
  account-lifecycle -> sync-mounts -> operator-target

# Inspect profiles and target policy.
config profiles
config --target researchscientist config-show
sudo config --target researchscientist status

# Dry-run account operations.
sudo config --create-target --profile ResearchScientist --name researchscientist --dry-run
sudo config --create-target --profile AIEngineer --name aiengineer --dry-run
sudo config --create-target --profile Publisher --name publisher --dry-run
sudo config --remove-target --name researchscientist --dry-run

# Review sync help before moving data.
config help mount
config help pull
config help push

# Run only when intentionally syncing.
# sudo config --target researchscientist pull
# sudo config --target researchscientist push
