<#
.SYNOPSIS
    Updates the definition of a Fabric item.

.DESCRIPTION
    The Update-FabricItemDefinition function replaces an item's definition via
    `POST /workspaces/{workspaceId}/items/{itemId}/updateDefinition`. This is the generic definition
    updater that works for any item type that supports definitions. The call is long-running; the
    module transparently waits for completion.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item to update. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Definition
    The item definition hashtable to apply, with 'format' (optional) and 'parts' (array of
    @{ path; payload; payloadType }). Mandatory.

.PARAMETER UpdateMetadata
    If specified, instructs Fabric to also update item metadata (e.g. the .platform part) from the
    supplied definition.

.EXAMPLE
    $def = @{ parts = @(@{ path = 'notebook-content.py'; payload = $b64; payloadType = 'InlineBase64' }) }
    Update-FabricItemDefinition -WorkspaceId $ws -ItemId $id -Definition $def

    Replaces the item's definition with the supplied parts.

.OUTPUTS
    System.Object
    The API response (or completed long-running operation result).

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/items/{itemId}/updateDefinition
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricItemDefinition {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ItemId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Definition,

        [Parameter()]
        [switch]$UpdateMetadata
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'updateDefinition')
            if ($UpdateMetadata) {
                $apiEndpointURI = "{0}?updateMetadata=true" -f $apiEndpointURI
            }
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

            if ($PSCmdlet.ShouldProcess("Item '$ItemId'", "Update item definition")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Definition for item '$ItemId' updated successfully." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update definition for item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
