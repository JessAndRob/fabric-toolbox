#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for Update-FabricGateway: PATCH /gateways/{id} with only-supplied properties.
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
    Mock -ModuleName MicrosoftFabricMgmt Resolve-FabricCapacityName { 'Cap-Name' }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri    = $BaseURI
        $global:__capMethod = $Method
        $global:__capBody   = $Body | ConvertFrom-Json
        [pscustomobject]@{ id = 'gw-1'; type = 'VirtualNetwork'; displayName = 'VNet GW' }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Update-FabricGateway' -Tag 'UnitTests' {

    It 'PATCHes the gateway endpoint and sends type plus only supplied props' {
        $null = Update-FabricGateway -GatewayId 'gw-1' -Type VirtualNetwork -NumberOfMemberGateways 3 -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways/gw-1'
        $global:__capMethod | Should -Be 'Patch'
        $global:__capBody.type                   | Should -Be 'VirtualNetwork'
        $global:__capBody.numberOfMemberGateways | Should -Be 3
        $global:__capBody.PSObject.Properties.Name | Should -Not -Contain 'loadBalancingSetting'
    }

    It 'sends on-premises load balancing settings when supplied' {
        $null = Update-FabricGateway -GatewayId 'gw-1' -Type OnPremises -LoadBalancingSetting DistributeEvenly -AllowCustomConnectors $true -Confirm:$false
        $global:__capBody.loadBalancingSetting  | Should -Be 'DistributeEvenly'
        $global:__capBody.allowCustomConnectors | Should -Be $true
    }

    It 'rejects an invalid Type' {
        { Update-FabricGateway -GatewayId 'gw-1' -Type Bogus -Confirm:$false } | Should -Throw
    }
}
