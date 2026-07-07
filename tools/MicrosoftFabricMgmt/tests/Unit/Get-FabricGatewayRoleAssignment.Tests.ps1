#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricGatewayRoleAssignment:
    GET /gateways/{id}/roleAssignments (+ /{raId}), GatewayName enrichment.
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
            [pscustomobject]@{ id = 'ra-1'; role = 'Admin'; principal = [pscustomobject]@{ id = 'p1'; displayName = 'Alice'; type = 'User' } }
        )
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricGatewayRoleAssignment' -Tag 'UnitTests' {

    It 'GETs the roleAssignments collection' {
        $null = Get-FabricGatewayRoleAssignment -GatewayId 'gw-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1/roleAssignments'
        $global:__capMethod | Should -Be 'Get'
    }

    It 'GETs a single role assignment by id' {
        $null = Get-FabricGatewayRoleAssignment -GatewayId 'gw-1' -GatewayRoleAssignmentId 'ra-1'
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1/roleAssignments/ra-1'
    }

    It 'enriches assignments with GatewayId, GatewayName and the type name' {
        $r = Get-FabricGatewayRoleAssignment -GatewayId 'gw-1'
        $r[0].GatewayId          | Should -Be 'gw-1'
        $r[0].GatewayName        | Should -Be 'GW-Name'
        $r[0].PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.GatewayRoleAssignment'
    }

    It '-Raw returns the untouched response' {
        $r = Get-FabricGatewayRoleAssignment -GatewayId 'gw-1' -Raw
        $r[0].PSObject.Properties.Name | Should -Not -Contain 'GatewayName'
        $r[0].PSObject.TypeNames[0]    | Should -Not -Be 'MicrosoftFabric.GatewayRoleAssignment'
    }
}
