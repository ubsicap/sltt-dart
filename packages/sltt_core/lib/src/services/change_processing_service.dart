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

          // Determine effective source storage id per request wrapper rules
          final effectiveSrcStorageId = _determineEffectiveSourceStorageId(
            srcStorageType: srcStorageType,
            srcStorageId: srcStorageId,
            changeLogEntry: changeLogEntry,
            targetStorageId: targetStorageId,
          );

          // Override deserialized storageId so downstream logic uses our chosen mode
          try {
            changeLogEntry.storageId = effectiveSrcStorageId;
          } catch (_) {
            // ignore if not writable
          }

          // Basic validation of operation states when originating from same storage
          final validationResult = _validateChangeOperation(
            changeLogEntry: changeLogEntry,
            targetStorageId: targetStorageId,
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
            targetStorageId: targetStorageId,
          );

          // Check payload size limits for same-storage operations
          final payloadCheckResult = _checkPayloadLimits(
            targetStorageId: targetStorageId,
            changeLogEntry: changeLogEntry,
            entityState: entityState,
            stateUpdates: result.stateUpdates,
            changeIndex: i,
          );

          if (payloadCheckResult != null) {
            return payloadCheckResult;
          }

          // Update storage with the change and state
          final updateResults = await storage.updateChangeLogAndState(
            changeLogEntry: changeLogEntry,
            changeUpdates: result.changeUpdates,
            entityState: entityState,
            stateUpdates: result.stateUpdates,
          );

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

  /// Determine the effective source storage ID based on request parameters
  static String _determineEffectiveSourceStorageId({
    required String srcStorageType,
    required String srcStorageId,
    required BaseChangeLogEntry changeLogEntry,
    required String targetStorageId,
  }) {
    // We expect srcStorageType to be either 'local' or 'cloud' and
    // srcStorageId to be non-empty (validated by caller). Prefer the
    // provided srcStorageId; fall back to the change entry's storageId only
    // in the unlikely case it's different.
    return srcStorageId.isNotEmpty ? srcStorageId : changeLogEntry.storageId;
  }

  /// Validate change operation states
  static ChangeProcessingResult? _validateChangeOperation({
    required BaseChangeLogEntry changeLogEntry,
    required String targetStorageId,
    required int changeIndex,
  }) {
    final cid = changeLogEntry.cid;

    // Basic validation of operation states when originating from same storage
    if (changeLogEntry.storageId == targetStorageId) {
      // treat these changes as atomic since they originated on the same system
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
    } else {
      // treat these as a batch from a remote or LAN storage.
      // For now, just log but don't fail - these will be handled individually
      if (changeLogEntry.operation == 'error') {}
      if (changeLogEntry.operation == 'hold') {}
    }

    return null; // No validation error
  }

  /// Check payload size limits for DynamoDB compatibility
  static ChangeProcessingResult? _checkPayloadLimits({
    required String targetStorageId,
    required BaseChangeLogEntry changeLogEntry,
    required BaseEntityState? entityState,
    required Map<String, dynamic> stateUpdates,
    required int changeIndex,
  }) {
    final cid = changeLogEntry.cid;

    // return error if targetStorageId is same as changeLogEntry.storageId and
    // total state update payload is greater than dynamodb payload limits
    if (targetStorageId == changeLogEntry.storageId) {
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
