<#
.SYNOPSIS
    Retrieves the SQL audit settings of a Fabric warehouse.

.DESCRIPTION
    The Get-FabricWarehouseSqlAudit function retrieves the SQL audit settings of a warehouse via
    `GET /workspaces/{workspaceId}/warehouses/{itemId}/settings/sqlAudit`, including the audit state,
    retention, and the configured audit actions and groups.

    By default the result is enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the warehouse. Mandatory.

.PARAMETER WarehouseId
    The unique identifier of the warehouse. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricWarehouseSqlAudit -WorkspaceId $ws -WarehouseId $wh

    Returns the SQL audit settings for the warehouse.

.OUTPUTS
    System.Object
    The SQL audit settings object (state, retentionDays, auditActionsAndGroups) plus a resolved
    WorkspaceName when enriched.

.NOTES
    - API Endpoint: GET /workspaces/{workspaceId}/warehouses/{itemId}/settings/sqlAudit
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricWarehouseSqlAudit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$WarehouseId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'warehouses', $WarehouseId, 'settings', 'sqlAudit')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No SQL audit settings found for warehouse '$WarehouseId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            $workspaceName = $WorkspaceId
            try { $workspaceName = Resolve-FabricWorkspaceName -WorkspaceId $WorkspaceId }
            catch { $workspaceName = $WorkspaceId }

            foreach ($setting in $response) {
                $setting | Add-Member -NotePropertyName 'workspaceId'   -NotePropertyValue $WorkspaceId   -Force
                $setting | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.SqlAuditSettings'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve SQL audit settings for warehouse '$WarehouseId'. Error: $errorDetails" -Level Error
        }
    }
}
