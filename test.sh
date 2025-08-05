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

        # Test packages in specified order
        PACKAGES=("packages/sltt_core" "packages/aws_backend" "packages/sync_manager")

        run_package_tests() {
            PKG_PATH="$1"
            shift
            if [ -d "$PKG_PATH/test" ]; then
                echo "📦 Testing $PKG_PATH..."
                cd "$PKG_PATH"

                # Build command array to preserve quotes
                CMD=(dart test "$@" --fail-fast --reporter compact --concurrency 1)

                # Set up environment variables
                export LD_LIBRARY_PATH="/tmp/dart_test_libs"
                if [ -n "$CLOUD_BASE_URL" ]; then
                    echo "🌐 Using CLOUD_BASE_URL: $CLOUD_BASE_URL"
                    export CLOUD_BASE_URL="$CLOUD_BASE_URL"
                fi
                if [ "$USE_DEV_CLOUD" = "true" ]; then
                    echo "🌩️ Using DEV CLOUD for testing"
                    export USE_DEV_CLOUD="true"
                elif [ "$USE_CLOUD_STORAGE" = "true" ]; then
                    echo "☁️ Using LOCAL CLOUD STORAGE for testing"
                    export USE_CLOUD_STORAGE="true"
                else
                    echo "🏠 Using LOCALHOST for testing"
                fi

                # Execute the command
                "${CMD[@]}"
                TEST_EXIT_CODE=$?
                cd - > /dev/null
                echo ""
                if [ $TEST_EXIT_CODE -ne 0 ]; then
                    echo "❌ Tests failed in $PKG_PATH. Stopping further tests."
                    exit $TEST_EXIT_CODE
                fi
            else
                echo "⏭️ Skipping $PKG_PATH (no test directory)"
            fi
        }

        # If arguments are package paths, only run those (in provided order)
        PKG_ARGS=()
        for arg in "$@"; do
            if [[ "$arg" == packages/* ]]; then
                PKG_ARGS+=("$arg")
            fi
        done

        if [ ${#PKG_ARGS[@]} -gt 0 ]; then
            for pkg in "${PKG_ARGS[@]}"; do
                run_package_tests "$pkg"
            done
        else
            for package in "${PACKAGES[@]}"; do
                run_package_tests "$package"
            done
        fi
    else
        # Arguments provided
        run_package_tests() {
            PKG_PATH="$1"
            shift
            if [ -d "$PKG_PATH/test" ]; then
                echo "📦 Testing $PKG_PATH..."
                cd "$PKG_PATH"

                # Build command array to preserve quotes
                CMD=(dart test "$@" --fail-fast --reporter compact --concurrency 1)

                # Set up environment variables
                export LD_LIBRARY_PATH="/tmp/dart_test_libs"
                if [ -n "$CLOUD_BASE_URL" ]; then
                    echo "🌐 Using CLOUD_BASE_URL: $CLOUD_BASE_URL"
                    export CLOUD_BASE_URL="$CLOUD_BASE_URL"
                fi
                if [ "$USE_DEV_CLOUD" = "true" ]; then
                    echo "🌩️ Using DEV CLOUD for testing"
                    export USE_DEV_CLOUD="true"
                elif [ "$USE_CLOUD_STORAGE" = "true" ]; then
                    echo "☁️ Using LOCAL CLOUD STORAGE for testing"
                    export USE_CLOUD_STORAGE="true"
                else
                    echo "🏠 Using LOCALHOST for testing"
                fi

                # Execute the command
                "${CMD[@]}"
                cd - > /dev/null
            else
                echo "⏭️ Skipping $PKG_PATH (no test directory)"
            fi
        }

        PKG_ARGS=()
        OTHER_ARGS=()
        for arg in "$@"; do
            if [[ "$arg" == packages/* ]]; then
                PKG_ARGS+=("$arg")
            else
                OTHER_ARGS+=("$arg")
            fi
        done

        if [ ${#PKG_ARGS[@]} -gt 0 ]; then
            for pkg in "${PKG_ARGS[@]}"; do
                run_package_tests "$pkg" "${OTHER_ARGS[@]}"
            done
        else
            # Otherwise, run tests in workspace root
            CMD=(dart test "$@" --fail-fast --reporter compact --concurrency 1)

            # Set up environment variables
            export LD_LIBRARY_PATH="/tmp/dart_test_libs"
            if [ -n "$CLOUD_BASE_URL" ]; then
                echo "🌐 Using CLOUD_BASE_URL: $CLOUD_BASE_URL"
                export CLOUD_BASE_URL="$CLOUD_BASE_URL"
            fi
            if [ "$USE_DEV_CLOUD" = "true" ]; then
                echo "🌩️ Using DEV CLOUD for testing"
                export USE_DEV_CLOUD="true"
            elif [ "$USE_CLOUD_STORAGE" = "true" ]; then
                echo "☁️ Using LOCAL CLOUD STORAGE for testing"
                export USE_CLOUD_STORAGE="true"
            else
                echo "🏠 Using LOCALHOST for testing"
            fi

            # Execute the command
            "${CMD[@]}"
        fi
    fi

else
    echo "❌ libisar.so not found at expected location: $ISAR_LIB_PATH"
    echo "🔍 Searching for libisar.so..."
    find /home/epyle/repos/ericpyle/flutter-2 -name "libisar.so" -type f 2>/dev/null
    echo "❌ Cannot run tests without Isar library"
    exit 1
fi
