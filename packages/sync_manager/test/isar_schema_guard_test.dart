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

  SchemasInfo calculateInfo(
    List<CollectionSchema> incomingSchemas, {
    bool withFileInfo = false,
  }) {
    return IsarStorageService.calculateSchemasInfo(
      incomingSchemas: incomingSchemas,
      calculateFileInfoSchemaStatus: withFileInfo,
      fileInfoDirectoryPath: withFileInfo ? tempDir.path : null,
      fileInfoDatabaseName: withFileInfo ? dbName : null,
    );
  }

  String schemaHash(List<String> schemaNames) {
    final input = schemaNames.join('|');
    return crc32.convert(input.codeUnits).toString();
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
      final expectedIncomingSchemas = [IsarTaskStateSchema];

      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);

      final actualInfo = calculateInfo(expectedIncomingSchemas);
      final schemaNames = actualInfo.schemaNames;

      expect(schemaNames, equals([...schemaNames]..sort()));
      expect(schemaNames, contains(IsarTaskStateSchema.name));
      final expectedCoreSchemaNames =
          IsarStorageService.coreSchemas.map((s) => s.name).toList()..sort();
      final expectedSchemaNames = [
        ...expectedCoreSchemaNames,
        ...expectedIncomingSchemas.map((s) => s.name),
      ]..sort();
      expect(actualInfo.coreSchemaNames, equals(expectedCoreSchemaNames));
      expect(actualInfo.coreSchemaNamesLength, expectedCoreSchemaNames.length);
      expect(schemaNames, equals(expectedSchemaNames));
      expect(actualInfo.schemaNamesLength, expectedSchemaNames.length);
      expect(actualInfo.schemaNamesCrc32, schemaHash(expectedSchemaNames));
    });

    test('updates manifest when requested schemas are a superset', () async {
      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final initialInfo = calculateInfo([IsarTaskStateSchema]);

      await initializeWith([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final expandedInfo = calculateInfo([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ]);

      final initialNames = initialInfo.schemaNames;
      final expandedNames = expandedInfo.schemaNames;

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
      final oldInfo = calculateInfo([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], withFileInfo: true);
      final oldNames = oldInfo.fileInfoSchemaNames;
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
      final taskOnlyInfo = calculateInfo([
        IsarTaskStateSchema,
      ], withFileInfo: true);
      final taskOnlyNames = taskOnlyInfo.fileInfoSchemaNames;
      final taskOnlyHash = schemaHash(taskOnlyNames);

      await File(dbPath()).copy('${dbPath()}.$taskOnlyHash.bak');
      await File(schemaPath()).copy('${schemaPath()}.$taskOnlyHash.bak');

      await initializeWith([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final expandedInfo = calculateInfo([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], withFileInfo: true);
      final expandedNames = expandedInfo.fileInfoSchemaNames;
      final expandedHash = schemaHash(expandedNames);

      expect(expandedHash, isNot(equals(taskOnlyHash)));

      // Simulate a bad live database state before switching back.
      await File(dbPath()).writeAsBytes(List<int>.filled(64, 7), flush: true);

      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);

      final restoredInfo = calculateInfo([
        IsarTaskStateSchema,
      ], withFileInfo: true);
      final restoredNames = restoredInfo.fileInfoSchemaNames;
      expect(restoredNames, equals(taskOnlyNames));
      expect(await File('${dbPath()}.$expandedHash.bak').exists(), isTrue);
      expect(await File('${schemaPath()}.$expandedHash.bak').exists(), isTrue);
    });

    test('throws in strict mode when requested schemas are reduced', () async {
      await initializeWith([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);
      final oldInfo = calculateInfo([
        IsarTaskStateSchema,
        IsarProjectStateSchema,
      ], withFileInfo: true);
      final oldNames = oldInfo.fileInfoSchemaNames;
      final oldHash = schemaHash(oldNames);

      await expectLater(
        () => initializeWith([
          IsarTaskStateSchema,
        ], backupAndSwitchOnMissingSchemas: false),
        throwsA(isA<StateError>()),
      );

      expect(await File('${dbPath()}.$oldHash.bak').exists(), isFalse);
      expect(await File('${schemaPath()}.$oldHash.bak').exists(), isFalse);
      final strictInfo = calculateInfo([
        IsarTaskStateSchema,
      ], withFileInfo: true);
      expect(strictInfo.fileInfoSchemaNames, equals(oldNames));
    });

    test('does not throw in strict mode when schemas match exactly', () async {
      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: true);

      await initializeWith([
        IsarTaskStateSchema,
      ], backupAndSwitchOnMissingSchemas: false);

      final info = calculateInfo([IsarTaskStateSchema], withFileInfo: true);
      final names = info.fileInfoSchemaNames;
      expect(names, contains(IsarTaskStateSchema.name));
    });

    test('schema status is noInfo when file status is not requested', () async {
      final info = calculateInfo([IsarTaskStateSchema]);
      expect(info.schemaStatus, SchemaStatus.noInfo);
      expect(info.fileInfoSchemasPath, isEmpty);
      expect(info.fileInfoBackupPath, isEmpty);
      expect(info.fileInfoSchemaNames, isEmpty);
      expect(info.fileInfoCoreSchemaNames, isEmpty);
    });

    test(
      'schema status is addIncoming for first initialize with no schema file',
      () async {
        final info = calculateInfo([IsarTaskStateSchema], withFileInfo: true);
        expect(info.schemaStatus, SchemaStatus.addIncoming);
        expect(info.fileInfoSchemasPath, isEmpty);
        expect(info.fileInfoSchemaNames, isEmpty);
        expect(info.fileInfoCoreSchemaNames, isEmpty);
      },
    );

    test(
      'schema status is noChanges when incoming matches file schema names',
      () async {
        await initializeWith([
          IsarTaskStateSchema,
        ], backupAndSwitchOnMissingSchemas: true);

        final info = calculateInfo([IsarTaskStateSchema], withFileInfo: true);
        expect(info.schemaStatus, SchemaStatus.noChanges);
        expect(info.fileInfoSchemasPath, isNotEmpty);
        expect(info.fileInfoSchemaNames, equals(info.schemaNames));
      },
    );

    test(
      'schema status is missingHasNoBackup when incoming misses schemas and no backup exists',
      () async {
        await initializeWith([
          IsarTaskStateSchema,
          IsarProjectStateSchema,
        ], backupAndSwitchOnMissingSchemas: true);

        final info = calculateInfo([IsarTaskStateSchema], withFileInfo: true);
        expect(info.schemaStatus, SchemaStatus.missingHasNoBackup);
        expect(info.fileInfoBackupPath, isEmpty);
      },
    );

    test(
      'schema status is missingHasBackup when incoming misses schemas and backup exists',
      () async {
        await initializeWith([
          IsarTaskStateSchema,
        ], backupAndSwitchOnMissingSchemas: true);
        final taskOnlyInfo = calculateInfo([
          IsarTaskStateSchema,
        ], withFileInfo: true);
        final taskOnlyHash = schemaHash(taskOnlyInfo.fileInfoSchemaNames);

        await File(dbPath()).copy('${dbPath()}.$taskOnlyHash.bak');
        await File(schemaPath()).copy('${schemaPath()}.$taskOnlyHash.bak');

        await initializeWith([
          IsarTaskStateSchema,
          IsarProjectStateSchema,
        ], backupAndSwitchOnMissingSchemas: true);

        final info = calculateInfo([IsarTaskStateSchema], withFileInfo: true);
        expect(info.schemaStatus, SchemaStatus.missingHasBackup);
        expect(info.fileInfoBackupPath, isNotEmpty);
        expect(await File(info.fileInfoBackupPath).exists(), isTrue);
      },
    );
  });
}
