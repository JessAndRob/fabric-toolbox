#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Update-FabricGatewayMember: PATCH /gateways/{id}/members/{memberId}.
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
        [pscustomobject]@{ id = 'm-1'; displayName = 'Renamed'; enabled = $false }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Update-FabricGatewayMember' -Tag 'UnitTests' {

    It 'PATCHes the member endpoint with only supplied props' {
        $null = Update-FabricGatewayMember -GatewayId 'gw-1' -GatewayMemberId 'm-1' -Enabled $false -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1/members/m-1'
        $global:__capMethod | Should -Be 'Patch'
        $global:__capBody.enabled | Should -Be $false
        $global:__capBody.PSObject.Properties.Name | Should -Not -Contain 'displayName'
    }

    It 'sends displayName when supplied' {
        $null = Update-FabricGatewayMember -GatewayId 'gw-1' -GatewayMemberId 'm-1' -DisplayName 'Renamed' -Confirm:$false
        $global:__capBody.displayName | Should -Be 'Renamed'
    }
}
