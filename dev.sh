#!/bin/bash
# SLTT Dart Development Helper Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
CORE_DIR="$ROOT_DIR/packages/sltt_core"
DEMO_DIR="$ROOT_DIR/examples/sync_manager_demo"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_help() {
    echo "SLTT Dart Development Helper"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup     - Install all dependencies and generate code"
    echo "  deps      - Install dependencies for all packages"
    echo "  gen       - Generate code for core package"
    echo "  clean     - Clean build artifacts"
    echo "  analyze   - Run analysis on all packages"
    echo "  demo      - Run the interactive demo"
    echo "  test      - Run all tests"
    echo "  servers   - Start all servers"
    echo "  status    - Check server status"
    echo "  sync      - Perform full sync operation"
    echo "  help      - Show this help message"
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

install_deps() {
    print_step "Installing dependencies for sltt_core..."
    cd "$CORE_DIR"
    dart pub get

    print_step "Installing dependencies for sync_manager_demo..."
    cd "$DEMO_DIR"
    dart pub get

    print_success "All dependencies installed"
}

generate_code() {
    print_step "Generating code for sltt_core..."
    cd "$CORE_DIR"
    dart run build_runner build --delete-conflicting-outputs
    print_success "Code generation complete"
}

clean_build() {
    print_step "Cleaning build artifacts..."
    cd "$CORE_DIR"
    dart run build_runner clean || true
    rm -rf .dart_tool/build

    cd "$DEMO_DIR"
    rm -rf .dart_tool/build

    print_success "Build artifacts cleaned"
}

analyze_code() {
    print_step "Analyzing sltt_core..."
    cd "$CORE_DIR"
    dart analyze --no-fatal-warnings

    print_step "Analyzing sync_manager_demo..."
    cd "$DEMO_DIR"
    dart analyze --no-fatal-warnings

    print_success "Analysis complete"
}

run_demo() {
    print_step "Starting interactive demo..."
    cd "$DEMO_DIR"
    dart run demo_sync_system.dart
}

run_tests() {
    print_step "Running sync manager tests..."
    cd "$DEMO_DIR"
    dart run test_sync_manager.dart

    print_step "Running operation field tests..."
    dart run test_operation_field.dart

    print_success "All tests complete"
}

start_servers() {
    print_step "Starting all servers..."
    cd "$DEMO_DIR"
    dart run server_runner.dart start-all
}

check_status() {
    print_step "Checking server status..."
    cd "$DEMO_DIR"
    dart run server_runner.dart status
}

run_sync() {
    print_step "Performing full sync..."
    cd "$DEMO_DIR"
    dart run server_runner.dart sync
}

setup_project() {
    print_step "Setting up SLTT Dart project..."
    install_deps
    generate_code
    analyze_code
    print_success "Project setup complete!"
    echo ""
    print_step "Next steps:"
    echo "  - Run './dev.sh demo' to try the interactive demo"
    echo "  - Run './dev.sh servers' to start all servers"
    echo "  - Run './dev.sh test' to run all tests"
}

# Main command handling
case "${1:-help}" in
    setup)
        setup_project
        ;;
    deps)
        install_deps
        ;;
    gen)
        generate_code
        ;;
    clean)
        clean_build
        ;;
    analyze)
        analyze_code
        ;;
    demo)
        run_demo
        ;;
    test)
        run_tests
        ;;
    servers)
        start_servers
        ;;
    status)
        check_status
        ;;
    sync)
        run_sync
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        print_help
        exit 1
        ;;
esac
