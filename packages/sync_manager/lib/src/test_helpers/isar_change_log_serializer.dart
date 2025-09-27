import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/src/models/isar_change_log_entry.dart';

/// Register the common Isar change log SerializableGroup used by tests.
void registerIsarChangeLogSerializableGroup() {
  registerChangeLogEntryFactoryGroup(
    SerializableGroup<BaseChangeLogEntry>(
      fromJson: IsarChangeLogEntry.fromJson,
      fromJsonBase: IsarChangeLogEntry.fromJsonBase,
      toJson: (entry) => (entry as IsarChangeLogEntry).toJson(),
      toJsonBase: (entry) => (entry as IsarChangeLogEntry).toJsonBase(),
      toSafeJson: (original) =>
          SafeJsonService.generateSafeChangeLogJson(original),
      validate: (entry) async {
        // Ensure dataJson isn't empty and parses to BaseDataFields
        BaseDataFields.fromJson(entry.getData());
      },
    ),
  );
}
