import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:sync_manager/src/models/isar_project_state.dart';
import 'package:sync_manager/src/models/isar_task_state.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  const dbName = 'isar_schema_guard_test_db';

  String dbPath() => '${tempDir.path}/$dbName.isar';
  String schemaPath() => '${tempDir.path}/$dbName.isar.schemas';

  String schemaHash(List<String> schemaNames) {
    final input = schemaNames.join('|');
    var hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  Future<List<String>> readSchemaNames() async {
    final file = File(schemaPath());
    expect(
      await file.exists(),
      isTrue,
      reason: '.isar.schemas file is missing',
    );
    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final names = (decoded['schemaNames'] as List).whereType<String>().toList()
      ..sort();
    return names;
  }

  Future<void> initializeWith(List<CollectionSchema> providedSchemas) async {
    final storage = IsarStorageService(
      dbName,
      'SchemaGuardTest',
      dbDirectory: tempDir.path,
    );
    await storage.initialize(providedEntityStateSchemas: providedSchemas);
    await storage.close();
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_schema_guard_');
  });

  tearDown(() async {
    await IsarStorageService.deleteDatabaseFiles(dbName, dirPath: tempDir.path);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Isar schema guard', () {
    test('creates sorted schema manifest on initialize', () async {
      await initializeWith([IsarTaskStateSchema]);

      final names = await readSchemaNames();
      expect(names, equals([...names]..sort()));
      expect(names, contains(IsarTaskStateSchema.name));
    });

    test('updates manifest when requested schemas are a superset', () async {
      await initializeWith([IsarTaskStateSchema]);
      final initialNames = await readSchemaNames();

      await initializeWith([IsarTaskStateSchema, IsarProjectStateSchema]);
      final expandedNames = await readSchemaNames();

      expect(expandedNames.length, greaterThan(initialNames.length));
      expect(expandedNames.toSet().containsAll(initialNames), isTrue);

      final backupFiles = await tempDir
          .list()
          .where((e) => e is File && e.path.endsWith('.bak'))
          .toList();
      expect(backupFiles, isEmpty);
    });

    test('creates hash backups when requested schemas are reduced', () async {
      await initializeWith([IsarTaskStateSchema, IsarProjectStateSchema]);
      final oldNames = await readSchemaNames();
      final oldHash = schemaHash(oldNames);

      await initializeWith([IsarTaskStateSchema]);

      expect(await File('${dbPath()}.$oldHash.bak').exists(), isTrue);
      expect(await File('${schemaPath()}.$oldHash.bak').exists(), isTrue);
    });

    test('restores requested-schema backup when available', () async {
      await initializeWith([IsarTaskStateSchema]);
      final taskOnlyNames = await readSchemaNames();
      final taskOnlyHash = schemaHash(taskOnlyNames);

      await File(dbPath()).copy('${dbPath()}.$taskOnlyHash.bak');
      await File(schemaPath()).copy('${schemaPath()}.$taskOnlyHash.bak');

      await initializeWith([IsarTaskStateSchema, IsarProjectStateSchema]);
      final expandedNames = await readSchemaNames();
      final expandedHash = schemaHash(expandedNames);

      expect(expandedHash, isNot(equals(taskOnlyHash)));

      // Simulate a bad live database state before switching back.
      await File(dbPath()).writeAsBytes(List<int>.filled(64, 7), flush: true);

      await initializeWith([IsarTaskStateSchema]);

      final restoredNames = await readSchemaNames();
      expect(restoredNames, equals(taskOnlyNames));
      expect(await File('${dbPath()}.$expandedHash.bak').exists(), isTrue);
      expect(await File('${schemaPath()}.$expandedHash.bak').exists(), isTrue);
    });
  });
}
