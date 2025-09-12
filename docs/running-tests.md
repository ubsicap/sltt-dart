# Running Tests

This document describes various ways to run tests and ensure the Isar native library is available for `dart test`.

## Option 1: VS Code Test Runner (Recommended)

The project now includes VS Code configurations for running tests with proper Isar setup:

1. **Run all tests**: Use the "Run Dart Tests (with Isar setup)" configuration in VS Code's Run and Debug panel
2. **Debug a specific test**: Open the test file and use "Debug Current Dart Test (with Isar setup)"

Both configurations automatically:
- Run the setup script to copy `libisar.so` to `/tmp/dart_test_libs`
- Set the `LD_LIBRARY_PATH` environment variable
- Use compact reporter and single concurrency

## Command line testing

If you prefer the command line, source the setup script then run `dart test`.

```bash
# Source once to set LD_LIBRARY_PATH in your current shell
source ./setup_test_env.sh

# Run all tests
dart test

# Run a specific test file
dart test test/my_test.dart

# Run tests that match a name pattern
dart test -n "my test name"
```

## Option 3: Manual Setup + dart test

If you prefer to run `dart test` directly:

There are two easy ways to ensure the Isar native library is available for `dart test`:

1) One‑shot setup (run and then export in the current shell session)

```bash
# Copy libisar.so to the test lib dir (does not export into your shell)
./setup_test_env.sh

# Export LD_LIBRARY_PATH for this shell session
export LD_LIBRARY_PATH="/tmp/dart_test_libs"

# Run tests
dart test
dart test test/my_test.dart
dart test -n "test pattern"
```

2) Sourceable setup (recommended when you want the env var to persist in your shell)

```bash
# Source the script so it sets LD_LIBRARY_PATH in your current shell
source ./setup_test_env.sh

# Verify
echo "$LD_LIBRARY_PATH"
ls -la /tmp/dart_test_libs/libisar.so

# Run tests
dart test
```

Sourcing is recommended when you plan to run multiple `dart test` commands during a session because it sets `LD_LIBRARY_PATH` in your current shell (no extra export required).

## Option 4: dart_test.yaml Configuration

The project includes a `dart_test.yaml` file that:

However, you still need to run `./setup_test_env.sh` once to copy the Isar library.

## Option 5: Shell Alias (Optional)

Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
alias dtest='export LD_LIBRARY_PATH="/tmp/dart_test_libs" && dart test'
```

Then use:
```bash
# Run setup once
./setup_test_env.sh

# Use alias
dtest
dtest test/my_test.dart
```

## Why the Library Setup is Needed

Dart tests run in isolated environments that don't automatically find the `libisar.so` native library. The setup scripts copy the library to a standard location (`/tmp/dart_test_libs`) and set the `LD_LIBRARY_PATH` environment variable so Isar can find it.

## Troubleshooting

If you get "Failed to load dynamic library" errors:

1. Check that `libisar.so` exists in the project root
2. Run `./setup_test_env.sh` to ensure the library is copied
3. Verify `LD_LIBRARY_PATH` is set: `echo $LD_LIBRARY_PATH`
4. Check that the library exists: `ls -la /tmp/dart_test_libs/libisar.so`
