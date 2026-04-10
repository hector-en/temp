Describe "Increment 3 iSCSI Lab VHDX Discovery" {
    . "$PSScriptRoot\..\configure_hq.ps1"

    Context "Get-HqLabVhdDiscoveryChoices" {
        It "enumerates existing child and parent VHDX candidates from nested share folders and includes create-new defaults" {
            # Section: expand Lab VHDX discovery so the workflow can enumerate existing
            # child disks and parent disks from the real network shares before any
            # iSCSI target publication work begins.
            #
            # Setup: discover child-VHDX candidates by walking all subfolders under
            # \\10.100.0.10\lab\virtual hdds frontends and collecting existing child
            # disks for operator selection.
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

            # Setup: discover parent-VHDX candidates by walking all subfolders under
            # \\10.100.0.10\lab\virtual hdds and collecting existing parent disks for
            # operator selection.
            $parentFiles = @(
                [pscustomobject]@{
                    FullName = '\\10.100.0.10\lab\virtual hdds\Base-Frontend\Base-Frontend.vhdx'
                    Name = 'Base-Frontend.vhdx'
                    DirectoryName = '\\10.100.0.10\lab\virtual hdds\Base-Frontend'
                }
                [pscustomobject]@{
                    FullName = '\\10.100.0.10\lab\virtual hdds\Base-Frontend-Alt\Base-Frontend-Alt.vhdx'
                    Name = 'Base-Frontend-Alt.vhdx'
                    DirectoryName = '\\10.100.0.10\lab\virtual hdds\Base-Frontend-Alt'
                }
            )

            Mock Get-ChildItem {
                if ($Path -eq '\\10.100.0.10\lab\virtual hdds frontends') {
                    return $childFiles
                }

                if ($Path -eq '\\10.100.0.10\lab\virtual hdds') {
                    return $parentFiles
                }

                throw "Unexpected path: $Path"
            }

            # Step: present the operator with a default "create new" path for child
            # disks, while still allowing selection of an existing child disk when one
            # is already present.
            #
            # Step: present the operator with a default "create new" path for parent
            # disks and parent folders, while still allowing selection of an existing
            # parent disk when one is already present.
            $result = Get-HqLabVhdDiscoveryChoices

            # Check: keep discovery responsible only for enumerating candidates and
            # returning the operator's choice set, without yet creating folders,
            # creating VHDX files, or publishing iSCSI targets.
            #
            # Check: preserve enough metadata to distinguish existing child disks,
            # existing parent disks, and the default create-new actions for each side
            # of the workflow.
            $result.ChildChoices.Count | Should Be 3
            $result.ParentChoices.Count | Should Be 3

            $result.ChildChoices[0].Action | Should Be 'CreateNew'
            $result.ChildChoices[0].ChoiceType | Should Be 'ChildVhdx'
            $result.ChildChoices[1].Action | Should Be 'UseExisting'
            $result.ChildChoices[1].Path | Should Be '\\10.100.0.10\lab\virtual hdds frontends\Frontend-01\frontend-01-child.vhdx'
            $result.ChildChoices[2].Path | Should Be '\\10.100.0.10\lab\virtual hdds frontends\Frontend-02\frontend-02-child.vhdx'

            $result.ParentChoices[0].Action | Should Be 'CreateNew'
            $result.ParentChoices[0].ChoiceType | Should Be 'ParentVhdx'
            $result.ParentChoices[1].Action | Should Be 'UseExisting'
            $result.ParentChoices[1].Path | Should Be '\\10.100.0.10\lab\virtual hdds\Base-Frontend\Base-Frontend.vhdx'
            $result.ParentChoices[2].Path | Should Be '\\10.100.0.10\lab\virtual hdds\Base-Frontend-Alt\Base-Frontend-Alt.vhdx'

            Assert-MockCalled Get-ChildItem -Times 1 -Exactly -ParameterFilter {
                $Path -eq '\\10.100.0.10\lab\virtual hdds frontends' -and $Recurse -and $File -and $Filter -eq '*.vhdx'
            }
            Assert-MockCalled Get-ChildItem -Times 1 -Exactly -ParameterFilter {
                $Path -eq '\\10.100.0.10\lab\virtual hdds' -and $Recurse -and $File -and $Filter -eq '*.vhdx'
            }
        }
    }
}