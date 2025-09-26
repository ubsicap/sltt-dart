// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateChangesRequest _$CreateChangesRequestFromJson(
  Map<String, dynamic> json,
) => CreateChangesRequest(
  changes: fromJsonChangeLogEntryList(json['changes'] as List),
  srcStorageType: json['srcStorageType'] as String,
  srcStorageId: json['srcStorageId'] as String,
  storageMode: json['storageMode'] as String?,
  includeChangeUpdates: json['includeChangeUpdates'] as bool? ?? false,
  includeStateUpdates: json['includeStateUpdates'] as bool? ?? false,
);

Map<String, dynamic> _$CreateChangesRequestToJson(
  CreateChangesRequest instance,
) => <String, dynamic>{
  'changes': toJsonChangeLogEntryList(instance.changes),
  'srcStorageType': instance.srcStorageType,
  'srcStorageId': instance.srcStorageId,
  'storageMode': instance.storageMode,
  'includeChangeUpdates': instance.includeChangeUpdates,
  'includeStateUpdates': instance.includeStateUpdates,
};

CreateChangesResponse _$CreateChangesResponseFromJson(
  Map<String, dynamic> json,
) => CreateChangesResponse(
  storageType: json['storageType'] as String?,
  storageId: json['storageId'] as String?,
  created: (json['created'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  updated: (json['updated'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  deleted: (json['deleted'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  noOps: (json['noOps'] as List<dynamic>?)?.map((e) => e as String).toList(),
  clouded: (json['clouded'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  dups: (json['dups'] as List<dynamic>?)?.map((e) => e as String).toList(),
  unknowns: (json['unknowns'] as List<dynamic>?)
      ?.map((e) => UnknownEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  info: (json['info'] as List<dynamic>?)
      ?.map((e) => ChangeInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  errors: (json['errors'] as List<dynamic>?)
      ?.map((e) => ChangeError.fromJson(e as Map<String, dynamic>))
      .toList(),
  changeUpdates: (json['changeUpdates'] as List<dynamic>?)
      ?.map((e) => ChangeUpdateItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  stateUpdates: (json['stateUpdates'] as List<dynamic>?)
      ?.map((e) => StateUpdateItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  timestamp: json['timestamp'] as String?,
);

Map<String, dynamic> _$CreateChangesResponseToJson(
  CreateChangesResponse instance,
) => <String, dynamic>{
  'storageType': instance.storageType,
  'storageId': instance.storageId,
  'created': instance.created,
  'updated': instance.updated,
  'deleted': instance.deleted,
  'noOps': instance.noOps,
  'clouded': instance.clouded,
  'dups': instance.dups,
  'unknowns': instance.unknowns?.map((e) => e.toJson()).toList(),
  'info': instance.info?.map((e) => e.toJson()).toList(),
  'errors': instance.errors?.map((e) => e.toJson()).toList(),
  'changeUpdates': instance.changeUpdates?.map((e) => e.toJson()).toList(),
  'stateUpdates': instance.stateUpdates?.map((e) => e.toJson()).toList(),
  'timestamp': instance.timestamp,
};

UnknownEntry _$UnknownEntryFromJson(Map<String, dynamic> json) => UnknownEntry(
  cid: json['cid'] as String,
  unknown: json['unknown'] as Map<String, dynamic>,
);

Map<String, dynamic> _$UnknownEntryToJson(UnknownEntry instance) =>
    <String, dynamic>{'cid': instance.cid, 'unknown': instance.unknown};

ChangeInfo _$ChangeInfoFromJson(Map<String, dynamic> json) => ChangeInfo(
  cid: json['cid'] as String,
  operation: json['operation'] as String?,
  info: json['info'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ChangeInfoToJson(ChangeInfo instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'operation': instance.operation,
      'info': instance.info,
    };

ChangeError _$ChangeErrorFromJson(Map<String, dynamic> json) => ChangeError(
  cid: json['cid'] as String,
  info: json['info'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ChangeErrorToJson(ChangeError instance) =>
    <String, dynamic>{'cid': instance.cid, 'info': instance.info};

ChangeUpdateItem _$ChangeUpdateItemFromJson(Map<String, dynamic> json) =>
    ChangeUpdateItem(
      cid: json['cid'] as String,
      updates: json['updates'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChangeUpdateItemToJson(ChangeUpdateItem instance) =>
    <String, dynamic>{'cid': instance.cid, 'updates': instance.updates};

StateUpdateItem _$StateUpdateItemFromJson(Map<String, dynamic> json) =>
    StateUpdateItem(
      cid: json['cid'] as String,
      state: json['state'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$StateUpdateItemToJson(StateUpdateItem instance) =>
    <String, dynamic>{'cid': instance.cid, 'state': instance.state};

ChangeObject _$ChangeObjectFromJson(Map<String, dynamic> json) => ChangeObject(
  seq: (json['seq'] as num?)?.toInt(),
  projectId: json['projectId'] as String?,
  entityType: json['entityType'] as String?,
  operation: json['operation'] as String?,
  entityId: json['entityId'] as String?,
  changeAt: json['changeAt'] as String?,
  dataJson: json['dataJson'] as Map<String, dynamic>?,
  cid: json['cid'] as String?,
);

Map<String, dynamic> _$ChangeObjectToJson(ChangeObject instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'projectId': instance.projectId,
      'entityType': instance.entityType,
      'operation': instance.operation,
      'entityId': instance.entityId,
      'changeAt': instance.changeAt,
      'dataJson': instance.dataJson,
      'cid': instance.cid,
    };

ChangesPageResponse _$ChangesPageResponseFromJson(Map<String, dynamic> json) =>
    ChangesPageResponse(
      changes: (json['changes'] as List<dynamic>)
          .map((e) => ChangeObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
      cursor: (json['cursor'] as num?)?.toInt(),
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$ChangesPageResponseToJson(
  ChangesPageResponse instance,
) => <String, dynamic>{
  'changes': instance.changes.map((e) => e.toJson()).toList(),
  'count': instance.count,
  'cursor': instance.cursor,
  'timestamp': instance.timestamp,
};

DomainListResponse _$DomainListResponseFromJson(Map<String, dynamic> json) =>
    DomainListResponse(
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
      count: (json['count'] as num).toInt(),
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$DomainListResponseToJson(DomainListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'count': instance.count,
      'timestamp': instance.timestamp,
    };

ProjectsResponse _$ProjectsResponseFromJson(Map<String, dynamic> json) =>
    ProjectsResponse(
      projects: (json['projects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      count: (json['count'] as num).toInt(),
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$ProjectsResponseToJson(ProjectsResponse instance) =>
    <String, dynamic>{
      'projects': instance.projects,
      'count': instance.count,
      'timestamp': instance.timestamp,
    };

ProjectStatsResponse _$ProjectStatsResponseFromJson(
  Map<String, dynamic> json,
) => ProjectStatsResponse(
  projectId: json['projectId'] as String,
  changeStats: json['changeStats'] == null
      ? null
      : EntityTypeSummary.fromJson(json['changeStats'] as Map<String, dynamic>),
  entityTypeStats: json['entityTypeStats'] == null
      ? null
      : EntityTypeStats.fromJson(
          json['entityTypeStats'] as Map<String, dynamic>,
        ),
  timestamp: json['timestamp'] as String?,
  storageType: json['storageType'] as String?,
);

Map<String, dynamic> _$ProjectStatsResponseToJson(
  ProjectStatsResponse instance,
) => <String, dynamic>{
  'projectId': instance.projectId,
  'changeStats': instance.changeStats?.toJson(),
  'entityTypeStats': instance.entityTypeStats?.toJson(),
  'timestamp': instance.timestamp,
  'storageType': instance.storageType,
};

EntityStatesResponse _$EntityStatesResponseFromJson(
  Map<String, dynamic> json,
) => EntityStatesResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  hasMore: json['hasMore'] as bool,
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$EntityStatesResponseToJson(
  EntityStatesResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'hasMore': instance.hasMore,
  'nextCursor': instance.nextCursor,
};
