# Integration Request — <Batch number/title>

## Role owner
<researchscientist|aiengineer|publisher|operator|other>

## Workspace root
/home/researchscientist/workspace

## Batch source

```text
Track: skeleton|organ
Batch slug: <slug>
Postcheck path: <path>
Companion path: <path>
Dev recording path: <path>
```

## Commands to expose

```bash
<safe local command>
```

## Python packages needed

- <package or none>

## Environment variables needed

- <name only, no value>

## Config integration requested

- <health check|role alias|lv profile|workflow step|status command|dry-run launcher|mount/output validation|none>

## Smoke check

```bash
<safe dry-run/local smoke command>
```

## Output contract

```text
<output file or schema>
```

## Safety boundaries

```text
No secrets.
No broad bootstrap.
No live remote/provider job unless explicitly human-gated.
Do not edit config directly from project batch.
```

## Open questions

- <question or none>
