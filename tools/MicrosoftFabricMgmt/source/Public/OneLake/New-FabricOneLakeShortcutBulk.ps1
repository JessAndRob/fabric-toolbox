<#
.SYNOPSIS
    Creates multiple OneLake shortcuts in a single bulk request.

.DESCRIPTION
    The New-FabricOneLakeShortcutBulk function creates a batch of shortcuts under an item via
    `POST /workspaces/{workspaceId}/items/{itemId}/shortcuts/bulkCreate`. Each shortcut request in
    -CreateShortcutRequest is a hashtable matching the CreateShortcut schema (path, name, target).

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the item. Mandatory.

.PARAMETER ItemId
    The unique identifier of the item to create the shortcuts under. Mandatory. Binds from the
    pipeline via the 'id' alias.

.PARAMETER CreateShortcutRequest
    An array of shortcut request hashtables (each with path, name, and target). Mandatory.

.PARAMETER ShortcutConflictPolicy
    Optional policy for handling name conflicts (e.g. Abort, GenerateUniqueName, CreateOrOverwrite).

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    $reqs = @(
        @{ path = 'Files'; name = 'sc1'; target = @{ oneLake = @{ workspaceId = $ws; itemId = $lh; path = 'Tables/t1' } } }
    )
    New-FabricOneLakeShortcutBulk -WorkspaceId $ws -ItemId $lh -CreateShortcutRequest $reqs

    Creates the shortcuts in bulk under the item.

.OUTPUTS
    System.Object
    The API response (the created shortcuts, or completed long-running operation result).

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/items/{itemId}/shortcuts/bulkCreate
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function New-FabricOneLakeShortcutBulk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$ItemId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable[]]$CreateShortcutRequest,

        [Parameter()]
        [ValidateSet('Abort', 'GenerateUniqueName', 'CreateOrOverwrite')]
        [string]$ShortcutConflictPolicy,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', $ItemId, 'shortcuts', 'bulkCreate')
            if ($ShortcutConflictPolicy) {
                $apiEndpointURI = "{0}?shortcutConflictPolicy={1}" -f $apiEndpointURI, $ShortcutConflictPolicy
            }
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                createShortcutRequests = $CreateShortcutRequest
            }

            $bodyJson = $body | ConvertTo-Json -Depth 20
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Item '$ItemId'", "Bulk create $($CreateShortcutRequest.Count) shortcut(s)")) {
                $response = Invoke-FabricAPIRequest @apiParams

                if ($Raw) {
                    return $response
                }

                Write-FabricLog -Message "Bulk created $($CreateShortcutRequest.Count) shortcut(s) under item '$ItemId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to bulk create shortcuts under item '$ItemId'. Error: $errorDetails" -Level Error
        }
    }
}
