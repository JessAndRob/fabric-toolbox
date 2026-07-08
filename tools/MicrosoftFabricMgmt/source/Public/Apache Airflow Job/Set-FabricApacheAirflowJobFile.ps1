<#
.SYNOPSIS
    Creates or updates a file in a Fabric Apache Airflow job. (Preview)

.DESCRIPTION
    The Set-FabricApacheAirflowJobFile function uploads a file to an Apache Airflow job at the given
    path via `PUT /workspaces/{workspaceId}/ApacheAirflowJobs/{apacheAirflowJobId}/files/{filePath}`.
    The file content is sent as an application/octet-stream body. This is a preview (beta) API.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the Apache Airflow job. Mandatory.

.PARAMETER ApacheAirflowJobId
    The unique identifier of the Apache Airflow job. Mandatory. Binds from the pipeline via the 'id'
    alias.

.PARAMETER FilePath
    The destination path of the file within the job (e.g. 'dags/my_dag.py'). Mandatory.

.PARAMETER SourceFile
    The path to the local file whose content is uploaded. Mandatory. The file must exist.

.EXAMPLE
    Set-FabricApacheAirflowJobFile -WorkspaceId $ws -ApacheAirflowJobId $job -FilePath 'dags/my_dag.py' -SourceFile .\my_dag.py

    Uploads my_dag.py to dags/my_dag.py in the job.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: PUT /workspaces/{workspaceId}/ApacheAirflowJobs/{apacheAirflowJobId}/files/{filePath} (preview)
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Set-FabricApacheAirflowJobFile {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$SourceFile
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'ApacheAirflowJobs', $ApacheAirflowJobId, 'files', $FilePath) -QueryParameters @{ beta = 'true' }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $fileContent = Get-Content -Path $SourceFile -Raw

            $apiParams = @{
                BaseURI     = $apiEndpointURI
                Headers     = $script:FabricAuthContext.FabricHeaders
                Method      = 'Put'
                Body        = $fileContent
                ContentType = 'application/octet-stream'
            }

            if ($PSCmdlet.ShouldProcess("File '$FilePath' on Apache Airflow job '$ApacheAirflowJobId'", "Create or update")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "File '$FilePath' uploaded to Apache Airflow job '$ApacheAirflowJobId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to upload file '$FilePath' to Apache Airflow job '$ApacheAirflowJobId'. Error: $errorDetails" -Level Error
        }
    }
}
