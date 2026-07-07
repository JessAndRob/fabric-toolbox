#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Add-FabricGatewayRoleAssignment: POST /gateways/{id}/roleAssignments.
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
        [pscustomobject]@{ id = 'ra-new'; role = 'Admin' }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Add-FabricGatewayRoleAssignment' -Tag 'UnitTests' {

    It 'POSTs a principal/role body to the roleAssignments endpoint' {
        $null = Add-FabricGatewayRoleAssignment -GatewayId 'gw-1' -PrincipalId 'p1' -PrincipalType User -GatewayRole Admin -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1/roleAssignments'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.principal.id   | Should -Be 'p1'
        $global:__capBody.principal.type | Should -Be 'User'
        $global:__capBody.role           | Should -Be 'Admin'
    }

    It 'rejects an invalid GatewayRole' {
        { Add-FabricGatewayRoleAssignment -GatewayId 'gw-1' -PrincipalId 'p1' -PrincipalType User -GatewayRole Owner -Confirm:$false } | Should -Throw
    }
}
