# GitHub Copilot Instructions


## Important Testing Requirements

### Isar Database Dependencies

This project uses Isar database which requires native library dependencies. When running tests or working with the `sync_manager` package:

1. Source the provided setup script to make the native Isar library available to the Dart VM in your current shell session.

```bash
# Source once to export LD_LIBRARY_PATH (Linux/macOS) or set up environment in your shell
source ./setup_test_env.sh

# Then run tests directly
dart test
```

On Windows, use the PowerShell setup script instead:

```powershell
# Run in PowerShell once to set up the environment for the current session
.\setup_test_env.ps1

# Then run tests (PowerShell)
dart test
```

### Why This is Required

- The `sync_manager` package uses Isar database with native bindings
- Tests require the Isar native library (e.g., `libisar.so` or `isar.dll`) to be discoverable by the test processes
- The `setup_test_env.*` scripts copy the native library into a known location and set the appropriate environment variable(s) so `dart test` can find them

### Available Test Commands

```bash
# Run all tests after sourcing the setup script
source ./setup_test_env.sh && dart test

# Run tests for a specific package
source ./setup_test_env.sh && dart test packages/sync_manager

# Run a specific test file
source ./setup_test_env.sh && dart test packages/sync_manager/test/sync_manager_test.dart

# Use VS Code tasks that include setup (some tasks in .vscode/tasks.json run the setup script)
```

### Package Structure

- **sltt_core** - Backend-agnostic base classes (no Isar dependencies)
- **sync_manager** - Isar-based client implementations (requires libisar.so)
- **aws_backend** - Uses sltt_core only (no Isar dependencies)

### Common Errors to Avoid

If you see this error:
```
Failed to load dynamic library 'libisar.so': libisar.so: cannot open shared object file
```

**Solution**: Source `./setup_test_env.sh` (or run the PowerShell setup on Windows) before running `dart test`.

### Development Workflow

1. Make code changes
2. Run tests: `source ./setup_test_env.sh && dart test`
3. For continuous testing in IDE: Use VS Code tasks
4. For CI/CD: Ensure scripts use proper environment setup

## Architecture Notes

- Created sync_manager package to separate Isar-specific code from backend-agnostic sltt_core
- This allows aws_backend to use sltt_core without Isar dependencies
- Client applications use sync_manager for full Isar-based storage and sync functionality

## Valid Dart CLI Commands (v3.8.2)

### Testing Commands
```bash
# ✅ CORRECT - Run tests
dart test
dart test test/specific_test.dart
dart test --name "test name pattern"
dart test --tags "integration"
dart test --exclude-tags "slow"
dart test --platform vm
dart test --platform chrome
dart test --concurrency 4
dart test --timeout 60s
dart test --coverage coverage/
dart test --reporter compact
dart test --reporter json
dart test --no-fatal-warnings

# ❌ INVALID - These options don't exist
dart test -c                     # Use --compiler instead
dart test --chain-stack-traces   # Use --[no-]chain-stack-traces
dart test --verbose              # Use dart -v test instead
```

### Analysis Commands
```bash
# ✅ CORRECT - Analyze code
dart analyze
dart analyze lib/
dart analyze --fatal-infos
dart analyze --no-fatal-warnings

# ❌ INVALID - These options don't exist
dart analyze --no-fatal-warnings  # This is actually valid
dart analyze -c                   # No -c option for analyze
dart analyze --verbose            # Use dart -v analyze instead
```

### Running Programs
```bash
# ✅ CORRECT - Run Dart programs
dart run
dart run bin/my_script.dart
dart run package:my_package/script.dart
dart run --enable-asserts
dart run --observe=8080
dart run --verbosity=error

# ❌ INVALID - These options don't exist
dart run -c                      # No -c option for run
dart run --debug                 # Use --observe instead
dart run --production            # No such option
```

### Global Options (available for all commands)
```bash
# ✅ CORRECT - Global options
dart -v <command>               # Verbose output
dart --version                  # Show Dart version
dart --help                     # Show help
dart --enable-analytics         # Enable analytics
dart --disable-analytics        # Disable analytics
dart --suppress-analytics       # Suppress for this run

# ❌ INVALID - These don't exist
dart -c                         # No global -c option
dart --debug                    # Not a global option
dart --quiet                    # Use normal output instead
```

### Package Management
```bash
# ✅ CORRECT - Pub commands
dart pub get
dart pub upgrade
dart pub deps
dart pub run <package>:<script>
dart pub global activate <package>

# ✅ CORRECT - Other commands
dart create <project_name>
dart format lib/
dart doc
dart compile exe bin/my_app.dart
```
