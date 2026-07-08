<#
.SYNOPSIS
    Lists the files of a Fabric Apache Airflow job, or retrieves a single file's content. (Preview)

.DESCRIPTION
    The Get-FabricApacheAirflowJobFile function lists the files stored in an Apache Airflow job via
    `GET /workspaces/{workspaceId}/ApacheAirflowJobs/{apacheAirflowJobId}/files`, or retrieves the
    content of a single file via `GET .../files/{filePath}` when -FilePath is supplied. This is a
    preview (beta) API.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the Apache Airflow job. Mandatory.

.PARAMETER ApacheAirflowJobId
    The unique identifier of the Apache Airflow job. Mandatory. Binds from the pipeline via the 'id'
    alias.

.PARAMETER FilePath
    The path of a single file to retrieve (e.g. 'dags/my_dag.py'). When omitted, all files are listed.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Get-FabricApacheAirflowJobFile -WorkspaceId $ws -ApacheAirflowJobId $job

    Lists all files in the Apache Airflow job.

.EXAMPLE
    Get-FabricApacheAirflowJobFile -WorkspaceId $ws -ApacheAirflowJobId $job -FilePath 'dags/my_dag.py'

    Retrieves the content of the specified file.

.OUTPUTS
    System.Object
    The file listing, or the requested file's content.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/ApacheAirflowJobs/{apacheAirflowJobId}/files (+ /{filePath}) (preview)
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricApacheAirflowJobFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ApacheAirflowJobId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $segments = @('workspaces', $WorkspaceId, 'ApacheAirflowJobs', $ApacheAirflowJobId, 'files')
            if ($FilePath) { $segments += $FilePath }
            $apiEndpointURI = New-FabricAPIUri -Segments $segments -QueryParameters @{ beta = 'true' }
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

            Write-FabricLog -Message "Files retrieved for Apache Airflow job '$ApacheAirflowJobId'." -Level Debug
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve files for Apache Airflow job '$ApacheAirflowJobId'. Error: $errorDetails" -Level Error
        }
    }
}
