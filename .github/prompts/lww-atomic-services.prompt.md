TODO:
- add `noOp` and `outdated` to `operation` type enum
- add `noOpFields` string list to change log entry
- add `outdatedBys` map to change log entry (field name -> cid)
- add `isChange` string to change log entry (for filtering on changes that are not noOp or outdated)
- add `model` string for breaking changes and `downsyncs` collection to `queue` database (with `outsyncs` collection)
Question: should we store change log and state as map string, dynamic to preserve any data from apps with newer data?


atomic-lww-algorithm:
# Atomic Last-Writer-Wins (LWW) Algorithm for Change Log Entries
- call `changeLogEntryToMap(ChangeLogEntry)`
- call `entityState<>ToMap(entityState)?
- call `changeStateAnalysis(change, existingEntityStateFields)`
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

- detectDuplicate(change, existingEntityStateFields):
    - if the change log entry cid is the same as the existing entity state cid:
        - this is a duplicate.
        - if change.cloudAt
            - set with `cloudAt`
    - ?? if change.outdatedBy has a non-null cid value
             - add each field to outdatedBys list?

- getOperation(change, existingEntityStateFields):
    - if change.cloudAt has a value then
        - change.operation is the source of truth, no need to change
    - else
        - if `delete` true is in change.data, then
            - `operation` is `delete`
        - if no existing entity state fields,
            - `operation` is `create`
        - else if existing entity state fields:
            - `operation` is `update`
- fieldChangesOrNoOps(change, existingEntityStateFields):
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
