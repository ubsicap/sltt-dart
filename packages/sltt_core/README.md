# SLTT Dart

A comprehensive offline-first sync system for Flutter applications with multi-server architecture, change tracking, and REST API interface.

## Features

- **Multi-Storage Architecture**: Separate storage services for outsyncs, downsyncs, and cloud simulation
- **Advanced Sync Management**: Bi-directional sync with outsync and downsync capabilities
- **REST API Servers**: Multiple API servers for different storage types with sync ## License

This project is part of the SLTT Dart sync system.points
- **Offline-First Storage**: Uses Isar for local data persistence with automatic change tracking
- **Developer-Friendly**: Easy to debug, test, and extend with comprehensive tooling System

A shared Dart backend codebase for offline-first, LAN-collaborative, cloud-sync applications with a comprehensive sync management system and REST API interface.

## Features

- **Multi-Storage Architecture**: Separate storage services for outsyncs, downsyncs, and cloud simulation
- **Advanced Sync Management**: Bi-directional sync with outsync and downsync capabilities
- **REST API Servers**: Multiple API servers for different storage types with sync endpoints
- **Offline-First Storage**: Uses Isar for local data persistence with automatic change tracking
- **Developer-Friendly**: Easy to debug, test, and extend with comprehensive tooling

## Architecture Overview

The system consists of three main storage services:
- **Outsyncs Storage**: Stores local changes that need to be uploaded to the cloud
- **Downsyncs Storage**: Stores changes received from the cloud
- **Cloud Storage**: Simulates cloud-based storage (read-only for updates/deletes)

Each storage service has its own REST API server:
- **Outsyncs Server**: Port 8082 - Full CRUD operations
- **Downsyncs Server**: Port 8081 - Full CRUD operations
- **Cloud Storage Server**: Port 8083 - Read and create only (simulates cloud constraints)

## Quick Start

### 1. Install Dependencies

```bash
dart pub get
```

### 2. Install Isar Native Library

The server uses Isar database which requires a native library. Download the appropriate library for your platform:

#### Linux (x64)
```bash
curl -L https://github.com/isar/isar/releases/download/3.1.0%2B1/libisar_linux_x64.so -o bin/libisar.so
chmod +x bin/libisar.so
```

#### macOS (x64)
```bash
curl -L https://github.com/isar/isar/releases/download/3.1.0%2B1/libisar_macos_x64.dylib -o bin/libisar.dylib
chmod +x bin/libisar.dylib
```

#### macOS (ARM64)
```bash
curl -L https://github.com/isar/isar/releases/download/3.1.0%2B1/libisar_macos_arm64.dylib -o bin/libisar.dylib
chmod +x bin/libisar.dylib
```

#### Windows (x64)
```powershell
curl -L https://github.com/isar/isar/releases/download/3.1.0%2B1/isar_windows_x64.dll -o bin/isar.dll
```

### 3. Generate Code

```bash
dart run build_runner build
```

### 4. Start the Sync System

#### Option A: Start All Servers (Recommended for Demo)
```bash
dart run bin/server_runner.dart start-all
```

#### Option B: Start Individual Servers
```bash
# Start outsyncs server (port 8082)
dart run bin/server_runner.dart start outsyncs

# Start downsyncs server (port 8081)
dart run bin/server_runner.dart start downsyncs

# Start cloud storage server (port 8083)
dart run bin/server_runner.dart start cloud
```

### 5. Run the Interactive Demo
```bash
dart run bin/demo_sync_system.dart
```

This will demonstrate the complete sync workflow with sample data.

## Usage

### Server Management

```bash
# Start all servers
dart run bin/server_runner.dart start-all

# Check server status
dart run bin/server_runner.dart status

# Stop all servers
dart run bin/server_runner.dart stop-all

# Perform sync operations
dart run bin/server_runner.dart sync         # Full sync (outsync + downsync)
dart run bin/server_runner.dart outsync      # Upload local changes to cloud
dart run bin/server_runner.dart downsync    # Download cloud changes locally
dart run bin/server_runner.dart sync-status # Show sync statistics
```

### API Endpoints

All servers support the following endpoints:

#### Health Check
```
GET /health
```

#### API Documentation
```
GET /api/help                     # Get comprehensive API documentation
```

#### Change Management
```
GET  /api/changes                  # Get all changes (with optional query parameters)
GET  /api/changes/{seq}           # Get specific change by sequence number
POST /api/changes                 # Create new changes (array format)
```

**GET /api/changes Query Parameters:**
- `cursor` (optional): Starting sequence number (exclusive). Only returns changes with sequence numbers greater than this value.
- `limit` (optional): Maximum number of results to return. Must be a positive integer, maximum value is 1000.

**Example Usage:**
```bash
# Get all changes
GET /api/changes

# Get changes after sequence 50
GET /api/changes?cursor=50

# Get up to 20 changes
GET /api/changes?limit=20

# Get up to 10 changes after sequence 100
GET /api/changes?cursor=100&limit=10
```

**Response Format:**
```json
{
  "changes": [
    {
      "seq": 101,
      "entityType": "Document",
      "operation": "create",
      "entityId": "doc-123",
      "timestamp": "2025-07-26T15:30:00.000Z",
      "data": {"title": "My Document"}
    }
  ],
  "count": 1,
  "timestamp": "2025-07-26T15:30:00.000Z",
  "cursor": 101  // Present if there are more results available
}
```

#### Statistics
```
GET /api/stats                    # Get change and entity type statistics
```

**Note**: PUT and DELETE endpoints have been removed. The API now follows append-only change log semantics for data integrity.

### Sync Workflow

1. **Local Changes**: Create changes in the outsyncs storage
2. **Outsync**: Sync manager uploads changes from outsyncs to cloud storage
3. **Cleanup**: Successfully uploaded changes are removed from outsyncs storage
4. **Downsync**: Sync manager downloads new changes from cloud to downsyncs storage
5. **Full Sync**: Combines outsync and downsync operations

### Example API Usage

#### Create a Change
```bash
curl -X POST http://localhost:8082/api/changes \
  -H "Content-Type: application/json" \
  -d '{
    "entityType": "Document",
    "operation": "create",
    "entityId": "doc-123",
    "data": {
      "title": "My Document",
      "content": "Document content"
    }
  }'
```

#### Use Sync Endpoint
```bash
curl -X POST http://localhost:8083/api/changes/sync/0 \
  -H "Content-Type: application/json" \
  -d '[{
    "entityType": "Document",
    "operation": "update",
    "entityId": "doc-123",
    "data": {"title": "Updated Document"}
  }]'
```

#### Get Changes with Pagination
```bash
curl "http://localhost:8081/api/changes?cursor=10&limit=5"
```

## Testing

### Run Unit Tests

#### Local Testing (Default)
```bash
# Run sync manager tests with localhost servers
dart test test/sync_manager_test.dart

# Or using the test runner script
LD_LIBRARY_PATH=/tmp/dart_test_libs dart test test/sync_manager_test.dart
```

#### Dev Cloud Testing
```bash
# Run sync manager tests against AWS dev cloud
USE_DEV_CLOUD=true LD_LIBRARY_PATH=/tmp/dart_test_libs dart test test/sync_manager_test.dart
```

#### API Endpoints Testing
```bash
# Run API endpoints tests with local outsyncs storage (default)
LD_LIBRARY_PATH=/tmp/dart_test_libs dart test test/api_endpoints_test.dart

# Run API endpoints tests with local cloud storage server
USE_CLOUD_STORAGE=true LD_LIBRARY_PATH=/tmp/dart_test_libs dart test test/api_endpoints_test.dart

# Run API endpoints tests against AWS dev cloud
USE_DEV_CLOUD=true LD_LIBRARY_PATH=/tmp/dart_test_libs dart test test/api_endpoints_test.dart
```

**Environment Variables:**
- `USE_DEV_CLOUD=true`: Configures tests to use the AWS Lambda dev cloud instead of localhost
- `USE_CLOUD_STORAGE=true`: Configures API tests to use local cloud storage server instead of outsyncs storage
- `LD_LIBRARY_PATH=/tmp/dart_test_libs`: Required for Isar database library access

### Run API Tests
```bash
# Test complete sync system
dart run bin/test_sync_manager.dart

# Test operation field functionality
dart run bin/test_operation_field.dart
```

### Manual Testing
1. Start all servers: `dart run bin/server_runner.dart start-all`
2. Add changes to outsyncs: `POST http://localhost:8082/api/changes`
3. Perform outsync: `dart run bin/server_runner.dart outsync`
4. Check cloud storage: `GET http://localhost:8083/api/changes`
5. Perform downsync: `dart run bin/server_runner.dart downsync`
6. Check downsyncs: `GET http://localhost:8081/api/changes`

## Development

### File Structure
```
lib/core/
├── api/
│   └── enhanced_rest_api_server.dart    # Multi-storage API server
├── models/
│   ├── change_log_entry.dart            # Change log data model
│   └── change_log_entry.g.dart          # Generated Isar schema
├── server/
│   ├── multi_server_launcher.dart       # Server management utility
│   └── server_ports.dart                # Port configuration constants
├── storage/
│   └── shared_storage_service.dart      # Unified storage services
└── sync/
    └── sync_manager.dart                 # Sync orchestration

bin/
├── demo_sync_system.dart                # Interactive demo
├── server.dart                          # Main server executable
├── server_runner.dart                   # Server management CLI
├── test_operation_field.dart            # Operation field tests
└── test_sync_manager.dart               # Sync system tests
```

### Key Components

#### Storage Services
- **OutsyncsStorageService**: Manages local changes awaiting upload
- **DownsyncsStorageService**: Manages changes received from cloud
- **CloudStorageService**: Simulates cloud storage (append-only)

#### Sync Manager
- **outsyncToCloud()**: Uploads local changes and cleans up
- **downsyncFromCloud()**: Downloads remote changes using cursor
- **performFullSync()**: Combines both operations
- **getSyncStatus()**: Provides sync statistics

#### Enhanced API Server
- Supports multiple storage backends (outsyncs, downsyncs, cloud)
- Implements change log semantics with append-only operations
- Provides sequence mapping for sync operations
- Filters outdated changes from sync operations

### Adding New Features

1. **New Entity Types**: Update the `ChangeLogEntry` model and regenerate code
2. **Custom Sync Logic**: Extend the `SyncManager` class
3. **Additional Endpoints**: Add routes to `EnhancedRestApiServer`
4. **Storage Backends**: Implement new storage services following existing patterns

## Troubleshooting

### Common Issues

1. **Server won't start**: Check if ports are already in use
2. **Sync fails**: Ensure all servers are running and accessible
3. **Database errors**: Verify Isar native library is installed correctly
4. **Build errors**: Run `dart run build_runner clean` then `dart run build_runner build`
```

### 4. Run the Server

```bash
dart run bin/server.dart
```

### 5. Test the System

```bash
# Test the complete sync system
dart run bin/test_sync_manager.dart

# Or run the interactive demo
dart run bin/demo_sync_system.dart
```

## Architecture

### Core Components

- **`ChangeLogEntry`**: Change log data model with Isar schema
- **`SharedStorageService`**: Unified storage service with sync-aware filtering
- **`SyncManager`**: Orchestrates sync between outsyncs, downsyncs, and cloud
- **`EnhancedRestApiServer`**: Multi-storage API server with change log semantics
- **`MultiServerLauncher`**: Manages multiple server instances

### Sync Architecture

The sync system uses a three-tier change log architecture:

1. **Outsyncs Storage**: Local changes awaiting upload to cloud
2. **Cloud Storage**: Centralized change log (append-only)
3. **Downsyncs Storage**: Changes received from cloud

### Data Flow

```
Outsyncs → Cloud Storage → Downsyncs
    ↑           ↓             ↓
Local Clients ← SyncManager → Application State
```

## Development

### Code Generation

The project uses code generation for Isar entities. Run this after modifying models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Adding New Entities

1. Create your entity class extending `BaseEntity`
2. Add appropriate Isar annotations
3. Register the schema in `LocalStorageService`
4. Run code generation
5. Add API endpoints in `RestApiServer`

### Extending Sync Providers

The `LANSyncProvider` and `CloudSyncProvider` are currently stubbed. To implement:

1. **LAN Provider**: Implement mDNS discovery, WebSocket/HTTP communication
2. **Cloud Provider**: Implement AWS DynamoDB/S3 integration

## Configuration

Default configuration:
- Server Port: 8080
- Sync Interval: 5 minutes
- Database: Local Isar database
- Object IDs: UUIDv7

## Troubleshooting

### "Failed to load dynamic library" Error

If you see an error like:
```
Failed to load dynamic library 'libisar.so': libisar.so: cannot open shared object file
```

This means the Isar native library is missing. Follow the **Install Isar Native Library** step above for your platform.

### "Permission denied" Error

If you get permission errors on Linux/macOS, make sure the native library is executable:
```bash
chmod +x bin/libisar.so   # Linux
chmod +x bin/libisar.dylib  # macOS
```

### Build Runner Issues

If code generation fails, try cleaning and rebuilding:
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Port Already in Use

If ports 8081, 8082, or 8083 are already in use, the servers will fail to start. You can:
1. Stop the processes using these ports
2. Or modify the port constants in `lib/core/server/server_ports.dart`

## Future Enhancements

- [ ] Add operation field validation against entity state snapshots
- [ ] Implement compressed change log storage
- [ ] Add real-time WebSocket notifications for sync events
- [ ] Implement conflict resolution for concurrent changes
- [ ] Add authentication and authorization
- [ ] Add cloud storage backend (AWS S3, Google Cloud, etc.)
- [ ] Implement change log compaction and archiving
- [ ] Add metrics and monitoring capabilities

## License

This project is part of the Dart shared backend codebase.
