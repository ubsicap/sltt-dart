import 'dart:convert';

import 'package:sltt_core/src/models/base_change_log_entry.dart';
import 'package:sltt_core/src/models/base_entity_state.dart';

/// Result type for getMaybeIsduplicateCid
class GetMaybeIsDuplicateCidResult {
  final bool isDuplicate;
  final DateTime? cloudAt;

  GetMaybeIsDuplicateCidResult({required this.isDuplicate, this.cloudAt});
}

/// getMaybeIsduplicateCid(changeLogEntry: ChangeLogEntry, baseEntityState: BaseEntityState):
/// Checks if the given change log entry is a duplicate based on its cid.
///
/// @returns { isDuplicate: boolean, cloudAt?: DateTime }
GetMaybeIsDuplicateCidResult getMaybeIsDuplicateCidResult(
  ChangeLogEntry changeLogEntry,
  BaseEntityState baseEntityState,
) {
  // Implement the logic to check for duplicate cid
  bool isDuplicate = false;
  DateTime? cloudAt;

  if (baseEntityState.cid == changeLogEntry.cid) {
    // If the base entity state cid matches the change log entry cid, it's a duplicate
    isDuplicate = true;
    cloudAt = baseEntityState.cloudAt;
  }

  return GetMaybeIsDuplicateCidResult(
    isDuplicate: isDuplicate,
    cloudAt: cloudAt,
  );
}

/// calculateOperation(changeLogEntry: ChangeLogEntry, baseEntityState: BaseEntityState):
/// returns { operation: string } 'noOp', 'outdated', 'create', 'update', or 'delete'
/// Determines the operation type based on the change log entry and current entity state.
String calculateOperation(
  ChangeLogEntry changeLogEntry,
  BaseEntityState? baseEntityState,
  Map<String, dynamic> fieldChanges, // Map of field changes
  List<String> noOpFields, // List of fields that are no-ops
  List<String> outdatedBys, // List of fields that are outdated
) {
  final changeData = changeLogEntry.getData();

  // If the base entity state is null, we assume it's a create operation
  if (baseEntityState == null) {
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

/// getFieldChangesOrNoOps(changeLogEntry: ChangeLogEntry, baseEntityState: BaseEntityState):
/// returns { fieldChanges: Map<String, dynamic>, noOpFields: List<String> }
Map<String, dynamic> getFieldChangesOrNoOps(
  ChangeLogEntry changeLogEntry,
  BaseEntityState? baseEntityState,
) {
  final changeData = changeLogEntry.getData();
  final fieldChanges = <String, dynamic>{};
  final noOpFields = <String>[];
  final incomingData = changeData['data'] as Map<String, dynamic>;

  if (baseEntityState != null) {
    final existingData = baseEntityState.toJson();

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

  return {'fieldChanges': fieldChanges, 'noOpFields': noOpFields};
}

/// fieldUpdatesOrOutdatedBys(changeLogEntry: ChangeLogEntry, baseEntityState: BaseEntityState, fieldChanges):
/// returns { fieldUpdates: Map<String, dynamic>, outdatedBys: List<String> }
Map<String, dynamic> fieldUpdatesOrOutdatedBys(
  ChangeLogEntry changeLogEntry,
  BaseEntityState? baseEntityState,
  Map<String, dynamic> fieldChanges,
  List<String> noOpFields, // List of fields that are no-ops
) {
  final fieldUpdates = <String, dynamic>{};
  final outdatedBys = <String>[];

  if (baseEntityState != null) {
    final existingData = baseEntityState.toJson();

    fieldChanges.forEach((field, value) {
      final existingFieldChangeAt =
          existingData['${field}ChangeAt'] as DateTime?;
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
    'fieldUpdates': fieldUpdates,
    'outdatedBys': outdatedBys,
    'operation': calculateOperation(
      changeLogEntry,
      baseEntityState,
      fieldChanges,
      noOpFields,
      outdatedBys,
    ),
  };
}
