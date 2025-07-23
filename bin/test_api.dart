import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class ApiTester {
  final Dio _dio;
  final String baseUrl;
  
  ApiTester(this.baseUrl) : _dio = Dio() {
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }
  
  Future<void> runTests() async {
    print('🚀 Starting API Tests for $baseUrl\n');
    
    try {
      await _testHealthCheck();
      await _testDocumentCRUD();
      await _testSearch();
      await _testSyncEndpoints();
      await _testStats();
      
      print('\n✅ All tests completed successfully!');
      
    } catch (e) {
      print('\n❌ Test failed: $e');
      rethrow;
    }
  }
  
  Future<void> _testHealthCheck() async {
    print('🔍 Testing health check...');
    
    final response = await _dio.get('$baseUrl/health');
    
    if (response.statusCode == 200) {
      final data = response.data;
      print('   ✅ Health check passed: ${data['status']}');
    } else {
      throw Exception('Health check failed: ${response.statusCode}');
    }
  }
  
  Future<void> _testDocumentCRUD() async {
    print('\n📄 Testing document CRUD operations...');
    
    // Create a document
    print('   Creating document...');
    final createResponse = await _dio.post(
      '$baseUrl/api/documents',
      data: {
        'title': 'Test Document',
        'content': 'This is a test document for the API',
        'type': 'note',
        'metadata': {
          'tags': ['test', 'api'],
          'priority': 'high',
        },
      },
    );
    
    if (createResponse.statusCode != 200) {
      throw Exception('Failed to create document: ${createResponse.statusCode}');
    }
    
    final createdDoc = createResponse.data['document'];
    final docUuid = createdDoc['uuid'];
    print('   ✅ Document created with UUID: $docUuid');
    
    // Get the document
    print('   Fetching document...');
    final getResponse = await _dio.get('$baseUrl/api/documents/$docUuid');
    
    if (getResponse.statusCode != 200) {
      throw Exception('Failed to get document: ${getResponse.statusCode}');
    }
    
    final fetchedDoc = getResponse.data;
    print('   ✅ Document fetched: ${fetchedDoc['title']}');
    
    // Update the document
    print('   Updating document...');
    final updateResponse = await _dio.put(
      '$baseUrl/api/documents/$docUuid',
      data: {
        'title': 'Updated Test Document',
        'content': 'This document has been updated',
        'metadata': {
          'tags': ['test', 'api', 'updated'],
          'priority': 'medium',
        },
      },
    );
    
    if (updateResponse.statusCode != 200) {
      throw Exception('Failed to update document: ${updateResponse.statusCode}');
    }
    
    print('   ✅ Document updated successfully');
    
    // Get all documents
    print('   Fetching all documents...');
    final allDocsResponse = await _dio.get('$baseUrl/api/documents');
    
    if (allDocsResponse.statusCode != 200) {
      throw Exception('Failed to get all documents: ${allDocsResponse.statusCode}');
    }
    
    final allDocs = allDocsResponse.data;
    print('   ✅ Found ${allDocs['count']} documents');
    
    // Delete the document
    print('   Deleting document...');
    final deleteResponse = await _dio.delete('$baseUrl/api/documents/$docUuid');
    
    if (deleteResponse.statusCode != 200) {
      throw Exception('Failed to delete document: ${deleteResponse.statusCode}');
    }
    
    print('   ✅ Document deleted successfully');
  }
  
  Future<void> _testSearch() async {
    print('\n🔍 Testing search functionality...');
    
    // Create some test documents first
    final testDocs = [
      {
        'title': 'Flutter Development Guide',
        'content': 'Learn how to build Flutter applications',
        'type': 'guide',
      },
      {
        'title': 'Dart Programming Tips',
        'content': 'Best practices for Dart programming',
        'type': 'tips',
      },
      {
        'title': 'API Testing Notes',
        'content': 'Notes about testing REST APIs',
        'type': 'note',
      },
    ];
    
    final createdUuids = <String>[];
    
    for (final doc in testDocs) {
      final response = await _dio.post('$baseUrl/api/documents', data: doc);
      final uuid = response.data['document']['uuid'];
      createdUuids.add(uuid);
    }
    
    print('   Created ${createdUuids.length} test documents');
    
    // Test search
    final searchResponse = await _dio.get('$baseUrl/api/documents/search/Flutter');
    
    if (searchResponse.statusCode != 200) {
      throw Exception('Search failed: ${searchResponse.statusCode}');
    }
    
    final searchResults = searchResponse.data;
    print('   ✅ Search for "Flutter" returned ${searchResults['count']} results');
    
    // Filter by type
    final typeResponse = await _dio.get('$baseUrl/api/documents?type=guide');
    
    if (typeResponse.statusCode != 200) {
      throw Exception('Filter by type failed: ${typeResponse.statusCode}');
    }
    
    final typeResults = typeResponse.data;
    print('   ✅ Filter by type "guide" returned ${typeResults['count']} results');
    
    // Cleanup
    for (final uuid in createdUuids) {
      await _dio.delete('$baseUrl/api/documents/$uuid');
    }
    
    print('   ✅ Test documents cleaned up');
  }
  
  Future<void> _testSyncEndpoints() async {
    print('\n🔄 Testing sync endpoints...');
    
    // Get sync status
    final statusResponse = await _dio.get('$baseUrl/api/sync/status');
    
    if (statusResponse.statusCode != 200) {
      throw Exception('Failed to get sync status: ${statusResponse.statusCode}');
    }
    
    final status = statusResponse.data;
    print('   ✅ Sync status retrieved:');
    print('      - Initialized: ${status['isInitialized']}');
    print('      - LAN Available: ${status['lanAvailable']}');
    print('      - Cloud Available: ${status['cloudAvailable']}');
    
    // Trigger sync
    final triggerResponse = await _dio.post('$baseUrl/api/sync/trigger');
    
    if (triggerResponse.statusCode != 200) {
      throw Exception('Failed to trigger sync: ${triggerResponse.statusCode}');
    }
    
    print('   ✅ Sync triggered successfully');
  }
  
  Future<void> _testStats() async {
    print('\n📊 Testing statistics endpoint...');
    
    final statsResponse = await _dio.get('$baseUrl/api/stats');
    
    if (statsResponse.statusCode != 200) {
      throw Exception('Failed to get stats: ${statsResponse.statusCode}');
    }
    
    final stats = statsResponse.data;
    print('   ✅ Statistics retrieved:');
    print('      - Total documents: ${stats['storage']['total']}');
    print('      - Pending sync: ${stats['storage']['pending']}');
    print('      - Server port: ${stats['server']['port']}');
  }
}

Future<void> main(List<String> args) async {
  final baseUrl = args.isNotEmpty ? args.first : 'http://localhost:8080';
  
  print('Testing API at $baseUrl');
  print('Make sure the server is running first!\n');
  
  final tester = ApiTester(baseUrl);
  
  try {
    await tester.runTests();
  } catch (e) {
    print('Test suite failed: $e');
    exit(1);
  }
}
