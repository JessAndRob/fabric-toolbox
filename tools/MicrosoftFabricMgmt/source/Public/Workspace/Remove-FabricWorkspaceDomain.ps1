<#
.SYNOPSIS
    Unassigns a Fabric workspace from its domain.

.DESCRIPTION
    The Remove-FabricWorkspaceDomain function unassigns a workspace from the domain it is currently
    assigned to via `POST /workspaces/{workspaceId}/unassignFromDomain`. This is the workspace-side
    operation; for the domain-side bulk unassignment used by Fabric administrators, see
    Remove-FabricDomainWorkspace.

.PARAMETER WorkspaceId
    The unique identifier of the workspace to unassign. Mandatory. Binds from the pipeline via the
    'id' alias.

.EXAMPLE
    Remove-FabricWorkspaceDomain -WorkspaceId $ws

    Unassigns the workspace from its domain.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/unassignFromDomain
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricWorkspaceDomain {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WorkspaceId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'unassignFromDomain')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("Workspace '$WorkspaceId'", "Unassign from domain")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Post'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Workspace '$WorkspaceId' unassigned from its domain." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to unassign workspace '$WorkspaceId' from domain. Error: $errorDetails" -Level Error
        }
    }
}
