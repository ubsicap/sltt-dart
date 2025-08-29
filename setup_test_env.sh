#!/bin/bash

# SLTT Test Environment Setup (sourceable)
# Usage:
#   source ./setup_test_env.sh     # sets LD_LIBRARY_PATH in current shell
#   ./setup_test_env.sh            # copies libisar.so and prints instructions

# Detect whether the script is being sourced.
# In a sourced context `return` succeeds; in an executed script it fails.
if (return 0 2>/dev/null); then
  _SOURCED=1
else
  _SOURCED=0
fi

setup_test_env() {
  echo "🔧 Setting up test environment for Isar database..."

  ISAR_LIB_PATH="/home/epyle/repos/ericpyle/flutter-2/libisar.so"

  if [ -f "$ISAR_LIB_PATH" ]; then
    echo "✅ Found libisar.so at: $ISAR_LIB_PATH"

    TEST_LIB_DIR="/tmp/dart_test_libs"
    mkdir -p "$TEST_LIB_DIR"

    cp -f "$ISAR_LIB_PATH" "$TEST_LIB_DIR/"
    echo "📁 Copied libisar.so to: $TEST_LIB_DIR/"

    DEMO_DIR="/home/epyle/repos/ericpyle/flutter-2/examples/sync_manager_demo"
    if [ -d "$DEMO_DIR" ]; then
      cp -f "$ISAR_LIB_PATH" "$DEMO_DIR/"
      echo "📁 Copied libisar.so to: $DEMO_DIR/"
    fi

    # Export variables so they persist if this script is sourced.
    export LD_LIBRARY_PATH="$TEST_LIB_DIR:${LD_LIBRARY_PATH:-}"
    export ISAR_LIBRARY_PATH="$TEST_LIB_DIR/libisar.so"

    echo "🌍 Set environment variables:"
    echo "   LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    echo "   ISAR_LIBRARY_PATH=$ISAR_LIBRARY_PATH"

  else
    echo "❌ libisar.so not found at expected location: $ISAR_LIB_PATH"
    echo "🔍 Searching for libisar.so..."
    find /home/epyle/repos/ericpyle/flutter-2 -name "libisar.so" -type f || true
    return 1
  fi
}

# Run setup now:
setup_test_env

# If the script was executed (not sourced), inform the user how to persist env vars.
if [ "$_SOURCED" -eq 0 ]; then
  echo ""
  echo "ℹ️  Note: Running the script does not export variables into your current shell."
  echo "    To have LD_LIBRARY_PATH in your shell, run:"
  echo "      source ./setup_test_env.sh"
fi
