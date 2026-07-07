<#
.SYNOPSIS
    Sets the audited actions and groups for a Fabric warehouse.

.DESCRIPTION
    The Set-FabricWarehouseSqlAuditActionsAndGroups function replaces the set of audited actions and
    action groups for a warehouse via
    `POST /workspaces/{workspaceId}/warehouses/{itemId}/settings/sqlAudit/setAuditActionsAndGroups`.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the warehouse. Mandatory.

.PARAMETER WarehouseId
    The unique identifier of the warehouse. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER AuditActionsAndGroups
    The array of audit action and action-group names to set (e.g.
    'BATCH_COMPLETED_GROUP', 'FAILED_DATABASE_AUTHENTICATION_GROUP'). Mandatory.

.EXAMPLE
    Set-FabricWarehouseSqlAuditActionsAndGroups -WorkspaceId $ws -WarehouseId $wh -AuditActionsAndGroups 'BATCH_COMPLETED_GROUP'

    Sets the warehouse to audit the batch-completed group.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/warehouses/{itemId}/settings/sqlAudit/setAuditActionsAndGroups
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Set-FabricWarehouseSqlAuditActionsAndGroups {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WarehouseId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$AuditActionsAndGroups
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'warehouses', $WarehouseId, 'settings', 'sqlAudit', 'setAuditActionsAndGroups')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            # The request body is a bare JSON array of action/group names.
            $bodyJson = $AuditActionsAndGroups | ConvertTo-Json -Depth 10 -AsArray
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Warehouse '$WarehouseId'", "Set $($AuditActionsAndGroups.Count) audit action(s)/group(s)")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "SQL audit actions and groups for warehouse '$WarehouseId' set successfully." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to set SQL audit actions and groups for warehouse '$WarehouseId'. Error: $errorDetails" -Level Error
        }
    }
}
