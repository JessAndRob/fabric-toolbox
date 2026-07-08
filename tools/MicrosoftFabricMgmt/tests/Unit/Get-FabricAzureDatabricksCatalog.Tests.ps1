#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Get-FabricAzureDatabricksCatalog: GET .../azuredatabricks/catalogs. #>

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
    Mock -ModuleName MicrosoftFabricMgmt Resolve-FabricWorkspaceName { 'WS' }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri = $BaseURI; $global:__capMethod = $Method
        @([pscustomobject]@{ name = 'main'; catalogType = 'Managed'; fullName = 'main' })
    }
}
AfterAll { Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue }

Describe 'Get-FabricAzureDatabricksCatalog' -Tag 'UnitTests' {
    It 'GETs the catalogs endpoint with the connection query' {
        $null = Get-FabricAzureDatabricksCatalog -WorkspaceId 'ws-1' -DatabricksWorkspaceConnectionId 'conn-1'
        $global:__capUri    | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/azuredatabricks/catalogs*databricksWorkspaceConnectionId=conn-1*'
        $global:__capMethod | Should -Be 'Get'
    }
    It 'enriches with WorkspaceName and the type name' {
        $r = Get-FabricAzureDatabricksCatalog -WorkspaceId 'ws-1' -DatabricksWorkspaceConnectionId 'conn-1'
        $r[0].WorkspaceName         | Should -Be 'WS'
        $r[0].PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.DatabricksCatalog'
    }
}
