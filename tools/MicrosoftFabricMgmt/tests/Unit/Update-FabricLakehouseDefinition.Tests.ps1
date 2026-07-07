#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Update-FabricLakehouseDefinition:
    POST /workspaces/{ws}/lakehouses/{id}/updateDefinition.
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

Describe 'Update-FabricLakehouseDefinition' -Tag 'UnitTests' {

    BeforeAll {
        $def = @{ parts = @(@{ path = 'x.json'; payload = 'abc'; payloadType = 'InlineBase64' }) }
    }

    It 'POSTs a definition body to the updateDefinition endpoint' {
        $null = Update-FabricLakehouseDefinition -WorkspaceId 'ws-1' -LakehouseId 'lh-1' -Definition $def -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/lakehouses/lh-1/updateDefinition'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.definition.parts[0].path | Should -Be 'x.json'
    }

    It 'adds the updateMetadata query when -UpdateMetadata is set' {
        $null = Update-FabricLakehouseDefinition -WorkspaceId 'ws-1' -LakehouseId 'lh-1' -Definition $def -UpdateMetadata -Confirm:$false
        $global:__capUri | Should -BeLike '*updateMetadata=true*'
    }
}
