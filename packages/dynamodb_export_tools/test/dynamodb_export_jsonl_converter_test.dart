import 'dart:convert';
import 'dart:io';

import 'package:dynamodb_export_tools/dynamodb_export_tools.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('DynamoExportJsonlConverter', () {
    late Directory tempRoot;
    late Directory inputDir;
    late Directory outputDir;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp(
        'dynamo_export_tools_test',
      );
      inputDir = Directory(
        p.join(tempRoot.path, 'AWSDynamoDB', '01772818685648-730afa12', 'data'),
      );
      outputDir = Directory(p.join(tempRoot.path, 'out'));
      await inputDir.create(recursive: true);
      await outputDir.create(recursive: true);
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('converts export lines into routed JSONL files and manifest', () async {
      final source = File(p.join(inputDir.path, 'sample.json.gz'));
      final lines = [
        jsonEncode({
          'Item': {
            'pk': {
              'S':
                  r'$sltt#state#domainType_project#domainId_abc123#entityType_note',
            },
            'sk': {'S': r'$states#state#entityId_note1'},
            'gsi2pk': {
              'S':
                  r'$sltt#state#domainType_project#domainId_abc123#entityType_note#parentId_video1',
            },
            'gsi2sk': {'S': 'parentProp_notes#rank_001'},
            'title': {'S': 'hello'},
          },
        }),
        jsonEncode({
          'Item': {
            'pk': {
              'S':
                  r'$sltt#change#domainType_project#domainId_abc123#entityType_note#entityId_note1',
            },
            'sk': {'S': r'$changes#change#cid_123'},
            'seq': {'N': '42'},
          },
        }),
        jsonEncode({
          'Item': {
            'pk': {'S': r'$sltt#mystery#domainType_project#domainId_abc123'},
            'sk': {'S': r'$mystery#thing'},
          },
        }),
      ].join('\n');
      await source.writeAsBytes(gzip.encode(utf8.encode(lines)));

      final converter = DynamoExportJsonlConverter();
      final manifest = await converter.convertDirectory(
        inputDirectory: Directory(
          p.join(tempRoot.path, 'AWSDynamoDB', '01772818685648-730afa12'),
        ),
        outputDirectory: outputDir,
      );

      expect(manifest.totalRowsSeen, 3);
      expect(manifest.rawRowsWritten, 3);
      expect(manifest.unsupportedRows, 1);
      expect(manifest.exportId, '01772818685648-730afa12');

      expect(
        File(p.join(outputDir.path, 'raw_items-3.jsonl')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(outputDir.path, 'entity_state__note-1.jsonl')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(outputDir.path, 'change_log_entries-1.jsonl')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(outputDir.path, 'unsupported_items-1.jsonl')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(outputDir.path, 'manifest.json')).existsSync(),
        isTrue,
      );

      final noteRows = await File(
        p.join(outputDir.path, 'entity_state__note-1.jsonl'),
      ).readAsLines();
      expect(noteRows, hasLength(1));

      final manifestJson =
          jsonDecode(
                await File(
                  p.join(outputDir.path, 'manifest.json'),
                ).readAsString(),
              )
              as Map<String, dynamic>;
      expect(manifestJson['unsupportedRows'], 1);
      expect(manifestJson['tables'], isA<List<dynamic>>());
    });

    test(
      'handles gzip-compressed content even when file extension is .json',
      () async {
        final source = File(p.join(inputDir.path, 'sample.json'));
        final lines = [
          jsonEncode({
            'Item': {
              'pk': {
                'S':
                    r'$sltt#state#domainType_project#domainId_abc123#entityType_note',
              },
              'sk': {'S': r'$states#state#entityId_note1'},
            },
          }),
        ].join('\n');
        await source.writeAsBytes(gzip.encode(utf8.encode(lines)));

        final converter = DynamoExportJsonlConverter();
        final manifest = await converter.convertDirectory(
          inputDirectory: Directory(
            p.join(tempRoot.path, 'AWSDynamoDB', '01772818685648-730afa12'),
          ),
          outputDirectory: outputDir,
        );

        expect(manifest.totalRowsSeen, 1);
        expect(
          File(
            p.join(outputDir.path, 'entity_state__note-1.jsonl'),
          ).existsSync(),
          isTrue,
        );
      },
    );
  });
}
