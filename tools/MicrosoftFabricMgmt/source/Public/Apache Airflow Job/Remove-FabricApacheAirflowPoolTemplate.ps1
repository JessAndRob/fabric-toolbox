<#
.SYNOPSIS
    Removes an Apache Airflow pool template from a Fabric workspace. (Preview)

.DESCRIPTION
    The Remove-FabricApacheAirflowPoolTemplate function deletes a pool template via
    `DELETE /workspaces/{workspaceId}/apacheAirflowJobs/poolTemplates/{poolTemplateId}`. This is a
    preview (beta) API.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory.

.PARAMETER PoolTemplateId
    The unique identifier of the pool template to remove. Mandatory. Binds from the pipeline via the
    'id' alias.

.EXAMPLE
    Remove-FabricApacheAirflowPoolTemplate -WorkspaceId $ws -PoolTemplateId $pt

    Deletes the specified pool template.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE /workspaces/{workspaceId}/apacheAirflowJobs/poolTemplates/{poolTemplateId} (preview)
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricApacheAirflowPoolTemplate {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$PoolTemplateId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'apacheAirflowJobs', 'poolTemplates', $PoolTemplateId) -QueryParameters @{ beta = 'true' }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("Pool template '$PoolTemplateId' in workspace '$WorkspaceId'", "Delete")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Apache Airflow pool template '$PoolTemplateId' removed from workspace '$WorkspaceId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove Apache Airflow pool template '$PoolTemplateId'. Error: $errorDetails" -Level Error
        }
    }
}
