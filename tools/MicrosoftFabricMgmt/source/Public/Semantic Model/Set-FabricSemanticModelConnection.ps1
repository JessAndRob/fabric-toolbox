<#
.SYNOPSIS
    Binds a Fabric semantic model to a connection.

.DESCRIPTION
    The Set-FabricSemanticModelConnection function binds a semantic model to a data connection via
    `POST /workspaces/{workspaceId}/semanticModels/{semanticModelId}/bindConnection`.

.PARAMETER WorkspaceId
    The unique identifier of the workspace containing the semantic model. Mandatory.

.PARAMETER SemanticModelId
    The unique identifier of the semantic model to bind. Mandatory. Binds from the pipeline via the
    'id' alias.

.PARAMETER ConnectionBinding
    A hashtable describing the connection binding, with 'connectionDetails' (required) and optionally
    'id' and 'connectivityType'. Mandatory.

.EXAMPLE
    $binding = @{ id = $connectionId; connectivityType = 'ShareableCloud'; connectionDetails = @{ ... } }
    Set-FabricSemanticModelConnection -WorkspaceId $ws -SemanticModelId $sm -ConnectionBinding $binding

    Binds the semantic model to the specified connection.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /workspaces/{workspaceId}/semanticModels/{semanticModelId}/bindConnection
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Set-FabricSemanticModelConnection {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$SemanticModelId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$ConnectionBinding
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('workspaces', $WorkspaceId, 'semanticModels', $SemanticModelId, 'bindConnection')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ connectionBinding = $ConnectionBinding }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Semantic model '$SemanticModelId'", "Bind connection")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Connection bound to semantic model '$SemanticModelId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to bind connection to semantic model '$SemanticModelId'. Error: $errorDetails" -Level Error
        }
    }
}
