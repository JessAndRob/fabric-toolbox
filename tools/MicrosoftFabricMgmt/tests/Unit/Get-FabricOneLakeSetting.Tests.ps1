#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricOneLakeSetting: GET /workspaces/{ws}/onelake/settings.
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
    Mock -ModuleName MicrosoftFabricMgmt Resolve-FabricWorkspaceName { 'WS' }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri    = $BaseURI
        $global:__capMethod = $Method
        [pscustomobject]@{ diagnostics = [pscustomobject]@{ status = 'Disabled' }; immutabilityPolicies = @() }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricOneLakeSetting' -Tag 'UnitTests' {

    It 'GETs the onelake settings endpoint' {
        $null = Get-FabricOneLakeSetting -WorkspaceId 'ws-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/onelake/settings'
        $global:__capMethod | Should -Be 'Get'
    }

    It 'enriches with WorkspaceName and the type name' {
        $r = Get-FabricOneLakeSetting -WorkspaceId 'ws-1'
        $r.WorkspaceName         | Should -Be 'WS'
        $r.PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.OneLakeSetting'
    }

    It '-Raw returns the untouched response' {
        $r = Get-FabricOneLakeSetting -WorkspaceId 'ws-1' -Raw
        $r.PSObject.Properties.Name | Should -Not -Contain 'WorkspaceName'
    }
}
