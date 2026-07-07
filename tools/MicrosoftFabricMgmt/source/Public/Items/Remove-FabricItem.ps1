<#
.SYNOPSIS
    Removes a Fabric item from a workspace.

.DESCRIPTION
    The Remove-FabricItem function deletes an item via
    `DELETE /workspaces/{workspaceId}/items/{itemId}`. This is the generic remover that works for
    any item type.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item to remove. Mandatory. Binds from the pipeline via the 'id' alias.

.EXAMPLE
    Remove-FabricItem -WorkspaceId $ws -ItemId $id

    Deletes the specified item.

.EXAMPLE
    Get-FabricItem -WorkspaceId $ws | Where-Object type -eq 'Report' | Remove-FabricItem -WorkspaceId $ws -Confirm:$false

    Deletes every report in the workspace.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE /workspaces/{workspaceId}/items/{itemId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricItem {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ItemId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId)
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("Item '$ItemId' in workspace '$WorkspaceId'", "Delete")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Item '$ItemId' removed successfully from workspace '$WorkspaceId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
