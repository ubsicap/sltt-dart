#!/bin/bash

# SLTT Test Runner with Auto-Setup
# This script automatically sets up the test environment and runs tests
#
# Usage:
#   ./test.sh                                    # Run all tests in all packages
#   ./test.sh test/specific_test.dart           # Run specific test file in workspace root
#   ./test.sh -n "test name"                    # Run tests matching name in workspace root
#   USE_DEV_CLOUD=true ./test.sh                # Run all package tests with AWS dev cloud
#   USE_CLOUD_STORAGE=true ./test.sh            # Run all package tests with local cloud storage
#
# Environment Variables:
#   USE_DEV_CLOUD=true       Use AWS Lambda dev cloud instead of localhost
#   USE_CLOUD_STORAGE=true   Use local cloud storage server for API tests

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
    # If no arguments provided, run tests in all packages
    if [ $# -eq 0 ]; then
        echo "🏗️ Running tests in all packages..."
        
        # Test packages with actual test files
        PACKAGES=("packages/sync_manager" "packages/aws_backend" "packages/sltt_core")
        
        for package in "${PACKAGES[@]}"; do
            if [ -d "$package/test" ]; then
                echo "📦 Testing $package..."
                cd "$package"
                
                # Pass through environment variables to dart test
                if [ "$USE_DEV_CLOUD" = "true" ]; then
                    echo "🌩️ Using DEV CLOUD for testing"
                    USE_DEV_CLOUD=true LD_LIBRARY_PATH=/tmp/dart_test_libs dart test
                elif [ "$USE_CLOUD_STORAGE" = "true" ]; then
                    echo "☁️ Using LOCAL CLOUD STORAGE for testing"
                    USE_CLOUD_STORAGE=true LD_LIBRARY_PATH=/tmp/dart_test_libs dart test
                else
                    echo "🏠 Using LOCALHOST for testing"
                    LD_LIBRARY_PATH=/tmp/dart_test_libs dart test
                fi
                
                # Return to workspace root
                cd - > /dev/null
                echo ""
            else
                echo "⏭️ Skipping $package (no test directory)"
            fi
        done
    else
        # Arguments provided, pass them to dart test in workspace root
        # Pass through environment variables to dart test
        if [ "$USE_DEV_CLOUD" = "true" ]; then
            echo "🌩️ Using DEV CLOUD for testing"
            USE_DEV_CLOUD=true LD_LIBRARY_PATH=/tmp/dart_test_libs dart test "$@"
        elif [ "$USE_CLOUD_STORAGE" = "true" ]; then
            echo "☁️ Using LOCAL CLOUD STORAGE for testing"
            USE_CLOUD_STORAGE=true LD_LIBRARY_PATH=/tmp/dart_test_libs dart test "$@"
        else
            echo "🏠 Using LOCALHOST for testing"
            LD_LIBRARY_PATH=/tmp/dart_test_libs dart test "$@"
        fi
    fi

else
    echo "❌ libisar.so not found at expected location: $ISAR_LIB_PATH"
    echo "🔍 Searching for libisar.so..."
    find /home/epyle/repos/ericpyle/flutter-2 -name "libisar.so" -type f 2>/dev/null
    echo "❌ Cannot run tests without Isar library"
    exit 1
fi
