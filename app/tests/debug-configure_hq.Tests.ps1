param(
    [string]$TestPath = "$PSScriptRoot\configure_hq.Tests.ps1"
)

Set-StrictMode -Version Latest

Import-Module Pester -ErrorAction Stop

# Launch Pester from a normal script so VS Code can break inside both the test
# file and the implementation file when breakpoints are set.
Invoke-Pester -Script $TestPath
