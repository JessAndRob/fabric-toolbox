<#
.SYNOPSIS
    Lists the users of a Power BI gateway datasource.

.DESCRIPTION
    The Get-FabricAdminGatewayDatasourceUser function retrieves the users that have access to a
    gateway datasource via
    `GET https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}/users`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER DatasourceId
    The unique identifier of the datasource. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Get-FabricAdminGatewayDatasourceUser -GatewayId $gw -DatasourceId $ds

    Lists the users with access to the datasource.

.OUTPUTS
    System.Object
    The datasource user object(s).

.NOTES
    - API Endpoint: GET https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}/users
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricAdminGatewayDatasourceUser {
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
            $apiEndpointURI = "$powerBIBaseUrl/gateways/$GatewayId/datasources/$DatasourceId/users"
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

            Write-FabricLog -Message "Users retrieved for datasource '$DatasourceId' on gateway '$GatewayId'." -Level Debug
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve users for datasource '$DatasourceId' on gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
