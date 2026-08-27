import 'dart:io';

import 'package:sync_manager/src/isar_storage_service.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late Directory archiveParentDir;
  const dbName = 'isar_storage_service_files_cleanup_test_db';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_storage_clean_');
    archiveParentDir = await Directory.systemTemp.createTemp(
      'isar_storage_archive_',
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    if (await archiveParentDir.exists()) {
      await archiveParentDir.delete(recursive: true);
    }
  });

  test('deleteDatabaseFiles removes Isar files, directory, and backups', () async {
    final dbFile = File('${tempDir.path}/$dbName.isar');
    final lockFile = File('${tempDir.path}/$dbName.isar-lck');
    final schemaFile = File('${tempDir.path}/$dbName.isar.schemas');
    final dbDir = Directory('${tempDir.path}/$dbName');
    final paginationJobDbFile = File(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName.isar',
    );
    final paginationJobLck = File(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName.isar-lck',
    );
    final paginationJobDbDir = Directory(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName',
    );
    final backupDbFile = File('${tempDir.path}/$dbName.isar.123_1_abc.bak');
    final backupSchemaFile = File(
      '${tempDir.path}/$dbName.isar.schemas.123_1_abc.bak',
    );
    final paginationJobBackupDbFile = File(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName.isar.123_1_abc.bak',
    );
    final paginationJobBackupSchemaFile = File(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName.isar.schemas.123_1_abc.bak',
    );

    await dbFile.writeAsString('db');
    await lockFile.writeAsString('lock');
    await schemaFile.writeAsString('schema');
    await paginationJobDbFile.writeAsString('job-db');
    await paginationJobLck.writeAsString('job-lock');
    await backupDbFile.writeAsString('db-backup');
    await backupSchemaFile.writeAsString('schema-backup');
    await paginationJobBackupDbFile.writeAsString('job-db-backup');
    await paginationJobBackupSchemaFile.writeAsString('job-schema-backup');
    await dbDir.create(recursive: true);
    await paginationJobDbDir.create(recursive: true);
    await File('${dbDir.path}/data.txt').writeAsString('data');
    await File(
      '${paginationJobDbDir.path}/job-data.txt',
    ).writeAsString('job-data');

    final result = await IsarStorageService.deleteDatabaseFiles(
      dbName,
      dirPath: tempDir.path,
    );

    expect(
      result,
      isTrue,
      reason: 'deleteDatabaseFiles should succeed for $dbName',
    );
    expect(
      await dbFile.exists(),
      isFalse,
      reason: 'expected main Isar file to be removed',
    );
    expect(
      await lockFile.exists(),
      isFalse,
      reason: 'expected lock file to be removed',
    );
    expect(
      await schemaFile.exists(),
      isFalse,
      reason: 'expected schema file to be removed',
    );
    expect(
      await dbDir.exists(),
      isFalse,
      reason: 'expected database directory to be removed',
    );
    expect(
      await paginationJobDbFile.exists(),
      isFalse,
      reason: 'expected pagination job main Isar file to be removed',
    );
    expect(
      await paginationJobLck.exists(),
      isFalse,
      reason: 'expected pagination job lock file to be removed',
    );
    expect(
      await paginationJobDbDir.exists(),
      isFalse,
      reason: 'expected pagination job database directory to be removed',
    );
    expect(
      await backupDbFile.exists(),
      isFalse,
      reason: 'expected backup DB file to be removed',
    );
    expect(
      await backupSchemaFile.exists(),
      isFalse,
      reason: 'expected backup schema file to be removed',
    );
    expect(
      await paginationJobBackupDbFile.exists(),
      isFalse,
      reason: 'expected pagination job backup DB file to be removed',
    );
    expect(
      await paginationJobBackupSchemaFile.exists(),
      isFalse,
      reason: 'expected pagination job backup schema file to be removed',
    );
  });

  test('archiveDatabaseFiles moves files and directory to destination', () async {
    final dbFile = File('${tempDir.path}/$dbName.isar');
    final lockFile = File('${tempDir.path}/$dbName.isar-lck');
    final schemaFile = File('${tempDir.path}/$dbName.isar.schemas');
    final dbDir = Directory('${tempDir.path}/$dbName');
    final paginationJobDbFile = File(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName.isar',
    );
    final paginationJobLck = File(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName.isar-lck',
    );
    final paginationJobDbDir = Directory(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName',
    );
    final backupDbFile = File('${tempDir.path}/$dbName.isar.123_1_abc.bak');
    final backupSchemaFile = File(
      '${tempDir.path}/$dbName.isar.schemas.123_1_abc.bak',
    );
    final paginationJobBackupDbFile = File(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName.isar.123_1_abc.bak',
    );
    final paginationJobBackupSchemaFile = File(
      '${tempDir.path}/entity_state_pagination_jobs_$dbName.isar.schemas.123_1_abc.bak',
    );

    await dbFile.writeAsString('db');
    await lockFile.writeAsString('lock');
    await schemaFile.writeAsString('schema');
    await paginationJobDbFile.writeAsString('job-db');
    await paginationJobLck.writeAsString('job-lock');
    await backupDbFile.writeAsString('db-backup');
    await backupSchemaFile.writeAsString('schema-backup');
    await paginationJobBackupDbFile.writeAsString('job-db-backup');
    await paginationJobBackupSchemaFile.writeAsString('job-schema-backup');
    await dbDir.create(recursive: true);
    await paginationJobDbDir.create(recursive: true);
    await File('${dbDir.path}/data.txt').writeAsString('data');
    await File(
      '${paginationJobDbDir.path}/job-data.txt',
    ).writeAsString('job-data');

    final destination = Directory('${archiveParentDir.path}/destination');
    final result = await IsarStorageService.archiveDatabaseFiles(
      dbName,
      dirPath: tempDir.path,
      destinationDirPath: destination.path,
    );

    expect(
      result,
      isTrue,
      reason: 'archiveDatabaseFiles should succeed for $dbName',
    );
    expect(
      await dbFile.exists(),
      isFalse,
      reason: 'expected source main Isar file to be moved or removed',
    );
    expect(
      await lockFile.exists(),
      isFalse,
      reason: 'expected source lock file to be moved or removed',
    );
    expect(
      await schemaFile.exists(),
      isFalse,
      reason: 'expected source schema file to be moved or removed',
    );
    expect(
      await dbDir.exists(),
      isFalse,
      reason: 'expected source database directory to be moved or removed',
    );
    expect(
      await paginationJobDbFile.exists(),
      isFalse,
      reason:
          'expected source pagination job main Isar file to be moved or removed',
    );
    expect(
      await paginationJobLck.exists(),
      isFalse,
      reason: 'expected source pagination job lock file to be moved or removed',
    );
    expect(
      await paginationJobDbDir.exists(),
      isFalse,
      reason: 'expected source pagination job directory to be moved or removed',
    );
    expect(
      await backupDbFile.exists(),
      isFalse,
      reason: 'expected source backup DB file to be moved or removed',
    );
    expect(
      await backupSchemaFile.exists(),
      isFalse,
      reason: 'expected source backup schema file to be moved or removed',
    );
    expect(
      await paginationJobBackupDbFile.exists(),
      isFalse,
      reason:
          'expected source pagination job backup DB file to be moved or removed',
    );
    expect(
      await paginationJobBackupSchemaFile.exists(),
      isFalse,
      reason:
          'expected source pagination job backup schema file to be moved or removed',
    );

    final archivedDbFile = File('${destination.path}/$dbName.isar');
    final archivedLockFile = File('${destination.path}/$dbName.isar-lck');
    final archivedSchemaFile = File('${destination.path}/$dbName.isar.schemas');
    final archivedDbDir = Directory('${destination.path}/$dbName');
    final archivedBackupDbFile = File(
      '${destination.path}/$dbName.isar.123_1_abc.bak',
    );
    final archivedBackupSchemaFile = File(
      '${destination.path}/$dbName.isar.schemas.123_1_abc.bak',
    );
    final archivedPaginationJobDbFile = File(
      '${destination.path}/entity_state_pagination_jobs_$dbName.isar',
    );
    final archivedPaginationJobLck = File(
      '${destination.path}/entity_state_pagination_jobs_$dbName.isar-lck',
    );
    final archivedPaginationJobDbDir = Directory(
      '${destination.path}/entity_state_pagination_jobs_$dbName',
    );
    final archivedPaginationJobBackupDbFile = File(
      '${destination.path}/entity_state_pagination_jobs_$dbName.isar.123_1_abc.bak',
    );
    final archivedPaginationJobBackupSchemaFile = File(
      '${destination.path}/entity_state_pagination_jobs_$dbName.isar.schemas.123_1_abc.bak',
    );

    expect(
      await archivedDbFile.exists(),
      isTrue,
      reason: 'expected archived main Isar file to exist at destination',
    );
    expect(
      await archivedLockFile.exists(),
      isTrue,
      reason: 'expected archived lock file to exist at destination',
    );
    expect(
      await archivedSchemaFile.exists(),
      isTrue,
      reason: 'expected archived schema file to exist at destination',
    );
    expect(
      await archivedDbDir.exists(),
      isTrue,
      reason: 'expected archived database directory to exist at destination',
    );
    expect(
      await archivedBackupDbFile.exists(),
      isTrue,
      reason: 'expected archived backup DB file to exist at destination',
    );
    expect(
      await archivedBackupSchemaFile.exists(),
      isTrue,
      reason: 'expected archived backup schema file to exist at destination',
    );
    expect(
      await archivedPaginationJobDbFile.exists(),
      isTrue,
      reason:
          'expected archived pagination job main Isar file to exist at destination',
    );
    expect(
      await archivedPaginationJobLck.exists(),
      isTrue,
      reason:
          'expected archived pagination job lock file to exist at destination',
    );
    expect(
      await archivedPaginationJobDbDir.exists(),
      isTrue,
      reason:
          'expected archived pagination job database directory to exist at destination',
    );
    expect(
      await archivedPaginationJobBackupDbFile.exists(),
      isTrue,
      reason:
          'expected archived pagination job backup DB file to exist at destination',
    );
    expect(
      await archivedPaginationJobBackupSchemaFile.exists(),
      isTrue,
      reason:
          'expected archived pagination job backup schema file to exist at destination',
    );
    expect(
      await File('${archivedDbDir.path}/data.txt').readAsString(),
      'data',
      reason: 'expected archived database directory contents to be preserved',
    );
    expect(
      await File(
        '${archivedPaginationJobDbDir.path}/job-data.txt',
      ).readAsString(),
      'job-data',
      reason:
          'expected archived pagination job directory contents to be preserved',
    );
  });
}
