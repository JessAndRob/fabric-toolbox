<#
.SYNOPSIS
    Lists role assignments on a Fabric gateway, or retrieves a single one by id.

.DESCRIPTION
    The Get-FabricGatewayRoleAssignment function retrieves the role assignments of a gateway via
    `GET /gateways/{gatewayId}/roleAssignments`, or a single assignment via
    `GET /gateways/{gatewayId}/roleAssignments/{gatewayRoleAssignmentId}` when
    the -GatewayRoleAssignmentId parameter is supplied. Results are auto-paginated.

    By default each assignment is enriched with the owning GatewayId / resolved GatewayName and
    decorated for the custom table view. Pass -Raw to return the untouched API response.

.PARAMETER GatewayId
    The unique identifier of the gateway whose role assignments are listed. Mandatory. Binds from
    the pipeline by property name via the 'id' alias.

.PARAMETER GatewayRoleAssignmentId
    The unique identifier of a single role assignment to retrieve. When omitted, all assignments
    are listed.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricGatewayRoleAssignment -GatewayId "12345678-1234-1234-1234-123456789012"

    Lists all role assignments on the specified gateway.

.EXAMPLE
    Get-FabricGatewayRoleAssignment -GatewayId $gw -GatewayRoleAssignmentId $ra

    Retrieves the single role assignment with the specified id.

.OUTPUTS
    System.Object
    Role assignment object(s) with all API-returned properties (id, principal, role) plus the
    owning GatewayId / GatewayName when enriched.

.NOTES
    - API Endpoint: GET /gateways/{gatewayId}/roleAssignments and .../{gatewayRoleAssignmentId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricGatewayRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayRoleAssignmentId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = if ($GatewayRoleAssignmentId) {
                New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId -Subresource 'roleAssignments' -ItemId $GatewayRoleAssignmentId
            }
            else {
                New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId -Subresource 'roleAssignments'
            }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No role assignments found for gateway '$GatewayId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            $gatewayName = $GatewayId
            try { $gatewayName = Resolve-FabricGatewayName -GatewayId $GatewayId }
            catch {
                Write-FabricLog -Message "Failed to resolve gateway name for ID '$GatewayId': $($_.Exception.Message)" -Level Debug
            }

            foreach ($assignment in $response) {
                $assignment | Add-Member -NotePropertyName 'GatewayId'   -NotePropertyValue $GatewayId   -Force
                $assignment | Add-Member -NotePropertyName 'GatewayName' -NotePropertyValue $gatewayName -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.GatewayRoleAssignment'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve role assignments for gateway '$GatewayId'. Error: $errorDetails" -Level Error
        }
    }
}
