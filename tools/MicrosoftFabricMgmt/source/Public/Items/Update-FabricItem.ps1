<#
.SYNOPSIS
    Updates the display name and/or description of a Fabric item.

.DESCRIPTION
    The Update-FabricItem function updates an item's metadata via
    `PATCH /workspaces/{workspaceId}/items/{itemId}`. Only the supplied properties are sent. This is
    the generic updater that works for any item type.

    The updated item is returned enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item to update. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER DisplayName
    The new display name for the item.

.PARAMETER Description
    The new description for the item.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Update-FabricItem -WorkspaceId $ws -ItemId $id -DisplayName 'Renamed'

    Renames the item.

.EXAMPLE
    Get-FabricItem -WorkspaceId $ws | Where-Object displayName -eq 'Old' | Update-FabricItem -WorkspaceId $ws -Description 'Updated'

    Updates the description of the matching item.

.OUTPUTS
    System.Object
    The updated item object with all API-returned properties plus a resolved WorkspaceName.

.NOTES
    - API Endpoint: PATCH /workspaces/{workspaceId}/items/{itemId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricItem {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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
        [string]$DisplayName,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId)
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{}
            if ($PSBoundParameters.ContainsKey('DisplayName')) { $body.displayName = $DisplayName }
            if ($PSBoundParameters.ContainsKey('Description')) { $body.description = $Description }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Patch'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Item '$ItemId'", "Update item")) {
                $response = Invoke-FabricAPIRequest @apiParams

                if (-not $response) {
                    Write-FabricLog -Message "No response returned after updating item '$ItemId'." -Level Warning
                    return $null
                }

                if ($Raw) {
                    return $response
                }

                $workspaceName = $WorkspaceId
                try { $workspaceName = Resolve-FabricWorkspaceName -WorkspaceId $WorkspaceId }
                catch { $workspaceName = $WorkspaceId }
                $response | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force

                $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.Item'
                Write-FabricLog -Message "Item '$ItemId' updated successfully!" -Level Host
                return $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
