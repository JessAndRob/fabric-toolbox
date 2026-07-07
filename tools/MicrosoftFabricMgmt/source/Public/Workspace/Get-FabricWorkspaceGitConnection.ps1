<#
.SYNOPSIS
    Retrieves the Git connection details for a Fabric workspace.

.DESCRIPTION
    The Get-FabricWorkspaceGitConnection function returns the Git integration connection for a single
    workspace via `GET /workspaces/{workspaceId}/git/connection`. The response includes the Git
    provider details, sync details, and the current connection state.

    By default the result is enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

    Note: for a tenant-wide, admin-level listing of every workspace's Git connection, use
    Get-FabricAdminGitConnection instead (that calls the admin discovery endpoint).

.PARAMETER WorkspaceId
    The unique identifier of the workspace whose Git connection is retrieved. Mandatory. Binds from
    the pipeline via the 'id' alias.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricWorkspaceGitConnection -WorkspaceId "workspace123"

    Returns the Git connection details for the specified workspace.

.EXAMPLE
    Get-FabricWorkspace -WorkspaceName 'Analytics' | Get-FabricWorkspaceGitConnection

    Returns the Git connection for the 'Analytics' workspace (WorkspaceId binds from the pipeline).

.OUTPUTS
    System.Object
    The workspace Git connection object (gitProviderDetails, gitSyncDetails, gitConnectionState)
    plus a resolved WorkspaceName when enriched.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/git/connection
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricWorkspaceGitConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WorkspaceId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'git', 'connection')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No Git connection found for workspace '$WorkspaceId'." -Level Warning
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

            foreach ($connection in $response) {
                $connection | Add-Member -NotePropertyName 'workspaceId'   -NotePropertyValue $WorkspaceId   -Force
                $connection | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.WorkspaceGitConnection'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve Git connection for workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
        }
    }
}
