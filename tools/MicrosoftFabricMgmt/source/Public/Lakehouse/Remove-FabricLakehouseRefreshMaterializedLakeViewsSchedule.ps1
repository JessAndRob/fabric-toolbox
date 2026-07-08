<#
.SYNOPSIS
    Removes a schedule of the Refresh Materialized Lake Views job of a Fabric lakehouse.

.DESCRIPTION
    The Remove-FabricLakehouseRefreshMaterializedLakeViewsSchedule function deletes a schedule for
    the lakehouse RefreshMaterializedLakeViews background job via
    `DELETE /workspaces/{workspaceId}/lakehouses/{lakehouseId}/jobs/RefreshMaterializedLakeViews/schedules/{scheduleId}`.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the lakehouse. Mandatory.

.PARAMETER LakehouseId
    The unique identifier of the lakehouse. Mandatory.

.PARAMETER ScheduleId
    The unique identifier of the schedule to remove. Mandatory. Binds from the pipeline via the 'id'
    alias.

.EXAMPLE
    Remove-FabricLakehouseRefreshMaterializedLakeViewsSchedule -WorkspaceId $ws -LakehouseId $lh -ScheduleId $sc

    Deletes the specified refresh schedule.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE /workspaces/{workspaceId}/lakehouses/{lakehouseId}/jobs/RefreshMaterializedLakeViews/schedules/{scheduleId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricLakehouseRefreshMaterializedLakeViewsSchedule {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LakehouseId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ScheduleId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'lakehouses', $LakehouseId, 'jobs', 'RefreshMaterializedLakeViews', 'schedules', $ScheduleId)
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("Schedule '$ScheduleId' on lakehouse '$LakehouseId'", "Delete")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "RefreshMaterializedLakeViews schedule '$ScheduleId' removed from lakehouse '$LakehouseId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove RefreshMaterializedLakeViews schedule '$ScheduleId'. Error: $errorDetails" -Level Error
        }
    }
}
