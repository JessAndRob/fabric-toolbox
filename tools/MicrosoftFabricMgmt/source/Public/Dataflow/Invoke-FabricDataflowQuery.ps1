<#
.SYNOPSIS
    Executes a query against a Fabric dataflow.

.DESCRIPTION
    The Invoke-FabricDataflowQuery function runs a named query (optionally with a custom mashup
    document) against a dataflow via `POST /workspaces/{workspaceId}/dataflows/{dataflowId}/executeQuery`.
    The call is long-running; the module transparently waits for and returns the result.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the dataflow. Mandatory.

.PARAMETER DataflowId
    The unique identifier of the dataflow. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER QueryName
    The name of the query to execute. Mandatory.

.PARAMETER CustomMashupDocument
    An optional custom mashup (M) document to execute in place of the stored query definition.

.EXAMPLE
    Invoke-FabricDataflowQuery -WorkspaceId $ws -DataflowId $df -QueryName 'Query1'

    Executes the named query and returns its result.

.OUTPUTS
    System.Object
    The query execution result returned by the API.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/dataflows/{dataflowId}/executeQuery
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Invoke-FabricDataflowQuery {
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
        [ValidateNotNullOrEmpty()]
        [string]$QueryName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CustomMashupDocument
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'dataflows', $DataflowId, 'executeQuery')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ queryName = $QueryName }
            if ($PSBoundParameters.ContainsKey('CustomMashupDocument')) { $body.customMashupDocument = $CustomMashupDocument }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Dataflow '$DataflowId'", "Execute query '$QueryName'")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Query '$QueryName' executed on dataflow '$DataflowId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to execute query on dataflow '$DataflowId'. Error: $errorDetails" -Level Error
        }
    }
}
