#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricGatewayMember: GET /gateways/{id}/members, GatewayName enrichment.
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
    Mock -ModuleName MicrosoftFabricMgmt Resolve-FabricGatewayName { 'GW-Name' }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri    = $BaseURI
        $global:__capMethod = $Method
        @(
            [pscustomobject]@{ id = 'm-1'; displayName = 'Member 1'; version = '3000.1'; enabled = $true }
        )
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricGatewayMember' -Tag 'UnitTests' {

    It 'GETs the members endpoint' {
        $null = Get-FabricGatewayMember -GatewayId 'gw-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1/members'
        $global:__capMethod | Should -Be 'Get'
    }

    It 'enriches members with GatewayId, GatewayName and the type name' {
        $r = Get-FabricGatewayMember -GatewayId 'gw-1'
        $r[0].GatewayId          | Should -Be 'gw-1'
        $r[0].GatewayName        | Should -Be 'GW-Name'
        $r[0].PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.GatewayMember'
    }

    It '-Raw returns the untouched response' {
        $r = Get-FabricGatewayMember -GatewayId 'gw-1' -Raw
        $r[0].PSObject.Properties.Name | Should -Not -Contain 'GatewayName'
        $r[0].PSObject.TypeNames[0]    | Should -Not -Be 'MicrosoftFabric.GatewayMember'
    }

    It 'binds GatewayId from the pipeline (id alias)' {
        $null = [pscustomobject]@{ id = 'piped-gw' } | Get-FabricGatewayMember
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/piped-gw/members'
    }
}
