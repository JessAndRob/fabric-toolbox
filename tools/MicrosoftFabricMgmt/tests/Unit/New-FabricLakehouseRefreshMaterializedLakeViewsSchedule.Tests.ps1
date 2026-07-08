#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for New-FabricLakehouseRefreshMaterializedLakeViewsSchedule. #>

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

Describe 'New-FabricLakehouseRefreshMaterializedLakeViewsSchedule' -Tag 'UnitTests' {
    It 'POSTs enabled+configuration to the schedules endpoint' {
        $null = New-FabricLakehouseRefreshMaterializedLakeViewsSchedule -WorkspaceId 'ws-1' -LakehouseId 'lh-1' -Enabled $true -Configuration @{ type = 'Daily' } -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/lakehouses/lh-1/jobs/RefreshMaterializedLakeViews/schedules'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.enabled | Should -Be $true
        $global:__capBody.configuration.type | Should -Be 'Daily'
    }
}
