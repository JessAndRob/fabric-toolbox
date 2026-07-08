<#
.SYNOPSIS
    Imports an external library specification file into a Fabric environment's staging libraries.

.DESCRIPTION
    The Import-FabricEnvironmentStagingExternalLibrary function uploads an external library
    specification file (e.g. a requirements.txt or environment.yml) to an environment's staging
    libraries via
    `POST /workspaces/{workspaceId}/environments/{environmentId}/staging/libraries/importExternalLibraries`.
    The file is sent as an application/octet-stream body.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the environment. Mandatory.

.PARAMETER EnvironmentId
    The unique identifier of the environment. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER FilePath
    The path to the external library specification file to upload. Mandatory. The file must exist.

.EXAMPLE
    Import-FabricEnvironmentStagingExternalLibrary -WorkspaceId $ws -EnvironmentId $env -FilePath .\requirements.txt

    Uploads requirements.txt as the environment's staging external libraries.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/environments/{environmentId}/staging/libraries/importExternalLibraries
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Import-FabricEnvironmentStagingExternalLibrary {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$FilePath
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'environments', $EnvironmentId, 'staging', 'libraries', 'importExternalLibraries')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            # The file is uploaded verbatim as an octet-stream body.
            $fileContent = Get-Content -Path $FilePath -Raw

            $apiParams = @{
                BaseURI     = $apiEndpointURI
                Headers     = $script:FabricAuthContext.FabricHeaders
                Method      = 'Post'
                Body        = $fileContent
                ContentType = 'application/octet-stream'
            }

            if ($PSCmdlet.ShouldProcess("Environment '$EnvironmentId'", "Import external libraries from '$FilePath'")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "External libraries imported into environment '$EnvironmentId' from '$FilePath'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to import external libraries into environment '$EnvironmentId'. Error: $errorDetails" -Level Error
        }
    }
}
