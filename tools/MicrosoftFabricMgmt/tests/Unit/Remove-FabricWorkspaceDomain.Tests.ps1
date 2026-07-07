#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Remove-FabricWorkspaceDomain: POST /workspaces/{ws}/unassignFromDomain.
#>

BeforeAll {
    Get-Module MicrosoftFabricMgmt | Remove-Module -Force -ErrorAction SilentlyContinue
    $BuiltModule   = "$PSScriptRoot/../../output/module/MicrosoftFabricMgmt"
    $ModuleVersion = (Get-ChildItem $BuiltModule -Directory | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1).Name
    Import-Module (Join-Path $BuiltModule "$ModuleVersion/MicrosoftFabricMgmt.psd1") -Force -ErrorAction Stop

    InModuleScope MicrosoftFabricMgmt {
        $script:FabricAuthContext = [pscustomobject]@{
            BaseUrl       = 'https://api.fabric.microsoft.com/v1'
            FabricHeaders = @{ Authorization = 'Bearer test' }
        }
    }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAuthCheck {}
    Mock -ModuleName MicrosoftFabricMgmt Write-FabricLog {}
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri    = $BaseURI
        $global:__capMethod = $Method
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Remove-FabricWorkspaceDomain' -Tag 'UnitTests' {

    It 'POSTs to the unassignFromDomain endpoint' {
        Remove-FabricWorkspaceDomain -WorkspaceId 'ws-1' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/unassignFromDomain'
        $global:__capMethod | Should -Be 'Post'
    }

    It 'does not call the API under -WhatIf' {
        $global:__capMethod = $null
        Remove-FabricWorkspaceDomain -WorkspaceId 'ws-2' -WhatIf
        $global:__capMethod | Should -BeNullOrEmpty
    }

    It 'binds WorkspaceId from the pipeline (id alias)' {
        [pscustomobject]@{ id = 'piped-ws' } | Remove-FabricWorkspaceDomain -Confirm:$false
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/piped-ws/unassignFromDomain'
    }
}
