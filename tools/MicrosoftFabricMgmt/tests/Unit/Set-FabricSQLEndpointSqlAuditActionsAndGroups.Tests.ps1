#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Set-FabricSQLEndpointSqlAuditActionsAndGroups. #>

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

Describe 'Set-FabricSQLEndpointSqlAuditActionsAndGroups' -Tag 'UnitTests' {
    It 'POSTs a bare string array to the setAuditActionsAndGroups endpoint' {
        $null = Set-FabricSQLEndpointSqlAuditActionsAndGroups -WorkspaceId 'ws-1' -SQLEndpointId 'ep-1' -AuditActionsAndGroups 'BATCH_COMPLETED_GROUP', 'FAILED_DATABASE_AUTHENTICATION_GROUP' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/sqlEndpoints/ep-1/settings/sqlAudit/setAuditActionsAndGroups'
        $global:__capMethod | Should -Be 'Post'
        @($global:__capBody).Count | Should -Be 2
        $global:__capBody[0] | Should -Be 'BATCH_COMPLETED_GROUP'
    }
}
