# Prompt: Copy Isar Model Files from sltt-standalone-app to sltt-dart

Follow these steps to sync new Isar entity state model files from the `sltt-standalone-app` project into the `sltt-dart` repository:

---

1. **Identify the Files to Copy**
   - Locate the new Isar model files in `sltt-standalone-app`, typically named `*.entity_state.isar.dart` and their generated `*.g.dart` files.
   - Example: `marker.entity_state.isar.dart`, `marker.entity_state.isar.g.dart`.

2. **Copy Files to sltt-dart**
   - Copy each Isar model file and its generated `.g.dart` file into `sltt-dart/packages/sync_manager/lib/src/models/`.
   - Overwrite existing files if updating an existing model.

3. **Update Inspector Schema Registration**
   - Open `sltt-dart/bin/run_local_server_with_inspector.dart`.
   - Add the new schema(s) to the `providedEntityStateSchemas` list so the inspector and local server recognize the new entity type.
   - Example:
     ```dart
     providedEntityStateSchemas: [
       ...existing schemas...,
       MarkerDataEntityStateSchema,
     ]
     ```

4. **Test the Integration**
   - Run the local server and inspector to verify the new entity type is available and working as expected.
   - Run tests in `sltt-dart` to ensure no regressions.

---

**Note:**
- Always keep the instructions in this prompt up to date if the process changes.
- This process is typically performed after adding or updating Isar entity state models in `sltt-standalone-app` and running code generation.
