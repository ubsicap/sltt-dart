import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
import 'package:sltt_core/src/models/constants/change_operations.dart';

class LastWriteWinsResult {
  /// may or may not be the same as the incoming changeLogEntryToWrite
  /// null if duplicate cid
  final BaseChangeLogEntry? changeLogEntryToWrite;

  /// If the operation resulted in a state change, this will contain the new entity state.
  final BaseEntityState? newEntityState;

  LastWriteWinsResult({
    required this.changeLogEntryToWrite,
    this.newEntityState,
  });
}

class OperationCounts {
  final int create;
  final int update;
  final int delete;
  final int noOp;
  final int duplicate;
  final int clouded;
  final int outdated;
  final int partialUpdate;
  final int error;
  final int hold;

  OperationCounts({
    this.create = 0,
    this.update = 0,
    this.delete = 0,
    this.noOp = 0,
    this.duplicate = 0,
    this.clouded = 0,
    this.outdated = 0,
    this.partialUpdate = 0,
    this.error = 0,
    this.hold = 0,
  });

  @override
  String toString() {
    return 'OperationCounts(create: $create, update: $update, delete: $delete, noOp: $noOp, duplicate: $duplicate, clouded: $clouded, outdated: $outdated, partialUpdate: $partialUpdate, error: $error, hold: $hold)';
  }
}

/// Result container for computing updates without constructing a new change-log entry
class GetUpdateResults {
  final bool isDuplicate;
  final Map<String, dynamic> stateUpdates;
  final Map<String, dynamic> changeUpdates;
  final OperationCounts operationCounts;

  const GetUpdateResults({
    required this.isDuplicate,
    required this.stateUpdates,
    required this.changeUpdates,
    required this.operationCounts,
  });
}

/// Compute updates for a change-log entry against optional current entity state.
/// Returns whether the CID is a duplicate (and if so, any minimal state updates like cloudAt),
/// plus the stateUpdates (metadata + data_ field metadata) and the subset of change data to write.
GetUpdateResults getUpdatesForChangeLogEntryAndEntityState(
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState, {
  required String storageMode,
  required String storageType,
  required String targetStorageId,
}) {
  // Compute cloud/stored pair once for this change processing invocation so
  // all downstream helpers use the exact same timestamps (avoids millisecond
  // differences from multiple DateTime.now() calls).
  final CloudStoredPair cs = computeCloudAndStoredAt(
    changeLogEntry,
    storageType,
  );

  // Duplicate CID detection
  final duplicateCheck = getMaybeIsDuplicateCidResult(
    changeLogEntry: changeLogEntry,
    entityState: entityState,
    storageType: storageType,
    cloudStoredPair: cs,
  );

  if (duplicateCheck.isDuplicate) {
    // For duplicates, do not emit change data; only apply minimal state updates
    return GetUpdateResults(
      isDuplicate: true,
      stateUpdates: duplicateCheck.stateUpdates,
      changeUpdates: const <String, dynamic>{},
      operationCounts: OperationCounts(
        duplicate: duplicateCheck.stateUpdates.isEmpty ? 1 : 0,
        clouded: duplicateCheck.stateUpdates.isNotEmpty ? 1 : 0,
      ),
    );
  }

  // TODO: some errors we may want to save, at least for audit trail on cloud storage
  if ([
    kChangeOperationError,
    kChangeOperationNoOp,
    kChangeOperationHold,
  ].contains(changeLogEntry.operation)) {
    return GetUpdateResults(
      isDuplicate: false,
      stateUpdates: <String, dynamic>{},
      changeUpdates: <String, dynamic>{},
      operationCounts: OperationCounts(
        error: changeLogEntry.operation == kChangeOperationError ? 1 : 0,
        hold: changeLogEntry.operation == kChangeOperationHold ? 1 : 0,
        noOp: changeLogEntry.operation == kChangeOperationNoOp ? 1 : 0,
      ),
    );
  }

  // Compute changed vs no-op fields
  final fieldChangesOrNoOps = getFieldChangesOrNoOps(
    changeLogEntry,
    entityState,
  );
  final fieldChanges = fieldChangesOrNoOps.fieldChanges;
  final noOpFields = fieldChangesOrNoOps.noOpFields;

  // Decide field-level updates and produce state updates
  final updates = getDataAndStateUpdatesOrOutdatedBys(
    changeLogEntry: changeLogEntry,
    entityState: entityState,
    fieldChanges: fieldChanges,
    noOpFields: noOpFields,
    storageType: storageType,
    storageMode: storageMode,
    cs: cs,
  );

  final changeDataUpdates = {
    ...(updates['changeDataUpdates'] as Map<String, dynamic>?) ??
        <String, dynamic>{},
  };
  final stateUpdates = {
    ...(updates['stateUpdates'] as Map<String, dynamic>?) ??
        <String, dynamic>{},
  };

  // remove any null (field-detection) fields from stateUpdates
  stateUpdates.removeWhere((key, value) => value == null);
  final outdatedBys = (updates['outdatedBys'] as List<String>? ?? <String>[]);
  final operation = (updates['operation'] as String? ?? '');
  final stateChanged = stateUpdates.isNotEmpty;
  Map<String, dynamic> additionalWarnings = getAdditionalWarnings(
    operation: operation,
    changeLogEntry: changeLogEntry,
    entityState: entityState,
    stateUpdates: stateUpdates,
    storageMode: storageMode,
  );

  // Read cloudAt/storedAt values computed by getDataAndStateUpdatesOrOutdatedBys
  final String? cloudAt = updates['cloudAt'] as String?;
  final String storedAt = updates['storedAt'] as String;

  // Build the full set of change-log entry updates callers can apply
  // Decide whether to preserve incoming change data in the change-log entry.
  // In "sync" mode we generally preserve the incoming data when it originated
  // from another storage (non-empty storageId). In "save" mode the incoming
  // change represents a local save, so we can trim incoming data.
  final shouldPreserveData = storageMode == 'sync';
  final changeLogEntryUpdates = <String, dynamic>{
    'operation': operation,
    'operationInfoJson': jsonEncode({
      'outdatedBys': outdatedBys,
      'noOpFields': noOpFields,
      if (additionalWarnings.isNotEmpty) ...{'warnings': additionalWarnings},
    }),
    'stateChanged': stateChanged,
    'storedAt': storedAt,
    'cloudAt': cloudAt,
    if (storageMode == 'save') ...{
      // In save mode the persisted change should indicate the storage that originally saved it
      'storageId': targetStorageId,
    },
  };
  if (shouldPreserveData) {
    changeLogEntryUpdates['dataJson'] = changeLogEntry.dataJson;
  } else {
    changeLogEntryUpdates['dataJson'] = jsonEncode(changeDataUpdates);
  }

  return GetUpdateResults(
    isDuplicate: false,
    stateUpdates: stateUpdates,
    changeUpdates: changeLogEntryUpdates,
    operationCounts: OperationCounts(
      create: operation == kChangeOperationCreate ? 1 : 0,
      update:
          [
            kChangeOperationUpdate,
            kChangeOperationPartialUpdate,
          ].contains(operation)
          ? 1
          : 0,
      partialUpdate: operation == kChangeOperationPartialUpdate ? 1 : 0,
      outdated: operation == kChangeOperationOutdated ? 1 : 0,
      delete: operation == kChangeOperationDelete ? 1 : 0,
      noOp: operation == kChangeOperationNoOp ? 1 : 0,
    ),
  );
}

/// additional warnings:
/// 1) incoming operation does not match actual operation
/// 2) incoming field_x_orig_ does not match existing state
Map<String, dynamic> getAdditionalWarnings({
  required String operation,
  required BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState,
  required Map<String, dynamic> stateUpdates,
  required String storageMode,
}) {
  final additionalWarnings = <String, dynamic>{};
  if (['create', 'update', 'delete'].contains(operation) &&
      (storageMode != 'save' || changeLogEntry.operation.isNotEmpty) &&
      changeLogEntry.operation != operation) {
    additionalWarnings['operation'] = changeLogEntry.operation;
  }
  if (entityState == null) {
    // for new entities, fieldx_orig_ fields should always be equal to the corresponding fieldx value
    for (final key in stateUpdates.keys) {
      if (key.endsWith('_orig_')) {
        final fieldX = key.substring(0, key.length - '_orig_'.length);
        final fieldXValue = stateUpdates[fieldX];
        // TODO: endsWith('At') is fragile, need a better way to determine
        // date fields
        if (fieldXValue != null &&
            fieldXValue != stateUpdates[key] &&
            ((!fieldX.endsWith('At') && !stateUpdates[key].isEmpty) ||
                (fieldX.endsWith('At') &&
                    stateUpdates[key] !=
                        BaseEntityState.defaultOrigDateTime()
                            .toIso8601String()))) {
          // only capture non-default as warning
          additionalWarnings[key] = stateUpdates[key];
        }
        stateUpdates[key] = fieldXValue;
      }
    }
  } else {
    // don't change any existing fieldx__orig_ fields!!!
    // look for any fieldx_orig_ fields in stateUpdates
    // add them to additionalWarnings
    // and remove them from stateUpdates.
    // no need to check equality, since stateUpdates should
    // only contain values if they are different
    for (final key in {...stateUpdates}.keys) {
      if (key.endsWith('_orig_')) {
        additionalWarnings[key] = stateUpdates[key];
        stateUpdates.remove(key);
      }
    }
  }
  return additionalWarnings;
}

/// Result type for getMaybeIsduplicateCid
class GetMaybeIsDuplicateCidResult {
  final bool isDuplicate;

  /// Minimal state updates to apply when a duplicate is detected.
  /// Examples:
  ///  - {'change_cloudAt': '...'} for latest-level duplicates
  ///  - {'data_<field>_cloudAt_': '...'} for field-level duplicates
  final Map<String, dynamic> stateUpdates;

  GetMaybeIsDuplicateCidResult({
    required this.isDuplicate,
    required this.stateUpdates,
  });
}

/// getMaybeIsduplicateCid(changeLogEntry: ChangeLogEntry, entityState: BaseEntityState):
/// Checks if the given change log entry is a duplicate based on its cid.
///
/// @returns { isDuplicate: boolean, cloudAt?: DateTime }
GetMaybeIsDuplicateCidResult getMaybeIsDuplicateCidResult({
  required BaseChangeLogEntry changeLogEntry,
  required BaseEntityState? entityState,
  required String storageType,
  CloudStoredPair? cloudStoredPair,
}) {
  // Implement the logic to check for duplicate cid
  bool isDuplicate = false;
  final stateUpdates = <String, dynamic>{};

  if (entityState == null) {
    // If no entity state, it's not our duplicate
    return GetMaybeIsDuplicateCidResult(
      isDuplicate: false,
      stateUpdates: const <String, dynamic>{},
    );
  }

  final entityStateJson = entityState.toJson();
  final changeLogCid = changeLogEntry.cid;

  final changeLogEntryCloudAt = changeLogEntry.cloudAt?.toIso8601String();

  // Use provided cloud/stored pair (cs) if supplied so both values are
  // consistent for the current invocation with other helpers.
  final CloudStoredPair localCs =
      cloudStoredPair ?? computeCloudAndStoredAt(changeLogEntry, storageType);
  final String computedStoredAt = localCs.storedAt;

  if (entityState.change_cid == changeLogCid) {
    isDuplicate = true;
    if (storageType == 'local' &&
        changeLogEntryCloudAt != null &&
        entityStateJson['change_cloudAt'] != changeLogEntryCloudAt) {
      // Update latest-level cloudAt
      stateUpdates['change_cloudAt'] = changeLogEntryCloudAt;
      // Also persist the storedAt so callers can persist change_storedAt
      stateUpdates['change_storedAt'] = computedStoredAt;
    }
  }

  if (!isDuplicate) {
    // Check if any field in the entity state matches the change log entry cid
    for (final key in entityStateJson.keys) {
      if (key.endsWith('_cid_') && entityStateJson[key] == changeLogCid) {
        isDuplicate = true;

        /// get field without _cid_ and lookup field_cloudAt_
        final fieldWithoutCid = key.substring(0, key.length - 4);
        final entityStateFieldCloudAt =
            entityStateJson['${fieldWithoutCid}_cloudAt_'];
        if (changeLogEntryCloudAt != null &&
            entityStateFieldCloudAt != changeLogEntryCloudAt) {
          // Update field-level cloudAt
          stateUpdates['${fieldWithoutCid}_cloudAt_'] = changeLogEntryCloudAt;
          // Also set latest-level storedAt for the change so downstream callers
          // have the storedAt that corresponds to this cloudAt.
          stateUpdates['change_storedAt'] = computedStoredAt;
        }
        break;
      }
    }
  }

  return GetMaybeIsDuplicateCidResult(
    isDuplicate: isDuplicate,
    stateUpdates: stateUpdates,
  );
}

/// calculateOperation(changeLogEntry: ChangeLogEntry, entityState: BaseEntityState):
/// returns { operation: string } 'noOp', 'outdated', 'create', 'update', 'pUpdate', or 'delete'
/// Determines the operation type based on the change log entry and current entity state.
String calculateOperation({
  BaseEntityState? entityState,
  required Map<String, dynamic> fieldUpdates, // Map of field updates
  required List<String> noOpFields, // List of fields that are no-ops
  required List<String> outdatedBys, // List of fields that are outdated
}) {
  // If the base entity state is null, we assume it's a create operation
  if (entityState == null) {
    return kChangeOperationCreate;
  }

  if (fieldUpdates.isEmpty) {
    if (outdatedBys.isNotEmpty) {
      return kChangeOperationOutdated;
    } else {
      return kChangeOperationNoOp;
    }
  }

  // If the operation is 'delete', data includes 'deleted' 'true'
  if (fieldUpdates['deleted'] == true) {
    return kChangeOperationDelete;
  }

  // If there are outdated fields, we return 'pUpdate'
  if (outdatedBys.isNotEmpty) {
    return kChangeOperationPartialUpdate;
  }

  // Otherwise, we assume it's an update operation
  return kChangeOperationUpdate;
}

class GetFieldChangesOrNoOpResult {
  final Map<String, dynamic> fieldChanges;
  final List<String> noOpFields;

  GetFieldChangesOrNoOpResult({
    required this.fieldChanges,
    required this.noOpFields,
  });
}

/// getFieldChangesOrNoOps(changeLogEntry: ChangeLogEntry, entityState: BaseEntityState):
/// returns { fieldChanges: Map<String, dynamic>, noOpFields: List<String> }
GetFieldChangesOrNoOpResult getFieldChangesOrNoOps(
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState,
) {
  final changeData = changeLogEntry.getData();
  final fieldChanges = <String, dynamic>{};
  final noOpFields = <String>[];
  // The changeData is the incoming field data directly
  final incomingData = changeData;

  if (entityState != null) {
    final existingData = entityState.toJson();

    incomingData.forEach((field, value) {
      // Debug: log comparison to aid diagnosing noOp/update classification
      try {
        final existingVal = existingData['data_$field'];
        SlttLogger.logger.fine(
          'DEBUG: comparing field "$field": existing=$existingVal (${existingVal.runtimeType}), existing_str=${stableStringify(existingVal)} incoming=$value (${value.runtimeType}), incoming_str=${stableStringify(value)}',
        );
      } catch (e, st) {
        // Log any unexpected errors during debug printing to avoid silent failures
        SlttLogger.logger.warning(
          'DEBUG: comparing field "$field": error printing values: $e',
        );
        SlttLogger.logger.warning(st.toString());
      }
      final entityFieldKey =
          'data_$field'; // Change log has 'rank', entity has 'data_rank'
      if (stableStringify(existingData[entityFieldKey]) !=
          stableStringify(value)) {
        fieldChanges[field] = value;
      } else {
        noOpFields.add(field);
      }
    });
  } else {
    // If no base entity state, treat all incoming data as field changes
    fieldChanges.addAll(incomingData);
  }

  return GetFieldChangesOrNoOpResult(
    fieldChanges: fieldChanges,
    noOpFields: noOpFields,
  );
}

DateTime _toDateTime(dynamic v, DateTime defaultValue) {
  if (v == null) return defaultValue;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v) ?? defaultValue;
  return defaultValue;
}

/// fieldUpdatesOrOutdatedBys(changeLogEntry: ChangeLogEntry, entityState: BaseEntityState, fieldChanges):
/// returns { fieldUpdates: Map<String, dynamic>, outdatedBys: List<String> }
Map<String, dynamic> getDataAndStateUpdatesOrOutdatedBys({
  required BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState,
  required Map<String, dynamic> fieldChanges,
  required List<String> noOpFields,
  required String storageType,
  required String storageMode,
  CloudStoredPair? cs,
}) {
  final fieldUpdates = <String, dynamic>{};
  final outdatedBys = <String>[];

  bool isChangeNewerThanLatest = false;

  if (entityState != null) {
    // Access entity state properties directly for latest metadata check
    final existingChangeAt = entityState.change_changeAt;

    final existingStateJson = entityState.toJson();

    // Check if incoming change is newer than the latest change in the entity state
    if (changeLogEntry.changeAt.isAfter(existingChangeAt)) {
      // Incoming change is newer than latest change
      isChangeNewerThanLatest = true;
    } else {
      // Incoming change is older than or equal to latest change
      isChangeNewerThanLatest = false;
    }

    if (isChangeNewerThanLatest) {
      // Change is newer than latest, update all changed fields
      fieldChanges.forEach((field, value) {
        fieldUpdates[field] = value;
      });
    } else {
      // Change is not newer than latest, check field by field
      fieldChanges.forEach((field, value) {
        final entityFieldKey =
            'data_$field'; // Change log has 'rank', entity has 'data_rank'            ;

        final existingFieldChangeAt = _toDateTime(
          existingStateJson['${entityFieldKey}_changeAt_'],
          DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
        );
        if (changeLogEntry.changeAt.isAfter(existingFieldChangeAt)) {
          fieldUpdates[field] = value;
        } else {
          outdatedBys.add(field);
        }
      });
    }
  } else {
    SlttLogger.logger.fine(
      'getDataAndStateUpdatesOrOutdatedBys - entityState is null for ${changeLogEntry.entityId}',
    );
    isChangeNewerThanLatest = true;
    // No entity state, treat all as updates
    fieldUpdates.addAll(fieldChanges);
  }

  // Debug: log detailed decision info
  try {
    SlttLogger.logger.fine(
      'DEBUG: getDataAndStateUpdatesOrOutdatedBys - cid=${changeLogEntry.cid} entityId=${changeLogEntry.entityId} fieldChanges=$fieldChanges noOpFields=$noOpFields outdatedBys=$outdatedBys isChangeNewerThanLatest=$isChangeNewerThanLatest',
    );
    if (entityState != null) {
      try {
        SlttLogger.logger.fine(
          'DEBUG: existingEntityState=${entityState.toJson()}',
        );
      } catch (e, st) {
        // If entityState serialization fails, log stack for diagnosis
        SlttLogger.logger.warning(
          'DEBUG: failed to serialize existingEntityState: $e',
        );
        SlttLogger.logger.warning(st.toString());
      }
    }
  } catch (e, st) {
    // Log any unexpected errors during debug printing
    SlttLogger.logger.warning(
      'DEBUG: getDataAndStateUpdatesOrOutdatedBys - debug print failed: $e',
    );
    SlttLogger.logger.warning(st.toString());
  }

  // Use provided cloud/stored pair (cs) if supplied to ensure the same
  // timestamps are used across the whole change processing invocation.
  final CloudStoredPair localCs =
      cs ?? computeCloudAndStoredAt(changeLogEntry, storageType);
  final String? computedCloudAt = localCs.cloudAt;
  final String computedStoredAt = localCs.storedAt;

  // add these in for field-drift detection, and remove them later if still null
  final optionalStateFields = {'schemaVersion': null};
  final optionalDataFields = {'deleted': null, 'rank': null};
  final metaFields = [
    'cid',
    'changeBy',
    'changeAt',
    'dataSchemaRev',
    'cloudAt',
  ];

  final optionalDataMetaFields = <String, dynamic>{};
  // for each data field, add _meta_ fields for field-drift detection, remove later
  for (final dataField in optionalDataFields.keys) {
    for (final meta in metaFields) {
      optionalDataMetaFields['data_${dataField}_${meta}_'] = null;
    }
  }

  final stateUpdates = {
    if (entityState == null) ...{
      'entityId': changeLogEntry.entityId,
      'domainType': changeLogEntry.domainType,
      'entityType': changeLogEntry.entityType.toString().split('.').last,
      'change_dataSchemaRev': changeLogEntry.dataSchemaRev,
      'change_domainId_orig_': changeLogEntry.domainId,
      'change_cid_orig_': changeLogEntry.cid,
      'change_changeBy_orig_': changeLogEntry.changeBy,
      'change_changeAt_orig_': changeLogEntry.changeAt
          .toUtc()
          .toIso8601String(),
      'change_storedAt_orig_': computedStoredAt,
    },
    // latest metadata
    // If there are any field updates, include the cloud/stored timestamps so
    // callers can persist change_storedAt even when the incoming change is
    // not newer than the entity's overall latest change. Only promote
    // the latest-level change metadata when the incoming change is newer
    // than the existing latest (isChangeNewerThanLatest).
    if (fieldUpdates.isNotEmpty) ...{
      if (isChangeNewerThanLatest) ...{
        'domainType': changeLogEntry.domainType,
        'change_domainId': changeLogEntry.domainId,
        'change_changeAt': changeLogEntry.changeAt.toIso8601String(),
        'change_cid': changeLogEntry.cid,
        'change_changeBy': changeLogEntry.changeBy,
        'change_dataSchemaRev': changeLogEntry.dataSchemaRev,
      },
      // Always set cloudAt/storedAt when applying field updates so downstream
      // callers can persist change_storedAt even for partial-field updates.
      'change_cloudAt': computedCloudAt,
      'change_storedAt': computedStoredAt,
    },
    // add optional state fields for field-drift detection, remove later
    ...optionalStateFields.map((key, value) => MapEntry(key, value)),
    // add optional data fields for field-drift detection, remove later
    ...optionalDataFields.map((key, value) => MapEntry('data_$key', value)),
    // for each data field, add _meta_ fields for field-drift detection, remove later
    ...optionalDataMetaFields,
    // Transform field updates to use data_ prefix for entity state
    // update data_ field values
    ...fieldUpdates.map((key, value) => MapEntry('data_$key', value)),
    // update data_ field-specific metadata
    ...fieldUpdates.map(
      (key, value) => MapEntry(
        'data_${key}_changeAt_',
        changeLogEntry.changeAt.toIso8601String(),
      ),
    ),
    ...fieldUpdates.map(
      (key, value) => MapEntry('data_${key}_cid_', changeLogEntry.cid),
    ),
    ...fieldUpdates.map(
      (key, value) =>
          MapEntry('data_${key}_changeBy_', changeLogEntry.changeBy),
    ),
    ...fieldUpdates.map(
      (key, value) => MapEntry('data_${key}_cloudAt_', computedCloudAt),
    ),
    ...fieldUpdates.map(
      (key, value) =>
          MapEntry('data_${key}_dataSchemaRev_', changeLogEntry.dataSchemaRev),
    ),
  };

  final operation = calculateOperation(
    entityState: entityState,
    fieldUpdates: fieldUpdates,
    noOpFields: noOpFields,
    outdatedBys: outdatedBys,
  );

  return {
    // expose the computed values to callers
    'cloudAt': computedCloudAt,
    'storedAt': computedStoredAt,
    'stateUpdates': stateUpdates,
    'changeDataUpdates': fieldUpdates,
    'outdatedBys': outdatedBys,
    'operation': operation,
  };
}

/// Helper class to hold computed cloudAt and storedAt values. Using a single
/// helper that returns both values ensures callers that need them during a
/// single change-processing invocation get consistent timestamps (cached per
/// call), rather than potentially different DateTime.now() values on repeated
/// calls.
class CloudStoredPair {
  final String? cloudAt;
  final String storedAt;

  CloudStoredPair(this.cloudAt, this.storedAt);
}

CloudStoredPair computeCloudAndStoredAt(
  BaseChangeLogEntry changeLogEntry,
  String storageType,
) {
  // If the incoming change has an explicit cloudAt we serialize and reuse it.
  final String? incomingCloudAt = changeLogEntry.cloudAt != null
      ? changeLogEntry.toJson()['cloudAt'] as String?
      : null;

  // Synthesize a single timestamp when we need to generate now() so both
  // cloudAt and storedAt (for cloud storage) use the exact same value.
  // If the incoming change already provided a cloudAt string, reuse it.
  final String nowIso = const UtcDateTimeConverter().toJson(DateTime.now());

  // For cloud storage, if incoming cloudAt is null use the synthesized nowIso
  // for both computedCloudAt and computedStoredAt. For local storage,
  // computedCloudAt remains null and storedAt is synthesized nowIso.
  final String? computedCloudAt =
      incomingCloudAt ?? (storageType == 'cloud' ? nowIso : null);

  final String computedStoredAt = storageType == 'cloud'
      ? (incomingCloudAt ?? nowIso)
      : nowIso;

  return CloudStoredPair(computedCloudAt, computedStoredAt);
}
