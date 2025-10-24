import 'package:isar_community/isar.dart';

part 'isar_storage_state.g.dart';

@collection
class IsarStorageState {
  final Id id;
  final String storageId;
  final String storageType;
  final DateTime createdAt;
  final DateTime updatedAt;

  IsarStorageState({
    this.id = Isar.autoIncrement,
    required this.storageId,
    required this.storageType,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = createdAt.toUtc(),
       updatedAt = updatedAt.toUtc();
}
