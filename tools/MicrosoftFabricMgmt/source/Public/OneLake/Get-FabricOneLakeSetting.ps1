<#
.SYNOPSIS
    Retrieves the OneLake settings for a Fabric workspace.

.DESCRIPTION
    The Get-FabricOneLakeSetting function returns the workspace-level OneLake settings via
    `GET /workspaces/{workspaceId}/onelake/settings`, including the diagnostic settings, any
    immutability policies, and lifecycle configuration.

    By default the result is enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER WorkspaceId
    The unique identifier of the workspace whose OneLake settings are retrieved. Mandatory. Binds
    from the pipeline via the 'id' alias.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricOneLakeSetting -WorkspaceId "workspace123"

    Returns the OneLake settings for the specified workspace.

.OUTPUTS
    System.Object
    The OneLake settings object (diagnostics, immutabilityPolicies, lifecycle) plus a resolved
    WorkspaceName when enriched.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/onelake/settings
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricOneLakeSetting {
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

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'onelake', 'settings')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No OneLake settings found for workspace '$WorkspaceId'." -Level Warning
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

            foreach ($setting in $response) {
                $setting | Add-Member -NotePropertyName 'workspaceId'   -NotePropertyValue $WorkspaceId   -Force
                $setting | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.OneLakeSetting'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve OneLake settings for workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
        }
    }
}
