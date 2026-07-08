#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Add-FabricAdminGatewayDatasourceUser. #>

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
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest { $global:__capUri = $BaseURI; $global:__capMethod = $Method; $global:__capBody = $Body | ConvertFrom-Json }
}
AfterAll { Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue }

Describe 'Add-FabricAdminGatewayDatasourceUser' -Tag 'UnitTests' {
    It 'POSTs the user grant to the datasource users endpoint' {
        $null = Add-FabricAdminGatewayDatasourceUser -GatewayId 'gw-1' -DatasourceId 'ds-1' -DatasourceAccessRight Read -EmailAddress 'u@c.com' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.powerbi.com/v1.0/myorg/gateways/gw-1/datasources/ds-1/users'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.datasourceAccessRight | Should -Be 'Read'
        $global:__capBody.emailAddress          | Should -Be 'u@c.com'
    }
    It 'rejects an invalid access right' {
        { Add-FabricAdminGatewayDatasourceUser -GatewayId 'gw-1' -DatasourceId 'ds-1' -DatasourceAccessRight Write -EmailAddress 'u@c.com' -Confirm:$false } | Should -Throw
    }
}
