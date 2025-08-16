import 'dart:convert';

import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/base_entity_state.dart';

class LastWriteWinsResult {
  final BaseChangeLogEntry newChangeLogEntry;
  final BaseEntityState? newEntityState;

  LastWriteWinsResult({required this.newChangeLogEntry, this.newEntityState});
}

///
getAtomicLastWriteWinsToChangeLogEntryAndUpdateEntityState(
  BaseChangeLogEntry changeLogEntry,
  BaseEntityState? entityState, {
  required BaseChangeLogEntry Function(Map<String, dynamic>)?
  changeLogEntryFactory,
  required BaseEntityState Function(Map<String, dynamic>) entityStateFactory,
}) {
  // Check if the change log entry is a duplicate
  final duplicateCheck = getMaybeIsDuplicateCidResult(
    changeLogEntry,
    entityState,
  );

  if (duplicateCheck.isDuplicate) {
    // If it's a duplicate, update cloudAt if available
    changeLogEntry.cloudAt = duplicateCheck.cloudAt;
    return;
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

  final newChangeLogEntryJson = {
    ...changeLogEntry.toJson(),
    'operation': operation,
    'operationInfo': {'outdatedBys': outdatedBys, 'noOpFields': noOpFields},
    'stateChanged': operation != 'noOp' && operation != 'outdated',
    'data': changeDataUpdates,
    'cloudAt': changeLogEntry.cloudAt,
  };

  final newChangeLogEntry = changeLogEntryFactory != null
      ? changeLogEntryFactory(newChangeLogEntryJson)
      : throw Exception(
          'changeLogEntryFactory is required for creating new ChangeLogEntry instances',
        );

  // Update the entity state if necessary
  return LastWriteWinsResult(
    newChangeLogEntry: newChangeLogEntry,
    newEntityState: operation != 'noOp' && operation != 'outdated'
        ? forkWithStateUpdates(
            entityState,
            stateUpdates,
            entityStateFactory,
            changeLogEntry: changeLogEntry,
          )
        : null,
  );
}

BaseEntityState forkWithStateUpdates(
  BaseEntityState? sourceEntityState,
  Map<String, dynamic> stateUpdates,
  BaseEntityState Function(Map<String, dynamic>) entityStateFactory, {
  BaseChangeLogEntry? changeLogEntry,
}) {
  Map<String, dynamic> clone;

  if (sourceEntityState != null) {
    clone = sourceEntityState.toJson();
  } else if (changeLogEntry != null) {
    // Create a new entity state from the change log entry
    clone = {
      'entityId': changeLogEntry.entityId,
      'entityType': changeLogEntry.entityType.toString().split('.').last,
      'change_domainId': changeLogEntry.domainId,
      'change_domainId_orig_': changeLogEntry.domainId,
      'change_changeAt': changeLogEntry.changeAt.toIso8601String(),
      'change_changeAt_orig_': changeLogEntry.changeAt.toIso8601String(),
      'change_cid': changeLogEntry.cid,
      'change_cid_orig_': changeLogEntry.cid,
      'change_changeBy': changeLogEntry.changeBy,
      'change_changeBy_orig_': changeLogEntry.changeBy,
      'change_dataSchemaRev': changeLogEntry.dataSchemaRev,
      'change_cloudAt': changeLogEntry.cloudAt?.toIso8601String(),
      'change_cloudAt_orig_': changeLogEntry.cloudAt?.toIso8601String(),
    };

    // Add required data fields from the change log entry data
    for (final entry in changeLogEntry.data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (!key.startsWith('_') && key != 'deleted') {
        // Add the data field and its metadata
        clone['data_$key'] = value;
        clone['data_${key}_dataSchemaRev'] = changeLogEntry.dataSchemaRev ?? 1;
        clone['data_${key}_changeAt_'] = changeLogEntry.changeAt
            .toIso8601String();
        clone['data_${key}_cid_'] = changeLogEntry.cid;
        clone['data_${key}_changeBy_'] = changeLogEntry.changeBy;
        if (changeLogEntry.cloudAt != null) {
          clone['data_${key}_cloudAt_'] = changeLogEntry.cloudAt!
              .toIso8601String();
        }
      }
    }
  } else {
    clone = {};
  }

  final newJson = {...clone, ...stateUpdates};

  // Ensure unknown field is always a Map for deserialization
  if (!newJson.containsKey('unknown') || newJson['unknown'] == null) {
    newJson['unknown'] = <String, dynamic>{};
  }

  // Remove null values that the generated fromJson can't handle
  newJson.removeWhere((key, value) => value == null && key != 'unknown');

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
    cloudAt = changeLogEntry.cloudAt;
  }

  if (!isDuplicate) {
    // Check if any field in the entity state matches the change log entry cid
    for (final key in entryState.keys) {
      if (key.endsWith('_cid_') && entryState[key] == changeLogCid) {
        isDuplicate = true;
        cloudAt = changeLogEntry.cloudAt;
        break;
      }
    }
  }

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

  if (entityState != null) {
    // Access entity state properties directly for latest metadata check
    final existingChangeAt = entityState.change_changeAt;

    final existingData = entityState.toJson();

    bool isChangeNewerThanLatest = false;

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
            'data_$field'; // Change log has 'rank', entity has 'data_rank'
        final existingFieldChangeAtData =
            existingData['${entityFieldKey}_changeAt_'];
        final existingFieldChangeAt = existingFieldChangeAtData is DateTime
            ? existingFieldChangeAtData
            : (existingFieldChangeAtData is String
                  ? DateTime.tryParse(existingFieldChangeAtData)
                  : null);

        if (changeLogEntry.changeAt.isAfter(
          existingFieldChangeAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        )) {
          fieldUpdates[field] = value;
        } else {
          outdatedBys.add(field);
        }
      });
    }
  } else {
    // No entity state, treat all as updates
    fieldUpdates.addAll(fieldChanges);
  }

  return {
    'stateUpdates': {
      // Transform field updates to use data_ prefix for entity state
      ...fieldUpdates.map((key, value) => MapEntry('data_$key', value)),
      // Field-specific metadata
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
      // latest metadata
      if (fieldUpdates.isNotEmpty) ...{
        'change_changeAt': changeLogEntry.changeAt.toIso8601String(),
        'change_cid': changeLogEntry.cid,
        'change_changeBy': changeLogEntry.changeBy,
        'change_cloudAt': changeLogEntry.cloudAt?.toIso8601String(),
      },
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
