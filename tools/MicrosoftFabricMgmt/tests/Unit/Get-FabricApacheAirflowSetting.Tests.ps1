#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Get-FabricApacheAirflowSetting. #>

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
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest { $global:__capUri = $BaseURI; $global:__capMethod = $Method; [pscustomobject]@{ defaultPoolTemplateId = 'pt-1' } }
}
AfterAll { Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue }

Describe 'Get-FabricApacheAirflowSetting' -Tag 'UnitTests' {
    It 'GETs the settings endpoint (beta)' {
        $null = Get-FabricApacheAirflowSetting -WorkspaceId 'ws-1'
        $global:__capUri    | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/apacheAirflowJobs/settings*beta=true*'
        $global:__capMethod | Should -Be 'Get'
    }
}
