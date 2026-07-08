#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Set-FabricSemanticModelConnection: POST .../semanticModels/{id}/bindConnection. #>

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

Describe 'Set-FabricSemanticModelConnection' -Tag 'UnitTests' {
    It 'POSTs a connectionBinding body to the bindConnection endpoint' {
        $null = Set-FabricSemanticModelConnection -WorkspaceId 'ws-1' -SemanticModelId 'sm-1' -ConnectionBinding @{ id = 'c1'; connectionDetails = @{ } } -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/semanticModels/sm-1/bindConnection'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.connectionBinding.id | Should -Be 'c1'
    }
}
