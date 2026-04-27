import 'package:aws_backend/src/models/dynamo_change_log_entry.dart';
import 'package:sltt_core/sltt_core.dart';

import 'auth_models.dart';

class AuthAppStateStore {
  AuthAppStateStore({required BaseStorageService storage}) : _storage = storage;

  final BaseStorageService _storage;
  static const String _authSourceStorageId = 'auth-backend';

  Future<void> upsertVerifiedUserProfile({
    required AuthPrincipal principal,
    required String changeBy,
  }) async {
    await _storeProfileChange(
      principal: principal,
      changeBy: changeBy,
      deleted: false,
    );
  }

  Future<void> applyProjectAssignmentChanges({
    required AuthPrincipal principal,
    required Iterable<String> projectIdsToAdd,
    required Iterable<String> projectIdsToRemove,
    required String changeBy,
  }) async {
    final addSet = _normalizeProjectIds(projectIdsToAdd);
    final removeSet = _normalizeProjectIds(projectIdsToRemove)
      ..removeAll(addSet);

    final changes = <Map<String, dynamic>>[];
    for (final projectId in addSet) {
      changes.add(
        _buildChangeJson(
          domainType: kDomainMembership,
          domainId: projectId,
          entityType: kEntityTypeMember,
          entityId: principal.userId,
          parentProp: kCollectionMembership,
          parentId: kDomainEntityRootParentId,
          changeBy: changeBy,
          deleted: false,
          customFields: {
            'userId': principal.userId,
            'role': 'translator',
            'name': principal.displayName,
            'username': principal.username,
            'email': principal.email,
            'isAdHoc': principal.isAdHoc,
            'emailVerified': principal.emailVerified,
          },
        ),
      );
    }
    for (final projectId in removeSet) {
      changes.add(
        _buildChangeJson(
          domainType: kDomainMembership,
          domainId: projectId,
          entityType: kEntityTypeMember,
          entityId: principal.userId,
          parentProp: kCollectionMembership,
          parentId: kDomainEntityRootParentId,
          changeBy: changeBy,
          deleted: true,
          customFields: {
            'userId': principal.userId,
            'role': 'translator',
            'name': principal.displayName,
            'username': principal.username,
            'email': principal.email,
            'isAdHoc': principal.isAdHoc,
            'emailVerified': principal.emailVerified,
          },
        ),
      );
    }

    await _storeProjectMemberChanges(changes);
  }

  Future<void> markUserDeleted({
    required AuthPrincipal principal,
    required String changeBy,
  }) async {
    await _storeProfileChange(
      principal: principal,
      changeBy: changeBy,
      deleted: true,
    );
    await applyProjectAssignmentChanges(
      principal: principal,
      projectIdsToAdd: const <String>[],
      projectIdsToRemove: principal.assignedProjectIds,
      changeBy: changeBy,
    );
  }

  Future<List<String>> getAdminProjectIdsForUser(String userId) async {
    // TODO: detect super admin role?
    // TODO: use getCrossDomainEntityStates
    final projectIds = await _storage.getAllDomainIds(
      domainType: kDomainMembership,
    );
    final adminProjects = <String>[];
    for (final projectId in projectIds) {
      final state = await _storage.getEntityState(
        domainType: kDomainMembership,
        domainId: projectId,
        entityType: kEntityTypeMember,
        entityId: userId,
      );
      if (state == null) {
        continue;
      }
      final json = state.toJson();
      final role =
          (json['role'] as String? ?? json['data_role'] as String? ?? '')
              .trim()
              .toLowerCase();
      final deleted = json['data_deleted'] as bool? ?? false;
      if (!deleted && (role == MemberType.admin.name)) {
        adminProjects.add(projectId);
      }
    }
    return adminProjects;
  }

  Future<void> _storeProfileChange({
    required AuthPrincipal principal,
    required String changeBy,
    required bool deleted,
  }) async {
    final result = await ChangeProcessingService.storeChanges(
      storageMode: 'save',
      changes: <Map<String, dynamic>>[
        _buildChangeJson(
          domainType: kDomainUser,
          domainId: principal.userId,
          entityType: kEntityTypeUserProfile,
          entityId: principal.userId,
          parentProp: kEntityTypeUserProfileCollection,
          parentId: kDomainEntityRootParentId,
          changeBy: changeBy,
          deleted: deleted,
          customFields: {
            'name': principal.displayName,
            'email': principal.email,
            'username': principal.username,
            'dateOfBirth': principal.dateOfBirth,
            'isAdHoc': principal.isAdHoc,
            'emailVerified': principal.emailVerified,
            'identityKind': principal.identityKind.value,
          },
        ),
      ],
      srcStorageType: 'local',
      srcStorageId: _authSourceStorageId,
      storage: _storage,
      includeChangeUpdates: false,
      includeStateUpdates: false,
    );
    if (!result.isSuccess) {
      throw StateError(result.errorMessage ?? 'Failed to store auth profile');
    }
  }

  Future<void> _storeProjectMemberChanges(
    List<Map<String, dynamic>> changes,
  ) async {
    if (changes.isEmpty) {
      return;
    }

    final result = await ChangeProcessingService.storeChanges(
      storageMode: 'save',
      changes: changes,
      srcStorageType: 'local',
      srcStorageId: _authSourceStorageId,
      storage: _storage,
      includeChangeUpdates: false,
      includeStateUpdates: false,
    );
    if (!result.isSuccess) {
      throw StateError(
        result.errorMessage ?? 'Failed to store auth project membership',
      );
    }
  }

  Set<String> _normalizeProjectIds(Iterable<String> projectIds) {
    return projectIds
        .map((projectId) => projectId.trim())
        .where((projectId) => projectId.isNotEmpty)
        .toSet();
  }

  Map<String, dynamic> _buildChangeJson({
    required String domainType,
    required String domainId,
    required String entityId,
    required String entityType,
    required String parentProp,
    required String parentId,
    required String changeBy,
    required Map<String, dynamic> customFields,
    bool deleted = false,
  }) {
    final now = DateTime.now().toUtc();
    final entity = EntityType.tryFromString(entityType) ?? EntityType.unknown;
    final data = <String, dynamic>{
      'parentId': parentId,
      'parentProp': parentProp,
      'deleted': deleted,
      ...customFields,
    }..removeWhere((key, value) => value == null);

    return DynamoChangeLogEntry(
      cid: generateCid(entityType: entity, userId: changeBy),
      storageId: '',
      domainType: domainType,
      domainId: domainId,
      entityType: entityType,
      operation: deleted
          ? kChangeOperationDelete
          : kChangeOperationNotYetDefined,
      stateChanged: false,
      changeAt: now,
      entityId: entityId,
      dataJson: stableStringify(data),
      changeBy: changeBy,
      unknownJson: '{}',
      operationInfoJson: '{}',
    ).toJson();
  }
}
