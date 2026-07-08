#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for New-FabricDataflowJobSchedule: POST .../dataflows/{id}/jobs/{jobType}/schedules. #>

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

Describe 'New-FabricDataflowJobSchedule' -Tag 'UnitTests' {
    It 'POSTs to the job-type schedules endpoint' {
        $null = New-FabricDataflowJobSchedule -WorkspaceId 'ws-1' -DataflowId 'df-1' -JobType Execute -Enabled $true -Configuration @{ type = 'Daily' } -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/dataflows/df-1/jobs/Execute/schedules'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.enabled | Should -Be $true
    }
    It 'targets ApplyChanges when requested and rejects unknown job types' {
        $null = New-FabricDataflowJobSchedule -WorkspaceId 'ws-1' -DataflowId 'df-1' -JobType ApplyChanges -Enabled $true -Configuration @{ type = 'Cron' } -Confirm:$false
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/dataflows/df-1/jobs/ApplyChanges/schedules'
        { New-FabricDataflowJobSchedule -WorkspaceId 'ws-1' -DataflowId 'df-1' -JobType Bogus -Enabled $true -Configuration @{} -Confirm:$false } | Should -Throw
    }
}
