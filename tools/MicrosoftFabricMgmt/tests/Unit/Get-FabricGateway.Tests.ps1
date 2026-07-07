#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricGateway: GET /gateways (+ /{id}), CapacityName enrichment,
    MicrosoftFabric.Gateway decoration, and -Raw pass-through.
#>

BeforeAll {
    Get-Module MicrosoftFabricMgmt | Remove-Module -Force -ErrorAction SilentlyContinue
    $BuiltModule   = "$PSScriptRoot/../../output/module/MicrosoftFabricMgmt"
    $ModuleVersion = (Get-ChildItem $BuiltModule -Directory | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1).Name
    Import-Module (Join-Path $BuiltModule "$ModuleVersion/MicrosoftFabricMgmt.psd1") -Force -ErrorAction Stop

    InModuleScope MicrosoftFabricMgmt {
        $script:FabricAuthContext = [pscustomobject]@{
            BaseUrl       = 'https://api.fabric.microsoft.com/v1'
            FabricHeaders = @{ Authorization = 'Bearer test' }
        }
    }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAuthCheck {}
    Mock -ModuleName MicrosoftFabricMgmt Write-FabricLog {}
    Mock -ModuleName MicrosoftFabricMgmt Resolve-FabricCapacityName { 'Cap-Name' }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri    = $BaseURI
        $global:__capMethod = $Method
        @(
            [pscustomobject]@{ id = 'gw-1'; type = 'VirtualNetwork'; displayName = 'VNet GW'; capacityId = 'cap-1' }
            [pscustomobject]@{ id = 'gw-2'; type = 'OnPremises';     displayName = 'OnPrem GW' }
        )
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricGateway' -Tag 'UnitTests' {

    It 'GETs the gateways collection when no id supplied' {
        $null = Get-FabricGateway
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways'
        $global:__capMethod | Should -Be 'Get'
    }

    It 'GETs a single gateway by id' {
        $null = Get-FabricGateway -GatewayId 'gw-1'
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1'
    }

    It 'enriches capacity-bound gateways with CapacityName and the type name' {
        $r = Get-FabricGateway
        $r[0].CapacityName         | Should -Be 'Cap-Name'
        $r[0].PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.Gateway'
        # a gateway with no capacityId gets no CapacityName
        $r[1].PSObject.Properties.Name | Should -Not -Contain 'CapacityName'
    }

    It '-Raw returns the untouched response' {
        $r = Get-FabricGateway -Raw
        $r[0].PSObject.Properties.Name | Should -Not -Contain 'CapacityName'
        $r[0].PSObject.TypeNames[0]    | Should -Not -Be 'MicrosoftFabric.Gateway'
    }

    It 'binds GatewayId from the pipeline (id alias)' {
        $null = [pscustomobject]@{ id = 'piped-gw' } | Get-FabricGateway
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/piped-gw'
    }
}
