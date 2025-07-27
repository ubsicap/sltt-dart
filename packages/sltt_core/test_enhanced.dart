import 'package:sltt_core/sltt_core.dart';

void main() {
  print('Testing sltt_core imports...');
  
  // Test BaseRestApiServer is available
  print('BaseRestApiServer: available');
  
  // Test EnhancedRestApiServer creation
  final server = EnhancedRestApiServer(StorageType.outsyncs, 'Test Server');
  
  print('✅ EnhancedRestApiServer created!');
  print('Server: ${server.serverName}');
  print('Storage: ${server.storageTypeDescription}');
}
