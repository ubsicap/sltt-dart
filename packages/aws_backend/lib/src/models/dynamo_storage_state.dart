import 'package:sltt_core/sltt_core.dart';

class DynamoStorageState implements BaseStorageState {
  @override
  final String storageId;

  @override
  final String storageType;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  DynamoStorageState({
    required this.storageId,
    required this.storageType,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = createdAt.toUtc(),
       updatedAt = updatedAt.toUtc();

  factory DynamoStorageState.fromJson(Map<String, dynamic> json) {
    return DynamoStorageState(
      storageId: json['storageId'] as String,
      storageType: json['storageType'] as String? ?? 'cloud',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'storageId': storageId,
      'storageType': storageType,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
