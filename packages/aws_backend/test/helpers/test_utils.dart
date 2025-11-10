import 'dart:convert';

import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:http/http.dart' as http;
import 'package:sltt_core/sltt_core.dart';

/// Helper function to reset/delete a test project domain.
///
/// This calls the `/api/storage/__test/reset/{domainType}/{domainId}` endpoint
/// to delete all data for a test domain. The endpoint only allows deletion of
/// domains with IDs starting with `__test`.
///
/// Example:
/// ```dart
/// await resetTestProject(baseUrl, '__test_my_project__');
/// ```
Future<void> resetTestProject(
  Uri baseUrl,
  String projectId, {
  String domainType = 'projects',
}) async {
  await http.delete(
    Uri.parse('$baseUrl/api/storage/__test/reset/$domainType/$projectId'),
  );
}

/// Helper function to save a project change to the API.
///
/// Creates and posts a change log entry for a project entity to the
/// `/api/changes` endpoint.
///
/// Parameters:
/// - [baseUrl]: The base URL of the API server
/// - [projectId]: The project domain ID (should start with `__test` for tests)
/// - [projectData]: Optional project data fields (defaults to basic test data)
/// - [changeBy]: The user making the change (defaults to 'userId')
/// - [srcStorageType]: Source storage type (defaults to 'cloud')
/// - [srcStorageId]: Source storage ID (defaults to 'test')
///
/// Returns the HTTP response from the POST request.
///
/// Example:
/// ```dart
/// final response = await saveProjectChange(
///   baseUrl,
///   '__test_my_project__',
/// );
/// expect(response.statusCode, anyOf([200, 201]));
/// ```
Future<http.Response> saveProjectChange(
  Uri baseUrl,
  String projectId, {
  BaseDataFields? projectData,
  String changeBy = 'userId',
  String srcStorageType = 'cloud',
  String srcStorageId = 'test',
}) async {
  final data =
      projectData ??
      BaseDataFields(parentId: 'parentId', parentProp: 'parentProp');

  return saveChanges<BaseDataFields>(
    baseUrl,
    domainType: 'project',
    domainId: projectId,
    entityType: 'project',
    entityId: projectId,
    changesToSave: [data],
    changeBy: changeBy,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
  );
}

/// Generic helper function to save any entity change to the API.
///
/// Creates and posts a change log entry to the `/api/changes` endpoint.
///
/// Parameters:
/// - [baseUrl]: The base URL of the API server
/// - [domainType]: The domain type (e.g., 'project')
/// - [domainId]: The domain ID (should start with `__test` for tests)
/// - [entityType]: The entity type (e.g., 'portion', 'document')
/// - [entityId]: The entity ID
/// - [data]: The entity data fields
/// - [changeBy]: The user making the change (defaults to 'userId')
/// - [srcStorageType]: Source storage type (defaults to 'cloud')
/// - [srcStorageId]: Source storage ID (defaults to 'test')
///
/// Returns the HTTP response from the POST request.
///
/// Example:
/// ```dart
/// final response = await saveChange<PortionDataFields>(
///   baseUrl,
///   domainType: 'project',
///   domainId: '__test_project__',
///   entityType: 'portion',
///   entityId: 'portion-1',
///   data: PortionDataFields(name: 'Test', parentId: 'root', parentProp: 'portions'),
/// );
/// expect(response.statusCode, anyOf([200, 201]));
/// ```
Future<http.Response> saveChanges<TData extends BaseDataFields>(
  Uri baseUrl, {
  required String domainType,
  required String domainId,
  required String entityType,
  required String entityId,
  required List<TData> changesToSave,
  String changeBy = 'userId',
  String srcStorageType = 'cloud',
  String srcStorageId = 'test',
}) async {
  final changes = changesToSave
      .map(
        (TData data) =>
            ChangeLogEntryFactoryService.forChangeSave<
              DynamoChangeLogEntry,
              int,
              TData
            >(
              factory: DynamoChangeLogEntry.new,
              domainType: domainType,
              domainId: domainId,
              entityType: entityType,
              entityId: entityId,
              changeBy: changeBy,
              data: data,
            ),
      )
      .toList();

  final request = CreateChangesRequest(
    changes: changes,
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
    storageMode: 'save',
  );

  final payload = jsonEncode(request.toJson());

  return http.post(
    Uri.parse('$baseUrl/api/changes'),
    body: payload,
    headers: {'Content-Type': 'application/json'},
  );
}
