import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'api_models.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateChangesRequest {
  ///serialized/deserialized manually in the service to ensure proper (de)serialization
  @JsonKey(
    toJson: toJsonChangeLogEntryList,
    fromJson: fromJsonChangeLogEntryList,
  )
  final List<BaseChangeLogEntry> changes;
  final String srcStorageType;
  final String srcStorageId;
  final String? storageMode;
  final bool includeChangeUpdates;
  final bool includeStateUpdates;

  CreateChangesRequest({
    required this.changes,
    required this.srcStorageType,
    required this.srcStorageId,
    this.storageMode,
    this.includeChangeUpdates = false,
    this.includeStateUpdates = false,
  });

  factory CreateChangesRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChangesRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChangesRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateChangesResponse {
  final String? storageType;
  final String? storageId;
  final List<String>? created;
  final List<String>? updated;
  final List<String>? deleted;
  final List<String>? noOps;
  final List<String>? clouded;
  final List<String>? dups;
  final List<UnknownEntry>? unknowns;
  final List<ChangeInfo>? info;
  final List<ChangeError>? errors;
  final List<ChangeUpdateItem>? changeUpdates;
  final List<StateUpdateItem>? stateUpdates;
  final String? timestamp;

  CreateChangesResponse({
    this.storageType,
    this.storageId,
    this.created,
    this.updated,
    this.deleted,
    this.noOps,
    this.clouded,
    this.dups,
    this.unknowns,
    this.info,
    this.errors,
    this.changeUpdates,
    this.stateUpdates,
    this.timestamp,
  });

  factory CreateChangesResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateChangesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChangesResponseToJson(this);
}

@JsonSerializable()
class UnknownEntry {
  final String cid;
  final Map<String, dynamic> unknown;

  UnknownEntry({required this.cid, required this.unknown});

  factory UnknownEntry.fromJson(Map<String, dynamic> json) =>
      _$UnknownEntryFromJson(json);
  Map<String, dynamic> toJson() => _$UnknownEntryToJson(this);
}

@JsonSerializable()
class ChangeInfo {
  final String cid;
  final String? operation;
  final Map<String, dynamic>? info;

  ChangeInfo({required this.cid, this.operation, this.info});

  factory ChangeInfo.fromJson(Map<String, dynamic> json) =>
      _$ChangeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ChangeInfoToJson(this);
}

@JsonSerializable()
class ChangeError {
  final String cid;
  final Map<String, dynamic>? info;

  ChangeError({required this.cid, this.info});

  factory ChangeError.fromJson(Map<String, dynamic> json) =>
      _$ChangeErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ChangeErrorToJson(this);
}

@JsonSerializable()
class ChangeUpdateItem {
  final String cid;
  final Map<String, dynamic>? updates;

  ChangeUpdateItem({required this.cid, this.updates});

  factory ChangeUpdateItem.fromJson(Map<String, dynamic> json) =>
      _$ChangeUpdateItemFromJson(json);
  Map<String, dynamic> toJson() => _$ChangeUpdateItemToJson(this);
}

@JsonSerializable()
class StateUpdateItem {
  final String cid;
  final Map<String, dynamic>? state;

  StateUpdateItem({required this.cid, this.state});

  factory StateUpdateItem.fromJson(Map<String, dynamic> json) =>
      _$StateUpdateItemFromJson(json);
  Map<String, dynamic> toJson() => _$StateUpdateItemToJson(this);
}

@JsonSerializable()
class ChangeObject {
  final int? seq;
  @JsonKey(name: 'projectId')
  final String? projectId;
  final String? entityType;
  final String? operation;
  final String? entityId;
  final String? changeAt;
  final Map<String, dynamic>? dataJson;
  final String? cid;

  ChangeObject({
    this.seq,
    this.projectId,
    this.entityType,
    this.operation,
    this.entityId,
    this.changeAt,
    this.dataJson,
    this.cid,
  });

  factory ChangeObject.fromJson(Map<String, dynamic> json) =>
      _$ChangeObjectFromJson(json);
  Map<String, dynamic> toJson() => _$ChangeObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChangesPageResponse {
  final List<ChangeObject> changes;
  final int count;
  final int? cursor;
  final String? timestamp;

  ChangesPageResponse({
    required this.changes,
    required this.count,
    this.cursor,
    this.timestamp,
  });

  factory ChangesPageResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangesPageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChangesPageResponseToJson(this);
}

@JsonSerializable()
class DomainListResponse {
  final List<String> items;
  final int count;
  final String? timestamp;

  DomainListResponse({
    required this.items,
    required this.count,
    this.timestamp,
  });

  factory DomainListResponse.fromJson(Map<String, dynamic> json) =>
      _$DomainListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DomainListResponseToJson(this);
}

@JsonSerializable()
class ProjectsResponse {
  final List<String> projects;
  final int count;
  final String? timestamp;

  ProjectsResponse({
    required this.projects,
    required this.count,
    this.timestamp,
  });

  factory ProjectsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProjectStatsResponse {
  final String projectId;
  final EntityTypeSummary? changeStats;
  final EntityTypeStats? entityTypeStats;
  final String? timestamp;
  final String? storageType;

  ProjectStatsResponse({
    required this.projectId,
    this.changeStats,
    this.entityTypeStats,
    this.timestamp,
    this.storageType,
  });

  factory ProjectStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectStatsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectStatsResponseToJson(this);
}

@JsonSerializable()
class EntityStatesResponse {
  final List<Map<String, dynamic>> items;
  final bool hasMore;
  final String? nextCursor;

  EntityStatesResponse({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  factory EntityStatesResponse.fromJson(Map<String, dynamic> json) =>
      _$EntityStatesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EntityStatesResponseToJson(this);
}
