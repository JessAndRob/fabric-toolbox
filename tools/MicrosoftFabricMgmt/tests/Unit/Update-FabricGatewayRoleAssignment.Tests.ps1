#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Update-FabricGatewayRoleAssignment:
    PATCH /gateways/{id}/roleAssignments/{raId}.
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
        $global:__capBody   = $Body | ConvertFrom-Json
        [pscustomobject]@{ id = 'ra-1'; role = 'ConnectionCreator' }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Update-FabricGatewayRoleAssignment' -Tag 'UnitTests' {

    It 'PATCHes the role assignment endpoint with the new role' {
        $null = Update-FabricGatewayRoleAssignment -GatewayId 'gw-1' -GatewayRoleAssignmentId 'ra-1' -GatewayRole ConnectionCreator -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1/roleAssignments/ra-1'
        $global:__capMethod | Should -Be 'Patch'
        $global:__capBody.role | Should -Be 'ConnectionCreator'
    }

    It 'rejects an invalid GatewayRole' {
        { Update-FabricGatewayRoleAssignment -GatewayId 'gw-1' -GatewayRoleAssignmentId 'ra-1' -GatewayRole Owner -Confirm:$false } | Should -Throw
    }
}
