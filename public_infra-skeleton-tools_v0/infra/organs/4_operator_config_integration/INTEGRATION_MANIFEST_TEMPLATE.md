# Integration Manifest — <skeleton|organ|mixed> evidence set

## Source evidence

| Track | Batch | Postcheck | Integration request | Companion | Status |
|---|---|---|---|---|---|
| skeleton|organ | <slug> | <path> | <path> | <path> | complete/partial/blocked |

## Candidate config hooks

| Hook type | Target role | Proposed name | Source batch | Command/artifact | Status |
|---|---|---|---|---|---|
| role alias | researchscientist | <name> | <slug> | <command> | planned/deferred |

## Python/lv profile needs

| Role | Profile/group | Packages | Source batch | Notes |
|---|---|---|---|---|
| researchscientist | <profile> | <packages> | <slug> | <notes> |

## Workflow/status/health needs

| Type | Proposed exposure | Safe command | Output contract | Source batch |
|---|---|---|---|---|
| health check | <name> | <command --dry-run> | <artifact> | <slug> |

## Deferred or rejected integrations

| Source batch | Request | Reason deferred/rejected |
|---|---|---|
| <slug> | <request> | <reason> |

## Generated config-integration batches

| Batch | Scope | Evidence consumed | Generated zip/path | Status |
|---|---|---|---|---|
| config-integration/01-... | <scope> | <evidence> | <path> | planned |
