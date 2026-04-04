<#
.SYNOPSIS
  Create/show/remove SMB shares, reset share ACLs, connect/logout to remote shares, and drop SMB sessions (client + server).

.DESCRIPTION
  smb.ps1 is a single-file utility for common SMB share operations:
    - show:        list shares, paths, UNC/UNC-by-IP, and share-level ACL entries
    - create:      create/replace ONE share and grant ONE user READ|CHANGE|FULL
    - create-both: create/replace ingress + egress using default paths
    - set-acl:     reset share ACL to exactly what you pass (single or multiple grants)
    - remove:      remove ONE share
    - connect:     connect to \\Target\Share as a user (prompts), then open Explorer
    - logout:      drop SMB client sessions to target (net use)
    - drop:        drop SMB client mapping(s) AND/OR close inbound SMB session(s) (Close-SmbSession)
    - disable-adminshares / enable-adminshares: toggle Windows administrative shares persistently

  Notes:
    - Share permissions are *share-level* (Get-SmbShareAccess). You may still need NTFS ACLs.
    - connect/logout use `net use` to avoid mixed-credential issues.
    - drop is for “I need it gone now” cleanup: client mapping removal + server session close.

.PARAMETER Action
  Operation to perform.
  Valid values:
    create, create-both, set-acl, remove, show, connect, logout, drop, disable-adminshares, enable-adminshares, help
  Default: help

.PARAMETER Name
  Share name to operate on (create/remove/set-acl).

.PARAMETER Path
  Local filesystem path for the share (create).

.PARAMETER User
  Account to grant share access to (create/create-both/set-acl single-user mode) or to authenticate as (connect).
  Example: 'P50\gptuser'

.PARAMETER Perm
  Share permission to grant in single-user mode.
  Valid values: READ, CHANGE, FULL
  Default: FULL

.PARAMETER IngressPath
  Path used by create-both for the ingress share.
  Default: D:\ingress

.PARAMETER EgressPath
  Path used by create-both for the egress share.
  Default: D:\egress

.PARAMETER Grants
  Multi-grant mode for set-acl. Each entry must be 'Account:READ|CHANGE|FULL'.
  Example: 'P50\gptuser:READ','P50\hector:FULL'

.PARAMETER Target
  Hostname or IPv4 address for connect/logout/drop.
  Examples: P50, 10.100.0.1

.PARAMETER Share
  Share name used by connect.

.PARAMETER RemotePath
  Used by Action=drop (client-side).
  A specific UNC to remove via Remove-SmbMapping.
  Example: '\\P50\ingress'

.PARAMETER SessionId
  Used by Action=drop (server-side).
  One or more inbound SMB SessionId values to close via Close-SmbSession.
  Example: 2645766963637

.PARAMETER AllClientToTarget
  Used by Action=drop (client-side).
  If set, removes *all* SMB client mappings to -Target.

.PARAMETER AllServerSessions
  Used by Action=drop (server-side).
  If set, closes *all* inbound SMB sessions (Close-SmbSession for each session).

.OUTPUTS
  Console text and formatted tables.

.EXAMPLE
  # Show built-in usage banner (Action defaults to help)
  .\smb.ps1

.EXAMPLE
  # Show shares + UNC + UNC_IP + ACL + connect strings (run locally on the server)
  .\smb.ps1 -Action show

.EXAMPLE
  # Create ingress + egress on the local machine, grant FULL to one user
  .\smb.ps1 -Action create-both -User 'P50\gptuser' -Perm FULL

.EXAMPLE
  # Create a single share and grant CHANGE
  .\smb.ps1 -Action create -Name repo -Path 'D:\repo' -User 'P50\gptuser' -Perm CHANGE

.EXAMPLE
  # Reset share ACL to exactly these users (multi-grant)
  .\smb.ps1 -Action set-acl -Name ingress -Grants 'P50\gptuser:READ','P50\hector:FULL'

.EXAMPLE
  # Connect from HQ -> P50 ingress using hostname
  .\smb.ps1 -Action connect -Target P50 -Share ingress -User 'P50\gptuser'

.EXAMPLE
  # Logout / drop client sessions to target (net use)
  .\smb.ps1 -Action logout -Target P50


.EXAMPLE
  # DROP: remove ONE client mapping you made (client-side)
  .\smb.ps1 -Action drop -RemotePath '\\P50\ingress'

.EXAMPLE
  # DROP: remove ALL client mappings to a target (client-side)
  .\smb.ps1 -Action drop -Target P50 -AllClientToTarget

.EXAMPLE
  # DROP: close ONE inbound SMB session to YOUR host (server-side)
  .\smb.ps1 -Action drop -SessionId 2645766963637

.EXAMPLE
  # DROP: close multiple inbound SMB sessions (server-side)
  .\smb.ps1 -Action drop -SessionId 2645766963637,2645766964001

.EXAMPLE
  # DROP: do both (remove mapping + close inbound session)
  .\smb.ps1 -Action drop -RemotePath '\\P50\ingress' -SessionId 2645766963637

.EXAMPLE
  # Verify (manual)
  Get-SmbConnection | ft ServerName,ShareName,UserName,NumOpens
  Get-SmbSession    | ft ClientComputerName,ClientUserName,NumOpens,SessionId

.NOTES
  Help rendering:
    - To see this comment-based help reliably, call Get-Help with the script path:
        Get-Help .\smb.ps1 -Full
        Get-Help .\smb.ps1 -Examples

  Admin share toggling:
    - Workstation uses AutoShareWks; Server/DC uses AutoShareServer.
    - The script restarts LanmanServer to apply immediately.
#>
#Requires -RunAsAdministrator
param(
  [ValidateSet("create","create-both","set-acl","remove","show","connect","logout","drop","disable-adminshares","enable-adminshares","help")]
  [string]$Action = "help",

  # Share management
  [string]$Name,
  [string]$Path,
  [string]$User,
  [ValidateSet("READ","CHANGE","FULL")]
  [string]$Perm = "FULL",
  [string]$IngressPath = "D:\ingress",
  [string]$EgressPath  = "D:\egress",
  [string[]]$Grants,

  # Connect/logout
  [string]$Target,
  [string]$Share
  ,
  # Drop (client + server)
  [string]$RemotePath,
  [UInt64[]]$SessionId,
  [switch]$AllClientToTarget,
  [switch]$AllServerSessions
)

$ErrorActionPreference = "Stop"

# --------helper functions ----------
function Show-Help {
@"
smb.ps1

Actions:
  show
    Table of shares + UNC + UNC_IP + connect strings + share ACL entries.

  create
    Create/replace one share and grant one user share permission.
    Required: -Name -Path -User [-Perm READ|CHANGE|FULL]

  create-both
    Create/replace ingress + egress (defaults D:\ingress, D:\egress).
    Required: -User [-Perm READ|CHANGE|FULL]
    Optional: -IngressPath, -EgressPath

  set-acl
    RESET share-level permissions to exactly what you pass.
    Mode A (single):  -Name <share> -User <acct> -Perm READ|CHANGE|FULL
    Mode B (multi):   -Name <share> -Grants 'acct:READ','acct2:FULL'

  disable-adminshares / enable-adminshares
    Toggle Windows administrative shares (C$, ADMIN$, etc.) persistently.
    Workstation (P50/Win10): sets HKLM...\LanmanServer\Parameters\AutoShareWks = 0|1
    Server (HQ/WinServer):   sets HKLM...\LanmanServer\Parameters\AutoShareServer = 0|1
    Applies immediately by restarting the LanmanServer service.
    Usage:
      -Action disable-adminshares
      -Action enable-adminshares

  remove
    Remove one share.
    Required: -Name

  connect
    Connect to \\Target\Share as -User (password prompt), open Explorer.
    Required: -Target -Share <name> -User

  logout
    Drop SMB client sessions to -Target (net use).
    Required: -Target

  drop
    Immediate SMB cleanup (client + server). Use one or more:
      Client-side (connections you initiated):
        -RemotePath '\\HOST\share'         (Remove-SmbMapping for one mapping)
        -Target HOST -AllClientToTarget    (Remove-SmbMapping for all mappings to host)
      Server-side (inbound sessions to your shares):
        -SessionId <id[,id2,...]>          (Close-SmbSession for specific session(s))
        -AllServerSessions                 (Close-SmbSession for every current inbound session)

    Notes:
      - Closing inbound sessions requires admin and will kick the remote client off.
      - Removing a client mapping drops your connection but does NOT stop the server from listening on 445.

Examples:
  .\smb.ps1 -Action show
  .\smb.ps1 -Action create-both -User P50\gptuser -Perm FULL
  .\smb.ps1 -Action set-acl -Name ingress -Grants 'P50\gptuser:READ','P50\hector:FULL'
  .\smb.ps1 -Action connect -Target P50 -Share ingress -User P50\gptuser
  .\smb.ps1 -Action disable-adminshares
  .\smb.ps1 -Action enable-adminshares
  .\smb.ps1 -Action logout -Target P50
  .\smb.ps1 -Action remove -Name 'ingress'

  # Drop ONE client mapping you made:
  .\smb.ps1 -Action drop -RemotePath '\\P50\ingress'

  # Drop ALL client mappings to P50:
  .\smb.ps1 -Action drop -Target P50 -AllClientToTarget

  # Close ONE inbound SMB session to your host:
  .\smb.ps1 -Action drop -SessionId 2645766963637

  # Verify:
  Get-SmbConnection | ft ServerName,ShareName,UserName,NumOpens
  Get-SmbSession    | ft ClientComputerName,ClientUserName,NumOpens,SessionId
"@ | Write-Host
}

function Ensure-Folder([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) {
    New-Item -ItemType Directory -Path $p -Force | Out-Null
  }
}

function Remove-ShareIfExists([string]$n) {
  $s = Get-SmbShare -Name $n -ErrorAction SilentlyContinue
  if ($s) { Remove-SmbShare -Name $n -Force }
}

function New-ShareWithPerm([string]$n,[string]$p,[string]$u,[string]$perm) {
  Ensure-Folder $p
  Remove-ShareIfExists $n

  switch ($perm) {
    "READ"   { New-SmbShare -Name $n -Path $p -ReadAccess   $u | Out-Null }
    "CHANGE" { New-SmbShare -Name $n -Path $p -ChangeAccess $u | Out-Null }
    "FULL"   { New-SmbShare -Name $n -Path $p -FullAccess   $u | Out-Null }
  }

  Set-SmbShare -Name $n -FolderEnumerationMode AccessBased -ErrorAction SilentlyContinue | Out-Null
  Write-Host "[OK] \\$env:COMPUTERNAME\$n -> $p ($perm for $u)"
}

function Set-ShareAcl([string]$n, [string]$u, [string]$perm, [string[]]$grants) {
  $s = Get-SmbShare -Name $n -ErrorAction SilentlyContinue
  if (-not $s) { throw "Share '$n' not found." }

  $desired = @()
  if ($grants -and $grants.Count -gt 0) {
    $desired = $grants
  } else {
    if (-not $u) { throw "Missing -User (or provide -Grants)." }
    $desired = @("${u}:$perm")
  }

  # Revoke ALL existing Allow entries
  $allow = Get-SmbShareAccess -Name $n -ErrorAction Stop |
           Where-Object { $_.AccessControlType -eq "Allow" }

  foreach ($a in $allow) {
    try { Revoke-SmbShareAccess -Name $n -AccountName $a.AccountName -Force | Out-Null } catch { }
  }

  # Apply ONLY desired entries
  foreach ($g in $desired) {
    if ($g -notmatch '^(.*?):(READ|CHANGE|FULL)$') {
      throw "Bad grant '$g'. Expected 'Account:READ|CHANGE|FULL' (e.g. 'P50\gptuser:READ')."
    }
    $acct = $Matches[1]
    $p    = $Matches[2]

    switch ($p) {
      "READ"   { Grant-SmbShareAccess -Name $n -AccountName $acct -AccessRight Read   -Force | Out-Null }
      "CHANGE" { Grant-SmbShareAccess -Name $n -AccountName $acct -AccessRight Change -Force | Out-Null }
      "FULL"   { Grant-SmbShareAccess -Name $n -AccountName $acct -AccessRight Full   -Force | Out-Null }
    }
  }

  Write-Host "[OK] Reset share ACL: \\$env:COMPUTERNAME\$n -> ONLY ($($desired -join ', '))"
}

function Get-BestIPv4ForLocalHost {
  $hn = $env:COMPUTERNAME
  try {
    $ip = [System.Net.Dns]::GetHostAddresses($hn) |
          Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
          Select-Object -First 1
    if ($ip) { return $ip.IPAddressToString }
  } catch { }

  try {
    $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
          Where-Object {
            $_.IPAddress -and
            $_.IPAddress -ne '127.0.0.1' -and
            $_.PrefixOrigin -ne 'WellKnown' -and
            $_.IPAddress -notlike '169.254.*'
          } |
          Select-Object -First 1
    if ($ip) { return $ip.IPAddress }
  } catch { }

  return ""
}

function Resolve-TargetIPv4([string]$t) {
  if ($t -match '^\d{1,3}(\.\d{1,3}){3}$') { return $t }
  try {
    $ip = [System.Net.Dns]::GetHostAddresses($t) |
          Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
          Select-Object -First 1
    if ($ip) { return $ip.IPAddressToString }
  } catch { }
  return ""
}

function SMB-Connect([string]$t,[string]$sh,[string]$u) {
  if ($sh -match '[\\/]') { throw "Bad -Share '$sh'. Pass only the share name (for example: ingress)." }
  $unc = "\\$t\$sh"

  cmd /c "net use \\$t\* /delete /y" | Out-Null
  cmd /c "net use \\$t\IPC$ /user:$u *" | Out-Null

  Start-Process explorer.exe $unc
  Write-Host "[OK] Connected + opened $unc as $u (use logout when done)."
}

function SMB-Logout([string]$t) {
  cmd /c "net use \\$t\* /delete /y" | Out-Null
  cmd /c "net use \\$t\IPC$ /delete /y" | Out-Null
  Write-Host "[OK] Disconnected SMB sessions to \\$t"
}

function Get-AutoShareRegName {
  $os = Get-CimInstance Win32_OperatingSystem
  if ($os.ProductType -eq 1) { return "AutoShareWks" }
  return "AutoShareServer"
}

function Set-AdminSharesEnabled([bool]$enable) {
  $regName = Get-AutoShareRegName
  $value   = if ($enable) { 1 } else { 0 }

  New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    -Name $regName -PropertyType DWord -Value $value -Force | Out-Null

  Restart-Service LanmanServer -Force

  $state = if ($enable) { "ENABLED" } else { "DISABLED" }
  Write-Host "[OK] Administrative shares $state on $env:COMPUTERNAME ($regName=$value)."
}

function SMB-Drop {
  param(
    [string]$Target,
    [string]$RemotePath,
    [UInt64[]]$SessionId,
    [switch]$AllClientToTarget,
    [switch]$AllServerSessions
  )

  $did = $false

  # ---- client-side: remove mapping(s) you initiated ----
  if ($RemotePath) {
    # Normalize \\\\host\\share input
    if ($RemotePath -notmatch '^\\\\[^\\]+\\[^\\]+') { throw "Bad -RemotePath '$RemotePath'. Expected '\\\\HOST\\share'." }
    try {
      Remove-SmbMapping -RemotePath $RemotePath -Force -ErrorAction Stop
      Write-Host "[OK] Removed SMB mapping: $RemotePath"
      $did = $true
    } catch {
      throw "Remove-SmbMapping failed for $RemotePath : $($_.Exception.Message)"
    }
  }

  if ($AllClientToTarget) {
    if (-not $Target) { throw "drop: -AllClientToTarget requires -Target." }
    $maps = @(Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$Target\*" })
    if ($maps.Count -eq 0) {
      Write-Host "[OK] No SMB mappings found to \\$Target\*"
    } else {
      foreach ($m in $maps) {
        try { Remove-SmbMapping -RemotePath $m.RemotePath -Force -ErrorAction Stop; Write-Host "[OK] Removed SMB mapping: $($m.RemotePath)" }
        catch { Write-Host "[WARN] Failed removing mapping $($m.RemotePath): $($_.Exception.Message)" }
      }
    }
    $did = $true
  }

  # ---- server-side: close inbound SMB session(s) to your shares ----
  if ($SessionId -and $SessionId.Count -gt 0) {
    foreach ($sid in $SessionId) {
      try {
        Close-SmbSession -SessionId $sid -Force -ErrorAction Stop
        Write-Host "[OK] Closed inbound SMB session: $sid"
        $did = $true
      } catch {
        Write-Host "[WARN] Close-SmbSession failed for $sid : $($_.Exception.Message)"
      }
    }
  }

  if ($AllServerSessions) {
    $sess = @(Get-SmbSession -ErrorAction SilentlyContinue)
    if ($sess.Count -eq 0) {
      Write-Host "[OK] No inbound SMB sessions found (Get-SmbSession empty)."
    } else {
      foreach ($s in $sess) {
        try {
          Close-SmbSession -SessionId $s.SessionId -Force -ErrorAction Stop
          Write-Host "[OK] Closed inbound SMB session: $($s.SessionId) ($($s.ClientUserName) @ $($s.ClientComputerName))"
        } catch {
          Write-Host "[WARN] Failed closing session $($s.SessionId): $($_.Exception.Message)"
        }
      }
    }
    $did = $true
  }

  if (-not $did) {
    throw "drop: nothing to do. Use -RemotePath OR (-Target -AllClientToTarget) OR -SessionId OR -AllServerSessions."
  }

  # ---- verification snapshot ----
  Write-Host "`nVERIFY (post-drop):"
  try {
    Get-SmbConnection | Format-Table ServerName,ShareName,UserName,NumOpens -AutoSize
  } catch { Write-Host "(Get-SmbConnection failed: $($_.Exception.Message))" }

  try {
    Get-SmbSession | Format-Table ClientComputerName,ClientUserName,NumOpens,SessionId -AutoSize
  } catch { Write-Host "(Get-SmbSession failed: $($_.Exception.Message))" }
}

# ---- main ----
if ($Action -eq "help") { Show-Help; exit 0 }

if ($Action -eq "show") {
  $hostname = $env:COMPUTERNAME
  $localIP = Get-BestIPv4ForLocalHost

  $rows = foreach ($s in (Get-SmbShare | Sort-Object Name)) {
    $uncHost = "\\$hostname\$($s.Name)"
    $uncIP   = if ($localIP) { "\\$localIP\$($s.Name)" } else { "" }
    $connect = ".\smb.ps1 -Action connect -Target $hostname -Share $($s.Name) -User <DOMAIN\User>"

    [pscustomobject]@{
      Share      = "=== $($s.Name) ==="
      Path       = $s.Path
      UNC        = $uncHost
      UNC_IP     = $uncIP
      ConnectCmd = $connect
      Account    = ""
      Type       = ""
      Right      = ""
    }

    $acl = @(Get-SmbShareAccess -Name $s.Name -ErrorAction SilentlyContinue)
    if ($acl.Count -eq 0) {
      [pscustomobject]@{
        Share=""; Path=""; UNC=""; UNC_IP=""; ConnectCmd=""
        Account="(no entries)"; Type=""; Right=""
      }
      continue
    }

    foreach ($a in ($acl | Sort-Object AccountName, AccessControlType, AccessRight)) {
      [pscustomobject]@{
        Share=""; Path=""; UNC=""; UNC_IP=""; ConnectCmd=""
        Account=$a.AccountName; Type=$a.AccessControlType; Right=$a.AccessRight
      }
    }
  }

  $rows | Format-Table -Auto
  exit 0
}

if ($Action -eq "remove") {
  if (-not $Name) { Show-Help; throw "Missing -Name for remove." }
  Remove-ShareIfExists $Name
  Write-Host "[OK] Removed share '$Name' (if it existed)."
  exit 0
}

if ($Action -eq "create") {
  if (-not $Name -or -not $Path -or -not $User) { Show-Help; throw "Missing -Name/-Path/-User for create." }
  New-ShareWithPerm -n $Name -p $Path -u $User -perm $Perm
  exit 0
}

if ($Action -eq "create-both") {
  if (-not $User) { Show-Help; throw "Missing -User for create-both." }
  New-ShareWithPerm -n "ingress" -p $IngressPath -u $User -perm $Perm
  New-ShareWithPerm -n "egress"  -p $EgressPath  -u $User -perm $Perm
  exit 0
}

if ($Action -eq "set-acl") {
  if (-not $Name) { Show-Help; throw "Missing -Name for set-acl." }
  Set-ShareAcl -n $Name -u $User -perm $Perm -grants $Grants
  exit 0
}

if ($Action -eq "connect") {
  if (-not $Target -or -not $Share -or -not $User) { Show-Help; throw "Missing -Target/-Share/-User for connect." }
  SMB-Connect -t $Target -sh $Share -u $User
  exit 0
}

if ($Action -eq "logout") {
  if (-not $Target) { Show-Help; throw "Missing -Target for logout." }
  SMB-Logout -t $Target
  exit 0
}

if ($Action -eq "drop") {
  SMB-Drop -Target $Target -RemotePath $RemotePath -SessionId $SessionId -AllClientToTarget:$AllClientToTarget -AllServerSessions:$AllServerSessions
  exit 0
}

if ($Action -eq "disable-adminshares") {
  Set-AdminSharesEnabled -enable:$false
  exit 0
}

if ($Action -eq "enable-adminshares") {
  Set-AdminSharesEnabled -enable:$true
  exit 0
}

Show-Help
exit 0
