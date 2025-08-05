import '../models/base_change_log_entry.dart';
import '../storage/base_storage_service.dart';
import 'change_analysis_service.dart' show hasValueChanged;
import 'field_change_detector.dart';

/// Shared service for field-level change detection that can work with any storage backend.
/// This encapsulates the business logic for detecting field-level changes and determining
/// whether a change is a no-op, reducing the implementation burden on storage services.
///
/// Note: This service now uses the shared hasValueChanged utility from change_analysis_service
/// to avoid code duplication across different change detection implementations.
class ChangeDetectionService {
  /// Performs field-level change detection for a batch of changes.
  ///
  /// This method handles the core business logic:
  /// - CID generation for changes that don't have one
  /// - Field-level comparison for update operations
  /// - No-op detection when no fields actually changed
  /// - Optimization of change data to only include modified fields
  ///
  /// Storage implementations only need to provide:
  /// - createChange() method for actually storing changes
  /// - getCurrentEntityState() method for retrieving current entity data
  static Future<CreateChangesResult> processChangesWithDetection(
    List<Map<String, dynamic>> changesData,
    BaseStorageService storage, {
    required Future<ChangeLogEntry?> Function(
      String projectId,
      String entityType,
      String entityId,
    )
    getCurrentEntityState,
  }) async {
    final createdChanges = <ChangeLogEntry>[];
    final noOpChangeCids = <String>[];
    final changeDetails = <String, FieldChangeResult>{};

    for (final changeData in changesData) {
      final projectId = changeData['projectId'] as String;
      final entityType = changeData['entityType'] as String;
      final entityId = changeData['entityId'] as String;
      final operation = changeData['operation'] as String? ?? 'create';
      final incomingData = changeData['data'] as Map<String, dynamic>? ?? {};

      // Generate CID for this change if not provided
      final cid =
          changeData['cid'] as String? ?? BaseChangeLogEntry.generateCid();

      // For create operations, always create the change
      if (operation == 'create') {
        final changeDataWithCid = Map<String, dynamic>.from(changeData);
        changeDataWithCid['cid'] = cid;

        final change = await storage.createChange(changeDataWithCid);
        createdChanges.add(change);
        changeDetails[cid] = FieldChangeResult(
          updatedFields: incomingData.keys.toList(),
          noOpFields: [],
          totalFields: incomingData.keys.length,
        );
        continue;
      }

      // For update operations, perform field-level change detection
      if (operation == 'update') {
        try {
          // Get the current state of the entity
          final currentState = await getCurrentEntityState(
            projectId,
            entityType,
            entityId,
          );

          if (currentState == null) {
            // Entity doesn't exist yet, treat as create
            final changeDataWithCid = Map<String, dynamic>.from(changeData);
            changeDataWithCid['cid'] = cid;

            final change = await storage.createChange(changeDataWithCid);
            createdChanges.add(change);
            changeDetails[cid] = FieldChangeResult(
              updatedFields: incomingData.keys.toList(),
              noOpFields: [],
              totalFields: incomingData.keys.length,
            );
            continue;
          }

          // Perform field-level change detection
          final currentData = currentState.data;
          final updatedFields = <String>[];
          final noOpFields = <String>[];

          for (final entry in incomingData.entries) {
            final fieldName = entry.key;
            final incomingValue = entry.value;
            final currentValue = currentData[fieldName];

            if (hasValueChanged(currentValue, incomingValue)) {
              updatedFields.add(fieldName);
            } else {
              noOpFields.add(fieldName);
            }
          }

          final result = FieldChangeResult(
            updatedFields: updatedFields,
            noOpFields: noOpFields,
            totalFields: incomingData.keys.length,
          );

          changeDetails[cid] = result;

          if (result.hasUpdates) {
            // Create the change - only include fields that actually changed
            final optimizedData = <String, dynamic>{};
            for (final field in updatedFields) {
              optimizedData[field] = incomingData[field];
            }

            final optimizedChangeData = Map<String, dynamic>.from(changeData);
            optimizedChangeData['data'] = optimizedData;
            optimizedChangeData['cid'] = cid;

            final change = await storage.createChange(optimizedChangeData);
            createdChanges.add(change);
          } else {
            // No-op change - track the CID but don't create the change
            noOpChangeCids.add(cid);
          }
          continue;
        } catch (e) {
          // Re-throw with more context
          throw ArgumentError(
            'Field-level change detection failed for $operation on $entityType:$entityId in project $projectId: $e',
          );
        }
      }

      // For delete operations, always create the change
      final changeDataWithCid = Map<String, dynamic>.from(changeData);
      changeDataWithCid['cid'] = cid;

      final change = await storage.createChange(changeDataWithCid);
      createdChanges.add(change);
      changeDetails[cid] = FieldChangeResult(
        updatedFields: incomingData.keys.toList(),
        noOpFields: [],
        totalFields: incomingData.keys.length,
      );
    }

    return CreateChangesResult(
      createdChanges: createdChanges,
      noOpChangeCids: noOpChangeCids,
      changeDetails: changeDetails,
    );
  }
}
