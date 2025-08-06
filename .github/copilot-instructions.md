# GitHub Copilot Instructions

## Important Testing Requirements

### Isar Database Dependencies

This project uses Isar database which requires native library dependencies. When running tests or working with the sync_manager package:

**ALWAYS use the provided test setup scripts** instead of running `dart test` directly:

```bash
# ✅ CORRECT - Use test.sh for proper Isar library setup
./test.sh

# ✅ CORRECT - Run tests for specific package
./test.sh packages/sync_manager

# ✅ CORRECT - Run specific test file
./test.sh packages/sync_manager test/sync_manager_test.dart

# ✅ CORRECT - Use VS Code tasks that include setup
# Ctrl+Shift+P → "Tasks: Run Task" → "Run Tests with Setup"
# Ctrl+Shift+P → "Tasks: Run Task" → "Run Integration Tests"

# ❌ INCORRECT - Don't run dart test directly (will fail with libisar.so errors)
dart test
```

### Why This is Required

- The sync_manager package uses Isar database with native bindings
- Tests require `libisar.so` library to be available via `LD_LIBRARY_PATH`
- The `test.sh` script automatically:
  1. Copies `libisar.so` to `/tmp/dart_test_libs/`
  2. Sets `LD_LIBRARY_PATH=/tmp/dart_test_libs`
  3. Runs tests with proper environment

### Available Test Commands

```bash
# Run all tests with setup
./test.sh

# Run tests for specific package
./test.sh packages/sync_manager

# Run specific test file
./test.sh packages/sync_manager test/sync_manager_test.dart

# Run integration tests
./test.sh test/integration_test.dart

# Use VS Code tasks (recommended in IDE)
# - "Run Tests with Setup"
# - "Run Integration Tests"
# - "Setup Test Environment"
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

**Solution**: Use `./test.sh` instead of `dart test` directly.

### Development Workflow

1. Make code changes
2. Run tests: `./test.sh`
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
