[CmdletBinding(SupportsShouldProcess = $true)]
<#
.SYNOPSIS
Configures Windows host forwarding and portproxy so Hyper-V host-only VMs can reach WSL services.

.DESCRIPTION
This script bridges connectivity from a Hyper-V host-only network (for example HQ-HOSTONLY)
to WSL2 by:
- Detecting host-only and WSL interface IPv4 addresses.
- Enabling IPv4 forwarding on both interfaces.
- Enabling global Windows IP routing (IPEnableRouter=1).
- Creating/refreshing netsh portproxy mappings from ListenIP:Port to current WSL guest IP:Port.
- Printing info about firewall handling when third-party firewalls (for example Kaspersky) are used.

It also prints the persistent route command that should be run inside each HQ VM.

.PARAMETER HostOnlySwitchName
Name of the Hyper-V host-only switch. The script derives interface alias as:
vEthernet (<HostOnlySwitchName>).

.PARAMETER WSLIfAlias
Windows interface alias for the WSL virtual NIC (default: vEthernet (WSL)).

.PARAMETER Ports
TCP ports to forward from ListenIP to current WSL guest IP.

.PARAMETER ListenIP
IPv4 address that portproxy listens on. If omitted, defaults to the host-only gateway IP
detected on vEthernet (<HostOnlySwitchName>).

.PARAMETER WSLGuestIP
WSL guest IPv4 to use as portproxy connectaddress. If omitted, the script attempts host-side
discovery from the neighbor table on vEthernet (WSL) and does not call wsl.exe.

.PARAMETER AutoRecoverWSLLock
If distro-based IP lookup hits Wsl/Service/CreateInstance/MountDisk/HCS/ERROR_SHARING_VIOLATION,
automatically runs:
- wsl --shutdown
- restart vmcompute and LxssManager
then retries lookup once.

.EXAMPLE
.\wsl.ps1
Runs with defaults:
- HostOnlySwitchName: HQ-HOSTONLY
- WSLIfAlias: vEthernet (WSL)
- Ports: 8080,8000,5000
- ListenIP: auto-detected host-only gateway IP

.EXAMPLE
.\wsl.ps1 -Ports 3000,5173 -WhatIf
Shows what would change for ports 3000 and 5173 without applying changes.

.EXAMPLE
.\wsl.ps1 -HostOnlySwitchName HQ-HOSTONLY -ListenIP 192.168.99.1 -Ports 8080,8000,5000
Forces a specific listen IP and forwarded port list.

.EXAMPLE
.\wsl.ps1 -WSLGuestIP 172.27.248.45 -Ports 8080,8000,5000
Uses an explicit WSL guest IPv4 and skips auto-discovery.

.EXAMPLE
.\wsl.ps1 -AutoRecoverWSLLock
Enables automatic recovery + retry when WSL VHDX mount is blocked by sharing violation.

.NOTES
Requires an elevated PowerShell session (Run as Administrator).
Use Get-Help for docs:
Get-Help .\tools\wsl.ps1 -Detailed
Get-Help .\tools\wsl.ps1 -Examples
Get-Help .\tools\wsl.ps1 -Full
#>
param(
  [string]$HostOnlySwitchName = "HQ-HOSTONLY",
  [string]$WSLIfAlias = "vEthernet (WSL)",
  [int[]]$Ports = @(8000, 22),
  [string]$ListenIP,
  [string]$WSLGuestIP,
  [switch]$AutoRecoverWSLLock
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }
function Is-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $pr = New-Object Security.Principal.WindowsPrincipal($id)
  return $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Get-FirstIPv4([string]$InterfaceAlias) {
  Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
      $_.IPAddress -match '^\d+\.\d+\.\d+\.\d+$' -and
      $_.IPAddress -ne '0.0.0.0' -and
      $_.IPAddress -notlike '169.254.*'
    } |
    Sort-Object PrefixLength,IPAddress |
    Select-Object -First 1
}
function PrefixToMask([int]$p) {
  $mask = [uint32]0
  for ($i=0; $i -lt $p; $i++) { $mask = $mask -bor (1 -shl (31-$i)) }
  $b = [BitConverter]::GetBytes($mask)
  return "$($b[3]).$($b[2]).$($b[1]).$($b[0])"
}
function Convert-IPv4ToUInt32([string]$ip) {
  $bytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
  return [uint32](($bytes[0] -shl 24) -bor ($bytes[1] -shl 16) -bor ($bytes[2] -shl 8) -bor $bytes[3])
}
function Test-IPv4InPrefix([string]$IPAddress, [string]$Network, [int]$PrefixLength) {
  $ipU  = Convert-IPv4ToUInt32 $IPAddress
  $netU = Convert-IPv4ToUInt32 $Network
  $mask = [uint32]0
  for ($i = 0; $i -lt $PrefixLength; $i++) { $mask = $mask -bor (1 -shl (31 - $i)) }
  return (($ipU -band $mask) -eq ($netU -band $mask))
}
function Get-IPv4Network([string]$IPAddress, [int]$PrefixLength) {
  $ipBytes = [System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()
  $maskBytes = New-Object byte[] 4
  $remaining = $PrefixLength
  for ($i = 0; $i -lt 4; $i++) {
    if ($remaining -ge 8) {
      $maskBytes[$i] = 255
      $remaining -= 8
    } elseif ($remaining -gt 0) {
      $maskBytes[$i] = [byte](256 - [Math]::Pow(2, 8 - $remaining))
      $remaining = 0
    } else {
      $maskBytes[$i] = 0
    }
  }

  $netBytes = New-Object byte[] 4
  for ($i = 0; $i -lt 4; $i++) {
    $netBytes[$i] = [byte]($ipBytes[$i] -band $maskBytes[$i])
  }

  return [System.Net.IPAddress]::new($netBytes).ToString()
}
function Select-WSLDistroName {
  $raw = (& wsl.exe --list --quiet 2>&1 | Out-String)
  if (-not $raw) { return $null }
  if ($raw -match 'ERROR_SHARING_VIOLATION') {
    Write-Host "WSL reported VHDX sharing violation while listing distros." -ForegroundColor Yellow
    Write-Host "Tip: rerun with -AutoRecoverWSLLock to auto-restart WSL services and retry once." -ForegroundColor DarkYellow
    return $null
  }

  $distros = $raw -split "`r?`n" |
    ForEach-Object { ($_ -replace '[\x00-\x1F]', '').Trim() } |
    Where-Object { $_ } |
    Select-Object -Unique

  if (-not $distros -or $distros.Count -eq 0) { return $null }
  if ($distros.Count -eq 1) { return $distros[0] }

  Write-Host "`nSelect WSL distro for IP lookup:" -ForegroundColor Cyan
  for ($i = 0; $i -lt $distros.Count; $i++) {
    Write-Host ("  [{0}] {1}" -f ($i + 1), $distros[$i]) -ForegroundColor Yellow
  }
  $choice = Read-Host "Enter distro number (or press Enter to skip)"
  if (-not $choice) { return $null }

  $idx = 0
  if (-not [int]::TryParse($choice, [ref]$idx)) { return $null }
  if ($idx -lt 1 -or $idx -gt $distros.Count) { return $null }
  return $distros[$idx - 1]
}
function Invoke-WSLLockRecovery {
  if (-not $PSCmdlet.ShouldProcess("WSL services", "Recover from VHDX sharing violation")) {
    return $false
  }

  & wsl.exe --shutdown 2>$null | Out-Null

  $svc = Get-Service -Name vmcompute -ErrorAction SilentlyContinue
  if ($svc) {
    Stop-Service vmcompute -Force -ErrorAction SilentlyContinue
    Start-Service vmcompute -ErrorAction SilentlyContinue
  }

  $svc = Get-Service -Name LxssManager -ErrorAction SilentlyContinue
  if ($svc) {
    Stop-Service LxssManager -Force -ErrorAction SilentlyContinue
    Start-Service LxssManager -ErrorAction SilentlyContinue
  }
  Start-Sleep -Seconds 1
  return $true
}
function Get-WSLGuestIPv4FromDistro([string]$DistroName, [switch]$TryAutoRecover) {
  $raw = (& wsl.exe -d $DistroName -- hostname -I 2>&1 | Out-String).Trim()
  $ip = ($raw -split '\s+') | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' } | Select-Object -First 1
  if ($ip) {
    return @{ IP = $ip; Raw = $raw; Recovered = $false }
  }

  $isShareViolation = $raw -match 'ERROR_SHARING_VIOLATION'
  if ($isShareViolation -and $TryAutoRecover) {
    Write-Host "Detected WSL VHDX sharing violation. Attempting automatic recovery..." -ForegroundColor Yellow
    $recovered = Invoke-WSLLockRecovery
    if ($recovered) {
      $rawRetry = (& wsl.exe -d $DistroName -- hostname -I 2>&1 | Out-String).Trim()
      $ipRetry = ($rawRetry -split '\s+') | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' } | Select-Object -First 1
      return @{ IP = $ipRetry; Raw = $rawRetry; Recovered = $true }
    }
  }

  return @{ IP = $null; Raw = $raw; Recovered = $false }
}
function Get-PortProxyV4ToV4Entries {
  $raw = (& netsh interface portproxy show v4tov4 2>&1 | Out-String)
  if (-not $raw) { return @() }

  $entries = @()
  foreach ($line in ($raw -split "`r?`n")) {
    if ($line -match '^\s*(\d+\.\d+\.\d+\.\d+)\s+(\d+)\s+(\d+\.\d+\.\d+\.\d+)\s+(\d+)\s*$') {
      $entries += [pscustomobject]@{
        ListenAddress  = $matches[1]
        ListenPort     = [int]$matches[2]
        ConnectAddress = $matches[3]
        ConnectPort    = [int]$matches[4]
      }
    }
  }
  return $entries
}
function Select-PortProxyAction(
  [string]$ListenAddress,
  [int]$ListenPort,
  [string]$CurrentConnectAddress,
  [int]$CurrentConnectPort,
  [string]$SuggestedConnectAddress,
  [int]$SuggestedConnectPort
) {
  Write-Host "`nPortproxy review for ${ListenAddress}:$ListenPort" -ForegroundColor Yellow
  if ($CurrentConnectAddress) {
    Write-Host "  current  : ${CurrentConnectAddress}:$CurrentConnectPort" -ForegroundColor DarkYellow
  } else {
    Write-Host "  current  : (none)" -ForegroundColor DarkYellow
  }
  Write-Host "  suggested: ${SuggestedConnectAddress}:$SuggestedConnectPort" -ForegroundColor Green
  Write-Host "Choose action: [U]pdate (default), [R]emove, [M]anual, [S]tay" -ForegroundColor Cyan
  $choice = (Read-Host "Action").Trim().ToUpperInvariant()
  if (-not $choice) { $choice = "U" }

  switch ($choice) {
    "U" {
      return [pscustomobject]@{
        Mode = "update"
        ConnectAddress = $SuggestedConnectAddress
        ConnectPort = $SuggestedConnectPort
      }
    }
    "R" { return [pscustomobject]@{ Mode = "remove"; ConnectAddress = $null; ConnectPort = $null } }
    "S" { return [pscustomobject]@{ Mode = "stay"; ConnectAddress = $CurrentConnectAddress; ConnectPort = $CurrentConnectPort } }
    "M" {
      $manualIp = (Read-Host "Manual connect IP").Trim()
      $manualPortRaw = (Read-Host "Manual connect port").Trim()
      $manualPort = 0
      if (($manualIp -notmatch '^\d+\.\d+\.\d+\.\d+$') -or (-not [int]::TryParse($manualPortRaw, [ref]$manualPort)) -or $manualPort -lt 1 -or $manualPort -gt 65535) {
        Write-Host "Invalid manual target, defaulting to suggested update." -ForegroundColor Yellow
        return [pscustomobject]@{
          Mode = "update"
          ConnectAddress = $SuggestedConnectAddress
          ConnectPort = $SuggestedConnectPort
        }
      }
      return [pscustomobject]@{
        Mode = "manual"
        ConnectAddress = $manualIp
        ConnectPort = $manualPort
      }
    }
    default {
      Write-Host "Unknown action, defaulting to suggested update." -ForegroundColor Yellow
      return [pscustomobject]@{
        Mode = "update"
        ConnectAddress = $SuggestedConnectAddress
        ConnectPort = $SuggestedConnectPort
      }
    }
  }
}

Write-Section "Route HQ-HOSTONLY <-> WSL via existing vEthernet (WSL) (robust)"

$HOIfAlias  = "vEthernet ($HostOnlySwitchName)"   # e.g. vEthernet (HQ-HOSTONLY)

if (-not (Is-Admin)) {
  throw "Run this script from an elevated PowerShell session (Administrator)."
}

# --- Resolve Host-only gateway (Host IP on HQ-HOSTONLY) robustly ---
$hoIp = Get-FirstIPv4 -InterfaceAlias $HOIfAlias

if (-not $hoIp) {
  Write-Host "Could not find an IPv4 address on '$HOIfAlias' (host-only interface)." -ForegroundColor Yellow
  Write-Host "Debug: Get-NetIPAddress -InterfaceAlias '$HOIfAlias' -AddressFamily IPv4" -ForegroundColor Yellow
  return
}

$HostOnlyGW = $hoIp.IPAddress

# --- Resolve WSL interface IPv4 ---
$wslIp = Get-FirstIPv4 -InterfaceAlias $WSLIfAlias

if (-not $wslIp) {
  Write-Host "Could not find an IPv4 address on '$WSLIfAlias'. Start any WSL2 distro once, then rerun." -ForegroundColor Yellow
  return
}

# --- Determine WSL subnet from interface IP/prefix ---
$wslPlen   = [int]$wslIp.PrefixLength
$wslNet    = Get-IPv4Network -IPAddress $wslIp.IPAddress -PrefixLength $wslPlen
$wslPrefix = "$wslNet/$wslPlen"
$wslMask   = PrefixToMask $wslPlen
if (-not $ListenIP) { $ListenIP = $HostOnlyGW }

# Prefer an existing connected route for this interface/subnet if present.
$existingConnected = Get-NetRoute -InterfaceIndex $wslIp.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
  Where-Object { $_.NextHop -eq "0.0.0.0" -and $_.DestinationPrefix -eq $wslPrefix } |
  Select-Object -First 1
if ($existingConnected) {
  Write-Host "[i] WSL subnet already present as connected route: $wslPrefix" -ForegroundColor DarkGray
} else {
  Write-Host "[i] No exact connected route for $wslPrefix was found; using subnet derived from interface IP/prefix." -ForegroundColor DarkGray
}

Write-Host "[+] Host-only Gate Way (Host IP on $HOIfAlias): $HostOnlyGW" -ForegroundColor Yellow
Write-Host "[+] WSL IPv4 (on $WSLIfAlias): $($wslIp.IPAddress)/$($wslIp.PrefixLength)" -ForegroundColor Yellow
Write-Host "[+] WSL connected prefix: $wslPrefix" -ForegroundColor Yellow
Write-Host "[+] Listen IP for portproxy: $ListenIP" -ForegroundColor Yellow

# --- Enable forwarding on both host interfaces ---
foreach ($ifAlias in @($HOIfAlias, $WSLIfAlias)) {
  $ifState = Get-NetIPInterface -InterfaceAlias $ifAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $ifState) {
    Write-Host "Could not read interface state for '$ifAlias'." -ForegroundColor Yellow
    continue
  }
  if ($ifState.Forwarding -eq "Enabled") {
    Write-Host "[i] IPv4 forwarding already enabled on $ifAlias" -ForegroundColor DarkGray
    continue
  }
  if ($PSCmdlet.ShouldProcess($ifAlias, "Enable IPv4 forwarding")) {
    Set-NetIPInterface -InterfaceAlias $ifAlias -AddressFamily IPv4 -Forwarding Enabled -ErrorAction SilentlyContinue | Out-Null
    Write-Host "[i] Enabled IPv4 forwarding on $ifAlias" -ForegroundColor DarkGray
  }
}

# --- Enable global routing flag ---
$ipEnableRouter = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
  -Name "IPEnableRouter" -ErrorAction SilentlyContinue).IPEnableRouter
if ($ipEnableRouter -eq 1) {
  Write-Host "[i] Global IP routing already enabled (IPEnableRouter=1)" -ForegroundColor DarkGray
} elseif ($PSCmdlet.ShouldProcess("Host", "Enable IP routing (IPEnableRouter=1)")) {
  New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
    -Name "IPEnableRouter" -PropertyType DWord -Value 1 -Force | Out-Null
  Write-Host "[i] Enabled global IP routing (IPEnableRouter=1)" -ForegroundColor DarkGray
}

Write-Section "Portproxy HQ-HOSTONLY -> WSL"

$wslHostIP = $WSLGuestIP
$selectedDistro = $null
if (-not $wslHostIP) {
  $neighbors = Get-NetNeighbor -InterfaceIndex $wslIp.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
      $_.IPAddress -match '^\d+\.\d+\.\d+\.\d+$' -and
      $_.IPAddress -ne $wslIp.IPAddress -and
      $_.State -in @("Reachable", "Stale", "Delay", "Probe", "Permanent") -and
      (Test-IPv4InPrefix -IPAddress $_.IPAddress -Network $wslNet -PrefixLength $wslPlen)
    } |
    Sort-Object @{Expression = {
      switch ($_.State) {
        "Reachable" { 0 }
        "Stale"     { 1 }
        "Delay"     { 2 }
        "Probe"     { 3 }
        default     { 4 }
      }
    }}, IPAddress

  $wslHostIP = $neighbors | Select-Object -ExpandProperty IPAddress -First 1
}

if (-not $wslHostIP) {
  $selectedDistro = Select-WSLDistroName
  if ($selectedDistro) {
    $lookup = Get-WSLGuestIPv4FromDistro -DistroName $selectedDistro -TryAutoRecover:$AutoRecoverWSLLock
    $distroRaw = $lookup.Raw
    $wslHostIP = $lookup.IP
    if (-not $wslHostIP) {
      Write-Host "Could not determine WSL guest IPv4 from distro '$selectedDistro'." -ForegroundColor Yellow
      if ($distroRaw) {
        Write-Host "wsl.exe output: $distroRaw" -ForegroundColor DarkYellow
      }
      if (($distroRaw -match 'ERROR_SHARING_VIOLATION') -and -not $AutoRecoverWSLLock) {
        Write-Host "Tip: rerun with -AutoRecoverWSLLock to auto-restart WSL services and retry once." -ForegroundColor DarkYellow
      }
    } elseif ($lookup.Recovered) {
      Write-Host "[i] Distro IP lookup succeeded after automatic WSL lock recovery." -ForegroundColor DarkGray
    }
  }
}

if (-not $wslHostIP) {
  Write-Host "Could not determine WSL guest IPv4 from host-side data. Skipping portproxy/firewall." -ForegroundColor Yellow
  Write-Host "Tip: pass -WSLGuestIP <ip>, or rerun and select a distro when prompted." -ForegroundColor DarkYellow
} else {
  if ($WSLGuestIP) {
    Write-Host "[+] Using provided WSL guest IP: $wslHostIP" -ForegroundColor Yellow
  } elseif ($selectedDistro) {
    Write-Host "[+] WSL guest IP from distro '$selectedDistro': $wslHostIP" -ForegroundColor Yellow
  } else {
    Write-Host "[+] Auto-discovered WSL guest IP (neighbor table): $wslHostIP" -ForegroundColor Yellow
  }

  $portProxyEntries = Get-PortProxyV4ToV4Entries
  foreach ($p in $Ports) {
    $existing = $portProxyEntries |
      Where-Object { $_.ListenAddress -eq $ListenIP -and $_.ListenPort -eq $p } |
      Select-Object -First 1
    $decision = Select-PortProxyAction `
      -ListenAddress $ListenIP `
      -ListenPort $p `
      -CurrentConnectAddress $(if ($existing) { $existing.ConnectAddress } else { $null }) `
      -CurrentConnectPort $(if ($existing) { $existing.ConnectPort } else { 0 }) `
      -SuggestedConnectAddress $wslHostIP `
      -SuggestedConnectPort $p

    if ($decision.Mode -eq "stay") {
      if ($existing) {
        Write-Host "[i] Keeping existing mapping ${ListenIP}:$p -> $($existing.ConnectAddress):$($existing.ConnectPort)" -ForegroundColor DarkGray
      } else {
        Write-Host "[i] Keeping as-is: no mapping for ${ListenIP}:$p" -ForegroundColor DarkGray
      }
      continue
    }

    if ($decision.Mode -eq "remove") {
      if (-not $existing) {
        Write-Host "[i] No mapping exists to remove for ${ListenIP}:$p" -ForegroundColor DarkGray
      } elseif ($PSCmdlet.ShouldProcess("portproxy ${ListenIP}:$p", "Remove mapping")) {
        & netsh interface portproxy delete v4tov4 listenaddress=$ListenIP listenport=$p | Out-Null
        Write-Host "[i] Portproxy removed ${ListenIP}:$p" -ForegroundColor DarkGray
      }
      continue
    }

    if ($PSCmdlet.ShouldProcess("portproxy ${ListenIP}:$p -> $($decision.ConnectAddress):$($decision.ConnectPort)", "Update mapping")) {
      if ($existing) {
        & netsh interface portproxy delete v4tov4 listenaddress=$ListenIP listenport=$p | Out-Null
      }
      & netsh interface portproxy add v4tov4 `
        listenaddress=$ListenIP listenport=$p `
        connectaddress=$($decision.ConnectAddress) connectport=$($decision.ConnectPort) | Out-Null
      if ($decision.Mode -eq "manual") {
        Write-Host "[i] Portproxy manually set ${ListenIP}:$p -> $($decision.ConnectAddress):$($decision.ConnectPort)" -ForegroundColor DarkGray
      } else {
        Write-Host "[i] Portproxy updated ${ListenIP}:$p -> $($decision.ConnectAddress):$($decision.ConnectPort)" -ForegroundColor DarkGray
      }
    }
  }
}



Write-Host "`n[HQ VM] Add this persistent route (Windows syntax, one-time per VM):" -ForegroundColor Cyan
Write-Host "  route -p add $wslNet mask $wslMask $HostOnlyGW" -ForegroundColor Yellow
Write-Host "  (Routes WSL subnet $wslPrefix via host-only gateway $HostOnlyGW)" -ForegroundColor DarkGray

Write-Host "`nValidation / debug commands:" -ForegroundColor Cyan
Write-Host "  Host: Get-NetIPAddress -InterfaceAlias '$HOIfAlias','$WSLIfAlias' -AddressFamily IPv4" -ForegroundColor Yellow
Write-Host "  Host: Get-NetIPInterface -InterfaceAlias '$HOIfAlias','$WSLIfAlias' -AddressFamily IPv4 | ft InterfaceAlias,Forwarding" -ForegroundColor Yellow
Write-Host "  Host: netsh interface portproxy show v4tov4" -ForegroundColor Yellow
Write-Host "  HQ VM: tracert $($wslIp.IPAddress)   # expected hop1=$HostOnlyGW then likely timeouts for ICMP" -ForegroundColor Yellow
foreach ($p in $Ports) {
  if ($wslHostIP) {
    Write-Host "  WSL: python3 -m http.server $p --bind $wslHostIP" -ForegroundColor DarkGray
  } else {
    Write-Host "  WSL: python3 -m http.server $p --bind <wsl-guest-ip>" -ForegroundColor DarkGray
  }
  Write-Host "  Host: Test-NetConnection $ListenIP -Port $p" -ForegroundColor Yellow
}


Write-Host "`nGet-Help:" -ForegroundColor Cyan
Write-Host "  Get-Help .\tools\wsl.ps1 -Detailed" -ForegroundColor Yellow
Write-Host "  Get-Help .\tools\wsl.ps1 -Examples" -ForegroundColor Yellow
Write-Host "  Get-Help .\tools\wsl.ps1 -Full" -ForegroundColor Yellow


Write-Section "Final Portproxy Table"
$finalEntries = Get-PortProxyV4ToV4Entries |
  Sort-Object ListenAddress,ListenPort

if (-not $finalEntries -or $finalEntries.Count -eq 0) {
  Write-Host "[i] No v4tov4 portproxy entries found." -ForegroundColor DarkGray
} else {
  $finalEntries |
    Select-Object `
      ListenAddress,
      ListenPort,
      ConnectAddress,
      ConnectPort,
      @{Name = "Access service via"; Expression = { "http://$($_.ListenAddress):$($_.ListenPort) (localhost:$($_.ListenPort))" }} |
    Format-Table -AutoSize
}
Write-Host "[i] Windows Firewall rules were not modified by this script." -ForegroundColor DarkGray
Write-Host "[i] Ensure your active firewall (for example Kaspersky) allows inbound TCP on $ListenIP for ports: $($Ports -join ', ')." -ForegroundColor DarkGray
