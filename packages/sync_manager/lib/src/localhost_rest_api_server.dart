import 'package:sltt_core/sltt_core.dart';

import 'isar_storage_service.dart';

enum StorageType { local, cloud }

/// Enhanced REST API server using local Isar storage.
///
/// This server extends the base functionality with local storage capabilities
/// and provides the same API endpoints as other SLTT servers.
class LocalhostRestApiServer extends BaseRestApiServer {
  final StorageType storageType;

  LocalhostRestApiServer(
    this.storageType,
    String serverName, {
    BaseStorageService? storage,
  }) : super(
         serverName: serverName,
         storage: storage ?? _createStorage(storageType),
       );

  @override
  String get storageTypeDescription =>
      'Local Isar (${storageType.toString().split('.').last})';

  /// Create storage service based on type
  static BaseStorageService _createStorage(StorageType storageType) {
    switch (storageType) {
      case StorageType.local:
        return LocalStorageService.instance;
      case StorageType.cloud:
        return CloudStorageService.instance;
    }
  }
}
