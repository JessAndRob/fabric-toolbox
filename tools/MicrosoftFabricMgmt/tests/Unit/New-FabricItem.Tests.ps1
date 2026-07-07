#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for New-FabricItem: POST /workspaces/{ws}/items with a generic item body.
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
        [pscustomobject]@{ id = 'it-new'; displayName = 'My LH'; type = 'Lakehouse'; workspaceId = 'ws-1' }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'New-FabricItem' -Tag 'UnitTests' {

    It 'POSTs to the items endpoint with displayName and type' {
        $null = New-FabricItem -WorkspaceId 'ws-1' -DisplayName 'My LH' -Type Lakehouse -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.displayName | Should -Be 'My LH'
        $global:__capBody.type        | Should -Be 'Lakehouse'
    }

    It 'includes optional folderId and definition when supplied' {
        $null = New-FabricItem -WorkspaceId 'ws-1' -DisplayName 'X' -Type Report -FolderId 'f1' -Definition @{ parts = @() } -Confirm:$false
        $global:__capBody.folderId | Should -Be 'f1'
        $global:__capBody.definition | Should -Not -BeNullOrEmpty
    }

    It 'enriches the created item with WorkspaceName and the type name' {
        $r = New-FabricItem -WorkspaceId 'ws-1' -DisplayName 'My LH' -Type Lakehouse -Confirm:$false
        $r.WorkspaceName         | Should -Be 'WS'
        $r.PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.Item'
    }
}
