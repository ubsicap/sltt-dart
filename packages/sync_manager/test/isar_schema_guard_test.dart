import 'dart:convert';
import 'dart:io';

import 'package:hashlib/hashlib.dart';
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
    return crc32.convert(input.codeUnits).toString();
  }

  Future<Map<String, dynamic>> readSchemaInfo() async {
    final file = File(schemaPath());
    expect(
      await file.exists(),
      isTrue,
      reason: '.isar.schemas file is missing',
    );
    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return decoded;
  }

  Future<List<String>> readSchemaNames() async {
    final decoded = await readSchemaInfo();
    final names = (decoded['schemaNames'] as List).whereType<String>().toList()
      ..sort();
    return names;
  }

  Future<void> initializeWith(
    List<CollectionSchema> providedSchemas, {
    bool? backupAndSwitchOnMissingSchemas,
  }) async {
    final storage = IsarStorageService(
      dbName,
      'SchemaGuardTest',
      dbDirectory: tempDir.path,
    );
    await storage.initialize(
      providedEntityStateSchemas: providedSchemas,
      backupAndSwitchOnMissingSchemas: backupAndSwitchOnMissingSchemas ?? false,
    );
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
      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);

      final info = await readSchemaInfo();
      final names = await readSchemaNames();
      final expectedInfo = IsarStorageService.calculateSchemasInfo(
        incomingSchemas: [IsarTaskStateSchema],
      );

      expect(names, equals([...names]..sort()));
      expect(names, contains(IsarTaskStateSchema.name));
      expect(info['coreSchemaNames'], equals(expectedInfo['coreSchemaNames']));
      expect(
        info['coreSchemaNamesLength'],
        equals(expectedInfo['coreSchemaNamesLength']),
      );
      expect(
        info['schemaNamesLength'],
        equals(expectedInfo['schemaNamesLength']),
      );
      expect(
        info['schemaNamesCrc32'],
        equals(expectedInfo['schemaNamesCrc32']),
      );
    });

    test('updates manifest when requested schemas are a superset', () async {
      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final initialNames = await readSchemaNames();

      await initializeWith([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
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
      await initializeWith([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final oldNames = await readSchemaNames();
      final oldHash = schemaHash(oldNames);

      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);

      expect(await File('${dbPath()}.$oldHash.bak').exists(), isTrue);
      expect(await File('${schemaPath()}.$oldHash.bak').exists(), isTrue);
    });

    test('restores requested-schema backup when available', () async {
      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final taskOnlyNames = await readSchemaNames();
      final taskOnlyHash = schemaHash(taskOnlyNames);

      await File(dbPath()).copy('${dbPath()}.$taskOnlyHash.bak');
      await File(schemaPath()).copy('${schemaPath()}.$taskOnlyHash.bak');

      await initializeWith([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final expandedNames = await readSchemaNames();
      final expandedHash = schemaHash(expandedNames);

      expect(expandedHash, isNot(equals(taskOnlyHash)));

      // Simulate a bad live database state before switching back.
      await File(dbPath()).writeAsBytes(List<int>.filled(64, 7), flush: true);

      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);

      final restoredNames = await readSchemaNames();
      expect(restoredNames, equals(taskOnlyNames));
      expect(await File('${dbPath()}.$expandedHash.bak').exists(), isTrue);
      expect(await File('${schemaPath()}.$expandedHash.bak').exists(), isTrue);
    });

    test('throws in strict mode when requested schemas are reduced', () async {
      await initializeWith([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final oldNames = await readSchemaNames();
      final oldHash = schemaHash(oldNames);

      await expectLater(
        () => initializeWith([
          IsarTaskStateSchema,
        ], backupAndSwitchOnMissingSchemas: false),
        throwsA(isA<StateError>()),
      );

      expect(await File('${dbPath()}.$oldHash.bak').exists(), isFalse);
      expect(await File('${schemaPath()}.$oldHash.bak').exists(), isFalse);
      expect(await readSchemaNames(), equals(oldNames));
    });

    test('does not throw in strict mode when schemas match exactly', () async {
      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);

      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: false);

      final names = await readSchemaNames();
      expect(names, contains(IsarTaskStateSchema.name));
    });
  });
}
