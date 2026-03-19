import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/dynamo_entity_state.dart';
import 'package:sltt_core/sltt_core.dart';

Future<void> main(List<String> args) async {
  SlttLogger.init(level: SlttLogLevel.fine);

  String? awsProfile;
  String stage = 'dev';
  String domainType = 'project';
  int pageSize = 100;
  bool writeChanges = false;

  for (int index = 0; index < args.length; index++) {
    switch (args[index]) {
      case '--aws-profile':
        if (index + 1 < args.length) {
          awsProfile = args[index + 1];
          index++;
        }
        break;
      case '--stage':
        if (index + 1 < args.length) {
          stage = args[index + 1];
          index++;
        }
        break;
      case '--domain-type':
        if (index + 1 < args.length) {
          domainType = args[index + 1];
          index++;
        }
        break;
      case '--page-size':
        if (index + 1 < args.length) {
          pageSize = int.tryParse(args[index + 1]) ?? pageSize;
          index++;
        }
        break;
      case '--write-changes':
        writeChanges = true;
        break;
      case '--help':
        _printUsage();
        return;
    }
  }

  // Allow -1 to mean "no limit" (let the storage/backend decide the page size).
  if (pageSize == 0 || pageSize < -1) {
    stderr.writeln('--page-size must be -1 (no limit) or a positive integer');
    exitCode = 64;
    return;
  }

  if (writeChanges) {
    stderr.writeln(
      '--write-changes is not implemented yet. This script currently supports dry-run output only.',
    );
    exitCode = 2;
    return;
  }

  awsProfile ??= 'sltt-dart-dev';

  print('🔧 Starting changeDataHash dry-run migration');
  print('   AWS Profile: $awsProfile');
  print('   Stage: $stage');
  print('   Domain Type: $domainType');
  print('   Page Size: $pageSize');
  print('   Dry Run: true');

  final useCloudStorage = Platform.environment['USE_CLOUD_STORAGE'] ?? 'true';
  final useLocalDynamoDB = useCloudStorage != 'true';

  DynamoDBStorageService? sourceStorage;
  try {
    final credentials = await AwsCredentialsService().getOrCreateCredentials();
    sourceStorage = StorageFactory.createStorage(
      credentials: credentials,
      useLocalDynamoDB: useLocalDynamoDB,
    );
    await sourceStorage.initialize();

    final srcStorageId = await sourceStorage.getStorageId();
    print('🗄️  Source Table: ${sourceStorage.tableName}');
    print('   Source Storage ID: $srcStorageId');
    print('   Region: ${sourceStorage.region}');

    final domainIds =
        await sourceStorage.getAllDomainIds(domainType: domainType)
          ..sort();
    print('📚 Found ${domainIds.length} $domainType domain(s)');

    for (final domainId in domainIds) {
      await _processDomain(
        sourceStorage: sourceStorage,
        domainType: domainType,
        domainId: domainId,
        pageSize: pageSize,
        srcStorageId: srcStorageId,
      );
    }

    print('✅ Dry-run migration completed');
  } on AwsCredentialsException catch (error, stackTrace) {
    stderr.writeln('❌ Credentials error: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
  } catch (error, stackTrace) {
    stderr.writeln('❌ Migration failed: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
  } finally {
    await sourceStorage?.close();
  }
}

Future<void> _processDomain({
  required DynamoDBStorageService sourceStorage,
  required String domainType,
  required String domainId,
  required int pageSize,
  required String srcStorageId,
}) async {
  print('');
  print('=== Domain $domainId ===');

  final replayStorage = InMemoryStorage(
    storageType: 'cloud',
    storageId: 'migration-replay-$domainId',
    fromJsonChangeLogEntry: DynamoChangeLogEntry.fromJson,
    fromJsonEntityState: DynamoEntityState.fromJson,
  );
  await replayStorage.initialize();

  int? sourceCursor;
  int? replayCursor;
  var pageNumber = 0;

  while (true) {
    final sourceChanges = await sourceStorage.getChangesWithCursor(
      domainType: domainType,
      domainId: domainId,
      cursor: sourceCursor,
      limit: pageSize == -1 ? null : pageSize,
    );

    if (sourceChanges.isEmpty) {
      break;
    }

    pageNumber++;
    print('--- Page $pageNumber (${sourceChanges.length} change(s)) ---');

    final result = await ChangeProcessingService.storeChanges(
      storageMode: 'sync',
      changes: sourceChanges.map((change) => change.toJson()).toList(),
      srcStorageType: sourceStorage.getStorageType(),
      srcStorageId: srcStorageId,
      storage: replayStorage,
      includeChangeUpdates: false,
      includeStateUpdates: false,
    );

    if (result.isError) {
      throw StateError(result.errorMessage ?? 'Unknown migration replay error');
    }

    final replayedChanges = await replayStorage.getChangesWithCursor(
      domainType: domainType,
      domainId: domainId,
      cursor: replayCursor,
      limit: pageSize == -1 ? null : pageSize,
    );

    for (final change in replayedChanges) {
      print(
        'change stateDataHash: cid=${change.cid} entityType=${change.entityType} entityId=${change.entityId} value=${change.stateDataHash}',
      );
    }

    if (replayedChanges.isNotEmpty) {
      replayCursor = replayedChanges.last.seq;
    }
    sourceCursor = sourceChanges.last.seq;
  }

  final stateStats = await replayStorage.getStateStats(
    domainType: domainType,
    domainId: domainId,
  );

  final entityTypes = stateStats.entityTypes.keys.toList()..sort();
  for (final entityType in entityTypes) {
    String? stateCursor;
    while (true) {
      final page = await replayStorage.getEntityStates(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        cursor: stateCursor,
        limit: pageSize == -1 ? null : pageSize,
      );

      final items = (page['items'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();
      if (items.isEmpty) {
        break;
      }

      for (final item in items) {
        final entityState = DynamoEntityState.fromJson(item);
        print(
          'entityState stateDataHash: entityType=${entityState.entityType} entityId=${entityState.entityId} value=${entityState.stateDataHash}',
        );
      }

      final hasMore = page['hasMore'] as bool? ?? false;
      if (!hasMore) {
        break;
      }
      stateCursor = page['nextCursor'] as String?;
      if (stateCursor == null || stateCursor.isEmpty) {
        break;
      }
    }
  }

  await replayStorage.close();
}

void _printUsage() {
  print('''
Dry-run migration for printing replayed stateDataHash values.

Usage: dart run bin/migrate_state_data_hash.dart [options]

Options:
  --aws-profile <profile>   AWS profile to use (default: sltt-dart-dev)
  --stage <stage>           Deployment stage label for logging (default: dev)
  --domain-type <type>      Domain type to scan (default: project)
  --page-size <count>       Number of source changes per page (default: 100). Use -1 to let the storage/backend decide (no limit).
  --write-changes           Reserved for future write mode; currently unsupported
  --help                    Show this help message
''');
}
