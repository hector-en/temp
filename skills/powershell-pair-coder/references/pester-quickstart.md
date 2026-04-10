# Pester Quickstart

## Core Blocks
- `Describe`: suite for a function/module.
- `Context`: scenario grouping.
- `It`: single expected behavior.

## Common Assertions
- `value | Should Be expected`
- `{ command } | Should Throw`

## Mocks
- `Mock CmdletName { ... }`
- `Assert-MockCalled CmdletName -Times 1`

## Run Tests
```powershell
Invoke-Pester -Script .\tests\configure_hq.next.Tests.ps1 -PassThru
```
