<#
.SYNOPSIS
    Removes a role assignment from a Fabric gateway.

.DESCRIPTION
    The Remove-FabricGatewayRoleAssignment function deletes a gateway role assignment via
    `DELETE /gateways/{gatewayId}/roleAssignments/{gatewayRoleAssignmentId}`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER GatewayRoleAssignmentId
    The unique identifier of the role assignment to remove. Mandatory. Binds from the pipeline by
    property name via the 'id' alias.

.EXAMPLE
    Remove-FabricGatewayRoleAssignment -GatewayId $gw -GatewayRoleAssignmentId $ra

    Removes the specified role assignment from the gateway.

.OUTPUTS
    None.

.NOTES
    - API Endpoint: DELETE /gateways/{gatewayId}/roleAssignments/{gatewayRoleAssignmentId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Remove-FabricGatewayRoleAssignment {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayRoleAssignmentId
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId -Subresource 'roleAssignments' -ItemId $GatewayRoleAssignmentId
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            if ($PSCmdlet.ShouldProcess("Role assignment '$GatewayRoleAssignmentId' on gateway '$GatewayId'", "Delete")) {
                $apiParams = @{
                    BaseURI = $apiEndpointURI
                    Headers = $script:FabricAuthContext.FabricHeaders
                    Method  = 'Delete'
                }
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Role assignment '$GatewayRoleAssignmentId' removed successfully from gateway '$GatewayId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to remove gateway role assignment '$GatewayRoleAssignmentId'. Error: $errorDetails" -Level Error
        }
    }
}
