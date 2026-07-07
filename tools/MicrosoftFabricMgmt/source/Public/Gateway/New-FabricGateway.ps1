<#
.SYNOPSIS
    Creates a new virtual network Fabric gateway.

.DESCRIPTION
    The New-FabricGateway function creates a virtual network gateway via `POST /gateways`.
    Virtual network is the only gateway type that can be created through the API (on-premises
    gateways are installed on a host and registered separately).

    The newly created gateway is returned enriched with a resolved CapacityName and decorated for
    the custom table view. Pass -Raw to return the untouched API response.

.PARAMETER DisplayName
    The display name for the new gateway. Mandatory.

.PARAMETER CapacityId
    The unique identifier of the Fabric capacity the gateway is bound to. Mandatory.

.PARAMETER VirtualNetworkAzureResource
    A hashtable describing the Azure virtual network the gateway is deployed into. Mandatory.
    Expected keys: virtualNetworkName, subnetName, subscriptionId, resourceGroupName.

.PARAMETER InactivityMinutesBeforeSleep
    The number of idle minutes before the gateway goes to sleep. Mandatory. Valid Fabric values
    include 30, 60, 90, 120, 150, 240, 360, 480, 720, 1440.

.PARAMETER NumberOfMemberGateways
    The number of member gateways in the virtual network gateway cluster (1-7). Mandatory.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    $vnet = @{
        virtualNetworkName = 'my-vnet'
        subnetName         = 'fabric-subnet'
        subscriptionId     = '00000000-0000-0000-0000-000000000000'
        resourceGroupName  = 'my-rg'
    }
    New-FabricGateway -DisplayName 'VNet GW' -CapacityId $capId -VirtualNetworkAzureResource $vnet -InactivityMinutesBeforeSleep 30 -NumberOfMemberGateways 1

    Creates a virtual network gateway bound to the specified capacity.

.OUTPUTS
    System.Object
    The created gateway object with all API-returned properties plus a resolved CapacityName.

.NOTES
    - API Endpoint: POST /gateways
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function New-FabricGateway {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CapacityId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$VirtualNetworkAzureResource,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$InactivityMinutesBeforeSleep,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 7)]
        [int]$NumberOfMemberGateways,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways'
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                type                         = 'VirtualNetwork'
                displayName                  = $DisplayName
                capacityId                   = $CapacityId
                virtualNetworkAzureResource  = $VirtualNetworkAzureResource
                inactivityMinutesBeforeSleep = $InactivityMinutesBeforeSleep
                numberOfMemberGateways       = $NumberOfMemberGateways
            }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess($DisplayName, "Create Fabric virtual network gateway")) {
                $response = Invoke-FabricAPIRequest @apiParams

                if (-not $response) {
                    Write-FabricLog -Message "No response returned after creating gateway '$DisplayName'." -Level Warning
                    return $null
                }

                if ($Raw) {
                    return $response
                }

                if ($response.capacityId) {
                    $capacityName = $response.capacityId
                    try { $capacityName = Resolve-FabricCapacityName -CapacityId $response.capacityId }
                    catch { $capacityName = $response.capacityId }
                    $response | Add-Member -NotePropertyName 'CapacityName' -NotePropertyValue $capacityName -Force
                }

                $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.Gateway'
                Write-FabricLog -Message "Gateway '$DisplayName' created successfully!" -Level Host
                return $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to create gateway '$DisplayName'. Error: $errorDetails" -Level Error
        }
    }
}
