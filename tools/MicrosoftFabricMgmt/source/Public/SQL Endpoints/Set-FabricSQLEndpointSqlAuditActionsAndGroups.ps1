<#
.SYNOPSIS
    Sets the audited actions and groups for a Fabric SQL endpoint.

.DESCRIPTION
    The Set-FabricSQLEndpointSqlAuditActionsAndGroups function replaces the set of audited actions
    and action groups for a SQL endpoint via
    `POST /workspaces/{workspaceId}/sqlEndpoints/{itemId}/settings/sqlAudit/setAuditActionsAndGroups`.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the SQL endpoint. Mandatory.

.PARAMETER SQLEndpointId
    The unique identifier of the SQL endpoint. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER AuditActionsAndGroups
    The array of audit action and action-group names to set (e.g.
    'BATCH_COMPLETED_GROUP', 'FAILED_DATABASE_AUTHENTICATION_GROUP'). Mandatory.

.EXAMPLE
    Set-FabricSQLEndpointSqlAuditActionsAndGroups -WorkspaceId $ws -SQLEndpointId $ep -AuditActionsAndGroups 'BATCH_COMPLETED_GROUP'

    Sets the SQL endpoint to audit the batch-completed group.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/sqlEndpoints/{itemId}/settings/sqlAudit/setAuditActionsAndGroups
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Set-FabricSQLEndpointSqlAuditActionsAndGroups {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$SQLEndpointId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$AuditActionsAndGroups
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'sqlEndpoints', $SQLEndpointId, 'settings', 'sqlAudit', 'setAuditActionsAndGroups')
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

            if ($PSCmdlet.ShouldProcess("SQL endpoint '$SQLEndpointId'", "Set $($AuditActionsAndGroups.Count) audit action(s)/group(s)")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "SQL audit actions and groups for SQL endpoint '$SQLEndpointId' set successfully." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to set SQL audit actions and groups for SQL endpoint '$SQLEndpointId'. Error: $errorDetails" -Level Error
        }
    }
}
