# Flutter-2 Local Storage Server

A shared Dart backend codebase for offline-first, LAN-collaborative, cloud-sync applications with a REST API interface.

## Features

- **Offline-First Storage**: Uses Isar for local data persistence with UUIDv7 identifiers
- **REST API Server**: Built with Shelf, provides full CRUD operations
- **Sync Management**: Stubbed implementations for LAN and Cloud sync
- **Developer-Friendly**: Easy to debug and extend

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
