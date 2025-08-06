build a demo flutter app in the `apps/flutter_sync_manager` directory.

sync_manager should provide hooks to asynchronously control the flow of changes between the app and the backend, allowing the app to see the flow of data and final results

Purpose: This app will demonstrate the usage of the `sync_manager` package, showcasing how to manage state synchronization in a Flutter application.

It should also show reactive updates to the UI based on changes in the sync state.

In this app, the user will be able to
1) add their user name/email
2) create or select a unique and (url safe) projectId

Simulate being offline, and then online, and see the sync manager update the UI with the current sync state.

Dashboard:
 see cloud stats, outsync stats, and current sync status, and how many entities are in the current app state, and what types they are. how many entities are in the cloud, and how many are out of sync.

Entity Browser:
- Bread-crumb navigation to follow the hierarchy of entities (according to their parentId)
- nameLocal are most important
- entity is at top of page
- create / update / delete

- upsync button
- downsync button

Steps:
1. Setup Flutter
