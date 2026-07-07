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

## Bucket B — Generic item ops (10)  ◐ scoped, ready to implement

These are the tenant-generic `/workspaces/{ws}/items[...]` operations that have **no** generic
wrapper yet (per-resource variants and shortcuts/schedules/job-instances/external-data-shares
already exist — do NOT duplicate those). Schemas from `platform.platform.definitions.json` /
`platform.tags.definitions.json`.

| # | Function | Method | Endpoint | Body / params | Status |
|---|----------|--------|----------|---------------|--------|
| 1 | New-FabricItem | POST | /items | CreateItemRequest: displayName(req), type(req), description, folderId, definition, creationPayload, sensitivityLabelSettings | ☐ |
| 2 | Update-FabricItem | PATCH | /items/{itemId} | UpdateItemRequest: displayName, description | ☐ |
| 3 | Remove-FabricItem | DELETE | /items/{itemId} | — | ☐ |
| 4 | Get-FabricItemDefinition | POST | /items/{itemId}/getDefinition | query: format (optional); returns {definition:{format,parts[]}} — LRO 202 | ☐ |
| 5 | Update-FabricItemDefinition | POST | /items/{itemId}/updateDefinition | query: updateMetadata; body UpdateItemDefinitionRequest{definition{format,parts[{path,payload,payloadType}]}} — LRO | ☐ |
| 6 | Move-FabricItem | POST | /items/{itemId}/move | MoveItemRequest: targetFolderId | ☐ |
| 7 | Move-FabricItemBulk | POST | /items/bulkMove | BulkMoveItemsRequest: targetFolderId, items[](req) | ☐ |
| 8 | Add-FabricItemTag | POST | /items/{itemId}/applyTags | ApplyTagsRequest: tags[](req) (array of {id}) | ☐ |
| 9 | Remove-FabricItemTag | POST | /items/{itemId}/unapplyTags | UnapplyTagsRequest: tags[](req) | ☐ |
| 10 | New-FabricOneLakeShortcutBulk | POST | /items/{itemId}/shortcuts/bulkCreate | query: shortcutConflictPolicy; BulkCreateShortcutsRequest: createShortcutRequests[](req) | ☐ |

Notes:
- 4 & 5 are long-running (202 + operation polling) — follow the existing `*Definition` command
  pattern (see `Get-FabricNotebookDefinition` / `Update-FabricNotebookDefinition`) for LRO handling.
- Enrichment: Get-FabricItemDefinition returns a definition blob (no id/name to resolve) — decorate
  minimally; New/Update/Move return the item or 202 — enrich with WorkspaceName where an item is returned.
- Confirm `New-FabricItem`/`Update-FabricItem`/`Remove-FabricItem`/`Get-FabricItemDefinition` truly
  absent before writing (grep confirmed absent 2026-07-07).

## Bucket C+D — Per-resource + small fixes (~60)  ☐ (not started)
## Bucket E — Power BI Admin + Gateways (15)  ☐ (not started)
## Bucket F — Legacy Power BI (~216)  ⊘ pending scope confirmation from user

---

## Validator false-negatives already confirmed (do NOT re-implement)
Update-FabricConnection, connection roleAssignments add/remove/update, Remove/Update-FabricDeploymentPipeline,
Get-FabricWorkspaceGitConnection, Get-FabricLongRunningOperation, Get-FabricDomain — all exist.
