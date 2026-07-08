<#
.SYNOPSIS
    Lists the Apache Airflow pool templates in a Fabric workspace, or retrieves one by id. (Preview)

.DESCRIPTION
    The Get-FabricApacheAirflowPoolTemplate function lists the Apache Airflow pool templates via
    `GET /workspaces/{workspaceId}/apacheAirflowJobs/poolTemplates`, or retrieves a single template
    via `GET .../poolTemplates/{poolTemplateId}` when -PoolTemplateId is supplied. This is a preview
    (beta) API.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER PoolTemplateId
    The unique identifier of a single pool template to retrieve. When omitted, all templates are listed.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Get-FabricApacheAirflowPoolTemplate -WorkspaceId $ws

    Lists all Apache Airflow pool templates in the workspace.

.EXAMPLE
    Get-FabricApacheAirflowPoolTemplate -WorkspaceId $ws -PoolTemplateId $pt

    Retrieves the specified pool template.

.OUTPUTS
    System.Object
    Pool template object(s) with all API-returned properties (id, name, nodeSize, shutdownPolicy,
    computeScalability, apacheAirflowJobVersion).

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/apacheAirflowJobs/poolTemplates (+ /{poolTemplateId}) (preview)
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricApacheAirflowPoolTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WorkspaceId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$PoolTemplateId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $segments = @('workspaces', $WorkspaceId, 'apacheAirflowJobs', 'poolTemplates')
            if ($PoolTemplateId) { $segments += $PoolTemplateId }
            $apiEndpointURI = New-FabricAPIUri -Segments $segments -QueryParameters @{ beta = 'true' }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No Apache Airflow pool templates found for workspace '$WorkspaceId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.AirflowPoolTemplate'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve Apache Airflow pool templates for workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
        }
    }
}
