<#
.SYNOPSIS
    Lists the external data shares created for a Fabric item, or retrieves one by id.

.DESCRIPTION
    The Get-FabricItemExternalDataShare function retrieves the provider-side external data shares of
    an item via `GET /workspaces/{workspaceId}/items/{itemId}/externalDataShares`, or a single share
    via `GET /workspaces/{workspaceId}/items/{itemId}/externalDataShares/{externalDataShareId}` when
    -ExternalDataShareId is supplied. Results are auto-paginated.

    By default each share is enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

    Note: for a tenant-wide, admin-level listing use Get-FabricExternalDataShare (admin surface).

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item whose external data shares are listed. Mandatory. Binds from
    the pipeline via the 'id' alias.

.PARAMETER ExternalDataShareId
    The unique identifier of a single external data share to retrieve. When omitted, all shares are
    listed.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricItemExternalDataShare -WorkspaceId $ws -ItemId $item

    Lists all external data shares created for the item.

.EXAMPLE
    Get-FabricItemExternalDataShare -WorkspaceId $ws -ItemId $item -ExternalDataShareId $share

    Retrieves the single external data share with the specified id.

.OUTPUTS
    System.Object
    External data share object(s) with all API-returned properties (id, paths, creatorPrincipal,
    recipient, status, expirationTimeUtc, workspaceId, itemId, invitationUrl, acceptedByTenantId)
    plus a resolved WorkspaceName when enriched.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/items/{itemId}/externalDataShares (+ /{externalDataShareId})
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricItemExternalDataShare {
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
        [string]$ExternalDataShareId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = if ($ExternalDataShareId) {
                New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'externalDataShares', $ExternalDataShareId)
            }
            else {
                New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'externalDataShares')
            }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No external data shares found for item '$ItemId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            $workspaceName = $WorkspaceId
            try { $workspaceName = Resolve-FabricWorkspaceName -WorkspaceId $WorkspaceId }
            catch {
                Write-FabricLog -Message "Failed to resolve workspace name for ID '$WorkspaceId': $($_.Exception.Message)" -Level Debug
            }

            foreach ($share in $response) {
                $share | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.ExternalDataShare'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve external data shares for item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
