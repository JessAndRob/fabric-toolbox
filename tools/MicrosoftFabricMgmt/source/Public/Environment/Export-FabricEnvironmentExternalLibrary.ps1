<#
.SYNOPSIS
    Exports the external library specification of a Fabric environment.

.DESCRIPTION
    The Export-FabricEnvironmentExternalLibrary function downloads the external library specification
    (e.g. the PyPI/Conda requirements) of an environment. By default it exports the published
    libraries via `GET /workspaces/{workspaceId}/environments/{environmentId}/libraries/exportExternalLibraries`;
    pass -Staging to export the staging libraries via
    `GET /workspaces/{workspaceId}/environments/{environmentId}/staging/libraries/exportExternalLibraries`.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the environment. Mandatory.

.PARAMETER EnvironmentId
    The unique identifier of the environment. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Staging
    If specified, exports the staging (pending) external libraries instead of the published ones.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Export-FabricEnvironmentExternalLibrary -WorkspaceId $ws -EnvironmentId $env

    Exports the published external library specification.

.EXAMPLE
    Export-FabricEnvironmentExternalLibrary -WorkspaceId $ws -EnvironmentId $env -Staging

    Exports the staging external library specification.

.OUTPUTS
    System.Object
    The exported external library specification.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/environments/{environmentId}/libraries/exportExternalLibraries
    - API Endpoint: GET /workspaces/{workspaceId}/environments/{environmentId}/staging/libraries/exportExternalLibraries
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Export-FabricEnvironmentExternalLibrary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$EnvironmentId,

        [Parameter()]
        [switch]$Staging,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = if ($Staging) {
                New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'environments', $EnvironmentId, 'staging', 'libraries', 'exportExternalLibraries')
            }
            else {
                New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'environments', $EnvironmentId, 'libraries', 'exportExternalLibraries')
            }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if ($Raw) {
                return $response
            }

            Write-FabricLog -Message "External libraries exported for environment '$EnvironmentId'." -Level Debug
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to export external libraries for environment '$EnvironmentId'. Error: $errorDetails" -Level Error
        }
    }
}
