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
      await _testChangeLogCRUD();
      await _testStats();

      print('\n✅ All tests completed successfully!');
    } catch (e) {
      print('\n❌ Test failed: $e');
      if (e is DioException) {
        print('DioException: ${e.message}');
        print('Response data: ${e.response?.data}');
      }
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

  Future<void> _testChangeLogCRUD() async {
    print('\n📝 Testing change log CRUD operations...');

    // Create a change log entry
    print('   Creating change log entry...');
    final createData = {
      'entityType': 'Document',
      'operation': 'create',
      'entityId': 'test-uuid-123',
      'data': {
        'title': 'Test Document',
        'content': 'This is a test document created via API',
        'type': 'note',
      },
    };

    final createResponse =
        await _dio.post('$baseUrl/api/changes', data: createData);

    if (createResponse.statusCode != 200) {
      print('Response data: ${createResponse.data}');
      throw Exception('Failed to create change: ${createResponse.statusCode}');
    }

    final createdChange = createResponse.data;
    final changeId = createdChange['id'];
    print('   ✅ Change created with ID: $changeId');

    // Get the created change
    print('   Fetching created change...');
    final getResponse = await _dio.get('$baseUrl/api/changes/$changeId');

    if (getResponse.statusCode != 200) {
      throw Exception('Failed to get change: ${getResponse.statusCode}');
    }

    final fetchedChange = getResponse.data;
    print('DEBUG: Fetched change: $fetchedChange');
    if (fetchedChange['entityType'] == 'Document' &&
        fetchedChange['operation'] == 'create' &&
        fetchedChange['entityId'] == 'test-uuid-123') {
      print('   ✅ Change fetched successfully');
    } else {
      print(
          'DEBUG: Expected entityType=Document, operation=create, entityId=test-uuid-123');
      print(
          'DEBUG: Got entityType=${fetchedChange['entityType']}, operation=${fetchedChange['operation']}, entityId=${fetchedChange['entityId']}');
      throw Exception('Fetched change data does not match expected values');
    }

    // Update the change
    print('   Updating change...');
    final updateData = {
      'operation': 'update',
      'data': {
        'title': 'Updated Test Document',
        'content': 'This document has been updated via API',
        'type': 'note',
      },
    };

    final updateResponse =
        await _dio.put('$baseUrl/api/changes/$changeId', data: updateData);

    if (updateResponse.statusCode != 200) {
      throw Exception('Failed to update change: ${updateResponse.statusCode}');
    }

    final updatedChange = updateResponse.data;
    if (updatedChange['operation'] == 'update') {
      print('   ✅ Change updated successfully');
    } else {
      throw Exception('Change was not updated correctly');
    }

    // Get all changes
    print('   Fetching all changes...');
    final allChangesResponse = await _dio.get('$baseUrl/api/changes');

    if (allChangesResponse.statusCode != 200) {
      throw Exception(
          'Failed to get all changes: ${allChangesResponse.statusCode}');
    }

    final allChanges = allChangesResponse.data;
    if (allChanges['count'] > 0) {
      print(
          '   ✅ All changes fetched successfully (count: ${allChanges['count']})');
    } else {
      throw Exception('No changes found when at least one should exist');
    }

    // Test filtering by entity type
    print('   Testing entity type filter...');
    final filteredResponse =
        await _dio.get('$baseUrl/api/changes?entityType=Document');

    if (filteredResponse.statusCode != 200) {
      throw Exception(
          'Failed to filter by entity type: ${filteredResponse.statusCode}');
    }

    final filtered = filteredResponse.data;
    if (filtered['count'] > 0) {
      print('   ✅ Entity type filter works (count: ${filtered['count']})');
    }

    // Test cursor and limit functionality
    print('   Testing cursor and limit...');

    // Create multiple changes for cursor testing
    final createData2 = {
      'entityType': 'Document',
      'operation': 'update',
      'entityId': 'test-uuid-456',
      'data': {
        'title': 'Second Test Document',
        'content': 'This is another test document',
        'type': 'note',
      },
    };
    final createResponse2 =
        await _dio.post('$baseUrl/api/changes', data: createData2);
    final createdChange2 = createResponse2.data;
    final changeId2 = createdChange2['id'];

    // Test limit parameter
    final limitResponse = await _dio.get('$baseUrl/api/changes?limit=1');
    if (limitResponse.statusCode != 200) {
      throw Exception('Failed to test limit: ${limitResponse.statusCode}');
    }

    final limitedResults = limitResponse.data;
    if (limitedResults['count'] == 1 && limitedResults.containsKey('cursor')) {
      print('   ✅ Limit parameter works and cursor returned');
    } else {
      throw Exception(
          'Limit test failed - expected count=1 and cursor present');
    }

    // Test cursor parameter
    final cursor = limitedResults['cursor'];
    final cursorResponse =
        await _dio.get('$baseUrl/api/changes?cursor=$cursor');
    if (cursorResponse.statusCode != 200) {
      throw Exception('Failed to test cursor: ${cursorResponse.statusCode}');
    }

    final cursorResults = cursorResponse.data;
    if (cursorResults['count'] > 0) {
      print(
          '   ✅ Cursor parameter works (returned ${cursorResults['count']} results)');
    }

    // Clean up the second change
    await _dio.delete('$baseUrl/api/changes/$changeId2');

    // Delete the change
    print('   Deleting change...');
    final deleteResponse = await _dio.delete('$baseUrl/api/changes/$changeId');

    if (deleteResponse.statusCode != 200) {
      throw Exception('Failed to delete change: ${deleteResponse.statusCode}');
    }

    print('   ✅ Change deleted successfully');

    // Verify deletion
    print('   Verifying deletion...');
    try {
      await _dio.get('$baseUrl/api/changes/$changeId');
      throw Exception('Change was not deleted - still exists');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        print('   ✅ Change deletion verified');
      } else {
        rethrow;
      }
    }
  }

  Future<void> _testStats() async {
    print('\n📊 Testing statistics endpoint...');

    final response = await _dio.get('$baseUrl/api/stats');

    if (response.statusCode == 200) {
      final stats = response.data;
      print('   ✅ Statistics retrieved:');
      print('      Change stats: ${stats['changeStats']}');
      print('      Entity type stats: ${stats['entityTypeStats']}');
    } else {
      throw Exception('Failed to get statistics: ${response.statusCode}');
    }
  }

  Future<void> _testErrorHandling() async {
    print('\n🚫 Testing error handling...');

    // Test invalid change ID
    try {
      await _dio.get('$baseUrl/api/changes/invalid-id');
      throw Exception('Expected 400 error for invalid ID');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        print('   ✅ Invalid ID error handled correctly');
      } else {
        rethrow;
      }
    }

    // Test non-existent change
    try {
      await _dio.get('$baseUrl/api/changes/999999');
      throw Exception('Expected 404 error for non-existent change');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        print('   ✅ Non-existent change error handled correctly');
      } else {
        rethrow;
      }
    }

    // Test invalid cursor parameter
    try {
      await _dio.get('$baseUrl/api/changes?cursor=invalid-cursor');
      throw Exception('Expected 400 error for invalid cursor');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        print('   ✅ Invalid cursor error handled correctly');
      } else {
        rethrow;
      }
    }

    // Test invalid limit parameter
    try {
      await _dio.get('$baseUrl/api/changes?limit=invalid-limit');
      throw Exception('Expected 400 error for invalid limit');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        print('   ✅ Invalid limit error handled correctly');
      } else {
        rethrow;
      }
    }

    // Test limit out of range (negative)
    try {
      await _dio.get('$baseUrl/api/changes?limit=-5');
      throw Exception('Expected 400 error for negative limit');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        print('   ✅ Negative limit error handled correctly');
      } else {
        rethrow;
      }
    }

    // Test limit out of range (too large)
    try {
      await _dio.get('$baseUrl/api/changes?limit=10000');
      throw Exception('Expected 400 error for limit too large');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        print('   ✅ Limit too large error handled correctly');
      } else {
        rethrow;
      }
    }

    // Test invalid endpoint
    try {
      await _dio.get('$baseUrl/api/invalid-endpoint');
      throw Exception('Expected 404 error for invalid endpoint');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        print('   ✅ Invalid endpoint error handled correctly');
      } else {
        rethrow;
      }
    }
  }
}

void main(List<String> args) async {
  String baseUrl = 'http://localhost:8080';

  // Allow custom URL from command line
  if (args.isNotEmpty) {
    baseUrl = args[0];
  }

  print('Testing API at: $baseUrl');

  final tester = ApiTester(baseUrl);

  try {
    await tester.runTests();
    await tester._testErrorHandling();

    print('\n🎉 All tests passed!');
    exit(0);
  } catch (e) {
    print('\n💥 Tests failed: $e');
    exit(1);
  }
}
