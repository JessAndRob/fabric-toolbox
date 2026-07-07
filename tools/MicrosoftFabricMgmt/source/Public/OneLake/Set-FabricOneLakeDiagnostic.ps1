<#
.SYNOPSIS
    Enables or disables OneLake diagnostic settings for a Fabric workspace.

.DESCRIPTION
    The Set-FabricOneLakeDiagnostic function modifies the workspace OneLake diagnostic settings via
    `POST /workspaces/{workspaceId}/onelake/settings/modifyDiagnostics`. When enabling diagnostics,
    supply a -Destination describing where the logs are stored; when disabling, the destination is
    not required.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Status
    The diagnostics status to set: Enabled or Disabled. Mandatory.

.PARAMETER Destination
    A hashtable describing the destination where OneLake diagnostic logs are stored. Required when
    enabling diagnostics; ignored when disabling.

.EXAMPLE
    Set-FabricOneLakeDiagnostic -WorkspaceId $ws -Status Disabled

    Disables OneLake diagnostics for the workspace.

.EXAMPLE
    Set-FabricOneLakeDiagnostic -WorkspaceId $ws -Status Enabled -Destination $dest

    Enables OneLake diagnostics, routing logs to the supplied destination.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/onelake/settings/modifyDiagnostics
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Set-FabricOneLakeDiagnostic {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Enabled', 'Disabled')]
        [string]$Status,

        [Parameter()]
        [hashtable]$Destination
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'onelake', 'settings', 'modifyDiagnostics')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ status = $Status }
            if ($Destination) { $body.destination = $Destination }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Workspace '$WorkspaceId'", "Set OneLake diagnostics to '$Status'")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "OneLake diagnostics for workspace '$WorkspaceId' set to '$Status'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to modify OneLake diagnostics for workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
        }
    }
}
