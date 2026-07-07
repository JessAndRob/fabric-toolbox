<#
.SYNOPSIS
    Lists the connections used by a Microsoft Fabric item.

.DESCRIPTION
    The Get-FabricItemConnection function retrieves the connections that a specific Fabric item
    depends on, via GET to `/workspaces/{workspaceId}/items/{itemId}/connections`. The results are
    auto-paginated.

    By default each returned connection is enriched with the originating WorkspaceId (stamped from
    the parameter), a resolved WorkspaceName, a resolved GatewayName (when the connection is bound
    to a gateway), and decorated for the custom table view. Pass -Raw to return the untouched API
    response.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item whose connections are listed. Mandatory.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricItemConnection -WorkspaceId "12345678-1234-1234-1234-123456789012" -ItemId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

    Lists all connections used by the item, enriched with WorkspaceName and GatewayName.

.EXAMPLE
    Get-FabricDataPipeline -WorkspaceId $ws | Get-FabricItemConnection -WorkspaceId $ws

    Lists the connections each data pipeline in the workspace depends on (ItemId binds from the pipeline's id).

.OUTPUTS
    System.Object
    Connection object(s) with all API-returned properties (id, displayName, gatewayId,
    connectivityType, connectionDetails) plus WorkspaceName / GatewayName when enriched.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/items/{itemId}/connections
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricItemConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ItemId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'connections')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No connections returned for item '$ItemId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            # Resolve the workspace display name once for all returned connections.
            $workspaceName = $WorkspaceId
            try {
                $workspaceName = Resolve-FabricWorkspaceName -WorkspaceId $WorkspaceId
            }
            catch {
                Write-FabricLog -Message "Failed to resolve workspace name for ID '$WorkspaceId': $($_.Exception.Message)" -Level Debug
            }

            foreach ($connection in $response) {
                $connection | Add-Member -NotePropertyName 'workspaceId'   -NotePropertyValue $WorkspaceId   -Force
                $connection | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force

                # Resolve the gateway name when the connection is bound to a gateway.
                if ($connection.gatewayId) {
                    $gatewayName = $connection.gatewayId
                    try { $gatewayName = Resolve-FabricGatewayName -GatewayId $connection.gatewayId }
                    catch {
                        Write-FabricLog -Message "Failed to resolve gateway name for ID '$($connection.gatewayId)': $($_.Exception.Message)" -Level Debug
                    }
                    $connection | Add-Member -NotePropertyName 'GatewayName' -NotePropertyValue $gatewayName -Force
                }
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.Connection'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve connections for item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
