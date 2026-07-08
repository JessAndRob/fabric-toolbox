<#
.SYNOPSIS
    Retrieves the Apache Airflow workspace settings. (Preview)

.DESCRIPTION
    The Get-FabricApacheAirflowSetting function retrieves the workspace-level Apache Airflow settings
    via `GET /workspaces/{workspaceId}/apacheAirflowJobs/settings`, including the default pool
    template. This is a preview (beta) API.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Get-FabricApacheAirflowSetting -WorkspaceId $ws

    Returns the workspace's Apache Airflow settings.

.OUTPUTS
    System.Object
    The Apache Airflow workspace settings object (defaultPoolTemplateId).

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/apacheAirflowJobs/settings (preview)
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricApacheAirflowSetting {
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

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'apacheAirflowJobs', 'settings') -QueryParameters @{ beta = 'true' }
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

            Write-FabricLog -Message "Apache Airflow settings retrieved for workspace '$WorkspaceId'." -Level Debug
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve Apache Airflow settings for workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
        }
    }
}
