#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
param(
    $ModuleName = "MicrosoftFabricMgmt",
$expectedParams = @(
    "WorkspaceId"
    "Raw"
    "ProgressAction"
    "Verbose"
    "Debug"
    "ErrorAction"
    "WarningAction"
    "InformationAction"
    "InformationVariable"
    "OutVariable"
    "OutBuffer"
    "PipelineVariable"
    "ErrorVariable"
    "WarningVariable"
)
)

Describe "Get-FabricWorkspaceGitConnection" -Tag "UnitTests" {

    BeforeDiscovery {
        $command = Get-Command -Name Get-FabricWorkspaceGitConnection
        $expected = $expectedParams
    }

    Context "Parameter validation" {
        BeforeAll {
            $command = Get-Command -Name Get-FabricWorkspaceGitConnection
            $expected = $expectedParams
        }

        It "Has parameter: <_>" -ForEach $expected {
            $command | Should -HaveParameter $PSItem
        }

        It "Should have exactly the number of expected parameters $($expected.Count)" {
            $hasparms = $command.Parameters.Values.Name
            #$hasparms.Count | Should -BeExactly $expected.Count
            Compare-Object -ReferenceObject $expected -DifferenceObject $hasparms | Should -BeNullOrEmpty
        }
    }
}

Describe "Get-FabricWorkspaceGitConnection endpoint" -Tag "UnitTests" {

    BeforeAll {
        Get-Module MicrosoftFabricMgmt | Remove-Module -Force -ErrorAction SilentlyContinue
        $BuiltModule   = "$PSScriptRoot/../../output/module/MicrosoftFabricMgmt"
        $ModuleVersion = (Get-ChildItem $BuiltModule -Directory | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1).Name
        Import-Module (Join-Path $BuiltModule "$ModuleVersion/MicrosoftFabricMgmt.psd1") -Force -ErrorAction Stop

        InModuleScope MicrosoftFabricMgmt {
            $script:FabricAuthContext = [pscustomobject]@{
                BaseUrl       = 'https://api.fabric.microsoft.com/v1'
                FabricHeaders = @{ Authorization = 'Bearer test' }
            }
        }
        Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAuthCheck {}
        Mock -ModuleName MicrosoftFabricMgmt Write-FabricLog {}
        Mock -ModuleName MicrosoftFabricMgmt Resolve-FabricWorkspaceName { 'WS' }
        Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
            $global:__capUri    = $BaseURI
            $global:__capMethod = $Method
            [pscustomobject]@{ gitConnectionState = 'ConnectedAndInitialized' }
        }
    }

    AfterAll {
        Remove-Variable -Name __capUri, __capMethod -Scope Global -ErrorAction SilentlyContinue
    }

    It 'GETs the per-workspace git/connection endpoint (not the admin discover endpoint)' {
        $null = Get-FabricWorkspaceGitConnection -WorkspaceId 'ws-1'
        $global:__capUri    | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/git/connection'
        $global:__capMethod | Should -Be 'Get'
    }

    It 'enriches with WorkspaceName and the type name' {
        $r = Get-FabricWorkspaceGitConnection -WorkspaceId 'ws-1'
        $r.WorkspaceName         | Should -Be 'WS'
        $r.PSObject.TypeNames[0] | Should -Be 'MicrosoftFabric.WorkspaceGitConnection'
    }
}
