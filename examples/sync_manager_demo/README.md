# Sync Manager Demo

Interactive demo and test suite for the SLTT Core sync system.

## Quick Start

1. Install dependencies:
   ```bash
   dart pub get
   ```

2. Run the interactive demo:
   ```bash
   dart run demo_sync_system.dart
   ```

## Available Scripts

- **`demo_sync_system.dart`** - Interactive demonstration of the sync system
- **`server.dart`** - Start individual or multiple servers
- **`server_runner.dart`** - Command-line server management and sync operations
- **`test_sync_manager.dart`** - Comprehensive test suite for sync functionality
- **`test_operation_field.dart`** - Tests for operation field validation

## Usage Examples

### Start All Servers
```bash
dart run server_runner.dart start-all
```

### Run Sync Operations
```bash
dart run server_runner.dart sync         # Full sync
dart run server_runner.dart outsync      # Upload local changes
dart run server_runner.dart downsync     # Download remote changes
```

### Run Tests
```bash
dart run test_sync_manager.dart
dart run test_operation_field.dart
```

## Dependencies

This demo depends on the `sltt_core` package located at `../../packages/sltt_core`.
