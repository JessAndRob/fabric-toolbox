<#
.SYNOPSIS
    Refreshes the catalog metadata of a mirrored Azure Databricks catalog.

.DESCRIPTION
    The Update-FabricMirroredAzureDatabricksCatalogMetadata function triggers a metadata refresh of a
    mirrored Azure Databricks catalog via
    `POST /workspaces/{workspaceId}/mirroredAzureDatabricksCatalogs/{mirroredAzureDatabricksCatalogId}/refreshCatalogMetadata`,
    re-syncing the mirrored catalog with its Databricks source. The call is long-running; the module
    transparently waits for completion.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the mirrored catalog. Mandatory.

.PARAMETER MirroredAzureDatabricksCatalogId
    The unique identifier of the mirrored Azure Databricks catalog to refresh. Mandatory. Binds from
    the pipeline via the 'id' alias.

.EXAMPLE
    Update-FabricMirroredAzureDatabricksCatalogMetadata -WorkspaceId $ws -MirroredAzureDatabricksCatalogId $cat

    Refreshes the mirrored catalog's metadata from its Databricks source.

.OUTPUTS
    System.Object
    The API response (or completed long-running operation result).

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/mirroredAzureDatabricksCatalogs/{mirroredAzureDatabricksCatalogId}/refreshCatalogMetadata
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricMirroredAzureDatabricksCatalogMetadata {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$MirroredAzureDatabricksCatalogId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'mirroredAzureDatabricksCatalogs', $MirroredAzureDatabricksCatalogId, 'refreshCatalogMetadata')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
            }

            if ($PSCmdlet.ShouldProcess("Mirrored catalog '$MirroredAzureDatabricksCatalogId'", "Refresh catalog metadata")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Metadata refresh triggered for mirrored catalog '$MirroredAzureDatabricksCatalogId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to refresh metadata for mirrored catalog '$MirroredAzureDatabricksCatalogId'. Error: $errorDetails" -Level Error
        }
    }
}
