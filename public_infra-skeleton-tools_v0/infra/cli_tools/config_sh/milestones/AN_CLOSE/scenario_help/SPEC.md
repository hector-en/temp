# SPEC - Add scenario and workflow help to config CLI

## Goal
Add a terminal-native scenario/workflow companion inside `config`.

A **scenario** is one situation. A **workflow** is a practical sequence of scenarios that matches how the project will be used in real research, AI infrastructure, writing, and future Agentfield automation.

## Commands
Support these commands:

```bash
config scenarios
config scenario list
config scenario NAME
config workflows
config workflow list
config workflow NAME
config help scenario
config help workflow
```

`config scenarios` and `config scenario list` print scenario names and one-line descriptions.
`config workflows` and `config workflow list` print workflow names, purpose, and included scenarios.
`config scenario NAME` prints one compact scenario.
`config workflow NAME` prints one compact workflow with the scenario chain and commands.

## Edit scope
Preferred changed files:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/patches/AN_CLOSE_01_scenario_workflow_help_postcheck.log
```

Do not create guide/article/manual/HTML files.

## CLI style
Every scenario/workflow should fit terminal help.

Use this shape:

```text
Workflow: <name>
<short context paragraph, 2-5 lines max>

What this does for the work.
<1-3 lines: why this helps research, development, publishing, infrastructure, or safe setup.>

Scenarios used:
  scenario-a -> scenario-b -> scenario-c

# Comment around a command group.
command ...
command ...

# Verify.
command ...
```

Rules:
- Keep commands exact.
- Avoid article prose and long tables.
- Use comments before command groups.
- Include future steps only as commented placeholders, never executable commands.
- Do not print huge help by default; users choose a workflow or scenario by name.
- Prefer `config workflow NAME` for long multi-stage loops.
- Keep `config scenario NAME` smaller and reusable.

## Scenario names
Implement or preserve these scenario names:

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

Useful aliases may be added:

```text
research -> research-grn
publisher -> publisher-paper
runpod -> runpod-prototype
agentfield -> agentfield-runtime
```

## Workflow names
Add these workflow names:

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

## Required workflow mapping
Use WORKFLOWS.md as the content source.

At minimum:

```text
research-daily = daily-loop + operator-target + python-env
prototype-to-policy = package + package-step + managed-step
grn-discovery-local = research-grn + nca-art-research + grn-parameter-search
runpod-grn-campaign = runpod-prototype + runpod-training + runpod-inference + experiment-cost-control
ai-infra-prototype = ai-prototype + remote-compute + runpod-prototype
publishing-machine = publisher-paper + obsidian-writing-machine + paper-latex-export
pkm-openclaw-writing = openclaw-pkm + pkm-local-model + obsidian-writing-machine + publisher-paper
agentfield-platform = agentfield-runtime + agentfield-controller + agentic-platform-layer
safe-sync-and-accounts = account-lifecycle + sync-mounts + operator-target
```

## Dispatch integration
Add scenario/workflow commands to the existing command parser and help surfaces.
Do not disturb existing commands.

## Validation
Run only non-mutating checks:

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/lv.sh
bash --noprofile --norc -n /home/vmuser/.local/lib/config-sh/installers.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/mounts.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/create-cifs-credentials-files.sh
config scenario list
config workflows
config workflow research-daily
config workflow prototype-to-policy
config workflow grn-discovery-local
config workflow runpod-grn-campaign
config workflow publishing-machine
config workflow agentfield-platform
config help workflow
```

Do not execute printed workflow commands.
