<#
.SYNOPSIS
    Removes one or more tags from a Fabric item.

.DESCRIPTION
    The Remove-FabricItemTag function unapplies tags from an item via
    `POST /workspaces/{workspaceId}/items/{itemId}/unapplyTags`. Tags are referenced by their tag ids
    (see Get-FabricTag).

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item to untag. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER TagId
    One or more tag identifiers to remove. Mandatory. Accepts an array.

.EXAMPLE
    Remove-FabricItemTag -WorkspaceId $ws -ItemId $id -TagId $tag1

    Removes the tag from the item.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/items/{itemId}/unapplyTags
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricItemTag {
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
        [string[]]$TagId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'unapplyTags')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                tags = @($TagId | ForEach-Object { @{ id = $_ } })
            }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Item '$ItemId'", "Unapply $($TagId.Count) tag(s)")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Removed $($TagId.Count) tag(s) from item '$ItemId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove tags from item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
