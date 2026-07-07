#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricItemDefinition: POST /workspaces/{ws}/items/{itemId}/getDefinition.
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
        [pscustomobject]@{ definition = [pscustomobject]@{ format = 'ipynb'; parts = @() } }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricItemDefinition' -Tag 'UnitTests' {

    It 'POSTs to the getDefinition endpoint' {
        $null = Get-FabricItemDefinition -WorkspaceId 'ws-1' -ItemId 'it-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/it-1/getDefinition'
        $global:__capMethod | Should -Be 'Post'
    }

    It 'appends the format query when supplied' {
        $null = Get-FabricItemDefinition -WorkspaceId 'ws-1' -ItemId 'it-1' -Format ipynb
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/items/it-1/getDefinition?format=ipynb'
    }

    It 'returns the definition' {
        $r = Get-FabricItemDefinition -WorkspaceId 'ws-1' -ItemId 'it-1'
        $r.definition.format | Should -Be 'ipynb'
    }
}
