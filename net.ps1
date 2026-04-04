#Requires -RunAsAdministrator
[CmdletBinding()]
param(
  [switch]$Help,
  [int]$Top = 50,
  [switch]$ShowProcTruth,
  [switch]$ShowPersistence,
  [switch]$ShowRecentLogons,
  [int]$RecentLogonsHours = 4,
  [string]$LabIfaceNameLike = 'HQ-hostonly'
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Show-Help {
  @"
net.ps1

What it does:
  - LISTENERS: TCP listening + UDP endpoints
  - ESTABLISHED: SMB subset + Internet subset
  - SMB cmdlets: Get-SmbConnection / Get-SmbSession / Get-SmbOpenFile
  - PROCESS TRUTH (optional): Path + signature + parent + command line
  - PERSISTENCE (optional): tasks + run keys + services
  - RECENT LOGONS (optional): Security 4624 parsed from XML (no truncation)
  - LAB IFACE CHECK: listeners bound to lab NIC IP(s)

Usage:
  .\net.ps1
  .\net.ps1 -Top 25
  .\net.ps1 -Top 50 -ShowProcTruth
  .\net.ps1 -Top 50 -ShowPersistence
  .\net.ps1 -Top 50 -ShowRecentLogons -RecentLogonsHours 12
  .\net.ps1 -LabIfaceNameLike 'HQ-hostonly' -Top 50 -ShowProcTruth -ShowPersistence -ShowRecentLogons

Tip (PowerShell Help):
  Get-Help .\net.ps1 -Full
  Get-Help .\net.ps1 -Examples
"@ | Write-Host
}

$legacyPath = Join-Path $PSScriptRoot "net.ps1"
if (-not (Test-Path -LiteralPath $legacyPath)) {
  throw "Legacy script not found: $legacyPath"
}

if ($Help -or $PSBoundParameters.Count -eq 0) {
  Show-Help
  exit 0
}

& $legacyPath @PSBoundParameters
exit $LASTEXITCODE
