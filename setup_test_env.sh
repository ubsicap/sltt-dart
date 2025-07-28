#!/bin/bash

# SLTT Test Environment Setup
# This script copies the Isar native library to make it available for tests

echo "🔧 Setting up test environment for Isar database..."

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

    # Set environment variable so Isar can find it
    export LD_LIBRARY_PATH="$TEST_LIB_DIR:$LD_LIBRARY_PATH"
    export ISAR_LIBRARY_PATH="$TEST_LIB_DIR/libisar.so"

    echo "🌍 Set environment variables:"
    echo "   LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    echo "   ISAR_LIBRARY_PATH=$ISAR_LIBRARY_PATH"

    echo ""
    echo "🧪 Running integration tests with Isar support..."
    cd /home/epyle/repos/ericpyle/flutter-2
    dart test test/integration_test.dart

else
    echo "❌ libisar.so not found at expected location: $ISAR_LIB_PATH"
    echo "🔍 Searching for libisar.so..."
    find /home/epyle/repos/ericpyle/flutter-2 -name "libisar.so" -type f
fi
