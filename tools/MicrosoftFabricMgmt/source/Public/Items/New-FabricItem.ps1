<#
.SYNOPSIS
    Creates a new Fabric item of any type in a workspace.

.DESCRIPTION
    The New-FabricItem function creates an item via `POST /workspaces/{workspaceId}/items`. This is
    the generic creator that works for any item type (use the type-specific New-Fabric* commands
    when you need type-specific conveniences). An optional definition and creation payload can be
    supplied for types that require them.

    The created item is returned enriched with a resolved WorkspaceName and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER WorkspaceId
    The unique identifier of the workspace to create the item in. Mandatory.

.PARAMETER DisplayName
    The display name for the new item. Mandatory.

.PARAMETER Type
    The item type (e.g. Notebook, Lakehouse, Report). Mandatory. Additional types may be added by
    Fabric over time, so this is not restricted to a fixed set.

.PARAMETER Description
    An optional description for the item.

.PARAMETER FolderId
    Optional workspace folder id to create the item inside.

.PARAMETER Definition
    Optional item definition hashtable (with 'format' and 'parts'). Required by some item types.

.PARAMETER CreationPayload
    Optional type-specific creation payload hashtable.

.PARAMETER SensitivityLabelSettings
    Optional sensitivity label settings hashtable.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    New-FabricItem -WorkspaceId $ws -DisplayName 'My Lakehouse' -Type Lakehouse

    Creates a Lakehouse in the workspace.

.EXAMPLE
    New-FabricItem -WorkspaceId $ws -DisplayName 'Report1' -Type Report -Definition $def

    Creates a Report from a supplied definition payload.

.OUTPUTS
    System.Object
    The created item object with all API-returned properties plus a resolved WorkspaceName.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/items
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function New-FabricItem {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Type,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FolderId,

        [Parameter()]
        [hashtable]$Definition,

        [Parameter()]
        [hashtable]$CreationPayload,

        [Parameter()]
        [hashtable]$SensitivityLabelSettings,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                displayName = $DisplayName
                type        = $Type
            }
            if ($PSBoundParameters.ContainsKey('Description')) { $body.description = $Description }
            if ($FolderId) { $body.folderId = $FolderId }
            if ($Definition) { $body.definition = $Definition }
            if ($CreationPayload) { $body.creationPayload = $CreationPayload }
            if ($SensitivityLabelSettings) { $body.sensitivityLabelSettings = $SensitivityLabelSettings }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess($DisplayName, "Create Fabric $Type")) {
                $response = Invoke-FabricAPIRequest @apiParams

                if (-not $response) {
                    Write-FabricLog -Message "No response returned after creating item '$DisplayName'." -Level Warning
                    return $null
                }

                if ($Raw) {
                    return $response
                }

                $workspaceName = $WorkspaceId
                try { $workspaceName = Resolve-FabricWorkspaceName -WorkspaceId $WorkspaceId }
                catch { $workspaceName = $WorkspaceId }
                $response | Add-Member -NotePropertyName 'WorkspaceName' -NotePropertyValue $workspaceName -Force

                $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.Item'
                Write-FabricLog -Message "Item '$DisplayName' created successfully!" -Level Host
                return $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to create item '$DisplayName'. Error: $errorDetails" -Level Error
        }
    }
}
