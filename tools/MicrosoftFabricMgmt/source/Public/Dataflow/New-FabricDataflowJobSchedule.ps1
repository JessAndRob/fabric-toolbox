<#
.SYNOPSIS
    Creates a schedule for a Fabric dataflow job.

.DESCRIPTION
    The New-FabricDataflowJobSchedule function creates a schedule for a dataflow background job via
    `POST /workspaces/{workspaceId}/dataflows/{dataflowId}/jobs/{jobType}/schedules`, for either the
    Execute or ApplyChanges job type.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the dataflow. Mandatory.

.PARAMETER DataflowId
    The unique identifier of the dataflow. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER JobType
    The dataflow job type to schedule: Execute or ApplyChanges. Mandatory.

.PARAMETER Enabled
    Whether the schedule is enabled. Mandatory.

.PARAMETER Configuration
    The schedule configuration hashtable (type, startDateTime, endDateTime, localTimeZoneId, etc.).
    Mandatory.

.EXAMPLE
    $cfg = @{ type = 'Daily'; startDateTime = '2026-01-01T00:00:00'; endDateTime = '2026-12-31T00:00:00'; localTimeZoneId = 'UTC'; times = @('06:00') }
    New-FabricDataflowJobSchedule -WorkspaceId $ws -DataflowId $df -JobType Execute -Enabled $true -Configuration $cfg

    Creates a daily Execute schedule for the dataflow.

.OUTPUTS
    System.Object
    The created schedule object returned by the API.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/dataflows/{dataflowId}/jobs/{jobType}/schedules
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function New-FabricDataflowJobSchedule {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$DataflowId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Execute', 'ApplyChanges')]
        [string]$JobType,

        [Parameter(Mandatory = $true)]
        [bool]$Enabled,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Configuration
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'dataflows', $DataflowId, 'jobs', $JobType, 'schedules')
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

            if ($PSCmdlet.ShouldProcess("Dataflow '$DataflowId'", "Create $JobType schedule")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "$JobType schedule created for dataflow '$DataflowId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to create $JobType schedule for dataflow '$DataflowId'. Error: $errorDetails" -Level Error
        }
    }
}
