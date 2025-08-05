import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  final baseUrl = Platform.environment['CLOUD_BASE_URL'] ?? kCloudDevUrl;
  print('Testing against: $baseUrl');
  const testProjectId = '_test_cloud_create_changes';
  final now = DateTime.now().toUtc();
  final customChangeAt = now
      .subtract(const Duration(minutes: 5))
      .toIso8601String();

  group('Cloud Create Changes API', () {
    test('preserves custom changeAt and sets cloudAt > changeAt', () async {
      final origSeq = 123;
      final testCid = BaseChangeLogEntry.generateCid();

      // 1. Post a change with a custom changeAt
      final postResponse = await http.post(
        Uri.parse('$baseUrl/api/changes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'seq': origSeq,
            'projectId': testProjectId,
            'entityType': 'document',
            'operation': 'create',
            'entityId': 'doc-abc',
            'changeAt': customChangeAt,
            'cid': testCid,
            'data': {'title': 'Cloud Test', 'content': 'Hello cloud!'},
          },
        ]),
      );
      expect(postResponse.statusCode, 200, reason: postResponse.body);

      final postResult = jsonDecode(postResponse.body);
      expect(postResult['success'], isTrue);

      // get seqMap from postResult and use its seq to fetch change
      final seqMap = postResult['seqMap'] as Map<String, dynamic>;
      expect(seqMap, isNotEmpty, reason: 'Expected seqMap to be non-empty');
      print('seqMap: ${jsonEncode(seqMap)}');

      final newSeq = seqMap['$origSeq'] as int?;

      // 2. Fetch changes for the project
      final getResponse = await http.get(
        Uri.parse('$baseUrl/api/projects/$testProjectId/changes/$newSeq'),
      );
      expect(getResponse.statusCode, 200, reason: getResponse.body);

      final createdChange = jsonDecode(getResponse.body);
      expect(createdChange, isNotNull);

      // 4. Assert changeAt is preserved and cloudAt > changeAt
      expect(createdChange['changeAt'], customChangeAt);
      expect(createdChange['cloudAt'], isNotNull);

      final changeAtTime = DateTime.parse(createdChange['changeAt']).toUtc();
      final cloudAtTime = DateTime.parse(createdChange['cloudAt']).toUtc();
      expect(
        cloudAtTime.isAfter(changeAtTime),
        isTrue,
        reason: 'cloudAt should be after changeAt',
      );
    });
  });
}
