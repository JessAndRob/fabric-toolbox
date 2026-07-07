<#
.SYNOPSIS
    Updates the SQL audit settings of a Fabric warehouse.

.DESCRIPTION
    The Update-FabricWarehouseSqlAudit function updates the SQL audit state and/or retention of a
    warehouse via `PATCH /workspaces/{workspaceId}/warehouses/{itemId}/settings/sqlAudit`. Only the
    supplied properties are sent. To change the audited actions and groups, use
    Set-FabricWarehouseSqlAuditActionsAndGroups.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the warehouse. Mandatory.

.PARAMETER WarehouseId
    The unique identifier of the warehouse. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER State
    The audit state to set: Enabled or Disabled.

.PARAMETER RetentionDays
    The number of days to retain audit logs.

.EXAMPLE
    Update-FabricWarehouseSqlAudit -WorkspaceId $ws -WarehouseId $wh -State Enabled -RetentionDays 30

    Enables SQL auditing with a 30-day retention.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: PATCH /workspaces/{workspaceId}/warehouses/{itemId}/settings/sqlAudit
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricWarehouseSqlAudit {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WarehouseId,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled')]
        [string]$State,

        [Parameter()]
        [int]$RetentionDays
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'warehouses', $WarehouseId, 'settings', 'sqlAudit')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{}
            if ($PSBoundParameters.ContainsKey('State')) { $body.state = $State }
            if ($PSBoundParameters.ContainsKey('RetentionDays')) { $body.retentionDays = $RetentionDays }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Patch'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Warehouse '$WarehouseId'", "Update SQL audit settings")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "SQL audit settings for warehouse '$WarehouseId' updated successfully." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update SQL audit settings for warehouse '$WarehouseId'. Error: $errorDetails" -Level Error
        }
    }
}
