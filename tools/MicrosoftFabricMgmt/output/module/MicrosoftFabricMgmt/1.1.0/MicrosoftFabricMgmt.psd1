@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'MicrosoftFabricMgmt.psm1'

    # Version number of this module.
    ModuleVersion        = '1.1.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Core')

    # ID used to uniquely identify this module
    GUID                 = 'd0110b5c-cfcc-4bcc-8049-468880cf66c8'

    # Author of this module
    Author               = 'Rob Sewell, Jess Pomfret and Tiago Balabuch on behalf of Fabric Community'

    # Company or vendor of this module
    CompanyName          = 'Microsoft Fabric Mgmt by Fabric Toolbox'

    # Copyright statement for this module
    Copyright            = '2026 Microsoft Fabric Mgmt by Fabric Toolbox'

    # Description of the functionality provided by this module
    Description          = 'PowerShell module for managing Microsoft Fabric resources via the Fabric API. Supports workspaces, lakehouses, warehouses, notebooks, and more.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '7.0'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @(
        @{ ModuleName = 'PSFramework'; ModuleVersion = '1.12.345' },
        @{ ModuleName = 'Az.Accounts'; ModuleVersion = '5.0.0' },
        @{ ModuleName = 'Az.Resources'; ModuleVersion = '6.15.1' },
        @{ ModuleName = 'MicrosoftPowerBIMgmt'; ModuleVersion = '1.2.1111' }
    )


    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess     = @('MicrosoftFabricMgmt.Format.ps1xml')

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @('Add-FabricAdminCapacityWorkspace','Add-FabricAdminPipelineUser','Add-FabricAdminWorkspaceUser','Export-FabricAdminDataflow','Get-FabricAdminActivityEvent','Get-FabricAdminApp','Get-FabricAdminAppUser','Get-FabricAdminCapacity','Get-FabricAdminCapacityUser','Get-FabricAdminDashboard','Get-FabricAdminDashboardSubscription','Get-FabricAdminDashboardTile','Get-FabricAdminDashboardUser','Get-FabricAdminDataflow','Get-FabricAdminDataflowDatasource','Get-FabricAdminDataflowUpstream','Get-FabricAdminDataflowUser','Get-FabricAdminDataset','Get-FabricAdminDatasetDataflowLink','Get-FabricAdminDatasetDatasource','Get-FabricAdminDatasetUser','Get-FabricAdminEncryptionKey','Get-FabricAdminGateway','Get-FabricAdminGatewayDatasource','Get-FabricAdminGatewayDatasourceById','Get-FabricAdminGatewayInventory','Get-FabricAdminGitConnection','Get-FabricAdminImport','Get-FabricAdminItem','Get-FabricAdminItemUser','Get-FabricAdminModifiedWorkspace','Get-FabricAdminPipeline','Get-FabricAdminPipelineUser','Get-FabricAdminProfile','Get-FabricAdminRefreshable','Get-FabricAdminReport','Get-FabricAdminReportSubscription','Get-FabricAdminReportUser','Get-FabricAdminUserAccess','Get-FabricAdminUserArtifactAccess','Get-FabricAdminUserSubscription','Get-FabricAdminWidelySharedArtifactLink','Get-FabricAdminWidelySharedArtifactWeb','Get-FabricAdminWorkspace','Get-FabricAdminWorkspaceScanResult','Get-FabricAdminWorkspaceScanStatus','Get-FabricAdminWorkspaceUnusedArtifact','Get-FabricAdminWorkspaceUser','New-FabricAdminEncryptionKey','Remove-FabricAdminCapacityWorkspace','Remove-FabricAdminInformationProtectionLabel','Remove-FabricAdminPipelineUser','Remove-FabricAdminProfile','Remove-FabricAdminWorkspaceUser','Restore-FabricAdminWorkspace','Set-FabricAdminInformationProtectionLabel','Start-FabricAdminEncryptionKeyRotation','Start-FabricAdminWorkspaceScan','Update-FabricAdminCapacity','Update-FabricAdminPipelineUser','Update-FabricAdminWorkspace','Get-FabricAnomalyDetector','Get-FabricAnomalyDetectorDefinition','New-FabricAnomalyDetector','Remove-FabricAnomalyDetector','Update-FabricAnomalyDetector','Update-FabricAnomalyDetectorDefinition','Get-FabricApacheAirflowJob','Get-FabricApacheAirflowJobDefinition','New-FabricApacheAirflowJob','Remove-FabricApacheAirflowJob','Update-FabricApacheAirflowJob','Update-FabricApacheAirflowJobDefinition','Get-FabricCapacity','Add-FabricConnectionRoleAssignment','Get-FabricConnection','Get-FabricConnectionRoleAssignment','Get-FabricConnectionSupportedType','New-FabricConnection','Remove-FabricConnection','Remove-FabricConnectionRoleAssignment','Update-FabricConnection','Update-FabricConnectionRoleAssignment','Get-FabricCopyJob','Get-FabricCopyJobDefinition','New-FabricCopyJob','Remove-FabricCopyJob','Update-FabricCopyJob','Update-FabricCopyJobDefinition','Get-FabricCosmosDBDatabase','Get-FabricCosmosDBDatabaseDefinition','New-FabricCosmosDBDatabase','Remove-FabricCosmosDBDatabase','Update-FabricCosmosDBDatabase','Update-FabricCosmosDBDatabaseDefinition','Get-FabricDashboard','Get-FabricDataPipeline','Get-FabricDataPipelineDefinition','New-FabricDataPipeline','Remove-FabricDataPipeline','Update-FabricDataPipeline','Update-FabricDataPipelineDefinition','Get-FabricDataflow','Get-FabricDataflowDefinition','Get-FabricDataflowParameter','Invoke-FabricDataflowQuery','New-FabricDataflow','New-FabricDataflowJobSchedule','Remove-FabricDataflow','Start-FabricDataflowJob','Update-FabricDataflow','Update-FabricDataflowDefinition','Get-FabricDatamart','Add-FabricDeploymentPipelineRoleAssignment','Add-FabricDeploymentPipelineStageWorkspace','Get-FabricDeploymentPipeline','Get-FabricDeploymentPipelineOperation','Get-FabricDeploymentPipelineRoleAssignment','Get-FabricDeploymentPipelineStage','Get-FabricDeploymentPipelineStageItem','Invoke-FabricDeploymentPipelineDeploy','New-FabricDeploymentPipeline','Remove-FabricDeploymentPipeline','Remove-FabricDeploymentPipelineRoleAssignment','Remove-FabricDeploymentPipelineStageWorkspace','Update-FabricDeploymentPipeline','Update-FabricDeploymentPipelineStage','Get-FabricDigitalTwinBuilder','Get-FabricDigitalTwinBuilderDefinition','New-FabricDigitalTwinBuilder','Remove-FabricDigitalTwinBuilder','Update-FabricDigitalTwinBuilder','Update-FabricDigitalTwinBuilderDefinition','Get-FabricDigitalTwinBuilderFlow','Get-FabricDigitalTwinBuilderFlowDefinition','New-FabricDigitalTwinBuilderFlow','Remove-FabricDigitalTwinBuilderFlow','Update-FabricDigitalTwinBuilderFlow','Update-FabricDigitalTwinBuilderFlowDefinition','Add-FabricDomainWorkspaceByCapacity','Add-FabricDomainWorkspaceById','Add-FabricDomainWorkspaceByPrincipal','Add-FabricDomainWorkspaceByRoleAssignment','Get-FabricDomain','Get-FabricDomainRoleAssignment','Get-FabricDomainWorkspace','New-FabricDomain','Remove-FabricDomain','Remove-FabricDomainWorkspace','Remove-FabricDomainWorkspaceRoleAssignment','Sync-FabricDomainRoleAssignment','Update-FabricDomain','Get-FabricEnvironment','Get-FabricEnvironmentDefinition','Get-FabricEnvironmentLibrary','Get-FabricEnvironmentSparkCompute','Get-FabricEnvironmentStagingLibrary','Get-FabricEnvironmentStagingSparkCompute','Import-FabricEnvironmentStagingLibrary','New-FabricEnvironment','Publish-FabricEnvironment','Remove-FabricEnvironment','Remove-FabricEnvironmentStagingLibrary','Stop-FabricEnvironmentPublish','Update-FabricEnvironment','Update-FabricEnvironmentDefinition','Update-FabricEnvironmentStagingSparkCompute','Get-FabricEventSchemaSet','Get-FabricEventSchemaSetDefinition','New-FabricEventSchemaSet','Remove-FabricEventSchemaSet','Update-FabricEventSchemaSet','Update-FabricEventSchemaSetDefinition','Get-FabricEventhouse','Get-FabricEventhouseDefinition','New-FabricEventhouse','Remove-FabricEventhouse','Update-FabricEventhouse','Update-FabricEventhouseDefinition','Get-FabricEventstream','Get-FabricEventstreamDefinition','Get-FabricEventstreamDestination','Get-FabricEventstreamDestinationConnection','Get-FabricEventstreamSource','Get-FabricEventstreamSourceConnection','Get-FabricEventstreamTopology','New-FabricEventstream','Remove-FabricEventstream','Resume-FabricEventstream','Resume-FabricEventstreamDestination','Resume-FabricEventstreamSource','Suspend-FabricEventstream','Suspend-FabricEventstreamDestination','Suspend-FabricEventstreamSource','Update-FabricEventstream','Update-FabricEventstreamDefinition','Approve-FabricExternalDataShareInvitation','Get-FabricExternalDataShare','Get-FabricExternalDataShareInvitation','Get-FabricItemExternalDataShare','New-FabricExternalDataShare','Remove-FabricExternalDataShare','Revoke-FabricExternalDataShare','Get-FabricFolder','Move-FabricFolder','New-FabricFolder','Remove-FabricFolder','Update-FabricFolder','Add-FabricGatewayRoleAssignment','Get-FabricGateway','Get-FabricGatewayMember','Get-FabricGatewayRoleAssignment','New-FabricGateway','Remove-FabricGateway','Remove-FabricGatewayMember','Remove-FabricGatewayRoleAssignment','Update-FabricGateway','Update-FabricGatewayMember','Update-FabricGatewayRoleAssignment','Connect-FabricWorkspaceGit','Disconnect-FabricWorkspaceGit','Get-FabricWorkspaceGitCredential','Get-FabricWorkspaceGitStatus','Initialize-FabricWorkspaceGitConnection','Save-FabricWorkspaceGitCommit','Update-FabricWorkspaceFromGit','Update-FabricWorkspaceGitCredential','Get-FabricGraphModel','Get-FabricGraphModelDefinition','Get-FabricGraphModelQueryableType','Invoke-FabricGraphModelQuery','New-FabricGraphModel','Remove-FabricGraphModel','Start-FabricGraphModelRefresh','Update-FabricGraphModel','Update-FabricGraphModelDefinition','Get-FabricGraphQuerySet','Get-FabricGraphQuerySetDefinition','New-FabricGraphQuerySet','Remove-FabricGraphQuerySet','Update-FabricGraphQuerySet','Update-FabricGraphQuerySetDefinition','Get-FabricGraphQLApi','Get-FabricGraphQLApiDefinition','New-FabricGraphQLApi','Remove-FabricGraphQLApi','Update-FabricGraphQLApi','Update-FabricGraphQLApiDefinition','Add-FabricItemTag','Get-FabricItem','Get-FabricItemConnection','Get-FabricItemDefinition','Move-FabricItem','Move-FabricItemBulk','New-FabricItem','Remove-FabricItem','Remove-FabricItemTag','Update-FabricItem','Update-FabricItemDefinition','Get-FabricItemJobInstance','Get-FabricItemSchedule','New-FabricItemSchedule','Remove-FabricItemSchedule','Start-FabricItemJob','Stop-FabricItemJobInstance','Update-FabricItemSchedule','Get-FabricKQLDashboard','Get-FabricKQLDashboardDefinition','New-FabricKQLDashboard','Remove-FabricKQLDashboard','Update-FabricKQLDashboard','Update-FabricKQLDashboardDefinition','Get-FabricKQLDatabase','Get-FabricKQLDatabaseDefinition','New-FabricKQLDatabase','Remove-FabricKQLDatabase','Update-FabricKQLDatabase','Update-FabricKQLDatabaseDefinition','Get-FabricKQLQueryset','Get-FabricKQLQuerysetDefinition','New-FabricKQLQueryset','Remove-FabricKQLQueryset','Update-FabricKQLQueryset','Update-FabricKQLQuerysetDefinition','Remove-FabricLabel','Set-FabricLabel','Get-FabricLakehouse','Get-FabricLakehouseDefinition','Get-FabricLakehouseLivySession','Get-FabricLakehouseTable','New-FabricLakehouse','New-FabricLakehouseRefreshMaterializedLakeViewsSchedule','Remove-FabricLakehouse','Remove-FabricLakehouseRefreshMaterializedLakeViewsSchedule','Start-FabricLakehouseRefreshMaterializedLakeView','Start-FabricLakehouseTableMaintenance','Update-FabricLakehouse','Update-FabricLakehouseDefinition','Update-FabricLakehouseRefreshMaterializedLakeViewsSchedule','Write-FabricLakehouseTableData','Get-FabricManagedPrivateEndpoint','New-FabricManagedPrivateEndpoint','Remove-FabricManagedPrivateEndpoint','Get-FabricMap','Get-FabricMapDefinition','New-FabricMap','Remove-FabricMap','Update-FabricMap','Update-FabricMapDefinition','Get-FabricAzureDatabricksCatalog','Get-FabricAzureDatabricksSchema','Get-FabricAzureDatabricksTable','Get-FabricMirroredAzureDatabricksCatalog','Get-FabricMirroredAzureDatabricksCatalogDefinition','New-FabricMirroredAzureDatabricksCatalog','Remove-FabricMirroredAzureDatabricksCatalog','Update-FabricMirroredAzureDatabricksCatalog','Update-FabricMirroredAzureDatabricksCatalogDefinition','Update-FabricMirroredAzureDatabricksCatalogMetadata','Get-FabricMirroredDatabase','Get-FabricMirroredDatabaseDefinition','Get-FabricMirroredDatabaseStatus','Get-FabricMirroredDatabaseTableStatus','New-FabricMirroredDatabase','Remove-FabricMirroredDatabase','Start-FabricMirroredDatabaseMirroring','Stop-FabricMirroredDatabaseMirroring','Update-FabricMirroredDatabase','Update-FabricMirroredDatabaseDefinition','Get-FabricMirroredWarehouse','Get-FabricMLExperiment','New-FabricMLExperiment','Remove-FabricMLExperiment','Update-FabricMLExperiment','Disable-FabricMLModelEndpointVersion','Enable-FabricMLModelEndpointVersion','Get-FabricMLModel','Get-FabricMLModelEndpoint','Get-FabricMLModelEndpointVersion','Invoke-FabricMLModelEndpointScore','Invoke-FabricMLModelEndpointVersionScore','New-FabricMLModel','Remove-FabricMLModel','Update-FabricMLModel','Update-FabricMLModelEndpoint','Update-FabricMLModelEndpointVersion','Get-FabricMountedDataFactory','Get-FabricMountedDataFactoryDefinition','New-FabricMountedDataFactory','Remove-FabricMountedDataFactory','Update-FabricMountedDataFactory','Update-FabricMountedDataFactoryDefinition','Get-FabricNotebook','Get-FabricNotebookDefinition','Get-FabricNotebookLivySession','New-FabricNotebook','Remove-FabricNotebook','Update-FabricNotebook','Update-FabricNotebookDefinition','Get-FabricOneLakeDataAccessRole','Get-FabricOneLakeDataAccessSecurity','Get-FabricOneLakeSetting','Get-FabricOneLakeShortcut','New-FabricOneLakeShortcut','New-FabricOneLakeShortcutBulk','Remove-FabricOneLakeShortcut','Reset-FabricOneLakeShortcutCache','Set-FabricOneLakeDataAccessSecurity','Set-FabricOneLakeDiagnostic','Set-FabricOneLakeImmutabilityPolicy','Get-FabricOntology','Get-FabricOntologyDefinition','New-FabricOntology','Remove-FabricOntology','Update-FabricOntology','Update-FabricOntologyDefinition','Get-FabricOperationsAgent','Get-FabricOperationsAgentDefinition','New-FabricOperationsAgent','Remove-FabricOperationsAgent','Update-FabricOperationsAgent','Update-FabricOperationsAgentDefinition','Get-FabricPaginatedReport','Update-FabricPaginatedReport','Get-FabricReflex','Get-FabricReflexDefinition','New-FabricReflex','Remove-FabricReflex','Update-FabricReflex','Update-FabricReflexDefinition','Get-FabricReport','Get-FabricReportDefinition','New-FabricReport','Remove-FabricReport','Update-FabricReport','Update-FabricReportDefinition','Get-FabricSemanticModel','Get-FabricSemanticModelDefinition','New-FabricSemanticModel','Remove-FabricSemanticModel','Set-FabricSemanticModelConnection','Update-FabricSemanticModel','Update-FabricSemanticModelDefinition','Remove-FabricSharingLinks','Remove-FabricSharingLinksBulk','Get-FabricSnowflakeDatabase','Get-FabricSnowflakeDatabaseDefinition','New-FabricSnowflakeDatabase','Remove-FabricSnowflakeDatabase','Update-FabricSnowflakeDatabase','Update-FabricSnowflakeDatabaseDefinition','Get-FabricSparkCustomPool','Get-FabricSparkLivySession','Get-FabricSparkSettings','Get-FabricSparkWorkspaceSettings','New-FabricSparkCustomPool','Remove-FabricSparkCustomPool','Update-FabricSparkCustomPool','Update-FabricSparkSettings','Update-FabricSparkWorkspaceSettings','Get-FabricSparkJobDefinition','Get-FabricSparkJobDefinitionDefinition','Get-FabricSparkJobDefinitionLivySession','New-FabricSparkJobDefinition','Remove-FabricSparkJobDefinition','Start-FabricSparkJobDefinitionOnDemand','Update-FabricSparkJobDefinition','Update-FabricSparkJobDefinitionDefinition','Get-FabricSQLDatabase','Get-FabricSQLDatabaseConnectionString','Get-FabricSQLDatabaseDefinition','New-FabricSQLDatabase','Remove-FabricSQLDatabase','Start-FabricSQLDatabaseMirroring','Stop-FabricSQLDatabaseMirroring','Update-FabricSQLDatabase','Update-FabricSQLDatabaseDefinition','Get-FabricSQLEndpoint','Get-FabricSQLEndpointConnectionString','Get-FabricSQLEndpointSqlAudit','Set-FabricSQLEndpointSqlAuditActionsAndGroups','Update-FabricSQLEndpointMetadata','Update-FabricSQLEndpointSqlAudit','Get-FabricTag','New-FabricTag','Remove-FabricTag','Update-FabricTag','Get-FabricCapacityTenantSettingOverrides','Get-FabricDomainTenantSettingOverrides','Get-FabricTenantSetting','Get-FabricTenantSettingOverridesCapacity','Get-FabricWorkspaceTenantSettingOverrides','Revoke-FabricCapacityTenantSettingOverrides','Update-FabricCapacityTenantSettingOverrides','Update-FabricTenantSetting','Get-FabricUserDataFunction','Get-FabricUserDataFunctionDefinition','New-FabricUserDataFunction','Remove-FabricUserDataFunction','Update-FabricUserDataFunction','Update-FabricUserDataFunctionDefinition','Get-FabricUserListAccessEntities','Clear-FabricNameCache','Connect-FabricAccount','Convert-FromBase64','Convert-ToBase64','Get-FabricLongRunningOperation','Get-FabricLongRunningOperationResult','Invoke-FabricAPIRequest','Resolve-FabricCapacityIdFromWorkspace','Resolve-FabricCapacityName','Resolve-FabricDatasetName','Resolve-FabricGatewayName','Resolve-FabricWorkspaceName','Get-FabricVariableLibrary','Get-FabricVariableLibraryDefinition','New-FabricVariableLibrary','Remove-FabricVariableLibrary','Update-FabricVariableLibrary','Get-FabricWarehouse','Get-FabricWarehouseConnectionString','Get-FabricWarehouseRestorePoint','Get-FabricWarehouseSnapshot','Get-FabricWarehouseSqlAudit','New-FabricWarehouse','New-FabricWarehouseRestorePoint','New-FabricWarehouseSnapshot','Remove-FabricWarehouse','Remove-FabricWarehouseRestorePoint','Remove-FabricWarehouseSnapshot','Restore-FabricWarehouseToRestorePoint','Set-FabricWarehouseSqlAuditActionsAndGroups','Update-FabricWarehouse','Update-FabricWarehouseRestorePoint','Update-FabricWarehouseSnapshot','Update-FabricWarehouseSqlAudit','Add-FabricWorkspaceCapacity','Add-FabricWorkspaceDomain','Add-FabricWorkspaceIdentity','Add-FabricWorkspaceRoleAssignment','Get-FabricWorkspace','Get-FabricWorkspaceAsAdmin','Get-FabricWorkspaceGitConnection','Get-FabricWorkspaceRoleAssignment','New-FabricWorkspace','Remove-FabricWorkspace','Remove-FabricWorkspaceCapacity','Remove-FabricWorkspaceDomain','Remove-FabricWorkspaceIdentity','Remove-FabricWorkspaceRoleAssignment','Update-FabricWorkspace','Update-FabricWorkspaceRoleAssignment','Get-FabricWorkspaceGitOutboundPolicy','Get-FabricWorkspaceNetworkCommunicationPolicy','Get-FabricWorkspaceOutboundConnectionRule','Get-FabricWorkspaceOutboundGatewayRule','Set-FabricWorkspaceGitOutboundPolicy','Set-FabricWorkspaceNetworkCommunicationPolicy','Set-FabricWorkspaceOutboundConnectionRule','Set-FabricWorkspaceOutboundGatewayRule')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = 'FabricConfig'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @('Get-FileDefinitionParts','Assign-FabricDomainWorkspaceByCapacity','Assign-FabricDomainWorkspaceByRoleAssignment','Unassign-FabricDomainWorkspace','Unassign-FabricDomainWorkspaceByRoleAssignment','Get-FabricExternalDataShares','Load-FabricLakehouseTable','Set-FabricApiHeaders','Assign-FabricWorkspaceCapacity')

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/microsoft/fabric-toolbox/blob/main/tools/MicrosoftFabricMgmt/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/microsoft/fabric-toolbox/'

            # A URL to an icon representing this module.
            # IconUri = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = '## [1.1.0] - 2026-07-08

### Added

- **Dataflow query & job schedules** (2 new): `Invoke-FabricDataflowQuery`
  (POST `.../dataflows/{id}/executeQuery` with `-QueryName` / `-CustomMashupDocument`) and
  `New-FabricDataflowJobSchedule` (POST `.../dataflows/{id}/jobs/{Execute|ApplyChanges}/schedules`).
- **Domain role-assignment admin** (2 new): `Get-FabricDomainRoleAssignment`
  (GET `/admin/domains/{id}/roleAssignments`) and `Sync-FabricDomainRoleAssignment`
  (POST `.../roleAssignments/syncToSubdomains`, propagating a role to subdomains).
- **Lakehouse Refresh Materialized Lake Views schedules** (3 new):
  `New`/`Update`/`Remove-FabricLakehouseRefreshMaterializedLakeViewsSchedule`
  (POST/PATCH/DELETE `.../lakehouses/{id}/jobs/RefreshMaterializedLakeViews/schedules[/{scheduleId}]`;
  take `-Enabled` + `-Configuration`, support `-WhatIf`/`-Confirm`).
- **`Set-FabricSemanticModelConnection`** (new): binds a semantic model to a connection via
  POST `.../semanticModels/{id}/bindConnection` (`-ConnectionBinding` hashtable; `-WhatIf`/`-Confirm`).
- **Azure Databricks catalog discovery** (4 new): `Get-FabricAzureDatabricksCatalog` /
  `Get-FabricAzureDatabricksSchema` / `Get-FabricAzureDatabricksTable` (GET
  `.../azuredatabricks/catalogs[/{catalog}/schemas[/{schema}/tables]]`, requiring a
  `-DatabricksWorkspaceConnectionId`, auto-paginated) and
  `Update-FabricMirroredAzureDatabricksCatalogMetadata` (POST `.../refreshCatalogMetadata`,
  long-running). Getters enrich with `WorkspaceName` (+ CatalogName/SchemaName context) and honor `-Raw`.
- **SQL audit commands** (6 new) for SQL endpoints and warehouses:
  `Get-FabricSQLEndpointSqlAudit` / `Update-FabricSQLEndpointSqlAudit` /
  `Set-FabricSQLEndpointSqlAuditActionsAndGroups` and the matching `*WarehouseSqlAudit*` trio
  (GET/PATCH `.../settings/sqlAudit`, POST `.../setAuditActionsAndGroups`). Getters enrich with
  `WorkspaceName` + `MicrosoftFabric.SqlAuditSettings` and honor `-Raw`; PATCH sends only the
  supplied `State`/`RetentionDays`; the actions/groups setter posts a bare string array. Mutating
  commands support `-WhatIf`/`-Confirm`.
- **Lakehouse & environment definition commands** (4 new): `Get-FabricLakehouseDefinition` /
  `Update-FabricLakehouseDefinition` and `Get-FabricEnvironmentDefinition` /
  `Update-FabricEnvironmentDefinition` (POST .../getDefinition and .../updateDefinition,
  long-running). Update commands take a `-Definition` hashtable (`parts` array) and support
  `-UpdateMetadata`, `-WhatIf`/`-Confirm`; getters support `-Format` and `-Raw`.
- **Platform coverage fills** (6 new commands): `Get-FabricConnectionRoleAssignment`
  (GET /connections/{id}/roleAssignments + by-id — completes the connection role-assignment set that
  previously had only Add/Remove/Update), `Get-FabricItemExternalDataShare` (provider-side
  GET .../items/{itemId}/externalDataShares + by-id), `Get-FabricOneLakeSetting`
  (GET .../onelake/settings), `Set-FabricOneLakeDiagnostic` (POST .../onelake/settings/modifyDiagnostics),
  and `Add-FabricWorkspaceDomain` / `Remove-FabricWorkspaceDomain` (workspace-side
  assignToDomain / unassignFromDomain). Getters enrich + decorate and honor `-Raw`; mutating commands
  support `-WhatIf`/`-Confirm`.
- **Generic item operations** (10 new commands) filling the tenant-generic `/workspaces/{ws}/items`
  gaps that had no wrapper: `New-FabricItem` / `Update-FabricItem` / `Remove-FabricItem`
  (create/patch/delete any item type), `Get-FabricItemDefinition` / `Update-FabricItemDefinition`
  (generic definition get/update, long-running), `Move-FabricItem` and `Move-FabricItemBulk`
  (move one or many items to a folder), `Add-FabricItemTag` / `Remove-FabricItemTag`
  (apply/unapply tags by id), and `New-FabricOneLakeShortcutBulk` (bulk shortcut creation).
  Item-returning commands enrich with `WorkspaceName` + `MicrosoftFabric.Item` and honor `-Raw`;
  mutating commands support `-WhatIf`/`-Confirm`.
- **Fabric Gateways API** (11 new commands) covering all 13 `/gateways` endpoints:
  `Get-FabricGateway` (list + by-id), `New-FabricGateway` (virtual network gateways —
  the only type creatable via the API), `Update-FabricGateway` (type-aware body for
  VirtualNetwork / OnPremises), `Remove-FabricGateway`, `Get/Update/Remove-FabricGatewayMember`,
  and `Get/Add/Update/Remove-FabricGatewayRoleAssignment`. Getters enrich with resolved
  `CapacityName` / `GatewayName`, decorate as `MicrosoftFabric.Gateway` / `.GatewayMember` /
  `.GatewayRoleAssignment` (new format views), and honor `-Raw`; mutating commands support
  `-WhatIf`/`-Confirm`. Roles: `Admin`, `ConnectionCreatorWithResharing`, `ConnectionCreator`.
- **`Get-FabricItemConnection`** (new): lists the connections an item depends on via
  `GET /workspaces/{workspaceId}/items/{itemId}/connections` (List Item Connections;
  auto-paginated). Enriches with `WorkspaceName` and `GatewayName` (when gateway-bound),
  the owning item''s `ItemName`/`ResourceType`, and a parsed/flattened `connectionDetails`
  (`ConnectionDetailsParsed` + PascalCased fields such as `Path`/`Type`/`Server`/`Database`);
  decorates as `MicrosoftFabric.Connection`, and honors `-Raw`. Supports the full
  `Get-FabricWorkspace | Get-FabricItem | Get-FabricItemConnection` pipeline — `WorkspaceId`,
  `ItemId`, `ItemName`, and `ItemType` all bind by property name from `Get-FabricItem`.
- **Workspace networking commands** (8 new) filling the remaining platform networking gap
  (all preview, under `/workspaces/{workspaceId}/networking/communicationPolicy/...`):
  `Get/Set-FabricWorkspaceNetworkCommunicationPolicy` (full policy; PUT supports optimistic
  concurrency via `-IfMatch`), `Get/Set-FabricWorkspaceOutboundConnectionRule`,
  `Get/Set-FabricWorkspaceOutboundGatewayRule`, and `Get/Set-FabricWorkspaceGitOutboundPolicy`
  (`-IfMatch`). Getters enrich with `WorkspaceName` + a `MicrosoftFabric.*` type and honor `-Raw`;
  setters take hashtable pass-through bodies and support `-WhatIf`/`-Confirm`.
- **`Set-FabricOneLakeImmutabilityPolicy`** (new): `POST /workspaces/{workspaceId}/onelake/settings/modifyImmutabilityPolicy`;
  `-Scope` (DiagnosticLogs) + `-RetentionDays`; supports `-WhatIf`/`-Confirm` and `-Raw`.
- **`New-FabricSemanticModel`** and **`New-FabricReport`**: new optional `-FolderId` parameter that
  places the newly created item directly inside a workspace folder (resolves
  [#427](https://github.com/microsoft/fabric-toolbox/issues/427)). Maps to the Fabric *Create item*
  API `folderId` request-body property; when omitted, the item is created in the workspace root.

### Fixed

- **`Update-FabricWarehouseSnapshot`** now targets the correct
  `PATCH /workspaces/{workspaceId}/warehousesnapshots/{warehouseSnapshotId}` endpoint. It previously
  built `.../warehouses/{WarehouseId}` from an undefined `$WarehouseId` variable, producing an
  empty/incorrect URL that never updated the snapshot.
- **`Get-FabricWorkspaceGitConnection`** now calls the per-workspace endpoint
  `GET /workspaces/{workspaceId}/git/connection` (returning that workspace''s Git provider/sync/state)
  instead of duplicating the admin discovery endpoint. `WorkspaceId` is now mandatory and pipeline-
  bindable. The tenant-wide admin listing remains available via `Get-FabricAdminGitConnection`.
- **`Get-FabricConnection -ConnectionName` validation**: removed the over-restrictive
  `ValidatePattern(''^[a-zA-Z0-9_ ]*$'')` that rejected valid connection names containing hyphens,
  dots, parentheses, etc. The name is a filter, so it now accepts any string (`ValidateNotNullOrEmpty`),
  matching `New-FabricConnection`. Also corrected the stale `$FabricConfig`/`Test-TokenExpired` note.
- **`Get-FabricAdminWorkspace` filtering**: the `-Filter` parameter (and `-Top`/`-Skip`/`-OrderBy`)
  never worked — the Fabric admin `GET /admin/workspaces` endpoint does not support OData query
  options, so those values were silently ignored. Removed the four phantom parameters and added the
  genuinely-supported `-EncryptionStatus` (auto-sets `-Include encryption`) and `-Include`. Also fixed
  `-WorkspaceName`, which returned nothing because the results were re-filtered client-side on
  `displayName` while the admin API returns `name`; filtering is now server-side via the `name` query
  parameter. Use the named filters (`-CapacityId`/`-WorkspaceName`/`-WorkspaceType`/`-State`/
  `-EncryptionStatus`) or pipe to `Where-Object`/`Select-Object` for client-side work.
- **`scripts/Update-FabricAPISpecsCache.ps1`**: now auto-discovers and downloads the nested
  `./definitions/{name}.json` files each swagger `$ref`s (cached as `{spec}.{name}.definitions.json`)
  — e.g. `platform.workspaceNetworkingPolicy.definitions.json`, connections, deploymentPipelines,
  gitIntegration, externaldatasharing — so the body/response schemas for those operations are
  durably resolvable during validation. 15 nested files fetched (platform, admin, eventstream), 0 failures.
- **`scripts/sync-test-expected-params.ps1` idempotency**: a second run no longer corrupts
  test files. Previously the `param()`-insert fallback ran whenever the regex replacement
  produced no change — including the already-synced case — so re-running duplicated the
  `$expectedParams` block into every synced test file (253 had both a `param()` and the array).
  The branch is now chosen by whether the block exists, the pattern anchors on horizontal
  whitespace so replacement is byte-stable, and the helper (`Set-ExpectedParamsInTest`, renamed
  from the unapproved-verb `Replace-…`) plus the main loop are guarded for dot-source testing.
  New regression suite `tests/Unit/SyncExpectedParams.Tests.ps1`; idempotency also verified
  against the real `tests/Unit` tree (second run: 0 files changed).

### Changed

- **`Get-FabricAdminGatewayDatasource` now unflattens `connectionDetails`**: the datasource''s
  `connectionDetails` '

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
