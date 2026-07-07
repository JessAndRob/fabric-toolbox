#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Set-FabricOneLakeDiagnostic:
    POST /workspaces/{ws}/onelake/settings/modifyDiagnostics.
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

Describe 'Set-FabricOneLakeDiagnostic' -Tag 'UnitTests' {

    It 'POSTs the status to the modifyDiagnostics endpoint' {
        $null = Set-FabricOneLakeDiagnostic -WorkspaceId 'ws-1' -Status Disabled -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/onelake/settings/modifyDiagnostics'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.status | Should -Be 'Disabled'
    }

    It 'includes destination when supplied' {
        $null = Set-FabricOneLakeDiagnostic -WorkspaceId 'ws-1' -Status Enabled -Destination @{ type = 'x' } -Confirm:$false
        $global:__capBody.status      | Should -Be 'Enabled'
        $global:__capBody.destination | Should -Not -BeNullOrEmpty
    }

    It 'rejects an invalid status' {
        { Set-FabricOneLakeDiagnostic -WorkspaceId 'ws-1' -Status Bogus -Confirm:$false } | Should -Throw
    }
}
