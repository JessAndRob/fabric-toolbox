<#
.SYNOPSIS
    Retrieves the definition of a Fabric environment.

.DESCRIPTION
    The Get-FabricEnvironmentDefinition function retrieves an environment's definition via
    `POST /workspaces/{workspaceId}/environments/{environmentId}/getDefinition`. The call is
    long-running; the module transparently waits for and returns the completed definition.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the environment. Mandatory.

.PARAMETER EnvironmentId
    The unique identifier of the environment whose definition is retrieved. Mandatory. Binds from
    the pipeline via the 'id' alias.

.PARAMETER Format
    Optional definition format to request.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Get-FabricEnvironmentDefinition -WorkspaceId $ws -EnvironmentId $env

    Retrieves the environment definition.

.OUTPUTS
    System.Object
    The environment definition (format plus base64-encoded parts).

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/environments/{environmentId}/getDefinition
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricEnvironmentDefinition {
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
        [ValidateNotNullOrEmpty()]
        [string]$Format,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $queryParams = if ($Format) { @{ format = $Format } } else { $null }
            $apiEndpointURI = New-FabricAPIUri -Resource 'workspaces' -WorkspaceId $WorkspaceId -Subresource "environments/$EnvironmentId/getDefinition" -QueryParameters $queryParams
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if ($Raw) {
                return $response
            }

            Write-FabricLog -Message "Definition for environment '$EnvironmentId' retrieved successfully." -Level Debug
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve definition for environment '$EnvironmentId'. Error: $errorDetails" -Level Error
        }
    }
}
