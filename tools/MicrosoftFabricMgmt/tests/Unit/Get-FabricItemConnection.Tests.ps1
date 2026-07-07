#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricItemConnection:
    GET /workspaces/{id}/items/{itemId}/connections, default enrichment (WorkspaceName /
    GatewayName / type), -Raw returns the untouched response.
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
    Mock -ModuleName MicrosoftFabricMgmt Resolve-FabricGatewayName   { 'GW-Name' }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri    = $BaseURI
        $global:__capMethod = $Method
        @(
            [pscustomobject]@{ id = 'conn-1'; displayName = 'SQL'; connectivityType = 'ShareableCloud'; gatewayId = 'gw-1' }
            [pscustomobject]@{ id = 'conn-2'; displayName = 'Web'; connectivityType = 'ShareableCloud' }
        )
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricItemConnection' -Tag 'UnitTests' {

    It 'GETs the item connections endpoint' {
        $null = Get-FabricItemConnection -WorkspaceId 'ws-1' -ItemId 'it-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/it-1/connections'
        $global:__capMethod | Should -Be 'Get'
    }

    It 'enriches with WorkspaceName, GatewayName (when bound) and type by default' {
        $r = Get-FabricItemConnection -WorkspaceId 'ws-1' -ItemId 'it-1'
        $r[0].WorkspaceName          | Should -Be 'WS'
        $r[0].workspaceId            | Should -Be 'ws-1'
        $r[0].GatewayName            | Should -Be 'GW-Name'
        $r[0].PSObject.TypeNames[0]  | Should -Be 'MicrosoftFabric.Connection'
        $r[0].id                     | Should -Be 'conn-1'
        # a connection without a gatewayId gets no GatewayName
        $r[1].PSObject.Properties.Name | Should -Not -Contain 'GatewayName'
    }

    It '-Raw returns the untouched response (no added names, no type)' {
        $r = Get-FabricItemConnection -WorkspaceId 'ws-1' -ItemId 'it-1' -Raw
        $r[0].PSObject.Properties.Name | Should -Not -Contain 'WorkspaceName'
        $r[0].PSObject.Properties.Name | Should -Not -Contain 'GatewayName'
        $r[0].PSObject.TypeNames[0]    | Should -Not -Be 'MicrosoftFabric.Connection'
        $r[0].id                       | Should -Be 'conn-1'
    }

    It 'binds ItemId from the pipeline (id alias)' {
        $null = [pscustomobject]@{ id = 'piped-item' } | Get-FabricItemConnection -WorkspaceId 'ws-1'
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/piped-item/connections'
    }
}
