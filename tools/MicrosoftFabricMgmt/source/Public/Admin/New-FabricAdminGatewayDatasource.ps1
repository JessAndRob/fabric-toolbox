<#
.SYNOPSIS
    Creates (publishes) a datasource on a Power BI on-premises gateway.

.DESCRIPTION
    The New-FabricAdminGatewayDatasource function publishes a new datasource to a gateway via
    `POST https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER DataSourceType
    The datasource type (e.g. 'SQL', 'Web'). Mandatory.

.PARAMETER ConnectionDetails
    The connection details as a JSON string (e.g. '{"server":"srv","database":"db"}'). Mandatory.

.PARAMETER CredentialDetails
    A hashtable of credential details (credentialType, credentials, encryptedConnection,
    encryptionAlgorithm, privacyLevel, etc.). Mandatory.

.PARAMETER DataSourceName
    The display name for the datasource. Mandatory.

.EXAMPLE
    New-FabricAdminGatewayDatasource -GatewayId $gw -DataSourceType SQL -ConnectionDetails '{"server":"s","database":"d"}' -CredentialDetails $cred -DataSourceName 'Prod SQL'

    Publishes a SQL datasource to the gateway.

.OUTPUTS
    System.Object
    The created datasource object.

.NOTES
    - API Endpoint: POST https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function New-FabricAdminGatewayDatasource {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DataSourceType,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionDetails,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$CredentialDetails,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DataSourceName
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $powerBIBaseUrl = "https://api.powerbi.com/v1.0/myorg"
            $apiEndpointURI = "$powerBIBaseUrl/gateways/$GatewayId/datasources"
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                dataSourceType    = $DataSourceType
                connectionDetails = $ConnectionDetails
                credentialDetails = $CredentialDetails
                dataSourceName    = $DataSourceName
            }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Gateway '$GatewayId'", "Publish datasource '$DataSourceName'")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Datasource '$DataSourceName' published to gateway '$GatewayId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to publish datasource to gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
