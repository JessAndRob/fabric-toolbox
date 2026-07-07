#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Remove-FabricGatewayRoleAssignment:
    DELETE /gateways/{id}/roleAssignments/{raId}.
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
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri    = $BaseURI
        $global:__capMethod = $Method
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Remove-FabricGatewayRoleAssignment' -Tag 'UnitTests' {

    It 'DELETEs the role assignment endpoint' {
        Remove-FabricGatewayRoleAssignment -GatewayId 'gw-1' -GatewayRoleAssignmentId 'ra-1' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1/roleAssignments/ra-1'
        $global:__capMethod | Should -Be 'Delete'
    }

    It 'does not call the API under -WhatIf' {
        $global:__capMethod = $null
        Remove-FabricGatewayRoleAssignment -GatewayId 'gw-1' -GatewayRoleAssignmentId 'ra-2' -WhatIf
        $global:__capMethod | Should -BeNullOrEmpty
    }

    It 'binds GatewayRoleAssignmentId from the pipeline (id alias)' {
        [pscustomobject]@{ id = 'piped-ra' } | Remove-FabricGatewayRoleAssignment -GatewayId 'gw-1' -Confirm:$false
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1/roleAssignments/piped-ra'
    }
}
