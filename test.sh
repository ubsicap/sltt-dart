#!/bin/bash

# SLTT Test Runner with Auto-Setup
# This script automatically sets up the test environment and runs tests

echo "🔧 Setting up test environment..."

# Find the libisar.so file
ISAR_LIB_PATH="/home/epyle/repos/ericpyle/flutter-2/libisar.so"

if [ -f "$ISAR_LIB_PATH" ]; then
    echo "✅ Found libisar.so at: $ISAR_LIB_PATH"

    # Create a temporary directory that Dart tests can access
    TEST_LIB_DIR="/tmp/dart_test_libs"
    mkdir -p "$TEST_LIB_DIR"

    # Copy the library
    cp "$ISAR_LIB_PATH" "$TEST_LIB_DIR/"
    echo "📁 Copied libisar.so to: $TEST_LIB_DIR/"

    echo "🧪 Running dart test with proper environment..."
    # Run dart test with all arguments passed through
    # LD_LIBRARY_PATH=/tmp/dart_test_libs dart test "$@"
    LD_LIBRARY_PATH=/tmp/dart_test_libs dart run run_tests.dart

else
    echo "❌ libisar.so not found at expected location: $ISAR_LIB_PATH"
    echo "🔍 Searching for libisar.so..."
    find /home/epyle/repos/ericpyle/flutter-2 -name "libisar.so" -type f 2>/dev/null
    echo "❌ Cannot run tests without Isar library"
    exit 1
fi
