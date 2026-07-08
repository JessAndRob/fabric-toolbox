#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.0"}
<# Behavior tests for Set-FabricApacheAirflowJobFile (PUT octet-stream). #>

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
    Mock -ModuleName MicrosoftFabricMgmt Invoke-FabricAPIRequest { $global:__capUri = $BaseURI; $global:__capMethod = $Method; $global:__capContentType = $ContentType; $global:__capBody = $Body }
    $script:tmpFile = Join-Path ([System.IO.Path]::GetTempPath()) ("dag_{0}.py" -f ([guid]::NewGuid().ToString('N')))
    Set-Content -Path $script:tmpFile -Value "print('hello')" -Encoding utf8
}
AfterAll {
    Remove-Variable -Name __capUri, __capMethod, __capContentType, __capBody -Scope Global -ErrorAction SilentlyContinue
    if ($script:tmpFile -and (Test-Path $script:tmpFile)) { Remove-Item $script:tmpFile -Force -ErrorAction SilentlyContinue }
}

Describe 'Set-FabricApacheAirflowJobFile' -Tag 'UnitTests' {
    It 'PUTs the file as octet-stream to the files/{filePath} endpoint' {
        $null = Set-FabricApacheAirflowJobFile -WorkspaceId 'ws-1' -ApacheAirflowJobId 'job-1' -FilePath 'dags/x.py' -SourceFile $script:tmpFile -Confirm:$false
        $global:__capUri         | Should -BeLike 'https://api.fabric.microsoft.com/v1/workspaces/ws-1/ApacheAirflowJobs/job-1/files/dags/x.py*'
        $global:__capMethod      | Should -Be 'Put'
        $global:__capContentType | Should -Be 'application/octet-stream'
        $global:__capBody        | Should -Match 'hello'
    }
}
