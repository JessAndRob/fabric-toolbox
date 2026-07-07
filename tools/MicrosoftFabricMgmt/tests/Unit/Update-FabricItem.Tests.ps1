#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Update-FabricItem: PATCH /workspaces/{ws}/items/{itemId}.
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
        $global:__capBody   = $Body | ConvertFrom-Json
        [pscustomobject]@{ id = 'it-1'; displayName = 'Renamed'; type = 'Lakehouse'; workspaceId = 'ws-1' }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Update-FabricItem' -Tag 'UnitTests' {

    It 'PATCHes the item endpoint with only supplied props' {
        $null = Update-FabricItem -WorkspaceId 'ws-1' -ItemId 'it-1' -DisplayName 'Renamed' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/it-1'
        $global:__capMethod | Should -Be 'Patch'
        $global:__capBody.displayName | Should -Be 'Renamed'
        $global:__capBody.PSObject.Properties.Name | Should -Not -Contain 'description'
    }

    It 'sends description when supplied' {
        $null = Update-FabricItem -WorkspaceId 'ws-1' -ItemId 'it-1' -Description 'New desc' -Confirm:$false
        $global:__capBody.description | Should -Be 'New desc'
    }

    It 'enriches the updated item and binds ItemId from the pipeline (id alias)' {
        $r = [pscustomobject]@{ id = 'piped-item'; workspaceId = 'ws-1' } | Update-FabricItem -WorkspaceId 'ws-1' -DisplayName 'Y' -Confirm:$false
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/piped-item'
        $r.WorkspaceName | Should -Be 'WS'
    }
}
