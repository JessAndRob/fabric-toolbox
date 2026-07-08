<#
.SYNOPSIS
    Removes a datasource from a Power BI on-premises gateway.

.DESCRIPTION
    The Remove-FabricAdminGatewayDatasource function deletes a datasource from a gateway via
    `DELETE https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER DatasourceId
    The unique identifier of the datasource to remove. Mandatory. Binds from the pipeline via the
    'id' alias.

.EXAMPLE
    Remove-FabricAdminGatewayDatasource -GatewayId $gw -DatasourceId $ds

    Deletes the datasource from the gateway.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricAdminGatewayDatasource {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$DatasourceId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $powerBIBaseUrl = "https://api.powerbi.com/v1.0/myorg"
            $apiEndpointURI = "$powerBIBaseUrl/gateways/$GatewayId/datasources/$DatasourceId"
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("Datasource '$DatasourceId' on gateway '$GatewayId'", "Delete")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Datasource '$DatasourceId' removed from gateway '$GatewayId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove datasource '$DatasourceId' from gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
