Describe "Increment 3 iSCSI Lab VHDX Discovery" {
    . "$PSScriptRoot\..\configure_hq.ps1"

    Context "Get-HqLabVhdDiscoveryChoices" {
        It "enumerates existing child VHDX candidates from nested share folders and includes create-new defaults" {
            # Section: expand Lab VHDX discovery so the workflow can enumerate existing
            # child disks from the real network shares before any iSCSI target
            # publication work begins.
            $childFiles = @(
                [pscustomobject]@{
                    FullName = '\\10.100.0.10\lab\virtual hdds frontends\Frontend-01\frontend-01-child.vhdx'
                    Name = 'frontend-01-child.vhdx'
                    DirectoryName = '\\10.100.0.10\lab\virtual hdds frontends\Frontend-01'
                }
                [pscustomobject]@{
                    FullName = '\\10.100.0.10\lab\virtual hdds frontends\Frontend-02\frontend-02-child.vhdx'
                    Name = 'frontend-02-child.vhdx'
                    DirectoryName = '\\10.100.0.10\lab\virtual hdds frontends\Frontend-02'
                }
            )

            Mock Get-ChildItem {
                if ($Path -eq '\\10.100.0.10\lab\virtual hdds frontends') {
                    return $childFiles
                }

                throw "Unexpected path: $Path"
            }

            Mock Get-VHD {
                throw 'Access denied for lineage inspection in the discovery-only slice.'
            }

            $result = Get-HqLabVhdDiscoveryChoices

            $result.ChildChoices.Count | Should Be 3

            $result.ChildChoices[0].Action | Should Be 'CreateNew'
            $result.ChildChoices[0].ChoiceType | Should Be 'ChildVhdx'
            $result.ChildChoices[0].ParentChain.Count | Should Be 0
            $result.ChildChoices[0].FinalParent | Should Be $null
            $result.ChildChoices[0].ParentChainStatus | Should Be 'NotApplicable'

            $result.ChildChoices[1].Action | Should Be 'UseExisting'
            $result.ChildChoices[1].Path | Should Be '\\10.100.0.10\lab\virtual hdds frontends\Frontend-01\frontend-01-child.vhdx'
            $result.ChildChoices[1].ParentChain.Count | Should Be 0
            $result.ChildChoices[1].FinalParent | Should Be $null
            $result.ChildChoices[1].ParentChainStatus | Should Be 'Unavailable'

            $result.ChildChoices[2].Action | Should Be 'UseExisting'
            $result.ChildChoices[2].Path | Should Be '\\10.100.0.10\lab\virtual hdds frontends\Frontend-02\frontend-02-child.vhdx'
            $result.ChildChoices[2].ParentChain.Count | Should Be 0
            $result.ChildChoices[2].FinalParent | Should Be $null
            $result.ChildChoices[2].ParentChainStatus | Should Be 'Unavailable'

            Assert-MockCalled Get-ChildItem -Times 1 -Exactly -ParameterFilter {
                $Path -eq '\\10.100.0.10\lab\virtual hdds frontends' -and $Recurse -and $File -and $Filter -eq '*.vhdx'
            }

            Assert-MockCalled Get-VHD -Times 1 -Exactly -ParameterFilter {
                $Path -eq '\\10.100.0.10\lab\virtual hdds frontends\Frontend-01\frontend-01-child.vhdx'
            }

            Assert-MockCalled Get-VHD -Times 1 -Exactly -ParameterFilter {
                $Path -eq '\\10.100.0.10\lab\virtual hdds frontends\Frontend-02\frontend-02-child.vhdx'
            }
        }
    }
}

Describe "Increment 4 iSCSI Lab VHDX Operator Selection" {
    . "$PSScriptRoot\..\configure_hq.ps1"

    Context "Resolve-HqLabVhdOperatorSelection" {
        It "returns the requested child and parent choice rows by index" {
            $discovery = [pscustomobject]@{
                ChildChoices = @(
                    [pscustomobject]@{ Action = 'CreateNew'; ChoiceType = 'ChildVhdx'; Path = $null; Name = $null; DirectoryPath = '\\10.100.0.10\lab\virtual hdds frontends' }
                    [pscustomobject]@{ Action = 'UseExisting'; ChoiceType = 'ChildVhdx'; Path = '\\10.100.0.10\lab\virtual hdds frontends\Frontend-01\frontend-01-child.vhdx'; Name = 'frontend-01-child.vhdx'; DirectoryPath = '\\10.100.0.10\lab\virtual hdds frontends\Frontend-01' }
                    [pscustomobject]@{ Action = 'UseExisting'; ChoiceType = 'ChildVhdx'; Path = '\\10.100.0.10\lab\virtual hdds frontends\Frontend-02\frontend-02-child.vhdx'; Name = 'frontend-02-child.vhdx'; DirectoryPath = '\\10.100.0.10\lab\virtual hdds frontends\Frontend-02' }
                )
                ParentChoices = @(
                    [pscustomobject]@{ Action = 'CreateNew'; ChoiceType = 'ParentVhdx'; Path = $null; Name = $null; DirectoryPath = '\\10.100.0.10\lab\virtual hdds' }
                    [pscustomobject]@{ Action = 'UseExisting'; ChoiceType = 'ParentVhdx'; Path = '\\10.100.0.10\lab\virtual hdds\Base-Frontend\Base-Frontend.vhdx'; Name = 'Base-Frontend.vhdx'; DirectoryPath = '\\10.100.0.10\lab\virtual hdds\Base-Frontend' }
                )
            }

            $selection = Resolve-HqLabVhdOperatorSelection -DiscoveryChoices $discovery -ChildChoiceIndex 2 -ParentChoiceIndex 1
            $selection.ChildChoiceIndex | Should Be 2
            $selection.ParentChoiceIndex | Should Be 1
            $selection.ChildChoice.Action | Should Be 'UseExisting'
            $selection.ChildChoice.Path | Should Be '\\10.100.0.10\lab\virtual hdds frontends\Frontend-02\frontend-02-child.vhdx'
            $selection.ParentChoice.Action | Should Be 'UseExisting'
            $selection.ParentChoice.Path | Should Be '\\10.100.0.10\lab\virtual hdds\Base-Frontend\Base-Frontend.vhdx'
        }
    }
}
