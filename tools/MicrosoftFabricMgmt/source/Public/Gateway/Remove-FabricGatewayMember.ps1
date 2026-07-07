<#
.SYNOPSIS
    Removes a member gateway from a Fabric gateway cluster.

.DESCRIPTION
    The Remove-FabricGatewayMember function deletes a gateway member via
    `DELETE /gateways/{gatewayId}/members/{gatewayMemberId}`.

.PARAMETER GatewayId
    The unique identifier of the gateway that owns the member. Mandatory.

.PARAMETER GatewayMemberId
    The unique identifier of the member gateway to remove. Mandatory. Binds from the pipeline by
    property name via the 'id' alias.

.EXAMPLE
    Remove-FabricGatewayMember -GatewayId $gw -GatewayMemberId $member

    Removes the specified member gateway from the cluster.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE /gateways/{gatewayId}/members/{gatewayMemberId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricGatewayMember {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayMemberId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId -Subresource 'members' -ItemId $GatewayMemberId
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("Member '$GatewayMemberId' on gateway '$GatewayId'", "Delete")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Gateway member '$GatewayMemberId' removed successfully from gateway '$GatewayId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove gateway member '$GatewayMemberId'. Error: $errorDetails" -Level Error
        }
    }
}
