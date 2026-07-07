#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Remove-FabricItem: DELETE /workspaces/{ws}/items/{itemId}.
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

Describe 'Remove-FabricItem' -Tag 'UnitTests' {

    It 'DELETEs the item endpoint' {
        Remove-FabricItem -WorkspaceId 'ws-1' -ItemId 'it-1' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/it-1'
        $global:__capMethod | Should -Be 'Delete'
    }

    It 'does not call the API under -WhatIf' {
        $global:__capMethod = $null
        Remove-FabricItem -WorkspaceId 'ws-1' -ItemId 'it-2' -WhatIf
        $global:__capMethod | Should -BeNullOrEmpty
    }

    It 'binds ItemId from the pipeline (id alias)' {
        [pscustomobject]@{ id = 'piped-item'; workspaceId = 'ws-1' } | Remove-FabricItem -WorkspaceId 'ws-1' -Confirm:$false
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/piped-item'
    }
}
