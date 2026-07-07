#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<#
    Behavior tests for New-FabricGateway: POST /gateways with a VirtualNetwork body.
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
        [pscustomobject]@{ id = 'gw-new'; type = 'VirtualNetwork'; displayName = 'VNet GW'; capacityId = 'cap-1' }
    }
}

AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capBody -Scope Global -ErrorAction SilentlyContinue
}

Describe 'New-FabricGateway' -Tag 'UnitTests' {

    BeforeAll {
        $vnet = @{ virtualNetworkName = 'vnet'; subnetName = 'subnet'; subscriptionId = 'sub'; resourceGroupName = 'rg' }
    }

    It 'POSTs to the gateways endpoint with a VirtualNetwork body' {
        $null = New-FabricGateway -DisplayName 'VNet GW' -CapacityId 'cap-1' -VirtualNetworkAzureResource $vnet -InactivityMinutesBeforeSleep 30 -NumberOfMemberGateways 1 -Confirm:$false
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/gateways'
        $global:__capMethod | Should -Be 'Post'
        $global:__capBody.type                         | Should -Be 'VirtualNetwork'
        $global:__capBody.displayName                  | Should -Be 'VNet GW'
        $global:__capBody.capacityId                   | Should -Be 'cap-1'
        $global:__capBody.inactivityMinutesBeforeSleep | Should -Be 30
        $global:__capBody.numberOfMemberGateways       | Should -Be 1
        $global:__capBody.virtualNetworkAzureResource.virtualNetworkName | Should -Be 'vnet'
    }

    It 'enriches the created gateway with CapacityName and the type name' {
        $r = New-FabricGateway -DisplayName 'VNet GW' -CapacityId 'cap-1' -VirtualNetworkAzureResource $vnet -InactivityMinutesBeforeSleep 30 -NumberOfMemberGateways 1 -Confirm:$false
        $r.CapacityName          | Should -Be 'Cap-Name'
        $r.PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.Gateway'
    }

    It 'rejects an out-of-range NumberOfMemberGateways' {
        { New-FabricGateway -DisplayName 'x' -CapacityId 'c' -VirtualNetworkAzureResource $vnet -InactivityMinutesBeforeSleep 30 -NumberOfMemberGateways 8 -Confirm:$false } | Should -Throw
    }
}
