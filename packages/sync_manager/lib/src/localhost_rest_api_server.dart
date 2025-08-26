import 'package:sltt_core/sltt_core.dart';

import 'shared_storage_service.dart';

enum StorageType { outsyncs, cloudStorage }

/// Enhanced REST API server using local Isar storage.
///
/// This server extends the base functionality with local storage capabilities
/// and provides the same API endpoints as other SLTT servers.
class LocalhostRestApiServer extends BaseRestApiServer {
  final StorageType storageType;

  LocalhostRestApiServer(this.storageType, String serverName)
    : super(serverName: serverName, storage: _createStorage(storageType));

  @override
  String get storageTypeDescription =>
      'Local Isar (${storageType.toString().split('.').last})';

  /// Create storage service based on type
  static BaseStorageService _createStorage(StorageType storageType) {
    switch (storageType) {
      case StorageType.outsyncs:
        return OutsyncsStorageService.instance;
      case StorageType.cloudStorage:
        return CloudStorageService.instance;
    }
  }
}
