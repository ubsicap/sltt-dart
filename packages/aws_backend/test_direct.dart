import 'package:sltt_core/sltt_core.dart';
import 'lib/src/storage/dynamodb_storage_service.dart';
import 'lib/src/api/aws_rest_api_server.dart';

void main() {
  print('Testing AWS server directly...');
  
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
  
  print('✅ Direct imports working!');
  print('Server: ${server.serverName}');
  print('Storage: ${server.storageTypeDescription}');
}
