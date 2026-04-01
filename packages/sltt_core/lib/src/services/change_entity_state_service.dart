import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';

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
  );

  if (duplicateCheck.isDuplicate && storageType == 'cloud') {
    // Cloud is authoritative for duplicate CIDs. Do not emit any updates.
    return GetUpdateResults(
      isDuplicate: true,
      stateUpdates: const <String, dynamic>{},
      changeUpdates: const <String, dynamic>{},
      operationCounts: OperationCounts(
        duplicate: duplicateCheck.isClouded ? 0 : 1,
        clouded: duplicateCheck.isClouded ? 1 : 0,
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
    isDuplicate: duplicateCheck.isDuplicate,
    cidStateFields: duplicateCheck.cidStateFields,
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
    isDuplicate: duplicateCheck.isDuplicate,
    isClouded: duplicateCheck.isClouded,
    cidStateFields: duplicateCheck.cidStateFields,
  );

  final changeDataUpdates = {...updates.changeDataUpdates};
  final stateUpdates = {...updates.stateUpdates};

  // remove any null (field-detection) fields from stateUpdates
  stateUpdates.removeWhere((key, value) => value == null);
  final outdatedBys = (updates.outdatedBys);
  final operation = (updates.operation);
  final stateChanged = stateUpdates.isNotEmpty;
  Map<String, dynamic> additionalWarnings = getAdditionalWarnings(
    operation: operation,
    changeLogEntry: changeLogEntry,
    entityState: entityState,
    stateUpdates: stateUpdates,
    storageMode: storageMode,
  );

  // Read cloudAt/storedAt values computed by getDataAndStateUpdatesOrOutdatedBys
  final String? cloudAt = updates.cloudAt;
  final String storedAt = updates.storedAt;
  // Compute stateDataHash according to rules:
  // - if entityState == null: compute from stateUpdates and set stateDataHash_orig_
  // - if entityState != null and no stateUpdates: reuse entityState.stateDataHash
  // - otherwise: compute hash from merged data_ fields (entityState + stateUpdates)
  late final String stateDataHash;
  if (entityState == null) {
    stateDataHash = computeStateDataHash(stateUpdates);
    stateUpdates['stateDataHash_orig_'] = stateDataHash;
  } else {
    if (stateUpdates.isEmpty && entityState.stateDataHash != null) {
      stateDataHash = entityState.stateDataHash!;
    } else {
      final merged = <String, dynamic>{
        ...entityState.toJson(),
        ...stateUpdates,
      };
      stateDataHash = computeStateDataHash(merged);
    }
  }

  if (changeLogEntry.stateDataHash != null &&
      changeLogEntry.stateDataHash != stateDataHash) {
    // TODO(lan-local-team-storage): this currently keeps only the latest
    // sender-reported hash mismatch and assumes warnings originated from
    // changeLogEntry.storageId. Revisit warning provenance for multi-hop sync.
    additionalWarnings['stateDataHash'] = changeLogEntry.stateDataHash;
  }

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

  // Propagate stateDataHash into change updates and state updates when present
  changeLogEntryUpdates['stateDataHash'] = stateDataHash;
  if (stateUpdates.isNotEmpty) {
    stateUpdates['stateDataHash'] = stateDataHash;
  }

  return GetUpdateResults(
    isDuplicate: duplicateCheck.isDuplicate,
    stateUpdates: stateUpdates,
    changeUpdates: changeLogEntryUpdates,
    operationCounts: duplicateCheck.isDuplicate
        ? OperationCounts(
            duplicate: duplicateCheck.isClouded ? 0 : 1,
            clouded: duplicateCheck.isClouded ? 1 : 0,
          )
        : OperationCounts(
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
    // TODO(lan-local-team-storage): assumes warning values came from
    // changeLogEntry.storageId and does not preserve warning history.
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
  final bool isClouded;
  final List<String> cidStateFields;

  GetMaybeIsDuplicateCidResult({
    required this.isDuplicate,
    required this.isClouded,
    required this.cidStateFields,
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
}) {
  // Implement the logic to check for duplicate cid
  bool isDuplicate = false;
  bool isClouded = false;
  final cidStateFields = <String>{};

  if (entityState == null) {
    // If no entity state, it's not our duplicate
    return GetMaybeIsDuplicateCidResult(
      isDuplicate: false,
      isClouded: false,
      cidStateFields: const <String>[],
    );
  }

  final entityStateJson = entityState.toJson();
  final changeLogCid = changeLogEntry.cid;

  final changeLogEntryCloudAt = changeLogEntry.cloudAt
      ?.toUtc()
      .toIso8601String();

  final latestLevelDuplicate = entityState.change_cid == changeLogCid;
  if (latestLevelDuplicate) {
    isDuplicate = true;
  }

  for (final key in entityStateJson.keys) {
    if (key.endsWith('_cid_') && entityStateJson[key] == changeLogCid) {
      isDuplicate = true;
      if (key.startsWith('data_') && key.length > 10) {
        final field = key.substring(5, key.length - 5);
        if (field.isNotEmpty) {
          cidStateFields.add(field);
        }
      }
    }
  }

  if (isDuplicate && storageType == 'local' && changeLogEntryCloudAt != null) {
    final latestCloudDrift =
        latestLevelDuplicate &&
        entityStateJson['change_cloudAt'] != changeLogEntryCloudAt;

    var anyFieldCloudDrift = false;
    for (final field in cidStateFields) {
      final existingFieldCloudAt = entityStateJson['data_${field}_cloudAt_'];
      if (existingFieldCloudAt != changeLogEntryCloudAt) {
        anyFieldCloudDrift = true;
        break;
      }
    }
    isClouded = latestCloudDrift || anyFieldCloudDrift;
  }

  return GetMaybeIsDuplicateCidResult(
    isDuplicate: isDuplicate,
    isClouded: isClouded,
    cidStateFields: cidStateFields.toList()..sort(),
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
  BaseEntityState? entityState, {
  bool isDuplicate = false,
  List<String> cidStateFields = const <String>[],
}) {
  final changeData = changeLogEntry.getData();
  // Reject encoded null values in change data. Consumers currently expect
  // concrete values; encoded JSON nulls can cause ambiguous semantics and
  // are not supported yet. Fail fast so callers can sanitize upstream.
  for (final entry in changeData.entries) {
    if (entry.value == null) {
      throw Exception(
        'Null data values are not yet supported (field: ${entry.key})',
      );
    }
  }
  final fieldChanges = <String, dynamic>{};
  final noOpFields = <String>[];
  // The changeData is the incoming field data directly
  final incomingData = changeData;

  if (entityState != null) {
    final existingData = entityState.toJson();
    final cidStateFieldSet = cidStateFields.toSet();
    final String incomingChangeAt = changeLogEntry.changeAt.toIso8601String();
    final String? incomingCloudAt = changeLogEntry.cloudAt
        ?.toUtc()
        .toIso8601String();

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
      if (isDuplicate && cidStateFieldSet.contains(field)) {
        final valueChanged =
            stableStringify(existingData[entityFieldKey]) !=
            stableStringify(value);

        final metaPairs = <String, dynamic>{
          'data_${field}_changeAt_': incomingChangeAt,
          'data_${field}_cid_': changeLogEntry.cid,
          'data_${field}_changeBy_': changeLogEntry.changeBy,
          'data_${field}_dataSchemaRev_': changeLogEntry.dataSchemaRev,
          'data_${field}_cloudAt_': incomingCloudAt,
        };

        final metaChanged = metaPairs.entries.any(
          (entry) =>
              stableStringify(existingData[entry.key]) !=
              stableStringify(entry.value),
        );

        if (valueChanged || metaChanged) {
          fieldChanges[field] = value;
        } else {
          noOpFields.add(field);
        }
        return;
      }

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
GetDataAndStateUpdatesOrOutdatedBysResult getDataAndStateUpdatesOrOutdatedBys({
  required BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState,
  required Map<String, dynamic> fieldChanges,
  required List<String> noOpFields,
  required String storageType,
  required String storageMode,
  CloudStoredPair? cs,
  bool isDuplicate = false,
  bool isClouded = false,
  List<String> cidStateFields = const <String>[],
}) {
  // Reject null values in fieldChanges. Null data values are not supported yet
  // and should be handled upstream by callers that construct change data.
  for (final entry in fieldChanges.entries) {
    if (entry.value == null) {
      throw Exception(
        'Null data values are not yet supported (field: ${entry.key})',
      );
    }
  }
  final fieldUpdates = <String, dynamic>{};
  final outdatedBys = <String>[];
  final cidStateFieldSet = cidStateFields.toSet();

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
          epochZeroUtc,
        );
        if (changeLogEntry.changeAt.isAfter(existingFieldChangeAt)) {
          fieldUpdates[field] = value;
        } else {
          outdatedBys.add(field);
        }
      });
    }

    if (isDuplicate && isClouded) {
      for (final field in cidStateFieldSet) {
        if (fieldChanges.containsKey(field)) {
          fieldUpdates[field] = fieldChanges[field];
          outdatedBys.remove(field);
        }
      }
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
    if (isDuplicate && isClouded && fieldUpdates.isEmpty) ...{
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

  if (isDuplicate && cidStateFieldSet.isNotEmpty) {
    for (final field in cidStateFieldSet) {
      stateUpdates.remove('data_$field');
    }
  }

  final changeDataUpdates = <String, dynamic>{...fieldUpdates};
  if (isDuplicate && cidStateFieldSet.isNotEmpty) {
    changeDataUpdates.removeWhere(
      (key, value) => cidStateFieldSet.contains(key),
    );
  }

  return GetDataAndStateUpdatesOrOutdatedBysResult(
    cloudAt: computedCloudAt,
    storedAt: computedStoredAt,
    stateUpdates: stateUpdates,
    changeDataUpdates: changeDataUpdates,
    outdatedBys: outdatedBys,
    operation: operation,
  );
}

/// Typed result for `getDataAndStateUpdatesOrOutdatedBys` so callers have
/// well-defined top-level fields instead of a loose `Map`.
class GetDataAndStateUpdatesOrOutdatedBysResult {
  final String? cloudAt;
  final String storedAt;
  final Map<String, dynamic> stateUpdates;
  final Map<String, dynamic> changeDataUpdates;
  final List<String> outdatedBys;
  final String operation;

  GetDataAndStateUpdatesOrOutdatedBysResult({
    required this.cloudAt,
    required this.storedAt,
    required this.stateUpdates,
    required this.changeDataUpdates,
    required this.outdatedBys,
    required this.operation,
  });

  /// Backwards-compatible map-style accessor used by existing callers that
  /// expect a Map returned from the older implementation.
  dynamic operator [](String key) {
    switch (key) {
      case 'cloudAt':
        return cloudAt;
      case 'storedAt':
        return storedAt;
      case 'stateUpdates':
        return stateUpdates;
      case 'changeDataUpdates':
        return changeDataUpdates;
      case 'outdatedBys':
        return outdatedBys;
      case 'operation':
        return operation;
      default:
        return null;
    }
  }
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
