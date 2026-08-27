
**Agent Instruction:**

- Any change to `packages/aws_backend/lib/src/storage/dynamodb_storage_service.dart` **must** update the key access map comment at the top of that file to reflect the current key patterns and usage. This ensures the documentation stays in sync with the implementation.

- prefer running commands with cmd.exe instead of powershell pwsh.
- Whenever pwsh is used, don't use '&&' since that is not a valid statement separator
- first try running `dart test [options]` rather than using special scripts to run tests.
  - if isar complains about missing native library, remind user to source the setup script, eg. `./setup_test_env.sh` before running `dart test` to ensure the Isar native library is available.
- When adding or updating tests, include `reason:` text on failing assertions where it helps identify which behavior or file check failed.
- Always keep the `/api/help` documentation in sync with the actual API handlers implemented in `lib/src/api/base_rest_api_server.dart` (`_handleApiDocs`).
- Whenever you add, remove, or change any API endpoint or its behavior, immediately update the `/api/help` docs to reflect those changes.
 - Do not add fallback scanning code without prior confirmation from the repository maintainer.
   Such fallback code increases complexity and can mask issues in upstream data; ask for confirmation before adding it.
 - When adding new API network tests, register them in `packages/sltt_core/test/helpers/api_changes_network_suite.dart` and call the specific test entries from each test runner (for example `packages/sltt_core/test/api_changes_network_test.dart` and `packages/sync_manager/test/isar_storage_api_changes_network_test.dart`).
   This keeps test discovery consistent across storage backends and avoids duplicated test logic.

- When introducing a new Dynamo entity state model, register it in `packages/aws_backend/lib/src/models/dynamo_entity_state_serialization_registry.dart` so serialization/deserialization works across entity types.

- When adding or changing AWS backend environment variables used by local debug runs, keep `packages/aws_backend/bin/debug_server.dart` and `.vscode/launch.json` in sync with the same variable names, defaults, and operator-facing hints.
  - This applies especially to new auth settings alongside existing storage/media settings.

- For AWS backend Lambda deployments using compiled Dart `bootstrap`, do not assume non-Dart assets are packaged just because they exist in the repo.
  - Dart imports only load Dart libraries. Files like `.html` are not importable as strings and are not automatically included in the Lambda artifact.
  - If runtime code needs template content, prefer embedding it in Dart (or generated Dart source) unless packaging rules explicitly include the asset files.

- Do not automatically add code just so deserialization works; always confirm with the repository maintainer before adding such code.
   - such code may mask data that is required to be added upstream
   - as an example of what NOT to auto add:
     ```dart
      // Fallback for missing 'domainType' in JSON (should be added upstream)
      mergedStateJson['domainType'] = domainType;
     ```
