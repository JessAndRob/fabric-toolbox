#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Add-FabricWorkspaceDomain: POST /workspaces/{ws}/assignToDomain.
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
        $global:__capBody   = $Body | ConvertFrom-Json
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Add-FabricWorkspaceDomain' -Tag 'UnitTests' {

    It 'POSTs the domainId to the assignToDomain endpoint' {
        $null = Add-FabricWorkspaceDomain -WorkspaceId 'ws-1' -DomainId 'dom-1' -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/assignToDomain'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.domainId | Should -Be 'dom-1'
    }

    It 'binds WorkspaceId from the pipeline (id alias)' {
        $null = [pscustomobject]@{ id = 'piped-ws' } | Add-FabricWorkspaceDomain -DomainId 'dom-1' -Confirm:$false
        $global:__capUri | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/piped-ws/assignToDomain'
    }
}
