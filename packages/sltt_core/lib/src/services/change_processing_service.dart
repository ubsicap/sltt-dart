import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';

/// Result of processing changes through the change processing service
class ChangeProcessingResult {
  final ChangeProcessingSummary? resultsSummary;
  final String? errorMessage;
  final int? errorCode;
  final StackTrace? stackTrace;

  const ChangeProcessingResult({
    this.resultsSummary,
    this.errorMessage,
    this.errorCode,
    this.stackTrace,
  });

  bool get isSuccess => errorMessage == null;
  bool get isError => errorMessage != null;
}

/// Service for processing changes with field-level change detection
class ChangeProcessingService {
  /// Validate that storage-related responsibilities for a change and its
  /// entity state are satisfied before persisting.
  ///
  /// - `storage`: the target BaseStorageService implementation
  /// - `change`: the deserialized BaseChangeLogEntry to be written
  /// - `entityState`: optional deserialized BaseEntityState associated with the change
  /// - `skipChangeLogWrite`/`skipStateWrite`: booleans indicating whether writes
  ///   are being skipped (storage implementations may call validation even when
  ///   skipping to ensure callers provided required metadata)
  ///
  /// This function is defensive: it only validates and throws on invariant
  /// violations; it does not mutate `change` or `entityState`.
  static void checkCoreChangeStorageResponsibilities({
    required BaseStorageService storage,
    required BaseChangeLogEntry changeToPut,
    required BaseEntityState entityStateToPut,
    required bool skipChangeLogWrite,
    required bool skipStateWrite,
  }) {
    if (skipChangeLogWrite && skipStateWrite) {
      // If both writes are skipped, there's nothing to validate
      return;
    }
    if (changeToPut.storageId.trim().isEmpty && !skipChangeLogWrite) {
      throw ArgumentError('storage received empty storageId on change');
    }
    if (!skipChangeLogWrite) {
      if (changeToPut.storedAt == null) {
        throw ArgumentError('storage requires storedAt to be set on change');
      }
      if (storage.getStorageType() == 'cloud' && changeToPut.cloudAt == null) {
        throw ArgumentError(
          'cloud storage requires cloudAt to be set on change',
        );
      }
    }

    if (!skipStateWrite) {
      // If entityState includes change-side timestamps, validate they match
      // or are present as expected (do not mutate).
      if (!skipChangeLogWrite &&
          entityStateToPut.change_storedAt != changeToPut.storedAt) {
        throw ArgumentError(
          'entityState.change_storedAt (${entityStateToPut.change_storedAt}) does not match change.storedAt (${changeToPut.storedAt})',
        );
      }
      if (storage.getStorageType() == 'cloud' &&
          !skipChangeLogWrite &&
          changeToPut.cloudAt == null) {
        throw ArgumentError(
          'cloud storage requires change.cloudAt to be set when writing state',
        );
      }
      // see if incoming change.cloudAt matches any of the entityState cloudAt's
      // in other words, entityState.cloudAt may or may not match change.cloudAt
      // depending on which field(s) actually got merged, but at least one of them
      // should match the incoming change.cloudAt
      final entityStateKvs = entityStateToPut.toJson();
      final entityStateCloudAts = <String, dynamic>{};
      entityStateKvs.forEach((key, value) {
        if (key.endsWith('_cloudAt') ||
            key.endsWith('_cloudAt_') && value is String) {
          entityStateCloudAts[key] = value;
        }
      });
      if (changeToPut.cloudAt != null &&
          !entityStateCloudAts.values.contains(
            changeToPut.cloudAt!.toIso8601String(),
          )) {
        throw ArgumentError(
          'entityState does not contain any cloudAt matching change.cloudAt (${changeToPut.cloudAt!.toIso8601String()}). Got: $entityStateCloudAts',
        );
      }
    }
  }

  /// 380KB (~400KB) Maximum payload size for DynamoDB/APIGateway (in bytes)
  static const int dynamodbPayloadLimit = 380000;

  /// Store a list of changes and return a summary of results
  static Future<ChangeProcessingResult> storeChanges({
    /// `save` or `sync`
    required String storageMode,

    /// If true, return an error if there are any errors in resultsSummary
    bool returnErrorIfInResultsSummary = true,

    /// changes to `save` or `sync`
    required List<Map<String, dynamic>> changes,

    /// `local` or `cloud`
    required String srcStorageType,
    required String srcStorageId,

    /// destination storage service
    required BaseStorageService storage,

    /// include detailed change updates in the response
    required bool includeChangeUpdates,

    /// include detailed state updates in the response
    required bool includeStateUpdates,
  }) async {
    final storageType = storage.getStorageType();
    SlttLogger.logger.info(
      '[ChangeProcessingService] Starting storeChanges with storageType=$storageType, storageMode=$storageMode, srcStorageType=$srcStorageType, srcStorageId=$srcStorageId, changesCount=${changes.length}, includeChangeUpdates=$includeChangeUpdates, includeStateUpdates=$includeStateUpdates',
    );
    try {
      if (changes.isEmpty) {
        return const ChangeProcessingResult(
          errorMessage: 'No changes provided',
          errorCode: 400,
        );
      }

      // Validate srcStorageType and srcStorageId: we no longer support 'none'.
      if (!(srcStorageType == 'local' || srcStorageType == 'cloud')) {
        return ChangeProcessingResult(
          errorMessage:
              'Invalid srcStorageType: $srcStorageType. Expected "local" or "cloud".',
          errorCode: 400,
        );
      }

      if (srcStorageId.trim().isEmpty) {
        return const ChangeProcessingResult(
          errorMessage: 'srcStorageId is required and must be non-empty',
          errorCode: 400,
        );
      }

      // Validate storageMode
      if (!(storageMode == 'save' || storageMode == 'sync')) {
        return ChangeProcessingResult(
          errorMessage:
              'Invalid storageMode: $storageMode. Expected "save" or "sync".',
          errorCode: 400,
        );
      }

      // Validate all changes before processing any changes
      final preValidationResult = await _preValidateChanges(
        changes: changes,
        storageMode: storageMode,
        srcStorageType: srcStorageType,
      );

      if (preValidationResult != null) {
        return preValidationResult;
      }

      final targetStorageType = storage.getStorageType();
      final targetStorageId = await storage.getStorageId();
      final resultsSummary = ChangeProcessingSummary(
        storageType: targetStorageType,
        storageId: targetStorageId,
        stateUpdates: [],
        changeUpdates: [],
        created: [],
        updated: [],
        pUpdated: [],
        deleted: [],
        outdated: [],
        noOps: [],
        clouded: [], // duplicates from the cloud
        dups: [],
        unknowns: [],
        info: [],
        errors: [],
        unprocessed: [], // TODO: changes that couldn't be processed
      );

      // Phase 1: Collect all change requests with their associated metadata
      final requests = <ChangeLogAndStateRequest>[];
      final requestMetadata =
          <
            ({
              int changeIndex,
              BaseChangeLogEntry changeLogEntry,
              BaseEntityState? entityState,
              GetUpdateResults result,
            })
          >[];

      for (int i = 0; i < changes.length; i++) {
        final changeData = changes[i];

        try {
          final changeLogEntry = deserializeChangeLogEntryUsingRegistry(
            changeData,
          );

          SlttLogger.logger.fine(
            '[${storage.getStorageType()}] DEBUG: Deserialized changeLogEntry: cid=${changeLogEntry.cid}, unknownJson=${changeLogEntry.getUnknown()}',
          );

          // Validate that unknownJson is empty when required
          final unknownValidationResult = validateUnknownJson(
            changeLogEntry: changeLogEntry,
            storageType: targetStorageType,
            storageMode: storageMode,
            changeIndex: i,
          );

          if (unknownValidationResult != null) {
            return unknownValidationResult;
          }

          // Basic validation of operation states based on storage mode
          final validationResult = _validateChangeOperation(
            changeLogEntry: changeLogEntry,
            storageMode: storageMode,
            changeIndex: i,
          );

          if (validationResult != null) {
            return validationResult;
          }
          // validate that domainId and entityId match if their types match
          if (changeLogEntry.domainType != 'unknown' &&
              changeLogEntry.domainType == changeLogEntry.entityType) {
            if (changeLogEntry.domainId != changeLogEntry.entityId) {
              return ChangeProcessingResult(
                errorMessage:
                    'Domain (${changeLogEntry.domainType}) ID (${changeLogEntry.domainId}) and Entity (${changeLogEntry.entityType}) ID (${changeLogEntry.entityId}) must match for ${changeLogEntry.cid}',
                errorCode: 400,
              );
            }
          }

          // Get current entity state
          final entityState = await storage.getEntityState(
            domainType: changeLogEntry.domainType,
            domainId: changeLogEntry.domainId,
            entityType: changeLogEntry.entityType.toString(),
            entityId: changeLogEntry.entityId,
          );

          // Debug: log the current entity state for diagnosis
          try {
            SlttLogger.logger.fine(
              '[${storage.getStorageType()}] DEBUG: entityState for CID ${changeLogEntry.cid}: ${entityState?.toJson()}',
            );
          } catch (e, st) {
            // Log failure to serialize entity state for debug purposes
            SlttLogger.logger.fine(
              '[${storage.getStorageType()}] DEBUG: failed to serialize entityState for CID ${changeLogEntry.cid}: $e',
            );
            SlttLogger.logger.fine(st.toString());
          }

          // Use enhanced change detection method
          final result = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            entityState,
            storageMode: storageMode,
            storageType: targetStorageType,
            targetStorageId: targetStorageId,
          );

          // Debug: log detailed result info
          try {
            SlttLogger.logger.fine(
              '[${storage.getStorageType()}] DEBUG: getUpdates result for CID ${changeLogEntry.cid}: isDuplicate=${result.isDuplicate} changeUpdates=${result.changeUpdates} stateUpdates=${result.stateUpdates}',
            );
          } catch (e, st) {
            // Log debug printing failures
            SlttLogger.logger.fine(
              '[${storage.getStorageType()}] DEBUG: failed to print getUpdates result for CID ${changeLogEntry.cid}: $e',
            );
            SlttLogger.logger.fine(st.toString());
          }

          // Check payload size limits for save operations (sync operations preserve data)
          final payloadCheckResult = _checkPayloadLimits(
            storageMode: storageMode,
            changeLogEntry: changeLogEntry,
            entityState: entityState,
            stateUpdates: result.stateUpdates,
            changeIndex: i,
          );

          if (payloadCheckResult != null) {
            return payloadCheckResult;
          }

          // Debug: log computed stateUpdates for diagnosis
          SlttLogger.logger.fine(
            '[${storage.getStorageType()}] DEBUG: computed stateUpdates for CID ${changeLogEntry.cid}: ${result.stateUpdates}',
          );

          // Ensure changeUpdates reflect the storage's identity in save mode
          final changeUpdates = <String, dynamic>{...result.changeUpdates};

          final shouldSkipChangeLogWrite =
              result.isDuplicate ||
              changeUpdates.isEmpty ||
              targetStorageType == 'local' &&
                  storageMode ==
                      'sync' /* for now, don't store incoming sync changes in the local change log */ ||
              (targetStorageId ==
                  changeLogEntry.storageId /* should already be saved */ );
          final operationCounts = result.operationCounts;

          final request = ChangeLogAndStateRequest(
            changeLogEntry: changeLogEntry,
            changeUpdates: changeUpdates,
            entityState: entityState,
            stateUpdates: result.stateUpdates,
            operationCounts: operationCounts,
            skipChangeLogWrite: shouldSkipChangeLogWrite,
            skipStateWrite: result.stateUpdates.isEmpty,
          );

          requests.add(request);
          requestMetadata.add((
            changeIndex: i,
            changeLogEntry: changeLogEntry,
            entityState: entityState,
            result: result,
          ));
        } catch (e, stackTrace) {
          // Handle individual change processing errors
          resultsSummary.errors.add({
            'changeIndex': i,
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
          });
        }
      }

      // Phase 2: Process all requests as a batch (if any valid requests collected)
      if (requests.isNotEmpty) {
        // Pre-validation enforces a single domainType for the whole batch,
        // so process all requests together as a single batch. Use the
        // first request's domainType as the batch domainType.
        final domainType = requests.first.changeLogEntry.domainType;

        final batchResults = await storage.updateChangeLogAndStates(
          domainType: domainType,
          requests: requests,
        );

        // Phase 3: Categorize results for each request in the batch
        for (int i = 0; i < requests.length; i++) {
          final metadata = requestMetadata[i];
          final updateResults = (
            newChangeLogEntry: batchResults.newChangeLogEntries[i],
            newEntityState: batchResults.newEntityStates[i],
          );

          // In sync mode, warn if we get unexpected state changes
          if (storageMode == 'sync' &&
              targetStorageId == metadata.changeLogEntry.storageId &&
              updateResults.newChangeLogEntry.operation !=
                  kChangeOperationNoOp &&
              !metadata.result.isDuplicate &&
              metadata.result.stateUpdates.isNotEmpty) {
            SlttLogger.logger.warning(
              '[${storage.getStorageType()}] WARNING: Sync mode resulted in state change for CID ${metadata.changeLogEntry.cid}. '
              'Operation: ${updateResults.newChangeLogEntry.operation}. '
              'This may indicate a data inconsistency worth investigating.'
              'ChangeLogEntry: ${metadata.changeLogEntry}'
              'Previous state: ${metadata.entityState}'
              'New state: ${updateResults.newEntityState}.'
              'State updates: ${metadata.result.stateUpdates}',
            );
          }

          // Categorize the result
          categorizeChangeResult(
            resultsSummary: resultsSummary,
            updateResults: updateResults,
            result: metadata.result,
            changeLogEntry: metadata.changeLogEntry,
            includeChangeUpdates: includeChangeUpdates,
            includeStateUpdates: includeStateUpdates,
          );
        }
      }

      if (returnErrorIfInResultsSummary && resultsSummary.errors.isNotEmpty) {
        final errorMessage =
            'One or more changes resulted in errors. See resultsSummary for details:\n$resultsSummary';
        SlttLogger.logger.warning(
          '[${storage.getStorageType()}] $errorMessage: $resultsSummary',
        );
        return ChangeProcessingResult(
          errorMessage: errorMessage,
          errorCode: 400, // consider using 207 Multi-Status in future?
          resultsSummary: resultsSummary,
        );
      }

      return ChangeProcessingResult(resultsSummary: resultsSummary);
    } catch (e, stackTrace) {
      return ChangeProcessingResult(
        errorMessage: 'Failed to process changes: ${e.toString()}',
        errorCode: 500,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validate that unknownJson is empty when required
  static ChangeProcessingResult? validateUnknownJson({
    required BaseChangeLogEntry changeLogEntry,
    required String storageType,
    required String storageMode,
    required int changeIndex,
  }) {
    final cid = changeLogEntry.cid;
    final unknownJson = changeLogEntry.unknownJson;

    SlttLogger.logger.fine(
      'DEBUG: validateUnknownJson - storageType=$storageType, storageMode=$storageMode, unknownJson=$unknownJson, cid=$cid',
    );

    // Return error if unknownJson is present when storageMode is 'save'
    if (storageMode == 'save' && unknownJson != '{}') {
      final knownFields = changeLogEntry
          .toJsonBase()
          .entries
          .map((e) => e.key)
          .toSet();
      return ChangeProcessingResult(
        errorMessage:
            'Change[$changeIndex] cid($cid) contains unknown fields in ($storageType) storage with save mode.\nUnknown fields: $unknownJson \nKnown fields: [$knownFields]',
        errorCode: 400,
      );
    }

    return null; // No validation error
  }

  /// Validate change operation states
  static ChangeProcessingResult? _validateChangeOperation({
    required BaseChangeLogEntry changeLogEntry,
    required String storageMode,
    required int changeIndex,
  }) {
    final cid = changeLogEntry.cid;

    // Basic validation of operation states based on storage mode
    if (storageMode == 'save') {
      // In save mode, treat changes as atomic since they're new data
      // so exit early on any errors
      if (changeLogEntry.operation == 'error') {
        return ChangeProcessingResult(
          errorMessage:
              'Change[$changeIndex] cid($cid) deserialization encountered error: ${changeLogEntry.getOperationInfo()}',
          errorCode: 400,
        );
      }
      if (changeLogEntry.operation == 'hold') {
        return ChangeProcessingResult(
          errorMessage:
              'Change[$changeIndex] cid($cid) deserialization resulted in `hold`: ${changeLogEntry.getOperationInfo()}',
          errorCode: 400,
        );
      }
    } else if (storageMode == 'sync') {
      // In sync mode, treat these as a batch from a remote storage.
      // For now, just log but don't fail - these will be handled individually
      if (changeLogEntry.operation == 'error') {}
      if (changeLogEntry.operation == 'hold') {}
    }

    return null; // No validation error
  }

  /// Check payload size limits for DynamoDB compatibility
  static ChangeProcessingResult? _checkPayloadLimits({
    required String storageMode,
    required BaseChangeLogEntry changeLogEntry,
    required BaseEntityState? entityState,
    required Map<String, dynamic> stateUpdates,
    required int changeIndex,
  }) {
    final cid = changeLogEntry.cid;

    // Return error if in save mode and total state update payload is greater than dynamodb payload limits
    if (storageMode == 'save') {
      final mergedState = {
        if (entityState != null) ...entityState.toJson(),
        ...stateUpdates,
      };
      final entityStateRecordSize = utf8
          .encode(jsonEncode(mergedState))
          .lengthInBytes;
      if (entityStateRecordSize > dynamodbPayloadLimit) {
        return ChangeProcessingResult(
          errorMessage:
              'Change[$changeIndex] cid($cid) exceeds payload limits ($dynamodbPayloadLimit bytes)',
          errorCode: 400,
        );
      }
    }
    // In sync mode, we preserve data as-is, so payload limits are less critical

    return null; // No payload limit error
  }

  /// Categorize the change result into appropriate response buckets
  static void categorizeChangeResult({
    required ChangeProcessingSummary resultsSummary,
    required UpdateChangeLogAndStateResult updateResults,
    required GetUpdateResults result,
    required BaseChangeLogEntry changeLogEntry,
    required bool includeChangeUpdates,
    required bool includeStateUpdates,
  }) {
    final newOperation = updateResults.newChangeLogEntry.operation;

    if (newOperation == kChangeOperationCreate) {
      resultsSummary.created.add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == kChangeOperationUpdate) {
      resultsSummary.updated.add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == kChangeOperationPartialUpdate) {
      resultsSummary.updated.add(updateResults.newChangeLogEntry.cid);
      resultsSummary.pUpdated.add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == kChangeOperationDelete) {
      resultsSummary.deleted.add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == kChangeOperationOutdated) {
      resultsSummary.outdated.add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == kChangeOperationNoOp) {
      resultsSummary.noOps.add(updateResults.newChangeLogEntry.cid);
    } else if (result.isDuplicate) {
      if (result.stateUpdates.isNotEmpty) {
        resultsSummary.clouded.add(changeLogEntry.cid);
      } else {
        resultsSummary.dups.add(changeLogEntry.cid);
      }
    } else if (updateResults.newChangeLogEntry.operation ==
        kChangeOperationError) {
      resultsSummary.errors.add({
        'cid': updateResults.newChangeLogEntry.cid,
        'info': updateResults.newChangeLogEntry.getOperationInfo(),
      });
    }

    // Add unknown fields if present
    if (updateResults.newChangeLogEntry.getUnknown().isNotEmpty) {
      resultsSummary.unknowns.add({
        'cid': updateResults.newChangeLogEntry.cid,
        'unknown': updateResults.newChangeLogEntry.getUnknown(),
      });
    }

    // Add operation info if present and not an error
    if (updateResults.newChangeLogEntry.operation != kChangeOperationError &&
        updateResults.newChangeLogEntry.getOperationInfo().isNotEmpty) {
      resultsSummary.info.add({
        'cid': updateResults.newChangeLogEntry.cid,
        'operation': updateResults.newChangeLogEntry.operation,
        'info': updateResults.newChangeLogEntry.getOperationInfo(),
      });
    }

    // Add detailed updates if requested
    if (includeChangeUpdates) {
      resultsSummary.changeUpdates.add({
        'cid': updateResults.newChangeLogEntry.cid,
        'updates': result.changeUpdates,
      });
    }

    if (includeStateUpdates) {
      resultsSummary.stateUpdates.add({
        'cid': updateResults.newChangeLogEntry.cid,
        'state': result.stateUpdates,
      });
    }

    // Debugging aid: log when tests produce unexpected empty updates
    try {
      SlttLogger.logger.fine(
        'DEBUG: _categorizeChangeResult includeChangeUpdates=$includeChangeUpdates includeStateUpdates=$includeStateUpdates cid=${updateResults.newChangeLogEntry.cid} changeUpdatesPresent=${result.changeUpdates.isNotEmpty} stateUpdatesPresent=${result.stateUpdates.isNotEmpty}',
      );
    } catch (e, st) {
      // Log failures of debug logging to avoid silent ignores
      SlttLogger.logger.warning(
        'DEBUG: _categorizeChangeResult debug print failed: $e',
      );
      SlttLogger.logger.warning(st.toString());
    }
  }

  /// Pre-validate all changes before processing
  /// Returns a ChangeProcessingResult with error details if validation fails, null otherwise
  static Future<ChangeProcessingResult?> _preValidateChanges({
    required List<Map<String, dynamic>> changes,
    required String storageMode,
    required String srcStorageType,
  }) async {
    final invalidStorageIds = <int>[];
    final List<int> invalidStateChanged = [];
    final List<int> invalidSeqProvided = [];
    final List<int> invalidCloudAt = [];
    // Track the set of domainTypes found in the incoming batch so we can
    // enforce that all changes in a single call to storeChanges share the
    // same domainType (simplifies batch storage implementations).
    final domainTypes = <String>{};
    for (int i = 0; i < changes.length; i++) {
      final changeData = changes[i];
      try {
        final changeLogEntry = deserializeChangeLogEntryUsingRegistry(
          changeData,
        );
        if (changeLogEntry.operation == kChangeOperationError) {
          // If deserialization failed, don't treat this as a fatal programming
          // error here. Allow the main processing loop to handle the entry so
          // that per-change errors are collected into the resultsSummary.
          // This ensures sync-mode requests can return 200 with errors in the
          // summary (returnErrorIfInResultsSummary=false) instead of a
          // top-level HTTP 400.
          continue;
        }

        // Record domainType for later batch-level validation. We only collect
        // domainTypes for successfully-deserialized entries (i.e. not
        // kChangeOperationError) so that partial deserialization failures do
        // not prevent the domainType check from running on the valid entries.
        domainTypes.add(changeLogEntry.domainType);

        // Validate other storageMode issues
        if (storageMode == 'sync') {
          if (srcStorageType == 'cloud' && changeLogEntry.cloudAt == null) {
            invalidCloudAt.add(i);
          }
          if (changeLogEntry.storageId.trim().isEmpty) {
            invalidStorageIds.add(i);
          }
          if (changeLogEntry.stateChanged == false) {
            invalidStateChanged.add(i);
          }
          if (changeLogEntry.seq <= 0) {
            // syncing assumes seq has already been provided
            invalidSeqProvided.add(i);
          }
        } else if (storageMode == 'save') {
          // validateChangeLogEntryDataJson may be async (test validators),
          // so await it to ensure exceptions are caught by the surrounding
          // try/catch and reported in the resultsSummary rather than
          // bubbling as an unhandled exception.
          await validateChangeLogEntryDataJson(changeLogEntry);
          if (changeLogEntry.cloudAt != null) {
            invalidCloudAt.add(i);
          }
          if (changeLogEntry.storageId.trim().isNotEmpty) {
            invalidStorageIds.add(i);
          }
          if (changeLogEntry.stateChanged == true) {
            invalidStateChanged.add(i);
          }
          // Reject positive caller-provided seq values in save mode: callers must not
          // supply a positive seq when asking the server to 'save' a change. The
          // storage is responsible for assigning its own auto-increment seq.
          if (changeLogEntry.seq > 0) {
            invalidSeqProvided.add(i);
          }
        }
      } catch (e) {
        // If we can't deserialize, we'll catch this in the main loop
        continue;
      }
    }

    if (invalidStorageIds.isNotEmpty) {
      final expectedState = storageMode == 'sync' ? 'non-empty' : 'empty';
      return ChangeProcessingResult(
        errorMessage:
            'Changes [${invalidStorageIds.join(', ')}] in $storageMode mode must have $expectedState storageId',
        errorCode: 400,
      );
    }
    if (invalidStateChanged.isNotEmpty) {
      final expectedState = storageMode == 'sync' ? 'true' : 'false or omitted';
      return ChangeProcessingResult(
        errorMessage:
            'Changes [${invalidStateChanged.join(', ')}] in $storageMode mode must have stateChanged=$expectedState',
        errorCode: 400,
      );
    }
    if (invalidSeqProvided.isNotEmpty) {
      if (storageMode == 'sync') {
        return ChangeProcessingResult(
          errorMessage:
              'Changes [${invalidSeqProvided.join(', ')}] in sync mode must include a valid positive seq',
          errorCode: 400,
        );
      }
      if (storageMode == 'save') {
        return ChangeProcessingResult(
          errorMessage:
              'Changes [${invalidSeqProvided.join(', ')}] in save mode must not include a caller-provided seq:',
          errorCode: 400,
        );
      }
    }

    // Enforce that all successfully-deserialized changes in this batch share
    // the same domainType. This simplifies batch storage implementations
    // which expect a single domainType per batch.
    if (domainTypes.length > 1) {
      return ChangeProcessingResult(
        errorMessage:
            'All changes in a single request to storeChanges must have the same domainType. Found domainTypes: ${domainTypes.join(', ')}',
        errorCode: 400,
      );
    }

    return null; // No validation errors
  }
}
