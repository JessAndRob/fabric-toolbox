#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Get-FabricApacheAirflowPoolTemplate (list + by id). #>

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
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest { $global:__capUri = $BaseURI; $global:__capMethod = $Method; @([pscustomobject]@{ id = 'pt-1'; name = 'default' }) }
}
AfterAll { Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue }

Describe 'Get-FabricApacheAirflowPoolTemplate' -Tag 'UnitTests' {
    It 'GETs the poolTemplates list endpoint (beta)' {
        $null = Get-FabricApacheAirflowPoolTemplate -WorkspaceId 'ws-1'
        $global:__capUri    | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/apacheAirflowJobs/poolTemplates*beta=true*'
        $global:__capMethod | Should -Be 'Get'
    }
    It 'GETs a single pool template by id and decorates the type' {
        $r = Get-FabricApacheAirflowPoolTemplate -WorkspaceId 'ws-1' -PoolTemplateId 'pt-1'
        $global:__capUri | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/apacheAirflowJobs/poolTemplates/pt-1*'
        $r[0].PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.AirflowPoolTemplate'
    }
}
