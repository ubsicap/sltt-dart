import 'dart:io';

import 'package:aws_backend/aws_backend.dart';

/// Shared utility for creating DynamoDB storage service with consistent configuration
class StorageFactory {
  /// Create a DynamoDB storage service using environment variables
  static DynamoDBStorageService createStorage({bool useLocalDynamoDB = false}) {
    final tableName =
        Platform.environment['DYNAMODB_TABLE'] ?? 'sltt-changes-dev';
    final region =
        Platform.environment['DYNAMODB_REGION'] ??
        Platform.environment['AWS_REGION'] ??
        'us-east-1';

    // Default to cloud storage unless explicitly overridden
    final useLocal = useLocalDynamoDB;

    return DynamoDBStorageService(
      tableName: tableName,
      region: region,
      useLocalDynamoDB: useLocal,
    );
  }
}
