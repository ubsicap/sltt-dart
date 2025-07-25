# Flutter-2 Sync System

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

#### Change Management
```
GET  /api/changes                  # Get all changes (with cursor/limit pagination)
GET  /api/changes/{seq}           # Get specific change by sequence number
POST /api/changes                 # Create new change
POST /api/changes/sync/{seq}      # Sync endpoint (store changes + return changes since seq)
PUT  /api/changes/{seq}           # Update existing change (not available on cloud storage)
DELETE /api/changes/{seq}         # Delete change (not available on cloud storage)
```

#### Statistics
```
GET /api/stats                    # Get change and entity type statistics
```

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

### Run API Tests
```bash
# Test original REST API
dart run bin/test_api.dart

# Test original API on specific server
dart run bin/test_api.dart http://localhost:8082

# Test complete sync system
dart run bin/test_sync_manager.dart
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
│   ├── enhanced_rest_api_server.dart    # New multi-storage API server
│   └── rest_api_server.dart             # Original API server (with sync endpoint)
├── models/
│   └── change_log_entry.dart            # Change log data model
├── server/
│   └── multi_server_launcher.dart       # Server management utility
├── storage/
│   ├── cloud_storage_service.dart       # Cloud storage simulation
│   ├── downsyncs_storage_service.dart   # Downsyncs storage
│   ├── local_storage_service.dart       # Original storage service
│   └── outsyncs_storage_service.dart     # Outsyncs storage
└── sync/
    └── sync_manager.dart                 # Sync orchestration

bin/
├── demo_sync_system.dart                # Interactive demo
├── server_runner.dart                   # Server management CLI
├── test_api.dart                        # Original API tests
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
- Supports multiple storage backends
- Implements sync endpoint for bi-directional sync
- Enforces cloud storage constraints (no PUT/DELETE)

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

### 5. Test the API

```bash
dart run bin/test_api.dart
```

## API Endpoints

### Health Check
- `GET /health` - Server health status

### Documents
- `GET /api/documents` - List all documents
- `GET /api/documents?type={type}` - Filter documents by type
- `GET /api/documents/{uuid}` - Get specific document
- `POST /api/documents` - Create new document
- `PUT /api/documents/{uuid}` - Update document
- `DELETE /api/documents/{uuid}` - Delete document
- `GET /api/documents/search/{query}` - Search documents

### Sync
- `GET /api/sync/status` - Get sync status
- `POST /api/sync/trigger` - Trigger sync process
- `POST /api/sync/document/{uuid}` - Sync specific document

### Statistics
- `GET /api/stats` - Get server and storage statistics

## Example Usage

### Create a Document
```bash
curl -X POST http://localhost:8080/api/documents \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Note",
    "content": "This is a test note",
    "type": "note",
    "metadata": {
      "tags": ["test", "example"]
    }
  }'
```

### Get All Documents
```bash
curl http://localhost:8080/api/documents
```

### Search Documents
```bash
curl http://localhost:8080/api/documents/search/test
```

### Check Sync Status
```bash
curl http://localhost:8080/api/sync/status
```

## Architecture

### Core Components

- **`BaseEntity`**: Base class for all persisted entities with sync metadata
- **`Document`**: Main content entity with title, content, type, and metadata
- **`LocalStorageService`**: Isar-based local persistence layer
- **`SyncManager`**: Orchestrates sync between local, LAN, and cloud
- **`RestApiServer`**: Shelf-based HTTP server with CORS support

### Sync Architecture

The sync system is designed with three layers:

1. **Local Storage**: Isar database for offline-first functionality
2. **LAN Sync**: Stubbed P2P sync for local network collaboration
3. **Cloud Sync**: Stubbed AWS integration for cloud synchronization

### Data Flow

```
Local Storage ↔ Sync Manager ↔ [LAN Provider, Cloud Provider]
                      ↓
                 REST API Server
                      ↓
              External Clients
```

## Sync Status States

- **`local`**: Only exists locally
- **`pending`**: Has local changes, needs sync
- **`syncing`**: Currently syncing
- **`synced`**: Synced to cloud
- **`conflict`**: Sync conflict detected

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

## Testing

Run the comprehensive API test suite:

```bash
dart run bin/test_api.dart
```

This will test all endpoints and verify functionality.

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

If port 8080 is already in use, the server will fail to start. You can:
1. Stop the process using port 8080
2. Or modify `bin/server.dart` to use a different port

## Future Enhancements

- [ ] Implement actual LAN discovery and sync
- [ ] Add AWS DynamoDB/S3 integration
- [ ] Add media file handling
- [ ] Implement conflict resolution UI
- [ ] Add user authentication
- [ ] Add real-time WebSocket notifications
- [ ] Add batch operations
- [ ] Add data export/import

## License

This project is part of the Flutter-2 shared backend codebase.
