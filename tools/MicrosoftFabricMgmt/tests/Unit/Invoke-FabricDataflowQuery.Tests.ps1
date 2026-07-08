#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Invoke-FabricDataflowQuery: POST .../dataflows/{id}/executeQuery. #>

BeforeAll {
    Get-Module MicrosoftFabricMgmt | Remove-Module -Force -ErrorAction SilentlyContinue
    $BuiltModule   = "$PSScriptRoot/../../output/module/MicrosoftFabricMgmt"
    $ModuleVersion = (Get-ChildItem $BuiltModule -Directory | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1).Name
    Import-Module (Join-Path $BuiltModule "$ModuleVersion/MicrosoftFabricMgmt.psd1") -Force -ErrorAction Stop
    InModuleScope MicrosoftFabricMgmt {
        $script:FabricAuthContext = [pscustomobject]@{ BaseUrl = 'https://api.fabric.microsoft.com/v1'; FabricHeaders = @{ Authorization = 'Bearer test' } }
    }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAuthCheck {}
    Mock -ModuleName MicrosoftFabricMgmt Write-FabricLog {}
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri = $BaseURI; $global:__capMethod = $Method; $global:__capBody = $Body | ConvertFrom-Json
    }
}
AfterAll { Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue }

Describe 'Invoke-FabricDataflowQuery' -Tag 'UnitTests' {
    It 'POSTs the queryName to the executeQuery endpoint' {
        $null = Invoke-FabricDataflowQuery -WorkspaceId 'ws-1' -DataflowId 'df-1' -QueryName 'Query1' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/dataflows/df-1/executeQuery'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.queryName | Should -Be 'Query1'
    }
    It 'includes customMashupDocument when supplied' {
        $null = Invoke-FabricDataflowQuery -WorkspaceId 'ws-1' -DataflowId 'df-1' -QueryName 'Q' -CustomMashupDocument 'let x=1 in x' -Confirm:$false
        $global:__capBody.customMashupDocument | Should -Be 'let x=1 in x'
    }
}
