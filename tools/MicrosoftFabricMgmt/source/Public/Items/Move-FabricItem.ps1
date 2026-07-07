<#
.SYNOPSIS
    Moves a Fabric item into a workspace folder.

.DESCRIPTION
    The Move-FabricItem function moves an item to a target folder via
    `POST /workspaces/{workspaceId}/items/{itemId}/move`. Omit -TargetFolderId (or pass an empty
    string) to move the item to the workspace root.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item to move. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER TargetFolderId
    The unique identifier of the destination folder. When omitted, the item moves to the workspace root.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Move-FabricItem -WorkspaceId $ws -ItemId $id -TargetFolderId $folder

    Moves the item into the specified folder.

.EXAMPLE
    Move-FabricItem -WorkspaceId $ws -ItemId $id

    Moves the item to the workspace root.

.OUTPUTS
    System.Object
    The moved item object with all API-returned properties plus a resolved WorkspaceName.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/items/{itemId}/move
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Move-FabricItem {
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
        [string]$TargetFolderId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'move')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{}
            if ($PSBoundParameters.ContainsKey('TargetFolderId')) { $body.targetFolderId = $TargetFolderId }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Item '$ItemId'", "Move item")) {
                $response = Invoke-FabricAPIRequest @apiParams

                if (-not $response) {
                    Write-FabricLog -Message "No response returned after moving item '$ItemId'." -Level Warning
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
                Write-FabricLog -Message "Item '$ItemId' moved successfully." -Level Host
                return $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to move item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
