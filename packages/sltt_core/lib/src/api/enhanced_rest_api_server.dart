import '../storage/base_storage_service.dart';
import '../storage/shared_storage_service.dart';
import 'base_rest_api_server.dart';

enum StorageType { outsyncs, downsyncs, cloudStorage }

/// Enhanced REST API server using local Isar storage.
///
/// This server extends the base functionality with local storage capabilities
/// and provides the same API endpoints as other SLTT servers.
class EnhancedRestApiServer extends BaseRestApiServer {
  final StorageType storageType;

  EnhancedRestApiServer(this.storageType, String serverName)
    : super(serverName: serverName, storage: _createStorage(storageType));

  @override
  String get storageTypeDescription =>
      'Local Isar (${storageType.toString().split('.').last})';

  /// Create storage service based on type
  static BaseStorageService _createStorage(StorageType storageType) {
    switch (storageType) {
      case StorageType.outsyncs:
        return OutsyncsStorageService.instance;
      case StorageType.downsyncs:
        return DownsyncsStorageService.instance;
      case StorageType.cloudStorage:
        return CloudStorageService.instance;
    }
  }
}
