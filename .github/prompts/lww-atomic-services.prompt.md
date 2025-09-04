PROMPT1: remove support for `none` in `srcStorageType`. Always expect `cloud` or `local` and always expect `srcStorageId` to be from the service where first change log entries were gotten (even if empty list)

PROMPT2:

add to POST api requestBody, api/help docs, processChanges api and related tests, to increase declarative context:
- `required String storageMode`: expect value to be `save` or `sync` where `sync` is for transferring already stored change log entries between storages, and `save` is for changes that have not yet been stored.
- during `sync` we expect all incoming change log entries to have non-empty storageIds, else return error. during sync, change log entry data is preserved independent of current state.
- during `save` we expect all incoming change log entries to have empty storageIds, else return error.  during save, change log entry data is a diff compared to current state.
- use this mode instead of comparing targetStorageId to change.storageId. In sync mode, a storage may receive back a change it once stored, probably should result in outdatedBy, noOp or dup. Print a warning if it results in change of state since this is unexpected and may be worth investigating.
- use `sync` mode in tests that expect data preservation and `save` in tests that expect diffs.

Possible external API changes:
`POST /api/changes/save` (to reduce boilerplate for change log entries)
`POST /api/changes/sync`
`POST /api/state/sync` (to make full state transfer more efficient, bypassing change log entry processing)
  - how to make this resumable? Could CursorSyncState be used for this, even though EntityState uses `Id`? Probably `entityId` as a cursor works well enough.
    - Maybe we need CursorSyncChanges vs. CursorSyncState?
  - use SelfSyncState to help client know final cid and seq for changelogs

Next step:
- in `sync` mode, updateChangeLogAndState() implementations should
   - for `cloud` storage type, typically result in storing a new change log entry and updated state if applicable
   - for `local` storage type, typically only update state if applicable. if hosting local team storage (future feature), then it will also store the change log entry (with cloudAt or not) and update state if applicable.
   - update `SelfSyncState` to track own latest change log entry
- in `save` mode, updateChangeLogAndState() should
  - for cloud and local storage type, typically result in change log and state updates if applicable.

Next step:
- handle domainId in _handleGetChanges rather than just projectId?

Next step:
   - update `SelfSyncState` to track own latest change log entry

Next step:
   - add serializable class for resultsSummary

Next step:
    - break api_changes_network_suite.dart into exportable tests
    - have clients import and run those in their own test with the same names

Next step:
    - change `/api/projects/{projectId}/changes` to take `cursorType` `cid` or `seq`
    - change `/api/projects/{projectId}/changes/{seq}` to `/api/projects/{projectId}/changes/{cid}`

Next step:??
- cloud storage type should return error if unknownJson is not empty or incoming schemaVersion is greater than it has knowledge of in its model


How to support required field using default:
```
@JsonSerializable()
class SchemaVersion1 with HasUnknownField {
  final String a;
  @override
  String unknownJson;

  Map<String, dynamic> get unknown => getUnknown();

  SchemaVersion1({required this.a, this.unknownJson = '{}'});
```


NEW TODOs:
for cloud storage type
get changes request can use cid instead of seq
- because database should store by seq internally and can look cid to get seq
- however for local team storage host, cid may not be sufficient??
  - host may have turned off hosting and thus no longer has its list
  - when a client needs to serialize its state back into change log entries,
     do we need to store a cloud seq as well as cid? Or will consumers just accept all the changes, including the sync_state which has a cloud seq

storageId as db responsibility
- transitions from '' to uuid as it's getting stored
- once change log entry has `storageId` then client should preserve its data
- if `storageId` is empty then we signal that it's a new change
    - if we determine the cid for cle with empty storageId has already been stored, then treat as a dup? treat as an error? compare actual data first?

- search for targetStorageId and adjust to use `storageId`

- probably should refactor POST changes logic for unit unit tests outside of request/response handling, then we can test different storage permutations  more easily.

- if storageType is cloud
  - always store change log entry with state
- FUTURE TODO: if sync with server that is hosting team local storage
  - always store change log entry with state, even those with cloudAt
- if storageType is local
  - don't store cloud entries in change log, just store to state
  - store all non-cloud entries in change log until they are clouded




-------------
TODO:
- add `noOp` and `outdated` to `operation` type enum
- add `noOpFields` string list to change log entry
- add `outdatedBys` map to change log entry (field name -> cid)
- add `isChange` string to change log entry (for filtering on changes that are not noOp or outdated)
- add `cloudAt` to each entity state field (to track when the change was applied to the cloud)
- add `model` string for breaking changes and `downsyncs` collection to `queue` database (with `outsyncs` collection)
Question: should we store change log and state as map string, dynamic to preserve any data from apps with newer data?


atomic-lww-algorithm:
# Atomic Last-Writer-Wins (LWW) Algorithm for Change Log Entries
applyAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState()
- call `getMaybeIsDuplicateCidResult(changeLogEntry, entityState)`
- if `isDuplicateCid` - set `cloudAt` if exists, otherwise don't store change log entry or update entity state
- else if `fieldUpdates` are empty and `noOpFields` are present:
    - set `operation` to `noOp`
    - set `change.noOpFields`
    - store change log entry, but do not update entity state
- else if any `outdatedBys` are present then
    - set `operation` to `outdated`
    - preserve the all `change.data` fields for debugging/archiving
    - set `change.outdatedBy` to be the latest `cid` in the `outdatedBys` map
- else apply `fieldUpdates` to the existing entity state fields and change log entry
    - use `change.changeAt` as the timestamp for each `{field}ChangeAt`
    - add `noOpFields` to the change log entry?

sltt_core/changeStateAnalysis(change, existingEntityStateFields):
- takes
    - incoming change log entry field
    - corresponding existing entity state fields
- returns
    - `operation` (create, update, delete)
    - `fieldUpdates` (implies `change.changeAt` for entity updates)
    - `noOpFields` (should this capture fields that are not changed - even if outdatedBys?)
    - `outdatedBys` (map of fields to the `cid` that outdated them)
    - `isDuplicateCid`
    - `cloudAt` - in case of duplicate cid went from local -> cloud -> local

- getMaybeIsDuplicateCidResult(change, existingEntityStateFields):
    - if the change log entry cid is the same as the existing entity state cid:
        - this is a duplicate.
        - if change.cloudAt
            - set with `cloudAt`
    - ?? if change.outdatedBy has a non-null cid value
             - add each field to outdatedBys list?

- calculateOperation(change, existingEntityStateFields):
    - if change.cloudAt has a value then
        - change.operation is the source of truth, no need to change
    - else
        - if `delete` true is in change.data, then
            - `operation` is `delete`
        - if no existing entity state fields,
            - `operation` is `create`
        - else if existing entity state fields:
            - `operation` is `update`
- `getFieldChangesOrNoOps(change, existingEntityStateFields)`:
    - determine which fields are different from the existing entity state fields
        - store those in a `fieldChanges` key/value map,
        - otherwise store them in a `noOpFields` list
- fieldUpdatesOrOutdatedBys(change, existingEntityStateFields, `fieldChanges`):
    - for each field in `fieldChanges` map
            - compare the change.changeAt to the existing entity state field's changeAt
                - if change.changeAt > existing fieldChangeAt:
                    - add it to the key/value map of `fieldUpdates`
                 - else
                    - add outdatedBy to the `outdatedBys` map
