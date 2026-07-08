#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Import-FabricEnvironmentStagingExternalLibrary (octet-stream upload). #>

BeforeAll {
    Get-Module MicrosoftFabricMgmt | Remove-Module -Force -ErrorAction SilentlyContinue
    $BuiltModule   = "$PSScriptRoot/../../output/module/MicrosoftFabricMgmt"
    $ModuleVersion = (Get-ChildItem $BuiltModule -Directory | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1).Name
    Import-Module (Join-Path $BuiltModule "$ModuleVersion/MicrosoftFabricMgmt.psd1") -Force -ErrorAction Stop
    InModuleScope MicrosoftFabricMgmt {
        $script:FabricAuthContext = [pscustomobject]@{ BaseUrl = 'https://api.fabric.microsoft.com/v1'; FabricHeaders = @{ Authorization = 'Bearer test' } }
    }
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAuthCheck {}
    Mock -ModuleName MicrosoftFabricMgmt Write-FabricLog {}
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest {
        $global:__capUri = $BaseURI; $global:__capMethod = $Method; $global:__capContentType = $ContentType; $global:__capBody = $Body
    }
    $script:tmpFile = Join-Path ([System.IO.Path]::GetTempPath()) ("reqs_{0}.txt" -f ([guid]::NewGuid().ToString('N')))
    Set-Content -Path $script:tmpFile -Value "numpy==1.26.0`npandas==2.2.0" -Encoding utf8
}
AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capContentType, __capBody -Scope Global -ErrorAction SilentlyContinue
    if ($script:tmpFile -and (Test-Path $script:tmpFile)) { Remove-Item $script:tmpFile -Force -ErrorAction SilentlyContinue }
}

Describe 'Import-FabricEnvironmentStagingExternalLibrary' -Tag 'UnitTests' {
    It 'POSTs the file as octet-stream to the importExternalLibraries endpoint' {
        $null = Import-FabricEnvironmentStagingExternalLibrary -WorkspaceId 'ws-1' -EnvironmentId 'env-1' -FilePath $script:tmpFile -Confirm:$false
        $global:__capUri         | Should -Be 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/environments/env-1/staging/libraries/importExternalLibraries'
        $global:__capMethod      | Should -Be 'Post'
        $global:__capContentType | Should -Be 'application/octet-stream'
        $global:__capBody        | Should -Match 'numpy'
    }
    It 'rejects a non-existent file' {
        { Import-FabricEnvironmentStagingExternalLibrary -WorkspaceId 'ws-1' -EnvironmentId 'env-1' -FilePath 'X:\does\not\exist.txt' -Confirm:$false } | Should -Throw
    }
}
