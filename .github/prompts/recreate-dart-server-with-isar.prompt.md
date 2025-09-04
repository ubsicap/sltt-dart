# Recreate Dart Server with Isar Database

**Objective:**
Convert the existing Dart REST API server from JSON file storage to use Isar database for proper persistence, performance, and transactional integrity.

---

## Current Implementation Status

The server currently uses a simple JSON file (`./data/documents.json`) for persistence via `IsarStorageService`. This works but lacks:
- Database transactions
- Indexing and query performance
- Concurrent access safety
- Data integrity guarantees

## Requirements

### 1. **Replace JSON Storage with Isar**
   - Convert `IsarStorageService` to use Isar database
   - Maintain all existing API functionality
   - Ensure data persists between server restarts
   - Handle Isar native library setup for pure Dart server environment

### 2. **Core Models with Isar Annotations**
   - **BaseEntity**: Convert to Isar-compatible mixin with proper annotations
   - **Document**: Use `@Collection()` annotation with proper field mappings
   - Handle complex types like `Map<String, dynamic>` metadata using JSON serialization
   - Maintain UUIDv7 identifiers with unique indexes

### 3. **Database Operations**
   - Implement all CRUD operations using Isar transactions
   - Maintain existing sync status tracking (local, pending, syncing, synced, conflict)
   - Support search functionality across title and content
   - Implement filtering by document type
   - Provide sync statistics and document counts

### 4. **Server Compatibility**
   - Ensure Isar works in pure Dart server environment (not Flutter)
   - Handle Isar native library dependencies correctly
   - Maintain existing REST API endpoints without changes
   - Preserve all sync manager and provider interfaces

### 5. **Code Generation Setup**
   - Configure `build_runner` to generate Isar schemas
   - Update `pubspec.yaml` with correct Isar dependencies for Dart server
   - Ensure generated files work with existing import structure

---

## 🚀 Quick Start Guide

### Prerequisites
- Dart SDK 3.0.0 or higher
- Linux/macOS/Windows environment

### Installation Steps

1. **Install Dependencies**
   ```bash
   dart pub get
   ```

2. **Install Isar Native Library** (Required for pure Dart)

   Choose your platform:

   **Linux (x64):**
   ```bash
   curl -L https://github.com/isar/isar/releases/download/3.1.0%2B1/libisar_linux_x64.so -o bin/libisar.so
   chmod +x bin/libisar.so
   ```

   **macOS (x64):**
   ```bash
   curl -L https://github.com/isar/isar/releases/download/3.1.0%2B1/libisar_macos_x64.dylib -o bin/libisar.dylib
   chmod +x bin/libisar.dylib
   ```

   **macOS (ARM64):**
   ```bash
   curl -L https://github.com/isar/isar/releases/download/3.1.0%2B1/libisar_macos_arm64.dylib -o bin/libisar.dylib
   chmod +x bin/libisar.dylib
   ```

   **Windows (x64):**
   ```powershell
   curl -L https://github.com/isar/isar/releases/download/3.1.0%2B1/isar_windows_x64.dll -o bin/isar.dll
   ```

3. **Generate Isar Schemas**
   ```bash
   dart run build_runner build
   ```

4. **Start the Server**
   ```bash
   dart run bin/server.dart
   ```

5. **Test the API**
   ```bash
   dart run bin/test_api.dart
   ```

---

## ✅ Implementation Details

### Updated File Structure
```
lib/
├── core/
│   ├── api/
│   │   └── rest_api_server.dart           # Shelf-based REST API
│   ├── models/
│   │   ├── base_entity.dart               # Base mixin with sync metadata
│   │   └── document.dart                  # Document model
│   ├── storage/
│   │   └── local_storage_service.dart     # Currently uses JSON file
│   └── sync/
│       ├── sync_manager.dart              # Orchestrates sync operations
│       └── sync_providers.dart            # LAN/Cloud sync providers (stubbed)
├── main.dart                              # Empty file for Dart-only version
bin/
├── server.dart                            # Main server executable
└── test_api.dart                          # API test suite
```

## Specific Implementation Details


### Isar-based IsarStorageService Interface
```dart
class IsarStorageService {
  static IsarStorageService get instance;
  Future<void> initialize();
  Future<Document> createDocument(Document document);
  Future<Document?> getDocument(String uuid);
  Future<List<Document>> getAllDocuments();
  Future<List<Document>> getDocumentsByType(String type);
  Future<List<Document>> getPendingSyncDocuments();
  Future<Document> updateDocument(Document document);
  Future<bool> deleteDocument(String uuid);
  Future<void> markDocumentSynced(String uuid, SyncTarget target);
  Future<int> getDocumentCount();
  Future<List<Document>> searchDocuments(String query);
  Future<Map<String, int>> getSyncStats();
  Future<void> close();
}
```

### Isar-based Document Model Structure
```dart
@Collection()
class Document with BaseEntityMixin {
  Id id = Isar.autoIncrement; // Isar auto-increment ID

  @Index(unique: true)
  late String uuid;              // UUIDv7, indexed as unique
  late DateTime createdAt;
  late DateTime updatedAt;
  @Enumerated(EnumType.name)
  SyncStatus syncStatus = SyncStatus.local;
  String? lastSyncedAt;

  late String title;
  late String content;
  String? mediaPath;
  @Index()
  late String type;              // indexed for filtering

  // Store as JSON string in Isar
  String _metadataJson = '{}';
  @ignore
  Map<String, dynamic> get metadata => ...;
  @ignore
  set metadata(Map<String, dynamic> value) => ...;
}
```

### REST API Endpoints (must remain functional):
- `GET /health` - Health check
- `GET /api/documents` - List all documents
- `GET /api/documents?type={type}` - Filter by type
- `GET /api/documents/{uuid}` - Get specific document
- `POST /api/documents` - Create document
- `PUT /api/documents/{uuid}` - Update document
- `DELETE /api/documents/{uuid}` - Delete document
- `GET /api/documents/search/{query}` - Search documents
- `GET /api/sync/status` - Get sync status
- `POST /api/sync/trigger` - Trigger sync
- `POST /api/sync/document/{uuid}` - Sync specific document
- `GET /api/stats` - Server statistics

## Expected Deliverables

1. **Updated pubspec.yaml** with correct Isar dependencies for Dart server
2. **Isar-compatible models** with proper annotations and code generation
3. **IsarStorageService implementation** using Isar with all existing methods
4. **Working build process** that generates Isar schemas successfully
5. **Functional server** that starts without native library errors
6. **Data persistence** that survives server restarts
7. **Passing test suite** with all API endpoints working

## Success Criteria

- `dart pub get` completes without errors
- `dart run build_runner build` generates Isar schemas successfully
- `dart run bin/server.dart` starts server without Isar native library errors
- `dart run bin/test_api.dart` passes all tests
- Documents created via API persist after server restart
- All sync status tracking continues to work
- Performance is improved over JSON file approach

---

**Note:** The current working implementation uses simple JSON file storage. The goal is to maintain 100% API compatibility while upgrading the persistence layer to Isar for better performance and reliability.
