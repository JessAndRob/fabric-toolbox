<#
.SYNOPSIS
    Lists the connections used by a Microsoft Fabric item.

.DESCRIPTION
    The Get-FabricItemConnection function retrieves the connections that a specific Fabric item
    depends on, via GET to `/workspaces/{workspaceId}/items/{itemId}/connections`. The results are
    auto-paginated.

    By default each returned connection is enriched with the originating WorkspaceId (stamped from
    the parameter), a resolved WorkspaceName, a resolved GatewayName (when the connection is bound
    to a gateway), the owning item's name (ItemName) and type (ResourceType) when supplied, the
    parsed/flattened connectionDetails, and decorated for the custom table view. Pass -Raw to return
    the untouched API response.

    ItemName and ResourceType bind automatically from the pipeline (from the item's displayName /
    type), so a workspace -> item -> connection pipeline carries the item context onto every
    connection row.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory. Binds from the pipeline
    by property name (e.g. from Get-FabricItem output).

.PARAMETER ItemId
    The unique identifier of the item whose connections are listed. Mandatory. Binds from the
    pipeline by property name via the 'id' alias.

.PARAMETER ItemName
    Optional display name of the owning item. Binds from the pipeline by property name via the
    'displayName' alias (as emitted by Get-FabricItem). When supplied, each connection is stamped
    with an ItemName property.

.PARAMETER ItemType
    Optional type of the owning item (e.g. DataPipeline, Notebook). Binds from the pipeline by
    property name via the 'type' alias (as emitted by Get-FabricItem). When supplied, each
    connection is stamped with a ResourceType property.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricItemConnection -WorkspaceId "12345678-1234-1234-1234-123456789012" -ItemId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

    Lists all connections used by the item, enriched with WorkspaceName and GatewayName.

.EXAMPLE
    Get-FabricWorkspace -WorkspaceName 'Analytics' | Get-FabricItem | Get-FabricItemConnection

    Walks every item in the 'Analytics' workspace and lists the connections each one depends on.
    WorkspaceId and ItemId bind from the item's id/workspaceId, and each connection row carries the
    owning item's ItemName and ResourceType.

.EXAMPLE
    Get-FabricDataPipeline -WorkspaceId $ws | Get-FabricItemConnection -WorkspaceId $ws

    Lists the connections each data pipeline in the workspace depends on (ItemId binds from the pipeline's id).

.OUTPUTS
    System.Object
    Connection object(s) with all API-returned properties (id, displayName, gatewayId,
    connectivityType, connectionDetails) plus WorkspaceName / GatewayName / ItemName / ResourceType
    and the parsed/flattened connectionDetails when enriched.

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

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('displayName')]
        [string]$ItemName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('type')]
        [string]$ItemType,

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

                # Stamp the owning item's name and type when they were supplied (e.g. piped from Get-FabricItem).
                if ($PSBoundParameters.ContainsKey('ItemName') -and $ItemName) {
                    $connection | Add-Member -NotePropertyName 'ItemName' -NotePropertyValue $ItemName -Force
                }
                if ($PSBoundParameters.ContainsKey('ItemType') -and $ItemType) {
                    $connection | Add-Member -NotePropertyName 'ResourceType' -NotePropertyValue $ItemType -Force
                }

                # Resolve the gateway name when the connection is bound to a gateway.
                if ($connection.gatewayId) {
                    $gatewayName = $connection.gatewayId
                    try { $gatewayName = Resolve-FabricGatewayName -GatewayId $connection.gatewayId }
                    catch {
                        Write-FabricLog -Message "Failed to resolve gateway name for ID '$($connection.gatewayId)': $($_.Exception.Message)" -Level Debug
                    }
                    $connection | Add-Member -NotePropertyName 'GatewayName' -NotePropertyValue $gatewayName -Force
                }

                # Parse and flatten connectionDetails so the type-specific fields (Server, Database,
                # Path, Url, etc.) surface as first-class properties. The shape varies by connection
                # type, so reserved names are prefixed with 'Detail' to avoid clobbering.
                if ($connection.connectionDetails) {
                    $parsed = $null
                    try {
                        if ($connection.connectionDetails -is [string]) {
                            $parsed = $connection.connectionDetails | ConvertFrom-Json -ErrorAction Stop
                        }
                        else {
                            $parsed = $connection.connectionDetails
                        }
                    }
                    catch {
                        Write-FabricLog -Message "Failed to parse connectionDetails for connection '$($connection.id)': $($_.Exception.Message)" -Level Debug
                    }

                    if ($parsed) {
                        $connection | Add-Member -NotePropertyName 'ConnectionDetailsParsed' -NotePropertyValue $parsed -Force
                        $reserved = @(
                            'id', 'displayName', 'gatewayId', 'connectivityType', 'connectionDetails',
                            'workspaceId', 'WorkspaceName', 'GatewayName', 'ItemName', 'ResourceType',
                            'ConnectionDetailsParsed'
                        )
                        foreach ($detail in $parsed.PSObject.Properties) {
                            if ($null -eq $detail.Value) { continue }
                            $propName = $detail.Name.Substring(0, 1).ToUpperInvariant() + $detail.Name.Substring(1)
                            if ($propName -in $reserved) { $propName = 'Detail' + $propName }
                            $connection | Add-Member -NotePropertyName $propName -NotePropertyValue $detail.Value -Force
                        }
                    }
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
