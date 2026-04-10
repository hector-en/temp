# Pester 3 Cheat Sheet

## Pattern
1. Dot-source implementation file in `Describe`.
2. Use `Mock` for external cmdlets.
3. Use `Assert-MockCalled` for side-effect verification.
4. Use `Should Be` assertions for returned objects.

## Example
```powershell
Describe "FunctionName" {
    . "$PSScriptRoot\..\configure_hq.next.ps1"

    Mock Get-Disk { @() }

    It "returns an empty list when no disks are found" {
        $result = Get-HqAttachedDisk
        $result.Count | Should Be 0
        Assert-MockCalled Get-Disk -Times 1
    }
}
```
