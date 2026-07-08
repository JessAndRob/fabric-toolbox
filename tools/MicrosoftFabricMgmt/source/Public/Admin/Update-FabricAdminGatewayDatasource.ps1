<#
.SYNOPSIS
    Updates the credentials of a datasource on a Power BI on-premises gateway.

.DESCRIPTION
    The Update-FabricAdminGatewayDatasource function updates a gateway datasource's credential details
    via `PATCH https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER DatasourceId
    The unique identifier of the datasource to update. Mandatory. Binds from the pipeline via the
    'id' alias.

.PARAMETER CredentialDetails
    A hashtable of the new credential details. Mandatory.

.EXAMPLE
    Update-FabricAdminGatewayDatasource -GatewayId $gw -DatasourceId $ds -CredentialDetails $cred

    Updates the datasource's stored credentials.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: PATCH https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricAdminGatewayDatasource {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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
        [hashtable]$CredentialDetails
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $powerBIBaseUrl = "https://api.powerbi.com/v1.0/myorg"
            $apiEndpointURI = "$powerBIBaseUrl/gateways/$GatewayId/datasources/$DatasourceId"
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ credentialDetails = $CredentialDetails }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Patch'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Datasource '$DatasourceId' on gateway '$GatewayId'", "Update credentials")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Datasource '$DatasourceId' updated on gateway '$GatewayId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update datasource '$DatasourceId' on gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
