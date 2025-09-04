import 'dart:convert';
import 'dart:io';

import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

/// Test suite configuration for API change network tests
class ApiChangesNetworkTestSuite {
  final Future<Uri> Function() resolveBaseUrl;
  final DateTime baseTime = DateTime.parse('2023-01-01T00:00:00Z');

  ApiChangesNetworkTestSuite(this.resolveBaseUrl);

  Future<Map<String, dynamic>> postSingleChange(
    Map<String, dynamic> change,
  ) async {
    final baseUrl = await resolveBaseUrl();
    final uri = baseUrl.replace(path: '/api/changes');

    // For save mode, clear the storageId from the change object
    final adjustedChange = Map<String, dynamic>.from(change);
    final originalStorageId = adjustedChange['storageId'] ?? 'local';
    adjustedChange['storageId'] = ''; // Empty for save mode

    final body = {
      'changes': [adjustedChange],
      // Tests simulate a local offline client by default
      'srcStorageType': 'local',
      'srcStorageId': originalStorageId,
      'storageMode': 'save',
      'includeChangeUpdates': true,
      'includeStateUpdates': true,
    };

    final req = await HttpClient().postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close();
    expect(res.statusCode, 200);
    final respBodyStr = await res.transform(utf8.decoder).join();
    return jsonDecode(respBodyStr) as Map<String, dynamic>;
  }

  Future<void> seedChange(Map<String, dynamic> change) async {
    await postSingleChange(change);
  }

  Future<Map<String, dynamic>> getProjectChanges(
    String projectId, {
    int? cursor,
    int? limit,
  }) async {
    final baseUrl = await resolveBaseUrl();
    final queryParams = <String, String>{};
    if (cursor != null) queryParams['cursor'] = cursor.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = baseUrl.replace(
      path: '/api/projects/${Uri.encodeComponent(projectId)}/changes',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final req = await HttpClient().getUrl(uri);
    final res = await req.close();
    expect(res.statusCode, 200);
    final body = await res.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Map<String, dynamic> changePayload({
    required String domainId,
    required String entityType,
    required String entityId,
    required DateTime changeAt,
    String storageId = 'local',
    Map<String, dynamic> data = const <String, dynamic>{},
    String operation = 'update',
    bool addDefaultParentId = true,
  }) {
    final adjustedData = Map<String, dynamic>.from(data);
    if (addDefaultParentId &&
        operation != 'delete' &&
        !adjustedData.containsKey('parentId')) {
      adjustedData['parentId'] = 'root';
    }
    final namespacedEntityId = '$domainId-$entityId';
    final namespacedCid = '$domainId-${generateCid(changeAt)}';
    return {
      'domainId': domainId,
      'domainType': 'project',
      'entityType': entityType,
      'entityId': namespacedEntityId,
      'changeBy': 'tester',
      'changeAt': changeAt.toUtc().toIso8601String(),
      'cid': namespacedCid,
      'storageId': storageId,
      'operation': operation,
      'operationInfoJson': '{}',
      'stateChanged': false,
      'unknownJson': '{}',
      'dataJson': jsonEncode(adjustedData),
    };
  }

  /// Get all test groups with their individual tests
  Map<String, Map<String, Future<void> Function()>> getTestGroups() {
    return {
      'POST /api/changes': {
        'with includeChangeUpdates/includeStateUpdates returns summaries': () =>
            _testPostChangesWithSummaries(),
      },
      'GET /api/projects/<projectId>/changes': {
        'returns empty list for project with no changes': () =>
            _testGetProjectChangesEmpty(),
        'returns changes for project with seeded data': () =>
            _testGetProjectChangesWithData(),
        'respects limit parameter': () => _testGetProjectChangesWithLimit(),
        'supports cursor-based pagination': () =>
            _testGetProjectChangesWithPagination(),
        'handles URL-encoded project IDs correctly': () =>
            _testGetProjectChangesUrlEncoded(),
        'returns 400 for invalid limit values': () =>
            _testGetProjectChangesInvalidLimit(),
        'returns 400 for invalid cursor values': () =>
            _testGetProjectChangesInvalidCursor(),
      },
      'POST /api/changes semantics': {
        'handles field-level conflict resolution (newer change wins)': () =>
            _testPostChangesFieldLevelConflict(),
      },
      'POST /api/changes srcStorageType/srcStorageId combinations': {
        'srcStorageType: local, srcStorageId: matches server storage id': () =>
            _testPostChangesLocalMatchingStorageId(),
        'srcStorageType: local, srcStorageId: different from server': () =>
            _testPostChangesLocalDifferentStorageId(),
        'srcStorageType: cloud, srcStorageId: cloud': () =>
            _testPostChangesCloudStorage(),
      },
    };
  }

  /// Get list of available test group names for easier maintenance
  List<String> getTestGroupNames() {
    return getTestGroups().keys.toList();
  }

  /// Get tests for a specific group
  Map<String, Future<void> Function()> getTestsForGroup(String groupName) {
    final testGroups = getTestGroups();
    return testGroups[groupName] ?? {};
  }

  /// Run all tests (backward compatibility)
  void runAllTests() {
    final testGroups = getTestGroups();

    for (final groupEntry in testGroups.entries) {
      final groupName = groupEntry.key;
      final tests = groupEntry.value;

      group(groupName, () {
        for (final testEntry in tests.entries) {
          final testName = testEntry.key;
          final testFunction = testEntry.value;

          test(testName, testFunction);
        }
      });
    }
  }

  /// Run all tests with custom group naming (for different storage backends)
  void runAllTestsWithPrefix(String prefix) {
    final testGroups = getTestGroups();

    for (final groupEntry in testGroups.entries) {
      final groupName = groupEntry.key;
      final tests = groupEntry.value;

      group('$prefix - $groupName', () {
        for (final testEntry in tests.entries) {
          final testName = testEntry.key;
          final testFunction = testEntry.value;

          test(testName, testFunction);
        }
      });
    }
  }

  // Individual test implementations

  Future<void> _testPostChangesWithSummaries() async {
    final baseUrl = await resolveBaseUrl();
    final uri = baseUrl.replace(path: '/api/changes');
    final now = DateTime.now().toUtc();
    final payload = [
      {
        'domainId': 'proj-1',
        'domainType': 'project',
        'entityType': 'project',
        'entityId': 'entity-1',
        'changeBy': 'tester',
        'changeAt': now.toIso8601String(),
        'cid': generateCid(now),
        'storageId': '', // Empty for save mode
        'operation': 'update',
        'operationInfoJson': '{}',
        'stateChanged': false,
        'unknownJson': '{}',
        'dataJson': jsonEncode({
          'nameLocal': 'Core API Net Test',
          'parentId': 'root',
        }),
      },
    ];

    final body = {
      'changes': payload,
      'srcStorageType': 'local',
      'srcStorageId': 'local',
      'storageMode': 'save',
      'includeChangeUpdates': true,
      'includeStateUpdates': true,
    };

    final req = await HttpClient().postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close();

    expect(res.statusCode, 200);
    final respBodyStr = await res.transform(utf8.decoder).join();
    final json = jsonDecode(respBodyStr) as Map<String, dynamic>;

    expect(json['storageType'], isNotEmpty);
    expect(json['storageId'], isNotEmpty);
    expect(json['changeUpdates'], isA<List>());
    expect(json['stateUpdates'], isA<List>());
    expect(json['changeUpdates'].first, contains('cid'));
    expect(json['stateUpdates'].first, contains('cid'));
  }

  Future<void> _testGetProjectChangesEmpty() async {
    final resp = await getProjectChanges('empty-project');

    expect(resp['changes'], isA<List>());
    expect(resp['changes'], isEmpty);
    expect(resp['count'], 0);
    expect(resp['timestamp'], isNotNull);
    expect(resp.containsKey('cursor'), isFalse);
  }

  Future<void> _testGetProjectChangesWithData() async {
    final projectId = 'test-get-changes';

    // Seed some changes
    await seedChange(
      changePayload(
        domainId: projectId,
        entityType: 'task',
        entityId: 'task-1',
        changeAt: baseTime,
        data: {'nameLocal': 'First Task'},
      ),
    );

    await seedChange(
      changePayload(
        domainId: projectId,
        entityType: 'task',
        entityId: 'task-2',
        changeAt: baseTime.add(const Duration(minutes: 1)),
        data: {'nameLocal': 'Second Task'},
      ),
    );

    final resp = await getProjectChanges(projectId);

    expect(resp['changes'], isA<List>());
    final changes = resp['changes'] as List;
    expect(changes.length, 2);
    expect(resp['count'], 2);
    expect(resp['timestamp'], isNotNull);
  }

  Future<void> _testGetProjectChangesWithLimit() async {
    final projectId = 'test-limit';

    // Seed 3 changes
    for (int i = 1; i <= 3; i++) {
      await seedChange(
        changePayload(
          domainId: projectId,
          entityType: 'task',
          entityId: 'task-$i',
          changeAt: baseTime.add(Duration(minutes: i)),
          data: {'nameLocal': 'Task $i'},
        ),
      );
    }

    final resp = await getProjectChanges(projectId, limit: 2);

    expect(resp['changes'], isA<List>());
    final changes = resp['changes'] as List;
    expect(changes.length, 2);
    expect(resp['count'], 2);
    expect(resp.containsKey('cursor'), isTrue);
  }

  Future<void> _testGetProjectChangesWithPagination() async {
    final projectId = 'test-pagination';

    // Seed multiple changes
    for (int i = 1; i <= 5; i++) {
      await seedChange(
        changePayload(
          domainId: projectId,
          entityType: 'task',
          entityId: 'task-$i',
          changeAt: baseTime.add(Duration(minutes: i)),
          data: {'nameLocal': 'Task $i'},
        ),
      );
    }

    // Get first page
    final firstPage = await getProjectChanges(projectId, limit: 2);
    expect(firstPage['changes'].length, 2);
    expect(firstPage.containsKey('cursor'), isTrue);

    final cursor = firstPage['cursor'] as int;

    // Get second page using cursor
    final secondPage = await getProjectChanges(
      projectId,
      cursor: cursor,
      limit: 2,
    );
    expect(secondPage['changes'].length, 2);

    // Verify no overlap between pages
    final firstPageSeqs = firstPage['changes']
        .map((c) => c['seq'] as int)
        .toSet();
    final secondPageSeqs = secondPage['changes']
        .map((c) => c['seq'] as int)
        .toSet();
    expect(firstPageSeqs.intersection(secondPageSeqs), isEmpty);
  }

  Future<void> _testGetProjectChangesUrlEncoded() async {
    final projectId = 'test@project.com';

    await seedChange(
      changePayload(
        domainId: projectId,
        entityType: 'project',
        entityId: 'proj-1',
        changeAt: baseTime,
        data: {'nameLocal': 'Encoded Project'},
      ),
    );

    final resp = await getProjectChanges(projectId);

    expect(resp['changes'], isA<List>());
    final changes = resp['changes'] as List;
    expect(changes.length, 1);
    expect(changes.first['domainId'], projectId);
  }

  Future<void> _testGetProjectChangesInvalidLimit() async {
    final baseUrl = await resolveBaseUrl();
    final uri = baseUrl.replace(
      path: '/api/projects/test/changes',
      queryParameters: {'limit': 'invalid'},
    );

    final req = await HttpClient().getUrl(uri);
    final res = await req.close();
    expect(res.statusCode, 400);
  }

  Future<void> _testGetProjectChangesInvalidCursor() async {
    final baseUrl = await resolveBaseUrl();
    final uri = baseUrl.replace(
      path: '/api/projects/test/changes',
      queryParameters: {'cursor': 'invalid'},
    );

    final req = await HttpClient().getUrl(uri);
    final res = await req.close();
    expect(res.statusCode, 400);
  }

  Future<void> _testPostChangesFieldLevelConflict() async {
    final project = 'proj-fl';
    final entity = 'entity-fl-1';
    await seedChange(
      changePayload(
        domainId: project,
        entityType: 'task',
        entityId: entity,
        changeAt: baseTime,
        data: {'rank': '1', 'nameLocal': 'Test Task'},
      ),
    );
    final newer = baseTime.add(const Duration(minutes: 5));
    final resp = await postSingleChange(
      changePayload(
        domainId: project,
        entityType: 'task',
        entityId: entity,
        changeAt: newer,
        data: {'rank': '2'},
        addDefaultParentId: false,
      ),
    );
    final cu = resp['changeUpdates'].first['updates'] as Map<String, dynamic>;
    final su = resp['stateUpdates'].first['state'] as Map<String, dynamic>;
    expect(cu['operation'], 'update');
    expect(
      cu['operationInfoJson'],
      equals(jsonEncode({'outdatedBys': [], 'noOpFields': []})),
    );
    expect(cu['stateChanged'], isTrue);
    expect(cu['dataJson'], jsonEncode({'rank': '2'}));
    expect(su['data_rank'], '2');
    expect(su['data_rank_changeAt_'], newer.toUtc().toIso8601String());
  }

  Future<void> _testPostChangesLocalMatchingStorageId() async {
    final baseUrl = await resolveBaseUrl();
    final uri = baseUrl.replace(path: '/api/changes');

    // First discover the server's storage ID
    final dummyResponse = await postSingleChange(
      changePayload(
        domainId: 'discover-storage-id',
        entityType: 'project',
        entityId: 'dummy',
        changeAt: baseTime,
        data: {'nameLocal': 'Dummy'},
      ),
    );
    final serverStorageId = dummyResponse['storageId'] as String;

    final payload = [
      changePayload(
        domainId: 'test-local-match',
        entityType: 'project',
        entityId: 'entity-1',
        changeAt: baseTime,
        data: {'nameLocal': 'Test Entity'},
      ),
    ];

    // Clear storageId for save mode
    payload[0]['storageId'] = '';

    final body = {
      'changes': payload,
      'srcStorageType': 'local',
      'srcStorageId': serverStorageId, // Matches server storage ID
      'storageMode': 'save',
      'includeChangeUpdates': true,
      'includeStateUpdates': true,
    };

    final req = await HttpClient().postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close();

    expect(res.statusCode, 200);
    final respBodyStr = await res.transform(utf8.decoder).join();
    final json = jsonDecode(respBodyStr) as Map<String, dynamic>;

    expect(json['storageType'], isNotEmpty);
    expect(json['storageId'], equals(serverStorageId));
    expect(json['changeUpdates'], isA<List>());
    expect(json['stateUpdates'], isA<List>());
  }

  Future<void> _testPostChangesLocalDifferentStorageId() async {
    final baseUrl = await resolveBaseUrl();
    final uri = baseUrl.replace(path: '/api/changes');

    // First discover the server's storage ID
    final dummyResponse = await postSingleChange(
      changePayload(
        domainId: 'discover-storage-id-2',
        entityType: 'project',
        entityId: 'dummy',
        changeAt: baseTime,
        data: {'nameLocal': 'Dummy'},
      ),
    );
    final serverStorageId = dummyResponse['storageId'] as String;

    final payload = [
      changePayload(
        domainId: 'test-local-diff',
        entityType: 'project',
        entityId: 'entity-1',
        changeAt: baseTime,
        data: {'nameLocal': 'Test Entity'},
      ),
    ];

    // Clear storageId for save mode
    payload[0]['storageId'] = '';

    final body = {
      'changes': payload,
      'srcStorageType': 'local',
      'srcStorageId': 'different-storage-id', // Different from server
      'storageMode': 'save',
      'includeChangeUpdates': true,
      'includeStateUpdates': true,
    };

    final req = await HttpClient().postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close();

    expect(res.statusCode, 200);
    final respBodyStr = await res.transform(utf8.decoder).join();
    final json = jsonDecode(respBodyStr) as Map<String, dynamic>;

    expect(json['storageType'], isNotEmpty);
    expect(json['storageId'], equals(serverStorageId));
    expect(json['changeUpdates'], isA<List>());
    expect(json['stateUpdates'], isA<List>());
  }

  Future<void> _testPostChangesCloudStorage() async {
    final baseUrl = await resolveBaseUrl();
    final uri = baseUrl.replace(path: '/api/changes');

    // First discover the server's storage ID
    final dummyResponse = await postSingleChange(
      changePayload(
        domainId: 'discover-storage-id-3',
        entityType: 'project',
        entityId: 'dummy',
        changeAt: baseTime,
        data: {'nameLocal': 'Dummy'},
      ),
    );
    final serverStorageId = dummyResponse['storageId'] as String;

    final payload = [
      changePayload(
        domainId: 'test-cloud',
        entityType: 'project',
        entityId: 'entity-1',
        changeAt: baseTime,
        data: {'nameLocal': 'Test Entity'},
      ),
    ];

    final body = {
      'changes': payload,
      'srcStorageType': 'cloud',
      'srcStorageId': 'cloud',
      'storageMode': 'sync',
      'includeChangeUpdates': true,
      'includeStateUpdates': true,
    };

    final req = await HttpClient().postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close();

    expect(res.statusCode, 200);
    final respBodyStr = await res.transform(utf8.decoder).join();
    final json = jsonDecode(respBodyStr) as Map<String, dynamic>;

    expect(json['storageType'], isNotEmpty);
    expect(json['storageId'], equals(serverStorageId));
    expect(json['changeUpdates'], isA<List>());
    expect(json['stateUpdates'], isA<List>());
  }
}

/// Register the full suite of API change network tests, using the provided
/// async resolver to obtain the server base URL at runtime.
///
/// final body = {
///   'changes': payload,
///   'srcStorageType': 'local',
///   'srcStorageId': serverStorageId,
///   'storageMode': 'save',
///   'includeChangeUpdates': true,
///   'includeStateUpdates': true,
/// };
void runApiChangesNetworkTests(Future<Uri> Function() resolveBaseUrl) {
  final suite = ApiChangesNetworkTestSuite(resolveBaseUrl);
  suite.runAllTests();
}
