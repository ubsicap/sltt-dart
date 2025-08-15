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
  BaseChangeLogEntry Function(Map<String, dynamic>)? changeLogEntryFactory,
  BaseEntityState Function(Map<String, dynamic>)? entityStateFactory,
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
        ? forkWithStateUpdates(entityState, stateUpdates, entityStateFactory)
        : null,
  );
}

BaseEntityState forkWithStateUpdates(
  BaseEntityState? sourceEntityState,
  Map<String, dynamic> stateUpdates,
  BaseEntityState Function(Map<String, dynamic>)? entityStateFactory,
) {
  final clone = sourceEntityState?.toJson() ?? {};
  final newJson = {...clone, ...stateUpdates};

  if (entityStateFactory != null) {
    return entityStateFactory(newJson);
  } else {
    throw Exception(
      'entityStateFactory is required for creating new EntityState instances',
    );
  }
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
  final changeLogData = changeLogEntry.data;
  final changeLogCid = changeLogEntry.cid;

  // Check if any field in the entity state matches the change log entry cid
  for (final key in changeLogData.keys) {
    if (key.endsWith('_cid_') && entryState[key] == changeLogCid) {
      isDuplicate = true;
      cloudAt = changeLogEntry.cloudAt;
      break;
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

  // If there are no field changes, it's a no-op
  if (fieldChanges.isEmpty && noOpFields.isNotEmpty) {
    return 'noOp';
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
      if (stableStringify(existingData[field]) != stableStringify(value)) {
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
    final existingData = entityState.toJson();

    fieldChanges.forEach((field, value) {
      final existingFieldChangeAt =
          existingData['${field}_changeAt_'] as DateTime?;
      if (changeLogEntry.changeAt.isAfter(
        existingFieldChangeAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      )) {
        fieldUpdates[field] = value;
      } else {
        outdatedBys.add(field);
      }
    });
  }

  return {
    'stateUpdates': {
      ...fieldUpdates,
      ...fieldUpdates.map(
        (key, value) => MapEntry('${key}ChangeAt', changeLogEntry.changeAt),
      ),
      ...fieldUpdates.map(
        (key, value) => MapEntry('${key}Cid', changeLogEntry.cid),
      ),
      ...fieldUpdates.map(
        (key, value) => MapEntry('${key}ChangeBy', changeLogEntry.changeBy),
      ),
      ...fieldUpdates.map(
        (key, value) => MapEntry('${key}CloudAt', changeLogEntry.cloudAt),
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
