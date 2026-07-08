#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Get-FabricApacheAirflowJobFile (list + by path). #>

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
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest { $global:__capUri = $BaseURI; $global:__capMethod = $Method; @([pscustomobject]@{ path = 'dags/x.py' }) }
}
AfterAll { Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue }

Describe 'Get-FabricApacheAirflowJobFile' -Tag 'UnitTests' {
    It 'GETs the files list endpoint (beta) by default' {
        $null = Get-FabricApacheAirflowJobFile -WorkspaceId 'ws-1' -ApacheAirflowJobId 'job-1'
        $global:__capUri    | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/ApacheAirflowJobs/job-1/files*beta=true*'
        $global:__capMethod | Should -Be 'Get'
    }
    It 'GETs a single file when -FilePath is given' {
        $null = Get-FabricApacheAirflowJobFile -WorkspaceId 'ws-1' -ApacheAirflowJobId 'job-1' -FilePath 'dags/x.py'
        $global:__capUri | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/ApacheAirflowJobs/job-1/files/dags/x.py*'
    }
}
