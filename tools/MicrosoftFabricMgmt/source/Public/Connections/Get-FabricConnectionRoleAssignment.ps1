<#
.SYNOPSIS
    Lists the role assignments on a Fabric connection, or retrieves a single one by id.

.DESCRIPTION
    The Get-FabricConnectionRoleAssignment function retrieves the role assignments of a connection
    via `GET /connections/{connectionId}/roleAssignments`, or a single assignment via
    `GET /connections/{connectionId}/roleAssignments/{connectionRoleAssignmentId}` when
    -ConnectionRoleAssignmentId is supplied. Results are auto-paginated.

    By default each assignment is stamped with the owning ConnectionId and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER ConnectionId
    The unique identifier of the connection whose role assignments are listed. Mandatory. Binds from
    the pipeline via the 'id' alias.

.PARAMETER ConnectionRoleAssignmentId
    The unique identifier of a single role assignment to retrieve. When omitted, all assignments are
    listed.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricConnectionRoleAssignment -ConnectionId "abc123"

    Lists all role assignments on the connection.

.EXAMPLE
    Get-FabricConnectionRoleAssignment -ConnectionId "abc123" -ConnectionRoleAssignmentId "ra1"

    Retrieves the single role assignment with the specified id.

.OUTPUTS
    System.Object
    Role assignment object(s) with all API-returned properties (id, principal, role) plus the owning
    ConnectionId when enriched.

.NOTES
    - API Endpoint: GET /connections/{connectionId}/roleAssignments (+ /{connectionRoleAssignmentId})
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricConnectionRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ConnectionId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionRoleAssignmentId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = if ($ConnectionRoleAssignmentId) {
                New-FabricAPIUri -Resource 'connections' -ResourceId $ConnectionId -Subresource 'roleAssignments' -ItemId $ConnectionRoleAssignmentId
            }
            else {
                New-FabricAPIUri -Resource 'connections' -ResourceId $ConnectionId -Subresource 'roleAssignments'
            }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No role assignments found for connection '$ConnectionId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            foreach ($assignment in $response) {
                $assignment | Add-Member -NotePropertyName 'ConnectionId' -NotePropertyValue $ConnectionId -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.ConnectionRoleAssignment'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve role assignments for connection '$ConnectionId'. Error: $errorDetails" -Level Error
        }
    }
}
