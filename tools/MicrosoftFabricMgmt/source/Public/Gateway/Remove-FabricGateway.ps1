<#
.SYNOPSIS
    Removes a Fabric gateway.

.DESCRIPTION
    The Remove-FabricGateway function deletes a gateway via `DELETE /gateways/{gatewayId}`.

.PARAMETER GatewayId
    The unique identifier of the gateway to remove. Mandatory. Binds from the pipeline by value or
    property name (e.g. from Get-FabricGateway output).

.EXAMPLE
    Remove-FabricGateway -GatewayId "12345678-1234-1234-1234-123456789012"

    Deletes the specified gateway.

.EXAMPLE
    Get-FabricGateway | Where-Object displayName -like 'Test*' | Remove-FabricGateway -Confirm:$false

    Deletes every gateway whose name starts with 'Test'.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE /gateways/{gatewayId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricGateway {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("Gateway '$GatewayId'", "Delete")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Gateway '$GatewayId' removed successfully." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
