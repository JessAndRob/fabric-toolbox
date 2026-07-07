#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricItemExternalDataShare:
    GET /workspaces/{ws}/items/{itemId}/externalDataShares (+ /{id}).
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
        @(
            [pscustomobject]@{ id = 'eds-1'; status = 'Active'; workspaceId = 'ws-1'; itemId = 'it-1' }
        )
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricItemExternalDataShare' -Tag 'UnitTests' {

    It 'GETs the externalDataShares collection for an item' {
        $null = Get-FabricItemExternalDataShare -WorkspaceId 'ws-1' -ItemId 'it-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/it-1/externalDataShares'
        $global:__capMethod | Should -Be 'Get'
    }

    It 'GETs a single external data share by id' {
        $null = Get-FabricItemExternalDataShare -WorkspaceId 'ws-1' -ItemId 'it-1' -ExternalDataShareId 'eds-1'
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/it-1/externalDataShares/eds-1'
    }

    It 'enriches with WorkspaceName and the type name' {
        $r = Get-FabricItemExternalDataShare -WorkspaceId 'ws-1' -ItemId 'it-1'
        $r[0].WorkspaceName      | Should -Be 'WS'
        $r[0].PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.ExternalDataShare'
    }

    It 'binds ItemId from the pipeline (id alias)' {
        $null = [pscustomobject]@{ id = 'piped-item' } | Get-FabricItemExternalDataShare -WorkspaceId 'ws-1'
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/piped-item/externalDataShares'
    }
}
