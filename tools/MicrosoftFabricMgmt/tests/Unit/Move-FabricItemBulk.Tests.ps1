#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Move-FabricItemBulk: POST /workspaces/{ws}/items/bulkMove.
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
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Move-FabricItemBulk' -Tag 'UnitTests' {

    It 'POSTs an items array to the bulkMove endpoint' {
        $null = Move-FabricItemBulk -WorkspaceId 'ws-1' -ItemId 'a', 'b' -TargetFolderId 'f1' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/bulkMove'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.targetFolderId | Should -Be 'f1'
        @($global:__capBody.items).Count | Should -Be 2
        $global:__capBody.items[0].id | Should -Be 'a'
    }

    It 'collects piped ids into a single bulk request' {
        $null = 'x', 'y', 'z' | ForEach-Object { [pscustomobject]@{ id = $_ } } | Move-FabricItemBulk -WorkspaceId 'ws-1' -Confirm:$false
        @($global:__capBody.items).Count | Should -Be 3
    }
}
