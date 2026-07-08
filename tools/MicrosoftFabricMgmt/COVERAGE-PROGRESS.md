# Coverage Program — Progress Tracker

Resumable worklog toward **provable 100% coverage** of the Fabric REST API and the in-scope
Power BI (Admin/Gateways) API for the MicrosoftFabricMgmt module. Update this file as each item
lands so work survives context resets / API throttling. Source of truth for schemas is the local
spec cache (`tools/.api-specs-cache/`) — no network calls needed.

**Branch:** `item-connections-and-coverage`
**Green baseline gate:** `pwsh -NoProfile -NonInteractive -Command "Set-Location '<repo>'; .\build.ps1 -Tasks build,test"`
(clean shell, non-interactive — see memory `fabricmgmt-build-test-invocation`).

Status legend: ☐ todo · ◐ in progress · ☑ done (built+tested) · ⊘ n/a / out of scope

---

## Bucket A — Fabric Gateways API (`platform.swagger.json`)

13 endpoints (last 2 already shipped as workspace networking rules) → **11 new functions**.
Schemas from `platform.gateways.definitions.json`.

Key enums: `GatewayType` = OnPremises | OnPremisesPersonal | VirtualNetwork ·
`GatewayRole` = Admin | ConnectionCreatorWithResharing | ConnectionCreator ·
`LoadBalancingSetting` = Failover | DistributeEvenly.

**BUCKET A COMPLETE** — 11 functions + 11 tests + 3 format views + CHANGELOG; build,test green
(8782 passed / 0 failed / 1 skipped). Commit: see git log on branch.

| # | Function | Method | Endpoint | Status | Notes |
|---|----------|--------|----------|--------|-------|
| 1 | Get-FabricGateway | GET | /gateways · /gateways/{id} | ☑ | List + by-id; enrich CapacityName (VNet); type MicrosoftFabric.Gateway; -Raw |
| 2 | New-FabricGateway | POST | /gateways | ☑ | VirtualNetwork only (sole creatable type). VirtualNetworkAzureResource(hashtable) |
| 3 | Update-FabricGateway | PATCH | /gateways/{id} | ☑ | Type-aware union of VNet + OnPrem updatable props |
| 4 | Remove-FabricGateway | DELETE | /gateways/{id} | ☑ | ShouldProcess High |
| 5 | Get-FabricGatewayMember | GET | /gateways/{id}/members | ☑ | enrich GatewayName; type MicrosoftFabric.GatewayMember; -Raw |
| 6 | Update-FabricGatewayMember | PATCH | /gateways/{id}/members/{memberId} | ☑ | DisplayName, Enabled |
| 7 | Remove-FabricGatewayMember | DELETE | /gateways/{id}/members/{memberId} | ☑ | ShouldProcess |
| 8 | Get-FabricGatewayRoleAssignment | GET | /gateways/{id}/roleAssignments · /{raId} | ☑ | List + by-id; enrich GatewayName; type MicrosoftFabric.GatewayRoleAssignment; -Raw |
| 9 | Add-FabricGatewayRoleAssignment | POST | /gateways/{id}/roleAssignments | ☑ | PrincipalId, PrincipalType, GatewayRole |
| 10 | Update-FabricGatewayRoleAssignment | PATCH | /gateways/{id}/roleAssignments/{raId} | ☑ | GatewayRole |
| 11 | Remove-FabricGatewayRoleAssignment | DELETE | /gateways/{id}/roleAssignments/{raId} | ☑ | ShouldProcess |

Supporting work for bucket A:
- ☑ Format views: MicrosoftFabric.Gateway / .GatewayMember / .GatewayRoleAssignment in `MicrosoftFabricMgmt.Format.ps1xml`
- ☑ Unit tests (behavior + endpoint/method/body) for all 11
- ☑ CHANGELOG entry
- ☑ build,test green (8782 passed / 0 failed / 1 skipped)

### Response schemas (for property completeness)
- **Gateway** (base): id, type. **VirtualNetworkGateway**: +displayName, capacityId, virtualNetworkAzureResource{virtualNetworkName,subnetName,(subscriptionId,resourceGroupName)}, inactivityMinutesBeforeSleep, numberOfMemberGateways. **OnPremisesGateway**: +displayName, publicKey{exponent,modulus}, version, numberOfMemberGateways, loadBalancingSetting, allowCloudConnectionRefresh, allowCustomConnectors. **OnPremisesGatewayPersonal**: +publicKey, version.
- **OnPremisesGatewayMember**: id, displayName, publicKey, version, enabled.
- **GatewayRoleAssignment**: id, principal{id,displayName,type}, role.

---

## Bucket B — Generic item ops (10)  ☑ COMPLETE

All 10 implemented with behavior tests + CHANGELOG; build,test green
(8874 passed / 0 failed / 1 skipped).


These are the tenant-generic `/workspaces/{ws}/items[...]` operations that have **no** generic
wrapper yet (per-resource variants and shortcuts/schedules/job-instances/external-data-shares
already exist — do NOT duplicate those). Schemas from `platform.platform.definitions.json` /
`platform.tags.definitions.json`.

| # | Function | Method | Endpoint | Body / params | Status |
|---|----------|--------|----------|---------------|--------|
| 1 | New-FabricItem | POST | /items | CreateItemRequest: displayName(req), type(req), description, folderId, definition, creationPayload, sensitivityLabelSettings | ☑ |
| 2 | Update-FabricItem | PATCH | /items/{itemId} | UpdateItemRequest: displayName, description | ☑ |
| 3 | Remove-FabricItem | DELETE | /items/{itemId} | — | ☑ |
| 4 | Get-FabricItemDefinition | POST | /items/{itemId}/getDefinition | query: format (optional); returns {definition:{format,parts[]}} — LRO 202 | ☑ |
| 5 | Update-FabricItemDefinition | POST | /items/{itemId}/updateDefinition | query: updateMetadata; body UpdateItemDefinitionRequest{definition{format,parts[{path,payload,payloadType}]}} — LRO | ☑ |
| 6 | Move-FabricItem | POST | /items/{itemId}/move | MoveItemRequest: targetFolderId | ☑ |
| 7 | Move-FabricItemBulk | POST | /items/bulkMove | BulkMoveItemsRequest: targetFolderId, items[](req) | ☑ |
| 8 | Add-FabricItemTag | POST | /items/{itemId}/applyTags | ApplyTagsRequest: tags[](req) (array of {id}) | ☑ |
| 9 | Remove-FabricItemTag | POST | /items/{itemId}/unapplyTags | UnapplyTagsRequest: tags[](req) | ☑ |
| 10 | New-FabricOneLakeShortcutBulk | POST | /items/{itemId}/shortcuts/bulkCreate | query: shortcutConflictPolicy; BulkCreateShortcutsRequest: createShortcutRequests[](req) | ☑ |

Notes:
- 4 & 5 are long-running (202 + operation polling) — follow the existing `*Definition` command
  pattern (see `Get-FabricNotebookDefinition` / `Update-FabricNotebookDefinition`) for LRO handling.
- Enrichment: Get-FabricItemDefinition returns a definition blob (no id/name to resolve) — decorate
  minimally; New/Update/Move return the item or 202 — enrich with WorkspaceName where an item is returned.
- Confirm `New-FabricItem`/`Update-FabricItem`/`Remove-FabricItem`/`Get-FabricItemDefinition` truly
  absent before writing (grep confirmed absent 2026-07-07).

## Bucket D — Platform small fixes  ☑ COMPLETE (pending build confirmation)

7 commands (6 new + 1 repurpose) covering the genuine platform gaps found in the verification pass:
- ☑ `Get-FabricConnectionRoleAssignment` — GET /connections/{id}/roleAssignments (+by-id)
- ☑ `Get-FabricWorkspaceGitConnection` — **repurposed** to GET /workspaces/{ws}/git/connection
  (was a mis-targeted duplicate of the admin discover endpoint; WorkspaceId now mandatory)
- ☑ `Get-FabricItemExternalDataShare` — GET .../items/{itemId}/externalDataShares (+by-id)
- ☑ `Get-FabricOneLakeSetting` — GET .../onelake/settings
- ☑ `Set-FabricOneLakeDiagnostic` — POST .../onelake/settings/modifyDiagnostics
- ☑ `Add-FabricWorkspaceDomain` — POST .../assignToDomain
- ☑ `Remove-FabricWorkspaceDomain` — POST .../unassignFromDomain

All with behavior tests + CHANGELOG (Added + Fixed).

## Bucket C — Per-resource  ☑ COMPLETE (except deferred nltokql)

**Fabric coverage now 96.7% (530/548).** The remaining 18 uncovered Fabric endpoints are all
accounted for — NOT genuine gaps:

**Confirmed false-negatives (covered; validator can't parse the URI shape):**
Start-FabricDataflowJob (dataflows Execute/ApplyChanges instances ×2), Start-FabricLakehouseRefreshMaterializedLakeView
+ Start-FabricLakehouseTableMaintenance (lakehouse instances ×2), Start-FabricSparkJobDefinitionOnDemand
(sparkjob instances), Update-FabricVariableLibraryDefinition (VariableLibraries updateDefinition),
Disable-FabricMLModelEndpointVersion -All (deactivateAll), Remove-FabricDomainWorkspace (unassignWorkspaces +
unassignAllWorkspaces), Import/Remove-FabricEnvironmentStagingLibrary (staging/libraries/{libraryName} POST+DELETE),
Get-FabricDomain (/domains → admin/domains), Get-FabricLongRunningOperation (/operations/{id}),
Get-FabricOneLakeShortcut (shortcuts/{path}/{name}).

**Deferred:** GET /realtimeintelligence/nltokql (beta; a required NlToKqlRequest **body on a GET** — needs
careful handling; itemIdForBilling/clusterUrl/naturalLanguage/databaseName).

**Ambiguous (left as-is):** POST /capacities/{id}/delegatedTenantSettingOverrides/{name}/update — existing
Update-FabricCapacityTenantSettingOverrides POSTs to `.../delegatedTenantSettingOverrides` (no /{name}/update);
verify against the live API before changing.

### Batches delivered (all committed + green):

After a 3rd validator fix (case-insensitive `-replace`, +11) **Fabric coverage is 90.1% (494/548)**.
The remaining-missing list is now trustworthy. Genuine gaps (false-negatives excluded):

**Still-false-negatives (covered; do NOT implement):** Start-FabricLakehouseRefreshMaterializedLakeView
(RefreshMaterializedLakeViews/instances), Start-FabricLakehouseTableMaintenance (TableMaintenance/instances),
Start-FabricSparkJobDefinitionOnDemand (sparkjob/instances), Update-FabricVariableLibraryDefinition
(VariableLibraries updateDefinition), Get-FabricLongRunningOperation (/operations/{id}),
Get-FabricOneLakeShortcut (shortcuts/{path}/{name}), Get-FabricDomain (/domains → admin/domains).

**Genuine C batches (~35 functions):**
- ☑ **C1 def wrappers** — Get/Update-FabricLakehouseDefinition + Get/Update-FabricEnvironmentDefinition (4 fns) — build green
- ☑ **C2 sqlAudit** — Get/Update-FabricSQLEndpointSqlAudit + Set-FabricSQLEndpointSqlAuditActionsAndGroups + Warehouse trio (6 fns) — build green (9023 passed)
- ☐ **C2 sqlAudit** — sqlEndpoint + warehouse (6 ep, 6 fns). Schemas ready:
  - GET .../settings/sqlAudit → `SqlAuditSettings` {state(Enabled|Disabled), retentionDays:int, auditActionsAndGroups:string[]}
  - PATCH .../settings/sqlAudit → `SqlAuditSettingsUpdate` {state, retentionDays}
  - POST .../settings/sqlAudit/setAuditActionsAndGroups → body is a bare **string[]** of action/group names
  - Fns: Get/Update-FabricSqlEndpointSqlAudit, Set-FabricSqlEndpointSqlAuditActionsAndGroups (+ Warehouse trio)
  - **DONE (source+tests+CHANGELOG written; combined build pending)**: Get/Update-FabricSQLEndpointSqlAudit,
    Set-FabricSQLEndpointSqlAuditActionsAndGroups, Get/Update-FabricWarehouseSqlAudit,
    Set-FabricWarehouseSqlAuditActionsAndGroups. Analyzer clean.
- ☑ **C3 mirroredAzureDatabricksCatalog** — Get-FabricAzureDatabricksCatalog/Schema/Table +
  Update-FabricMirroredAzureDatabricksCatalogMetadata (4 fns, tests, CHANGELOG; build pending):
  - GET /azuredatabricks/catalogs — query `databricksWorkspaceConnectionId` (req), continuationToken, maxResults → Get-FabricAzureDatabricksCatalog (resp DatabricksCatalogs)
  - GET /azuredatabricks/catalogs/{catalogName}/schemas → Get-FabricAzureDatabricksSchema (resp DatabricksSchemas)
  - GET /azuredatabricks/catalogs/{catalogName}/schemas/{schemaName}/tables → Get-FabricAzureDatabricksTable (resp DatabricksTables)
  - POST /mirroredAzureDatabricksCatalogs/{id}/refreshCatalogMetadata → Update-FabricMirroredAzureDatabricksCatalogMetadata (verb: Update, per Update-FabricSQLEndpointMetadata precedent)
- ☑ **C4 dataflow** — Invoke-FabricDataflowQuery + New-FabricDataflowJobSchedule (2 fns). Execute/ApplyChanges
  *instances* were false-negatives (Start-FabricDataflowJob -JobType already covers them).
- ☑ **C5 environment external libraries** — Export-FabricEnvironmentExternalLibrary (-Staging),
  Import-FabricEnvironmentStagingExternalLibrary (octet-stream), Remove-FabricEnvironmentStagingExternalLibrary
  (3 fns / 4 ep). staging/libraries/{libraryName} POST+DELETE left as false-negatives of existing Import/Remove-FabricEnvironmentStagingLibrary.
  Original note: 6 ep, but existing Get-FabricEnvironmentLibrary / Get/Import/Remove-FabricEnvironmentStagingLibrary
  already hit `environments/{id}/(staging/)libraries`. Genuine NEW = the 4 **external-library** ops
  (verify import/remove staging first): GET libraries/exportExternalLibraries, GET staging/libraries/exportExternalLibraries,
  POST staging/libraries/importExternalLibraries, POST staging/libraries/removeExternalLibrary.
  (POST/DELETE staging/libraries/{libraryName} are likely false-negatives of Import/Remove-FabricEnvironmentStagingLibrary.)
- ☑ **C6 apacheAirflowJob (beta)** — Get/Set/Remove-FabricApacheAirflowJobFile, Get/New/Remove-FabricApacheAirflowPoolTemplate,
  Get/Update-FabricApacheAirflowSetting (8 fns / 10 ep, tests, CHANGELOG; build pending). Details:
  - GET  .../ApacheAirflowJobs/{id}/files → Get-FabricApacheAirflowJobFile (list; add optional -FilePath for the by-path GET)
  - GET  .../ApacheAirflowJobs/{id}/files/{filePath} → (same fn via -FilePath)
  - PUT  .../ApacheAirflowJobs/{id}/files/{filePath} → Set-FabricApacheAirflowJobFile (octet-stream; {filePath} may contain '/')
  - DELETE .../ApacheAirflowJobs/{id}/files/{filePath} → Remove-FabricApacheAirflowJobFile
  - GET  .../apacheAirflowJobs/poolTemplates (+ /{poolTemplateId}) → Get-FabricApacheAirflowPoolTemplate (list + by-id)
  - POST .../apacheAirflowJobs/poolTemplates → New-FabricApacheAirflowPoolTemplate (body CreateAirflowPoolTemplateRequest:
    name, nodeSize(ref NodeSize), computeScalability(ref ComputeScalability), apacheAirflowJobVersion — all required)
  - DELETE .../apacheAirflowJobs/poolTemplates/{poolTemplateId} → Remove-FabricApacheAirflowPoolTemplate
  - GET  .../apacheAirflowJobs/settings → Get-FabricApacheAirflowSetting
  - PATCH .../apacheAirflowJobs/settings → Update-FabricApacheAirflowSetting (body {defaultPoolTemplateId})
  Note: {filePath} with embedded slashes — build with -Segments and pass the raw path, or append to the URI string.
  Get NodeSize/ComputeScalability enums from apacheAirflowJob.definitions.json before writing New-...PoolTemplate.
- ☑ **C7 lakehouse RefreshMaterializedLakeViews schedules** — New/Update/Remove (3 fns, tests, CHANGELOG; build pending)
- ◐ **C8 admin** — DONE the 2 genuine: Get-FabricDomainRoleAssignment + Sync-FabricDomainRoleAssignment.
  False-negatives confirmed: bulkAssign (Add-FabricDomainWorkspaceByRoleAssignment), unassignWorkspaces +
  unassignAllWorkspaces (Remove-FabricDomainWorkspace covers both). AMBIGUOUS/left as-is: capacity
  delegatedTenantSettingOverrides/{name}/update — existing Update-FabricCapacityTenantSettingOverrides POSTs
  to `.../delegatedTenantSettingOverrides` (no /{name}/update suffix); needs live-API verification before changing.
  Original scoping notes below:
  **SPOT-CHECK for false-negatives first** — module has
  Add-FabricDomainWorkspaceByRoleAssignment / Remove-FabricDomainWorkspaceRoleAssignment / Remove-FabricDomainWorkspace
  which may already cover the bulk role-assign/unassign + unassignWorkspaces. Genuine candidates:
  - GET /admin/domains/{id}/roleAssignments → Get-FabricDomainRoleAssignment (list) — check not present
  - POST /admin/domains/{id}/roleAssignments/syncToSubdomains → Sync-FabricDomainRoleAssignment (body SyncRoleAssignmentsToSubdomainsRequest)
  - POST /admin/domains/{id}/unassignAllWorkspaces → Remove-FabricDomainWorkspace -All? (no body)
  - POST /admin/capacities/{id}/delegatedTenantSettingOverrides/{name}/update → Update-FabricCapacityTenantSettingOverride (body UpdateCapacityTenantSettingOverrideRequest)
- ◐ **C9 singles** — reconciled:
  - ☑ semanticModel bindConnection → **Set-FabricSemanticModelConnection** (new)
  - ☑ warehouseSnapshot PATCH → **fixed Update-FabricWarehouseSnapshot** (was targeting /warehouses/ with an
    undefined $WarehouseId var; now PATCH /warehousesnapshots/{id})
  - ⊘ mlModel deactivateAll → FALSE-NEGATIVE (Disable-FabricMLModelEndpointVersion -All already covers it)
  - ☐ realTimeIntelligence **nltokql** (beta) — DEFERRED: GET /realtimeintelligence/nltokql with a required
    NlToKqlRequest **body on a GET** (itemIdForBilling, clusterUrl, naturalLanguage, databaseName) — awkward
    shape, handle carefully in its own pass.
## Bucket E — Power BI Admin + Gateways (15)  ◐ gateways done

**Gateways (7) DONE** — New/Update/Remove-FabricAdminGatewayDatasource, Get-FabricAdminGatewayDatasourceStatus,
Get/Add/Remove-FabricAdminGatewayDatasourceUser (7 fns, tests, CHANGELOG; build pending). Power BI base URL.
**Admin (8) remain = mostly false-negatives / ambiguous** (see below) — verify vs live API before adding.

Power BI in-scope 55/70 (78.6%). The 15 missing split into:

**Gateways (7) — GENUINE (only Get list + by-id datasource exist). Power BI classic gateway datasource mgmt:**
- POST   /v1.0/myorg/gateways/{gatewayId}/datasources → New-FabricAdminGatewayDatasource (body PublishDatasourceToGatewayRequest)
- PATCH  /gateways/{id}/datasources/{dsId} → Update-FabricAdminGatewayDatasource
- DELETE /gateways/{id}/datasources/{dsId} → Remove-FabricAdminGatewayDatasource
- GET    /gateways/{id}/datasources/{dsId}/status → Get-FabricAdminGatewayDatasourceStatus
- GET    /gateways/{id}/datasources/{dsId}/users → Get-FabricAdminGatewayDatasourceUser
- POST   /gateways/{id}/datasources/{dsId}/users → Add-FabricAdminGatewayDatasourceUser
- DELETE /gateways/{id}/datasources/{dsId}/users/{emailAdress} → Remove-FabricAdminGatewayDatasourceUser
  (schemas: pull from powerbi spec cache — PublishDatasourceToGatewayRequest, UpdateDatasourceRequest,
  DatasourceUser/GatewayDatasourceUser, add-user body.)

**Admin (8) — mostly false-negatives / ambiguous (verify vs live API before adding):**
- POST /admin/groups/{id}/restore → Restore-FabricAdminWorkspace ✓ (false-neg)
- POST /admin/tenantKeys/{id}/Default.Rotate → Start-FabricAdminEncryptionKeyRotation ✓ (false-neg)
- GET  /admin/groups/{id}/unused → Get-FabricAdminWorkspaceUnusedArtifact (targets /UnusedArtifacts — same op) ✓
- GET  /admin/groups/{id}/users → Get-FabricAdminWorkspaceUser (likely) ✓
- GET  /admin/groups (+ /{id}) → Get-FabricAdminWorkspace (likely) — verify path
- POST /admin/capacities/AssignWorkspaces + UnassignWorkspaces → AMBIGUOUS: existing
  Add-FabricAdminCapacityWorkspace hits `/capacities/{capacityId}/AssignWorkspaces` and
  Remove-FabricAdminCapacityWorkspace hits `/capacities/UnassignWorkspacesFromCapacity` — different
  endpoint variants; confirm whether the bulk `/admin/capacities/(Un)AssignWorkspaces` forms are needed.
## Bucket F — Legacy Power BI (~216)  ⊘ pending scope confirmation from user

---

## Coverage verification pass (2026-07-07)  ☑ DONE

Ran `Validate-FabricModuleCoverage.ps1 -Api All -ValidationType Coverage` against source and
**fixed two systematic validator false-negatives** (script was undercounting real coverage):

1. **`-ResourceId` alias** — the `-Resource` path builder only honored `-WorkspaceId`, so every
   function using the `-ResourceId` alias (all gateway cmds, connection roleAssignments,
   deploymentPipeline patch/delete) lost its `{p}` id segment. Now honors either spelling.
2. **Conditional URI assignment** — `$uri = if (...) { New-FabricAPIUri ... } else { ... }` was
   not walked; the by-id/list branches of Get-FabricGateway / Get-FabricGatewayRoleAssignment
   were invisible. Now collects every `New-FabricAPIUri` call in the RHS subtree.

Result: **Fabric coverage 84.9% → 88.1% (483/548)** with no code change — purely a more accurate
count. Overall All-API 64.4% (538/835); Power BI in-scope (Admin/Gateways) 78.6% (55/70).

### Remaining Fabric `platform` gaps — classified
**Genuine (candidates for new commands):**
- `Get-FabricConnectionRoleAssignment` — GET /connections/{id}/roleAssignments (+by-id). Only
  Add/Remove/Update exist; no getter.
- GET /workspaces/{ws}/git/connection — the per-workspace git connection getter. NOTE the existing
  `Get-FabricWorkspaceGitConnection` actually targets `admin/workspaces/discoverGitConnections`
  (a different, admin endpoint) — so this per-workspace GET is genuinely uncovered.
- GET /workspaces/{ws}/items/{itemId}/externalDataShares (+by-id) — provider-side list/get. The
  existing `Get-FabricExternalDataShare` targets `admin/items/externalDataShares` (admin surface).
- GET /workspaces/{ws}/onelake/settings — OneLake settings getter (new).
- POST /workspaces/{ws}/onelake/settings/modifyDiagnostics — new.
- POST /workspaces/{ws}/assignToDomain + /unassignFromDomain — workspace-side domain assign (new).

**False-negatives (covered; validator still can't see — leave as-is, do NOT re-implement):**
- GET /operations/{operationId} — `Get-FabricLongRunningOperation` builds it with a literal-base
  `-f` string inside an if-expression (validator only resolves New-FabricAPIUri in conditionals).
- GET /workspaces/{ws}/items/{itemId}/shortcuts/{shortcutPath}/{shortcutName} —
  `Get-FabricOneLakeShortcut` issues the collection GET and filters client-side (two-segment id;
  the by-id rule only matches single `/{p}`).
- GET /domains — `Get-FabricDomain` targets `admin/domains`; spec lists a plain `/domains` (path
  mismatch, effectively the same logical op).

### Non-platform Fabric gaps (genuine, by group) — for bucket C+D
apacheAirflowJob 10 · environment 8 · lakehouse 7 · admin 5 · dataflow 5 ·
mirroredAzureDatabricksCatalog 4 · sqlEndpoint 3 · warehouse 3 · graphQLApi 2 ·
mlModel 1 · realTimeIntelligence 1 · semanticModel 1 · sparkjobdefinition 1 ·
variableLibrary 1 · warehouseSnapshot 1. (Each still to be spot-checked for false-negatives
before implementing — the validator is now trustworthy but not perfect.)

## Validator false-negatives already confirmed (do NOT re-implement)
Update-FabricConnection, connection roleAssignments add/remove/update, Remove/Update-FabricDeploymentPipeline,
Get-FabricLongRunningOperation, Get-FabricDomain — all exist (see classified list above for the
specific still-uncounted ones).
