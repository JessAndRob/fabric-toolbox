<#
.SYNOPSIS
    Updates the Apache Airflow workspace settings. (Preview)

.DESCRIPTION
    The Update-FabricApacheAirflowSetting function updates the workspace-level Apache Airflow settings
    via `PATCH /workspaces/{workspaceId}/apacheAirflowJobs/settings`. This is a preview (beta) API.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER DefaultPoolTemplateId
    The unique identifier of the pool template to set as the workspace default. Mandatory.

.EXAMPLE
    Update-FabricApacheAirflowSetting -WorkspaceId $ws -DefaultPoolTemplateId $pt

    Sets the workspace's default Apache Airflow pool template.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: PATCH /workspaces/{workspaceId}/apacheAirflowJobs/settings (preview)
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricApacheAirflowSetting {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultPoolTemplateId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'apacheAirflowJobs', 'settings') -QueryParameters @{ beta = 'true' }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ defaultPoolTemplateId = $DefaultPoolTemplateId }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Patch'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Workspace '$WorkspaceId'", "Update Apache Airflow settings")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Apache Airflow settings updated for workspace '$WorkspaceId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update Apache Airflow settings for workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
        }
    }
}
