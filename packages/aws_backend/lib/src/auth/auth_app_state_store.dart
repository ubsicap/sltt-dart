import 'package:aws_backend/src/models/dynamo_entity_state.dart';
import 'package:sltt_core/sltt_core.dart';

import 'auth_models.dart';

class AuthAppStateStore {
  AuthAppStateStore({required BaseStorageService storage}) : _storage = storage;

  final BaseStorageService _storage;

  Future<void> upsertVerifiedUser(AuthPrincipal principal) async {
    final now = DateTime.now().toUtc();
    await _storage.testStoreState(
      entityState: _buildState(
        entityType: kEntityTypeUser,
        domainType: 'user',
        domainId: principal.userId,
        entityId: principal.userId,
        parentProp: kEntityTypeUserCollection,
        changeBy: 'auth-system',
        now: now,
        customFields: {
          'status': principal.accountStatus.value,
          'isAdHoc': principal.isAdHoc,
          'identityKind': principal.identityKind.value,
          'username': principal.username,
          'emailVerified': principal.emailVerified,
        },
      ),
    );

    await _storage.testStoreState(
      entityState: _buildState(
        entityType: kEntityTypeUserProfile,
        domainType: 'user',
        domainId: principal.userId,
        entityId: 'default',
        parentProp: kEntityTypeUserProfileCollection,
        changeBy: 'auth-system',
        now: now,
        customFields: {
          'name': principal.displayName,
          'email': principal.email,
          'username': principal.username,
          'dateOfBirth': principal.dateOfBirth,
          'isAdHoc': principal.isAdHoc,
          'status': principal.accountStatus.value,
        },
      ),
    );
  }

  Future<void> syncProjectAssignments({
    required AuthPrincipal principal,
    required List<String> previousProjectIds,
  }) async {
    final now = DateTime.now().toUtc();
    final previous = previousProjectIds.toSet();
    final current = principal.assignedProjectIds.toSet();
    for (final projectId in current) {
      await _storage.testStoreState(
        entityState: _buildState(
          entityType: kEntityTypeMember,
          domainType: 'project',
          domainId: projectId,
          entityId: principal.userId,
          parentProp: kEntityTypeMemberCollection,
          changeBy: 'auth-system',
          now: now,
          customFields: {
            'userId': principal.userId,
            'role': 'translator',
            'name': principal.displayName,
            'username': principal.username,
            'email': principal.email,
            'isAdHoc': principal.isAdHoc,
            'status': principal.accountStatus.value,
          },
        ),
      );
    }
    for (final removedProjectId in previous.difference(current)) {
      await _storage.testStoreState(
        entityState: _buildState(
          entityType: kEntityTypeMember,
          domainType: 'project',
          domainId: removedProjectId,
          entityId: principal.userId,
          parentProp: kEntityTypeMemberCollection,
          changeBy: 'auth-system',
          now: now,
          deleted: true,
          customFields: {
            'userId': principal.userId,
            'role': 'translator',
            'name': principal.displayName,
            'username': principal.username,
            'email': principal.email,
            'isAdHoc': principal.isAdHoc,
            'status': 'deleted',
          },
        ),
      );
    }
  }

  Future<void> markUserDeleted(AuthPrincipal principal) async {
    final now = DateTime.now().toUtc();
    await _storage.testStoreState(
      entityState: _buildState(
        entityType: kEntityTypeUser,
        domainType: 'user',
        domainId: principal.userId,
        entityId: principal.userId,
        parentProp: kEntityTypeUserCollection,
        changeBy: 'auth-system',
        now: now,
        deleted: true,
        customFields: {
          'status': 'deleted',
          'isAdHoc': principal.isAdHoc,
          'identityKind': principal.identityKind.value,
        },
      ),
    );
    await _storage.testStoreState(
      entityState: _buildState(
        entityType: kEntityTypeUserProfile,
        domainType: 'user',
        domainId: principal.userId,
        entityId: 'default',
        parentProp: kEntityTypeUserProfileCollection,
        changeBy: 'auth-system',
        now: now,
        deleted: true,
        customFields: {
          'name': principal.displayName,
          'email': principal.email,
          'username': principal.username,
          'dateOfBirth': principal.dateOfBirth,
          'status': 'deleted',
          'isAdHoc': principal.isAdHoc,
        },
      ),
    );
    await syncProjectAssignments(
      principal: principal.copyWith(assignedProjectIds: const <String>[]),
      previousProjectIds: principal.assignedProjectIds,
    );
  }

  Future<List<String>> getAdminProjectIdsForUser(String userId) async {
    final projectIds = await _storage.getAllDomainIds(domainType: 'project');
    final adminProjects = <String>[];
    for (final projectId in projectIds) {
      final state = await _storage.getEntityState(
        domainType: 'project',
        domainId: projectId,
        entityType: kEntityTypeMember,
        entityId: userId,
      );
      if (state == null) {
        continue;
      }
      final json = state.toJson();
      final role = (json['role'] as String? ?? '').trim().toLowerCase();
      final deleted = json['data_deleted'] as bool? ?? false;
      if (!deleted && (role == 'admin' || role == 'superadmin' || role == 'super_admin')) {
        adminProjects.add(projectId);
      }
    }
    return adminProjects;
  }

  DynamoEntityState _buildState({
    required String entityType,
    required String domainType,
    required String domainId,
    required String entityId,
    required String parentProp,
    required String changeBy,
    required DateTime now,
    required Map<String, dynamic> customFields,
    bool deleted = false,
  }) {
    return DynamoEntityState.fromJson({
      'entityId': entityId,
      'entityType': entityType,
      'domainType': domainType,
      'unknownJson': '{}',
      'change_domainId': domainId,
      'change_domainId_orig_': domainId,
      'change_changeAt': now.toIso8601String(),
      'change_changeAt_orig_': now.toIso8601String(),
      'change_cid': 'auth-${now.microsecondsSinceEpoch}',
      'change_cid_orig_': 'auth-${now.microsecondsSinceEpoch}',
      'change_changeBy': changeBy,
      'change_changeBy_orig_': changeBy,
      'change_storedAt': now.toIso8601String(),
      'change_storedAt_orig_': now.toIso8601String(),
      'data_parentId': '',
      'data_parentId_changeAt_': now.toIso8601String(),
      'data_parentId_cid_': 'auth-${now.microsecondsSinceEpoch}',
      'data_parentId_changeBy_': changeBy,
      'data_parentProp': parentProp,
      'data_parentProp_changeAt_': now.toIso8601String(),
      'data_parentProp_cid_': 'auth-${now.microsecondsSinceEpoch}',
      'data_parentProp_changeBy_': changeBy,
      'data_deleted': deleted,
      'data_deleted_changeAt_': now.toIso8601String(),
      'data_deleted_cid_': 'auth-${now.microsecondsSinceEpoch}',
      'data_deleted_changeBy_': changeBy,
      ...customFields,
    });
  }
}
