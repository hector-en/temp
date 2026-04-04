$profilePath = $PROFILE.CurrentUserCurrentHost
$showScript = Join-Path $PSScriptRoot "showtools.ps1"

$startMarker = "# >>> tools-autorun >>>"
$endMarker = "# <<< tools-autorun <<<"
$block = @"
$startMarker
if (Test-Path -LiteralPath '$showScript') {
  & '$showScript'
}
$endMarker
"@

$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path -LiteralPath $profileDir)) {
  New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path -LiteralPath $profilePath)) {
  New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$raw = Get-Content -LiteralPath $profilePath -Raw
if ($raw -match [regex]::Escape($startMarker)) {
  $pattern = "(?s)$([regex]::Escape($startMarker)).*?$([regex]::Escape($endMarker))"
  $updated = [regex]::Replace($raw, $pattern, $block.TrimEnd())
  Set-Content -LiteralPath $profilePath -Value $updated
  Write-Host "[i] Updated existing tools autorun block in $profilePath" -ForegroundColor DarkGray
} else {
  $prefix = if ([string]::IsNullOrWhiteSpace($raw)) { "" } else { "`r`n" }
  Add-Content -LiteralPath $profilePath -Value ($prefix + $block.TrimEnd() + "`r`n")
  Write-Host "[i] Added tools autorun block to $profilePath" -ForegroundColor DarkGray
}

Write-Host "[i] Restart PowerShell to see your tools list automatically." -ForegroundColor DarkGray
