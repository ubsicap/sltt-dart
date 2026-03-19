import 'package:sltt_core/sltt_core.dart';

import '../test_models.dart';

export 'package:sltt_core/src/storage/in_memory_storage.dart';

/// Convenience factory for tests: creates an [InMemoryStorage] pre-configured
/// with [TestChangeLogEntry] and [TestEntityState] factories.
InMemoryStorage testInMemoryStorage({
  required String storageType,
  String? storageId,
}) {
  return InMemoryStorage(
    storageType: storageType,
    storageId: storageId,
    fromJsonChangeLogEntry: TestChangeLogEntry.fromJson,
    fromJsonEntityState: TestEntityState.fromJson,
  );
}
