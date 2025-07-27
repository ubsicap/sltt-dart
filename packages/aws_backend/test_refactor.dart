import 'lib/src/api/aws_rest_api_server.dart';
import 'lib/src/storage/dynamodb_storage_service.dart';

void main() {
  print('Testing imports...');
  
  // Test DynamoDBStorageService creation
  final storage = DynamoDBStorageService(
    tableName: 'test-table',
    projectId: 'test-project',
    region: 'us-east-1',
  );
  
  // Test AwsRestApiServer creation
  final server = AwsRestApiServer(
    serverName: 'Test Server',
    storage: storage,
  );
  
  print('✅ All imports working!');
  print('Server: ${server.serverName}');
  print('Storage: ${server.storageTypeDescription}');
}
