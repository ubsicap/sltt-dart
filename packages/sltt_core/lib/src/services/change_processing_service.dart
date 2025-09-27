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
  /// 380KB (~400KB) Maximum payload size for DynamoDB/APIGateway (in bytes)
  static const int dynamodbPayloadLimit = 380000;

  /// Process a list of changes and return a summary of results
  static Future<ChangeProcessingResult> processChanges({
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
      final invalidStorageIds = <int>[];
      final List<int> invalidOperations = [];
      final List<int> invalidStateChanged = [];
      final List<int> invalidSeqProvided = [];
      for (int i = 0; i < changes.length; i++) {
        final changeData = changes[i];
        try {
          final operation = changeData['operation'];
          final validIncomingSaveOperations = [
            '',
            'create',
            'update',
            'delete',
          ];
          final validIncomingSyncOperations = [
            'create',
            'update',
            'delete',
            'no-op',
          ];
          if (storageMode == 'save' &&
              !validIncomingSaveOperations.contains(operation)) {
            invalidOperations.add(i);
            continue;
          }
          if (storageMode == 'sync' &&
              !validIncomingSyncOperations.contains(operation)) {
            invalidOperations.add(i);
            continue;
          }
          final changeLogEntry = deserializeChangeLogEntryUsingRegistry(
            changeData,
          );
          if (changeLogEntry.operation == 'error') {
            // If deserialization failed, right now we'll
            // treat this as a programming error that should be fixed
            return ChangeProcessingResult(
              errorMessage:
                  'Change[$i] cid(${changeLogEntry.cid}) deserialization encountered error: ${const JsonEncoder.withIndent('  ').convert(changeLogEntry.getOperationInfo())}',
              errorCode: 400,
            );
          }

          // Validate storageId based on storageMode
          if (storageMode == 'sync') {
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
            validateChangeLogEntryDataJson(changeLogEntry);
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
      if (invalidOperations.isNotEmpty) {
        return ChangeProcessingResult(
          errorMessage:
              'Changes [${invalidOperations.join(', ')}] have invalid operations for $storageMode mode',
          errorCode: 400,
        );
      }
      if (invalidStateChanged.isNotEmpty) {
        final expectedState = storageMode == 'sync'
            ? 'true'
            : 'false or omitted';
        return ChangeProcessingResult(
          errorMessage:
              'Changes [${invalidStateChanged.join(', ')}] in $storageMode mode must have stateChanged=$expectedState',
          errorCode: 400,
        );
      }
      if (invalidSeqProvided.isNotEmpty) {
        return ChangeProcessingResult(
          errorMessage:
              'Changes [${invalidSeqProvided.join(', ')}] in save mode must not include a caller-provided seq',
          errorCode: 400,
        );
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
        deleted: [],
        noOps: [],
        clouded: [], // duplicates from the cloud
        dups: [],
        unknowns: [],
        info: [],
        errors: [],
        unprocessed: [], // TODO: changes that couldn't be processed
      );

      // Process all changes
      for (int i = 0; i < changes.length; i++) {
        final changeData = changes[i];

        try {
          final changeLogEntry = deserializeChangeLogEntryUsingRegistry(
            changeData,
          );

          print(
            'DEBUG: Deserialized changeLogEntry: cid=${changeLogEntry.cid}, unknownJson=${changeLogEntry.getUnknown()}',
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
          if (changeLogEntry.domainType == changeLogEntry.entityType) {
            if (changeLogEntry.domainId != changeLogEntry.entityId) {
              return ChangeProcessingResult(
                errorMessage:
                    'Domain (${changeLogEntry.domainType}) ID (${changeLogEntry.domainId}) and Entity (${changeLogEntry.entityType}) ID (${changeLogEntry.entityId}) must match for ${changeLogEntry.cid}',
                errorCode: 400,
              );
            }
          }

          // Get current entity state
          final entityState = await storage.getCurrentEntityState(
            domainType: changeLogEntry.domainType,
            domainId: changeLogEntry.domainId,
            entityType: changeLogEntry.entityType.toString(),
            entityId: changeLogEntry.entityId,
          );

          // Debug: log the current entity state for diagnosis
          try {
            print(
              'DEBUG: entityState for CID ${changeLogEntry.cid}: ${entityState?.toJson()}',
            );
          } catch (e, st) {
            // Log failure to serialize entity state for debug purposes
            print(
              'DEBUG: failed to serialize entityState for CID ${changeLogEntry.cid}: $e',
            );
            print(st);
          }

          // Use enhanced change detection method
          final result = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            entityState,
            storageMode: storageMode,
          );

          // Debug: log detailed result info
          try {
            print(
              'DEBUG: getUpdates result for CID ${changeLogEntry.cid}: isDuplicate=${result.isDuplicate} changeUpdates=${result.changeUpdates} stateUpdates=${result.stateUpdates}',
            );
          } catch (e, st) {
            // Log debug printing failures
            print(
              'DEBUG: failed to print getUpdates result for CID ${changeLogEntry.cid}: $e',
            );
            print(st);
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

          // Update storage with the change and state
          // Debug: log computed stateUpdates for diagnosis
          print(
            'DEBUG: computed stateUpdates for CID ${changeLogEntry.cid}: ${result.stateUpdates}',
          );

          // Ensure changeUpdates reflect the storage's identity in save mode
          final changeUpdates = <String, dynamic>{...result.changeUpdates};
          if (storageMode == 'save') {
            // In save mode the persisted change should indicate the storage that saved it
            changeUpdates['storageId'] = targetStorageId;
          }

          final updateResults = await storage.updateChangeLogAndState(
            domainType: changeLogEntry.domainType,
            changeLogEntry: changeLogEntry,
            changeUpdates: changeUpdates,
            entityState: entityState,
            stateUpdates: result.stateUpdates,
          );

          // In sync mode, warn if we get unexpected state changes
          if (storageMode == 'sync' &&
              targetStorageId == changeLogEntry.storageId &&
              updateResults.newChangeLogEntry.operation != 'no-op' &&
              !result.isDuplicate &&
              result.stateUpdates.isNotEmpty) {
            print(
              'WARNING: Sync mode resulted in state change for CID ${changeLogEntry.cid}. '
              'Operation: ${updateResults.newChangeLogEntry.operation}. '
              'This may indicate a data inconsistency worth investigating.'
              'ChangeLogEntry: $changeLogEntry'
              'Previous state: $entityState'
              'New state: ${updateResults.newEntityState}.'
              'State updates: ${result.stateUpdates}',
            );
          }

          // Categorize the result
          _categorizeChangeResult(
            resultsSummary: resultsSummary,
            updateResults: updateResults,
            result: result,
            changeLogEntry: changeLogEntry,
            includeChangeUpdates: includeChangeUpdates,
            includeStateUpdates: includeStateUpdates,
          );
        } catch (e, stackTrace) {
          // Handle individual change processing errors
          resultsSummary.errors.add({
            'changeIndex': i,
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
          });
        }
      }

      if (returnErrorIfInResultsSummary && resultsSummary.errors.isNotEmpty) {
        return ChangeProcessingResult(
          errorMessage:
              'One or more changes resulted in errors. See resultsSummary for details:\n$resultsSummary',
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

    print(
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
  static void _categorizeChangeResult({
    required ChangeProcessingSummary resultsSummary,
    required UpdateChangeLogAndStateResult updateResults,
    required GetUpdateResults result,
    required BaseChangeLogEntry changeLogEntry,
    required bool includeChangeUpdates,
    required bool includeStateUpdates,
  }) {
    final newOperation = updateResults.newChangeLogEntry.operation;

    if (newOperation == 'create') {
      resultsSummary.created.add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == 'update') {
      resultsSummary.updated.add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == 'delete') {
      resultsSummary.deleted.add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == 'no-op') {
      resultsSummary.noOps.add(updateResults.newChangeLogEntry.cid);
    } else if (result.isDuplicate) {
      if (result.stateUpdates.isNotEmpty) {
        resultsSummary.clouded.add(changeLogEntry.cid);
      } else {
        resultsSummary.dups.add(changeLogEntry.cid);
      }
    } else if (updateResults.newChangeLogEntry.operation == 'error') {
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
    if (updateResults.newChangeLogEntry.operation != 'error' &&
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
      print(
        'DEBUG: _categorizeChangeResult includeChangeUpdates=$includeChangeUpdates includeStateUpdates=$includeStateUpdates cid=${updateResults.newChangeLogEntry.cid} changeUpdatesPresent=${result.changeUpdates.isNotEmpty} stateUpdatesPresent=${result.stateUpdates.isNotEmpty}',
      );
    } catch (e, st) {
      // Log failures of debug logging to avoid silent ignores
      print('DEBUG: _categorizeChangeResult debug print failed: $e');
      print(st);
    }
  }
}
