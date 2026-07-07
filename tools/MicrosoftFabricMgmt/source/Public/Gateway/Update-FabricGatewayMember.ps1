<#
.SYNOPSIS
    Updates a member gateway within a Fabric gateway cluster.

.DESCRIPTION
    The Update-FabricGatewayMember function updates a gateway member via
    `PATCH /gateways/{gatewayId}/members/{gatewayMemberId}`. Only the supplied properties are sent.

.PARAMETER GatewayId
    The unique identifier of the gateway that owns the member. Mandatory.

.PARAMETER GatewayMemberId
    The unique identifier of the member gateway to update. Mandatory. Binds from the pipeline by
    property name via the 'id' alias.

.PARAMETER DisplayName
    The new display name for the member gateway.

.PARAMETER Enabled
    Whether the member gateway is enabled.

.EXAMPLE
    Update-FabricGatewayMember -GatewayId $gw -GatewayMemberId $member -Enabled $false

    Disables the specified member gateway.

.OUTPUTS
    System.Object
    The updated member object returned by the API.

.NOTES
    - API Endpoint: PATCH /gateways/{gatewayId}/members/{gatewayMemberId}
    - Requires: authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Update-FabricGatewayMember {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$GatewayMemberId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter()]
        [bool]$Enabled
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Resource 'gateways' -ResourceId $GatewayId -Subresource 'members' -ItemId $GatewayMemberId
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{}
            if ($PSBoundParameters.ContainsKey('DisplayName')) { $body.displayName = $DisplayName }
            if ($PSBoundParameters.ContainsKey('Enabled')) { $body.enabled = $Enabled }

            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Patch'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Member '$GatewayMemberId' on gateway '$GatewayId'", "Update gateway member")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Gateway member '$GatewayMemberId' updated successfully in gateway '$GatewayId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to update gateway member '$GatewayMemberId'. Error: $errorDetails" -Level Error
        }
    }
}
