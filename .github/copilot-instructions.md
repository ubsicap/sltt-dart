# GitHub Copilot Instructions

## Important Testing Requirements

### Isar Database Dependencies

This project uses Isar database which requires native library dependencies. When running tests or working with the sync_manager package:

**ALWAYS use the provided test setup scripts** instead of running `dart test` directly:

```bash
# ✅ CORRECT - Use test.sh for proper Isar library setup
./test.sh

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

# Run specific test file
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
