<#
.SYNOPSIS
    Updates the SQL audit settings of a Fabric SQL endpoint.

.DESCRIPTION
    The Update-FabricSQLEndpointSqlAudit function updates the SQL audit state and/or retention of a
    SQL endpoint via `PATCH /workspaces/{workspaceId}/sqlEndpoints/{itemId}/settings/sqlAudit`. Only
    the supplied properties are sent. To change the audited actions and groups, use
    Set-FabricSQLEndpointSqlAuditActionsAndGroups.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the SQL endpoint. Mandatory.

.PARAMETER SQLEndpointId
    The unique identifier of the SQL endpoint. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER State
    The audit state to set: Enabled or Disabled.

.PARAMETER RetentionDays
    The number of days to retain audit logs.

.EXAMPLE
    Update-FabricSQLEndpointSqlAudit -WorkspaceId $ws -SQLEndpointId $ep -State Enabled -RetentionDays 30

    Enables SQL auditing with a 30-day retention.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: PATCH /workspaces/{workspaceId}/sqlEndpoints/{itemId}/settings/sqlAudit
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricSQLEndpointSqlAudit {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$SQLEndpointId,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled')]
        [string]$State,

        [Parameter()]
        [int]$RetentionDays
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'sqlEndpoints', $SQLEndpointId, 'settings', 'sqlAudit')
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

            if ($PSCmdlet.ShouldProcess("SQL endpoint '$SQLEndpointId'", "Update SQL audit settings")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "SQL audit settings for SQL endpoint '$SQLEndpointId' updated successfully." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update SQL audit settings for SQL endpoint '$SQLEndpointId'. Error: $errorDetails" -Level Error
        }
    }
}
