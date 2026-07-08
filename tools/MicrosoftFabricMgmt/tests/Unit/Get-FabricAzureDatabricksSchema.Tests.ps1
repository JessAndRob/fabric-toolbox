#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Get-FabricAzureDatabricksSchema. #>

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
        @([pscustomobject]@{ name = 'sales'; fullName = 'main.sales' })
    }
}
AfterAll { Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue }

Describe 'Get-FabricAzureDatabricksSchema' -Tag 'UnitTests' {
    It 'GETs the schemas endpoint for the catalog' {
        $null = Get-FabricAzureDatabricksSchema -WorkspaceId 'ws-1' -CatalogName 'main' -DatabricksWorkspaceConnectionId 'conn-1'
        $global:__capUri    | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/azuredatabricks/catalogs/main/schemas*'
        $global:__capMethod | Should -Be 'Get'
    }
    It 'stamps CatalogName and the type name' {
        $r = Get-FabricAzureDatabricksSchema -WorkspaceId 'ws-1' -CatalogName 'main' -DatabricksWorkspaceConnectionId 'conn-1'
        $r[0].CatalogName           | Should -Be 'main'
        $r[0].PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.DatabricksSchema'
    }
}
