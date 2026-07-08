<#
.SYNOPSIS
    Lists the tables of an Azure Databricks schema discoverable from a Fabric workspace.

.DESCRIPTION
    The Get-FabricAzureDatabricksTable function retrieves the tables of an Azure Databricks Unity
    Catalog schema via
    `GET /workspaces/{workspaceId}/azuredatabricks/catalogs/{catalogName}/schemas/{schemaName}/tables`.
    Results are auto-paginated.

    By default each table is enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory.

.PARAMETER CatalogName
    The name of the Databricks catalog. Mandatory.

.PARAMETER SchemaName
    The name of the schema whose tables are listed. Mandatory.

.PARAMETER DatabricksWorkspaceConnectionId
    The unique identifier of the Databricks workspace connection. Mandatory.

.PARAMETER MaxResults
    Optional maximum number of results to return per page.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricAzureDatabricksTable -WorkspaceId $ws -CatalogName 'main' -SchemaName 'sales' -DatabricksWorkspaceConnectionId $conn

    Lists the tables in the 'main.sales' schema.

.OUTPUTS
    System.Object
    Table object(s) with all API-returned properties (name, storageLocation, fullName, tableType,
    dataSourceFormat) plus a resolved WorkspaceName when enriched.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/azuredatabricks/catalogs/{catalogName}/schemas/{schemaName}/tables
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricAzureDatabricksTable {
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
        [string]$SchemaName,

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

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'azuredatabricks', 'catalogs', $CatalogName, 'schemas', $SchemaName, 'tables') -QueryParameters $queryParams
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No tables found for schema '$SchemaName' in catalog '$CatalogName'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            $workspaceName = $WorkspaceId
            try { $workspaceName = Resolve-FabricWorkspaceName -WorkspaceId $WorkspaceId }
            catch { $workspaceName = $WorkspaceId }

            foreach ($table in $response) {
                $table | Add-Member -NotePropertyName 'workspaceId'   -NotePropertyValue $WorkspaceId   -Force
                $table | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force
                $table | Add-Member -NotePropertyName 'CatalogName'   -NotePropertyValue $CatalogName   -Force
                $table | Add-Member -NotePropertyName 'SchemaName'    -NotePropertyValue $SchemaName    -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.DatabricksTable'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve tables for schema '$SchemaName'. Error: $errorDetails" -Level Error
        }
    }
}
