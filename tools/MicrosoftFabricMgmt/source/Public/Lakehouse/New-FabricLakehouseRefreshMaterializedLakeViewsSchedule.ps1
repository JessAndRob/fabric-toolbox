<#
.SYNOPSIS
    Creates a schedule for the Refresh Materialized Lake Views job of a Fabric lakehouse.

.DESCRIPTION
    The New-FabricLakehouseRefreshMaterializedLakeViewsSchedule function creates a schedule for the
    lakehouse RefreshMaterializedLakeViews background job via
    `POST /workspaces/{workspaceId}/lakehouses/{lakehouseId}/jobs/RefreshMaterializedLakeViews/schedules`.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the lakehouse. Mandatory.

.PARAMETER LakehouseId
    The unique identifier of the lakehouse. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Enabled
    Whether the schedule is enabled. Mandatory.

.PARAMETER Configuration
    The schedule configuration hashtable (e.g. @{ type = 'Cron'; startDateTime = ...; endDateTime = ...;
    localTimeZoneId = ...; interval = ... }). Mandatory.

.EXAMPLE
    $cfg = @{ type = 'Daily'; startDateTime = '2026-01-01T00:00:00'; endDateTime = '2026-12-31T00:00:00'; localTimeZoneId = 'UTC'; times = @('06:00') }
    New-FabricLakehouseRefreshMaterializedLakeViewsSchedule -WorkspaceId $ws -LakehouseId $lh -Enabled $true -Configuration $cfg

    Creates a daily refresh schedule.

.OUTPUTS
    System.Object
    The created schedule object returned by the API.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/lakehouses/{lakehouseId}/jobs/RefreshMaterializedLakeViews/schedules
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function New-FabricLakehouseRefreshMaterializedLakeViewsSchedule {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$LakehouseId,

        [Parameter(Mandatory = $true)]
        [bool]$Enabled,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Configuration
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'lakehouses', $LakehouseId, 'jobs', 'RefreshMaterializedLakeViews', 'schedules')
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
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Lakehouse '$LakehouseId'", "Create RefreshMaterializedLakeViews schedule")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "RefreshMaterializedLakeViews schedule created for lakehouse '$LakehouseId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to create RefreshMaterializedLakeViews schedule for lakehouse '$LakehouseId'. Error: $errorDetails" -Level Error
        }
    }
}
