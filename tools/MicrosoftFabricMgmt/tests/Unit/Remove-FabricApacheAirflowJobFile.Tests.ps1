#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Remove-FabricApacheAirflowJobFile. #>

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

Describe 'Remove-FabricApacheAirflowJobFile' -Tag 'UnitTests' {
    It 'DELETEs the files/{filePath} endpoint' {
        Remove-FabricApacheAirflowJobFile -WorkspaceId 'ws-1' -ApacheAirflowJobId 'job-1' -FilePath 'dags/x.py' -Confirm:$false
        $global:__capUri    | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/ApacheAirflowJobs/job-1/files/dags/x.py*'
        $global:__capMethod | Should -Be 'Delete'
    }
    It 'does not call the API under -WhatIf' {
        $global:__capMethod = $null
        Remove-FabricApacheAirflowJobFile -WorkspaceId 'ws-1' -ApacheAirflowJobId 'job-1' -FilePath 'dags/y.py' -WhatIf
        $global:__capMethod | Should -BeNullOrEmpty
    }
}
