<#
.SYNOPSIS
    Lists the role assignments of a Fabric domain.

.DESCRIPTION
    The Get-FabricDomainRoleAssignment function retrieves the role assignments (admins and
    contributors) of a domain via `GET /admin/domains/{domainId}/roleAssignments`. Results are
    auto-paginated. Requires Fabric administrator permissions.

    By default each assignment is stamped with the owning DomainId and decorated for the custom
    table view. Pass -Raw to return the untouched API response.

.PARAMETER DomainId
    The unique identifier of the domain whose role assignments are listed. Mandatory. Binds from the
    pipeline via the 'id' alias.

.PARAMETER Raw
    If specified, returns the untouched API response with no added properties or type decoration.

.EXAMPLE
    Get-FabricDomainRoleAssignment -DomainId $domain

    Lists the admins and contributors assigned to the domain.

.OUTPUTS
    System.Object
    Role assignment object(s) with all API-returned properties plus the owning DomainId when enriched.

.NOTES
    - API Endpoint: GET /admin/domains/{domainId}/roleAssignments
    - Requires: Fabric administrator; authentication via Connect-FabricAccount / Set-FabricApiHeaders.

    Author: Tiago Balabuch, Jess Pomfret, Rob Sewell
#>
function Get-FabricDomainRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [string]$DomainId,

        [Parameter()]
        [switch]$Raw
    )

    process {
        try {
            Invoke-FabricAuthCheck -ThrowOnFailure

            $apiEndpointURI = New-FabricAPIUri -Segments @('admin', 'domains', $DomainId, 'roleAssignments')
            Write-FabricLog -Message "API Endpoint: $apiEndpointURI" -Level Debug

            $apiParams = @{
                BaseURI = $apiEndpointURI
                Headers = $script:FabricAuthContext.FabricHeaders
                Method  = 'Get'
            }
            $response = Invoke-FabricAPIRequest @apiParams

            if (-not $response) {
                Write-FabricLog -Message "No role assignments found for domain '$DomainId'." -Level Warning
                return $null
            }

            if ($Raw) {
                return $response
            }

            foreach ($assignment in $response) {
                $assignment | Add-Member -NotePropertyName 'DomainId' -NotePropertyValue $DomainId -Force
            }

            $response | Add-FabricTypeName -TypeName 'MicrosoftFabric.DomainRoleAssignment'
            $response
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-FabricLog -Message "Failed to retrieve role assignments for domain '$DomainId'. Error: $errorDetails" -Level Error
        }
    }
}
