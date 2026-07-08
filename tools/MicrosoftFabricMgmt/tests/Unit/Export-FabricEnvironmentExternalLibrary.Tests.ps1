#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Export-FabricEnvironmentExternalLibrary (published + staging). #>

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
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest { $global:__capUri = $BaseURI; $global:__capMethod = $Method }
}
AfterAll { Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue }

Describe 'Export-FabricEnvironmentExternalLibrary' -Tag 'UnitTests' {
    It 'GETs the published exportExternalLibraries endpoint by default' {
        $null = Export-FabricEnvironmentExternalLibrary -WorkspaceId 'ws-1' -EnvironmentId 'env-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/environments/env-1/libraries/exportExternalLibraries'
        $global:__capMethod | Should -Be 'Get'
    }
    It 'GETs the staging endpoint when -Staging is specified' {
        $null = Export-FabricEnvironmentExternalLibrary -WorkspaceId 'ws-1' -EnvironmentId 'env-1' -Staging
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/environments/env-1/staging/libraries/exportExternalLibraries'
    }
}
