<#
.SYNOPSIS
    Updates a schedule of the Refresh Materialized Lake Views job of a Fabric lakehouse.

.DESCRIPTION
    The Update-FabricLakehouseRefreshMaterializedLakeViewsSchedule function updates an existing
    schedule for the lakehouse RefreshMaterializedLakeViews background job via
    `PATCH /workspaces/{workspaceId}/lakehouses/{lakehouseId}/jobs/RefreshMaterializedLakeViews/schedules/{scheduleId}`.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the lakehouse. Mandatory.

.PARAMETER LakehouseId
    The unique identifier of the lakehouse. Mandatory.

.PARAMETER ScheduleId
    The unique identifier of the schedule to update. Mandatory. Binds from the pipeline via the 'id'
    alias.

.PARAMETER Enabled
    Whether the schedule is enabled. Mandatory.

.PARAMETER Configuration
    The schedule configuration hashtable. Mandatory.

.EXAMPLE
    Update-FabricLakehouseRefreshMaterializedLakeViewsSchedule -WorkspaceId $ws -LakehouseId $lh -ScheduleId $sc -Enabled $false -Configuration $cfg

    Disables and reconfigures the schedule.

.OUTPUTS
    System.Object
    The updated schedule object returned by the API.

.NOTES
    - API Endpoint: PATCH /workspaces/{workspaceId}/lakehouses/{lakehouseId}/jobs/RefreshMaterializedLakeViews/schedules/{scheduleId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricLakehouseRefreshMaterializedLakeViewsSchedule {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LakehouseId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ScheduleId,

        [Parameter(Mandatory = $true)]
        [bool]$Enabled,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Configuration
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'lakehouses', $LakehouseId, 'jobs', 'RefreshMaterializedLakeViews', 'schedules', $ScheduleId)
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                enabled       = $Enabled
                configuration = $Configuration
            }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Patch'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Schedule '$ScheduleId' on lakehouse '$LakehouseId'", "Update RefreshMaterializedLakeViews schedule")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "RefreshMaterializedLakeViews schedule '$ScheduleId' updated for lakehouse '$LakehouseId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update RefreshMaterializedLakeViews schedule '$ScheduleId'. Error: $errorDetails" -Level Error
        }
    }
}
