#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Get-FabricLakehouseDefinition:
    POST /workspaces/{ws}/lakehouses/{id}/getDefinition.
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
        [pscustomobject]@{ definition = [pscustomobject]@{ parts = @() } }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Get-FabricLakehouseDefinition' -Tag 'UnitTests' {

    It 'POSTs to the lakehouse getDefinition endpoint' {
        $null = Get-FabricLakehouseDefinition -WorkspaceId 'ws-1' -LakehouseId 'lh-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/lakehouses/lh-1/getDefinition'
        $global:__capMethod | Should -Be 'Post'
    }

    It 'appends the format query when supplied' {
        $null = Get-FabricLakehouseDefinition -WorkspaceId 'ws-1' -LakehouseId 'lh-1' -Format 'x'
        $global:__capUri | Should -BeLike '*/workspaces/ws-1/lakehouses/lh-1/getDefinition*format=x*'
    }
}
