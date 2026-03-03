import 'dart:async';
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
/// await resetTestDomainData(baseUrl, '__test_my_project__');
/// ```
Future<void> resetTestDomainData(
  Uri baseUrl,
  String domainId, {
  String domainType = 'projects',
}) async {
  try {
    final uri = Uri.parse(
      '$baseUrl/api/storage/__test/reset/$domainType/$domainId',
    );
    final res = await http.delete(uri).timeout(const Duration(seconds: 15));

    // If server returned a non-success status, throw to make the failure
    // visible immediately instead of letting the test hang or proceed.
    if (res.statusCode >= 400) {
      throw Exception(
        'resetTestDomainData failed: ${res.statusCode} ${res.body}',
      );
    }
  } on TimeoutException catch (e) {
    throw Exception(
      'resetTestDomainData timed out calling ${baseUrl.toString()}: $e',
    );
  }
}

/// Helper function to save a project change to the API.
///
/// Creates and posts a change log entry for a project entity to the
/// `/api/changes` endpoint.
///
/// Parameters:
/// - [baseUrl]: The base URL of the API server
/// - [domainId]: The project domain ID (should start with `__test` for tests)
/// - [entityData]: Optional project data fields (defaults to basic test data)
/// - [changeBy]: The user making the change (defaults to 'userId')
/// - [srcStorageType]: Source storage type (defaults to 'cloud')
/// - [srcStorageId]: Source storage ID (defaults to 'test')
///
/// Returns the HTTP response from the POST request.
///
/// Example:
/// ```dart
/// final response = await saveDomainChange(
///   baseUrl,
///   '__test_my_project__',
/// );
/// expect(response.statusCode, anyOf([200, 201]));
/// ```
Future<http.Response> saveDomainChange(
  Uri baseUrl,
  String domainId, {
  BaseDataFields? entityData,
  String changeBy = 'userId',
  String srcStorageType = 'cloud',
  String srcStorageId = 'test',
  DomainType domainType = DomainType.project,
  EntityType entityType = EntityType.project,
}) async {
  final data =
      entityData ??
      BaseDataFields(parentId: 'parentId', parentProp: 'parentProp');

  return saveChanges<BaseDataFields>(
    baseUrl,
    domainType: domainType.value,
    domainId: domainId,
    changesToSave: [
      SaveChangeRequest<BaseDataFields>(
        entityType: entityType.value,
        entityId: domainId,
        data: data,
        changeBy: changeBy,
      ),
    ],
    srcStorageType: srcStorageType,
    srcStorageId: srcStorageId,
  );
}

class SaveChangeRequest<TData extends BaseDataFields> {
  final String entityType;
  final String entityId;
  final TData data;
  final String changeBy;

  SaveChangeRequest({
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.changeBy,
  });
}

/// Generic helper function to save any entity change to the API.
///
/// Creates and posts a change log entry to the `/api/changes` endpoint.
///
/// Parameters:
/// - [baseUrl]: The base URL of the API server
/// - [domainType]: The domain type (e.g., 'project')
/// - [domainId]: The domain ID (should start with `__test` for tests)
/// - [changesToSave]: List of changes to save as [SaveChangeRequest] objects
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
  required List<SaveChangeRequest<TData>> changesToSave,
  String srcStorageType = 'cloud',
  String srcStorageId = 'test',
}) async {
  final changes = changesToSave
      .map(
        (req) =>
            ChangeLogEntryFactoryService.forChangeSave<
              DynamoChangeLogEntry,
              int,
              TData
            >(
              factory: DynamoChangeLogEntry.new,
              domainType: domainType,
              domainId: domainId,
              entityType: req.entityType,
              entityId: req.entityId,
              changeBy: req.changeBy,
              data: req.data,
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
