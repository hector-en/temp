param(
    [Parameter(Mandatory = $true)]
    [string]$Increment,

    [Parameter(Mandatory = $true)]
    [ValidateSet('wip', 'blocked', 'dead-end', 'done')]
    [string]$Status,

    [Parameter(Mandatory = $true)]
    [string]$Message,

    [string]$StashRef = '',

    [string]$Notes = '',

    [string]$LedgerPath = 'workflow/stash-memory.yaml'
)

$timestamp = (Get-Date).ToString('s')
$ledgerDir = Split-Path -Parent $LedgerPath

if ($ledgerDir -and -not (Test-Path $ledgerDir)) {
    New-Item -ItemType Directory -Path $ledgerDir | Out-Null
}

if (-not (Test-Path $LedgerPath)) {
@"
schema_version: 1
project: configure-hq
global:
  current_focus: ""
  overall_status: active
  last_reviewed: ""
  stakeholder_feedback: []
increments: []
stash_entries:
"@ | Set-Content -Path $LedgerPath
}

@"
  - timestamp: "$timestamp"
    increment: "$Increment"
    status: "$Status"
    stash_ref: "$StashRef"
    message: "$Message"
    notes: "$Notes"
"@ | Add-Content -Path $LedgerPath

Write-Output "Recorded stash state in $LedgerPath"
