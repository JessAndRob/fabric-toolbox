<#
.SYNOPSIS
    Grants a user access to a Power BI gateway datasource.

.DESCRIPTION
    The Add-FabricAdminGatewayDatasourceUser function grants a principal an access right on a gateway
    datasource via
    `POST https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}/users`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER DatasourceId
    The unique identifier of the datasource. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER DatasourceAccessRight
    The access right to grant: None, Read, or ReadOverrideEffectiveIdentity. Mandatory.

.PARAMETER EmailAddress
    The email address of the user to grant access to.

.PARAMETER Identifier
    The object identifier of the principal (used for groups / service principals).

.PARAMETER PrincipalType
    The principal type: App, Group, None, or User.

.EXAMPLE
    Add-FabricAdminGatewayDatasourceUser -GatewayId $gw -DatasourceId $ds -DatasourceAccessRight Read -EmailAddress user@contoso.com

    Grants the user Read access to the datasource.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}/users
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Add-FabricAdminGatewayDatasourceUser {
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
        [ValidateSet('None', 'Read', 'ReadOverrideEffectiveIdentity')]
        [string]$DatasourceAccessRight,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$EmailAddress,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Identifier,

        [Parameter()]
        [ValidateSet('App', 'Group', 'None', 'User')]
        [string]$PrincipalType
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $powerBIBaseUrl = "https://api.powerbi.com/v1.0/myorg"
            $apiEndpointURI = "$powerBIBaseUrl/gateways/$GatewayId/datasources/$DatasourceId/users"
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ datasourceAccessRight = $DatasourceAccessRight }
            if ($PSBoundParameters.ContainsKey('EmailAddress')) { $body.emailAddress = $EmailAddress }
            if ($PSBoundParameters.ContainsKey('Identifier')) { $body.identifier = $Identifier }
            if ($PSBoundParameters.ContainsKey('PrincipalType')) { $body.principalType = $PrincipalType }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Datasource '$DatasourceId' on gateway '$GatewayId'", "Grant '$DatasourceAccessRight' access")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Access granted on datasource '$DatasourceId' (gateway '$GatewayId')." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to grant access on datasource '$DatasourceId'. Error: $errorDetails" -Level Error
        }
    }
}
