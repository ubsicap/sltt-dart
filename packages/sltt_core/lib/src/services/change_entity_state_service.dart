import 'dart:convert';

import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/base_entity_state.dart';

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

/// Result container for computing updates without constructing a new change-log entry
class GetUpdateResults {
  final bool isDuplicate;
  final Map<String, dynamic> stateUpdates;
  final Map<String, dynamic> changeUpdates;

  const GetUpdateResults({
    required this.isDuplicate,
    required this.stateUpdates,
    required this.changeUpdates,
  });
}

/// Compute updates for a change-log entry against optional current entity state.
/// Returns whether the CID is a duplicate (and if so, any minimal state updates like cloudAt),
/// plus the stateUpdates (metadata + data_ field metadata) and the subset of change data to write.
GetUpdateResults getUpdatesForChangeLogEntryAndEntityState(
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState, {
  required String targetStorageId,
}) {
  // Duplicate CID detection
  final duplicateCheck = getMaybeIsDuplicateCidResult(
    changeLogEntry,
    entityState,
  );

  if (duplicateCheck.isDuplicate) {
    // For duplicates, do not emit change data; only apply minimal state updates
    return GetUpdateResults(
      isDuplicate: true,
      stateUpdates: duplicateCheck.stateUpdates,
      changeUpdates: const <String, dynamic>{},
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
    changeLogEntry,
    entityState,
    fieldChanges,
    noOpFields,
  );

  final changeDataUpdates =
      (updates['changeDataUpdates'] as Map<String, dynamic>?) ??
      <String, dynamic>{};
  final stateUpdates =
      (updates['stateUpdates'] as Map<String, dynamic>?) ?? <String, dynamic>{};
  final outdatedBys = (updates['outdatedBys'] as List<String>? ?? <String>[]);
  final operation = (updates['operation'] as String? ?? 'update');
  final stateChanged = operation != 'noOp' && operation != 'outdated';
  Map<String, dynamic> additionalWarnings = getAdditionalWarnings(
    operation,
    changeLogEntry,
    entityState,
    stateUpdates,
  );

  // Build the full set of change-log entry updates callers can apply
  final shouldPreserveData = changeLogEntry.storageId != targetStorageId;
  final changeLogEntryUpdates = <String, dynamic>{
    'operation': operation,
    'operationInfoJson': jsonEncode({
      'outdatedBys': outdatedBys,
      'noOpFields': noOpFields,
      ...additionalWarnings,
    }),
    'stateChanged': stateChanged,
    'cloudAt': changeLogEntry.cloudAt,
  };
  if (!shouldPreserveData) {
    changeLogEntryUpdates['data'] = changeDataUpdates;
  }

  return GetUpdateResults(
    isDuplicate: false,
    stateUpdates: stateUpdates,
    changeUpdates: changeLogEntryUpdates,
  );
}

/// TODO: finish this function and add tests
/// additional warnings:
/// 1) incoming operation does not match actual operation
/// 2) incoming field_x_orig_ does not match existing state
Map<String, dynamic> getAdditionalWarnings(
  String operation,
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState,
  Map<String, dynamic> stateUpdates,
) {
  final additionalWarnings = <String, dynamic>{};
  if (['create', 'update', 'delete'].contains(operation) &&
      changeLogEntry.operation != operation) {
    additionalWarnings['operation'] = changeLogEntry.operation;
  }
  if (entityState == null) {
    if (stateUpdates['change_changeAt_orig_'] != null &&
        stateUpdates['change_changeAt'] !=
            stateUpdates['change_changeAt_orig_']) {
      additionalWarnings['change_changeAt_orig_'] =
          stateUpdates['change_changeAt_orig_'];
      // fix stateUpdates
      stateUpdates['change_changeAt_orig_'] = stateUpdates['change_changeAt'];
    }
    // TODO: do this for all _orig_ fields
  } else {
    // don't change any existing fieldx__orig_ fields!!!
    if (stateUpdates['change_changeAt_orig_'] != null &&
        entityState.change_changeAt_orig_ !=
            stateUpdates['change_changeAt_orig_']) {
      additionalWarnings['change_changeAt_orig_'] =
          stateUpdates['change_changeAt_orig_'];
      stateUpdates.remove('change_changeAt_orig_');
    }
    // TODO: do this for all _orig_ fields
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
GetMaybeIsDuplicateCidResult getMaybeIsDuplicateCidResult(
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState,
) {
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

  final changeLogEntryChangeAt = changeLogEntry.cloudAt?.toIso8601String();

  // todo: add test for checking latest cid first
  if (entityState.change_cid == changeLogCid) {
    isDuplicate = true;
    if (changeLogEntryChangeAt != null &&
        entityStateJson['change_cloudAt'] != changeLogEntryChangeAt) {
      // Update latest-level cloudAt
      stateUpdates['change_cloudAt'] = changeLogEntryChangeAt;
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
        if (changeLogEntryChangeAt != null &&
            entityStateFieldCloudAt != changeLogEntryChangeAt) {
          // Update field-level cloudAt
          stateUpdates['${fieldWithoutCid}_cloudAt_'] = changeLogEntryChangeAt;
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
/// returns { operation: string } 'noOp', 'outdated', 'create', 'update', or 'delete'
/// Determines the operation type based on the change log entry and current entity state.
String calculateOperation(
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState,
  Map<String, dynamic> fieldChanges, // Map of field changes
  List<String> noOpFields, // List of fields that are no-ops
  List<String> outdatedBys, // List of fields that are outdated
) {
  final changeData = changeLogEntry.getData();

  // If the base entity state is null, we assume it's a create operation
  if (entityState == null) {
    return 'create';
  }

  // If the operation is 'delete', we return 'delete'
  if (changeData['deleted'] == true) {
    return 'delete';
  }

  // If there are no pre-computed field changes, analyze the change log entry directly
  if (fieldChanges.isEmpty && outdatedBys.isEmpty) {
    // Check if the change log entry has actual data changes
    final hasDataChanges = changeData.keys
        .where((key) => !key.startsWith('_') && key != 'deleted')
        .isNotEmpty;

    if (!hasDataChanges) {
      return 'noOp';
    }

    final entityJson = entityState.toJson();

    // Check if the values are actually different
    bool hasActualChanges = false;
    bool isOutdated = false;

    for (final key in changeData.keys) {
      if (key.startsWith('_') || key == 'deleted') continue;

      final entityFieldKey =
          'data_$key'; // Change log has 'rank', entity has 'data_rank'
      final entityValue = entityJson[entityFieldKey];
      final changeValue = changeData[key];

      // Check if value is different
      if (stableStringify(entityValue) != stableStringify(changeValue)) {
        hasActualChanges = true;

        // Check if this change is outdated based on field timestamp
        final fieldChangeAtData = entityJson['${entityFieldKey}_changeAt_'];
        final fieldChangeAt = fieldChangeAtData is DateTime
            ? fieldChangeAtData
            : (fieldChangeAtData is String
                  ? DateTime.tryParse(fieldChangeAtData)
                  : null);
        if (fieldChangeAt != null &&
            !changeLogEntry.changeAt.isAfter(fieldChangeAt)) {
          isOutdated = true;
        }
      }
    }

    if (!hasActualChanges) {
      return 'noOp';
    }

    if (isOutdated) {
      return 'outdated';
    }

    return 'update';
  }

  // If there are outdated fields, we return 'outdated'
  if (outdatedBys.isNotEmpty) {
    return 'outdated';
  }

  // Otherwise, we assume it's an update operation
  return 'update';
}

String stableStringify(dynamic value) {
  if (value is Map) {
    final sortedKeys = value.keys.toList()..sort();
    final sortedMap = {for (var k in sortedKeys) k: stableStringify(value[k])};
    return jsonEncode(sortedMap);
  } else if (value is List) {
    return jsonEncode(value.map(stableStringify).toList());
  } else {
    return jsonEncode(value);
  }
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
Map<String, dynamic> getDataAndStateUpdatesOrOutdatedBys(
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState,
  Map<String, dynamic> fieldChanges,
  List<String> noOpFields, // List of fields that are no-ops
) {
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
    isChangeNewerThanLatest = true;
    // No entity state, treat all as updates
    fieldUpdates.addAll(fieldChanges);
  }

  return {
    'stateUpdates': {
      if (entityState == null) ...{
        'entityId': changeLogEntry.entityId,
        'entityType': changeLogEntry.entityType.toString().split('.').last,
        'change_dataSchemaRev': changeLogEntry.dataSchemaRev,
        // _orig_ empty/default field_x_orig_ should inherit field_x values
        'change_domainId_orig_': '',
        'change_cid_orig_': '',
        'change_changeBy_orig_': '',
        'change_changeAt_orig_': BaseEntityState.defaultOrigDateTime()
            .toString(),
      },
      // latest metadata
      if (isChangeNewerThanLatest && fieldUpdates.isNotEmpty) ...{
        'change_domainType': changeLogEntry.domainType,
        'change_domainId': changeLogEntry.domainId,
        'change_changeAt': changeLogEntry.changeAt.toIso8601String(),
        'change_cid': changeLogEntry.cid,
        'change_changeBy': changeLogEntry.changeBy,
        'change_cloudAt': changeLogEntry.cloudAt?.toIso8601String(),
      },
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
        (key, value) => MapEntry(
          'data_${key}_cloudAt_',
          changeLogEntry.cloudAt?.toIso8601String(),
        ),
      ),
    },
    'changeDataUpdates': fieldUpdates,
    'outdatedBys': outdatedBys,
    'operation': calculateOperation(
      changeLogEntry,
      entityState,
      fieldChanges,
      noOpFields,
      outdatedBys,
    ),
  };
}
