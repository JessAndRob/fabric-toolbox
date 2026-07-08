#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Sync-FabricDomainRoleAssignment: POST /admin/domains/{id}/roleAssignments/syncToSubdomains. #>

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

Describe 'Sync-FabricDomainRoleAssignment' -Tag 'UnitTests' {
    It 'POSTs the role to the syncToSubdomains endpoint' {
        $null = Sync-FabricDomainRoleAssignment -DomainId 'dom-1' -Role Admin -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/admin/domains/dom-1/roleAssignments/syncToSubdomains'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.role | Should -Be 'Admin'
    }
    It 'rejects an invalid role' {
        { Sync-FabricDomainRoleAssignment -DomainId 'dom-1' -Role Owner -Confirm:$false } | Should -Throw
    }
}
