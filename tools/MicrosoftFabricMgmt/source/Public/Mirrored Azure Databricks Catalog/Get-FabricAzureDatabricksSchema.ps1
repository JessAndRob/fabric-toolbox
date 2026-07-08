<#
.SYNOPSIS
    Lists the schemas of an Azure Databricks catalog discoverable from a Fabric workspace.

.DESCRIPTION
    The Get-FabricAzureDatabricksSchema function retrieves the schemas of an Azure Databricks Unity
    Catalog catalog via
    `GET /workspaces/{workspaceId}/azuredatabricks/catalogs/{catalogName}/schemas`. Results are
    auto-paginated.

    By default each schema is enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory.

.PARAMETER CatalogName
    The name of the Databricks catalog whose schemas are listed. Mandatory.

.PARAMETER DatabricksWorkspaceConnectionId
    The unique identifier of the Databricks workspace connection. Mandatory.

.PARAMETER MaxResults
    Optional maximum number of results to return per page.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricAzureDatabricksSchema -WorkspaceId $ws -CatalogName 'main' -DatabricksWorkspaceConnectionId $conn

    Lists the schemas in the 'main' catalog.

.OUTPUTS
    System.Object
    Schema object(s) with all API-returned properties (name, storageLocation, fullName) plus a
    resolved WorkspaceName when enriched.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/azuredatabricks/catalogs/{catalogName}/schemas
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricAzureDatabricksSchema {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CatalogName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DatabricksWorkspaceConnectionId,

        [Parameter()]
        [int]$MaxResults,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $queryParams = @{ databricksWorkspaceConnectionId = $DatabricksWorkspaceConnectionId }
            if ($PSBoundParameters.ContainsKey('MaxResults')) { $queryParams.maxResults = $MaxResults }

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'azuredatabricks', 'catalogs', $CatalogName, 'schemas') -QueryParameters $queryParams
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No schemas found for catalog '$CatalogName'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            $workspaceName = $WorkspaceId
            try { $workspaceName = Resolve-FabricWorkspaceName -WorkspaceId $WorkspaceId }
            catch { $workspaceName = $WorkspaceId }

            foreach ($schema in $response) {
                $schema | Add-Member -NotePropertyName 'workspaceId'   -NotePropertyValue $WorkspaceId   -Force
                $schema | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force
                $schema | Add-Member -NotePropertyName 'CatalogName'   -NotePropertyValue $CatalogName   -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.DatabricksSchema'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve schemas for catalog '$CatalogName'. Error: $errorDetails" -Level Error
        }
    }
}
