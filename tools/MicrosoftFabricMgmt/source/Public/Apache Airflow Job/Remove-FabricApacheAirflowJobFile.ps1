<#
.SYNOPSIS
    Removes a file from a Fabric Apache Airflow job. (Preview)

.DESCRIPTION
    The Remove-FabricApacheAirflowJobFile function deletes a file from an Apache Airflow job via
    `DELETE /workspaces/{workspaceId}/ApacheAirflowJobs/{apacheAirflowJobId}/files/{filePath}`. This
    is a preview (beta) API.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the Apache Airflow job. Mandatory.

.PARAMETER ApacheAirflowJobId
    The unique identifier of the Apache Airflow job. Mandatory. Binds from the pipeline via the 'id'
    alias.

.PARAMETER FilePath
    The path of the file to remove (e.g. 'dags/my_dag.py'). Mandatory.

.EXAMPLE
    Remove-FabricApacheAirflowJobFile -WorkspaceId $ws -ApacheAirflowJobId $job -FilePath 'dags/my_dag.py'

    Deletes the specified file from the job.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE /workspaces/{workspaceId}/ApacheAirflowJobs/{apacheAirflowJobId}/files/{filePath} (preview)
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricApacheAirflowJobFile {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ApacheAirflowJobId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'ApacheAirflowJobs', $ApacheAirflowJobId, 'files', $FilePath) -QueryParameters @{ beta = 'true' }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("File '$FilePath' on Apache Airflow job '$ApacheAirflowJobId'", "Delete")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "File '$FilePath' removed from Apache Airflow job '$ApacheAirflowJobId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove file '$FilePath' from Apache Airflow job '$ApacheAirflowJobId'. Error: $errorDetails" -Level Error
        }
    }
}
