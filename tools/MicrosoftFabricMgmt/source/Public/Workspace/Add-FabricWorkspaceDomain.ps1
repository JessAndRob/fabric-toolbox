<#
.SYNOPSIS
    Assigns a Fabric workspace to a domain.

.DESCRIPTION
    The Add-FabricWorkspaceDomain function assigns a workspace to a domain via
    `POST /workspaces/{workspaceId}/assignToDomain`. This is the workspace-side assignment (a
    workspace admin assigns their own workspace); for the domain-side bulk assignment used by
    Fabric administrators, see Add-FabricDomainWorkspaceById.

.PARAMETER WorkspaceId
    The unique identifier of the workspace to assign. Mandatory. Binds from the pipeline via the
    'id' alias.

.PARAMETER DomainId
    The unique identifier of the domain to assign the workspace to. Mandatory.

.EXAMPLE
    Add-FabricWorkspaceDomain -WorkspaceId $ws -DomainId $domain

    Assigns the workspace to the domain.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/assignToDomain
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Add-FabricWorkspaceDomain {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'assignToDomain')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ domainId = $DomainId }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Workspace '$WorkspaceId'", "Assign to domain '$DomainId'")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Workspace '$WorkspaceId' assigned to domain '$DomainId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to assign workspace '$WorkspaceId' to domain. Error: $errorDetails" -Level Error
        }
    }
}
