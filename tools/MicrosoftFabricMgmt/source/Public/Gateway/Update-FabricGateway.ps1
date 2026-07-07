<#
.SYNOPSIS
    Updates an existing Fabric gateway.

.DESCRIPTION
    The Update-FabricGateway function updates a gateway via `PATCH /gateways/{gatewayId}`. The
    request is a discriminated union keyed on gateway -Type: virtual network gateways accept
    CapacityId / InactivityMinutesBeforeSleep / NumberOfMemberGateways, while on-premises gateways
    accept LoadBalancingSetting / AllowCloudConnectionRefresh / AllowCustomConnectors. Only the
    parameters you supply are sent.

    The updated gateway is returned enriched and decorated for the custom table view; pass -Raw for
    the untouched API response.

.PARAMETER GatewayId
    The unique identifier of the gateway to update. Mandatory.

.PARAMETER Type
    The gateway type: VirtualNetwork or OnPremises. Mandatory (drives which properties are valid).

.PARAMETER DisplayName
    The new display name for the gateway.

.PARAMETER CapacityId
    (VirtualNetwork) The capacity the gateway is bound to.

.PARAMETER InactivityMinutesBeforeSleep
    (VirtualNetwork) Idle minutes before the gateway sleeps.

.PARAMETER NumberOfMemberGateways
    (VirtualNetwork) Number of member gateways in the cluster (1-7).

.PARAMETER LoadBalancingSetting
    (OnPremises) Load balancing mode: Failover or DistributeEvenly.

.PARAMETER AllowCloudConnectionRefresh
    (OnPremises) Whether cloud connection refresh is allowed.

.PARAMETER AllowCustomConnectors
    (OnPremises) Whether custom connectors are allowed.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Update-FabricGateway -GatewayId $id -Type VirtualNetwork -NumberOfMemberGateways 3

    Scales a virtual network gateway to three member gateways.

.EXAMPLE
    Update-FabricGateway -GatewayId $id -Type OnPremises -LoadBalancingSetting DistributeEvenly

    Switches an on-premises gateway cluster to even load distribution.

.OUTPUTS
    System.Object
    The updated gateway object with all API-returned properties plus a resolved CapacityName.

.NOTES
    - API Endpoint: PATCH /gateways/{gatewayId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricGateway {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('VirtualNetwork', 'OnPremises')]
        [string]$Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CapacityId,

        [Parameter()]
        [int]$InactivityMinutesBeforeSleep,

        [Parameter()]
        [ValidateRange(1, 7)]
        [int]$NumberOfMemberGateways,

        [Parameter()]
        [ValidateSet('Failover', 'DistributeEvenly')]
        [string]$LoadBalancingSetting,

        [Parameter()]
        [bool]$AllowCloudConnectionRefresh,

        [Parameter()]
        [bool]$AllowCustomConnectors,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ type = $Type }
            if ($PSBoundParameters.ContainsKey('DisplayName')) { $body.displayName = $DisplayName }
            if ($PSBoundParameters.ContainsKey('CapacityId')) { $body.capacityId = $CapacityId }
            if ($PSBoundParameters.ContainsKey('InactivityMinutesBeforeSleep')) { $body.inactivityMinutesBeforeSleep = $InactivityMinutesBeforeSleep }
            if ($PSBoundParameters.ContainsKey('NumberOfMemberGateways')) { $body.numberOfMemberGateways = $NumberOfMemberGateways }
            if ($PSBoundParameters.ContainsKey('LoadBalancingSetting')) { $body.loadBalancingSetting = $LoadBalancingSetting }
            if ($PSBoundParameters.ContainsKey('AllowCloudConnectionRefresh')) { $body.allowCloudConnectionRefresh = $AllowCloudConnectionRefresh }
            if ($PSBoundParameters.ContainsKey('AllowCustomConnectors')) { $body.allowCustomConnectors = $AllowCustomConnectors }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Patch'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Gateway '$GatewayId'", "Update gateway")) {
                $response = Invoke-FabricAPIRequest @apiParams

                if (-not $response) {
                    Write-FabricLog -Message "No response returned after updating gateway '$GatewayId'." -Level Warning
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
                Write-FabricLog -Message "Gateway '$GatewayId' updated successfully!" -Level Host
                return $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
