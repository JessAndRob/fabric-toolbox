#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricConnectionRoleAssignment:
    GET /connections/{id}/roleAssignments (+ /{raId}).
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
        @(
            [pscustomobject]@{ id = 'ra-1'; role = 'Owner'; principal = [pscustomobject]@{ id = 'p1'; displayName = 'Bob'; type = 'User' } }
        )
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricConnectionRoleAssignment' -Tag 'UnitTests' {

    It 'GETs the roleAssignments collection' {
        $null = Get-FabricConnectionRoleAssignment -ConnectionId 'c-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/connections/c-1/roleAssignments'
        $global:__capMethod | Should -Be 'Get'
    }

    It 'GETs a single role assignment by id' {
        $null = Get-FabricConnectionRoleAssignment -ConnectionId 'c-1' -ConnectionRoleAssignmentId 'ra-1'
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/connections/c-1/roleAssignments/ra-1'
    }

    It 'enriches with ConnectionId and the type name' {
        $r = Get-FabricConnectionRoleAssignment -ConnectionId 'c-1'
        $r[0].ConnectionId       | Should -Be 'c-1'
        $r[0].PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.ConnectionRoleAssignment'
    }

    It '-Raw returns the untouched response' {
        $r = Get-FabricConnectionRoleAssignment -ConnectionId 'c-1' -Raw
        $r[0].PSObject.Properties.Name | Should -Not -Contain 'ConnectionId'
        $r[0].PSObject.TypeNames[0]    | Should -Not -Be 'MicrosoftFabric.ConnectionRoleAssignment'
    }
}
