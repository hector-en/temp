param(
    [Parameter(Mandatory = $true)]
    [string]$Name
)

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$scriptPath = Join-Path $root "$Name.ps1"
$testDir = Join-Path $root "tests"
$testPath = Join-Path $testDir "$Name.Tests.ps1"

if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir | Out-Null
}

if (-not (Test-Path $scriptPath)) {
    @"
function Invoke-$Name {
    [CmdletBinding()]
    param()

    throw 'Not implemented.'
}
"@ | Set-Content -Path $scriptPath -NoNewline
}

if (-not (Test-Path $testPath)) {
    @"
Describe '$Name' {
    . "`$PSScriptRoot\..\$Name.ps1"

    It 'has a failing placeholder test' {
        { Invoke-$Name } | Should Throw
    }
}
"@ | Set-Content -Path $testPath -NoNewline
}

Write-Output "Scaffolded $scriptPath and $testPath"
