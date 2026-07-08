#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for New-FabricApacheAirflowPoolTemplate. #>

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

Describe 'New-FabricApacheAirflowPoolTemplate' -Tag 'UnitTests' {
    It 'POSTs a full pool template body to the poolTemplates endpoint' {
        $null = New-FabricApacheAirflowPoolTemplate -WorkspaceId 'ws-1' -Name 'default' -NodeSize Small -MinNodeCount 1 -MaxNodeCount 3 -ApacheAirflowJobVersion '2.9.3' -Confirm:$false
        $global:__capUri    | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/apacheAirflowJobs/poolTemplates*'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.name                        | Should -Be 'default'
        $global:__capBody.nodeSize                    | Should -Be 'Small'
        $global:__capBody.computeScalability.minNodeCount | Should -Be 1
        $global:__capBody.computeScalability.maxNodeCount | Should -Be 3
        $global:__capBody.apacheAirflowJobVersion     | Should -Be '2.9.3'
    }
    It 'rejects an invalid node size' {
        { New-FabricApacheAirflowPoolTemplate -WorkspaceId 'ws-1' -Name 'x' -NodeSize Medium -MinNodeCount 1 -MaxNodeCount 2 -ApacheAirflowJobVersion '2.9.3' -Confirm:$false } | Should -Throw
    }
}
