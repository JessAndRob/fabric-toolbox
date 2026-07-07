<#
.SYNOPSIS
    Applies one or more tags to a Fabric item.

.DESCRIPTION
    The Add-FabricItemTag function applies tags to an item via
    `POST /workspaces/{workspaceId}/items/{itemId}/applyTags`. Tags are referenced by their tag ids
    (see Get-FabricTag).

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item to tag. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER TagId
    One or more tag identifiers to apply. Mandatory. Accepts an array.

.EXAMPLE
    Add-FabricItemTag -WorkspaceId $ws -ItemId $id -TagId $tag1, $tag2

    Applies both tags to the item.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/items/{itemId}/applyTags
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Add-FabricItemTag {
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

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'applyTags')
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

            if ($PSCmdlet.ShouldProcess("Item '$ItemId'", "Apply $($TagId.Count) tag(s)")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Applied $($TagId.Count) tag(s) to item '$ItemId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to apply tags to item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
