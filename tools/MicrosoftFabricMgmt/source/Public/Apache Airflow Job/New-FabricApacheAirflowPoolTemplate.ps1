<#
.SYNOPSIS
    Creates an Apache Airflow pool template in a Fabric workspace. (Preview)

.DESCRIPTION
    The New-FabricApacheAirflowPoolTemplate function creates a pool template via
    `POST /workspaces/{workspaceId}/apacheAirflowJobs/poolTemplates`. This is a preview (beta) API.

.PARAMETER WorkspaceId
    The unique identifier of the workspace. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Name
    The name of the pool template. Mandatory.

.PARAMETER NodeSize
    The node size for the pool: Small or Large. Mandatory.

.PARAMETER MinNodeCount
    The minimum number of nodes for autoscaling. Mandatory.

.PARAMETER MaxNodeCount
    The maximum number of nodes for autoscaling. Mandatory.

.PARAMETER ApacheAirflowJobVersion
    The Apache Airflow version for the pool template. Mandatory.

.EXAMPLE
    New-FabricApacheAirflowPoolTemplate -WorkspaceId $ws -Name 'default' -NodeSize Small -MinNodeCount 1 -MaxNodeCount 3 -ApacheAirflowJobVersion '2.9.3'

    Creates a small autoscaling pool template.

.OUTPUTS
    System.Object
    The created pool template object.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/apacheAirflowJobs/poolTemplates (preview)
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function New-FabricApacheAirflowPoolTemplate {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Small', 'Large')]
        [string]$NodeSize,

        [Parameter(Mandatory = $true)]
        [int]$MinNodeCount,

        [Parameter(Mandatory = $true)]
        [int]$MaxNodeCount,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApacheAirflowJobVersion
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'apacheAirflowJobs', 'poolTemplates') -QueryParameters @{ beta = 'true' }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                name                    = $Name
                nodeSize                = $NodeSize
                computeScalability      = @{
                    minNodeCount = $MinNodeCount
                    maxNodeCount = $MaxNodeCount
                }
                apacheAirflowJobVersion = $ApacheAirflowJobVersion
            }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Workspace '$WorkspaceId'", "Create Apache Airflow pool template '$Name'")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Apache Airflow pool template '$Name' created in workspace '$WorkspaceId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to create Apache Airflow pool template '$Name'. Error: $errorDetails" -Level Error
        }
    }
}
