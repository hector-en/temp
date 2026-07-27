# InfraCTL

**Portable change control for AI-assisted private projects.**

Coding agents such as Codex, Claude Code, and OpenCode can plan, edit files, and run commands. InfraCTL controls the process around that work: which private project is authoritative, what may change, who approves it, how it is validated, and what evidence is returned.

> **The agent performs the work. InfraCTL keeps the delivery controlled, portable, and auditable.**

## The problem

Using one coding agent for one contained task is straightforward. The risk appears when a private project spans multiple sessions, agents, repositories, or execution environments.

Without a shared delivery contract:

- private context must be reconstructed repeatedly;
- approvals and change boundaries become informal;
- agents can act from stale or incomplete inputs;
- implementation becomes separated from validation evidence;
- the project becomes tied to one agent's memory or configuration.

InfraCTL provides a reusable public control layer while the project's proprietary context remains private.

```text
public InfraCTL contract + private project bundle + chosen agent
                         ↓
request → confirm → implement → validate → return evidence
```

## What it changes

InfraCTL verifies the authoritative private project, defines the permitted change boundary, requires approval before execution, validates the result, and preserves evidence for the next session or agent.

The organisation can change agents without rebuilding its delivery process or publishing proprietary project knowledge.

## Example

A private scientific platform needs a containerised API, cloud deployment, CI/CD, and a rollback procedure.

InfraCTL guides the work through a controlled sequence:

1. **Define** the outcome and select the authoritative private project.
2. **Plan** the architecture, affected files, tests, acceptance criteria, and rollback path.
3. **Approve** the scope before any mutation.
4. **Implement** with the selected coding agent or operator.
5. **Validate and close out** with results, risks, and evidence for the next cycle.

**So what:** the project moves from an informal AI conversation to a controlled and repeatable delivery process.

## Install

Requires Python 3.10+.

```bash
git clone <repository-url>
cd infractl
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
python -m pip install .
infractl --help
```

## Quick start

### 1. Keep public and private roots separate

```text
workspace/
├── infractl/              # public control layer
└── my-project-private/    # private context, rules, and evidence
```

### 2. Validate the selected private project

Run from the InfraCTL repository:

```bash
infractl validate-real-layout \
  --project ../my-project-private \
  --public-tool-root . \
  --private-bundle-source ../my-project-private
```

InfraCTL stops when project identity, required files, or source selection are missing or ambiguous.

### 3. Start a controlled request

For web chat, provide `infractl.zip`, `infractl.md`, and the selected private bundle. Then use:

```text
Use the public InfraCTL workflow with the selected private project.
Resolve the appropriate route and propose the complete scope,
variables, affected systems, acceptance criteria, and execution boundary.
Do not modify or overwrite anything until I approve the request.
```

For a local coding agent, provide access to this repository and the selected private project root. The same approval, validation, and evidence contract applies.

## Repository contents

The repository separates deterministic controls from human- and agent-readable workflow instructions.

- [`infractl/`](infractl/) — Python CLI for project resolution, validation, request generation, packaging, and evidence checks.
- [`infractl.md`](infractl.md) — compact entry point for selecting and running one controlled workflow.
- [`dots/`](dots/) — visual workflow contracts defining routes, roles, approvals, and stop conditions.
- [`schemas/`](schemas/) — public definitions for private-project manifests.
- [`examples/`](examples/) — non-proprietary examples of the expected private-project structure.
- [`scripts/`](scripts/) — export, reporting, snapshot, and safety utilities.
- [`tests/`](tests/) — automated checks for project identity, version consistency, and safe source resolution.
- [`workflow.md`](workflow.md) — operating sequence from request to evidence return.
- [`prompt_guide.md`](prompt_guide.md) — detailed prompts and route examples.

**Why Python and Markdown?** Python enforces rules that must be deterministic. Markdown and DOT keep decisions, responsibilities, approvals, and handoffs readable by people and portable across agents.

## When to use it

Use a coding agent directly for a contained task in one repository.

Use InfraCTL when work spans private projects, multiple agents or environments, separate approval and implementation responsibilities, or changes requiring validation, rollback, and retained evidence.

## Agent model

Current workflow contracts explicitly define ChatGPT, Codex, and operator-shell handoffs. Other coding agents can be connected by mapping them to the same contract: what they may read, what they may change, when approval is required, which checks must pass, and what evidence they return.

InfraCTL does not replace an agent runtime. It provides a portable control layer around one.

## Project requests

A new private-project structure, unsupported agent integration, or custom delivery workflow is handled as a **Project Request**.

A Project Request defines the intended outcome, private project identity, permitted environments, change boundaries, acceptance criteria, and evidence expectations.

Do not publish proprietary project content in public GitHub issues.

> Early public release: review generated plans and changes, test in an isolated environment, and keep a recoverable copy of every private project.
