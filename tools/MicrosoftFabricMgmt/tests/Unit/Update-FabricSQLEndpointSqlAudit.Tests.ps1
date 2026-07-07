#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Update-FabricSQLEndpointSqlAudit: PATCH .../sqlEndpoints/{id}/settings/sqlAudit. #>

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

Describe 'Update-FabricSQLEndpointSqlAudit' -Tag 'UnitTests' {
    It 'PATCHes only supplied props to the sqlAudit endpoint' {
        $null = Update-FabricSQLEndpointSqlAudit -WorkspaceId 'ws-1' -SQLEndpointId 'ep-1' -State Enabled -RetentionDays 30 -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/sqlEndpoints/ep-1/settings/sqlAudit'
        $global:__capMethod | Should -Be 'Patch'
        $global:__capBody.state         | Should -Be 'Enabled'
        $global:__capBody.retentionDays | Should -Be 30
    }
    It 'rejects an invalid state' {
        { Update-FabricSQLEndpointSqlAudit -WorkspaceId 'ws-1' -SQLEndpointId 'ep-1' -State Bogus -Confirm:$false } | Should -Throw
    }
}
