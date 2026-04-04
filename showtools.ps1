param(
  [string]$ToolsPath = $PSScriptRoot
)

$extensions = @(".ps1", ".cmd", ".bat")

if (-not (Test-Path -LiteralPath $ToolsPath)) {
  Write-Host "[tools] Path not found: $ToolsPath" -ForegroundColor Yellow
  return
}

$items = Get-ChildItem -LiteralPath $ToolsPath -File |
  Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() } |
  Sort-Object Name

if (-not $items) {
  Write-Host "[tools] No script files found in $ToolsPath" -ForegroundColor Yellow
  return
}

Write-Host ""
Write-Host "=== Tools Scripts ===" -ForegroundColor Cyan
$items | ForEach-Object { Write-Host (" - {0}" -f $_.Name) -ForegroundColor Gray }
Write-Host ""
