<#
.SYNOPSIS
    Assigns a role to a principal on a Fabric gateway.

.DESCRIPTION
    The Add-FabricGatewayRoleAssignment function assigns a gateway role (Admin,
    ConnectionCreatorWithResharing, ConnectionCreator) to a principal (User, Group,
    ServicePrincipal, ServicePrincipalProfile) by sending a POST request to
    `/gateways/{gatewayId}/roleAssignments`.

.PARAMETER GatewayId
    The unique identifier of the gateway. Mandatory.

.PARAMETER PrincipalId
    The unique identifier of the principal to assign the role to. Mandatory.

.PARAMETER PrincipalType
    The type of principal. Valid values: Group, ServicePrincipal, ServicePrincipalProfile, User.

.PARAMETER GatewayRole
    The role to assign. Valid values: Admin, ConnectionCreatorWithResharing, ConnectionCreator.

.EXAMPLE
    Add-FabricGatewayRoleAssignment -GatewayId $gw -PrincipalId $userId -PrincipalType User -GatewayRole Admin

    Grants the Admin role on the gateway to the specified user.

.OUTPUTS
    System.Object
    The created role assignment object returned by the API.

.NOTES
    - API Endpoint: POST /gateways/{gatewayId}/roleAssignments
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Add-FabricGatewayRoleAssignment {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PrincipalId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Group', 'ServicePrincipal', 'ServicePrincipalProfile', 'User')]
        [string]$PrincipalType,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Admin', 'ConnectionCreatorWithResharing', 'ConnectionCreator')]
        [string]$GatewayRole
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId -Subresource 'roleAssignments'
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                principal = @{
                    id   = $PrincipalId
                    type = $PrincipalType
                }
                role      = $GatewayRole
            }

            $bodyJson = Convert-FabricRequestBody -InputObject $body

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Gateway '$GatewayId'", "Assign role '$GatewayRole' to principal '$PrincipalId'")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Role '$GatewayRole' assigned to principal '$PrincipalId' successfully on gateway '$GatewayId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to assign gateway role. Error: $errorDetails" -Level Error
        }
    }
}
