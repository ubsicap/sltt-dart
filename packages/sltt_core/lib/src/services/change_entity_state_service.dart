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

///
LastWriteWinsResult getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState, {
  required String targetStorageId,
  required BaseChangeLogEntry Function(Map<String, dynamic>)?
  changeLogEntryFactory,
  required BaseEntityState Function(Map<String, dynamic>) entityStateFactory,
}) {
  if (changeLogEntryFactory == null) {
    throw Exception(
      'changeLogEntryFactory is required for creating new ChangeLogEntry instances',
    );
  }

  // Check if the change log entry is a duplicate
  final duplicateCheck = getMaybeIsDuplicateCidResult(
    changeLogEntry,
    entityState,
  );

  if (duplicateCheck.isDuplicate) {
    // If it's a duplicate, update cloudAt if needed
    // TODO: should changeLogEntry be null?
    // need to think about this more.
    // might depend on targetStorageId
    return LastWriteWinsResult(
      changeLogEntryToWrite: null,
      newEntityState: entityState,
    );
  }

  // Get field changes or no-op fields
  final fieldChangesOrNoOps = getFieldChangesOrNoOps(
    changeLogEntry,
    entityState,
  );
  final fieldChanges = fieldChangesOrNoOps.fieldChanges;
  final noOpFields = fieldChangesOrNoOps.noOpFields;

  // Get field updates or outdated fields
  final fieldUpdatesOrOutdatedBys = getDataAndStateUpdatesOrOutdatedBys(
    changeLogEntry,
    entityState,
    fieldChanges,
    noOpFields,
  );

  final changeDataUpdates =
      fieldUpdatesOrOutdatedBys['changeDataUpdates'] as Map<String, dynamic>;
  // todo: use instead of BaseEntityState.fromChangeLogEntry?
  // final stateUpdates =
  //    fieldUpdatesOrOutdatedBys['stateUpdates'] as Map<String, dynamic>;
  final outdatedBys = fieldUpdatesOrOutdatedBys['outdatedBys'] as List<String>;
  final stateUpdates =
      fieldUpdatesOrOutdatedBys['stateUpdates'] as Map<String, dynamic>;

  // Calculate the operation type
  final operation = fieldUpdatesOrOutdatedBys['operation'] as String;

  // Preserve original data payload when transferring to a different target storage
  final shouldPreserveData = changeLogEntry.storageId != targetStorageId;

  final Map<String, dynamic> changeLogEntryUpdates = {
    'operation': operation,
    'operationInfo': {'outdatedBys': outdatedBys, 'noOpFields': noOpFields},
    'stateChanged': operation != 'noOp' && operation != 'outdated',
    'cloudAt': changeLogEntry.cloudAt,
  };
  if (!shouldPreserveData) {
    changeLogEntryUpdates['data'] = changeDataUpdates;
  }
  final newChangeLogEntryJson = {
    ...changeLogEntry.toJson(),
    ...changeLogEntryUpdates,
  };

  final newChangeLogEntry = changeLogEntryFactory(newChangeLogEntryJson);

  // Update the entity state if necessary
  return LastWriteWinsResult(
    changeLogEntryToWrite: newChangeLogEntry,
    newEntityState: operation != 'noOp' && operation != 'outdated'
        ? forkWithStateUpdates(entityState, stateUpdates, entityStateFactory)
        : null,
  );
}

BaseEntityState forkWithStateUpdates(
  BaseEntityState? sourceEntityState,
  Map<String, dynamic> stateUpdates,
  BaseEntityState Function(Map<String, dynamic>) entityStateFactory,
) {
  Map<String, dynamic> clone = sourceEntityState?.toJson() ?? {};

  final newJson = {...clone, ...stateUpdates};

  // Remove null values that the generated fromJson can't handle
  newJson.removeWhere((key, value) => value == null);

  return entityStateFactory(newJson);
}

/// Result type for getMaybeIsduplicateCid
class GetMaybeIsDuplicateCidResult {
  final bool isDuplicate;
  final DateTime? cloudAt;

  GetMaybeIsDuplicateCidResult({required this.isDuplicate, this.cloudAt});
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

  /// if set, update cloudAt in entityState
  DateTime? cloudAt;

  if (entityState == null) {
    // If no entity state, it's not our duplicate
    return GetMaybeIsDuplicateCidResult(isDuplicate: false);
  }

  final entryState = entityState.toJson();
  final changeLogCid = changeLogEntry.cid;

  // todo: add test for checking latest cid first
  if (entityState.change_cid == changeLogCid) {
    isDuplicate = true;
    if (changeLogEntry.cloudAt != null &&
        entityState.change_cloudAt != changeLogEntry.cloudAt) {
      // indicate we need to change cloudAt
      cloudAt = changeLogEntry.cloudAt;
    }
  }

  if (!isDuplicate) {
    // Check if any field in the entity state matches the change log entry cid
    for (final key in entryState.keys) {
      if (key.endsWith('_cid_') && entryState[key] == changeLogCid) {
        isDuplicate = true;

        /// get field without _cid_ and lookup field_cloudAt_
        final fieldWithoutCid = key.substring(0, key.length - 4);
        final entityStateFieldCloudAt =
            entryState['${fieldWithoutCid}_cloudAt_'];
        if (entityStateFieldCloudAt != null &&
            entityStateFieldCloudAt != changeLogEntry.cloudAt) {
          // indicate we need to change cloudAt
          cloudAt = changeLogEntry.cloudAt;
        }
        break;
      }
    }
  }

  // TODO: return stateUpdates
  return GetMaybeIsDuplicateCidResult(
    isDuplicate: isDuplicate,
    cloudAt: cloudAt,
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
  final changeData = changeLogEntry.data;

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
  final changeData = changeLogEntry.data;
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
          DateTime.fromMillisecondsSinceEpoch(0),
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
        'change_domainId_orig_': changeLogEntry.domainId,
        'change_changeAt_orig_': changeLogEntry.changeAt.toIso8601String(),
        'change_cid_orig_': changeLogEntry.cid,
        'change_changeBy_orig_': changeLogEntry.changeBy,
        'change_cloudAt_orig_': changeLogEntry.cloudAt?.toIso8601String(),
        'change_dataSchemaRev': changeLogEntry.dataSchemaRev,
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
