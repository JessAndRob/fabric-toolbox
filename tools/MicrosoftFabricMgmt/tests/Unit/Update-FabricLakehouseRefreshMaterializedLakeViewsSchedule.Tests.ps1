#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Update-FabricLakehouseRefreshMaterializedLakeViewsSchedule. #>

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

Describe 'Update-FabricLakehouseRefreshMaterializedLakeViewsSchedule' -Tag 'UnitTests' {
    It 'PATCHes the specific schedule endpoint' {
        $null = Update-FabricLakehouseRefreshMaterializedLakeViewsSchedule -WorkspaceId 'ws-1' -LakehouseId 'lh-1' -ScheduleId 'sc-1' -Enabled $false -Configuration @{ type = 'Cron' } -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/lakehouses/lh-1/jobs/RefreshMaterializedLakeViews/schedules/sc-1'
        $global:__capMethod | Should -Be 'Patch'
        $global:__capBody.enabled | Should -Be $false
    }
}
