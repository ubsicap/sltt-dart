The next thing we need to do is to set up the entity state storage collections.

- add `changeBy` to change log entry schema:
  - `changeBy` (string) - memberId who made the change

- add core state schema which has metadata common across all entity types:
  - immutable fields:
    - `entityType` immutable (enum) (same as `entityType` from change log entry),
    - `entityId` (primary key) immutable (string) (same as `entityId` from change log entry). Same format as `cid` except it also contains an 4 character abbreviation of the entity type - not sure if this should be a prefix or suffix
  - mutable fields:
    - `rank` (string? int?) - used to sort in parent
    - `deleted` (bool) - (same as `deleted` from change log entry)
    - `parentId` (string) - (will match some `entityId` from a change log entry)
    - `projectId` (string) - (same as `projectId` from latest change log entry)
    - `changeAt` (dateTime) - (same as `changeAt` from latest change log entry)
    - `cid` (string) - (same as `cid` from latest change log entry)
    - `cloudAt` (dateTime) - (same as `cloudAt` from latest change log entry)
    - `changeBy` (string) - (same as `changeBy` from latest change log entry)
    - `origProjectId` (string) - (same as `projectId` from change log entry)
    - `origChangeAt` (dateTime) (captures the first `changeAt` for that entityId)
    - `origChangeBy` (string) - (same as `changeBy` from first change log entry)
    - `origCid` (string) - (same as `cid` from first change log entry)
    - `origCloudAt` (dateTime) - (same as `cloudAt` from first change log entry)

- each state field will also have a corresponding `{field}ChangeAt` (dateTime) which will be used for conflict resolution. it will come from the change log entry that is used to update that state field
    - conflict resolution logic is simple:
        - if the `changeAt` of the change log entry is newer than the `changeAt` of the state field, then update the state field
- also each will have a `{field}Cid` (string) which will be used to track the change log entry that was used to update that state field
- each state schema should have a corresponding `{field}ChangeBy` (string) which will be used to track the memberId who made the change to that state field

- if possible each state schema should have an entityId alias (getter?) called `{entityType}Id` that can be used to disambiguate where needed

- add entityType `team`
- state schemas that inherit from core state schema:
  - `team` state schema which has metadata specific to team entities:
    - `name` (string) - english team name
    - `nameLocal` (string) - team autonym
    - `description` (string) - team description

 - `project` state schema which has metadata specific to project entities:
    - `namePublic` (string) - project public name
    - `nameLocal` (string) - project autonym
    - `shortLocal` (string) - abbrev project name
    - `description` (string) - project description
    - `projectType` (enum)
    - `region` (string) - project region
    - `country` (string) - project country
    - `signLanguage` (string) - english name
    - `signLanguageLocal` (string) - project sign language autonym
    - `teamId` (string) - parentId alias points to team entityId

  - `plan` state schema which has metadata specific to plan entities:
    - `projectId` (string) - points to project entityId

  - `stage`
    - `nameLocal` (string) - stage name
    - `planId` (string) - parentId points to plan entityId

  - `task` state schema which has metadata specific to task entities:
    - `nameLocal` (string) - task name
    - `description` (string) - task description
    - `difficulty` (enum) - very easy, easy, medium, hard, very hard
    - `stageId` (string) - parentId points to stage entityId

  - `member` state schema which has metadata specific to member entities:
    - `nameLocal` (string)
    - `email` (string) - member email address
    - `role` (string) - member role in the project
    - `projectId` (string) - parentId points to project entityId

- `portion` state schema which has metadata specific to portion entities:
    - `nameLocal` (string) - english portion name
    - `projectId` (string) - parentId points to project entityId

- `passage` state schema which has metadata specific to passage entities:
    - `nameLocal` (string) - english passage name
    - `referenceRanges` (string)
    - `passageType` (enum) - translation, introduction, other
    - `hashtag` (string) - passage hashtag
    - `difficulty` (enum) - very easy, easy, medium, hard, very hard
    - `taskId` (enum) - points to task entityId
    - `portionId` (enum) - points to portion entityId

- `video` state schema which has metadata specific to draft video entities:
    - `label` (string) - local label
    - `duration` (int) - video duration in seconds
    - `draftType` (enum) - translation, introduction, other
    - `hashtag` (string) - draft hashtag
    - `difficulty` (enum) - very easy, easy, medium, hard, very hard

 - `patch` state schema which has metadata specific to patch video entities, based on video state schema::
    - `locationAt` (int) - location in the video timeline
    - `targetId` (string) - parentId points to video or patch entityId

- `note` state schema which has metadata specific to note entities:
