<#
.SYNOPSIS
    Lists the member gateways of a Fabric gateway cluster.

.DESCRIPTION
    The Get-FabricGatewayMember function retrieves the members of a gateway via
    `GET /gateways/{gatewayId}/members`. Results are auto-paginated.

    By default each member is enriched with the owning GatewayId / resolved GatewayName and
    decorated for the custom table view. Pass -Raw to return the untouched API response.

.PARAMETER GatewayId
    The unique identifier of the gateway whose members are listed. Mandatory. Binds from the
    pipeline by property name via the 'id' alias (e.g. from Get-FabricGateway output).

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricGatewayMember -GatewayId "12345678-1234-1234-1234-123456789012"

    Lists the member gateways of the specified gateway cluster.

.OUTPUTS
    System.Object
    Member object(s) with all API-returned properties (id, displayName, publicKey, version,
    enabled) plus the owning GatewayId / GatewayName when enriched.

.NOTES
    - API Endpoint: GET /gateways/{gatewayId}/members
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricGatewayMember {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId -Subresource 'members'
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No members found for gateway '$GatewayId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            $gatewayName = $GatewayId
            try { $gatewayName = Resolve-FabricGatewayName -GatewayId $GatewayId }
            catch {
                Write-FabricLog -Message "Failed to resolve gateway name for ID '$GatewayId': $($_.Exception.Message)" -Level Debug
            }

            foreach ($member in $response) {
                $member | Add-Member -NotePropertyName 'GatewayId'   -NotePropertyValue $GatewayId   -Force
                $member | Add-Member -NotePropertyName 'GatewayName' -NotePropertyValue $gatewayName -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.GatewayMember'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve members for gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
