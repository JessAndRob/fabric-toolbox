<#
.SYNOPSIS
    Retrieves the definition of a Fabric lakehouse.

.DESCRIPTION
    The Get-FabricLakehouseDefinition function retrieves a lakehouse's definition via
    `POST /workspaces/{workspaceId}/lakehouses/{lakehouseId}/getDefinition`. The call is
    long-running; the module transparently waits for and returns the completed definition.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the lakehouse. Mandatory.

.PARAMETER LakehouseId
    The unique identifier of the lakehouse whose definition is retrieved. Mandatory. Binds from the
    pipeline via the 'id' alias.

.PARAMETER Format
    Optional definition format to request.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Get-FabricLakehouseDefinition -WorkspaceId $ws -LakehouseId $lh

    Retrieves the lakehouse definition.

.OUTPUTS
    System.Object
    The lakehouse definition (format plus base64-encoded parts).

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/lakehouses/{lakehouseId}/getDefinition
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricLakehouseDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$LakehouseId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Format,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $queryParams = if ($Format) { @{ format = $Format } } else { $null }
            $apiEndpointURI = New-FabricAPIUri -Resource 'workspaces' -WorkspaceId $WorkspaceId -Subresource "lakehouses/$LakehouseId/getDefinition" -QueryParameters $queryParams
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if ($Raw) {
                return $response
            }

            Write-FabricLog -Message "Definition for lakehouse '$LakehouseId' retrieved successfully." -Level Debug
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve definition for lakehouse '$LakehouseId'. Error: $errorDetails" -Level Error
        }
    }
}
