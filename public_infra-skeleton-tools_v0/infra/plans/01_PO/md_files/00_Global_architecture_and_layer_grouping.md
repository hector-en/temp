# Global Architecture and Layer Grouping

## Global architecture direction

The system should be built as a stack, not as disconnected setup scripts:

### config

Prepares machines, roles, users, mounts, package policy, Python environments, Runpod workspaces, publishing paths, and safe runtime checks.

### Agentfield

Owns experiment intent, controller flow, agent selection, execution state, status, result tracking, and later campaign-level experiment automation.

### Paperclip-Agentfield adapter

Connects Paperclip jobs/actions to Agentfield experiments and returns status, metrics, artifacts, and failure reasons.

### Paperclip

Gives the human-facing dashboard, inbox, governance, job overview, review loop, and end-to-end visibility.

That matches your Agentfield notes: config prepares users, environments, mounts, and packages; Agentfield becomes the experiment-aware layer using `GRNExperiment`, controller status/results, an agent registry, a reasoner invoker, and GRN agents. The Paperclip notes add the missing bridge: Paperclip should stay the UI/control surface, while an adapter translates Paperclip jobs into Agentfield runs and returns status/results.

## Layer grouping

I would group the real-world work into five layers.

### Layer 1 - Runtime substrate

1. Runpod portable runtime base
2. Remote model brain endpoint

### Layer 2 - Role workstations

1. Research Scientist GRN workspace
2. AI Engineer agent/platform dev environment
3. Obsidian writing machine
4. Publisher LaTeX/paper export

### Layer 3 - Research execution loops

1. NCA-ART research stack
2. Parameter search comparison tools
3. Runpod training/inference loop

### Layer 4 - Knowledge, reasoning, and writing automation

1. OpenClaw + PKM reasoning workspace

### Layer 5 - Platform orchestration

1. Agentfield experiment runtime foundation
2. Paperclip-Agentfield adapter
3. Agentic GRN discovery platform

## Bundle boundary note

Some items you listed are not standalone bundles; they are concretizations inside bundles. For example, `prepare_docker_runtime_policy`, `check_docker_gpu_access`, `check_kubernetes_context`, and `prepare_remote_compute_profile` belong partly to Runpod portable runtime base and partly to AI Engineer agent/platform dev environment. I would not make them a fourteenth bundle unless the remote compute story becomes large enough later.
