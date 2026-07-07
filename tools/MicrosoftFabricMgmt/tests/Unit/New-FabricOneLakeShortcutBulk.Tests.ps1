#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for New-FabricOneLakeShortcutBulk:
    POST /workspaces/{ws}/items/{itemId}/shortcuts/bulkCreate.
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
        [pscustomobject]@{ value = @() }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'New-FabricOneLakeShortcutBulk' -Tag 'UnitTests' {

    BeforeAll {
        $reqs = @(
            @{ path = 'Files'; name = 'sc1'; target = @{ oneLake = @{ workspaceId = 'ws-1'; itemId = 'lh'; path = 'Tables/t1' } } }
        )
    }

    It 'POSTs createShortcutRequests to the bulkCreate endpoint' {
        $null = New-FabricOneLakeShortcutBulk -WorkspaceId 'ws-1' -ItemId 'lh' -CreateShortcutRequest $reqs -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/lh/shortcuts/bulkCreate'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.createShortcutRequests[0].name | Should -Be 'sc1'
    }

    It 'appends the shortcutConflictPolicy query when supplied' {
        $null = New-FabricOneLakeShortcutBulk -WorkspaceId 'ws-1' -ItemId 'lh' -CreateShortcutRequest $reqs -ShortcutConflictPolicy GenerateUniqueName -Confirm:$false
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/lh/shortcuts/bulkCreate?shortcutConflictPolicy=GenerateUniqueName'
    }
}
