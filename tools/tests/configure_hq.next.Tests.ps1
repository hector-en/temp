Describe "configure_hq.next - Disk Discovery and Activation" {
    . "$PSScriptRoot\..\configure_hq.next.ps1"

    Context "Get-HqAttachedDataDisks" {
        It "returns only data disks by default" {
            $disks = @(
                [pscustomobject]@{ Number = 0; SourceVhd = 'V:\VHDs\disks\HQ\HQ2025.vhdx'; IsSystem = $true; IsBoot = $true; IsOffline = $false; IsReadOnly = $false }
                [pscustomobject]@{ Number = 1; SourceVhd = 'M:\repository1.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $true; IsReadOnly = $true }
                [pscustomobject]@{ Number = 2; SourceVhd = 'W:\vmdisk.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $false; IsReadOnly = $false }
                [pscustomobject]@{ Number = 3; SourceVhd = 'X:\backup1.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $false; IsReadOnly = $true }
            )

            $result = Get-HqAttachedDataDisks -Disks $disks

            $result.Count | Should Be 3
            ($result | Select-Object -ExpandProperty Number) -join "," | Should Be "1,2,3"
        }

        It "filters by requested disk numbers" {
            $disks = @(
                [pscustomobject]@{ Number = 0; SourceVhd = 'V:\VHDs\disks\HQ\HQ2025.vhdx'; IsSystem = $true; IsBoot = $true; IsOffline = $false; IsReadOnly = $false }
                [pscustomobject]@{ Number = 1; SourceVhd = 'M:\repository1.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $true; IsReadOnly = $true }
                [pscustomobject]@{ Number = 2; SourceVhd = 'W:\vmdisk.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $false; IsReadOnly = $false }
                [pscustomobject]@{ Number = 3; SourceVhd = 'X:\backup1.vhdx'; IsSystem = $false; IsBoot = $false; IsOffline = $false; IsReadOnly = $true }
            )

            $result = Get-HqAttachedDataDisks -Disks $disks -DiskNumbers @(2, 3)

            $result.Count | Should Be 2
            $result[0].Number | Should Be 2
            $result[1].Number | Should Be 3
        }

        It "uses Get-Disk when disks are not injected" {
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
        It "calls Set-Disk for offline disks" {
            Mock Set-Disk {}

            $disks = @(
                [pscustomobject]@{ Number = 1; SourceVhd = 'M:\repository1.vhdx'; IsOffline = $true; IsReadOnly = $true },
                [pscustomobject]@{ Number = 2; SourceVhd = 'W:\vmdisk.vhdx'; IsOffline = $false; IsReadOnly = $false },
                [pscustomobject]@{ Number = 3; SourceVhd = 'X:\backup1.vhdx'; IsOffline = $false; IsReadOnly = $true }
            )

            $result = Bring-HqDisksOnline -Disks $disks

            $result.Count | Should Be 3
            ($result | Where-Object { $_.Action -eq "Updated" }).Count | Should Be 2
            Assert-MockCalled Set-Disk -Times 3 -Exactly
            Assert-MockCalled Set-Disk -Times 1 -Exactly -ParameterFilter { $Number -eq 1 -and $IsOffline -eq $false }
            Assert-MockCalled Set-Disk -Times 1 -Exactly -ParameterFilter { $Number -eq 1 -and $IsReadOnly -eq $false }
            Assert-MockCalled Set-Disk -Times 1 -Exactly -ParameterFilter { $Number -eq 3 -and $IsReadOnly -eq $false }
        }
    }

    Context "Invoke-HqDiskActivation" {
        It "orchestrates discovery and activation" {
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

            $result = Invoke-HqDiskActivation -DiskNumbers @(1, 2, 3)

            $result.Count | Should Be 3
            $result[0].DiskNumber | Should Be 1
            $result[1].DiskNumber | Should Be 2
            $result[2].DiskNumber | Should Be 3
            Assert-MockCalled Get-HqAttachedDataDisks -Times 1 -Exactly -ParameterFilter { ($DiskNumbers -join ',') -eq '1,2,3' }
            Assert-MockCalled Bring-HqDisksOnline -Times 1 -Exactly
        }
    }
}
