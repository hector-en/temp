Describe "configure_hq - Increment 1 Disk Discovery and Activation" {
    . "$PSScriptRoot\..\configure_hq.ps1"
    $repoTempDir = Join-Path $PSScriptRoot '..\temp'

    Context "Get-HqAttachedDataDisks" {
        It "returns only data disks by default" {
            # Setup: mirror the HQ VM layout with one OS disk and three data disks.
            $disks = @(
                [pscustomobject]@{ Number = 0; SourceVhd = 'V:\VHDs\disks\HQ\HQ2025.vhdx'; IsSystem = $true; IsBoot = $true; IsOffline = $false; IsReadOnly = $false }
                [pscustomobject]@{ Number = 1; SourceVhd = 'M:\repository1.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $true; IsReadOnly = $true }
                [pscustomobject]@{ Number = 2; SourceVhd = 'W:\vmdisk.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $false; IsReadOnly = $false }
                [pscustomobject]@{ Number = 3; SourceVhd = 'X:\backup1.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $false; IsReadOnly = $false }
            )

            $result = Get-HqAttachedDataDisks -Disks $disks

            # Check: only the three data disks should remain.
            $result.Count | Should Be 3
            ($result | Select-Object -ExpandProperty Number) -join "," | Should Be "1,2,3"
        }

        It "filters by requested disk numbers" {
            # Setup: reuse the same layout and ask for only selected data disks.
            $disks = @(
                [pscustomobject]@{ Number = 0; SourceVhd = 'V:\VHDs\disks\HQ\HQ2025.vhdx'; IsSystem = $true; IsBoot = $true; IsOffline = $false; IsReadOnly = $false }
                [pscustomobject]@{ Number = 1; SourceVhd = 'M:\repository1.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $true; IsReadOnly = $true }
                [pscustomobject]@{ Number = 2; SourceVhd = 'W:\vmdisk.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $false; IsReadOnly = $false }
                [pscustomobject]@{ Number = 3; SourceVhd = 'X:\backup1.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $false; IsReadOnly = $false }
            )

            $result = Get-HqAttachedDataDisks -Disks $disks -DiskNumbers @(2, 3)

            $result.Count | Should Be 2
            $result[0].Number | Should Be 2
            $result[1].Number | Should Be 3
        }

        It "uses Get-Disk when disks are not injected" {
            # Setup: cover the real path where the script calls Get-Disk.
            Mock Get-Disk {
                @([pscustomobject]@{ Number = 5; IsSystem = $false; IsBoot = $false })
            }

            $result = Get-HqAttachedDataDisks

            $result.Count | Should Be 1
            $result[0].Number | Should Be 5
            Assert-MockCalled Get-Disk -Times 1 -Exactly
        }
    }

    Context "Bring-HqDisksOnline" {
        It "calls Set-Disk for offline or read-only disks" {
            # Setup: mirror discovered data disks with mixed activation state.
            Mock Set-Disk {}
            Mock Get-Partition {
                switch ($DiskNumber) {
                    1 { @([pscustomobject]@{ DriveLetter = 'M' }) }
                    2 { @([pscustomobject]@{ DriveLetter = 'W' }) }
                    3 { @([pscustomobject]@{ DriveLetter = 'X' }) }
                }
            }

            $disks = @(
                [pscustomobject]@{ Number = 1; SourceVhd = 'M:\repository1.vhdx'; FriendlyName = 'repository1'; Size = 214748364800; IsOffline = $true; IsReadOnly = $true },
                [pscustomobject]@{ Number = 2; SourceVhd = 'W:\vmdisk.vhdx'; FriendlyName = 'vmdisk'; Size = 536870912000; IsOffline = $false; IsReadOnly = $false },
                [pscustomobject]@{ Number = 3; SourceVhd = 'X:\backup1.vhdx'; FriendlyName = 'backup1'; Size = 1073741824000; IsOffline = $false; IsReadOnly = $true }
            )

            $result = Bring-HqDisksOnline -Disks $disks

            $result.Count | Should Be 3
            ($result | Where-Object { $_.Action -eq "Updated" }).Count | Should Be 2
            $result[0].DiskName | Should Be 'repository1'
            $result[0].SizeGB | Should Be 200
            $result[0].DriveLetters | Should Be 'M'
            $result[2].DriveLetters | Should Be 'X'
            Assert-MockCalled Set-Disk -Times 3 -Exactly
            Assert-MockCalled Get-Partition -Times 5 -Exactly -Scope It
            Assert-MockCalled Set-Disk -Times 1 -Exactly -ParameterFilter { $Number -eq 1 -and $IsOffline -eq $false }
            Assert-MockCalled Set-Disk -Times 1 -Exactly -ParameterFilter { $Number -eq 1 -and $IsReadOnly -eq $false }
            Assert-MockCalled Set-Disk -Times 1 -Exactly -ParameterFilter { $Number -eq 3 -and $IsReadOnly -eq $false }
        }

        It "refreshes drive letters after bringing a disk online" {
            Mock Set-Disk {}
            $script:partitionReads = 0
            Mock Get-Partition {
                $script:partitionReads++
                if ($script:partitionReads -eq 1) {
                    return @()
                }

                return @([pscustomobject]@{ DriveLetter = 'W' })
            }

            $disks = @(
                [pscustomobject]@{
                    Number = 2
                    SourceVhd = 'W:\vmdisk.vhdx'
                    FriendlyName = 'vmdisk'
                    Size = 536870912000
                    IsOffline = $true
                    IsReadOnly = $false
                }
            )

            $result = Bring-HqDisksOnline -Disks $disks

            $result.Count | Should Be 1
            $result[0].Action | Should Be 'Updated'
            $result[0].DriveLetters | Should Be 'W'
            Assert-MockCalled Get-Partition -Times 2 -Exactly -Scope It
        }
    }

    Context "Invoke-HqDiskActivation" {
        It "orchestrates discovery, activation, imported role mapping, and validation warnings" {
            # Setup: mock collaborators so this test only checks orchestration.
            Mock Write-HqStatus {}
            Mock Get-HqAttachedDataDisks {
                @(
                    [pscustomobject]@{ Number = 1; SourceVhd = 'M:\repository1.vhdx'; IsOffline = $true; IsReadOnly = $true }
                    [pscustomobject]@{ Number = 2; SourceVhd = 'W:\vmdisk.vhdx'; IsOffline = $false; IsReadOnly = $false }
                    [pscustomobject]@{ Number = 3; SourceVhd = 'X:\backup1.vhdx'; IsOffline = $false; IsReadOnly = $true }
                )
            }
            Mock Bring-HqDisksOnline {
                @(
                    [pscustomobject]@{ DiskNumber = 1; Action = "Updated" }
                    [pscustomobject]@{ DiskNumber = 2; Action = "Unchanged" }
                    [pscustomobject]@{ DiskNumber = 3; Action = "Updated" }
                )
            }
            Mock Import-HqDiskMetadataDefinitions {
                @(
                    [pscustomobject]@{ SourceVhd = 'M:\repository1.vhdx'; RoleName = 'Repository'; ExpectedDriveLetter = 'R'; DedupEnabled = $false }
                    [pscustomobject]@{ SourceVhd = 'W:\vmdisk.vhdx'; RoleName = 'Lab'; ExpectedDriveLetter = 'W'; DedupEnabled = $true }
                    [pscustomobject]@{ SourceVhd = 'X:\backup1.vhdx'; RoleName = 'Backups'; ExpectedDriveLetter = 'B'; DedupEnabled = $false }
                    [pscustomobject]@{ SourceVhd = 'V:\VHDs\disks\sharedisk.vhdx'; RoleName = 'ShareDrive'; ExpectedDriveLetter = 'Z'; DedupEnabled = $false }
                )
            }
            Mock Get-HqDiskRoleMap {
                @(
                    [pscustomobject]@{ DiskNumber = 1; SourceVhd = 'M:\repository1.vhdx'; RoleName = 'Repository'; ExpectedDriveLetter = 'R'; DedupEnabled = $false }
                    [pscustomobject]@{ DiskNumber = 2; SourceVhd = 'W:\vmdisk.vhdx'; RoleName = 'Lab'; ExpectedDriveLetter = 'W'; DedupEnabled = $true }
                    [pscustomobject]@{ DiskNumber = 3; SourceVhd = 'X:\backup1.vhdx'; RoleName = 'Backups'; ExpectedDriveLetter = 'B'; DedupEnabled = $false }
                )
            }

            $result = Invoke-HqDiskActivation -DiskNumbers @(1, 2, 3)

            $result.Count | Should Be 3
            $result[0].DiskNumber | Should Be 1
            $result[1].DiskNumber | Should Be 2
            $result[2].DiskNumber | Should Be 3
            $result[0].RoleName | Should Be 'Repository'
            $result[1].ExpectedDriveLetter | Should Be 'W'
            $result[1].DedupEnabled | Should Be $true
            Assert-MockCalled Get-HqAttachedDataDisks -Times 1 -Exactly -ParameterFilter { ($DiskNumbers -join ',') -eq '1,2,3' }
            Assert-MockCalled Bring-HqDisksOnline -Times 1 -Exactly
            Assert-MockCalled Import-HqDiskMetadataDefinitions -Times 1 -Exactly
            Assert-MockCalled Get-HqDiskRoleMap -Times 1 -Exactly
            Assert-MockCalled Write-HqStatus -Times 1 -Exactly -ParameterFilter { $Phase -eq 'Validation' -and $Level -eq 'Warning' -and $Message -like '*ShareDrive*' }
        }
    }

    Context "Start-HqConfiguration" {
        It "uses activation and dedup orchestration as the guarded entrypoint" {
            Mock Invoke-HqDiskActivation {
                @(
                    [pscustomobject]@{ DiskNumber = 1; Action = "Updated"; DedupEnabled = $false }
                    [pscustomobject]@{ DiskNumber = 2; Action = "Unchanged"; DedupEnabled = $true }
                )
            }
            Mock Enable-HqDiskDeduplication {
                @(
                    [pscustomobject]@{ DiskNumber = 2; DedupAction = 'Enabled'; DedupVolume = 'W:' }
                )
            }
            Mock Test-HqRequiredSecurityPrincipalsPresent { $true }
            Mock Ensure-HqRoleAcl { @() }
            Mock Ensure-HqSmbShares { @() }

            $result = Start-HqConfiguration -DiskNumbers @(1, 2)

            $result.Count | Should Be 2
            $result[0].DiskNumber | Should Be 1
            $result[1].DiskNumber | Should Be 2
            $result[0].DedupAction | Should Be 'NotRequired'
            $result[1].DedupAction | Should Be 'Enabled'
            Assert-MockCalled Invoke-HqDiskActivation -Times 1 -Exactly -ParameterFilter { ($DiskNumbers -join ',') -eq '1,2' }
            Assert-MockCalled Enable-HqDiskDeduplication -Times 1 -Exactly
            Assert-MockCalled Ensure-HqRoleAcl -Times 1 -Exactly
            Assert-MockCalled Ensure-HqSmbShares -Times 1 -Exactly
        }

        It "adds identity and ACL status to workflow rows for the final summary" {
            Mock Invoke-HqDiskActivation {
                @(
                    [pscustomobject]@{
                        DiskNumber          = 1
                        Action              = "Updated"
                        DedupEnabled        = $false
                        RoleName            = 'Repository'
                        ExpectedDriveLetter = 'R'
                        DriveLetters        = 'R'
                    }
                )
            }
            Mock Ensure-HqSecurityPrincipals {
                @([pscustomobject]@{ Action = 'Created' })
            }
            Mock Enable-HqDiskDeduplication { @() }
            Mock Ensure-HqRoleAcl {
                @(
                    [pscustomobject]@{
                        DiskNumber  = 1
                        ManagedPath = 'R:\Shares\repository'
                        AclAction   = 'Applied'
                    }
                )
            }
            Mock Ensure-HqSmbShares {
                @(
                    [pscustomobject]@{
                        DiskNumber = 1
                        ShareName  = 'repository'
                        SmbAction  = 'Created'
                    }
                )
            }

            $result = Start-HqConfiguration -DiskNumbers @(1) -RunIdentityRestore

            $result.Count | Should Be 1
            $result[0].IdentityAction | Should Be 'Updated'
            $result[0].AclAction | Should Be 'Applied'
            $result[0].ManagedPath | Should Be 'R:\Shares\repository'
            $result[0].SmbAction | Should Be 'Created'
            $result[0].ShareName | Should Be 'repository'
        }

        It "restores required identities only when the workflow switch asks for it" {
            # ---------------------------------------------------------------------
            # Section: restore required identities only when the operator
            # asks for that step during activation.
            # ---------------------------------------------------------------------

            # Setup: keep the disk step and the later volume step fixed so this test only checks the new switch.
            Mock Invoke-HqDiskActivation {
                @(
                    [pscustomobject]@{ DiskNumber = 1; Action = "Updated"; DedupEnabled = $false }
                )
            }
            Mock Ensure-HqSecurityPrincipals {}
            Mock Enable-HqDiskDeduplication { @() }
            Mock Ensure-HqRoleAcl { @() }
            Mock Ensure-HqSmbShares { @() }

            # Step: run the workflow with the identity-restore switch.
            $null = Start-HqConfiguration -DiskNumbers @(1) -RunIdentityRestore

            # Check: restore identities only when that switch is requested.
            Assert-MockCalled Invoke-HqDiskActivation -Times 1 -Exactly -Scope It
            Assert-MockCalled Ensure-HqSecurityPrincipals -Times 1 -Exactly -Scope It
            Assert-MockCalled Enable-HqDiskDeduplication -Times 1 -Exactly -Scope It
            Assert-MockCalled Ensure-HqRoleAcl -Times 1 -Exactly -Scope It
            Assert-MockCalled Ensure-HqSmbShares -Times 1 -Exactly -Scope It
        }

        It "applies the access rules during activation after the volume step is done" {
            # ---------------------------------------------------------------------
            # Section: apply access rules as part of activation after the
            # storage work is finished and the final workflow rows are ready.
            # ---------------------------------------------------------------------

            # Setup: keep the disk step and the later volume step fixed so this test only checks the access-rule call.
            Mock Invoke-HqDiskActivation {
                @(
                    [pscustomobject]@{
                        DiskNumber          = 1
                        Action              = "Updated"
                        DedupEnabled        = $false
                        RoleName            = 'Repository'
                        ExpectedDriveLetter = 'R'
                        DriveLetters        = 'R'
                    }
                )
            }
            Mock Enable-HqDiskDeduplication { @() }
            Mock Test-HqRequiredSecurityPrincipalsPresent { $true }
            Mock Ensure-HqRoleAcl { @() }
            Mock Ensure-HqSmbShares { @() }

            # Step: run the activation workflow without the optional identity step.
            $null = Start-HqConfiguration -DiskNumbers @(1)

            # Check: apply the access rules once the final workflow rows are ready.
            Assert-MockCalled Invoke-HqDiskActivation -Times 1 -Exactly -Scope It
            Assert-MockCalled Enable-HqDiskDeduplication -Times 1 -Exactly -Scope It
            Assert-MockCalled Ensure-HqRoleAcl -Times 1 -Exactly -Scope It
            Assert-MockCalled Ensure-HqSmbShares -Times 1 -Exactly -Scope It
        }

        It "publishes SMB shares during activation after ACL paths are ready" {
            Mock Invoke-HqDiskActivation {
                @(
                    [pscustomobject]@{
                        DiskNumber          = 1
                        Action              = "Updated"
                        DedupEnabled        = $false
                        RoleName            = 'Repository'
                        ExpectedDriveLetter = 'R'
                        DriveLetters        = 'R'
                    }
                )
            }
            Mock Enable-HqDiskDeduplication { @() }
            Mock Test-HqRequiredSecurityPrincipalsPresent { $true }
            Mock Ensure-HqRoleAcl {
                @(
                    [pscustomobject]@{
                        DiskNumber  = 1
                        ManagedPath = 'R:\Shares\repository'
                        AclAction   = 'Applied'
                    }
                )
            }
            Mock Ensure-HqSmbShares {
                @(
                    [pscustomobject]@{
                        DiskNumber = 1
                        ShareName  = 'repository'
                        SharePath  = 'R:\Shares\repository'
                        SmbAction  = 'Created'
                    }
                )
            }

            $result = Start-HqConfiguration -DiskNumbers @(1)

            $result[0].SmbAction | Should Be 'Created'
            $result[0].ShareName | Should Be 'repository'
            Assert-MockCalled Ensure-HqSmbShares -Times 1 -Exactly -Scope It -ParameterFilter {
                @($WorkflowResults).Count -eq 1 -and [string]$WorkflowResults[0].ManagedPath -eq 'R:\Shares\repository'
            }
        }

        It "fails clearly when activation needs missing principals and restore was not requested" {
            # ---------------------------------------------------------------------
            # Section: stop before the ACL phase when activation was not asked
            # to restore identities and the required principals are still missing.
            # ---------------------------------------------------------------------

            Mock Invoke-HqDiskActivation {
                @(
                    [pscustomobject]@{
                        DiskNumber          = 1
                        Action              = "Updated"
                        DedupEnabled        = $false
                        RoleName            = 'Repository'
                        ExpectedDriveLetter = 'R'
                        DriveLetters        = 'R'
                    }
                )
            }
            Mock Enable-HqDiskDeduplication { @() }
            Mock Test-HqRequiredSecurityPrincipalsPresent { $false }
            Mock Ensure-HqRoleAcl {}

            {
                Start-HqConfiguration -DiskNumbers @(1)
            } | Should Throw "Required HQ principals are missing on this guest. Run .\configure_hq.ps1 -RunIdentityRestore first, or rerun activation with -RunIdentityRestore."

            Assert-MockCalled Ensure-HqRoleAcl -Times 0 -Exactly -Scope It
        }

        It "ignores identity rows that do not expose an Action property" {
            $result = Get-HqIdentityWorkflowAction -RestoreRequested -Results @(
                [pscustomobject]@{ Principal = 'HQ\svc_lab' }
                [pscustomobject]@{ Principal = 'HQ\hector'; Action = 'Created' }
            )

            $result | Should Be 'Updated'
        }
    }
}

Describe "Increment 2 VHD Role Mapping" {
    . "$PSScriptRoot\..\configure_hq.ps1"

    Context "Get-HqDiskRoleMap" {
        It "maps known SourceVhd values to server roles" {
            # Setup: cover the known SourceVhd to RoleName mapping.
            $disks = @(
                [pscustomobject]@{ Number = 1; SourceVhd = 'M:\repository1.vhdx' }
                [pscustomobject]@{ Number = 2; SourceVhd = 'W:\vmdisk.vhdx' }
                [pscustomobject]@{ Number = 3; SourceVhd = 'X:\backup1.vhdx' }
                [pscustomobject]@{ Number = 4; SourceVhd = 'V:\VHDs\disks\sharedisk.vhdx' }
            )

            $result = Get-HqDiskRoleMap -Disks $disks

            $result.Count | Should Be 4
            ($result | Where-Object { $_.DiskNumber -eq 1 }).SourceVhd | Should Be 'M:\repository1.vhdx'
            ($result | Where-Object { $_.DiskNumber -eq 2 }).SourceVhd | Should Be 'W:\vmdisk.vhdx'
            ($result | Where-Object { $_.DiskNumber -eq 3 }).SourceVhd | Should Be 'X:\backup1.vhdx'
            ($result | Where-Object { $_.DiskNumber -eq 4 }).SourceVhd | Should Be 'V:\VHDs\disks\sharedisk.vhdx'
            ($result | Where-Object { $_.DiskNumber -eq 1 }).RoleName | Should Be 'Repository'
            ($result | Where-Object { $_.DiskNumber -eq 2 }).RoleName | Should Be 'Lab'
            ($result | Where-Object { $_.DiskNumber -eq 3 }).RoleName | Should Be 'Backups'
            ($result | Where-Object { $_.DiskNumber -eq 4 }).RoleName | Should Be 'ShareDrive'
            ($result | Where-Object { $_.DiskNumber -eq 1 }).ExpectedDriveLetter | Should Be 'R'
            ($result | Where-Object { $_.DiskNumber -eq 2 }).ExpectedDriveLetter | Should Be 'W'
            ($result | Where-Object { $_.DiskNumber -eq 3 }).ExpectedDriveLetter | Should Be 'B'
            ($result | Where-Object { $_.DiskNumber -eq 4 }).ExpectedDriveLetter | Should Be 'Z'
            ($result | Where-Object { $_.DiskNumber -eq 1 }).DedupEnabled | Should Be $false
            ($result | Where-Object { $_.DiskNumber -eq 2 }).DedupEnabled | Should Be $true
            ($result | Where-Object { $_.DiskNumber -eq 3 }).DedupEnabled | Should Be $false
            ($result | Where-Object { $_.DiskNumber -eq 4 }).DedupEnabled | Should Be $false
        }

        It "maps guest disks by drive letters when SourceVhd is not available" {
            $disks = @(
                [pscustomobject]@{ Number = 1; FriendlyName = 'Msft Virtual Disk'; DriveLetters = 'R' }
                [pscustomobject]@{ Number = 2; FriendlyName = 'Msft Virtual Disk'; DriveLetters = 'W' }
                [pscustomobject]@{ Number = 3; FriendlyName = 'Msft Virtual Disk'; DriveLetters = 'B,F' }
            )

            $result = Get-HqDiskRoleMap -Disks $disks

            $result.Count | Should Be 3
            ($result | Where-Object { $_.DiskNumber -eq 1 }).RoleName | Should Be 'Repository'
            ($result | Where-Object { $_.DiskNumber -eq 2 }).RoleName | Should Be 'Lab'
            ($result | Where-Object { $_.DiskNumber -eq 3 }).RoleName | Should Be 'Backups'
            ($result | Where-Object { $_.DiskNumber -eq 1 }).ExpectedDriveLetter | Should Be 'R'
            ($result | Where-Object { $_.DiskNumber -eq 2 }).ExpectedDriveLetter | Should Be 'W'
            ($result | Where-Object { $_.DiskNumber -eq 3 }).ExpectedDriveLetter | Should Be 'B'
            ($result | Where-Object { $_.DiskNumber -eq 2 }).DedupEnabled | Should Be $true
        }

        It "fails clearly for an unknown SourceVhd" {
            # Setup: cover the failure path for an unmapped VHD.
            $disks = @(
                [pscustomobject]@{ Number = 9; SourceVhd = 'Q:\unknown.vhdx' }
            )

            { Get-HqDiskRoleMap -Disks $disks } | Should Throw 'Unknown disk role mapping for VHD path: Q:\unknown.vhdx'
        }
    }
}

Describe "Increment 2 Host Metadata Module" {
    . "$PSScriptRoot\..\configure_hq.ps1"
    $repoTempDir = Join-Path $PSScriptRoot '..\temp'

    BeforeEach {
        Remove-Module HqDiskMetadata -ErrorAction SilentlyContinue
    }

    AfterEach {
        Remove-Module HqDiskMetadata -ErrorAction SilentlyContinue
    }

    Context "Update-HqDiskMetadataModule" {
        It "fails clearly when host metadata commands are unavailable" {
            if (Test-Path $repoTempDir) {
                Remove-Item $repoTempDir -Recurse -Force
            }
            $modulePath = Join-Path $repoTempDir 'HqDiskMetadata.psm1'

            Mock Test-HqHostMetadataCommandsAvailable { $false }

            { Update-HqDiskMetadataModule -Path $modulePath } | Should Throw "Hyper-V host metadata commands are not available in this session. Run this command on the Hyper-V host, or run .\configure_hq.ps1 -RunActivation on the guest."
        }

        It "shows a VM selection menu and writes selected VM role definitions when no VM is provided" {
            if (Test-Path $repoTempDir) {
                Remove-Item $repoTempDir -Recurse -Force
            }
            $modulePath = Join-Path $repoTempDir 'HqDiskMetadata.psm1'

            Mock Test-HqHostMetadataCommandsAvailable { $true }
            Mock Get-VMHardDiskDrive {
                if ($VmName -eq '*') {
                    @(
                        [pscustomobject]@{ VMName = 'HQ-DC01'; Path = 'M:\repository1.vhdx' }
                        [pscustomobject]@{ VMName = 'OtherVm'; Path = 'D:\otherdisk.vhdx' }
                    )
                    return
                }

                @(
                    [pscustomobject]@{ VMName = 'HQ-DC01'; Path = 'M:\repository1.vhdx' }
                    [pscustomobject]@{ VMName = 'HQ-DC01'; Path = 'W:\vmdisk.vhdx' }
                    [pscustomobject]@{ VMName = 'HQ-DC01'; Path = 'X:\backup1.vhdx' }
                    [pscustomobject]@{ VMName = 'HQ-DC01'; Path = 'V:\VHDs\disks\sharedisk.vhdx' }
                )
            }
            Mock Read-Host { '1' }

            $result = Update-HqDiskMetadataModule -Path $modulePath
            $imported = Import-HqDiskMetadataDefinitions -Path $modulePath
            $config = Get-HqDiskMetadataConfig

            (Test-Path $modulePath) | Should Be $true
            $result.Count | Should Be 4
            $config.AvailableVmNames.Count | Should Be 2
            ($config.AvailableVmNames -join ',') | Should Be 'HQ-DC01,OtherVm'
            $config.SelectedVmName | Should Be 'HQ-DC01'
            $config.RoleDefinitions.Count | Should Be 4
            $config.RoleAclDefinitions.Count | Should Be 4
            $config.SecurityPrincipalDefinitions.Count | Should Be 7
            @(Get-HqRoleAclMetadataDefinitions).Count | Should Be 4
            @(Get-HqSecurityPrincipalMetadataDefinitions).Count | Should Be 7
            ($imported | Select-Object -First 1).VmName | Should Be 'HQ-DC01'
            Assert-MockCalled Get-VMHardDiskDrive -Times 1 -Exactly -ParameterFilter { $VmName -eq '*' }
            Assert-MockCalled Get-VMHardDiskDrive -Times 1 -Exactly -ParameterFilter { $VmName -eq 'HQ-DC01' }
            Assert-MockCalled Read-Host -Times 1 -Exactly
        }

        It "writes selected VM role definitions when a VM name is provided" {
            if (Test-Path $repoTempDir) {
                Remove-Item $repoTempDir -Recurse -Force
            }
            $modulePath = Join-Path $repoTempDir 'HqDiskMetadata.psm1'

            Mock Test-HqHostMetadataCommandsAvailable { $true }
            Mock Get-VMHardDiskDrive {
                if ($VmName -eq '*') {
                    @(
                        [pscustomobject]@{ VMName = 'HQ-DC01'; Path = 'M:\repository1.vhdx' }
                        [pscustomobject]@{ VMName = 'OtherVm'; Path = 'D:\otherdisk.vhdx' }
                    )
                    return
                }

                @(
                    [pscustomobject]@{ Path = 'M:\repository1.vhdx' }
                    [pscustomobject]@{ Path = 'W:\vmdisk.vhdx' }
                    [pscustomobject]@{ Path = 'X:\backup1.vhdx' }
                    [pscustomobject]@{ Path = 'V:\VHDs\disks\sharedisk.vhdx' }
                )
            }

            $result = Update-HqDiskMetadataModule -VmName 'HQ-DC01' -Path $modulePath
            $imported = Import-HqDiskMetadataDefinitions -Path $modulePath
            $config = Get-HqDiskMetadataConfig

            (Test-Path $modulePath) | Should Be $true
            $result.Count | Should Be 4
            $imported.Count | Should Be 4
            $config.SelectedVmName | Should Be 'HQ-DC01'
            $config.RoleAclDefinitions.Count | Should Be 4
            $config.SecurityPrincipalDefinitions.Count | Should Be 7
            ($imported | Select-Object -First 1).VmName | Should Be 'HQ-DC01'
            ($imported | Where-Object { $_.RoleName -eq 'ShareDrive' }).SourceVhd | Should Be 'V:\VHDs\disks\sharedisk.vhdx'
            ($imported | Where-Object { $_.RoleName -eq 'Lab' }).DedupEnabled | Should Be $true
        }
    }

    Context "Import-HqDiskMetadataDefinitions" {
        It "imports selected metadata definitions from the generated module" {
            if (Test-Path $repoTempDir) {
                Remove-Item $repoTempDir -Recurse -Force
            }
            $modulePath = Join-Path $repoTempDir 'HqDiskMetadata.psm1'

            Write-HqDiskMetadataModule `
                -AvailableVmNames @('HQ-DC01') `
                -SelectedVmName 'HQ-DC01' `
                -Definitions @(
                    [pscustomobject]@{
                        VmName = 'HQ-DC01'
                        SourceVhd = 'M:\repository1.vhdx'
                        VhdName = 'repository1.vhdx'
                        RoleName = 'Repository'
                        ExpectedDriveLetter = 'R'
                        DedupEnabled = $false
                    }
                ) `
                -RoleAclDefinitions @(
                    [pscustomobject]@{
                        RoleName = 'Repository'
                        ManagedPathName = 'repo'
                        Principal = 'HQ\Repo_R'
                        AccessLevel = 'ReadAndExecute'
                        ServiceAccount = 'HQ\svc_repo'
                        ServiceAccessLevel = 'FullControl'
                    }
                ) `
                -SecurityPrincipalDefinitions @(
                    [pscustomobject]@{
                        Principal = 'HQ\Repo_R'
                        Type = 'Group'
                        ExpectedMemberOf = @()
                        PasswordPromptRequired = $false
                    }
                    [pscustomobject]@{
                        Principal = 'HQ\repo_user'
                        Type = 'User'
                        ExpectedMemberOf = @('HQ\Repo_R')
                        PasswordPromptRequired = $true
                    }
                ) `
                -Path $modulePath

            $result = Import-HqDiskMetadataDefinitions -Path $modulePath
            $config = Get-HqDiskMetadataConfig
            $roleAclDefinitions = @(Get-HqRoleAclMetadataDefinitions)
            $securityPrincipalDefinitions = @(Get-HqSecurityPrincipalMetadataDefinitions)
            $resolvedRoleAclDefinitions = @(Get-HqRoleAclDefinitions)
            $resolvedSecurityPrincipalDefinitions = @(Get-HqRequiredSecurityPrincipalDefinitions)

            $result.Count | Should Be 1
            $result[0].VmName | Should Be 'HQ-DC01'
            $result[0].RoleName | Should Be 'Repository'
            $config.RoleAclDefinitions.Count | Should Be 1
            $config.SecurityPrincipalDefinitions.Count | Should Be 2
            $roleAclDefinitions.Count | Should Be 1
            $roleAclDefinitions[0].ManagedPathName | Should Be 'repo'
            $securityPrincipalDefinitions.Count | Should Be 2
            ($securityPrincipalDefinitions | Where-Object { $_.Principal -eq 'HQ\repo_user' }).PasswordPromptRequired | Should Be $true
            @(($securityPrincipalDefinitions | Where-Object { $_.Principal -eq 'HQ\repo_user' }).ExpectedMemberOf) | Should Be @('HQ\Repo_R')
            $resolvedRoleAclDefinitions.Count | Should Be 1
            $resolvedRoleAclDefinitions[0].Principal | Should Be 'HQ\Repo_R'
            $resolvedSecurityPrincipalDefinitions.Count | Should Be 2
            ($resolvedSecurityPrincipalDefinitions | Where-Object { $_.Principal -eq 'HQ\repo_user' }).Type | Should Be 'User'
        }

        It "fails clearly when the metadata file is not a generated HQ metadata module" {
            $modulePath = Join-Path $TestDrive 'HqDiskMetadata.psm1'
            @'
param(
    [switch]$RunActivation
)

Set-StrictMode -Version Latest

function Update-HqDiskMetadataModule {
    param()
}
'@ | Set-Content -Path $modulePath -Encoding ASCII

            {
                Import-HqDiskMetadataDefinitions -Path $modulePath
            } | Should Throw "Metadata module at $modulePath is not a generated HQ metadata module. Run .\app\configure_hq.ps1 on the host first."
        }
    }
}

Describe "Increment 3 Dedup Execution" {
    . "$PSScriptRoot\..\configure_hq.ps1"

    Context "Enable-HqDiskDeduplication" {
        It "selects only dedup-enabled activation results for the dedup step" {
            # Setup: use activation results with both dedup and non-dedup roles.
            Mock Invoke-HqDedupVolume {}
            $activationResults = @(
                [pscustomobject]@{ DiskNumber = 1; RoleName = 'Repository'; DriveLetters = 'R'; ExpectedDriveLetter = 'R'; DedupEnabled = $false }
                [pscustomobject]@{ DiskNumber = 2; RoleName = 'Lab'; DriveLetters = 'W'; ExpectedDriveLetter = 'W'; DedupEnabled = $true }
                [pscustomobject]@{ DiskNumber = 3; RoleName = 'Backups'; DriveLetters = 'B'; ExpectedDriveLetter = 'B'; DedupEnabled = $false }
            )

            # Check: only the Lab role should be selected for dedup.
            $result = Enable-HqDiskDeduplication -ActivationResults $activationResults

            # Check: the expected drive letter should stay with the dedup result.
            $result.Count | Should Be 1
            $result[0].DiskNumber | Should Be 2
            $result[0].RoleName | Should Be 'Lab'
            $result[0].ExpectedDriveLetter | Should Be 'W'
            $result[0].DedupAction | Should Be 'Enabled'
            $result[0].DedupVolume | Should Be 'W:'
            Assert-MockCalled Invoke-HqDedupVolume -Times 1 -Exactly -Scope It -ParameterFilter { $Volume -eq 'W:' -and -not $InstallMissingFeatures }

            # Note: direct Enable-DedupVolume mocking can be added later if needed.
        }

        It "fails clearly when the expected dedup drive letter is missing" {
            Mock Invoke-HqDedupVolume {}
            $activationResults = @(
                [pscustomobject]@{ DiskNumber = 2; RoleName = 'Lab'; DriveLetters = 'F'; ExpectedDriveLetter = 'W'; DedupEnabled = $true }
            )

            { Enable-HqDiskDeduplication -ActivationResults $activationResults } | Should Throw "Dedup target drive mismatch for role 'Lab': expected W, found F"
            Assert-MockCalled Invoke-HqDedupVolume -Times 0 -Exactly -Scope It
        }

        It "fails clearly when dedup cmdlets are unavailable and does not report success" {
            Mock Write-HqStatus {}
            Mock Invoke-HqDedupVolume {
                throw "Deduplication cmdlets are not available. Install the Data Deduplication feature on the guest first."
            }
            $activationResults = @(
                [pscustomobject]@{ DiskNumber = 2; RoleName = 'Lab'; DriveLetters = 'W'; ExpectedDriveLetter = 'W'; DedupEnabled = $true }
            )

            { Enable-HqDiskDeduplication -ActivationResults $activationResults } | Should Throw "Deduplication cmdlets are not available. Install the Data Deduplication feature on the guest first."
            Assert-MockCalled Invoke-HqDedupVolume -Times 1 -Exactly -Scope It -ParameterFilter { $Volume -eq 'W:' }
            Assert-MockCalled Write-HqStatus -Times 0 -Exactly -Scope It -ParameterFilter { $Phase -eq 'Dedup' -and $Level -eq 'Success' -and $Message -like '*Dedup enabled for role*' }
        }
    }

    Context "Invoke-HqDedupVolume" {
        It "installs the dedup feature when requested and cmdlets are missing" {
            $script:dedupAvailabilityChecks = 0
            Mock Test-HqDedupCmdletsAvailable {
                $script:dedupAvailabilityChecks++
                return ($script:dedupAvailabilityChecks -ge 2)
            }
            Mock Invoke-HqDedupFeatureInstall {}
            Mock Invoke-HqNativeDedupVolume {}

            Invoke-HqDedupVolume -Volume 'W:' -InstallMissingFeatures

            Assert-MockCalled Invoke-HqDedupFeatureInstall -Times 1 -Exactly -Scope It
            Assert-MockCalled Invoke-HqNativeDedupVolume -Times 1 -Exactly -Scope It -ParameterFilter { $Volume -eq 'W:' }
        }

        It "fails clearly when cmdlets stay unavailable after attempted installation" {
            Mock Test-HqDedupCmdletsAvailable { $false }
            Mock Invoke-HqDedupFeatureInstall {}
            Mock Invoke-HqNativeDedupVolume {}

            { Invoke-HqDedupVolume -Volume 'W:' -InstallMissingFeatures } | Should Throw "Deduplication cmdlets are still unavailable after attempting feature installation. A reboot or manual verification may be required."
            Assert-MockCalled Invoke-HqDedupFeatureInstall -Times 1 -Exactly -Scope It
            Assert-MockCalled Invoke-HqNativeDedupVolume -Times 0 -Exactly -Scope It
        }
    }
}

Describe "Increment 4 ACL and Identity Bootstrap" {
    . "$PSScriptRoot\..\configure_hq.ps1"

    BeforeEach {
        Remove-Module HqDiskMetadata -ErrorAction SilentlyContinue
    }

    Context "Get-HqRequiredSecurityPrincipalDefinitions" {
        It "returns the required mirrored users, service account, and ACL groups" {
            # Setup: lock the contract to the real lab identities before creation starts.
            $result = Get-HqRequiredSecurityPrincipalDefinitions

            $result.Count | Should Be 7
            ($result | Where-Object { $_.Type -eq 'Group' }).Count | Should Be 4
            ($result | Where-Object { $_.Type -eq 'User' }).Count | Should Be 3
            ($result | Where-Object { $_.Principal -eq 'HQ\Lab_RW' }).Type | Should Be 'Group'
            ($result | Where-Object { $_.Principal -eq 'HQ\Backups_RW' }).Type | Should Be 'Group'
            ($result | Where-Object { $_.Principal -eq 'HQ\ShareDrive_R' }).Type | Should Be 'Group'
            ($result | Where-Object { $_.Principal -eq 'HQ\Repository_R' }).Type | Should Be 'Group'
            ($result | Where-Object { $_.Principal -eq 'HQ\hector' }).Type | Should Be 'User'
            ($result | Where-Object { $_.Principal -eq 'HQ\Researcher' }).Type | Should Be 'User'
            ($result | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).Type | Should Be 'User'
            ($result | Where-Object { $_.Principal -eq 'HQ\hector' }).PasswordPromptRequired | Should Be $true
            ($result | Where-Object { $_.Principal -eq 'HQ\Researcher' }).PasswordPromptRequired | Should Be $true
            ($result | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).PasswordPromptRequired | Should Be $true
            ($result | Where-Object { $_.Principal -eq 'HQ\Lab_RW' }).PasswordPromptRequired | Should Be $false
            @(($result | Where-Object { $_.Principal -eq 'HQ\hector' }).ExpectedMemberOf) | Should Be @('HQ\Lab_RW', 'HQ\Repository_R', 'HQ\ShareDrive_R')
            @(($result | Where-Object { $_.Principal -eq 'HQ\Researcher' }).ExpectedMemberOf) | Should Be @('HQ\Lab_RW', 'HQ\ShareDrive_R')
            @(($result | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).ExpectedMemberOf) | Should Be @('HQ\Lab_RW', 'HQ\Repository_R', 'HQ\Backups_RW', 'HQ\ShareDrive_R')
            @(($result | Where-Object { $_.Principal -eq 'HQ\Lab_RW' }).ExpectedMemberOf).Count | Should Be 0
        }
    }

    Context "Get-HqLocalGroupMemberNames" {
        It "merges local-account and ADSI member lookups into unique leaf names" {
            Mock Get-LocalGroupMember {
                @(
                    [pscustomobject]@{ Name = 'HQ\hector' }
                    [pscustomobject]@{ Name = 'Researcher' }
                )
            }
            Mock Get-HqLocalSamGroupMemberNames {
                @('hector', 'HQ\Researcher')
            }

            $result = Get-HqLocalGroupMemberNames -GroupName 'Lab_RW'

            @($result) | Should Be @('hector', 'Researcher')
        }
    }

    Context "Show-HqRunSummary" {
        It "prints the disk, SMB, and access-group summaries when SMB results are present" {
            Mock Write-HqStatus {}
            Mock Get-HqManagedAccessGroupSummary {
                @([pscustomobject]@{ Group = 'Lab_RW'; Members = 'hector' })
            }
            Mock Out-Host {}

            Show-HqRunSummary -Results @(
                [pscustomobject]@{
                    DiskNumber          = 2
                    RoleName            = 'Lab'
                    DriveLetters        = 'W'
                    ExpectedDriveLetter = 'W'
                    Action              = 'Updated'
                    IdentityAction      = 'Updated'
                    AclAction           = 'Applied'
                    ShareName           = 'lab'
                    SharePath           = 'W:\Shares\lab'
                    SmbAction           = 'Adopted'
                    DedupAction         = 'Enabled'
                }
            )

            Assert-MockCalled Get-HqManagedAccessGroupSummary -Times 1 -Exactly -Scope It
            Assert-MockCalled Write-HqStatus -Times 1 -Exactly -Scope It -ParameterFilter {
                $Phase -eq 'Summary' -and $Message -eq 'Final disk summary:' -and $Level -eq 'Success'
            }
            Assert-MockCalled Write-HqStatus -Times 1 -Exactly -Scope It -ParameterFilter {
                $Phase -eq 'Summary' -and $Message -eq 'Final SMB share summary:' -and $Level -eq 'Success'
            }
            Assert-MockCalled Write-HqStatus -Times 1 -Exactly -Scope It -ParameterFilter {
                $Phase -eq 'Summary' -and $Message -eq 'Final access-group summary:' -and $Level -eq 'Success'
            }
        }

        It "skips the SMB summary when no share results are present" {
            Mock Write-HqStatus {}
            Mock Get-HqManagedAccessGroupSummary { @() }
            Mock Out-Host {}

            Show-HqRunSummary -Results @(
                [pscustomobject]@{
                    DiskNumber          = 3
                    RoleName            = 'Repository'
                    DriveLetters        = 'R'
                    ExpectedDriveLetter = 'R'
                    Action              = 'Unchanged'
                    AclAction           = 'Applied'
                    DedupAction         = 'NotRequired'
                }
            )

            Assert-MockCalled Write-HqStatus -Times 0 -Exactly -Scope It -ParameterFilter {
                $Phase -eq 'Summary' -and $Message -eq 'Final SMB share summary:'
            }
        }
    }

    Context "Read-HqSecurityPrincipalPassword" {
        It "returns a confirmed secure password on the first matching attempt" {
            $script:answers = @(
                (ConvertTo-SecureString 'pw123' -AsPlainText -Force)
                (ConvertTo-SecureString 'pw123' -AsPlainText -Force)
            )

            Mock Read-Host {
                $answer = $script:answers[0]
                if ($script:answers.Count -gt 1) {
                    $script:answers = @($script:answers[1..($script:answers.Count - 1)])
                } else {
                    $script:answers = @()
                }

                return $answer
            }
            Mock Write-HqStatus {}

            $result = Read-HqSecurityPrincipalPassword -Principal 'HQ\hector'

            (Convert-HqSecureStringToPlainText -Value $result) | Should Be 'pw123'
            Assert-MockCalled Read-Host -Times 2 -Exactly -Scope It
            Assert-MockCalled Write-HqStatus -Times 0 -Exactly -Scope It
        }

        It "warns and retries when the confirmation does not match" {
            $script:answers = @(
                (ConvertTo-SecureString 'pw123' -AsPlainText -Force)
                (ConvertTo-SecureString 'wrong' -AsPlainText -Force)
                (ConvertTo-SecureString 'pw456' -AsPlainText -Force)
                (ConvertTo-SecureString 'pw456' -AsPlainText -Force)
            )

            Mock Read-Host {
                $answer = $script:answers[0]
                if ($script:answers.Count -gt 1) {
                    $script:answers = @($script:answers[1..($script:answers.Count - 1)])
                } else {
                    $script:answers = @()
                }

                return $answer
            }
            Mock Write-HqStatus {}

            $result = Read-HqSecurityPrincipalPassword -Principal 'HQ\hector'

            (Convert-HqSecureStringToPlainText -Value $result) | Should Be 'pw456'
            Assert-MockCalled Read-Host -Times 4 -Exactly -Scope It
            Assert-MockCalled Write-HqStatus -Times 1 -Exactly -Scope It -ParameterFilter {
                $Phase -eq 'Identity' -and $Level -eq 'Warning' -and $Message -like "*did not match*"
            }
        }
    }

    Context "Ensure-HqRoleAcl" {
        It "normalizes imported ACL metadata to the legacy share-path contract" {
            function Get-HqRoleAclMetadataDefinitions { @() }
            Mock Get-HqRoleAclMetadataDefinitions {
                @(
                    [pscustomobject]@{
                        RoleName           = 'Backups'
                        ManagedPathName    = 'backups'
                        Principal          = 'HQ\Backups_RW'
                        AccessLevel        = 'Modify'
                        ServiceAccount     = 'HQ\svc_lab'
                        ServiceAccessLevel = 'FullControl'
                    }
                )
            }

            $result = Get-HqRoleAclDefinitions

            $result.Count | Should Be 1
            $result[0].RoleName | Should Be 'Backups'
            $result[0].ManagedPathName | Should Be 'Shares\backup'
        }

        It "creates managed role folders and grants the expected ACL entries" {
            # Setup: keep this focused on path and principal orchestration.
            Mock Get-HqRoleAclMetadataDefinitions { @() }
            Mock Resolve-HqSecurityPrincipalName { $Principal }
            Mock Invoke-HqEnsureDirectory {}
            Mock Invoke-HqGrantDirectoryAccess {}
            Mock Write-HqStatus {}
            $workflowResults = @(
                [pscustomobject]@{
                    DiskNumber = 2
                    RoleName = 'Lab'
                    ExpectedDriveLetter = 'W'
                }
                [pscustomobject]@{
                    DiskNumber = 1
                    RoleName = 'Repository'
                    ExpectedDriveLetter = 'R'
                }
            )

            $result = Ensure-HqRoleAcl -WorkflowResults $workflowResults

            $result.Count | Should Be 2
            ($result | Where-Object { $_.RoleName -eq 'Lab' }).ManagedPath | Should Be 'W:\Shares\lab'
            ($result | Where-Object { $_.RoleName -eq 'Repository' }).ManagedPath | Should Be 'R:\Shares\repository'
            ($result | Where-Object { $_.RoleName -eq 'Lab' }).AclAction | Should Be 'Applied'
            Assert-MockCalled Invoke-HqEnsureDirectory -Times 2 -Exactly -Scope It
            Assert-MockCalled Invoke-HqGrantDirectoryAccess -Times 8 -Exactly -Scope It
            Assert-MockCalled Invoke-HqGrantDirectoryAccess -Times 1 -Exactly -Scope It -ParameterFilter { $Path -eq 'W:\Shares\lab' -and $Principal -eq 'NT AUTHORITY\SYSTEM' -and $AccessLevel -eq 'FullControl' }
            Assert-MockCalled Invoke-HqGrantDirectoryAccess -Times 1 -Exactly -Scope It -ParameterFilter { $Path -eq 'W:\Shares\lab' -and $Principal -eq 'BUILTIN\Administrators' -and $AccessLevel -eq 'FullControl' }
            Assert-MockCalled Invoke-HqGrantDirectoryAccess -Times 1 -Exactly -Scope It -ParameterFilter { $Path -eq 'W:\Shares\lab' -and $Principal -eq 'HQ\Lab_RW' -and $AccessLevel -eq 'Modify' }
            Assert-MockCalled Invoke-HqGrantDirectoryAccess -Times 1 -Exactly -Scope It -ParameterFilter { $Path -eq 'W:\Shares\lab' -and $Principal -eq 'HQ\svc_lab' -and $AccessLevel -eq 'FullControl' }
            Assert-MockCalled Invoke-HqGrantDirectoryAccess -Times 1 -Exactly -Scope It -ParameterFilter { $Path -eq 'R:\Shares\repository' -and $Principal -eq 'HQ\Repository_R' -and $AccessLevel -eq 'ReadAndExecute' }
        }
    }

    Context "Ensure-HqSmbShares" {
        It "creates missing SMB shares for managed role folders and grants the expected access" {
            Mock Resolve-HqSecurityPrincipalName {
                switch ($Principal) {
                    'HQ\Lab_RW' { 'LABHOST\Lab_RW' }
                    'HQ\svc_lab' { 'LABHOST\svc_lab' }
                    default { $Principal }
                }
            }
            Mock Get-HqSmbShare { @() }
            Mock Get-HqSmbShareAccessEntries { @() }
            Mock Invoke-HqNativeNewSmbShare {}
            Mock Invoke-HqNativeGrantSmbShareAccess {}
            Mock Write-HqStatus {}

            $result = Ensure-HqSmbShares -WorkflowResults @(
                [pscustomobject]@{
                    DiskNumber          = 2
                    RoleName            = 'Lab'
                    ExpectedDriveLetter = 'W'
                    ManagedPath         = 'W:\Shares\lab'
                }
            )

            $result.Count | Should Be 1
            $result[0].ShareName | Should Be 'lab'
            $result[0].SmbAction | Should Be 'Created'
            Assert-MockCalled Invoke-HqNativeNewSmbShare -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'lab' -and $Path -eq 'W:\Shares\lab' -and @($FullAccess) -contains 'BUILTIN\Administrators' -and @($FullAccess) -contains 'LABHOST\svc_lab'
            }
            Assert-MockCalled Invoke-HqNativeGrantSmbShareAccess -Times 2 -Exactly -Scope It
            Assert-MockCalled Invoke-HqNativeGrantSmbShareAccess -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'lab' -and $AccountName -eq 'LABHOST\svc_lab' -and $AccessRight -eq 'Full'
            }
            Assert-MockCalled Invoke-HqNativeGrantSmbShareAccess -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'lab' -and $AccountName -eq 'LABHOST\Lab_RW' -and $AccessRight -eq 'Change'
            }
        }

        It "verifies an existing SMB share in place without recreating it" {
            Mock Resolve-HqSecurityPrincipalName { $Principal }
            Mock Get-HqSmbShare { @([pscustomobject]@{ Name = 'repository'; Path = 'R:\Shares\repository' }) }
            Mock Get-HqSmbShareAccessEntries {
                @(
                    [pscustomobject]@{ AccountName = 'HQ\svc_lab'; AccessRight = 'Full' }
                    [pscustomobject]@{ AccountName = 'HQ\Repository_R'; AccessRight = 'Read' }
                )
            }
            Mock Invoke-HqNativeNewSmbShare {}
            Mock Invoke-HqNativeGrantSmbShareAccess {}
            Mock Write-HqStatus {}

            $result = Ensure-HqSmbShares -WorkflowResults @(
                [pscustomobject]@{
                    DiskNumber          = 3
                    RoleName            = 'Repository'
                    ExpectedDriveLetter = 'R'
                    ManagedPath         = 'R:\Shares\repository'
                }
            )

            $result[0].SmbAction | Should Be 'Verified'
            Assert-MockCalled Invoke-HqNativeNewSmbShare -Times 0 -Exactly -Scope It
            Assert-MockCalled Invoke-HqNativeGrantSmbShareAccess -Times 0 -Exactly -Scope It
        }

        It "adopts an existing SMB share when the share name already points to a different path" {
            Mock Resolve-HqSecurityPrincipalName { $Principal }
            Mock Get-HqSmbShare { @([pscustomobject]@{ Name = 'lab'; Path = 'W:\lab' }) }
            Mock Get-HqSmbShareAccessEntries { @() }
            Mock Invoke-HqNativeNewSmbShare {}
            Mock Invoke-HqNativeGrantSmbShareAccess {}
            Mock Write-HqStatus {}

            $result = Ensure-HqSmbShares -WorkflowResults @(
                [pscustomobject]@{
                    DiskNumber          = 2
                    RoleName            = 'Lab'
                    ExpectedDriveLetter = 'W'
                    ManagedPath         = 'W:\Shares\lab'
                }
            )

            $result[0].ShareName | Should Be 'lab'
            $result[0].SharePath | Should Be 'W:\lab'
            $result[0].SmbAction | Should Be 'Adopted'
            Assert-MockCalled Invoke-HqNativeNewSmbShare -Times 0 -Exactly -Scope It
            Assert-MockCalled Invoke-HqNativeGrantSmbShareAccess -Times 2 -Exactly -Scope It
            Assert-MockCalled Write-HqStatus -Times 1 -Scope It -ParameterFilter {
                $Phase -eq 'SMB' -and $Level -eq 'Warning'
            }
        }
    }

    Context "Get-HqSecurityPrincipalStateEntry" {
        It "uses local lookups for HQ principal state even when AD cmdlets are present" {
            # Setup: keep increment-4 identity work pinned to the local
            # authority store instead of switching to domain state.
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock Get-HqLocalGroup { [pscustomobject]@{ Name = $Name } }
            Mock Get-HqActiveDirectoryGroup {}

            $result = Get-HqSecurityPrincipalStateEntry -Principal 'HQ\Lab_RW' -Type 'Group'

            $result.Principal | Should Be 'HQ\Lab_RW'
            $result.Type | Should Be 'Group'
            $result.Name | Should Be 'Lab_RW'
            $result.Exists | Should Be $true
            Assert-MockCalled Get-HqLocalGroup -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'Lab_RW' }
            Assert-MockCalled Get-HqActiveDirectoryGroup -Times 0 -Exactly -Scope It
        }

        It "captures the managed access-group memberships for HQ users from Active Directory" {
            # Check: keep only the expected HQ access groups in the backup.
            Mock Test-HqUseLocalSecurityPrincipals { $false }
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock Get-HqActiveDirectoryUser { [pscustomobject]@{ Name = $Name } }
            Mock Get-HqActiveDirectoryPrincipalGroupNames { @('Lab_RW', 'ShareDrive_R', 'Domain Users') }
            Mock Get-HqLocalUser {}

            $result = Get-HqSecurityPrincipalStateEntry `
                -Principal 'HQ\Researcher' `
                -Type 'User' `
                -ExpectedMemberOf @('HQ\Lab_RW', 'HQ\ShareDrive_R')

            $result.Principal | Should Be 'HQ\Researcher'
            $result.Type | Should Be 'User'
            $result.Name | Should Be 'Researcher'
            $result.Exists | Should Be $true
            @($result.ExpectedMemberOf) | Should Be @('HQ\Lab_RW', 'HQ\ShareDrive_R')
            @($result.MemberOf) | Should Be @('HQ\Lab_RW', 'HQ\ShareDrive_R')
            Assert-MockCalled Get-HqActiveDirectoryUser -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'Researcher' }
            Assert-MockCalled Get-HqActiveDirectoryPrincipalGroupNames -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'Researcher' }
            Assert-MockCalled Get-HqLocalUser -Times 0 -Exactly -Scope It
        }

        It "captures the managed access-group memberships for HQ users from local groups" {
            # Check: keep only the expected HQ access groups when the guest
            # is using local accounts instead of Active Directory.
            Mock Test-HqActiveDirectoryCommandsAvailable { $false }
            Mock Get-HqLocalUser { [pscustomobject]@{ Name = $Name } }
            Mock Get-HqLocalPrincipalGroupNames { @('Lab_RW', 'ShareDrive_R', 'Users') }
            Mock Get-HqActiveDirectoryUser {}

            $result = Get-HqSecurityPrincipalStateEntry `
                -Principal 'HQ\Researcher' `
                -Type 'User' `
                -ExpectedMemberOf @('HQ\Lab_RW', 'HQ\ShareDrive_R')

            $result.Principal | Should Be 'HQ\Researcher'
            $result.Type | Should Be 'User'
            $result.Name | Should Be 'Researcher'
            $result.Exists | Should Be $true
            @($result.ExpectedMemberOf) | Should Be @('HQ\Lab_RW', 'HQ\ShareDrive_R')
            @($result.MemberOf) | Should Be @('HQ\Lab_RW', 'HQ\ShareDrive_R')
            Assert-MockCalled Get-HqLocalUser -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'Researcher' }
            Assert-MockCalled Get-HqLocalPrincipalGroupNames -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'Researcher' }
            Assert-MockCalled Get-HqActiveDirectoryUser -Times 0 -Exactly -Scope It
        }

        It "can verify hidden local SAM principals when the caller opts into that fallback" {
            Mock Test-HqActiveDirectoryCommandsAvailable { $false }
            Mock Get-HqLocalGroup { $null }
            Mock Get-HqLocalSamPrincipal { [pscustomobject]@{ Name = $Name; SchemaClassName = 'group' } }

            $result = Get-HqSecurityPrincipalStateEntry -Principal 'HQ\Backups_RW' -Type 'Group' -AllowHiddenLocalSam

            $result.Exists | Should Be $true
            Assert-MockCalled Get-HqLocalSamPrincipal -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'Backups_RW' -and $Type -eq 'Group'
            }
        }
    }

    Context "Local-First Principal Operations" {
        It "returns null when a local group is not present in either lookup path" {
            Mock Get-LocalGroup { $null }

            $result = Get-HqLocalGroup -Name 'Missing_Group'

            $result | Should Be $null
        }

        It "returns null when a local user is not present in either lookup path" {
            Mock Get-LocalUser { $null }

            $result = Get-HqLocalUser -Name 'missing_user'

            $result | Should Be $null
        }

        It "falls back to enumerating local groups when direct name lookup misses an existing group" {
            Mock Get-LocalGroup {
                param([string]$Name)

                if ($PSBoundParameters.ContainsKey('Name')) {
                    return $null
                }

                return @(
                    [pscustomobject]@{ Name = 'Lab_RW' }
                    [pscustomobject]@{ Name = 'Backups_RW' }
                )
            }

            $result = Get-HqLocalGroup -Name 'Backups_RW'

            $result.Name | Should Be 'Backups_RW'
        }

        It "falls back to ADSI when local group cmdlets miss an existing group" {
            Mock Get-LocalGroup { $null }
            Mock Test-HqSecurityPrincipalResolvable { $true }
            Mock Get-HqLocalSamPrincipal {
                [pscustomobject]@{ Name = $Name; SchemaClassName = 'group' }
            }

            $result = Get-HqLocalGroup -Name 'Backups_RW'

            $result.Name | Should Be 'Backups_RW'
            Assert-MockCalled Get-HqLocalSamPrincipal -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'Backups_RW' -and $Type -eq 'Group'
            }
        }

        It "falls back to ADSI when local user cmdlets miss an existing user" {
            Mock Get-LocalUser { $null }
            Mock Test-HqSecurityPrincipalResolvable { $true }
            Mock Get-HqLocalSamPrincipal {
                [pscustomobject]@{ Name = $Name; SchemaClassName = 'user' }
            }

            $result = Get-HqLocalUser -Name 'svc_lab'

            $result.Name | Should Be 'svc_lab'
            Assert-MockCalled Get-HqLocalSamPrincipal -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'svc_lab' -and $Type -eq 'User'
            }
        }

        It "ignores stale ADSI group fallback entries when the local principal no longer resolves" {
            Mock Get-LocalGroup { $null }
            Mock Test-HqSecurityPrincipalResolvable { $false }
            Mock Get-HqLocalSamPrincipal {
                [pscustomobject]@{ Name = $Name; SchemaClassName = 'group' }
            }

            $result = Get-HqLocalGroup -Name 'Backups_RW'

            $result | Should Be $null
        }

        It "ignores stale ADSI user fallback entries when the local principal no longer resolves" {
            Mock Get-LocalUser { $null }
            Mock Test-HqSecurityPrincipalResolvable { $false }
            Mock Get-HqLocalSamPrincipal {
                [pscustomobject]@{ Name = $Name; SchemaClassName = 'user' }
            }

            $result = Get-HqLocalUser -Name 'svc_lab'

            $result | Should Be $null
        }

        It "finds local group memberships through ADSI when LocalAccounts cmdlets miss the group" {
            Mock Get-LocalGroup {
                param([string]$Name)

                if ($PSBoundParameters.ContainsKey('Name')) {
                    return $null
                }

                return @()
            }
            Mock Get-LocalGroupMember { @() }
            Mock Get-HqLocalSamGroupNames { @('Lab_RW') }
            Mock Get-HqLocalSamGroupMemberNames { @('hector') }

            $result = Get-HqLocalPrincipalGroupNames -Name 'hector'

            $result | Should Be @('Lab_RW')
        }

        It "creates local groups even when AD cmdlets are present" {
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock New-LocalGroup {}

            New-HqSecurityPrincipalGroup -Name 'Lab_RW'

            Assert-MockCalled New-LocalGroup -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'Lab_RW' }
        }

        It "treats duplicate local group creation as already satisfied when lookup confirms the group exists" {
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock New-LocalGroup { throw 'The name Lab_RW is already in use.' }
            Mock Get-HqLocalGroup { [pscustomobject]@{ Name = $Name } }

            { New-HqSecurityPrincipalGroup -Name 'Lab_RW' } | Should Not Throw

            Assert-MockCalled Get-HqLocalGroup -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'Lab_RW' }
        }

        It "treats duplicate local group creation as already satisfied when Windows reports already exists but lookup cannot confirm the hidden group" {
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock New-LocalGroup { throw 'Group Backups_RW already exists.' }
            Mock Get-HqLocalGroup { $null }
            Mock Get-HqLocalUser { $null }

            { New-HqSecurityPrincipalGroup -Name 'Backups_RW' } | Should Not Throw
        }

        It "throws a clear error when a local user blocks required group creation" {
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock New-LocalGroup { throw 'The name Backups_RW is already in use.' }
            Mock Get-HqLocalGroup { $null }
            Mock Get-HqLocalUser { [pscustomobject]@{ Name = $Name } }

            {
                New-HqSecurityPrincipalGroup -Name 'Backups_RW'
            } | Should Throw "Cannot create required group 'Backups_RW' because a local user with the same name already exists."
        }

        It "throws a clear error when a local group blocks required user creation" {
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock New-LocalUser { throw 'The name svc_lab is already in use.' }
            Mock Get-HqLocalUser { $null }
            Mock Get-HqLocalGroup { [pscustomobject]@{ Name = $Name } }

            {
                New-HqSecurityPrincipalUser -Name 'svc_lab'
            } | Should Throw "Cannot create required user 'svc_lab' because a local group with the same name already exists."
        }

        It "creates a local user with a secure password when one is supplied" {
            $password = ConvertTo-SecureString 'pw123' -AsPlainText -Force
            Mock Test-HqActiveDirectoryCommandsAvailable { $false }
            Mock New-LocalUser {}

            New-HqSecurityPrincipalUser -Name 'hector' -Password $password

            Assert-MockCalled New-LocalUser -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'hector' -and $null -ne $Password
            }
        }

        It "treats duplicate local user creation as already satisfied when Windows reports already exists but lookup cannot confirm the hidden user" {
            $password = ConvertTo-SecureString 'pw123' -AsPlainText -Force
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock New-LocalUser { throw 'User svc_lab already exists.' }
            Mock Get-HqLocalUser { $null }
            Mock Get-HqLocalGroup { $null }

            { New-HqSecurityPrincipalUser -Name 'svc_lab' -Password $password } | Should Not Throw
        }

        It "adds local users to local groups even when AD cmdlets are present" {
            Mock Test-HqUseLocalSecurityPrincipals { $true }
            Mock Test-HqActiveDirectoryCommandsAvailable { $true }
            Mock Invoke-HqNativeAddLocalGroupMember {}

            Add-HqSecurityPrincipalToGroup -Principal 'HQ\hector' -Group 'HQ\Lab_RW'

            Assert-MockCalled Invoke-HqNativeAddLocalGroupMember -Times 1 -Exactly -Scope It -ParameterFilter {
                $Group -eq 'Lab_RW' -and $Member -eq 'hector'
            }
        }

        It "adds local group membership through ADSI when the local SAM object is resolved directly" {
            $script:addedMemberPath = $null
            $groupObject = New-Object psobject
            $groupObject | Add-Member -MemberType ScriptMethod -Name Add -Value {
                param($memberPath)
                $script:addedMemberPath = $memberPath
            }

            Mock Get-HqLocalSamPrincipal { $groupObject }
            Mock Get-HqLocalSamMemberReferences { @('WinNT://LABHOST/hector,user') }

            Invoke-HqNativeAddLocalSamGroupMember -Group 'Lab_RW' -Member 'hector'

            $script:addedMemberPath | Should Be 'WinNT://LABHOST/hector,user'
        }

        It "treats already-missing local groups as already removed during cleanup" {
            Mock Test-HqUseLocalSecurityPrincipals { $true }
            Mock Remove-LocalGroup { throw 'Group ShareDrive_R was not found.' }
            Mock Get-HqLocalGroup { $null }

            { Remove-HqSecurityPrincipalGroup -Name 'ShareDrive_R' } | Should Not Throw
        }

        It "treats already-missing local groups as already removed when fallback lookup still sees stale state" {
            Mock Test-HqUseLocalSecurityPrincipals { $true }
            Mock Remove-LocalGroup { throw 'Group ShareDrive_R was not found.' }
            Mock Get-HqLocalGroup { [pscustomobject]@{ Name = 'ShareDrive_R' } }

            { Remove-HqSecurityPrincipalGroup -Name 'ShareDrive_R' } | Should Not Throw
        }

        It "treats already-missing local users as already removed during cleanup" {
            Mock Test-HqUseLocalSecurityPrincipals { $true }
            Mock Remove-LocalUser { throw 'User svc_lab was not found.' }
            Mock Get-HqLocalUser { [pscustomobject]@{ Name = 'svc_lab' } }

            { Remove-HqSecurityPrincipalUser -Name 'svc_lab' } | Should Not Throw
        }
    }

    Context "Resolve-HqSecurityPrincipalName" {
        It "falls back to the local computer-qualified principal when the configured HQ prefix does not resolve" {
            # Check: use the real local authority name when the configured
            # prefix is only a logical label for the lab contract.
            $originalComputerName = $env:COMPUTERNAME

            try {
                $env:COMPUTERNAME = 'LABHOST'
                Mock Test-HqActiveDirectoryCommandsAvailable { $false }
                Mock Test-HqSecurityPrincipalResolvable {
                    $Principal -eq 'LABHOST\Repository_R'
                }

                $result = Resolve-HqSecurityPrincipalName -Principal 'HQ\Repository_R'

                $result | Should Be 'LABHOST\Repository_R'
            }
            finally {
                $env:COMPUTERNAME = $originalComputerName
            }
        }
    }

    Context "Export-HqSecurityPrincipalState" {
        It "writes a principal backup artifact for the actual HQ lab principal set" {
            # Setup: align the export contract with the real HQ lab identities.
            $statePath = Join-Path $PSScriptRoot '..\temp\HqSecurityState.json'
            if (Test-Path $statePath) {
                Remove-Item $statePath -Force
            }

            try {
                # Setup: some mirrored principals exist already and some do not.
                Mock Test-HqActiveDirectoryCommandsAvailable { $false }
                Mock Get-HqLocalGroup {
                    if ($Name -in @('Lab_RW', 'Repository_R')) {
                        return [pscustomobject]@{ Name = $Name }
                    }

                    return $null
                }
                Mock Get-HqLocalUser {
                    if ($Name -eq 'svc_lab') {
                        return [pscustomobject]@{ Name = $Name }
                    }

                    return $null
                }

                $definitions = @(Get-HqRequiredSecurityPrincipalDefinitions)

                Export-HqSecurityPrincipalState -Path $statePath -Definitions $definitions
                $state = Get-Content -Path $statePath -Raw | ConvertFrom-Json

                (Test-Path $statePath) | Should Be $true
                @($state.Principals).Count | Should Be 7
                (@($state.Principals) | Where-Object { $_.Type -eq 'Group' }).Count | Should Be 4
                (@($state.Principals) | Where-Object { $_.Type -eq 'User' }).Count | Should Be 3
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\Lab_RW' }).Type | Should Be 'Group'
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\Backups_RW' }).Type | Should Be 'Group'
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\ShareDrive_R' }).Type | Should Be 'Group'
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\Repository_R' }).Type | Should Be 'Group'
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\hector' }).Type | Should Be 'User'
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\Researcher' }).Type | Should Be 'User'
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).Type | Should Be 'User'
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\Lab_RW' }).Exists | Should Be $true
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\Repository_R' }).Exists | Should Be $true
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\ShareDrive_R' }).Exists | Should Be $false
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).Exists | Should Be $true
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\hector' }).Exists | Should Be $false
                @((@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\hector' }).ExpectedMemberOf) | Should Be @('HQ\Lab_RW', 'HQ\Repository_R', 'HQ\ShareDrive_R')
                @((@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).ExpectedMemberOf) | Should Be @('HQ\Lab_RW', 'HQ\Repository_R', 'HQ\Backups_RW', 'HQ\ShareDrive_R')
                @((@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).MemberOf).Count | Should Be 0
                Assert-MockCalled Get-HqLocalGroup -Times 4 -Exactly -Scope It
                Assert-MockCalled Get-HqLocalUser -Times 3 -Exactly -Scope It
            }
            finally {
                if (Test-Path $statePath) {
                    Remove-Item $statePath -Force
                }
            }
        }
    }

    Context "Import-HqSecurityPrincipalState" {
        It "reads a saved principal backup artifact back into the shared bootstrap shape" {
            # Setup: keep the read boundary aligned with the saved guest artifact.
            $statePath = Join-Path $PSScriptRoot '..\temp\HqSecurityState.json'
            if (Test-Path $statePath) {
                Remove-Item $statePath -Force
            }

            try {
                $savedState = [pscustomobject]@{
                    ComputerName = 'HQ'
                    CreatedAtUtc = '2026-03-24T14:50:00.0000000Z'
                    Principals   = @(
                        [pscustomobject]@{
                            Principal = 'HQ\Lab_RW'
                            Type      = 'Group'
                            Name      = 'Lab_RW'
                            Exists    = $true
                            ExpectedMemberOf = @()
                            MemberOf         = @()
                        }
                        [pscustomobject]@{
                            Principal = 'HQ\svc_lab'
                            Type      = 'User'
                            Name      = 'svc_lab'
                            Exists    = $false
                            ExpectedMemberOf = @()
                            MemberOf         = @()
                        }
                    )
                }

                $savedState | ConvertTo-Json -Depth 5 | Set-Content -Path $statePath -Encoding ASCII
                $result = Import-HqSecurityPrincipalState -Path $statePath

                $result.ComputerName | Should Be 'HQ'
                $result.CreatedAtUtc | Should Be '2026-03-24T14:50:00.0000000Z'
                @($result.Principals).Count | Should Be 2
                (@($result.Principals) | Where-Object { $_.Principal -eq 'HQ\Lab_RW' }).Exists | Should Be $true
                (@($result.Principals) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).Type | Should Be 'User'
                @((@($result.Principals) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).MemberOf).Count | Should Be 0
            }
            finally {
                if (Test-Path $statePath) {
                    Remove-Item $statePath -Force
                }
            }
        }

        It "records missing mirrored AD users as absent instead of failing the backup" {
            # Check: export should still work before hector or Researcher exist.
            $statePath = Join-Path $PSScriptRoot '..\temp\HqSecurityState.json'
            if (Test-Path $statePath) {
                Remove-Item $statePath -Force
            }

            try {
                Mock Test-HqActiveDirectoryCommandsAvailable { $true }
                Mock Get-HqActiveDirectoryGroup {}
                Mock Get-HqActiveDirectoryUser {}
                Mock Get-HqActiveDirectoryPrincipalGroupNames { @() }
                Mock Get-HqLocalGroup {
                    if ($Name -in @('Lab_RW', 'Backups_RW', 'ShareDrive_R')) {
                        return [pscustomobject]@{ Name = $Name }
                    }

                    return $null
                }
                Mock Get-HqLocalUser {
                    if ($Name -eq 'svc_lab') {
                        return [pscustomobject]@{ Name = $Name }
                    }

                    return $null
                }

                $definitions = @(Get-HqRequiredSecurityPrincipalDefinitions)

                { Export-HqSecurityPrincipalState -Path $statePath -Definitions $definitions } | Should Not Throw
                $state = Get-Content -Path $statePath -Raw | ConvertFrom-Json

                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\hector' }).Exists | Should Be $false
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\Researcher' }).Exists | Should Be $false
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).Exists | Should Be $true
                (@($state.Principals) | Where-Object { $_.Principal -eq 'HQ\Repository_R' }).Exists | Should Be $false
                Assert-MockCalled Get-HqLocalGroup -Times 4 -Exactly -Scope It
                Assert-MockCalled Get-HqLocalUser -Times 3 -Exactly -Scope It
            }
            finally {
                if (Test-Path $statePath) {
                    Remove-Item $statePath -Force
                }
            }
        }
    }

    Context "Invoke-HqSecurityPrincipalStateBackup" {
        It "exports the required HQ principal set through the guest backup wrapper" {
            # Check: the guest wrapper should only gather and forward the contract.
            Mock Export-HqSecurityPrincipalState {}
            $statePath = Join-Path $PSScriptRoot '..\temp\HqSecurityState.json'

            $result = Invoke-HqSecurityPrincipalStateBackup -Path $statePath

            $result | Should Be $statePath
            Assert-MockCalled Export-HqSecurityPrincipalState -Times 1 -Exactly -Scope It -ParameterFilter {
                $Path -like '*HqSecurityState.json' -and @($Definitions).Count -eq 7
            }
        }
    }

    Context "Invoke-HqSecurityPrincipalStateRestore" {
        It "runs required identity restore through the guest wrapper" {
            # Check: the guest wrapper should only forward work into identity restore.
            Mock Ensure-HqSecurityPrincipals { @([pscustomobject]@{ Action = 'Created' }) }

            $result = Invoke-HqSecurityPrincipalStateRestore

            @($result).Count | Should Be 1
            $result[0].Action | Should Be 'Created'
            Assert-MockCalled Ensure-HqSecurityPrincipals -Times 1 -Exactly -Scope It
        }
    }

    Context "Invoke-HqSecurityPrincipalStateCleanup" {
        It "runs cleanup from the saved principal state through the guest wrapper" {
            # Check: the guest wrapper should only forward the saved-state path into cleanup.
            Mock Invoke-HqSecurityPrincipalCleanup { @([pscustomobject]@{ Action = 'RemoveMembership'; Result = 'Removed' }) }
            $statePath = Join-Path $PSScriptRoot '..\temp\HqSecurityState.json'

            $result = Invoke-HqSecurityPrincipalStateCleanup -Path $statePath

            @($result).Count | Should Be 1
            $result[0].Result | Should Be 'Removed'
            Assert-MockCalled Invoke-HqSecurityPrincipalCleanup -Times 1 -Exactly -Scope It -ParameterFilter {
                $Path -like '*HqSecurityState.json'
            }
        }

        It "skips invalid metadata modules and still runs cleanup with built-in definitions" {
            $statePath = Join-Path $PSScriptRoot '..\temp\HqSecurityState.json'
            $modulePath = Join-Path $TestDrive 'HqDiskMetadata.psm1'
            @'
param(
    [switch]$RunActivation
)

Set-StrictMode -Version Latest

function Update-HqDiskMetadataModule {
    param()
}
'@ | Set-Content -Path $modulePath -Encoding ASCII

            Mock Invoke-HqSecurityPrincipalCleanup { @([pscustomobject]@{ Action = 'RemovePrincipal'; Result = 'Planned' }) }
            Mock Write-HqStatus {}

            $result = Invoke-HqSecurityPrincipalStateCleanup -Path $statePath -MetadataModulePath $modulePath

            @($result).Count | Should Be 1
            $result[0].Result | Should Be 'Planned'
            Assert-MockCalled Invoke-HqSecurityPrincipalCleanup -Times 1 -Exactly -Scope It -ParameterFilter {
                $Path -like '*HqSecurityState.json'
            }
            Assert-MockCalled Write-HqStatus -Times 1 -Exactly -Scope It -ParameterFilter {
                $Phase -eq 'Metadata' -and $Level -eq 'Warning' -and $Message -like '*not a generated HQ metadata module*'
            }
        }
    }

    Context "Get-HqSecurityPrincipalCleanupPlan" {
        It "lists principals that can be removed because they were absent in the saved state" {
            # ---------------------------------------------------------------------
            # Section: use the saved principal state to find work that can be
            # undone without guessing what existed before this script ran.
            # ---------------------------------------------------------------------

            $statePath = Join-Path $TestDrive 'HqSecurityState.json'

            # Setup: keep the required identity list fixed for this cleanup case.
            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal        = 'HQ\Lab_RW'
                        Type             = 'Group'
                        ExpectedMemberOf = @()
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\svc_lab'
                        Type             = 'User'
                        ExpectedMemberOf = @()
                    }
                )
            }

            # Setup: say what the saved state recorded before restore work happened.
            Mock Import-HqSecurityPrincipalState {
                [pscustomobject]@{
                    Principals = @(
                        [pscustomobject]@{
                            Principal        = 'HQ\Lab_RW'
                            Type             = 'Group'
                            Name             = 'Lab_RW'
                            Exists           = $false
                            ExpectedMemberOf = @()
                            MemberOf         = @()
                        }
                        [pscustomobject]@{
                            Principal        = 'HQ\svc_lab'
                            Type             = 'User'
                            Name             = 'svc_lab'
                            Exists           = $true
                            ExpectedMemberOf = @()
                            MemberOf         = @()
                        }
                    )
                }
            }

            # Setup: say what exists now so this test only checks the cleanup plan.
            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = $true
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = @()
                }
            }

            # Step: build the cleanup plan from the saved state and the current state.
            $result = Get-HqSecurityPrincipalCleanupPlan -Path $statePath

            # Check: only principals added after the saved state should be marked for removal.
            @($result).Count | Should Be 1
            $result[0].Principal | Should Be 'HQ\Lab_RW'
            $result[0].Action | Should Be 'RemovePrincipal'
            Assert-MockCalled Import-HqSecurityPrincipalState -Times 1 -Exactly -Scope It -ParameterFilter { $Path -eq $statePath }
        }

        It "lists group links that can be removed because they were absent in the saved state" {
            # ---------------------------------------------------------------------
            # Section: remove added group links before removing whole users or
            # groups so cleanup can unwind the safer dependency first.
            # ---------------------------------------------------------------------

            $statePath = Join-Path $TestDrive 'HqSecurityState.json'

            # Setup: keep the required user and group relationship fixed for this cleanup case.
            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal        = 'HQ\hector'
                        Type             = 'User'
                        ExpectedMemberOf = @('HQ\Lab_RW')
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\Lab_RW'
                        Type             = 'Group'
                        ExpectedMemberOf = @()
                    }
                )
            }

            # Setup: say the saved state did not have the user in this group.
            Mock Import-HqSecurityPrincipalState {
                [pscustomobject]@{
                    Principals = @(
                        [pscustomobject]@{
                            Principal        = 'HQ\hector'
                            Type             = 'User'
                            Name             = 'hector'
                            Exists           = $true
                            ExpectedMemberOf = @('HQ\Lab_RW')
                            MemberOf         = @()
                        }
                        [pscustomobject]@{
                            Principal        = 'HQ\Lab_RW'
                            Type             = 'Group'
                            Name             = 'Lab_RW'
                            Exists           = $true
                            ExpectedMemberOf = @()
                            MemberOf         = @()
                        }
                    )
                }
            }

            # Setup: say the user is now in the group so this test only checks the cleanup plan.
            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = $true
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = if ($Principal -eq 'HQ\hector') { @('HQ\Lab_RW') } else { @() }
                }
            }

            # Step: build the cleanup plan from the saved state and the current state.
            $result = Get-HqSecurityPrincipalCleanupPlan -Path $statePath

            # Check: the added group link should be marked for removal before the user or group.
            $membershipResult = @($result) | Where-Object { $_.Action -eq 'RemoveMembership' }
            @($membershipResult).Count | Should Be 1
            $membershipResult[0].Principal | Should Be 'HQ\hector'
            $membershipResult[0].Group | Should Be 'HQ\Lab_RW'
        }
    }

    Context "Invoke-HqSecurityPrincipalCleanup" {
        It "removes planned group links before leaving whole principal removal planned when deletion is declined" {
            # ---------------------------------------------------------------------
            # Section: execute the safer cleanup step first by removing added
            # group links while leaving whole users and groups planned.
            # ---------------------------------------------------------------------

            $statePath = Join-Path $TestDrive 'HqSecurityState.json'

            # Setup: keep the cleanup plan fixed so this test only checks execution.
            Mock Get-HqSecurityPrincipalCleanupPlan {
                @(
                    [pscustomobject]@{
                        Principal = 'HQ\hector'
                        Type      = 'User'
                        Name      = 'hector'
                        Group     = 'HQ\Lab_RW'
                        Action    = 'RemoveMembership'
                    }
                    [pscustomobject]@{
                        Principal = 'HQ\Lab_RW'
                        Type      = 'Group'
                        Name      = 'Lab_RW'
                        Action    = 'RemovePrincipal'
                    }
                )
            }
            Mock Remove-HqSecurityPrincipalFromGroup {}
            Mock Read-Host { 'n' }

            # Step: run cleanup from the saved state path.
            $result = Invoke-HqSecurityPrincipalCleanup -Path $statePath

            # Check: remove the added group link now and leave whole principal removal planned.
            @($result).Count | Should Be 2
            (@($result) | Where-Object { $_.Action -eq 'RemoveMembership' }).Result | Should Be 'Removed'
            (@($result) | Where-Object { $_.Action -eq 'RemovePrincipal' }).Result | Should Be 'Planned'
            Assert-MockCalled Remove-HqSecurityPrincipalFromGroup -Times 1 -Exactly -Scope It -ParameterFilter {
                $Principal -eq 'HQ\hector' -and $Group -eq 'HQ\Lab_RW'
            }
        }

        It "shows planned removals and deletes confirmed users and groups in the same cleanup pass" {
            # ---------------------------------------------------------------------
            # Section: keep the whole cleanup flow inside one command by
            # removing links first, then confirming each planned deletion.
            # ---------------------------------------------------------------------

            $statePath = Join-Path $TestDrive 'HqSecurityState.json'
            $answers = @('y', 'y', 'y', 'y')

            # Setup: keep the cleanup plan fixed so this test only checks the confirmation flow.
            Mock Get-HqSecurityPrincipalCleanupPlan {
                @(
                    [pscustomobject]@{
                        Principal = 'HQ\hector'
                        Type      = 'User'
                        Name      = 'hector'
                        Group     = 'HQ\Lab_RW'
                        Action    = 'RemoveMembership'
                    }
                    [pscustomobject]@{
                        Principal = 'HQ\Researcher'
                        Type      = 'User'
                        Name      = 'Researcher'
                        Action    = 'RemovePrincipal'
                    }
                    [pscustomobject]@{
                        Principal = 'HQ\Lab_RW'
                        Type      = 'Group'
                        Name      = 'Lab_RW'
                        Action    = 'RemovePrincipal'
                    }
                )
            }
            Mock Remove-HqSecurityPrincipalFromGroup {}
            Mock Remove-HqSecurityPrincipalUser {}
            Mock Remove-HqSecurityPrincipalGroup {}
            Mock Read-Host {
                $answer = $script:answers[0]
                if ($script:answers.Count -gt 1) {
                    $script:answers = @($script:answers[1..($script:answers.Count - 1)])
                }

                return $answer
            }

            # Step: run cleanup through the full confirmation flow.
            $script:answers = $answers
            $result = Invoke-HqSecurityPrincipalCleanup -Path $statePath

            # Check: the confirmed user and group removals should complete in the same pass.
            @($result).Count | Should Be 3
            (@($result) | Where-Object { $_.Action -eq 'RemoveMembership' }).Result | Should Be 'Removed'
            (@($result) | Where-Object { $_.Principal -eq 'HQ\Researcher' }).Result | Should Be 'Removed'
            (@($result) | Where-Object { $_.Principal -eq 'HQ\Lab_RW' }).Result | Should Be 'Removed'
            Assert-MockCalled Remove-HqSecurityPrincipalFromGroup -Times 1 -Exactly -Scope It -ParameterFilter {
                $Principal -eq 'HQ\hector' -and $Group -eq 'HQ\Lab_RW'
            }
            Assert-MockCalled Remove-HqSecurityPrincipalUser -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'Researcher'
            }
            Assert-MockCalled Remove-HqSecurityPrincipalGroup -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'Lab_RW'
            }
        }

        It "continues past declined user deletion and reports when no groups are planned" {
            # ---------------------------------------------------------------------
            # Section: keep the cleanup flow readable when the operator skips
            # user deletion and there are no planned groups to review next.
            # ---------------------------------------------------------------------

            $statePath = Join-Path $TestDrive 'HqSecurityState.json'

            # Setup: keep the cleanup plan fixed so this test only checks operator flow.
            Mock Get-HqSecurityPrincipalCleanupPlan {
                @(
                    [pscustomobject]@{
                        Principal = 'HQ\hector'
                        Type      = 'User'
                        Name      = 'hector'
                        Action    = 'RemovePrincipal'
                    }
                )
            }
            Mock Read-Host { 'n' }
            Mock Write-HqStatus {}

            # Step: run cleanup and decline user deletion.
            $result = Invoke-HqSecurityPrincipalCleanup -Path $statePath

            # Check: the cleanup stays planned and still reports that no groups are waiting next.
            @($result).Count | Should Be 1
            $result[0].Result | Should Be 'Planned'
            Assert-MockCalled Write-HqStatus -Times 1 -Exactly -Scope It -ParameterFilter {
                $Phase -eq 'Identity' -and $Message -eq 'No planned groups are waiting for deletion.'
            }
        }

        It "returns cleanly when no cleanup work is planned" {
            # ---------------------------------------------------------------------
            # Section: skip the planned-removal table and confirmation prompts
            # when the saved state says there is nothing left to clean up.
            # ---------------------------------------------------------------------

            $statePath = Join-Path $TestDrive 'HqSecurityState.json'

            # Setup: keep the cleanup plan empty so this test checks the no-work path.
            Mock Get-HqSecurityPrincipalCleanupPlan { @() }
            Mock Show-HqSecurityPrincipalCleanupPlanTable {}
            Mock Read-Host {}
            Mock Write-HqStatus {}

            # Step: run cleanup when no removals are planned.
            $result = Invoke-HqSecurityPrincipalCleanup -Path $statePath

            # Check: the cleanup should return no rows and skip later prompts.
            @($result).Count | Should Be 0
            Assert-MockCalled Show-HqSecurityPrincipalCleanupPlanTable -Times 0 -Exactly -Scope It
            Assert-MockCalled Read-Host -Times 0 -Exactly -Scope It
        }
    }

    Context "Ensure-HqSecurityPrincipals" {
        It "creates missing HQ groups and users when required principals do not exist" {
            # ---------------------------------------------------------------------
            # Section: restore missing required users and groups
            # before later access rules can rely on them.
            # ---------------------------------------------------------------------

            # Setup: set the required users and groups for this case.
            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal        = 'HQ\Lab_RW'
                        Type             = 'Group'
                        ExpectedMemberOf = @()
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\hector'
                        Type             = 'User'
                        ExpectedMemberOf = @('HQ\Lab_RW')
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\svc_lab'
                        Type             = 'User'
                        ExpectedMemberOf = @()
                    }
                )
            }

            $script:createdPrincipals = @('HQ\svc_lab')
            $script:userMemberships = @{}

            # Setup: say which users and groups already exist.
            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = ($script:createdPrincipals -contains $Principal)
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = @($script:userMemberships[$Principal])
                }
            }

            # Setup: block real account creation during the test.
            Mock New-HqSecurityPrincipalGroup {
                $script:createdPrincipals += ("HQ\{0}" -f $Name)
            }
            Mock New-HqSecurityPrincipalUser {
                $script:createdPrincipals += ("HQ\{0}" -f $Name)
            }
            Mock Add-HqSecurityPrincipalToGroup {
                $script:userMemberships[$Principal] = @(@($script:userMemberships[$Principal]) + $Group | Select-Object -Unique)
            }

            # Step: run the restore function.
            $result = Ensure-HqSecurityPrincipals

            # Check: only create or unchanged results should appear here.
            @($result).Count | Should Be 3
            (@($result) | Where-Object { $_.Principal -eq 'HQ\Lab_RW' }).Action | Should Be 'Created'
            (@($result) | Where-Object { $_.Principal -eq 'HQ\hector' }).Action | Should Be 'Created'
            (@($result) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).Action | Should Be 'Unchanged'
            Assert-MockCalled New-HqSecurityPrincipalGroup -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'Lab_RW' }
            Assert-MockCalled New-HqSecurityPrincipalUser -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'hector' }
            Assert-MockCalled Add-HqSecurityPrincipalToGroup -Times 1 -Exactly -Scope It -ParameterFilter {
                $Principal -eq 'HQ\hector' -and $Group -eq 'HQ\Lab_RW'
            }
        }

        It "creates all missing groups before adding user memberships" {
            # ---------------------------------------------------------------------
            # Section: finish the group creation pass first so user memberships
            # are not added until every required group exists.
            # ---------------------------------------------------------------------

            $script:createdGroups = [System.Collections.ArrayList]::new()

            # Setup: place a user before one of the groups to prove the restore code orders them safely.
            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal        = 'HQ\Backups_RW'
                        Type             = 'Group'
                        ExpectedMemberOf = @()
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\hector'
                        Type             = 'User'
                        ExpectedMemberOf = @('HQ\Lab_RW', 'HQ\Backups_RW')
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\Lab_RW'
                        Type             = 'Group'
                        ExpectedMemberOf = @()
                    }
                )
            }

            $script:createdPrincipals = @()
            $script:userMemberships = @{}

            # Setup: start with no groups or users in place.
            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = ($script:createdPrincipals -contains $Principal)
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = @($script:userMemberships[$Principal])
                }
            }

            Mock New-HqSecurityPrincipalGroup {
                [void]$script:createdGroups.Add($Name)
                $script:createdPrincipals += ("HQ\{0}" -f $Name)
            }
            Mock New-HqSecurityPrincipalUser {
                $script:createdPrincipals += ("HQ\{0}" -f $Name)
            }
            Mock Add-HqSecurityPrincipalToGroup {
                @($script:createdGroups) | Should Be @('Backups_RW', 'Lab_RW')
                $script:userMemberships[$Principal] = @(@($script:userMemberships[$Principal]) + $Group | Select-Object -Unique)
            }

            # Step: run the restore function with the out-of-order definitions.
            Ensure-HqSecurityPrincipals | Out-Null

            # Check: both groups should be created before the user memberships are added.
            Assert-MockCalled New-HqSecurityPrincipalGroup -Times 2 -Exactly -Scope It
            Assert-MockCalled New-HqSecurityPrincipalUser -Times 1 -Exactly -Scope It -ParameterFilter { $Name -eq 'hector' }
            Assert-MockCalled Add-HqSecurityPrincipalToGroup -Times 2 -Exactly -Scope It
        }

        It "prompts securely when creating a missing mirrored user that requires a password" {
            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal              = 'HQ\Lab_RW'
                        Type                   = 'Group'
                        ExpectedMemberOf       = @()
                        PasswordPromptRequired = $false
                    }
                    [pscustomobject]@{
                        Principal              = 'HQ\hector'
                        Type                   = 'User'
                        ExpectedMemberOf       = @('HQ\Lab_RW')
                        PasswordPromptRequired = $true
                    }
                )
            }

            $script:createdPrincipals = @()
            $script:userMemberships = @{}
            $password = ConvertTo-SecureString 'pw123' -AsPlainText -Force

            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = ($script:createdPrincipals -contains $Principal)
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = @($script:userMemberships[$Principal])
                }
            }
            Mock Read-HqSecurityPrincipalPassword { $password }
            Mock New-HqSecurityPrincipalGroup {
                $script:createdPrincipals += ("HQ\{0}" -f $Name)
            }
            Mock New-HqSecurityPrincipalUser {
                $script:createdPrincipals += ("HQ\{0}" -f $Name)
            }
            Mock Add-HqSecurityPrincipalToGroup {
                $script:userMemberships[$Principal] = @(@($script:userMemberships[$Principal]) + $Group | Select-Object -Unique)
            }

            $result = Ensure-HqSecurityPrincipals

            (@($result) | Where-Object { $_.Principal -eq 'HQ\hector' }).Action | Should Be 'Created'
            Assert-MockCalled Read-HqSecurityPrincipalPassword -Times 1 -Exactly -Scope It -ParameterFilter {
                $Principal -eq 'HQ\hector'
            }
            Assert-MockCalled New-HqSecurityPrincipalUser -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'hector' -and $null -ne $Password
            }
        }

        It "prompts for a password and restores group links when creating the service account" {
            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal              = 'HQ\svc_lab'
                        Type                   = 'User'
                        ExpectedMemberOf       = @('HQ\Lab_RW')
                        PasswordPromptRequired = $true
                    }
                )
            }

            $script:createdPrincipals = @()
            $script:userMemberships = @{}
            $password = ConvertTo-SecureString 'pw123' -AsPlainText -Force

            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = ($script:createdPrincipals -contains $Principal)
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = @($script:userMemberships[$Principal])
                }
            }
            Mock Read-HqSecurityPrincipalPassword { $password }
            Mock New-HqSecurityPrincipalUser {
                $script:createdPrincipals += ("HQ\{0}" -f $Name)
            }
            Mock Add-HqSecurityPrincipalToGroup {
                $script:userMemberships[$Principal] = @(@($script:userMemberships[$Principal]) + $Group | Select-Object -Unique)
            }

            $result = Ensure-HqSecurityPrincipals

            (@($result) | Where-Object { $_.Principal -eq 'HQ\svc_lab' }).Action | Should Be 'Created'
            Assert-MockCalled Read-HqSecurityPrincipalPassword -Times 1 -Exactly -Scope It -ParameterFilter {
                $Principal -eq 'HQ\svc_lab'
            }
            Assert-MockCalled New-HqSecurityPrincipalUser -Times 1 -Exactly -Scope It -ParameterFilter {
                $Name -eq 'svc_lab' -and $null -ne $Password
            }
            Assert-MockCalled Add-HqSecurityPrincipalToGroup -Times 1 -Exactly -Scope It -ParameterFilter {
                $Principal -eq 'HQ\svc_lab' -and $Group -eq 'HQ\Lab_RW'
            }
        }

        It "adds users to missing required groups after the users and groups exist" {
            # ---------------------------------------------------------------------
            # Section: restore missing required group links
            # after the required users and groups already exist.
            # ---------------------------------------------------------------------

            # Setup: set the required user and group relationship for this case.
            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal        = 'HQ\Lab_RW'
                        Type             = 'Group'
                        ExpectedMemberOf = @()
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\hector'
                        Type             = 'User'
                        ExpectedMemberOf = @('HQ\Lab_RW')
                    }
                )
            }

            # Setup: the user and group exist, but the group link is still missing.
            $script:userMemberships = @{}
            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = $true
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = @($script:userMemberships[$Principal])
                }
            }

            # Setup: block real create and membership changes during the test.
            Mock New-HqSecurityPrincipalGroup {}
            Mock New-HqSecurityPrincipalUser {}
            Mock Add-HqSecurityPrincipalToGroup {
                $script:userMemberships[$Principal] = @(@($script:userMemberships[$Principal]) + $Group | Select-Object -Unique)
            }

            # Step: run the restore function with the missing group link.
            $result = Ensure-HqSecurityPrincipals

            # Check: the missing group link should be added for the user.
            (@($result) | Where-Object { $_.Principal -eq 'HQ\hector' }).Action | Should Be 'MembershipUpdated'
            Assert-MockCalled Add-HqSecurityPrincipalToGroup -Times 1 -Exactly -Scope It -ParameterFilter {
                $Principal -eq 'HQ\hector' -and $Group -eq 'HQ\Lab_RW'
            }
        }

        It "fails clearly when a required group link cannot be verified after add" {
            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal        = 'HQ\Lab_RW'
                        Type             = 'Group'
                        ExpectedMemberOf = @()
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\hector'
                        Type             = 'User'
                        ExpectedMemberOf = @('HQ\Lab_RW')
                    }
                )
            }

            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = $true
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = @()
                }
            }

            Mock New-HqSecurityPrincipalGroup {}
            Mock New-HqSecurityPrincipalUser {}
            Mock Add-HqSecurityPrincipalToGroup {}

            { Ensure-HqSecurityPrincipals } | Should Throw "Required group link 'HQ\Lab_RW' for 'HQ\hector' could not be verified after restore attempted to add it."
        }
    }

    Context "Test-HqRequiredSecurityPrincipalsPresent" {
        It "returns false when any required principal is still missing" {
            # ---------------------------------------------------------------------
            # Section: report when activation still needs the identity restore
            # step because a required user or group does not exist yet.
            # ---------------------------------------------------------------------

            Mock Get-HqRequiredSecurityPrincipalDefinitions {
                @(
                    [pscustomobject]@{
                        Principal        = 'HQ\Lab_RW'
                        Type             = 'Group'
                        ExpectedMemberOf = @()
                    }
                    [pscustomobject]@{
                        Principal        = 'HQ\hector'
                        Type             = 'User'
                        ExpectedMemberOf = @('HQ\Lab_RW')
                    }
                )
            }

            Mock Get-HqSecurityPrincipalStateEntry {
                [pscustomobject]@{
                    Principal        = $Principal
                    Type             = $Type
                    Name             = if ($Principal -match '^[^\\]+\\(.+)$') { $Matches[1] } else { $Principal }
                    Exists           = ($Principal -eq 'HQ\Lab_RW')
                    ExpectedMemberOf = @($ExpectedMemberOf)
                    MemberOf         = @()
                }
            }

            $result = Test-HqRequiredSecurityPrincipalsPresent

            $result | Should Be $false
        }
    }
}

