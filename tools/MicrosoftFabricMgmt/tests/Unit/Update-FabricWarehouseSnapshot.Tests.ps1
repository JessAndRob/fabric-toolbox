#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
param(
    $ModuleName = "MicrosoftFabricMgmt",
$expectedParams = @(
    "WorkspaceId"
    "WarehouseSnapshotId"
    "WarehouseSnapshotName"
    "WarehouseSnapshotDescription"
    "SnapshotDateTime"
    "ProgressAction"
    "Verbose"
    "Debug"
    "ErrorAction"
    "WarningAction"
    "InformationAction"
    "InformationVariable"
    "OutVariable"
    "OutBuffer"
    "PipelineVariable"
    "ErrorVariable"
    "WarningVariable"
    "Confirm"
    "WhatIf"
)
)

Describe "Update-FabricWarehouseSnapshot" -Tag "UnitTests" {

    BeforeDiscovery {
        $command = Get-Command -Name Update-FabricWarehouseSnapshot
        $expected = $expectedParams
    }

    Context "Parameter validation" {
        BeforeAll {
            $command = Get-Command -Name Update-FabricWarehouseSnapshot
            $expected = $expectedParams
        }

        It "Has parameter: <_>" -ForEach $expected {
            $command | Should -HaveParameter $PSItem
        }

        It "Should have exactly the number of expected parameters $($expected.Count)" {
            $hasparms = $command.Parameters.Values.Name
            #$hasparms.Count | Should -BeExactly $expected.Count
            Compare-Object -ReferenceObject $expected -DifferenceObject $hasparms | Should -BeNullOrEmpty
        }
    }
}

Describe "Update-FabricWarehouseSnapshot endpoint" -Tag "UnitTests" {

    BeforeAll {
        Get-Module MicrosoftFabricMgmt | Remove-Module -Force -ErrorAction SilentlyContinue
        $BuiltModule   = "$PSScriptRoot/../../output/module/MicrosoftFabricMgmt"
        $ModuleVersion = (Get-ChildItem $BuiltModule -Directory | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1).Name
        Import-Module (Join-Path $BuiltModule "$ModuleVersion/MicrosoftFabricMgmt.psd1") -Force -ErrorAction Stop
        InModuleScope MicrosoftFabricMgmt {
            $script:FabricAuthContext = [pscustomobject]@{ BaseUrl = 'https://api.fabric.microsoft.com/v1'; FabricHeaders = @{ Authorization = 'Bearer test' } }
        }
        Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAuthCheck {}
        Mock -ModuleName MicrosoftFabricMgmt Write-FabricLog {}
        Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest { $global:__capUri = $BaseURI; $global:__capMethod = $Method }
    }
    AfterAll { Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue }

    It 'PATCHes the warehousesnapshots endpoint using the snapshot id' {
        Update-FabricWarehouseSnapshot -WorkspaceId 'ws-1' -WarehouseSnapshotId 'snap-1' -WarehouseSnapshotName 'Q1' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/warehousesnapshots/snap-1'
        $global:__capMethod | Should -Be 'Patch'
    }
}
