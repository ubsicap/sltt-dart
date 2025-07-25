I'd like to refactor the rest_server_api.dart and local_storage_service.dart to 

1) add to the rest api so that POST /changes/sync/{seq} stores new changes and also responds with changes since last {seq}, and update tests

2) create the following two local changes storage services, for now, share the same local storage service code, except for the name for the isar.open should be:
    - `downsyncs` - which stores changes received from the cloud
    - `outsyncs` - which stores changes to be sent to the cloud

3) also, for now, use the same local storage service code to simulate cloud storage with the following isar.open name:
    - `cloud_storage`

4) allow for starting 3 api servers for each storage service:
    - `downsyncs` on port 8081
    - `outsyncs` on port 8082
    - `cloud_storage` on port 8083 (except don't allow delete or put operations, only get and post)

5) create a sync manager that can handle the following:
    - outsync changes from `outsyncs` to `cloud_storage`
    - downsync changes from `cloud_storage` to `downsyncs` (use last seq number as starting cursor)
    - delete local changes from `outsyncs` that have been successfully outsynced to `cloud_storage`

6) sync manager tests should verify expected behavior



