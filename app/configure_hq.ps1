param(
    [switch]$RunActivation,
    [switch]$RunIdentityRestore,
    [switch]$RunIdentityCleanup,
    [switch]$ExportSecurityPrincipalState,
    [switch]$InstallMissingFeatures,
    [switch]$DiscoverLabVhdChoices,
    [int[]]$TargetDiskNumbers,
    [string]$VmName,
    [string]$MetadataModulePath = (Join-Path $PSScriptRoot 'HqDiskMetadata.psm1'),
    [string]$SecurityStatePath = (Join-Path $PSScriptRoot 'HqSecurityState.json')
)

Set-StrictMode -Version Latest

# ---------------------------------------------------------------------
# Section: run the Lab VHDX discovery helper for the iSCSI workflow
# ---------------------------------------------------------------------

# Main function: show existing child and parent VHDX choices without creating anything yet.
if ($DiscoverLabVhdChoices) {
    $choices = Get-HqLabVhdDiscoveryChoices

    # Explain when the child discovery returned no existing VHDX files.
    if ($choices.ChildChoices.Count -eq 1) {
        Write-HqStatus -Phase 'iSCSI' -Message 'No existing child VHDX files were found under the Lab frontend share.' -Level Warning
    }

    # Show the child VHDX choices for the operator.
    Write-HqStatus -Phase 'iSCSI' -Message 'Discovered child VHDX choices:' -Level Success
    $choices.ChildChoices | Format-Table -AutoSize | Out-Host

    # Explain when the parent discovery returned no existing VHDX files.
    if ($choices.ParentChoices.Count -eq 1) {
        Write-HqStatus -Phase 'iSCSI' -Message 'No existing parent VHDX files were found under the Lab base-image share.' -Level Warning
    }

    # Show the parent VHDX choices for the operator.
    Write-HqStatus -Phase 'iSCSI' -Message 'Discovered parent VHDX choices:' -Level Success
    $choices.ParentChoices | Format-Table -AutoSize | Out-Host

    return $choices
}
# ---------------------------------------------------------------------
# Section: disk discovery, activation, and the main entrypoint
# ---------------------------------------------------------------------

function Write-HqStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $color = switch ($Level) {
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        default { 'White' }
    }

    Write-Host ("[HQ][{0}][{1}] {2}" -f $Phase, $Level.ToUpperInvariant(), $Message) -ForegroundColor $color
}

function Show-HqRunSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Results
    )

    Write-Host ''
    Write-HqStatus -Phase "Summary" -Message "Final disk summary:" -Level Success

    $summaryRows = @(
        foreach ($result in $Results) {
            [pscustomobject]@{
                Disk   = [int]$result.DiskNumber
                Role   = [string]$result.RoleName
                Drive  = [string]$result.DriveLetters
                Expect = [string]$result.ExpectedDriveLetter
                Action = [string]$result.Action
                Identity = if ($result.PSObject.Properties['IdentityAction']) { [string]$result.IdentityAction } else { $null }
                ACL    = if ($result.PSObject.Properties['AclAction']) { [string]$result.AclAction } else { $null }
                SMB    = if ($result.PSObject.Properties['SmbAction']) { [string]$result.SmbAction } else { $null }
                DedupAction = if ($result.PSObject.Properties['DedupAction']) { [string]$result.DedupAction } else { $null }
            }
        }
    )

    $summaryRows | Format-Table -AutoSize | Out-Host

    $smbSummaryRows = @(
        foreach ($result in $Results) {
            if (-not $result.PSObject.Properties['ShareName']) {
                continue
            }

            $shareName = [string]$result.ShareName
            if (-not $shareName) {
                continue
            }

            [pscustomobject]@{
                Role   = [string]$result.RoleName
                Share  = $shareName
                Path   = if ($result.PSObject.Properties['SharePath']) { [string]$result.SharePath } else { $null }
                Action = if ($result.PSObject.Properties['SmbAction']) { [string]$result.SmbAction } else { $null }
            }
        }
    )

    if ($smbSummaryRows.Count -gt 0) {
        Write-Host ''
        Write-HqStatus -Phase "Summary" -Message "Final SMB share summary:" -Level Success
        $smbSummaryRows | Format-Table -AutoSize | Out-Host
    }

    Write-Host ''
    Write-HqStatus -Phase "Summary" -Message "Final access-group summary:" -Level Success
    Get-HqManagedAccessGroupSummary | Format-Table -AutoSize | Out-Host
}

function Show-HqRoleResolutionStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Definitions,

        [Parameter(Mandatory = $true)]
        [object[]]$Results
    )

    # Step: compare configured roles with the roles seen in this run.
    $expectedRoles = @(
        $Definitions |
        Where-Object { $_.RoleName } |
        Select-Object -ExpandProperty RoleName -Unique
    )
    $actualRoles = @(
        $Results |
        Where-Object { $_.RoleName } |
        Select-Object -ExpandProperty RoleName -Unique
    )
    $missingRoles = @($expectedRoles | Where-Object { $actualRoles -notcontains $_ })

    if ($missingRoles.Count -gt 0) {
        Write-HqStatus -Phase "Validation" -Message ("Configured roles not present in this run: {0}" -f ($missingRoles -join ', ')) -Level Warning
    } else {
        Write-HqStatus -Phase "Validation" -Message "All configured roles were present in this run." -Level Success
    }

    # Check: warn when the current drive letters do not match the expected ones.
    $driveMismatches = @(
        foreach ($result in $Results) {
            $expectedDrive = [string]$result.ExpectedDriveLetter
            $actualDrives = @(
                [string]$result.DriveLetters -split ',' |
                ForEach-Object { $_.Trim().ToUpperInvariant() } |
                Where-Object { $_ }
            )

            if ($expectedDrive -and $actualDrives.Count -gt 0 -and ($actualDrives -notcontains $expectedDrive.ToUpperInvariant())) {
                [pscustomobject]@{
                    DiskNumber = [int]$result.DiskNumber
                    RoleName = [string]$result.RoleName
                    ExpectedDrive = $expectedDrive
                    ActualDrives = ($actualDrives -join ',')
                }
            }
        }
    )

    foreach ($mismatch in $driveMismatches) {
        Write-HqStatus -Phase "Validation" -Message ("Disk {0} role '{1}' expected drive '{2}' but found '{3}'." -f `
            $mismatch.DiskNumber, `
            $mismatch.RoleName, `
            $mismatch.ExpectedDrive, `
            $mismatch.ActualDrives) -Level Warning
    }
}

function Get-HqDefaultDiskRoleDefinitions {
    [CmdletBinding()]
    param()

    return @(
        [pscustomobject]@{
            SourceVhd = 'M:\repository1.vhdx'
            VhdName = 'repository1.vhdx'
            RoleName = 'Repository'
            ExpectedDriveLetter = 'R'
            DedupEnabled = $false
        }
        [pscustomobject]@{
            SourceVhd = 'W:\vmdisk.vhdx'
            VhdName = 'vmdisk.vhdx'
            RoleName = 'Lab'
            ExpectedDriveLetter = 'W'
            DedupEnabled = $true
        }
        [pscustomobject]@{
            SourceVhd = 'X:\backup1.vhdx'
            VhdName = 'backup1.vhdx'
            RoleName = 'Backups'
            ExpectedDriveLetter = 'B'
            DedupEnabled = $false
        }
        [pscustomobject]@{
            SourceVhd = 'V:\VHDs\disks\sharedisk.vhdx'
            VhdName = 'sharedisk.vhdx'
            RoleName = 'ShareDrive'
            ExpectedDriveLetter = 'Z'
            DedupEnabled = $false
        }
    )
}

function Get-HqHostDiskMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VmName
    )

    $definitions = @()
    $defaults = Get-HqDefaultDiskRoleDefinitions

    $attachments = @(Get-VMHardDiskDrive -VMName $VmName -ErrorAction Stop)
    $attachmentByName = @{}

    foreach ($attachment in $attachments) {
        $path = [string]$attachment.Path
        $fileName = [System.IO.Path]::GetFileName($path).ToLowerInvariant()
        $attachmentByName[$fileName] = $path
    }

    foreach ($definition in $defaults) {
        $sourceVhd = [string]$definition.SourceVhd
        $key = [string]$definition.VhdName

        if ($attachmentByName.ContainsKey($key)) {
            $sourceVhd = $attachmentByName[$key]
        }

        $definitions += [pscustomobject]@{
            VmName              = $VmName
            SourceVhd           = $sourceVhd
            VhdName             = [string]$definition.VhdName
            RoleName            = [string]$definition.RoleName
            ExpectedDriveLetter = [string]$definition.ExpectedDriveLetter
            DedupEnabled        = [bool]$definition.DedupEnabled
        }
    }

    return $definitions
}

function Get-HqHostVmNames {
    [CmdletBinding()]
    param()

    return @(
        Get-VMHardDiskDrive -VMName '*' -ErrorAction Stop |
        Select-Object -ExpandProperty VMName -Unique |
        Sort-Object
    )
}

function Test-HqHostMetadataCommandsAvailable {
    [CmdletBinding()]
    param()

    return [bool](Get-Command Get-VMHardDiskDrive -ErrorAction SilentlyContinue)
}

function Select-HqHostVmName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$VmNames
    )

    if (@($VmNames).Count -eq 0) {
        throw "No Hyper-V VMs were found."
    }

    Write-HqStatus -Phase "Host" -Message "Select the Hyper-V VM to process:"
    for ($i = 0; $i -lt $VmNames.Count; $i++) {
        Write-Host ("  [{0}] {1}" -f ($i + 1), $VmNames[$i])
    }

    $selection = Read-Host "Enter the VM number"
    $selectedIndex = 0

    if (-not [int]::TryParse([string]$selection, [ref]$selectedIndex)) {
        throw "Invalid VM selection: $selection"
    }

    if ($selectedIndex -lt 1 -or $selectedIndex -gt $VmNames.Count) {
        throw "VM selection out of range: $selectedIndex"
    }

    return [string]$VmNames[$selectedIndex - 1]
}

function ConvertTo-HqMetadataModuleLiteral {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return '$null'
    }

    if ($Value -is [bool]) {
        return ('$' + $Value.ToString().ToLowerInvariant())
    }

    if ($Value -is [string]) {
        return ("'{0}'" -f $Value.Replace("'", "''"))
    }

    if ($Value -is [System.Array]) {
        $items = @(
            foreach ($item in @($Value)) {
                ConvertTo-HqMetadataModuleLiteral -Value $item
            }
        )

        if ($items.Count -eq 0) {
            return '@()'
        }

        return ('@({0})' -f ($items -join ', '))
    }

    throw "Unsupported metadata literal value type: $($Value.GetType().FullName)"
}

function New-HqMetadataModuleObjectCollectionLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PropertyName,

        [object[]]$Items,

        [Parameter(Mandatory = $true)]
        [string[]]$Fields
    )

    $Items = @($Items)
    $lines = @("    $PropertyName = @(")

    for ($i = 0; $i -lt $Items.Count; $i++) {
        $item = $Items[$i]
        $lines += '        [pscustomobject]@{'

        foreach ($field in $Fields) {
            $property = if ($item) { $item.PSObject.Properties[$field] } else { $null }
            $value = if ($property) { $property.Value } else { $null }
            $lines += ("            {0} = {1}" -f $field, (ConvertTo-HqMetadataModuleLiteral -Value $value))
        }

        $lines += '        }'
        if ($i -lt ($Items.Count - 1)) {
            $lines += ''
        }
    }

    $lines += '    )'
    return $lines
}

function Write-HqDiskMetadataModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$AvailableVmNames,

        [string]$SelectedVmName,

        [object[]]$Definitions,

        [object[]]$RoleAclDefinitions,

        [object[]]$SecurityPrincipalDefinitions,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not $PSBoundParameters.ContainsKey('RoleAclDefinitions')) {
        $RoleAclDefinitions = @(Get-HqDefaultRoleAclDefinitions)
    } else {
        $RoleAclDefinitions = @($RoleAclDefinitions)
    }

    if (-not $PSBoundParameters.ContainsKey('SecurityPrincipalDefinitions')) {
        $SecurityPrincipalDefinitions = @(Get-HqDefaultSecurityPrincipalDefinitions)
    } else {
        $SecurityPrincipalDefinitions = @($SecurityPrincipalDefinitions)
    }

    $lines = @(
        '# Generated by app/configure_hq.ps1 on the host.',
        '# Update this module by running: .\app\configure_hq.ps1',
        ('# Selected VM: {0}' -f $SelectedVmName),
        '',
        '$script:HqDiskMetadataConfig = [pscustomobject]@{',
        '    AvailableVmNames = @('
    )

    for ($i = 0; $i -lt $AvailableVmNames.Count; $i++) {
        $lines += ("        '{0}'" -f ([string]$AvailableVmNames[$i]).Replace("'", "''"))
    }

    $Definitions = @($Definitions)

    $lines += @(
        '    )',
        ("    SelectedVmName = '{0}'" -f ([string]$SelectedVmName).Replace("'", "''")),
        ''
    )

    $lines += @(New-HqMetadataModuleObjectCollectionLines `
        -PropertyName 'RoleDefinitions' `
        -Items $Definitions `
        -Fields @('VmName', 'SourceVhd', 'VhdName', 'RoleName', 'ExpectedDriveLetter', 'DedupEnabled'))
    $lines += ''
    $lines += @(New-HqMetadataModuleObjectCollectionLines `
        -PropertyName 'RoleAclDefinitions' `
        -Items $RoleAclDefinitions `
        -Fields @('RoleName', 'ManagedPathName', 'Principal', 'AccessLevel', 'ServiceAccount', 'ServiceAccessLevel'))
    $lines += ''
    $lines += @(New-HqMetadataModuleObjectCollectionLines `
        -PropertyName 'SecurityPrincipalDefinitions' `
        -Items $SecurityPrincipalDefinitions `
        -Fields @('Principal', 'Type', 'ExpectedMemberOf', 'PasswordPromptRequired'))

    $lines += @(
        '}',
        '',
        'function Get-HqDiskMetadataConfig {',
        '    [CmdletBinding()]',
        '    param()',
        '',
        '    return $script:HqDiskMetadataConfig',
        '}',
        '',
        'function Get-HqDiskRoleDefinitions {',
        '    [CmdletBinding()]',
        '    param()',
        '',
        '    return @($script:HqDiskMetadataConfig.RoleDefinitions)',
        '}',
        '',
        'function Get-HqRoleAclMetadataDefinitions {',
        '    [CmdletBinding()]',
        '    param()',
        '',
        '    return @($script:HqDiskMetadataConfig.RoleAclDefinitions)',
        '}',
        '',
        'function Get-HqSecurityPrincipalMetadataDefinitions {',
        '    [CmdletBinding()]',
        '    param()',
        '',
        '    return @($script:HqDiskMetadataConfig.SecurityPrincipalDefinitions)',
        '}',
        '',
        'Export-ModuleMember -Function Get-HqDiskMetadataConfig, Get-HqDiskRoleDefinitions, Get-HqRoleAclMetadataDefinitions, Get-HqSecurityPrincipalMetadataDefinitions'
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -Path $parent -ItemType Directory -Force | Out-Null
    }

    Set-Content -Path $Path -Value $lines -Encoding ASCII
}

function Update-HqDiskMetadataModule {
    [CmdletBinding()]
    param(
        [string]$VmName,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-HqHostMetadataCommandsAvailable)) {
        throw "Hyper-V host metadata commands are not available in this session. Run this command on the Hyper-V host, or run .\configure_hq.ps1 -RunActivation on the guest."
    }

    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    Write-HqStatus -Phase "Host" -Message "Discovering Hyper-V VM names..."
    $availableVmNames = @(Get-HqHostVmNames)
    $selectedVmName = [string]$VmName

    if (-not $selectedVmName) {
        Write-HqStatus -Phase "Host" -Message ("Discovered VM names: {0}" -f ($availableVmNames -join ', '))
        $selectedVmName = Select-HqHostVmName -VmNames $availableVmNames
    }

    Write-HqStatus -Phase "Host" -Message ("Collecting VHD attachments for VM '{0}'..." -f $selectedVmName)
    $definitions = Get-HqHostDiskMetadata -VmName $selectedVmName
    $roleAclDefinitions = @(Get-HqDefaultRoleAclDefinitions)
    $securityPrincipalDefinitions = @(Get-HqDefaultSecurityPrincipalDefinitions)
    Write-HqStatus -Phase "Host" -Message ("Writing disk metadata module to {0}" -f $resolvedPath)
    Write-HqDiskMetadataModule `
        -AvailableVmNames $availableVmNames `
        -SelectedVmName $selectedVmName `
        -Definitions $definitions `
        -RoleAclDefinitions $roleAclDefinitions `
        -SecurityPrincipalDefinitions $securityPrincipalDefinitions `
        -Path $resolvedPath
    Write-HqStatus -Phase "Host" -Message ("Metadata update complete. Wrote {0} role definition(s)." -f @($definitions).Count)
    return $definitions
}

function Import-HqDiskMetadataDefinitions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    # Step: show when guest metadata loading starts.
    Write-HqStatus -Phase "Metadata" -Message ("Reading disk metadata module from {0}" -f $resolvedPath)

    if (-not (Test-Path $Path)) {
        throw "Disk metadata module not found: $Path. Run .\app\configure_hq.ps1 on the host first."
    }

    if (-not (Test-HqMetadataModuleLooksLikeGeneratedConfig -Path $Path)) {
        throw "Metadata module at $Path is not a generated HQ metadata module. Run .\app\configure_hq.ps1 on the host first."
    }

    Import-Module $Path -Force -ErrorAction Stop | Out-Null
    $config = Get-HqDiskMetadataConfig
    if (-not $config.SelectedVmName) {
        throw "Disk metadata module does not have a selected VM yet. Run .\app\configure_hq.ps1 -VmName <ExactVmName> on the host first."
    }

    $definitions = @(Get-HqDiskRoleDefinitions)
    $roleAclDefinitions = if (Get-Command Get-HqRoleAclMetadataDefinitions -ErrorAction SilentlyContinue) {
        @(Get-HqRoleAclMetadataDefinitions)
    } else {
        @()
    }
    $securityPrincipalDefinitions = if (Get-Command Get-HqSecurityPrincipalMetadataDefinitions -ErrorAction SilentlyContinue) {
        @(Get-HqSecurityPrincipalMetadataDefinitions)
    } else {
        @()
    }
    Write-HqStatus -Phase "Metadata" -Message ("Loaded metadata for VM '{0}'. Found {1} role definition(s), {2} ACL definition(s), and {3} principal definition(s)." -f `
        $config.SelectedVmName, `
        $definitions.Count, `
        $roleAclDefinitions.Count, `
        $securityPrincipalDefinitions.Count) -Level Success
    return $definitions
}

function Test-HqMetadataModuleLooksLikeGeneratedConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return $false
    }

    $content = Get-Content -Path $Path -Raw -ErrorAction Stop
    $requiredPatterns = @(
        [regex]::Escape('$script:HqDiskMetadataConfig')
        [regex]::Escape('function Get-HqDiskMetadataConfig')
        [regex]::Escape('function Get-HqDiskRoleDefinitions')
    )
    $invalidPatterns = @(
        '(?m)\A(?:[ \t]*#.*\r?\n|[ \t]*\r?\n)*[ \t]*param\s*\('
        [regex]::Escape('Set-StrictMode -Version Latest')
        [regex]::Escape('function Update-HqDiskMetadataModule')
        [regex]::Escape('if ($MyInvocation.InvocationName -ne ''.'')')
    )

    foreach ($pattern in $requiredPatterns) {
        if ($content -notmatch $pattern) {
            return $false
        }
    }

    foreach ($pattern in $invalidPatterns) {
        if ($content -match $pattern) {
            return $false
        }
    }

    return $true
}

function Import-HqMetadataModuleIfPresent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return $false
    }

    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    if (-not (Test-HqMetadataModuleLooksLikeGeneratedConfig -Path $Path)) {
        Write-HqStatus -Phase "Metadata" -Message ("Skipping metadata import from {0} because it is not a generated HQ metadata module. Using built-in identity definitions for this operation." -f $resolvedPath) -Level Warning
        return $false
    }

    try {
        Import-Module $Path -Force -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        $message = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { [string]$_ }
        Write-HqStatus -Phase "Metadata" -Message ("Skipping metadata import from {0}: {1}. Using built-in identity definitions for this operation." -f `
            $resolvedPath, `
            $message) -Level Warning
        return $false
    }
}

<#
.SYNOPSIS
    Returns attached data disks that are safe for HQ workflow processing.

.DESCRIPTION
    Uses injected disk objects during tests, or falls back to `Get-Disk`
    during real execution. System and boot disks are excluded, and an
    optional disk-number filter can narrow the result set further.

.PARAMETER DiskNumbers
    Optional list of disk numbers to keep after system and boot disks
    have been excluded.

.PARAMETER Disks
    Optional disk objects supplied by tests or callers that want to avoid
    reading live disk state from the host.
#>
function Get-HqAttachedDataDisks {
    [CmdletBinding()]
    param(
        [int[]]$DiskNumbers,
        [object[]]$Disks
    )

    # Step: use injected disks during tests, otherwise read live disks.
    if (-not $PSBoundParameters.ContainsKey("Disks")) {
        $Disks = @(Get-Disk)
    }

    # Step: remove system and boot disks before any explicit filter runs.
    $dataDisks = @($Disks | Where-Object { -not $_.IsSystem -and -not $_.IsBoot })

    if ($DiskNumbers -and $DiskNumbers.Count -gt 0) {
        $dataDisks = @($dataDisks | Where-Object { $DiskNumbers -contains [int]$_.Number })
    }

    return ,@($dataDisks)
}

<#
.SYNOPSIS
    Builds display metadata for HQ disk reporting.

.DESCRIPTION
    Produces human-friendly values used in progress messages and the final
    summary output. Falls back to `Get-Partition` for drive-letter discovery
    during real execution.

.PARAMETER Disk
    Disk object returned by `Get-Disk` or injected by a test.
#>
function Get-HqDiskSummaryInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Disk
    )

    $diskName = $null
    if ($Disk.PSObject.Properties['FriendlyName']) {
        $diskName = [string]$Disk.FriendlyName
    } elseif ($Disk.PSObject.Properties['SourceVhd']) {
        $diskName = [System.IO.Path]::GetFileNameWithoutExtension([string]$Disk.SourceVhd)
    } else {
        $diskName = "Disk$($Disk.Number)"
    }

    $sizeGB = $null
    if ($Disk.PSObject.Properties['Size']) {
        $sizeGB = [int][Math]::Round(([double]$Disk.Size / 1GB), 0)
    }

    $driveLetters = $null
    if ($Disk.PSObject.Properties['DriveLetters']) {
        $driveLetters = [string]$Disk.DriveLetters
    } else {
        $partitions = @(Get-Partition -DiskNumber ([int]$Disk.Number) -ErrorAction SilentlyContinue)
        $letters = @($partitions | Where-Object { $_.DriveLetter } | ForEach-Object { [string]$_.DriveLetter })
        if ($letters.Count -gt 0) {
            $driveLetters = ($letters -join ',')
        }
    }

    return [pscustomobject]@{
        DiskName     = $diskName
        SizeGB       = $sizeGB
        DriveLetters = $driveLetters
    }
}

<#
.SYNOPSIS
    Brings target disks online and clears read-only state.

.DESCRIPTION
    Evaluates each disk object and issues the minimum `Set-Disk` calls
    required to make it writable. Returns a per-disk summary object so
    callers and tests can inspect what changed.

.PARAMETER Disks
    Disk objects that expose at least `Number`, `IsOffline`, and
    `IsReadOnly`.
#>
function Bring-HqDisksOnline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Disks
    )

    $results = @()

    foreach ($disk in $Disks) {
        $action = "Unchanged"
        $wasOffline = [bool]$disk.IsOffline
        $wasReadOnly = [bool]$disk.IsReadOnly
        $summary = Get-HqDiskSummaryInfo -Disk $disk

        Write-HqStatus -Phase "Activation" -Message ("Disk {0} '{1}' SizeGB={2} DriveLetters={3} Offline={4} ReadOnly={5}" -f `
            $disk.Number, `
            $summary.DiskName, `
            $summary.SizeGB, `
            $summary.DriveLetters, `
            $wasOffline, `
            $wasReadOnly)

        # Step: use separate Set-Disk calls to avoid parameter-set conflicts.
        if ($wasOffline) {
            Set-Disk -Number ([int]$disk.Number) -IsOffline $false -ErrorAction Stop
            $action = "Updated"
        }

        if ($wasReadOnly) {
            Set-Disk -Number ([int]$disk.Number) -IsReadOnly $false -ErrorAction Stop
            $action = "Updated"
        }

        if ($action -eq 'Updated') {
            # Step: refresh the live partition view after the disk state changes
            # so later dedup and ACL phases see the mounted drive letters.
            $summary = Get-HqDiskSummaryInfo -Disk $disk
        }

        # Result: return one compact record for orchestration and tests.
        $results += [pscustomobject]@{
            DiskNumber  = [int]$disk.Number
            DiskName    = $summary.DiskName
            SizeGB      = $summary.SizeGB
            DriveLetters = $summary.DriveLetters
            WasOffline  = $wasOffline
            WasReadOnly = $wasReadOnly
            Action      = $action
        }
    }

    return $results
}

<#
.SYNOPSIS
    Orchestrates HQ disk discovery and activation.

.DESCRIPTION
    Finds target data disks first, then passes the result to the activation
    workflow. This is the increment-1 entrypoint for real disk preparation.

.PARAMETER DiskNumbers
    Optional list of disk numbers to activate.
#>
function Invoke-HqDiskActivation {
    [CmdletBinding()]
    param(
        [int[]]$DiskNumbers,
        [string]$MetadataModulePath = (Join-Path $PSScriptRoot 'HqDiskMetadata.psm1')
    )

    Write-HqStatus -Phase "Discovery" -Message "Discovering target data disks..."
    $disks = Get-HqAttachedDataDisks -DiskNumbers $DiskNumbers
    Write-HqStatus -Phase "Discovery" -Message ("Found {0} data disk(s) to process." -f $disks.Count)

    Write-HqStatus -Phase "Activation" -Message "Applying online and writable state..."
    $activationResults = Bring-HqDisksOnline -Disks $disks
    $updatedCount = @($activationResults | Where-Object { $_.Action -eq 'Updated' }).Count
    Write-HqStatus -Phase "Activation" -Message ("Activation phase complete. Updated {0} disk(s)." -f $updatedCount) -Level Success

    Write-HqStatus -Phase "Metadata" -Message "Applying configured role definitions to discovered guest disks..."
    $definitions = Import-HqDiskMetadataDefinitions -Path $MetadataModulePath
    $roleMap = Get-HqDiskRoleMap -Disks $disks -Definitions $definitions
    $roleLookup = @{}

    foreach ($role in $roleMap) {
        $roleLookup[[int]$role.DiskNumber] = $role
    }

    $results = @(
        foreach ($result in $activationResults) {
            $role = $roleLookup[[int]$result.DiskNumber]

            [pscustomobject]@{
                DiskNumber          = [int]$result.DiskNumber
                DiskName            = if ($result.PSObject.Properties['DiskName']) { $result.DiskName } else { $null }
                SizeGB              = if ($result.PSObject.Properties['SizeGB']) { $result.SizeGB } else { $null }
                DriveLetters        = if ($result.PSObject.Properties['DriveLetters']) { $result.DriveLetters } else { $null }
                WasOffline          = if ($result.PSObject.Properties['WasOffline']) { $result.WasOffline } else { $null }
                WasReadOnly         = if ($result.PSObject.Properties['WasReadOnly']) { $result.WasReadOnly } else { $null }
                Action              = if ($result.PSObject.Properties['Action']) { $result.Action } else { $null }
                SourceVhd           = $role.SourceVhd
                RoleName            = $role.RoleName
                ExpectedDriveLetter = $role.ExpectedDriveLetter
                DedupEnabled        = $role.DedupEnabled
            }
        }
    )

    Write-HqStatus -Phase "RoleMap" -Message ("Mapped {0} discovered disk(s) to configured roles." -f $results.Count) -Level Success
    Show-HqRoleResolutionStatus -Definitions $definitions -Results $results
    return $results
}

# ---------------------------------------------------------------------
# Section: map discovered disks to configured roles
# ---------------------------------------------------------------------

function Get-HqDiskRoleMap {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Disks,

        [object[]]$Definitions = (Get-HqDefaultDiskRoleDefinitions)
    )

    # Step: start with the discovered data disks from the caller.
    $results = @()

    # Step: prefer SourceVhd first, then fall back to guest drive letters.
    $roleDefinitions = @($Definitions)

    $roleMap = @{}
    foreach ($definition in $roleDefinitions) {
        $roleMap[[string]$definition.SourceVhd.ToLowerInvariant()] = $definition
    }

    # Step: map each known VHD path to its configured role.
    foreach ($disk in $Disks) {
        $sourceVhd = if ($disk.PSObject.Properties['SourceVhd']) { [string]$disk.SourceVhd } else { $null }
        $normalizedPath = if ($sourceVhd) { $sourceVhd.ToLowerInvariant() } else { $null }
        $mapping = $null

        if ($normalizedPath -and $roleMap.ContainsKey($normalizedPath)) {
            $mapping = $roleMap[$normalizedPath]
        }

        if (-not $mapping) {
            $summary = Get-HqDiskSummaryInfo -Disk $disk
            $driveLetters = @(
                [string]$summary.DriveLetters -split ',' |
                ForEach-Object { $_.Trim().ToUpperInvariant() } |
                Where-Object { $_ }
            )

            if ($driveLetters.Count -gt 0) {
                $mapping = $roleDefinitions | Where-Object { $driveLetters -contains $_.ExpectedDriveLetter } | Select-Object -First 1
            }
        }

        if ($mapping) {
            # Result: return the role data for the matched disk.
            $results += [pscustomobject]@{
                DiskNumber          = [int]$disk.Number
                SourceVhd           = $sourceVhd
                RoleName            = [string]$mapping.RoleName
                ExpectedDriveLetter = [string]$mapping.ExpectedDriveLetter
                DedupEnabled        = [bool]$mapping.DedupEnabled
            }
            continue
        }

        # Check: fail clearly when a disk cannot be mapped.
        throw "Unknown disk role mapping for VHD path: $sourceVhd"
    }

    return $results
}

# ---------------------------------------------------------------------
# Section: summarize workflow-wide identity state for the final output
# ---------------------------------------------------------------------

function Get-HqIdentityWorkflowAction {
    [CmdletBinding()]
    param(
        [object[]]$Results,
        [switch]$RestoreRequested
    )

    if (-not $RestoreRequested) {
        return 'Verified'
    }

    $results = @($Results)
    if ($results.Count -eq 0) {
        return 'Verified'
    }

    $actionableResults = @(
        $results |
        Where-Object { $_ -and $_.PSObject.Properties['Action'] } |
        Where-Object { @('Created', 'MembershipUpdated') -contains [string]$_.Action }
    )
    if ($actionableResults.Count -gt 0) {
        return 'Updated'
    }

    return 'Verified'
}

# ---------------------------------------------------------------------
# Section: run the shared workflow entrypoint
# ---------------------------------------------------------------------

<#
.SYNOPSIS
    Guarded entrypoint for the HQ configuration workflow.

.DESCRIPTION
    This wrapper is the intended real-execution entrypoint for the script.
    It currently runs increment-1 disk activation and will become the place
    where later increments add deduplication and SMB provisioning.

.PARAMETER DiskNumbers
    Optional list of disk numbers to activate.
#>
function Start-HqConfiguration {
    [CmdletBinding()]
    param(
        [switch]$InstallMissingFeatures,
        [switch]$RunIdentityRestore,
        [int[]]$DiskNumbers,
        [string]$MetadataModulePath = (Join-Path $PSScriptRoot 'HqDiskMetadata.psm1')
    )

    Write-HqStatus -Phase "Workflow" -Message "Starting configuration workflow..."
    $results = Invoke-HqDiskActivation -DiskNumbers $DiskNumbers -MetadataModulePath $MetadataModulePath
    $identityResults = @()
    $identityAction = 'Verified'

    if ($RunIdentityRestore) {
        $identityResults = @(Ensure-HqSecurityPrincipals)
        $identityAction = Get-HqIdentityWorkflowAction -Results $identityResults -RestoreRequested
    }

    # Step: pass activation results into dedup so only flagged disks are processed.
    Write-HqStatus -Phase "Dedup" -Message "Evaluating dedup-enabled volumes..."
    $dedupResults = Enable-HqDiskDeduplication -ActivationResults $results -InstallMissingFeatures:$InstallMissingFeatures
    $dedupLookup = @{}

    foreach ($dedupResult in $dedupResults) {
        $dedupLookup[[int]$dedupResult.DiskNumber] = $dedupResult
    }

    $results = @(
        foreach ($result in $results) {
            $dedupResult = $dedupLookup[[int]$result.DiskNumber]

            [pscustomobject]@{
                DiskNumber          = [int]$result.DiskNumber
                DiskName            = if ($result.PSObject.Properties['DiskName']) { $result.DiskName } else { $null }
                SizeGB              = if ($result.PSObject.Properties['SizeGB']) { $result.SizeGB } else { $null }
                DriveLetters        = if ($result.PSObject.Properties['DriveLetters']) { $result.DriveLetters } else { $null }
                WasOffline          = if ($result.PSObject.Properties['WasOffline']) { $result.WasOffline } else { $null }
                WasReadOnly         = if ($result.PSObject.Properties['WasReadOnly']) { $result.WasReadOnly } else { $null }
                Action              = if ($result.PSObject.Properties['Action']) { $result.Action } else { $null }
                SourceVhd           = if ($result.PSObject.Properties['SourceVhd']) { $result.SourceVhd } else { $null }
                RoleName            = if ($result.PSObject.Properties['RoleName']) { $result.RoleName } else { $null }
                ExpectedDriveLetter = if ($result.PSObject.Properties['ExpectedDriveLetter']) { $result.ExpectedDriveLetter } else { $null }
                DedupEnabled        = if ($result.PSObject.Properties['DedupEnabled']) { $result.DedupEnabled } else { $null }
                IdentityAction      = $identityAction
                DedupAction         = if ($dedupResult) { $dedupResult.DedupAction } else { 'NotRequired' }
                DedupVolume         = if ($dedupResult) { $dedupResult.DedupVolume } else { $null }
            }
        }
    )

    # Check: stop early with a clear restore instruction when ACL work still
    # depends on principals that are missing on the guest.
    if (-not $RunIdentityRestore -and -not (Test-HqRequiredSecurityPrincipalsPresent)) {
        throw "Required HQ principals are missing on this guest. Run .\configure_hq.ps1 -RunIdentityRestore first, or rerun activation with -RunIdentityRestore."
    }

    # Step: apply the access rules once the final workflow rows are ready.
    $aclResults = @(Ensure-HqRoleAcl -WorkflowResults $results)
    $aclLookup = @{}

    foreach ($aclResult in $aclResults) {
        $aclLookup[[int]$aclResult.DiskNumber] = $aclResult
    }

    $results = @(
        foreach ($result in $results) {
            $aclResult = $aclLookup[[int]$result.DiskNumber]

            [pscustomobject]@{
                DiskNumber          = [int]$result.DiskNumber
                DiskName            = if ($result.PSObject.Properties['DiskName']) { $result.DiskName } else { $null }
                SizeGB              = if ($result.PSObject.Properties['SizeGB']) { $result.SizeGB } else { $null }
                DriveLetters        = if ($result.PSObject.Properties['DriveLetters']) { $result.DriveLetters } else { $null }
                WasOffline          = if ($result.PSObject.Properties['WasOffline']) { $result.WasOffline } else { $null }
                WasReadOnly         = if ($result.PSObject.Properties['WasReadOnly']) { $result.WasReadOnly } else { $null }
                Action              = if ($result.PSObject.Properties['Action']) { $result.Action } else { $null }
                SourceVhd           = if ($result.PSObject.Properties['SourceVhd']) { $result.SourceVhd } else { $null }
                RoleName            = if ($result.PSObject.Properties['RoleName']) { $result.RoleName } else { $null }
                ExpectedDriveLetter = if ($result.PSObject.Properties['ExpectedDriveLetter']) { $result.ExpectedDriveLetter } else { $null }
                DedupEnabled        = if ($result.PSObject.Properties['DedupEnabled']) { $result.DedupEnabled } else { $null }
                IdentityAction      = if ($result.PSObject.Properties['IdentityAction']) { $result.IdentityAction } else { $identityAction }
                DedupAction         = if ($result.PSObject.Properties['DedupAction']) { $result.DedupAction } else { 'NotRequired' }
                DedupVolume         = if ($result.PSObject.Properties['DedupVolume']) { $result.DedupVolume } else { $null }
                ManagedPath         = if ($aclResult) { $aclResult.ManagedPath } else { $null }
                AclAction           = if ($aclResult) { $aclResult.AclAction } else { 'NotApplied' }
            }
        }
    )

    # Step: publish the managed folders through SMB once the ACL-backed
    # paths are known and the required principals are in place.
    $smbResults = @(Ensure-HqSmbShares -WorkflowResults $results)
    $smbLookup = @{}

    foreach ($smbResult in $smbResults) {
        $smbLookup[[int]$smbResult.DiskNumber] = $smbResult
    }

    $results = @(
        foreach ($result in $results) {
            $smbResult = $smbLookup[[int]$result.DiskNumber]

            [pscustomobject]@{
                DiskNumber          = [int]$result.DiskNumber
                DiskName            = if ($result.PSObject.Properties['DiskName']) { $result.DiskName } else { $null }
                SizeGB              = if ($result.PSObject.Properties['SizeGB']) { $result.SizeGB } else { $null }
                DriveLetters        = if ($result.PSObject.Properties['DriveLetters']) { $result.DriveLetters } else { $null }
                WasOffline          = if ($result.PSObject.Properties['WasOffline']) { $result.WasOffline } else { $null }
                WasReadOnly         = if ($result.PSObject.Properties['WasReadOnly']) { $result.WasReadOnly } else { $null }
                Action              = if ($result.PSObject.Properties['Action']) { $result.Action } else { $null }
                SourceVhd           = if ($result.PSObject.Properties['SourceVhd']) { $result.SourceVhd } else { $null }
                RoleName            = if ($result.PSObject.Properties['RoleName']) { $result.RoleName } else { $null }
                ExpectedDriveLetter = if ($result.PSObject.Properties['ExpectedDriveLetter']) { $result.ExpectedDriveLetter } else { $null }
                DedupEnabled        = if ($result.PSObject.Properties['DedupEnabled']) { $result.DedupEnabled } else { $null }
                IdentityAction      = if ($result.PSObject.Properties['IdentityAction']) { $result.IdentityAction } else { $identityAction }
                DedupAction         = if ($result.PSObject.Properties['DedupAction']) { $result.DedupAction } else { 'NotRequired' }
                DedupVolume         = if ($result.PSObject.Properties['DedupVolume']) { $result.DedupVolume } else { $null }
                ManagedPath         = if ($result.PSObject.Properties['ManagedPath']) { $result.ManagedPath } else { $null }
                AclAction           = if ($result.PSObject.Properties['AclAction']) { $result.AclAction } else { 'NotApplied' }
                ShareName           = if ($smbResult) { $smbResult.ShareName } else { $null }
                SmbAction           = if ($smbResult) { $smbResult.SmbAction } else { 'NotPublished' }
            }
        }
    )

    $dedupCount = @($dedupResults).Count
    Write-HqStatus -Phase "Dedup" -Message ("Dedup phase complete. Processed {0} volume(s)." -f $dedupCount) -Level Success
    Write-HqStatus -Phase "Workflow" -Message ("Configuration workflow complete. Produced {0} result row(s)." -f @($results).Count) -Level Success
    return $results
}

<#
.SYNOPSIS
    Enables deduplication for HQ volumes marked as dedup-enabled.
#>
function Enable-HqDiskDeduplication {
    [CmdletBinding()]
    param(
        [switch]$InstallMissingFeatures,
        [Parameter(Mandatory = $true)]
        [object[]]$ActivationResults
    )

    # Step: keep only the roles that require dedup.
    $dedupResults = @(
        $ActivationResults |
        Where-Object { $_.DedupEnabled }
    )

    $results = @()

    # Check: make sure the expected drive letter is really present.
    foreach ($result in $dedupResults) {
        $actualDrives = @(
            [string]$result.DriveLetters -split ',' |
            ForEach-Object { $_.Trim().ToUpperInvariant() } |
            Where-Object { $_ }
        )

        if ($actualDrives -notcontains ([string]$result.ExpectedDriveLetter).ToUpperInvariant()) {
            throw "Dedup target drive mismatch for role '$($result.RoleName)': expected $($result.ExpectedDriveLetter), found $($result.DriveLetters)"
        }

        $dedupVolume = ("{0}:" -f ([string]$result.ExpectedDriveLetter).ToUpperInvariant())

        # Result: return one compact record for this dedup volume.
        Write-HqStatus -Phase "Dedup" -Message ("Enabling dedup for role '{0}' on volume {1}..." -f `
            $result.RoleName, `
            $dedupVolume)
        Invoke-HqDedupVolume -Volume $dedupVolume -InstallMissingFeatures:$InstallMissingFeatures
        Write-HqStatus -Phase "Dedup" -Message ("Dedup enabled for role '{0}' on volume {1}." -f `
            $result.RoleName, `
            $dedupVolume) -Level Success
        $results += [pscustomobject]@{
            DiskNumber          = [int]$result.DiskNumber
            RoleName            = [string]$result.RoleName
            DriveLetters        = [string]$result.DriveLetters
            ExpectedDriveLetter = [string]$result.ExpectedDriveLetter
            DedupEnabled        = [bool]$result.DedupEnabled
            DedupAction         = 'Enabled'
            DedupVolume         = $dedupVolume
        }
    }

    return $results
}

function Invoke-HqDedupVolume {
    [CmdletBinding()]
    param(
        [switch]$InstallMissingFeatures,
        [Parameter(Mandatory = $true)]
        [string]$Volume
    )

    if (-not (Test-HqDedupCmdletsAvailable)) {
        if ($InstallMissingFeatures) {
            Invoke-HqDedupFeatureInstall
        }
    }

    if (-not (Test-HqDedupCmdletsAvailable)) {
        if ($InstallMissingFeatures) {
            throw "Deduplication cmdlets are still unavailable after attempting feature installation. A reboot or manual verification may be required."
        }

        throw "Deduplication cmdlets are not available. Install the Data Deduplication feature on the guest first or rerun with -InstallMissingFeatures."
    }

    Invoke-HqNativeDedupVolume -Volume $Volume
}

function Test-HqDedupCmdletsAvailable {
    [CmdletBinding()]
    param()

    Import-Module Deduplication -ErrorAction SilentlyContinue | Out-Null
    return [bool](Get-Command Enable-DedupVolume -ErrorAction SilentlyContinue)
}

function Invoke-HqDedupFeatureInstall {
    [CmdletBinding()]
    param()

    if (-not (Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue)) {
        throw "Install-WindowsFeature is not available on this guest. Install the Data Deduplication feature manually."
    }

    Write-HqStatus -Phase "Dedup" -Message "Installing missing Data Deduplication feature..." -Level Warning
    Install-WindowsFeature -Name FS-Data-Deduplication -IncludeManagementTools -ErrorAction Stop | Out-Null
    Write-HqStatus -Phase "Dedup" -Message "Data Deduplication feature installation completed." -Level Success
}

function Invoke-HqNativeDedupVolume {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Volume
    )

    Enable-DedupVolume -Volume $Volume -ErrorAction Stop | Out-Null
}

# ---------------------------------------------------------------------
# Section: define and apply the folder access rules for each HQ role
# ---------------------------------------------------------------------

function Get-HqLegacyManagedPathNameForRole {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RoleName
    )

    switch ($RoleName) {
        'Lab' { return 'Shares\lab' }
        'ShareDrive' { return 'Shares\share' }
        'Repository' { return 'Shares\repository' }
        'Backups' { return 'Shares\backup' }
        default { throw "No legacy managed path is defined for role '$RoleName'." }
    }
}

function Get-HqLegacyShareNameForRole {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RoleName
    )

    switch ($RoleName) {
        'Lab' { return 'lab' }
        'ShareDrive' { return 'share' }
        'Repository' { return 'repository' }
        'Backups' { return 'backup' }
        default { throw "No legacy SMB share name is defined for role '$RoleName'." }
    }
}

function Convert-HqRoleAclDefinitionsToLegacyContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Definitions
    )

    return @(
        foreach ($definition in @($Definitions)) {
            $roleName = [string]$definition.RoleName

            [pscustomobject]@{
                RoleName           = $roleName
                ManagedPathName    = Get-HqLegacyManagedPathNameForRole -RoleName $roleName
                Principal          = [string]$definition.Principal
                AccessLevel        = [string]$definition.AccessLevel
                ServiceAccount     = [string]$definition.ServiceAccount
                ServiceAccessLevel = [string]$definition.ServiceAccessLevel
            }
        }
    )
}

# Subfunction: keep the role-to-folder access rules in one place.
<#
.SYNOPSIS
    Returns increment-4 ACL policy definitions for HQ role folders.
#>
function Get-HqDefaultRoleAclDefinitions {
    [CmdletBinding()]
    param()

    return @(
        [pscustomobject]@{
            RoleName           = 'Lab'
            ManagedPathName    = 'Shares\lab'
            Principal          = 'HQ\Lab_RW'
            AccessLevel        = 'Modify'
            ServiceAccount     = 'HQ\svc_lab'
            ServiceAccessLevel = 'FullControl'
        }
        [pscustomobject]@{
            RoleName           = 'ShareDrive'
            ManagedPathName    = 'Shares\share'
            Principal          = 'HQ\ShareDrive_R'
            AccessLevel        = 'ReadAndExecute'
            ServiceAccount     = 'HQ\svc_lab'
            ServiceAccessLevel = 'FullControl'
        }
        [pscustomobject]@{
            RoleName           = 'Repository'
            ManagedPathName    = 'Shares\repository'
            Principal          = 'HQ\Repository_R'
            AccessLevel        = 'ReadAndExecute'
            ServiceAccount     = 'HQ\svc_lab'
            ServiceAccessLevel = 'FullControl'
        }
        [pscustomobject]@{
            RoleName           = 'Backups'
            ManagedPathName    = 'Shares\backup'
            Principal          = 'HQ\Backups_RW'
            AccessLevel        = 'Modify'
            ServiceAccount     = 'HQ\svc_lab'
            ServiceAccessLevel = 'FullControl'
        }
    )
}

function Get-HqRoleAclDefinitions {
    [CmdletBinding()]
    param()

    if (Get-Command Get-HqRoleAclMetadataDefinitions -ErrorAction SilentlyContinue) {
        try {
            $definitions = @(Get-HqRoleAclMetadataDefinitions)
            if ($definitions.Count -gt 0) {
                return @(Convert-HqRoleAclDefinitionsToLegacyContract -Definitions $definitions)
            }
        }
        catch {
            # Step: fall back to the built-in ACL contract when an older
            # metadata module does not expose ACL definitions yet.
        }
    }

    return @(Convert-HqRoleAclDefinitionsToLegacyContract -Definitions @(Get-HqDefaultRoleAclDefinitions))
}

# ---------------------------------------------------------------------
# Section: define the required HQ identity contract
# ---------------------------------------------------------------------

# Subfunction: combine the required users, service account, and groups.
function Get-HqDefaultSecurityPrincipalDefinitions {
    [CmdletBinding()]
    param()

    $results = @{}
    $expectedMemberships = Get-HqExpectedSecurityPrincipalMemberships
    $passwordPromptPrincipals = @('HQ\hector', 'HQ\Researcher', 'HQ\svc_lab')

    foreach ($definition in @(Get-HqDefaultRoleAclDefinitions)) {
        $results[[string]$definition.Principal] = [pscustomobject]@{
            Principal        = [string]$definition.Principal
            Type             = 'Group'
            ExpectedMemberOf = @()
            PasswordPromptRequired = $false
        }
        $results[[string]$definition.ServiceAccount] = [pscustomobject]@{
            Principal        = [string]$definition.ServiceAccount
            Type             = 'User'
            ExpectedMemberOf = @($expectedMemberships[[string]$definition.ServiceAccount])
            PasswordPromptRequired = ($passwordPromptPrincipals -contains [string]$definition.ServiceAccount)
        }
    }

    foreach ($principal in @('HQ\hector', 'HQ\Researcher')) {
        $results[$principal] = [pscustomobject]@{
            Principal        = $principal
            Type             = 'User'
            ExpectedMemberOf = @($expectedMemberships[$principal])
            PasswordPromptRequired = $true
        }
    }

    return @($results.Values)
}

function Get-HqRequiredSecurityPrincipalDefinitions {
    [CmdletBinding()]
    param()

    if (Get-Command Get-HqSecurityPrincipalMetadataDefinitions -ErrorAction SilentlyContinue) {
        try {
            $definitions = @(Get-HqSecurityPrincipalMetadataDefinitions)
            if ($definitions.Count -gt 0) {
                return $definitions
            }
        }
        catch {
            # Step: fall back to the built-in identity contract when an older
            # metadata module does not expose principal definitions yet.
        }
    }

    return @(Get-HqDefaultSecurityPrincipalDefinitions)
}

# Subfunction: keep the expected user-to-group links in one place.
function Get-HqExpectedSecurityPrincipalMemberships {
    [CmdletBinding()]
    param()

    return @{
        'HQ\hector' = @(
            'HQ\Lab_RW'
            'HQ\Repository_R'
            'HQ\ShareDrive_R'
        )
        'HQ\Researcher' = @(
            'HQ\Lab_RW'
            'HQ\ShareDrive_R'
        )
        'HQ\svc_lab' = @(
            'HQ\Lab_RW'
            'HQ\Repository_R'
            'HQ\Backups_RW'
            'HQ\ShareDrive_R'
        )
    }
}

function Test-HqSecurityPrincipalResolvable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Principal
    )

    try {
        $account = [System.Security.Principal.NTAccount]::new($Principal)
        [void]$account.Translate([System.Security.Principal.SecurityIdentifier])
        return $true
    }
    catch {
        return $false
    }
}

function Resolve-HqSecurityPrincipalName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Principal
    )

    $leafName = Get-HqSecurityPrincipalLeafName -Principal $Principal
    $candidatePrincipals = @($Principal)

    if (Test-HqActiveDirectoryCommandsAvailable) {
        try {
            $domain = Get-ADDomain -ErrorAction Stop
            if ($domain -and $domain.NetBIOSName) {
                $candidatePrincipals += ("{0}\{1}" -f [string]$domain.NetBIOSName, $leafName)
            }
        }
        catch {
            # Step: keep the original configured principal when the live
            # domain qualifier cannot be read in this session.
        }
    } else {
        $candidatePrincipals += ("{0}\{1}" -f $env:COMPUTERNAME, $leafName)
    }

    $candidatePrincipals += $leafName

    foreach ($candidate in @($candidatePrincipals | Where-Object { $_ } | Select-Object -Unique)) {
        if (Test-HqSecurityPrincipalResolvable -Principal ([string]$candidate)) {
            return [string]$candidate
        }
    }

    throw "Security principal '$Principal' could not be resolved on this guest."
}

function Invoke-HqEnsureDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Invoke-HqGrantDirectoryAccess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Principal,

        [Parameter(Mandatory = $true)]
        [string]$AccessLevel
    )

    $acl = Get-Acl -Path $Path
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $Principal,
        $AccessLevel,
        'ContainerInherit,ObjectInherit',
        'None',
        'Allow'
    )
    $acl.SetAccessRule($rule)
    Set-Acl -Path $Path -AclObject $acl
}

<#
.SYNOPSIS
    Applies increment-4 NTFS ACL policy to managed role folders.
#>
# Main function: create the managed folders and apply their access rules.
function Ensure-HqRoleAcl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$WorkflowResults
    )

    $definitions = @(Get-HqRoleAclDefinitions)
    $definitionLookup = @{}

    foreach ($definition in $definitions) {
        $definitionLookup[[string]$definition.RoleName] = $definition
    }

    $results = @()

    foreach ($workflowResult in $WorkflowResults) {
        $roleName = [string]$workflowResult.RoleName
        if (-not $definitionLookup.ContainsKey($roleName)) {
            throw "No ACL policy is defined for role '$roleName'."
        }

        $expectedDrive = [string]$workflowResult.ExpectedDriveLetter
        if (-not $expectedDrive) {
            throw "Cannot apply ACL policy for role '$roleName' without an expected drive letter."
        }

        $definition = $definitionLookup[$roleName]
        $managedPath = "{0}:\{1}" -f $expectedDrive.ToUpperInvariant(), [string]$definition.ManagedPathName
        $rolePrincipal = Resolve-HqSecurityPrincipalName -Principal ([string]$definition.Principal)
        $servicePrincipal = Resolve-HqSecurityPrincipalName -Principal ([string]$definition.ServiceAccount)

        Write-HqStatus -Phase "ACL" -Message ("Applying ACL policy for role '{0}' on path {1}..." -f $roleName, $managedPath)
        Invoke-HqEnsureDirectory -Path $managedPath
        Invoke-HqGrantDirectoryAccess -Path $managedPath -Principal 'NT AUTHORITY\SYSTEM' -AccessLevel 'FullControl'
        Invoke-HqGrantDirectoryAccess -Path $managedPath -Principal 'BUILTIN\Administrators' -AccessLevel 'FullControl'
        Invoke-HqGrantDirectoryAccess -Path $managedPath -Principal $rolePrincipal -AccessLevel ([string]$definition.AccessLevel)
        Invoke-HqGrantDirectoryAccess -Path $managedPath -Principal $servicePrincipal -AccessLevel ([string]$definition.ServiceAccessLevel)
        Write-HqStatus -Phase "ACL" -Message ("ACL policy applied for role '{0}' on path {1}." -f $roleName, $managedPath) -Level Success

        $results += [pscustomobject]@{
            DiskNumber  = [int]$workflowResult.DiskNumber
            RoleName    = $roleName
            ManagedPath = $managedPath
            AclAction   = 'Applied'
        }
    }

    return $results
}

# ---------------------------------------------------------------------
# Section: publish managed role folders through SMB shares
# ---------------------------------------------------------------------

# Subfunction: keep the SMB share contract aligned with the managed folders.
function Get-HqDefaultSmbShareDefinitions {
    [CmdletBinding()]
    param()

    return @(
        foreach ($definition in @(Get-HqRoleAclDefinitions)) {
            $roleName = [string]$definition.RoleName

            [pscustomobject]@{
                RoleName              = $roleName
                ShareName             = Get-HqLegacyShareNameForRole -RoleName $roleName
                SharePathName         = Get-HqLegacyManagedPathNameForRole -RoleName $roleName
                Principal             = [string]$definition.Principal
                AccessRight           = Convert-HqAccessLevelToSmbAccessRight -AccessLevel ([string]$definition.AccessLevel)
                ServiceAccount        = [string]$definition.ServiceAccount
                ServiceAccessRight    = Convert-HqAccessLevelToSmbAccessRight -AccessLevel ([string]$definition.ServiceAccessLevel)
            }
        }
    )
}

function Convert-HqAccessLevelToSmbAccessRight {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AccessLevel
    )

    switch ($AccessLevel) {
        'FullControl' { return 'Full' }
        'Modify' { return 'Change' }
        'ReadAndExecute' { return 'Read' }
        default { throw "Unsupported SMB access mapping for access level '$AccessLevel'." }
    }
}

function Test-HqSmbShareCmdletsAvailable {
    [CmdletBinding()]
    param()

    return [bool](
        (Get-Command Get-SmbShare -ErrorAction SilentlyContinue) -and
        (Get-Command New-SmbShare -ErrorAction SilentlyContinue) -and
        (Get-Command Get-SmbShareAccess -ErrorAction SilentlyContinue) -and
        (Get-Command Grant-SmbShareAccess -ErrorAction SilentlyContinue)
    )
}

function Get-HqSmbShare {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return @(Get-SmbShare -Name $Name -ErrorAction SilentlyContinue | Select-Object -First 1)
}

function Get-HqSmbShareAccessEntries {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return @(
        Get-SmbShareAccess -Name $Name -ErrorAction SilentlyContinue |
        Where-Object { $_ }
    )
}

function Invoke-HqNativeNewSmbShare {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string[]]$FullAccess
    )

    New-SmbShare -Name $Name -Path $Path -FullAccess $FullAccess -FolderEnumerationMode AccessBased -ErrorAction Stop | Out-Null
}

function Invoke-HqNativeGrantSmbShareAccess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$AccountName,

        [Parameter(Mandatory = $true)]
        [string]$AccessRight
    )

    Grant-SmbShareAccess -Name $Name -AccountName $AccountName -AccessRight $AccessRight -Force -ErrorAction Stop | Out-Null
}

function Ensure-HqSmbShareAccessRule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ShareName,

        [Parameter(Mandatory = $true)]
        [string]$Principal,

        [Parameter(Mandatory = $true)]
        [string]$AccessRight
    )

    $existingEntries = @(Get-HqSmbShareAccessEntries -Name $ShareName)
    $matchingEntry = @(
        $existingEntries |
        Where-Object { [string]$_.AccountName -eq $Principal -and [string]$_.AccessRight -eq $AccessRight } |
        Select-Object -First 1
    )

    if ($matchingEntry.Count -gt 0) {
        return
    }

    Invoke-HqNativeGrantSmbShareAccess -Name $ShareName -AccountName $Principal -AccessRight $AccessRight
}

<#
.SYNOPSIS
    Publishes increment-5 SMB shares for managed HQ role folders.
#>
function Ensure-HqSmbShares {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$WorkflowResults
    )

    if (-not (Test-HqSmbShareCmdletsAvailable)) {
        throw "SMB share cmdlets are not available on this guest. Install the File Server role tools or provision shares manually."
    }

    $definitions = @(Get-HqDefaultSmbShareDefinitions)
    $definitionLookup = @{}

    foreach ($definition in $definitions) {
        $definitionLookup[[string]$definition.RoleName] = $definition
    }

    $results = @()

    foreach ($workflowResult in $WorkflowResults) {
        $roleName = [string]$workflowResult.RoleName
        if (-not $definitionLookup.ContainsKey($roleName)) {
            throw "No SMB share policy is defined for role '$roleName'."
        }

        $expectedDrive = [string]$workflowResult.ExpectedDriveLetter
        if (-not $expectedDrive) {
            throw "Cannot publish SMB share for role '$roleName' without an expected drive letter."
        }

        $definition = $definitionLookup[$roleName]
        $shareName = [string]$definition.ShareName
        $managedPath = "{0}:\{1}" -f $expectedDrive.ToUpperInvariant(), [string]$definition.SharePathName
        $rolePrincipal = Resolve-HqSecurityPrincipalName -Principal ([string]$definition.Principal)
        $servicePrincipal = Resolve-HqSecurityPrincipalName -Principal ([string]$definition.ServiceAccount)
        $existingShare = @(Get-HqSmbShare -Name $shareName)
        $smbAction = 'Verified'
        $sharePath = $managedPath

        if ($existingShare.Count -eq 0) {
            Write-HqStatus -Phase "SMB" -Message ("Creating SMB share '{0}' for role '{1}' on path {2}..." -f $shareName, $roleName, $managedPath)
            Invoke-HqNativeNewSmbShare -Name $shareName -Path $managedPath -FullAccess @('BUILTIN\Administrators', $servicePrincipal)
            $smbAction = 'Created'
        } elseif ([string]$existingShare[0].Path -ne $managedPath) {
            $sharePath = [string]$existingShare[0].Path
            $smbAction = 'Adopted'
            Write-HqStatus -Phase "SMB" -Message ("Existing SMB share '{0}' already points to '{1}' instead of '{2}'. Reusing the existing share path." -f `
                $shareName, `
                $sharePath, `
                $managedPath) -Level Warning
        }

        Ensure-HqSmbShareAccessRule -ShareName $shareName -Principal $servicePrincipal -AccessRight ([string]$definition.ServiceAccessRight)
        Ensure-HqSmbShareAccessRule -ShareName $shareName -Principal $rolePrincipal -AccessRight ([string]$definition.AccessRight)

        Write-HqStatus -Phase "SMB" -Message ("SMB share '{0}' is ready for role '{1}'." -f $shareName, $roleName) -Level Success
        $results += [pscustomobject]@{
            DiskNumber = [int]$workflowResult.DiskNumber
            RoleName   = $roleName
            ShareName  = $shareName
            SharePath  = $sharePath
            SmbAction  = $smbAction
        }
    }

    return $results
}

# Subfunction: turn DOMAIN\name into the leaf name used by identity lookups.
function Get-HqSecurityPrincipalLeafName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Principal
    )

    if ($Principal -match '^[^\\]+\\(.+)$') {
        return $Matches[1]
    }

    return $Principal
}

function Test-HqSecurityPrincipalPasswordPromptRequired {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Definition
    )

    if ($Definition.PSObject.Properties['PasswordPromptRequired']) {
        return [bool]$Definition.PasswordPromptRequired
    }

    return $false
}

function Convert-HqSecureStringToPlainText {
    [CmdletBinding()]
    param(
        [System.Security.SecureString]$Value
    )

    if (-not $Value) {
        return ''
    }

    return [System.Net.NetworkCredential]::new('', $Value).Password
}

function Test-HqSecureStringHasValue {
    [CmdletBinding()]
    param(
        [System.Security.SecureString]$Value
    )

    return (Convert-HqSecureStringToPlainText -Value $Value).Length -gt 0
}

function Test-HqSecureStringMatches {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$Reference,

        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$Candidate
    )

    return (Convert-HqSecureStringToPlainText -Value $Reference) -ceq (Convert-HqSecureStringToPlainText -Value $Candidate)
}

function Read-HqSecurityPrincipalPassword {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Principal
    )

    while ($true) {
        $password = Read-Host -Prompt ("Enter password for new user '{0}'" -f $Principal) -AsSecureString
        if (-not (Test-HqSecureStringHasValue -Value $password)) {
            Write-HqStatus -Phase "Identity" -Message ("Password entry for '{0}' cannot be empty. Try again." -f $Principal) -Level Warning
            continue
        }

        $confirmation = Read-Host -Prompt ("Confirm password for new user '{0}'" -f $Principal) -AsSecureString
        if (-not (Test-HqSecureStringMatches -Reference $password -Candidate $confirmation)) {
            Write-HqStatus -Phase "Identity" -Message ("Password entries for '{0}' did not match. Try again." -f $Principal) -Level Warning
            continue
        }

        return $password
    }
}

function Test-HqActiveDirectoryCommandsAvailable {
    [CmdletBinding()]
    param()

    return [bool](
        (Get-Command Get-ADGroup -ErrorAction SilentlyContinue) -and
        (Get-Command Get-ADUser -ErrorAction SilentlyContinue) -and
        (Get-Command Get-ADPrincipalGroupMembership -ErrorAction SilentlyContinue)
    )
}

# Subfunction: keep increment-4 identity work on HQ-local principals even
# when the guest also exposes Active Directory cmdlets.
function Test-HqUseLocalSecurityPrincipals {
    [CmdletBinding()]
    param()

    return $true
}

function Get-HqActiveDirectoryGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $escapedName = $Name.Replace("'", "''")
    return Get-ADGroup -Filter ("SamAccountName -eq '{0}' -or Name -eq '{0}'" -f $escapedName) -ErrorAction Stop |
        Select-Object -First 1
}

function Get-HqActiveDirectoryUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $escapedName = $Name.Replace("'", "''")
    return Get-ADUser -Filter ("SamAccountName -eq '{0}'" -f $escapedName) -ErrorAction Stop |
        Select-Object -First 1
}

function Get-HqActiveDirectoryPrincipalGroupNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $user = Get-HqActiveDirectoryUser -Name $Name
    if (-not $user) {
        return @()
    }

    return @(
        Get-ADPrincipalGroupMembership -Identity $user -ErrorAction Stop |
        ForEach-Object { [string]$_.Name } |
        Where-Object { $_ }
    )
}

function Get-HqLocalGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $group = Get-LocalGroup -Name $Name -ErrorAction SilentlyContinue
    if ($group) {
        return $group
    }

    $group = (
        Get-LocalGroup -ErrorAction SilentlyContinue |
        Where-Object { $_ -and [string]$_.Name -eq $Name } |
        Select-Object -First 1
    )
    if ($group) {
        return $group
    }

    $group = Get-HqLocalSamPrincipal -Name $Name -Type 'Group'
    if ($group -and (Test-HqLocalPrincipalResolvableByLeafName -Name $Name)) {
        return $group
    }

    return $null
}

function Get-HqLocalUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $user = Get-LocalUser -Name $Name -ErrorAction SilentlyContinue
    if ($user) {
        return $user
    }

    $user = (
        Get-LocalUser -ErrorAction SilentlyContinue |
        Where-Object { $_ -and [string]$_.Name -eq $Name } |
        Select-Object -First 1
    )
    if ($user) {
        return $user
    }

    $user = Get-HqLocalSamPrincipal -Name $Name -Type 'User'
    if ($user -and (Test-HqLocalPrincipalResolvableByLeafName -Name $Name)) {
        return $user
    }

    return $null
}

function Test-HqLocalPrincipalResolvableByLeafName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return (Test-HqSecurityPrincipalResolvable -Principal ("{0}\{1}" -f $env:COMPUTERNAME, $Name))
}

function Get-HqLocalSamPrincipal {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Group', 'User')]
        [string]$Type
    )

    try {
        $computer = [ADSI]("WinNT://{0},computer" -f $env:COMPUTERNAME)
        $schemaClassName = if ($Type -eq 'Group') { 'group' } else { 'user' }

        return (
            $computer.psbase.Children |
            Where-Object {
                $_ -and
                [string]$_.SchemaClassName -eq $schemaClassName -and
                [string]$_.Name -eq $Name
            } |
            Select-Object -First 1
        )
    }
    catch {
        return $null
    }
}

function Get-HqLocalSamGroupNames {
    [CmdletBinding()]
    param()

    try {
        $computer = [ADSI]("WinNT://{0},computer" -f $env:COMPUTERNAME)

        return @(
            $computer.psbase.Children |
            Where-Object {
                $_ -and
                [string]$_.SchemaClassName -eq 'group' -and
                [string]$_.Name
            } |
            ForEach-Object { [string]$_.Name } |
            Select-Object -Unique
        )
    }
    catch {
        return @()
    }
}

function Get-HqLocalSamGroupMemberNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    $group = Get-HqLocalSamPrincipal -Name $GroupName -Type 'Group'
    if (-not $group) {
        return @()
    }

    try {
        return @(
            @($group.psbase.Invoke('Members')) |
            ForEach-Object {
                [string]$_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null)
            } |
            Where-Object { $_ } |
            Select-Object -Unique
        )
    }
    catch {
        return @()
    }
}

function Get-HqLocalGroupMemberNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    $members = @(
        Get-LocalGroupMember -Group $GroupName -ErrorAction SilentlyContinue |
        ForEach-Object { [string]$_.Name } |
        Where-Object { $_ }
    )
    $members += @(Get-HqLocalSamGroupMemberNames -GroupName $GroupName)

    return @(
        $members |
        ForEach-Object { Get-HqSecurityPrincipalLeafName -Principal ([string]$_) } |
        Where-Object { $_ } |
        Sort-Object -Unique
    )
}

function Get-HqManagedAccessGroupSummary {
    [CmdletBinding()]
    param()

    $groupNames = @(
        Get-HqRoleAclDefinitions |
        ForEach-Object { Get-HqSecurityPrincipalLeafName -Principal ([string]$_.Principal) } |
        Where-Object { $_ } |
        Sort-Object -Unique
    )

    return @(
        foreach ($groupName in $groupNames) {
            [pscustomobject]@{
                Group   = $groupName
                Members = (@(Get-HqLocalGroupMemberNames -GroupName $groupName) -join ', ')
            }
        }
    )
}

function Get-HqLocalSamMemberReferences {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $references = @()

    foreach ($type in @('User', 'Group')) {
        $principal = Get-HqLocalSamPrincipal -Name $Name -Type $type
        if (-not $principal) {
            continue
        }

        $principalName = if ($principal.PSObject.Properties['Name']) { [string]$principal.Name } else { $Name }
        $principalPath = if ($principal.PSObject.Properties['Path']) { [string]$principal.Path } else { $null }
        if ($principalPath) {
            $references += $principalPath
        }

        $references += @(
            ("WinNT://{0}/{1}" -f $env:COMPUTERNAME, $principalName)
            ("WinNT://./{0}" -f $principalName)
            ("WinNT://{0}/{1},{2}" -f $env:COMPUTERNAME, $principalName, $type.ToLowerInvariant())
            ("WinNT://./{0},{1}" -f $principalName, $type.ToLowerInvariant())
        )
    }

    if (@($references).Count -eq 0) {
        throw "Local principal '$Name' could not be resolved for local SAM membership management."
    }

    return @($references | Where-Object { $_ } | Select-Object -Unique)
}

function Invoke-HqNativeAddLocalSamGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $true)]
        [string]$Member
    )

    $groupObject = Get-HqLocalSamPrincipal -Name $Group -Type 'Group'
    if (-not $groupObject) {
        throw "Local group '$Group' could not be resolved through the local SAM provider."
    }

    $errors = @()

    foreach ($memberReference in @(Get-HqLocalSamMemberReferences -Name $Member)) {
        try {
            $groupObject.Add([string]$memberReference)
            return
        }
        catch {
            $errors += $_
        }
    }

    if ($errors.Count -gt 0) {
        throw $errors[-1]
    }
}

function Invoke-HqNativeRemoveLocalSamGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $true)]
        [string]$Member
    )

    $groupObject = Get-HqLocalSamPrincipal -Name $Group -Type 'Group'
    if (-not $groupObject) {
        throw "Local group '$Group' could not be resolved through the local SAM provider."
    }

    $errors = @()

    foreach ($memberReference in @(Get-HqLocalSamMemberReferences -Name $Member)) {
        try {
            $groupObject.Remove([string]$memberReference)
            return
        }
        catch {
            $errors += $_
        }
    }

    if ($errors.Count -gt 0) {
        throw $errors[-1]
    }
}

function Get-HqLocalPrincipalNameCollision {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Group', 'User')]
        [string]$ExpectedType
    )

    if ($ExpectedType -eq 'Group') {
        $other = Get-HqLocalUser -Name $Name
        if ($other) {
            return 'User'
        }
    } else {
        $other = Get-HqLocalGroup -Name $Name
        if ($other) {
            return 'Group'
        }
    }

    return $null
}

function Get-HqLocalPrincipalGroupNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $memberPatterns = @(
        $Name.ToLowerInvariant()
        ("{0}\{1}" -f $env:COMPUTERNAME, $Name).ToLowerInvariant()
    )

    $results = @()
    $groupNames = @(
        @(Get-LocalGroup -ErrorAction SilentlyContinue | ForEach-Object { [string]$_.Name } | Where-Object { $_ })
        @(Get-HqLocalSamGroupNames)
    ) | Select-Object -Unique

    foreach ($groupName in $groupNames) {
        $members = @(
            Get-LocalGroupMember -Group ([string]$groupName) -ErrorAction SilentlyContinue |
            ForEach-Object { [string]$_.Name } |
            Where-Object { $_ }
        )
        $members += @(Get-HqLocalSamGroupMemberNames -GroupName ([string]$groupName))
        $normalizedMembers = @($members | ForEach-Object { $_.ToLowerInvariant() })

        if (@($normalizedMembers | Where-Object { $memberPatterns -contains $_ }).Count -gt 0) {
            $results += [string]$groupName
        }
    }

    return @($results | Select-Object -Unique)
}

# Subfunction: read principal state from AD first, then fall back to local accounts.
function Get-HqSecurityPrincipalStateEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Principal,

        [Parameter(Mandatory = $true)]
        [string]$Type,

        [string[]]$ExpectedMemberOf,

        [switch]$AllowHiddenLocalSam
    )

    $name = Get-HqSecurityPrincipalLeafName -Principal $Principal
    $preferActiveDirectory = (-not (Test-HqUseLocalSecurityPrincipals)) -and (Test-HqActiveDirectoryCommandsAvailable)

    $exists = if ($Type -eq 'Group') {
        if ($preferActiveDirectory) {
            [bool](Get-HqActiveDirectoryGroup -Name $name)
        } else {
            [bool](Get-HqLocalGroup -Name $name)
        }
    } else {
        if ($preferActiveDirectory) {
            [bool](Get-HqActiveDirectoryUser -Name $name)
        } else {
            [bool](Get-HqLocalUser -Name $name)
        }
    }

    if ((-not $exists) -and (-not $preferActiveDirectory) -and $AllowHiddenLocalSam) {
        $exists = if ($Type -eq 'Group') {
            [bool](Get-HqLocalSamPrincipal -Name $name -Type 'Group')
        } else {
            [bool](Get-HqLocalSamPrincipal -Name $name -Type 'User')
        }
    }

    $memberOf = @()
    if ($Type -eq 'User' -and $preferActiveDirectory -and $exists) {
        $actualGroupNames = @(Get-HqActiveDirectoryPrincipalGroupNames -Name $name)
        $memberOf = @(
            foreach ($expectedGroup in @($ExpectedMemberOf)) {
                $expectedLeafName = Get-HqSecurityPrincipalLeafName -Principal $expectedGroup
                if ($actualGroupNames -contains $expectedLeafName) {
                    $expectedGroup
                }
            }
        )
    } elseif ($Type -eq 'User' -and $exists) {
        $actualGroupNames = @(Get-HqLocalPrincipalGroupNames -Name $name)
        $memberOf = @(
            foreach ($expectedGroup in @($ExpectedMemberOf)) {
                $expectedLeafName = Get-HqSecurityPrincipalLeafName -Principal $expectedGroup
                if ($actualGroupNames -contains $expectedLeafName) {
                    $expectedGroup
                }
            }
        )
    }

    return [pscustomobject]@{
        Principal        = $Principal
        Type             = $Type
        Name             = $name
        Exists           = $exists
        ExpectedMemberOf = @($ExpectedMemberOf)
        MemberOf         = @($memberOf)
    }
}

# Subfunction: export the current required-principal state for later comparison.
function Export-HqSecurityPrincipalState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [object[]]$Definitions
    )

    $principalStates = @(
        foreach ($definition in $Definitions) {
            Get-HqSecurityPrincipalStateEntry `
                -Principal ([string]$definition.Principal) `
                -Type ([string]$definition.Type) `
                -ExpectedMemberOf @($definition.ExpectedMemberOf)
        }
    )

    $state = [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME
        CreatedAtUtc = [DateTime]::UtcNow.ToString('o')
        Principals   = $principalStates
    }

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -Path $parent -ItemType Directory -Force | Out-Null
    }

    $state | ConvertTo-Json -Depth 5 | Set-Content -Path $Path -Encoding ASCII
}

# Subfunction: read the saved principal-state file through one shared boundary.
function Import-HqSecurityPrincipalState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "Security principal state file not found: $Path"
    }

    $state = Get-Content -Path $Path -Raw | ConvertFrom-Json
    if ($state -and $state.PSObject.Properties['CreatedAtUtc'] -and $state.CreatedAtUtc) {
        $state.CreatedAtUtc = ([DateTime]$state.CreatedAtUtc).ToString('o')
    }

    return $state
}

# Subfunction: let the guest save the current principal baseline without running the full workflow.
function Invoke-HqSecurityPrincipalStateBackup {
    [CmdletBinding()]
    param(
        [string]$Path = (Join-Path $PSScriptRoot 'HqSecurityState.json'),
        [string]$MetadataModulePath = (Join-Path $PSScriptRoot 'HqDiskMetadata.psm1')
    )

    Import-HqMetadataModuleIfPresent -Path $MetadataModulePath | Out-Null
    $definitions = @(Get-HqRequiredSecurityPrincipalDefinitions)
    Export-HqSecurityPrincipalState -Path $Path -Definitions $definitions
    return $Path
}

# Subfunction: let the guest restore required principals without running activation.
function Invoke-HqSecurityPrincipalStateRestore {
    [CmdletBinding()]
    param(
        [string]$MetadataModulePath = (Join-Path $PSScriptRoot 'HqDiskMetadata.psm1')
    )

    Import-HqMetadataModuleIfPresent -Path $MetadataModulePath | Out-Null
    return @(Ensure-HqSecurityPrincipals)
}

# Subfunction: let the guest run cleanup from the saved principal state without running activation.
function Invoke-HqSecurityPrincipalStateCleanup {
    [CmdletBinding()]
    param(
        [string]$Path = (Join-Path $PSScriptRoot 'HqSecurityState.json'),
        [string]$MetadataModulePath = (Join-Path $PSScriptRoot 'HqDiskMetadata.psm1')
    )

    Import-HqMetadataModuleIfPresent -Path $MetadataModulePath | Out-Null
    return @(Invoke-HqSecurityPrincipalCleanup -Path $Path)
}

# ---------------------------------------------------------------------
# Section: use the saved principal state to find work that can be
# undone without guessing what existed before this script ran.
# ---------------------------------------------------------------------

# Main function: build a cleanup plan from the saved state and the current state.
function Get-HqSecurityPrincipalCleanupPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Step: read the saved state that was captured before restore work ran.
    $savedState = Import-HqSecurityPrincipalState -Path $Path
    $savedLookup = @{}

    foreach ($savedPrincipal in @($savedState.Principals)) {
        $savedLookup[[string]$savedPrincipal.Principal] = $savedPrincipal
    }

    # Step: compare the required principal list against the current guest state.
    $results = @()
    $definitions = @(Get-HqRequiredSecurityPrincipalDefinitions)

    foreach ($definition in $definitions) {
        $principal = [string]$definition.Principal
        $savedPrincipal = $savedLookup[$principal]

        if (-not $savedPrincipal) {
            continue
        }

        $currentState = Get-HqSecurityPrincipalStateEntry `
            -Principal $principal `
            -Type ([string]$definition.Type) `
            -ExpectedMemberOf @($definition.ExpectedMemberOf)

        # Result: mark added group links before any whole principal removal.
        if ([string]$definition.Type -eq 'User') {
            foreach ($group in @($currentState.MemberOf)) {
                if (@($savedPrincipal.MemberOf) -notcontains [string]$group) {
                    $results += [pscustomobject]@{
                        Principal = $principal
                        Type      = [string]$currentState.Type
                        Name      = [string]$currentState.Name
                        Group     = [string]$group
                        Action    = 'RemoveMembership'
                    }
                }
            }
        }

        # Result: mark only principals that were absent before and exist now.
        if (-not [bool]$savedPrincipal.Exists -and [bool]$currentState.Exists) {
            $results += [pscustomobject]@{
                Principal = $principal
                Type      = [string]$currentState.Type
                Name      = [string]$currentState.Name
                Action    = 'RemovePrincipal'
            }
        }
    }

    return $results
}

# ---------------------------------------------------------------------
# Section: restore the required users, groups, and group links
# before later access rules and cleanup can rely on them.
# ---------------------------------------------------------------------

# Subfunction: create a missing required group.
function New-HqSecurityPrincipalGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ((-not (Test-HqUseLocalSecurityPrincipals)) -and (Test-HqActiveDirectoryCommandsAvailable)) {
        New-ADGroup -Name $Name -SamAccountName $Name -GroupScope Global -GroupCategory Security -ErrorAction Stop | Out-Null
        return
    }

    try {
        New-LocalGroup -Name $Name -ErrorAction Stop | Out-Null
    }
    catch {
        if (Get-HqLocalGroup -Name $Name) {
            return
        }

        $collisionType = Get-HqLocalPrincipalNameCollision -Name $Name -ExpectedType 'Group'
        if ($collisionType) {
            throw "Cannot create required group '$Name' because a local $($collisionType.ToLowerInvariant()) with the same name already exists."
        }

        if (Test-HqLocalPrincipalAlreadyExistsError -ErrorRecord $_) {
            return
        }

        throw
    }
}

# Subfunction: create a missing required user.
function New-HqSecurityPrincipalUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [System.Security.SecureString]$Password
    )

    if ((-not (Test-HqUseLocalSecurityPrincipals)) -and (Test-HqActiveDirectoryCommandsAvailable)) {
        if ($PSBoundParameters.ContainsKey('Password')) {
            New-ADUser -Name $Name -SamAccountName $Name -AccountPassword $Password -Enabled $true -ErrorAction Stop | Out-Null
        } else {
            New-ADUser -Name $Name -SamAccountName $Name -Enabled $false -ErrorAction Stop | Out-Null
        }
        return
    }

    try {
        if ($PSBoundParameters.ContainsKey('Password')) {
            New-LocalUser -Name $Name -Password $Password -ErrorAction Stop | Out-Null
        } else {
            New-LocalUser -Name $Name -NoPassword -ErrorAction Stop | Out-Null
        }
    }
    catch {
        if (Get-HqLocalUser -Name $Name) {
            return
        }

        $collisionType = Get-HqLocalPrincipalNameCollision -Name $Name -ExpectedType 'User'
        if ($collisionType) {
            throw "Cannot create required user '$Name' because a local $($collisionType.ToLowerInvariant()) with the same name already exists."
        }

        if (Test-HqLocalPrincipalAlreadyExistsError -ErrorRecord $_) {
            return
        }

        throw
    }
}

function Invoke-HqNativeAddLocalGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $true)]
        [string]$Member
    )

    try {
        Invoke-HqNativeLocalAccountsAddGroupMember -Group $Group -Member $Member
    }
    catch {
        try {
            Invoke-HqNativeAddLocalSamGroupMember -Group $Group -Member $Member
        }
        catch {
            if (@(Get-HqLocalSamGroupMemberNames -GroupName $Group) -contains $Member) {
                return
            }

            throw
        }
    }
}

function Invoke-HqNativeLocalAccountsAddGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $true)]
        [string]$Member
    )

    Add-LocalGroupMember -Group $Group -Member $Member -ErrorAction Stop
}

# Subfunction: add a user to a required group when that link is missing.
function Add-HqSecurityPrincipalToGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Principal,

        [Parameter(Mandatory = $true)]
        [string]$Group
    )

    $principalName = Get-HqSecurityPrincipalLeafName -Principal $Principal
    $groupName = Get-HqSecurityPrincipalLeafName -Principal $Group

    if ((-not (Test-HqUseLocalSecurityPrincipals)) -and (Test-HqActiveDirectoryCommandsAvailable)) {
        Add-ADGroupMember -Identity $groupName -Members $principalName -ErrorAction Stop
        return
    }

    Invoke-HqNativeAddLocalGroupMember -Group $groupName -Member $principalName
}

# Subfunction: remove a user from a group when cleanup needs to undo that link.
function Remove-HqSecurityPrincipalFromGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Principal,

        [Parameter(Mandatory = $true)]
        [string]$Group
    )

    $principalName = Get-HqSecurityPrincipalLeafName -Principal $Principal
    $groupName = Get-HqSecurityPrincipalLeafName -Principal $Group

    if ((-not (Test-HqUseLocalSecurityPrincipals)) -and (Test-HqActiveDirectoryCommandsAvailable)) {
        Remove-ADGroupMember -Identity $groupName -Members $principalName -Confirm:$false -ErrorAction Stop
        return
    }

    try {
        Invoke-HqNativeLocalAccountsRemoveGroupMember -Group $groupName -Member $principalName
    }
    catch {
        try {
            Invoke-HqNativeRemoveLocalSamGroupMember -Group $groupName -Member $principalName
        }
        catch {
            if (@(Get-HqLocalSamGroupMemberNames -GroupName $groupName) -notcontains $principalName) {
                return
            }

            throw
        }
    }
}

function Invoke-HqNativeLocalAccountsRemoveGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $true)]
        [string]$Member
    )

    Remove-LocalGroupMember -Group $Group -Member $Member -ErrorAction Stop
}

function Test-HqLocalPrincipalNotFoundError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$ErrorRecord
    )

    $message = if ($ErrorRecord.Exception -and $ErrorRecord.Exception.Message) {
        [string]$ErrorRecord.Exception.Message
    } else {
        [string]$ErrorRecord
    }

    foreach ($pattern in @(
        '(?i)\bgroup\b.*\bwas not found\b'
        '(?i)\buser\b.*\bwas not found\b'
        '(?i)\bmember\b.*\bwas not found\b'
        '(?i)\bprincipal\b.*\bwas not found\b'
        '(?i)\bcannot find (?:the )?(?:local )?(?:group|user|member|principal)\b'
    )) {
        if ($message -match $pattern) {
            return $true
        }
    }

    return $false
}

function Test-HqLocalPrincipalAlreadyExistsError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$ErrorRecord
    )

    $message = if ($ErrorRecord.Exception -and $ErrorRecord.Exception.Message) {
        [string]$ErrorRecord.Exception.Message
    } else {
        [string]$ErrorRecord
    }

    foreach ($pattern in @(
        '(?i)\balready exists\b'
        '(?i)\balready in use\b'
        '(?i)\baccount already exists\b'
        '(?i)\bgroup .* already exists\b'
        '(?i)\buser .* already exists\b'
        '(?i)\bname .* already in use\b'
    )) {
        if ($message -match $pattern) {
            return $true
        }
    }

    return $false
}

# Subfunction: remove a planned user after the operator confirms that exact deletion.
function Remove-HqSecurityPrincipalUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ((-not (Test-HqUseLocalSecurityPrincipals)) -and (Test-HqActiveDirectoryCommandsAvailable)) {
        Remove-ADUser -Identity $Name -Confirm:$false -ErrorAction Stop
        return
    }

    try {
        Remove-LocalUser -Name $Name -ErrorAction Stop
    }
    catch {
        if (Test-HqLocalPrincipalNotFoundError -ErrorRecord $_) {
            return
        }

        if (-not (Get-HqLocalUser -Name $Name)) {
            return
        }

        throw
    }
}

# Subfunction: remove a planned group after the operator confirms that exact deletion.
function Remove-HqSecurityPrincipalGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ((-not (Test-HqUseLocalSecurityPrincipals)) -and (Test-HqActiveDirectoryCommandsAvailable)) {
        Remove-ADGroup -Identity $Name -Confirm:$false -ErrorAction Stop
        return
    }

    try {
        Remove-LocalGroup -Name $Name -ErrorAction Stop
    }
    catch {
        if (Test-HqLocalPrincipalNotFoundError -ErrorRecord $_) {
            return
        }

        if (-not (Get-HqLocalGroup -Name $Name)) {
            return
        }

        throw
    }
}

# Subfunction: show the current whole-principal removal plan before any destructive confirmation starts.
function Show-HqSecurityPrincipalCleanupPlanTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Entries
    )

    if (@($Entries).Count -eq 0) {
        return
    }

    Write-Host ''
    Write-HqStatus -Phase "Identity" -Message "Planned whole-principal removals:" -Level Warning

    $rows = @(
        foreach ($entry in $Entries) {
            [pscustomobject]@{
                Principal = [string]$entry.Principal
                Type      = [string]$entry.Type
                Name      = [string]$entry.Name
                Action    = [string]$entry.Action
                Result    = [string]$entry.Result
            }
        }
    )

    $rows | Format-Table -AutoSize | Out-Host
}

# Subfunction: interpret yes-style answers for destructive confirmation prompts.
function Test-HqConfirmationAccepted {
    [CmdletBinding()]
    param(
        [string]$InputText
    )

    return @('y', 'yes') -contains ([string]$InputText).Trim().ToLowerInvariant()
}

# Main function: execute cleanup in one pass with safe link removal first,
# then operator-confirmed whole-principal deletion for users and groups.
function Invoke-HqSecurityPrincipalCleanup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Step: start from the saved-state cleanup plan.
    $plan = @(Get-HqSecurityPrincipalCleanupPlan -Path $Path)
    $results = @()

    foreach ($entry in $plan) {
        # Step: remove only added group links in this cleanup slice.
        if ([string]$entry.Action -eq 'RemoveMembership') {
            Write-HqStatus -Phase "Identity" -Message ("Removing group link '{0}' from '{1}'..." -f `
                [string]$entry.Group, `
                [string]$entry.Principal)
            Remove-HqSecurityPrincipalFromGroup -Principal ([string]$entry.Principal) -Group ([string]$entry.Group)
            Write-HqStatus -Phase "Identity" -Message ("Removed group link '{0}' from '{1}'." -f `
                [string]$entry.Group, `
                [string]$entry.Principal) -Level Success
            $results += [pscustomobject]@{
                Principal = [string]$entry.Principal
                Type      = [string]$entry.Type
                Name      = [string]$entry.Name
                Group     = [string]$entry.Group
                Action    = [string]$entry.Action
                Result    = 'Removed'
            }
            continue
        }

        # Result: collect whole-principal removals so the operator can review and confirm them later in this pass.
        $results += [pscustomobject]@{
            Principal = [string]$entry.Principal
            Type      = [string]$entry.Type
            Name      = [string]$entry.Name
            Group     = if ($entry.PSObject.Properties['Group']) { [string]$entry.Group } else { $null }
            Action    = [string]$entry.Action
            Result    = 'Planned'
        }
    }

    $plannedPrincipalResults = @(
        $results |
        Where-Object { [string]$_.Action -eq 'RemovePrincipal' }
    )
    if ($plannedPrincipalResults.Count -gt 0) {
        Show-HqSecurityPrincipalCleanupPlanTable -Entries $plannedPrincipalResults
    }

    $plannedUserResults = @(
        $plannedPrincipalResults |
        Where-Object { [string]$_.Type -eq 'User' }
    )
    if ($plannedUserResults.Count -gt 0) {
        $deleteUsers = Read-Host "Proceed with deleting the planned users first? [y/N]"
        if (Test-HqConfirmationAccepted -InputText $deleteUsers) {
            foreach ($entry in $plannedUserResults) {
                Write-HqStatus -Phase "Identity" -Message ("Planned principal '{0}' Type='{1}'." -f `
                    [string]$entry.Principal, `
                    [string]$entry.Type)
                $confirmUser = Read-Host ("Delete user '{0}' now? [y/N]" -f [string]$entry.Principal)
                if (Test-HqConfirmationAccepted -InputText $confirmUser) {
                    Remove-HqSecurityPrincipalUser -Name ([string]$entry.Name)
                    Write-HqStatus -Phase "Identity" -Message ("Removed user '{0}'." -f `
                        [string]$entry.Principal) -Level Success
                    $entry.Result = 'Removed'
                }
            }
        }
    }
    else {
        Write-HqStatus -Phase "Identity" -Message "No planned users are waiting for deletion."
    }

    $plannedGroupResults = @(
        $plannedPrincipalResults |
        Where-Object { [string]$_.Type -eq 'Group' }
    )
    if ($plannedGroupResults.Count -gt 0) {
        $deleteGroups = Read-Host "Proceed with deleting the planned groups now? [y/N]"
        if (Test-HqConfirmationAccepted -InputText $deleteGroups) {
            foreach ($entry in $plannedGroupResults) {
                Write-HqStatus -Phase "Identity" -Message ("Planned principal '{0}' Type='{1}'." -f `
                    [string]$entry.Principal, `
                    [string]$entry.Type)
                $confirmGroup = Read-Host ("Delete group '{0}' now? [y/N]" -f [string]$entry.Principal)
                if (Test-HqConfirmationAccepted -InputText $confirmGroup) {
                    Remove-HqSecurityPrincipalGroup -Name ([string]$entry.Name)
                    Write-HqStatus -Phase "Identity" -Message ("Removed group '{0}'." -f `
                        [string]$entry.Principal) -Level Success
                    $entry.Result = 'Removed'
                }
            }
        }
    }
    else {
        Write-HqStatus -Phase "Identity" -Message "No planned groups are waiting for deletion."
    }

    return $results
}

# Main function: restore required users, groups, and group links.
function Ensure-HqSecurityPrincipals {
    [CmdletBinding()]
    param()

    # Step: start with the required users and groups list.
    $definitions = @(Get-HqRequiredSecurityPrincipalDefinitions)
    $results = @()

    # Step: create or verify groups before users so required memberships never point
    # at a group that has not been created yet.
    $orderedDefinitions = @(
        $definitions |
        Sort-Object @{ Expression = { if ([string]$_.Type -eq 'Group') { 0 } else { 1 } } }, Principal
    )

    foreach ($definition in $orderedDefinitions) {
        # Check: read whether the current user or group already exists.
        $state = Get-HqSecurityPrincipalStateEntry `
            -Principal ([string]$definition.Principal) `
            -Type ([string]$definition.Type) `
            -ExpectedMemberOf @($definition.ExpectedMemberOf) `
            -AllowHiddenLocalSam

        $action = 'Unchanged'
        Write-HqStatus -Phase "Identity" -Message ("Checking required {0} '{1}'..." -f `
            ([string]$state.Type).ToLowerInvariant(), `
            [string]$state.Principal)

        if (-not $state.Exists) {
            # Step: create only the missing user or group.
            if ([string]$definition.Type -eq 'Group') {
                Write-HqStatus -Phase "Identity" -Message ("Creating missing group '{0}'..." -f `
                    [string]$state.Principal)
                New-HqSecurityPrincipalGroup -Name ([string]$state.Name)
            } else {
                Write-HqStatus -Phase "Identity" -Message ("Creating missing user '{0}'..." -f `
                    [string]$state.Principal)
                if (Test-HqSecurityPrincipalPasswordPromptRequired -Definition $definition) {
                    $password = Read-HqSecurityPrincipalPassword -Principal ([string]$state.Principal)
                    New-HqSecurityPrincipalUser -Name ([string]$state.Name) -Password $password
                } else {
                    New-HqSecurityPrincipalUser -Name ([string]$state.Name)
                }
            }

            # Check: confirm the created principal is now visible through the
            # same local-first lookup path the rest of the workflow relies on.
            $state = Get-HqSecurityPrincipalStateEntry `
                -Principal ([string]$definition.Principal) `
                -Type ([string]$definition.Type) `
                -ExpectedMemberOf @($definition.ExpectedMemberOf) `
                -AllowHiddenLocalSam
            if (-not $state.Exists) {
                throw "Required $(([string]$state.Type).ToLowerInvariant()) '$([string]$state.Principal)' could not be verified after creation."
            }

            $action = 'Created'
        }

        if ([string]$definition.Type -eq 'User') {
            # Step: add missing group links for existing users.
            foreach ($expectedGroup in @($state.ExpectedMemberOf)) {
                if (@($state.MemberOf) -notcontains [string]$expectedGroup) {
                    Write-HqStatus -Phase "Identity" -Message ("Adding missing group link '{0}' to '{1}'..." -f `
                        [string]$expectedGroup, `
                        [string]$state.Principal)
                    Add-HqSecurityPrincipalToGroup -Principal ([string]$state.Principal) -Group ([string]$expectedGroup)
                    $state = Get-HqSecurityPrincipalStateEntry `
                        -Principal ([string]$definition.Principal) `
                        -Type ([string]$definition.Type) `
                        -ExpectedMemberOf @($definition.ExpectedMemberOf) `
                        -AllowHiddenLocalSam
                    if (@($state.MemberOf) -notcontains [string]$expectedGroup) {
                        throw "Required group link '$expectedGroup' for '$([string]$state.Principal)' could not be verified after restore attempted to add it."
                    }
                    $action = if ($action -eq 'Created') { 'Created' } else { 'MembershipUpdated' }
                }
            }
        }

        if ($action -eq 'Unchanged') {
            Write-HqStatus -Phase "Identity" -Message ("Required {0} '{1}' is already in place." -f `
                ([string]$state.Type).ToLowerInvariant(), `
                [string]$state.Principal) -Level Success
        } elseif ($action -eq 'Created') {
            Write-HqStatus -Phase "Identity" -Message ("Required {0} '{1}' is now in place." -f `
                ([string]$state.Type).ToLowerInvariant(), `
                [string]$state.Principal) -Level Success
        } elseif ($action -eq 'MembershipUpdated') {
            Write-HqStatus -Phase "Identity" -Message ("Required group links for '{0}' are now in place." -f `
                [string]$state.Principal) -Level Success
        }

        # Result: return the final action for this user or group.
        $results += [pscustomobject]@{
            Principal        = [string]$state.Principal
            Type             = [string]$state.Type
            Name             = [string]$state.Name
            Exists           = [bool]$state.Exists
            ExpectedMemberOf = @($state.ExpectedMemberOf)
            MemberOf         = @($state.MemberOf)
            Action           = $action
        }
    }

    return $results
}

# Subfunction: check whether all required principals already exist before
# activation tries to apply ACLs without the optional restore step.
function Test-HqRequiredSecurityPrincipalsPresent {
    [CmdletBinding()]
    param()

    $definitions = @(Get-HqRequiredSecurityPrincipalDefinitions)

    foreach ($definition in $definitions) {
        $state = Get-HqSecurityPrincipalStateEntry `
            -Principal ([string]$definition.Principal) `
            -Type ([string]$definition.Type) `
            -ExpectedMemberOf @($definition.ExpectedMemberOf) `
            -AllowHiddenLocalSam

        if (-not [bool]$state.Exists) {
            return $false
        }
    }

    return $true
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        if ($ExportSecurityPrincipalState) {
            $path = Invoke-HqSecurityPrincipalStateBackup -Path $SecurityStatePath -MetadataModulePath $MetadataModulePath
            Write-HqStatus -Phase "Identity" -Message ("Security principal state backup complete: {0}" -f ([System.IO.Path]::GetFullPath($path))) -Level Success
        } elseif ($RunIdentityCleanup) {
            $results = @(Invoke-HqSecurityPrincipalStateCleanup -Path $SecurityStatePath -MetadataModulePath $MetadataModulePath)
            Write-HqStatus -Phase "Identity" -Message ("Identity cleanup step complete. Processed {0} cleanup row(s)." -f $results.Count) -Level Success
        } elseif ($RunActivation) {
            $results = Start-HqConfiguration -InstallMissingFeatures:$InstallMissingFeatures -RunIdentityRestore:$RunIdentityRestore -DiskNumbers $TargetDiskNumbers -MetadataModulePath $MetadataModulePath
            Show-HqRunSummary -Results $results
        } elseif ($RunIdentityRestore) {
            $results = @(Invoke-HqSecurityPrincipalStateRestore -MetadataModulePath $MetadataModulePath)
            Write-HqStatus -Phase "Identity" -Message ("Identity restore step complete. Processed {0} principal row(s)." -f $results.Count) -Level Success
        } else {
            Update-HqDiskMetadataModule -VmName $VmName -Path $MetadataModulePath
        }
    }
    catch {
        $message = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { [string]$_ }
        Write-HqStatus -Phase "Workflow" -Message $message -Level Error
        exit 1
    }
}

# ---------------------------------------------------------------------
# Section: discover safe Lab child and parent VHDX choices for iSCSI work
# ---------------------------------------------------------------------

# Main function: gather existing child and parent VHDX choices plus create-new defaults.
function Get-HqLabVhdDiscoveryChoices {
    [CmdletBinding()]
    param(
        [string]$ChildRootPath = '\\10.100.0.10\lab\virtual hdds frontends',
        [string]$ParentRootPath = '\\10.100.0.10\lab\virtual hdds'
    )

    # Start each choice list with the create-new option.
    $childChoices = @(
        [pscustomobject]@{
            Action        = 'CreateNew'
            ChoiceType    = 'ChildVhdx'
            Path          = $null
            Name          = $null
            DirectoryPath = $ChildRootPath
        }
    )

    # Add every existing child VHDX under the frontend share.
    $childChoices += @(
        Get-ChildItem -Path $ChildRootPath -Recurse -File -Filter '*.vhdx' -ErrorAction SilentlyContinue |
            ForEach-Object {
                [pscustomobject]@{
                    Action        = 'UseExisting'
                    ChoiceType    = 'ChildVhdx'
                    Path          = [string]$_.FullName
                    Name          = [string]$_.Name
                    DirectoryPath = [string]$_.DirectoryName
                }
            }
    )

    # Start the parent choice list with the create-new option.
    $parentChoices = @(
        [pscustomobject]@{
            Action        = 'CreateNew'
            ChoiceType    = 'ParentVhdx'
            Path          = $null
            Name          = $null
            DirectoryPath = $ParentRootPath
        }
    )

    # Add every existing parent VHDX under the base-image share.
    $parentChoices += @(
        Get-ChildItem -Path $ParentRootPath -Recurse -File -Filter '*.vhdx' -ErrorAction SilentlyContinue |
            ForEach-Object {
                [pscustomobject]@{
                    Action        = 'UseExisting'
                    ChoiceType    = 'ParentVhdx'
                    Path          = [string]$_.FullName
                    Name          = [string]$_.Name
                    DirectoryPath = [string]$_.DirectoryName
                }
            }
    )

    # Return only the discovery data for this slice.
    [pscustomobject]@{
        ChildRootPath  = $ChildRootPath
        ParentRootPath = $ParentRootPath
        ChildChoices   = @($childChoices)
        ParentChoices  = @($parentChoices)
    }
}