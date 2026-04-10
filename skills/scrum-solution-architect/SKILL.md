---
name: scrum-solution-architect
description: Define domain boundaries, invariants, and integration seams for infrastructure automation systems. Use when a task needs design-driven development, explicit domain language, and a safe architecture before implementation begins.
---

# Scrum Solution Architect

Create the technical blueprint for incremental delivery. Specify boundaries so implementation can be tested with mocks and run safely in production.

## Architecture Workflow

1. Define ubiquitous language for the current problem domain.
2. Split the system into bounded contexts and assign responsibilities.
3. Define invariants and idempotency rules for each context.
4. Specify interfaces between contexts as functions with typed inputs and outputs.
5. Map tests to each invariant before coding starts.

## Required Outputs

Produce these sections in order:
1. `Domain Language`
2. `Bounded Contexts`
3. `Invariants`
4. `Interface Contracts`
5. `Risk Register`

Use [references/domain-template.md](references/domain-template.md) as the base structure.

## Guardrails

- Keep architecture aligned to current increment scope.
- Require explicit handling for partial failure and rerun safety.
- Reject designs that cannot be validated with automated tests.
