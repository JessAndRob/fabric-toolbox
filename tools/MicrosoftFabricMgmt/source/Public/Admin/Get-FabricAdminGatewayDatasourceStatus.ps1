<#
.SYNOPSIS
    Gets the connectivity status of a Power BI gateway datasource.

.DESCRIPTION
    The Get-FabricAdminGatewayDatasourceStatus function checks the connectivity status of a gateway
    datasource via
    `GET https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}/status`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER DatasourceId
    The unique identifier of the datasource. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Get-FabricAdminGatewayDatasourceStatus -GatewayId $gw -DatasourceId $ds

    Returns the datasource's connectivity status.

.OUTPUTS
    System.Object
    The datasource connectivity status.

.NOTES
    - API Endpoint: GET https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}/status
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricAdminGatewayDatasourceStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$DatasourceId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $powerBIBaseUrl = "https://api.powerbi.com/v1.0/myorg"
            $apiEndpointURI = "$powerBIBaseUrl/gateways/$GatewayId/datasources/$DatasourceId/status"
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

            Write-FabricLog -Message "Status retrieved for datasource '$DatasourceId' on gateway '$GatewayId'." -Level Debug
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve status for datasource '$DatasourceId' on gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
