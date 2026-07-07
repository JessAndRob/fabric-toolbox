<#
.SYNOPSIS
    Moves multiple Fabric items into a workspace folder in one request.

.DESCRIPTION
    The Move-FabricItemBulk function moves a set of items to a target folder via
    `POST /workspaces/{workspaceId}/items/bulkMove`. Omit -TargetFolderId to move the items to the
    workspace root.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the items. Mandatory.

.PARAMETER ItemId
    One or more item identifiers to move. Mandatory. Accepts an array and binds from the pipeline via
    the 'id' alias.

.PARAMETER TargetFolderId
    The unique identifier of the destination folder. When omitted, the items move to the workspace root.

.PARAMETER Raw
    If specified, returns the untouched API response.

.EXAMPLE
    Move-FabricItemBulk -WorkspaceId $ws -ItemId $id1, $id2 -TargetFolderId $folder

    Moves both items into the specified folder.

.EXAMPLE
    Get-FabricItem -WorkspaceId $ws | Where-Object type -eq 'Report' | Move-FabricItemBulk -WorkspaceId $ws -TargetFolderId $folder

    Moves every report into the target folder in a single bulk request.

.OUTPUTS
    System.Object
    The API response (or completed long-running operation result).

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/items/bulkMove
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Move-FabricItemBulk {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string[]]$ItemId,

        [Parameter()]
        [string]$TargetFolderId,

        [Parameter()]
        [switch]$Raw
    )

    begin {
        $collectedIds = [System.Collections.Generic.List[string]]::new()
    }

    process {
        foreach ($id in $ItemId) {
            $collectedIds.Add($id)
        }
    }

    end {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'items', 'bulkMove')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{
                items = @($collectedIds | ForEach-Object { @{ id = $_ } })
            }
            if ($PSBoundParameters.ContainsKey('TargetFolderId')) { $body.targetFolderId = $TargetFolderId }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("$($collectedIds.Count) item(s) in workspace '$WorkspaceId'", "Bulk move items")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "$($collectedIds.Count) item(s) moved successfully." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to bulk move items. Error: $errorDetails" -Level Error
        }
    }
}
