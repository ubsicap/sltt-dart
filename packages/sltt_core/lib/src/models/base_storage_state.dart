abstract class BaseStorageState {
  String get storageId;
  String get storageType;
  DateTime get createdAt;
  DateTime get updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'storageId': storageId,
      'storageType': storageType,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
