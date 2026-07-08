<#
.SYNOPSIS
    Removes an external library from a Fabric environment's staging libraries.

.DESCRIPTION
    The Remove-FabricEnvironmentStagingExternalLibrary function removes a named external (PyPI/Conda)
    library from an environment's staging libraries via
    `POST /workspaces/{workspaceId}/environments/{environmentId}/staging/libraries/removeExternalLibrary`.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the environment. Mandatory.

.PARAMETER EnvironmentId
    The unique identifier of the environment. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Name
    The name of the external library to remove. Mandatory.

.PARAMETER Version
    The version of the external library to remove. Mandatory.

.EXAMPLE
    Remove-FabricEnvironmentStagingExternalLibrary -WorkspaceId $ws -EnvironmentId $env -Name 'numpy' -Version '1.26.0'

    Removes numpy 1.26.0 from the environment's staging libraries.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/environments/{environmentId}/staging/libraries/removeExternalLibrary
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricEnvironmentStagingExternalLibrary {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$EnvironmentId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Version
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'environments', $EnvironmentId, 'staging', 'libraries', 'removeExternalLibrary')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                name    = $Name
                version = $Version
            }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("External library '$Name' ($Version) on environment '$EnvironmentId'", "Remove")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "External library '$Name' ($Version) removed from environment '$EnvironmentId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove external library '$Name' from environment '$EnvironmentId'. Error: $errorDetails" -Level Error
        }
    }
}
