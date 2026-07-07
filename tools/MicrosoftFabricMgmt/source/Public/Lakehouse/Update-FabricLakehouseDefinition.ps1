<#
.SYNOPSIS
    Updates the definition of a Fabric lakehouse.

.DESCRIPTION
    The Update-FabricLakehouseDefinition function replaces a lakehouse's definition via
    `POST /workspaces/{workspaceId}/lakehouses/{lakehouseId}/updateDefinition`. The call is
    long-running; the module transparently waits for completion.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the lakehouse. Mandatory.

.PARAMETER LakehouseId
    The unique identifier of the lakehouse to update. Mandatory. Binds from the pipeline via the
    'id' alias.

.PARAMETER Definition
    The lakehouse definition hashtable to apply, with an optional 'format' and a 'parts' array of
    @{ path; payload; payloadType }. Mandatory.

.PARAMETER UpdateMetadata
    If specified, instructs Fabric to also update item metadata from the supplied definition.

.EXAMPLE
    $def = @{ parts = @(@{ path = 'lakehouse.metadata.json'; payload = $b64; payloadType = 'InlineBase64' }) }
    Update-FabricLakehouseDefinition -WorkspaceId $ws -LakehouseId $lh -Definition $def

    Replaces the lakehouse definition with the supplied parts.

.OUTPUTS
    System.Object
    The API response (or completed long-running operation result).

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/lakehouses/{lakehouseId}/updateDefinition
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricLakehouseDefinition {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$LakehouseId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Definition,

        [Parameter()]
        [switch]$UpdateMetadata
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $queryParams = if ($UpdateMetadata) { @{ updateMetadata = 'true' } } else { $null }
            $apiEndpointURI = New-FabricAPIUri -Resource 'workspaces' -WorkspaceId $WorkspaceId -Subresource "lakehouses/$LakehouseId/updateDefinition" -QueryParameters $queryParams
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ definition = $Definition }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Lakehouse '$LakehouseId'", "Update lakehouse definition")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Definition for lakehouse '$LakehouseId' updated successfully." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update definition for lakehouse '$LakehouseId'. Error: $errorDetails" -Level Error
        }
    }
}
