SLTT 2.0 vs. SLTT 3.0 synchronization comparison

|Topic | 2.0 Sync | 3.0 Sync (RFC)|
|-------|----------|---------------|
|Latest state | via client processing all change log entries via model in code | via reading entity record(s)|
|State Memory Usage| requires full state of objects in memory| only current objects in memory, rest in database until needed|
|Merge protection | cloud-only Last Write Wins (LWW) **per-object** (`modDate`) | local and cloud LWW **per-field** (`changeAt`) |
|Merge losers | sent to rollbar | stored in change log entries as `outdated` or `error` operation and `changedState` false|
|Merge Complexity | Very Simple | Moderate|
|Validation | none | state schema checked on save |
|Sync Authorization|non-observer and a few objects|client and server could share same authorization code|
|breaking schema updates | clients store change log entries but skips data for advanced schema version numbers until code updated | same for breaking changes, hopefully just add new fields and maintain backward compatibility for old ones |
|Backend queriable|change log[project seq doc] and basic project settings|all state and change log: most fields|
|Local queriable|after loading state into memory via code|most state fields and pending change logs|
|LAN ready|electron with express api server with file-system based database | same database as client and same sync api shelf server as for backend|
|is change doc from cloud| _id has integer seq below certain number|`cloudAt` property set|
|Object location| embedded in hierarchical `_id` (can't be changed. must use other fields to change) | `parentId` and `parentProp` (both can be changed, but copying state data would be required to move to different domainId (e.g. from project A to project B)|
|Root entities| `project` | domains (e.g. `project`, `user`, etc... ) each with their own change log|
