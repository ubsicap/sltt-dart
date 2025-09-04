import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';

/// Result of processing changes through the change processing service
class ChangeProcessingResult {
  /// resultsSummary fields:
  /// TODO: should we use a serializable ResultsSummary class for typesafety?
  /// - storageType: The type of storage used (e.g., local, remote)
  /// - storageId: The ID of the storage instance
  /// - stateUpdates: A list of state updates applied
  /// - changeUpdates: A list of change updates applied
  /// - created: A list of created entity IDs
  /// - updated: A list of updated entity IDs
  /// - deleted: A list of deleted entity IDs
  /// - noOps: A list of no-op entity IDs
  /// - clouded: A list of clouded entity IDs
  /// - dups: A list of duplicate entity IDs
  /// - unknowns: A list of unknown entity IDs
  /// - info: A list of informational messages
  /// - errors: A list of error messages
  /// - unprocessed: A list of unprocessed entity IDs
  final Map<String, dynamic>? resultsSummary;
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
    required List<Map<String, dynamic>> changesToCreate,
    required BaseStorageService storage,
    required String srcStorageType,
    required String srcStorageId,
    required String storageMode,
    required bool includeChangeUpdates,
    required bool includeStateUpdates,
  }) async {
    try {
      if (changesToCreate.isEmpty) {
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

      // Validate all storageIds before processing any changes
      final invalidStorageIds = <int>[];
      for (int i = 0; i < changesToCreate.length; i++) {
        final changeData = changesToCreate[i];
        try {
          final changeLogEntry = deserializeChangeLogEntryUsingRegistry(
            changeData,
          );

          // Validate storageId based on storageMode
          if (storageMode == 'sync') {
            if (changeLogEntry.storageId.trim().isEmpty) {
              invalidStorageIds.add(i);
            }
          } else if (storageMode == 'save') {
            if (changeLogEntry.storageId.trim().isNotEmpty) {
              invalidStorageIds.add(i);
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

      final targetStorageId = await storage.getStorageId();
      final resultsSummary = <String, dynamic>{
        'storageType': storage.getStorageType(),
        'storageId': targetStorageId,
        'stateUpdates': <Map<String, dynamic>>[],
        'changeUpdates': <Map<String, dynamic>>[],
        'created': <String>[],
        'updated': <String>[],
        'deleted': <String>[],
        'noOps': <String>[],
        'clouded': <String>[], // duplicates from the cloud
        'dups': <String>[],
        'unknowns': <Map<String, dynamic>>[],
        'info': <Map<String, dynamic>>[],
        'errors': <Map<String, dynamic>>[],
        'unprocessed': <String>[], // TODO: changes that couldn't be processed
      };

      // Process all changes
      for (int i = 0; i < changesToCreate.length; i++) {
        final changeData = changesToCreate[i];

        try {
          final changeLogEntry = deserializeChangeLogEntryUsingRegistry(
            changeData,
          );

          // Validate that unknownJson is empty when required
          final unknownValidationResult = _validateUnknownJson(
            changeLogEntry: changeLogEntry,
            storageType: storage.getStorageType(),
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

          // Get current entity state
          final entityState = await storage.getCurrentEntityState(
            changeLogEntry.domainId,
            changeLogEntry.entityType.toString(),
            changeLogEntry.entityId,
          );

          // Use enhanced change detection method
          final result = getUpdatesForChangeLogEntryAndEntityState(
            changeLogEntry,
            entityState,
            storageMode: storageMode,
          );

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
          final outgoingChangeUpdates = <String, dynamic>{
            ...result.changeUpdates,
          };
          if (storageMode == 'save') {
            // In save mode the persisted change should indicate the storage that saved it
            outgoingChangeUpdates['storageId'] = targetStorageId;
          }

          final updateResults = await storage.updateChangeLogAndState(
            changeLogEntry: changeLogEntry,
            changeUpdates: outgoingChangeUpdates,
            entityState: entityState,
            stateUpdates: result.stateUpdates,
          );

          // In sync mode, warn if we get unexpected state changes
          if (storageMode == 'sync' &&
              updateResults.newChangeLogEntry.operation != 'no-op' &&
              !result.isDuplicate &&
              result.stateUpdates.isNotEmpty) {
            print(
              'WARNING: Sync mode resulted in state change for CID ${changeLogEntry.cid}. '
              'Operation: ${updateResults.newChangeLogEntry.operation}. '
              'This may indicate a data inconsistency worth investigating.',
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
          resultsSummary['errors'].add({
            'changeIndex': i,
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
          });
        }
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
  static ChangeProcessingResult? _validateUnknownJson({
    required BaseChangeLogEntry changeLogEntry,
    required String storageType,
    required String storageMode,
    required int changeIndex,
  }) {
    final cid = changeLogEntry.cid;
    final unknownJson = changeLogEntry.getUnknown();

    // Return error if unknownJson is present when storageType is 'cloud' and storageMode is 'save'
    if (storageType == 'cloud' &&
        storageMode == 'save' &&
        unknownJson.isNotEmpty) {
      return ChangeProcessingResult(
        errorMessage:
            'Change[$changeIndex] cid($cid) contains unknown fields in cloud storage with save mode. Unknown fields: $unknownJson',
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
    required Map<String, dynamic> resultsSummary,
    required UpdateChangeLogAndStateResult updateResults,
    required GetUpdateResults result,
    required BaseChangeLogEntry changeLogEntry,
    required bool includeChangeUpdates,
    required bool includeStateUpdates,
  }) {
    final newOperation = updateResults.newChangeLogEntry.operation;

    if (newOperation == 'create') {
      resultsSummary['created'].add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == 'update') {
      resultsSummary['updated'].add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == 'delete') {
      resultsSummary['deleted'].add(updateResults.newChangeLogEntry.cid);
    } else if (newOperation == 'no-op') {
      resultsSummary['noOps'].add(updateResults.newChangeLogEntry.cid);
    } else if (result.isDuplicate) {
      if (result.stateUpdates.isNotEmpty) {
        resultsSummary['clouded'].add(changeLogEntry.cid);
      } else {
        resultsSummary['dups'].add(changeLogEntry.cid);
      }
    } else if (updateResults.newChangeLogEntry.operation == 'error') {
      resultsSummary['errors'].add({
        'cid': updateResults.newChangeLogEntry.cid,
        'info': updateResults.newChangeLogEntry.getOperationInfo(),
      });
    }

    // Add unknown fields if present
    if (updateResults.newChangeLogEntry.getUnknown().isNotEmpty) {
      resultsSummary['unknowns'].add({
        'cid': updateResults.newChangeLogEntry.cid,
        'unknown': updateResults.newChangeLogEntry.getUnknown(),
      });
    }

    // Add operation info if present and not an error
    if (updateResults.newChangeLogEntry.operation != 'error' &&
        updateResults.newChangeLogEntry.getOperationInfo().isNotEmpty) {
      resultsSummary['info'].add({
        'cid': updateResults.newChangeLogEntry.cid,
        'operation': updateResults.newChangeLogEntry.operation,
        'info': updateResults.newChangeLogEntry.getOperationInfo(),
      });
    }

    // Add detailed updates if requested
    if (includeChangeUpdates) {
      resultsSummary['changeUpdates'].add({
        'cid': updateResults.newChangeLogEntry.cid,
        'updates': result.changeUpdates,
      });
    }

    if (includeStateUpdates) {
      resultsSummary['stateUpdates'].add({
        'cid': updateResults.newChangeLogEntry.cid,
        'state': result.stateUpdates,
      });
    }
  }
}
