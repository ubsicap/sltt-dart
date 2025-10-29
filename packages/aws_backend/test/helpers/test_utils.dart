import 'package:http/http.dart' as http;

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
    baseUrl.replace(path: '/api/storage/__test/reset/$domainType/$projectId'),
  );
}
