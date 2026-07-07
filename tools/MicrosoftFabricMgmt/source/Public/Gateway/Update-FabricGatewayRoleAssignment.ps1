<#
.SYNOPSIS
    Updates the role assigned to a principal on a Fabric gateway.

.DESCRIPTION
    The Update-FabricGatewayRoleAssignment function updates an existing gateway role assignment via
    `PATCH /gateways/{gatewayId}/roleAssignments/{gatewayRoleAssignmentId}`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER GatewayRoleAssignmentId
    The unique identifier of the role assignment to update. Mandatory.

.PARAMETER GatewayRole
    The new role to assign. Valid values: Admin, ConnectionCreatorWithResharing, ConnectionCreator.

.EXAMPLE
    Update-FabricGatewayRoleAssignment -GatewayId $gw -GatewayRoleAssignmentId $ra -GatewayRole ConnectionCreator

    Changes the specified role assignment to the ConnectionCreator role.

.OUTPUTS
    System.Object
    The updated role assignment object returned by the API.

.NOTES
    - API Endpoint: PATCH /gateways/{gatewayId}/roleAssignments/{gatewayRoleAssignmentId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricGatewayRoleAssignment {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayRoleAssignmentId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Admin', 'ConnectionCreatorWithResharing', 'ConnectionCreator')]
        [string]$GatewayRole
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId -Subresource 'roleAssignments' -ItemId $GatewayRoleAssignmentId
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ role = $GatewayRole }
            $bodyJson = Convert-FabricRequestBody -InputObject $body

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Patch'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Role assignment '$GatewayRoleAssignmentId' on gateway '$GatewayId'", "Update role to '$GatewayRole'")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Role assignment '$GatewayRoleAssignmentId' updated successfully on gateway '$GatewayId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update gateway role assignment. Error: $errorDetails" -Level Error
        }
    }
}
