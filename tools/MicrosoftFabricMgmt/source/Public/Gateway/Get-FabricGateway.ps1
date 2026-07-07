<#
.SYNOPSIS
    Lists Fabric gateways or retrieves a single gateway by id.

.DESCRIPTION
    The Get-FabricGateway function retrieves gateways from the Fabric tenant via
    `GET /gateways`, or a single gateway via `GET /gateways/{gatewayId}` when -GatewayId is
    supplied. Results are auto-paginated.

    By default each gateway is enriched with a resolved CapacityName (for virtual network
    gateways bound to a capacity) and decorated for the custom table view. Pass -Raw to return
    the untouched API response.

.PARAMETER GatewayId
    The unique identifier of a gateway to retrieve. When omitted, all gateways are listed.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricGateway

    Lists every gateway in the tenant.

.EXAMPLE
    Get-FabricGateway -GatewayId "12345678-1234-1234-1234-123456789012"

    Retrieves the single gateway with the specified id.

.OUTPUTS
    System.Object
    Gateway object(s) with all API-returned properties (id, type, displayName, capacityId,
    virtualNetworkAzureResource, publicKey, version, loadBalancingSetting, etc.) plus a resolved
    CapacityName when enriched.

.NOTES
    - API Endpoint: GET /gateways and GET /gateways/{gatewayId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricGateway {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = if ($GatewayId) {
                New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId
            }
            else {
                New-FabricAPIUri -Resource 'gateways'
            }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No gateways found." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            foreach ($gateway in $response) {
                # Resolve the capacity display name for capacity-bound (virtual network) gateways.
                if ($gateway.capacityId) {
                    $capacityName = $gateway.capacityId
                    try { $capacityName = Resolve-FabricCapacityName -CapacityId $gateway.capacityId }
                    catch {
                        Write-FabricLog -Message "Failed to resolve capacity name for ID '$($gateway.capacityId)': $($_.Exception.Message)" -Level Debug
                    }
                    $gateway | Add-Member -NotePropertyName 'CapacityName' -NotePropertyValue $capacityName -Force
                }
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.Gateway'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve gateway(s). Error: $errorDetails" -Level Error
        }
    }
}
