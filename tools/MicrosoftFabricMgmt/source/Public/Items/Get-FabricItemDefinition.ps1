<#
.SYNOPSIS
    Retrieves the definition of a Fabric item.

.DESCRIPTION
    The Get-FabricItemDefinition function retrieves an item's definition via
    `POST /workspaces/{workspaceId}/items/{itemId}/getDefinition`. This is the generic definition
    getter that works for any item type that supports definitions. The call is long-running; the
    module transparently waits for and returns the completed definition.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item whose definition is retrieved. Mandatory. Binds from the
    pipeline via the 'id' alias.

.PARAMETER Format
    Optional definition format to request (item-type specific, e.g. 'ipynb' for notebooks).

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Get-FabricItemDefinition -WorkspaceId $ws -ItemId $id

    Retrieves the definition of the item in the default format.

.EXAMPLE
    Get-FabricItemDefinition -WorkspaceId $ws -ItemId $id -Format ipynb

    Retrieves the notebook definition in ipynb format.

.OUTPUTS
    System.Object
    The item definition (format plus base64-encoded parts).

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/items/{itemId}/getDefinition
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricItemDefinition {
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
        [ValidateNotNullOrEmpty()]
        [string]$Format,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'getDefinition')
            if ($Format) {
                $apiEndpointURI = "{0}?format={1}" -f $apiEndpointURI, $Format
            }
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

            Write-FabricLog -Message "Definition for item '$ItemId' retrieved successfully." -Level Debug
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve definition for item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
