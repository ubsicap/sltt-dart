**Agent Instruction:**

- first try running `dart test [options]` rather than using special scripts to run tests.
  - if isar complains about missing native library, remind user to source the setup script, eg. `./setup_test_env.sh` before running `dart test` to ensure the Isar native library is available.
- Always keep the `/api/help` documentation in sync with the actual API handlers implemented in `lib/src/api/base_rest_api_server.dart` (`_handleApiDocs`).
- Whenever you add, remove, or change any API endpoint or its behavior, immediately update the `/api/help` docs to reflect those changes.
 - Do not add fallback scanning code without prior confirmation from the repository maintainer.
   Such fallback code increases complexity and can mask issues in upstream data; ask for confirmation before adding it.

