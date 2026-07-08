<#
.SYNOPSIS
    Propagates a Fabric domain's role assignments to its subdomains.

.DESCRIPTION
    The Sync-FabricDomainRoleAssignment function syncs the role assignments of the specified role from
    a parent domain down to all of its subdomains via
    `POST /admin/domains/{domainId}/roleAssignments/syncToSubdomains`. Requires Fabric administrator
    permissions.

.PARAMETER DomainId
    The unique identifier of the parent domain. Mandatory. Binds from the pipeline via the 'id' alias.

.PARAMETER Role
    The role whose assignments are synced to subdomains: Admin or Contributor. Mandatory.

.EXAMPLE
    Sync-FabricDomainRoleAssignment -DomainId $domain -Role Admin

    Propagates the domain's admin role assignments to all subdomains.

.OUTPUTS
    System.Object
    The API response.

.NOTES
    - API Endpoint: POST /admin/domains/{domainId}/roleAssignments/syncToSubdomains
    - Requires: Fabric administrator; authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Sync-FabricDomainRoleAssignment {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$DomainId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Admin', 'Contributor')]
        [string]$Role
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('admin', 'domains', $DomainId, 'roleAssignments', 'syncToSubdomains')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $body = @{ role = $Role }
            $bodyJson = $body | ConvertTo-Json -Depth 10
            Write-FabricLog -Message "Request Body: $bodyJson" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Post'
                Body    = $bodyJson
            }

            if ($PSCmdlet.ShouldProcess("Domain '$DomainId'", "Sync '$Role' role assignments to subdomains")) {
                $response = Invoke-FabricAPIRequest @apiParams
                Write-FabricLog -Message "Synced '$Role' role assignments to subdomains of domain '$DomainId'." -Level Host
                $response
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to sync role assignments for domain '$DomainId'. Error: $errorDetails" -Level Error
        }
    }
}
