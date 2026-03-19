import 'dart:io';

import 'package:aws_backend/aws_backend.dart';
import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:aws_backend/src/models/dynamo_entity_state.dart';
import 'package:sltt_core/sltt_core.dart';

Future<void> main(List<String> args) async {
  SlttLogger.init(level: SlttLogLevel.warning);

  String? awsProfile;
  String stage = 'dev';
  String domainType = 'project';
  int pageSize = 100;
  String summaryFile = 'migration_state_data_hash_summary.yaml';
  bool includeTestDomainIds = false;
  bool writeChanges = false;
  bool exitOnError = false;

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
      case '--exit-on-error':
        exitOnError = true;
        break;
      case '--summary-file':
        if (index + 1 < args.length) {
          summaryFile = args[index + 1];
          index++;
        }
        break;
      case '--include-test-domainIds':
        includeTestDomainIds = true;
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
  print('   Summary File: $summaryFile');
  print('   Include Test Domains: $includeTestDomainIds');
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

    await _appendSummaryHeader(
      summaryFilePath: summaryFile,
      awsProfile: awsProfile,
      stage: stage,
      domainType: domainType,
      pageSize: pageSize,
      includeTestDomainIds: includeTestDomainIds,
    );

    for (final domainId in domainIds) {
      if (!includeTestDomainIds && domainId.startsWith('__test')) {
        // Skip test domains unless explicitly requested
        continue;
      }
      print('▶ Processing domain: $domainId');
      try {
        final summary = await _processDomain(
          sourceStorage: sourceStorage,
          domainType: domainType,
          domainId: domainId,
          pageSize: pageSize,
          srcStorageId: srcStorageId,
        );
        await _appendDomainSummary(
          summaryFilePath: summaryFile,
          summary: summary,
        );
        print('  ✓ Appended summary for domain: $domainId');
        final errors =
            (summary['errors'] as List<dynamic>? ?? const <dynamic>[]);
        if (exitOnError && errors.isNotEmpty) {
          stderr.writeln(
            'Exiting on first error encountered in domain: $domainId',
          );
          exitCode = 1;
          return;
        }
      } catch (error, stackTrace) {
        final errorSummary = <String, dynamic>{
          'domainId': domainId,
          'status': 'error',
          'changes': <Map<String, dynamic>>[],
          'states': <Map<String, dynamic>>[],
          'errors': <Map<String, dynamic>>[
            {'message': error.toString(), 'stackTrace': stackTrace.toString()},
          ],
        };
        await _appendDomainSummary(
          summaryFilePath: summaryFile,
          summary: errorSummary,
        );
        stderr.writeln('❌ Domain failed: $domainId -> $error');
        exitCode = 1;
      }
    }

    print('✅ Dry-run migration completed. Summary written to: $summaryFile');
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

Future<Map<String, dynamic>> _processDomain({
  required DynamoDBStorageService sourceStorage,
  required String domainType,
  required String domainId,
  required int pageSize,
  required String srcStorageId,
}) async {
  final replayStorage = InMemoryStorage(
    storageType: 'cloud',
    storageId: 'migration-replay-$domainId',
    fromJsonChangeLogEntry: DynamoChangeLogEntry.fromJson,
    fromJsonEntityState: DynamoEntityState.fromJson,
  );
  await replayStorage.initialize();

  // Step 1: accumulate all source changes (keyed by seq) as we page through them.
  // Step 4 later fills in computed stateDataHash values.
  final migrationChanges = <int, Map<String, dynamic>>{};
  // Preserve original change JSONs separately so we can compare before/after
  // without accidentally mutating the original objects stored here.
  final migrationOriginalChanges = <int, Map<String, dynamic>>{};

  // Final state view per entityType/entityId, merged from source states then
  // overwritten with replayed values from in-memory storage.
  final migrationStates = <String, Map<String, dynamic>>{};

  // Step 2: seqs whose stateChanged=false are queued here (FIFO); they are
  // skipped from storeChanges and assigned a borrowed hash in step 4.
  final skippedChangeSeqs = <int>[];

  int? sourceCursor;
  int? replayCursor;

  while (true) {
    // Step 1: fetch next page from the source (DynamoDB).
    final sourceChanges = await sourceStorage.getChangesWithCursor(
      domainType: domainType,
      domainId: domainId,
      cursor: sourceCursor,
      limit: pageSize == -1 ? null : pageSize,
    );

    if (sourceChanges.isEmpty) {
      break;
    }

    // Step 1+2: record every change in migrationChanges; split into
    // stateChanged=true (to replay) vs stateChanged=false (to skip).
    final stateChangedBatch = <BaseChangeLogEntry>[];
    for (final change in sourceChanges) {
      final json = change.toJson();
      // keep an immutable-ish copy of the original source JSON
      migrationOriginalChanges[change.seq] = Map<String, dynamic>.from(json);
      // work on a separate copy for migrationResults so we can add computed fields
      migrationChanges[change.seq] = Map<String, dynamic>.from(json);
      if (change.stateChanged) {
        stateChangedBatch.add(change);
      } else {
        skippedChangeSeqs.add(change.seq);
      }
    }

    // Step 2+3: only send stateChanged=true changes to storeChanges.
    if (stateChangedBatch.isNotEmpty) {
      final result = await ChangeProcessingService.storeChanges(
        storageMode: 'sync',
        changes: stateChangedBatch.map((change) => change.toJson()).toList(),
        srcStorageType: sourceStorage.getStorageType(),
        srcStorageId: srcStorageId,
        storage: replayStorage,
        includeChangeUpdates: false,
        includeStateUpdates: false,
      );

      if (result.isError) {
        throw StateError(
          result.errorMessage ?? 'Unknown migration replay error',
        );
      }

      // Step 3: cherry-pick computed stateDataHash values from replayStorage
      // using the same cursor window as the source page.
      final replayedChanges = await replayStorage.getChangesWithCursor(
        domainType: domainType,
        domainId: domainId,
        cursor: replayCursor,
        limit: pageSize == -1 ? null : pageSize,
      );

      for (final replayed in replayedChanges) {
        final entry = migrationChanges[replayed.seq];
        if (entry != null) {
          entry['stateDataHash'] = replayed.stateDataHash;
        }
      }

      if (replayedChanges.isNotEmpty) {
        replayCursor = replayedChanges.last.seq;
      }
    }

    sourceCursor = sourceChanges.last.seq;
  }

  // Step 4: assign hashes for skipped (stateChanged=false) changes.
  // A skipped change should carry forward the last known hash for its own
  // entityId, not the immediately previous global seq.
  final allSeqs = migrationChanges.keys.toList()..sort();
  final latestHashByEntity = <String, String>{};
  for (final seq in allSeqs) {
    final change = migrationChanges[seq]!;
    final entityId = change['entityId']?.toString() ?? '';
    if (entityId.isEmpty) {
      continue;
    }

    final existingHash = change['stateDataHash']?.toString() ?? '';
    if (existingHash.isNotEmpty) {
      latestHashByEntity[entityId] = existingHash;
      continue;
    }

    if (change['stateChanged'] == false) {
      final carriedHash = latestHashByEntity[entityId] ?? '';
      change['stateDataHash'] = carriedHash;
      if (carriedHash.isNotEmpty) {
        latestHashByEntity[entityId] = carriedHash;
      }
    }
  }

  // Seed migrationStates with source storage states first.
  final sourceStateStats = await sourceStorage.getStateStats(
    domainType: domainType,
    domainId: domainId,
  );
  final sourceEntityTypes = sourceStateStats.entityTypes.keys.toList()..sort();
  for (final entityType in sourceEntityTypes) {
    String? sourceStateCursor;
    while (true) {
      final page = await sourceStorage.getEntityStates(
        domainType: domainType,
        domainId: domainId,
        entityType: entityType,
        cursor: sourceStateCursor,
        limit: pageSize == -1 ? null : pageSize,
      );

      final items = (page['items'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();
      if (items.isEmpty) {
        break;
      }

      for (final item in items) {
        final entityId = item['entityId']?.toString();
        if (entityId == null || entityId.isEmpty) {
          continue;
        }
        final key = '$entityType|$entityId';
        migrationStates[key] = {
          'entityType': entityType,
          'entityId': entityId,
          // computed field starts as source value and may be overwritten by replay
          'stateDataHash': item['stateDataHash']?.toString() ?? '',
          // preserve source/original values for migration diagnostics
          'sourceStateDataHash': item['stateDataHash']?.toString() ?? '',
          'sourceStateDataHash_orig_':
              item['stateDataHash_orig_']?.toString() ?? '',
          'stateDataHash_orig_': item['stateDataHash_orig_']?.toString() ?? '',
        };
      }

      final hasMore = page['hasMore'] as bool? ?? false;
      if (!hasMore) {
        break;
      }
      sourceStateCursor = page['nextCursor'] as String?;
      if (sourceStateCursor == null || sourceStateCursor.isEmpty) {
        break;
      }
    }
  }

  // Merge replay storage state hashes into migrationStates.
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
        final key = '${entityState.entityType}|${entityState.entityId}';
        final existing =
            migrationStates[key] ??
            <String, dynamic>{
              'entityType': entityState.entityType,
              'entityId': entityState.entityId,
              'sourceStateDataHash': '',
              'sourceStateDataHash_orig_': '',
              'stateDataHash_orig_': '',
            };

        // Only overwrite the computed/final hash from replay.
        // Keep source fields captured from Dynamo source state pages.
        existing['stateDataHash'] = entityState.stateDataHash ?? '';
        // Track the replay-computed _orig_ separately from source _orig_.
        existing['stateDataHash_orig_'] = entityState.stateDataHash_orig_ ?? '';
        migrationStates[key] = existing;
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

  // Group changes by entityId.
  final entityToSeqs = <String, List<int>>{};
  for (final seq in allSeqs) {
    final entry = migrationChanges[seq]!;
    final eid = entry['entityId']?.toString() ?? '';
    if (eid.isEmpty) continue;
    entityToSeqs.putIfAbsent(eid, () => <int>[]).add(seq);
  }

  final changesAlreadyMigrated = <Map<String, dynamic>>[];
  final statesAlreadyMigrated = <Map<String, dynamic>>[];
  for (final eid in entityToSeqs.keys) {
    final stateKey = migrationStates.keys.firstWhere(
      (k) => k.endsWith('|$eid'),
      orElse: () => '',
    );
    if (stateKey.isEmpty) {
      continue;
    }

    final state = migrationStates[stateKey]!;
    final sourceStateDataHash = state['sourceStateDataHash']?.toString() ?? '';
    final sourceStateDataHashOrig =
        state['sourceStateDataHash_orig_']?.toString() ?? '';
    final finalStateDataHash = state['stateDataHash']?.toString() ?? '';
    final finalStateDataHashOrig =
        state['stateDataHash_orig_']?.toString() ?? '';

    // Consider an entity already migrated only when source already had a hash
    // and source hash fields match replay-computed final hash fields.
    final sourceHasHash =
        sourceStateDataHash.isNotEmpty || sourceStateDataHashOrig.isNotEmpty;
    final matchesFinal =
        (sourceStateDataHash.isEmpty ||
            sourceStateDataHash == finalStateDataHash) &&
        (sourceStateDataHashOrig.isEmpty ||
            sourceStateDataHashOrig == finalStateDataHashOrig);

    if (!sourceHasHash || !matchesFinal) {
      continue;
    }

    for (final seq in entityToSeqs[eid]!) {
      final c = migrationChanges[seq]!;
      changesAlreadyMigrated.add({
        'seq': seq,
        'entityId': eid,
        'stateDataHash': c['stateDataHash']?.toString() ?? '',
        // record the original source change value for later inspection
        'origStateDataHash':
            migrationOriginalChanges[seq]?['stateDataHash']?.toString() ?? '',
      });
      migrationChanges.remove(seq);
    }

    statesAlreadyMigrated.add(state);
    migrationStates.remove(stateKey);
  }

  // Recompute seq list after removals.
  final remainingSeqs = migrationChanges.keys.toList()..sort();

  // Build last-seen change per entityId for remaining changes.
  final lastSeenByEntity = <String, Map<String, dynamic>>{};
  for (final seq in remainingSeqs) {
    final entry = migrationChanges[seq]!;
    final eid = entry['entityId']?.toString() ?? '';
    if (eid.isEmpty) continue;
    lastSeenByEntity[eid] = {
      'seq': seq,
      'stateDataHash': entry['stateDataHash']?.toString() ?? '',
    };
  }

  final changesSummary = <Map<String, dynamic>>[];
  for (final seq in remainingSeqs) {
    final change = migrationChanges[seq]!;
    final entityId = change['entityId']?.toString() ?? '';
    final stateChanged = change['stateChanged'] == true;
    final isFinal =
        entityId.isNotEmpty && (lastSeenByEntity[entityId]?['seq'] == seq);
    changesSummary.add({
      'seq': seq,
      'stateChanged': stateChanged,
      'entityId': entityId,
      'finalState': isFinal,
      'stateDataHash': change['stateDataHash']?.toString() ?? '',
    });
  }

  final statesSummary = migrationStates.values.toList()
    ..sort((a, b) {
      final ta = a['entityType']?.toString() ?? '';
      final tb = b['entityType']?.toString() ?? '';
      final typeCmp = ta.compareTo(tb);
      if (typeCmp != 0) {
        return typeCmp;
      }
      final ia = a['entityId']?.toString() ?? '';
      final ib = b['entityId']?.toString() ?? '';
      return ia.compareTo(ib);
    });

  // Validate: for each final entity state, ensure the last change for that
  // entity has the same stateDataHash. If not, record an error.
  final errors = <Map<String, dynamic>>[];
  for (final state in statesSummary) {
    final entityId = state['entityId']?.toString() ?? '';
    if (entityId.isEmpty) continue;
    final entityType = state['entityType']?.toString() ?? '';
    final expected = state['stateDataHash']?.toString() ?? '';
    final sourceStateDataHash = state['sourceStateDataHash']?.toString() ?? '';
    final stateDataHashOrig = state['stateDataHash_orig_']?.toString() ?? '';
    final last = lastSeenByEntity[entityId];
    if (last == null) {
      errors.add({
        'message': 'No change found for final entity state',
        'entityType': entityType,
        'entityId': entityId,
        'expectedFinalStateHash': expected,
        'sourceStateDataHash': sourceStateDataHash,
        'stateDataHash_orig_': stateDataHashOrig,
      });
      continue;
    }
    final lastHash = (last['stateDataHash'] as String?) ?? '';
    if (lastHash != expected) {
      errors.add({
        'message': 'stateDataHash mismatch for entity',
        'entityType': entityType,
        'entityId': entityId,
        'expectedFinalStateHash': expected,
        'lastChangeSeq': last['seq'],
        'lastChangeHash': lastHash,
        'sourceStateDataHash': sourceStateDataHash,
        'stateDataHash_orig_': stateDataHashOrig,
      });
    }
  }

  // Warnings: compare source vs final per field.
  // We treat stateDataHash and stateDataHash_orig_ as separate fields.
  // Use raw string comparison so padding-only differences (e.g. trailing '=' )
  // are reported explicitly as warnings.
  final warnings = <Map<String, dynamic>>[];
  void checkStateForWarning(Map<String, dynamic> state, String source) {
    final entityType = state['entityType']?.toString() ?? '';
    final entityId = state['entityId']?.toString() ?? '';
    if (entityId.isEmpty) return;

    final sourceStateDataHash = state['sourceStateDataHash']?.toString() ?? '';
    final finalStateDataHash = state['stateDataHash']?.toString() ?? '';
    final sourceStateDataHashOrig =
        state['sourceStateDataHash_orig_']?.toString() ?? '';
    final finalStateDataHashOrig =
        state['stateDataHash_orig_']?.toString() ?? '';

    if (sourceStateDataHash.isNotEmpty &&
        sourceStateDataHash != finalStateDataHash) {
      warnings.add({
        'message': 'stateDataHash differs from sourceStateDataHash',
        'entityType': entityType,
        'entityId': entityId,
        'source': source,
        'field': 'stateDataHash',
        'sourceField': 'sourceStateDataHash',
        'sourceValue': sourceStateDataHash,
        'finalValue': finalStateDataHash,
      });
    }

    if (sourceStateDataHashOrig.isNotEmpty &&
        sourceStateDataHashOrig != finalStateDataHashOrig) {
      warnings.add({
        'message': 'stateDataHash_orig_ differs from sourceStateDataHash_orig_',
        'entityType': entityType,
        'entityId': entityId,
        'source': source,
        'field': 'stateDataHash_orig_',
        'sourceField': 'sourceStateDataHash_orig_',
        'sourceValue': sourceStateDataHashOrig,
        'finalValue': finalStateDataHashOrig,
      });
    }
  }

  for (final s in statesSummary) {
    checkStateForWarning(s, 'state');
  }
  for (final s in statesAlreadyMigrated) {
    checkStateForWarning(s, 'already_migrated_state');
  }

  return {
    'domainId': domainId,
    'status': 'success',
    'changes': changesSummary,
    'states': statesSummary,
    'errors': errors,
    'warnings': warnings,
    'changesAlreadyMigrated': changesAlreadyMigrated,
    'statesAlreadyMigrated': statesAlreadyMigrated,
  };
}

Future<void> _appendSummaryHeader({
  required String summaryFilePath,
  required String awsProfile,
  required String stage,
  required String domainType,
  required int pageSize,
  required bool includeTestDomainIds,
}) async {
  final file = File(summaryFilePath);
  await file.parent.create(recursive: true);

  final header = StringBuffer()
    ..writeln('# migration_state_data_hash summary')
    ..writeln('# runStartedAt: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('# awsProfile: ${_yamlQuote(awsProfile)}')
    ..writeln('# stage: ${_yamlQuote(stage)}')
    ..writeln('# domainType: ${_yamlQuote(domainType)}')
    ..writeln('# pageSize: $pageSize')
    ..writeln('# includeTestDomainIds: $includeTestDomainIds')
    ..writeln();

  await file.writeAsString(header.toString(), mode: FileMode.append);
}

Future<void> _appendDomainSummary({
  required String summaryFilePath,
  required Map<String, dynamic> summary,
}) async {
  final file = File(summaryFilePath);
  await file.parent.create(recursive: true);

  final changes = (summary['changes'] as List<dynamic>? ?? const <dynamic>[])
      .cast<Map<String, dynamic>>();
  final states = (summary['states'] as List<dynamic>? ?? const <dynamic>[])
      .cast<Map<String, dynamic>>();
  final errors = (summary['errors'] as List<dynamic>? ?? const <dynamic>[])
      .cast<Map<String, dynamic>>();
  final warnings = (summary['warnings'] as List<dynamic>? ?? const <dynamic>[])
      .cast<Map<String, dynamic>>();
  final changesAlreadyMigrated =
      (summary['changesAlreadyMigrated'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();
  final statesAlreadyMigrated =
      (summary['statesAlreadyMigrated'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();

  final out = StringBuffer()
    ..writeln('---')
    ..writeln('domainId: ${_yamlQuote(summary['domainId']?.toString() ?? '')}')
    ..writeln(
      'status: ${_yamlQuote(summary['status']?.toString() ?? 'unknown')}',
    )
    ..writeln('changes:');

  if (changes.isEmpty) {
    out.writeln('  []');
  } else {
    for (final change in changes) {
      final stateChanged = (change['stateChanged'] as bool?) ?? true;
      final mark = stateChanged ? '' : '*';
      out
        ..writeln('  - seq: ${change['seq']}')
        ..writeln('    stateChanged: $stateChanged')
        ..writeln(
          '    entityId: ${_yamlQuote(change['entityId']?.toString() ?? '')}',
        )
        ..writeln(
          '    finalState: ${change['finalState'] == true ? 'true' : 'false'}',
        )
        ..writeln(
          '    stateDataHash: ${_yamlQuote((change['stateDataHash']?.toString() ?? '') + mark)}',
        );
    }
  }

  out.writeln('states:');
  if (states.isEmpty) {
    out.writeln('  []');
  } else {
    for (final state in states) {
      out
        ..writeln(
          '  - entityType: ${_yamlQuote(state['entityType']?.toString() ?? '')}',
        )
        ..writeln(
          '    entityId: ${_yamlQuote(state['entityId']?.toString() ?? '')}',
        )
        ..writeln(
          '    stateDataHash: ${_yamlQuote(state['stateDataHash']?.toString() ?? '')}',
        )
        ..writeln(
          '    sourceStateDataHash: ${_yamlQuote(state['sourceStateDataHash']?.toString() ?? '')}',
        )
        ..writeln(
          '    sourceStateDataHash_orig_: ${_yamlQuote(state['sourceStateDataHash_orig_']?.toString() ?? '')}',
        )
        ..writeln(
          '    stateDataHash_orig_: ${_yamlQuote(state['stateDataHash_orig_']?.toString() ?? '')}',
        );
    }
  }

  if (errors.isNotEmpty) {
    out.writeln('errors:');
    for (final error in errors) {
      out.writeln(
        '  - message: ${_yamlQuote(error['message']?.toString() ?? '')}',
      );

      const preferredOrder = <String>[
        'entityType',
        'entityId',
        'expectedFinalStateHash',
        'lastChangeSeq',
        'lastChangeHash',
        'sourceStateDataHash',
        'stateDataHash_orig_',
        'stackTrace',
      ];

      for (final key in preferredOrder) {
        if (!error.containsKey(key)) {
          continue;
        }
        out.writeln('    $key: ${_yamlQuote(error[key]?.toString() ?? '')}');
      }
    }
  }

  if (warnings.isNotEmpty) {
    out.writeln('warnings:');
    for (final w in warnings) {
      out.writeln('  - message: ${_yamlQuote(w['message']?.toString() ?? '')}');

      const preferredOrder = <String>[
        'entityType',
        'entityId',
        'source',
        'field',
        'sourceField',
        'sourceValue',
        'finalValue',
      ];

      for (final key in preferredOrder) {
        if (!w.containsKey(key)) {
          continue;
        }
        out.writeln('    $key: ${_yamlQuote(w[key]?.toString() ?? '')}');
      }
    }
  }

  if (changesAlreadyMigrated.isNotEmpty) {
    out.writeln('changesAlreadyMigrated:');
    for (final c in changesAlreadyMigrated) {
      out
        ..writeln('  - seq: ${c['seq']}')
        ..writeln(
          '    entityId: ${_yamlQuote(c['entityId']?.toString() ?? '')}',
        )
        ..writeln(
          '    stateDataHash: ${_yamlQuote(c['stateDataHash']?.toString() ?? '')}',
        )
        ..writeln(
          '    origStateDataHash: ${_yamlQuote(c['origStateDataHash']?.toString() ?? '')}',
        );
    }
  }

  if (statesAlreadyMigrated.isNotEmpty) {
    out.writeln('statesAlreadyMigrated:');
    for (final s in statesAlreadyMigrated) {
      out
        ..writeln(
          '  - entityType: ${_yamlQuote(s['entityType']?.toString() ?? '')}',
        )
        ..writeln(
          '    entityId: ${_yamlQuote(s['entityId']?.toString() ?? '')}',
        )
        ..writeln(
          '    stateDataHash: ${_yamlQuote(s['stateDataHash']?.toString() ?? '')}',
        )
        ..writeln(
          '    sourceStateDataHash: ${_yamlQuote(s['sourceStateDataHash']?.toString() ?? '')}',
        )
        ..writeln(
          '    sourceStateDataHash_orig_: ${_yamlQuote(s['sourceStateDataHash_orig_']?.toString() ?? '')}',
        )
        ..writeln(
          '    stateDataHash_orig_: ${_yamlQuote(s['stateDataHash_orig_']?.toString() ?? '')}',
        );
    }
  }

  out.writeln();
  await file.writeAsString(out.toString(), mode: FileMode.append);
}

String _yamlQuote(String value) => "'${value.replaceAll("'", "''")}'";

// Normalization removed: comparisons are padding-sensitive now.

void _printUsage() {
  print('''
Dry-run migration for printing replayed stateDataHash values.

Usage: dart run bin/migrate_state_data_hash.dart [options]

Options:
  --aws-profile <profile>   AWS profile to use (default: sltt-dart-dev)
  --stage <stage>           Deployment stage label for logging (default: dev)
  --domain-type <type>      Domain type to scan (default: project)
  --page-size <count>       Number of source changes per page (default: 100). Use -1 to let the storage/backend decide (no limit).
  --summary-file <path>     Append per-domain YAML summaries to this file (default: migration_state_data_hash_summary.yaml)
  --write-changes           Reserved for future write mode; currently unsupported
  --exit-on-error           Exit immediately when a domain validation error is detected
  --include-test-domainIds  Include domainIds that start with __test (default: false)
  --help                    Show this help message
''');
}
