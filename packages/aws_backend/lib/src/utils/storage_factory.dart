import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_common/aws_common.dart';

/// Shared utility for creating DynamoDB storage service with consistent configuration
class StorageFactory {
  /// Create a DynamoDB storage service with the provided credentials.
  ///
  /// The caller is responsible for obtaining credentials via [AwsCredentialsService].
  static DynamoDBStorageService createStorage({
    required AWSCredentials credentials,
    bool useLocalDynamoDB = false,
    Future<AWSCredentials> Function()? credentialsResolver,
  }) {
    final tableName =
        Platform.environment['DYNAMODB_TABLE'] ?? 'sltt-changes-dev';
    final region =
        Platform.environment['DYNAMODB_REGION'] ??
        Platform.environment['AWS_REGION'] ??
        'us-east-1';

    return DynamoDBStorageService(
      tableName: tableName,
      region: region,
      useLocalDynamoDB: useLocalDynamoDB,
      credentials: credentials,
      credentialsResolver: credentialsResolver,
    );
  }
}
