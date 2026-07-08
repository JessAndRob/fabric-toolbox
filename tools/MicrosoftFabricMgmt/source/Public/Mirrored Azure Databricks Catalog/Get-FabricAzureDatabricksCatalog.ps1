<#
.SYNOPSIS
    Lists the Azure Databricks catalogs discoverable from a Fabric workspace.

.DESCRIPTION
    The Get-FabricAzureDatabricksCatalog function retrieves the Azure Databricks Unity Catalog
    catalogs reachable through a Databricks workspace connection via
    `GET /workspaces/{workspaceId}/azuredatabricks/catalogs`. Results are auto-paginated.

    By default each catalog is enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory.

.PARAMETER DatabricksWorkspaceConnectionId
    The unique identifier of the Databricks workspace connection to enumerate catalogs through.
    Mandatory.

.PARAMETER MaxResults
    Optional maximum number of results to return per page.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricAzureDatabricksCatalog -WorkspaceId $ws -DatabricksWorkspaceConnectionId $conn

    Lists the Databricks catalogs reachable through the connection.

.OUTPUTS
    System.Object
    Catalog object(s) with all API-returned properties (name, catalogType, storageLocation,
    fullName) plus a resolved WorkspaceName when enriched.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/azuredatabricks/catalogs
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricAzureDatabricksCatalog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

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

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'azuredatabricks', 'catalogs') -QueryParameters $queryParams
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No Databricks catalogs found for workspace '$WorkspaceId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            $workspaceName = $WorkspaceId
            try { $workspaceName = Resolve-FabricWorkspaceName -WorkspaceId $WorkspaceId }
            catch { $workspaceName = $WorkspaceId }

            foreach ($catalog in $response) {
                $catalog | Add-Member -NotePropertyName 'workspaceId'   -NotePropertyValue $WorkspaceId   -Force
                $catalog | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.DatabricksCatalog'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve Databricks catalogs for workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
        }
    }
}
