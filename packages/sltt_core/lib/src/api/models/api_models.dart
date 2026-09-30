import 'dart:convert' show jsonDecode;

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
  @JsonKey(name: 'domainId')
  final String? domainId;
  final String? entityType;
  final String? operation;
  final String? entityId;
  final String? changeAt;
  final Map<String, dynamic>? dataJson;
  final String? cid;

  ChangeObject({
    this.seq,
    this.domainId,
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
class DomainStatsResponse {
  final String domainId;
  final String domainType;
  final EntityTypeSummary? changeStats;
  final EntityTypeStats? entityTypeStats;
  final Map<String, String>? entityTypeCollections;
  final String? timestamp;
  final String? storageType;
  final bool isIncremental;

  DomainStatsResponse({
    required this.domainId,
    required this.domainType,
    this.changeStats,
    this.entityTypeStats,
    this.entityTypeCollections,
    this.timestamp,
    this.storageType,
    this.isIncremental = false,
  });

  factory DomainStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$DomainStatsResponseFromJson(json);
  Map<String, dynamic> toJson() {
    final coreJson = _$DomainStatsResponseToJson(this);
    return {'${domainType}Id': domainId, ...coreJson};
  }
}

@JsonSerializable(explicitToJson: true)
class EntityStatesResponse {
  final String domainId;
  final String domainType;
  final String entityType;
  final List<dynamic> items;
  final bool hasMore;
  final String? cursor;
  final String? timestamp;

  EntityStatesResponse({
    required this.domainId,
    required this.domainType,
    required this.entityType,
    required this.items,
    required this.hasMore,
    this.cursor,
    this.timestamp,
  });

  factory EntityStatesResponse.fromJson(Map<String, dynamic> json) =>
      _$EntityStatesResponseFromJson(json);

  Map<String, dynamic> toJson() {
    final coreJson = _$EntityStatesResponseToJson(this);
    return {'${domainType}Id': domainId, ...coreJson};
  }

  Map<String, dynamic> toJsonStable() => {
    ...toJson(),
    'items': stabilizeEachItemInList(items),
  };
}

@JsonSerializable(explicitToJson: true)
class CrossDomainEntityStatesResponse {
  final List<dynamic> items;
  final String? nextCursor;
  final int count;

  CrossDomainEntityStatesResponse({
    required this.items,
    this.nextCursor,
    required this.count,
  });

  factory CrossDomainEntityStatesResponse.fromJson(Map<String, dynamic> json) =>
      _$CrossDomainEntityStatesResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CrossDomainEntityStatesResponseToJson(this);

  Map<String, dynamic> toJsonStable() => {
    ...toJson(),
    'items': stabilizeEachItemInList(items),
  };
}

/// Stabilizes each item in the list by converting it to a JSON string and back (e.g. for stable payloads)
List<dynamic> stabilizeEachItemInList(List<dynamic> items) =>
    items.map((item) => jsonDecode(stableStringify(item))).toList();
