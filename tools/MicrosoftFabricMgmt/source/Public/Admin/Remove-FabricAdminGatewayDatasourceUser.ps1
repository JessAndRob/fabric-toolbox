<#
.SYNOPSIS
    Revokes a user's access to a Power BI gateway datasource.

.DESCRIPTION
    The Remove-FabricAdminGatewayDatasourceUser function removes a user's access from a gateway
    datasource via
    `DELETE https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}/users/{emailAdress}`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER DatasourceId
    The unique identifier of the datasource. Mandatory.

.PARAMETER EmailAddress
    The email address (or identifier) of the user whose access is revoked. Mandatory.

.EXAMPLE
    Remove-FabricAdminGatewayDatasourceUser -GatewayId $gw -DatasourceId $ds -EmailAddress user@contoso.com

    Revokes the user's access to the datasource.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}/users/{emailAdress}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricAdminGatewayDatasourceUser {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$DatasourceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EmailAddress
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $powerBIBaseUrl = "https://api.powerbi.com/v1.0/myorg"
            $apiEndpointURI = "$powerBIBaseUrl/gateways/$GatewayId/datasources/$DatasourceId/users/$EmailAddress"
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("User '$EmailAddress' on datasource '$DatasourceId' (gateway '$GatewayId')", "Revoke access")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Access revoked for '$EmailAddress' on datasource '$DatasourceId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to revoke access for '$EmailAddress' on datasource '$DatasourceId'. Error: $errorDetails" -Level Error
        }
    }
}
