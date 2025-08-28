#!/usr/bin/env bash
set -euo pipefail

# Start a local sync_manager server and run sltt_core network tests against it.
# Usage: ./scripts/run_network_tests_against_local_storage.sh [port]

PORT=${1:-8081}

echo "Starting local test server on port $PORT..."

# Start Dart server in background
dart run packages/sync_manager/bin/run_local_test_server.dart --port $PORT &
SERVER_PID=$!

trap 'echo "Stopping server..."; kill $SERVER_PID || true; wait $SERVER_PID 2>/dev/null || true' EXIT

# Give server a moment to start
sleep 1

export API_BASE_URL="http://localhost:$PORT"
echo "Running network tests in sltt_core with API_BASE_URL=$API_BASE_URL"
./test.sh packages/sltt_core

echo "Network tests finished"
