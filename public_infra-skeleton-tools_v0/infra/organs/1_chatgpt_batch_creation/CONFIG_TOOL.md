# CONFIG_TOOL.md — cache-safe capability reference

**Purpose.**  
Use this file as the compact, cache-stable reference for how Codex may use the existing `config` tool while implementing the vmuser / Agentfield / GRN platform skeleton.

This file is **not** an implementation spec. It is a tool-use capability cache.

The full guide explains the config tool as a role-aware workstation control plane: the operator prepares target identities such as `aiengineer`, `researchscientist`, and `publisher`; the tool keeps separate who is being configured, which Python environment receives packages, which shares and credentials are allowed, and which setup steps have already run.

---

## 1. Hard boundary for Codex

For skeleton/platform implementation bundles, the config tool is a **dependency**, not the thing being edited.

Codex may use `config` to inspect, verify, and run explicitly named managed steps.

Codex must not change the config tool unless a future dedicated config-tool milestone explicitly says so.

### Do not edit

```text
/home/vmuser/.local/bin/config
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/bin/lv.sh
/home/vmuser/.local/bin/mounts.sh
/home/vmuser/.local/bin/create-cifs-credentials-files.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh/*
/home/vmuser/.local/state/config-sh/*
```

### Allowed use

```text
config --target USER config-show
config --target USER bootstrap steps
sudo config --target USER bootstrap status
sudo config --target USER status
sudo config --target USER bootstrap step STEP_NAME
config help TOPIC
config profiles
lv
lv conda ENV_NAME
lv venv ENV_NAME
```

### Main rule

```text
Use config as an operational interface.
Do not patch config internals.
Implement project skeleton code under /workspace/repos/*.
Write data, runs, artifacts, models, and checkpoints under /workspace/* roots.
```

---

## 2. Mental model

The config tool separates setup from work.

```text
vmuser / operator
  prepares accounts, policy, mounts, credentials, bootstrap steps, and role readiness

target user
  owns actual work files, notebooks, source code, runs, reports, and manuscripts
```

Use:

```text
config --target USER ...
```

when preparing or inspecting a role from the operator seat.

Use:

```text
su - USER
```

when doing real work as that role.

---

## 3. Daily inspection loop

Use this before implementing or testing a bundle.

```bash
# Inspect target policy.
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
config --target researchscientist bootstrap steps

# Inspect Python environments.
lv
lv conda researchscientist

# Run one explicit managed step only when the SPEC requires it.
sudo config --target researchscientist bootstrap step install_grn_research_python_stack

# Verify again.
lv conda researchscientist
sudo config --target researchscientist bootstrap status
```

This prevents two common mistakes:

```text
installing into the wrong Python environment
running broad setup when one specific capability is enough
```

---

## 4. Role map

### `researchscientist`

Use for:

```text
GRN/NCA/ART research
PDE/ODE simulation
DSL candidates
parameter search
notebooks
mechanism reports
scientific artifacts
```

Main paths:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

Typical checks:

```bash
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
lv conda researchscientist
```

### `aiengineer`

Use for:

```text
Agentfield development
Paperclip-Agentfield adapter
OpenClaw workspace
remote model clients
AI platform tooling
API/inference services
Runpod/client-side infrastructure
```

Main paths:

```text
/workspace/repos/agentfield
/workspace/repos/paperclip-agentfield-adapter
/workspace/repos/openclaw-workspace
/workspace/repos/research-assistant
```

Typical checks:

```bash
config --target aiengineer config-show
sudo config --target aiengineer bootstrap status
lv conda aiengineer
```

### `publisher`

Use for:

```text
Atomic Zettelkasten / PKM
Obsidian vault access
notebook export
LaTeX paper project
manuscript build
figure/table export
```

Main paths:

```text
/workspace/pkm/zettelkasten
/workspace/artifacts/papers/grn-paper
```

Typical checks:

```bash
config --target publisher config-show
sudo config --target publisher bootstrap status
lv conda publisher
```

---

## 5. Python environment cockpit: `lv`

Use `lv` for Python environment inspection and manual env operations.

```bash
lv
lv -help
lv conda researchscientist
lv conda aiengineer
lv conda publisher
lv venv reports

# Prototype env creation.
lv conda grn-5node-prototype -new
lv conda grn-5node-prototype

# Delete only after preserving outputs.
lv conda grn-5node-prototype -del
```

Boundary:

```text
lv manages and inspects Python environments.
config prepares roles, policy, mounts, package stacks, and managed steps.
```

For Codex:

```text
Use lv only for inspection in validation commands unless the SPEC explicitly asks to create a prototype env.
Do not parse human-facing lv output for program logic.
```

---

## 6. Managed step model

A managed bootstrap step connects:

```text
friendly step name
  -> trusted function
  -> allowlist
  -> package/policy file
  -> target role
  -> target Python environment
  -> marker/status
```

Trace a step with:

```bash
grep -n 'STEP_NAME' /home/vmuser/.local/etc/config-sh/bootstrap/steps.tsv
grep -n 'FunctionName' /home/vmuser/.local/lib/config-sh/installers.sh
grep -n 'FunctionName' /home/vmuser/.local/bin/config.sh
grep -n 'STEP_NAME' /home/vmuser/.local/etc/config-sh/bootstrap/profiles/*.plan
```

For skeleton bundles, Codex should normally **not** create new config managed steps. Instead, create project CLIs/scripts in `/workspace/repos/*` and let future config milestones wire them into bootstrap steps.

---

## 7. Package policy

Stable package lists live in:

```text
/home/vmuser/.local/etc/config-sh/install/packages.env
```

Examples already used by the config tool include:

```text
PIP_ML_BASE_STACK
PIP_PYTORCH_STACK
PIP_LLM_STACK
PIP_API_STACK
PIP_ML_DEV_TOOLS

PIP_RESEARCH_NUMERIC_STACK
PIP_RESEARCH_OPTIMIZATION_STACK
PIP_RESEARCH_NOTEBOOK_STACK

PIP_PUBLISHER_BASE_STACK
PIP_PUBLISHER_NOTEBOOK_STACK
```

For skeleton bundles:

```text
Do not edit packages.env.
Do not install new packages unless the SPEC explicitly asks for a managed config step.
Prefer pure standard-library dummy CLIs and JSON/YAML/text outputs.
```

---

## 8. Safe config commands by purpose

### Inspect target

```bash
config --target researchscientist config-show
config --target aiengineer config-show
config --target publisher config-show
```

### Inspect managed steps and state

```bash
config --target researchscientist bootstrap steps
sudo config --target researchscientist bootstrap status
```

### Run one explicit managed step

```bash
sudo config --target researchscientist bootstrap step install_grn_research_python_stack
sudo config --target aiengineer bootstrap step install_api_stack
sudo config --target publisher bootstrap step install_publisher_base_tools
```

### Account dry-run only

```bash
config profiles
sudo config --create-target --profile ResearchScientist --name researchscientist --dry-run
sudo config --create-target --profile AIEngineer --name aiengineer --dry-run
sudo config --create-target --profile Publisher --name publisher --dry-run
sudo config --remove-target --name researchscientist --dry-run
```

### Mount and sync help only

```bash
config help mount
config help pull
config help push
```

Do not run pull/push/mount unless the SPEC explicitly says so.

---

## 9. Config-managed role stacks already known

Use only when a SPEC requires role readiness.

### Research Scientist

```bash
sudo config --target researchscientist bootstrap step install_research_numeric_python_stack
sudo config --target researchscientist bootstrap step install_research_optimization_stack
sudo config --target researchscientist bootstrap step install_research_notebook_stack
sudo config --target researchscientist bootstrap step install_grn_research_python_stack
sudo config --target researchscientist bootstrap step install_parameter_search_tooling
```

### AI Engineer

```bash
sudo config --target aiengineer bootstrap step install_ml_base_python_stack
sudo config --target aiengineer bootstrap step install_pytorch_stack
sudo config --target aiengineer bootstrap step install_llm_stack
sudo config --target aiengineer bootstrap step install_api_stack
sudo config --target aiengineer bootstrap step install_ml_dev_tools
```

### Publisher

```bash
sudo config --target publisher bootstrap step install_publisher_base_tools
sudo config --target publisher bootstrap step install_publisher_notebook_stack
sudo config --target publisher bootstrap step install_pandoc_obsidian_tools
```

### OpenClaw / PKM checks

```bash
sudo config --target publisher bootstrap step check_openclaw_base_requirements
sudo config --target publisher bootstrap step check_openclaw_agent_workspace
sudo config --target publisher bootstrap step install_openclaw_full_stack
```

### Infrastructure checks

```bash
sudo config --target aiengineer bootstrap step check_docker_access
sudo config --target aiengineer bootstrap step check_terraform_installation
sudo config --target aiengineer bootstrap step check_kubernetes_access
```

These are intended as checks; do not use them to mutate remote infrastructure.

---

## 10. Scenario catalog

Use these names when a Codex prompt asks for config help or workflow grounding.

```text
daily-loop
operator-target
python-env
package
package-step
managed-step
research-grn
ai-prototype
publisher-paper
remote-compute
openclaw-pkm
sync-mounts
account-lifecycle
runpod-prototype
runpod-training
runpod-inference
nca-art-research
grn-parameter-search
agentfield-runtime
agentfield-controller
obsidian-writing-machine
pkm-local-model
paper-latex-export
experiment-cost-control
agentic-platform-layer
```

The scenario content is a guide for command style and tool usage. Do not implement scenario CLI help unless a config-tool milestone explicitly requests it.

---

## 11. Workflow catalog

Use these names to select a compact operational flow.

```text
research-daily
prototype-to-policy
grn-discovery-local
runpod-grn-campaign
ai-infra-prototype
publishing-machine
pkm-openclaw-writing
agentfield-platform
safe-sync-and-accounts
```

The workflow content explains how to combine scenarios. It is not permission to edit config internals.

---

## 12. Platform skeleton path rules

Implement project code here:

```text
/workspace/repos/nca-art-grn
/workspace/repos/agentfield
/workspace/repos/paperclip-agentfield-adapter
/workspace/repos/openclaw-workspace
/workspace/repos/research-assistant
```

Write project outputs here:

```text
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
/workspace/runs/agentfield
/workspace/runs/paperclip-agentfield-adapter
/workspace/repos/openclaw-workspace/runs
/workspace/artifacts/papers/grn-paper
/workspace/pkm/zettelkasten
```

Do not use `/home/vmuser/.local` as the project implementation area.

---

## 13. Skeleton-first rule

For the first implementation pass, build dummy organs:

```text
schemas
fixtures
directory skeletons
dummy CLIs
fake JSON artifacts
fake Markdown reports
dry-run scripts
smoke tests
```

Expected dummy science outputs:

```text
metadata.json
candidate.dsl.json
pattern_dynamics.json
nca_summary.json
art2_prototypes.json
artmap_transitions.json
perturbation_summary.json
mechanism_report.md
search_report.md
candidate_rankings.json
paperclip_review_payload.json
```

Do not block on real science implementation.

---

## 14. Transition-to-real rule

When replacing dummy organs with real organs:

```text
keep output filenames stable
keep schema fields stable
keep run directories stable
keep Agentfield/Paperclip contracts stable
replace only the producer internals
```

This lets Agentfield, OpenClaw, Paperclip, and publishing work continue while science modules become real.

---

## 15. Safety rules

Codex must not:

```text
print secrets
read credential file contents
dump PKM note bodies into logs
run broad bootstrap
run pull or push
mount shares unless explicitly requested
start Runpod jobs unless explicitly requested
call paid model APIs unless explicitly requested
modify kube context
run Docker builds unless explicitly requested
auto-approve next experiments
write directly to real Paperclip database unless a transition SPEC explicitly requests it
```

Codex may:

```text
create dummy files under /workspace
write schema fixtures
write dry-run reports
write postcheck logs inside the task workspace
run syntax checks
run project-local smoke tests
call config read-only inspection commands
```

---

## 16. Recommended prompt snippet

Use this in Codex packs only when the task needs config tool knowledge:

```text
Read CONFIG_TOOL.md only if you need config/lv role workflow context.

The config tool is already implemented and out of scope.
Do not edit /home/vmuser/.local/bin/config.sh.
Do not edit /home/vmuser/.local/lib/config-sh/installers.sh.
Do not edit /home/vmuser/.local/etc/config-sh.
Use config only for inspection/status or for explicitly named bootstrap steps in the SPEC.
Implement project skeleton code under /workspace/repos/* and outputs under /workspace/*.
```

---

## 17. Minimal validation patterns

Config inspection:

```bash
config --target researchscientist config-show
sudo config --target researchscientist bootstrap status
config --target researchscientist bootstrap steps
lv
```

Project syntax:

```bash
python -m compileall /workspace/repos/nca-art-grn
python -m compileall /workspace/repos/agentfield
python -m compileall /workspace/repos/paperclip-agentfield-adapter
```

Smoke checks:

```bash
python -m nca_art_grn.cli.run_dummy --output /workspace/runs/nca-art-grn/smoke/manual
find /workspace/runs/nca-art-grn/smoke/manual -maxdepth 1 -type f -print
```

Only run smoke commands that the active SPEC explicitly asks for.
