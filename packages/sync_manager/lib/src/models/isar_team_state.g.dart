// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_team_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarTeamStateCollection on Isar {
  IsarCollection<IsarTeamState> get isarTeamStates => this.collection();
}

const IsarTeamStateSchema = CollectionSchema(
  name: r'IsarTeamState',
  id: 1156459184152366094,
  properties: {
    r'changeAt': PropertySchema(
      id: 0,
      name: r'changeAt',
      type: IsarType.dateTime,
    ),
    r'changeBy': PropertySchema(
      id: 1,
      name: r'changeBy',
      type: IsarType.string,
    ),
    r'cid': PropertySchema(
      id: 2,
      name: r'cid',
      type: IsarType.string,
    ),
    r'cloudAt': PropertySchema(
      id: 3,
      name: r'cloudAt',
      type: IsarType.dateTime,
    ),
    r'deleted': PropertySchema(
      id: 4,
      name: r'deleted',
      type: IsarType.bool,
    ),
    r'deletedChangeAt': PropertySchema(
      id: 5,
      name: r'deletedChangeAt',
      type: IsarType.dateTime,
    ),
    r'deletedChangeBy': PropertySchema(
      id: 6,
      name: r'deletedChangeBy',
      type: IsarType.string,
    ),
    r'deletedCid': PropertySchema(
      id: 7,
      name: r'deletedCid',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 8,
      name: r'description',
      type: IsarType.string,
    ),
    r'descriptionChangeAt': PropertySchema(
      id: 9,
      name: r'descriptionChangeAt',
      type: IsarType.dateTime,
    ),
    r'descriptionChangeBy': PropertySchema(
      id: 10,
      name: r'descriptionChangeBy',
      type: IsarType.string,
    ),
    r'descriptionCid': PropertySchema(
      id: 11,
      name: r'descriptionCid',
      type: IsarType.string,
    ),
    r'entityId': PropertySchema(
      id: 12,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 13,
      name: r'entityType',
      type: IsarType.string,
      enumMap: _IsarTeamStateentityTypeEnumValueMap,
    ),
    r'leadId': PropertySchema(
      id: 14,
      name: r'leadId',
      type: IsarType.string,
    ),
    r'leadIdChangeAt': PropertySchema(
      id: 15,
      name: r'leadIdChangeAt',
      type: IsarType.dateTime,
    ),
    r'leadIdChangeBy': PropertySchema(
      id: 16,
      name: r'leadIdChangeBy',
      type: IsarType.string,
    ),
    r'leadIdCid': PropertySchema(
      id: 17,
      name: r'leadIdCid',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 18,
      name: r'name',
      type: IsarType.string,
    ),
    r'nameChangeAt': PropertySchema(
      id: 19,
      name: r'nameChangeAt',
      type: IsarType.dateTime,
    ),
    r'nameChangeBy': PropertySchema(
      id: 20,
      name: r'nameChangeBy',
      type: IsarType.string,
    ),
    r'nameCid': PropertySchema(
      id: 21,
      name: r'nameCid',
      type: IsarType.string,
    ),
    r'origChangeAt': PropertySchema(
      id: 22,
      name: r'origChangeAt',
      type: IsarType.dateTime,
    ),
    r'origChangeBy': PropertySchema(
      id: 23,
      name: r'origChangeBy',
      type: IsarType.string,
    ),
    r'origCid': PropertySchema(
      id: 24,
      name: r'origCid',
      type: IsarType.string,
    ),
    r'origCloudAt': PropertySchema(
      id: 25,
      name: r'origCloudAt',
      type: IsarType.dateTime,
    ),
    r'origProjectId': PropertySchema(
      id: 26,
      name: r'origProjectId',
      type: IsarType.string,
    ),
    r'parentId': PropertySchema(
      id: 27,
      name: r'parentId',
      type: IsarType.string,
    ),
    r'parentIdChangeAt': PropertySchema(
      id: 28,
      name: r'parentIdChangeAt',
      type: IsarType.dateTime,
    ),
    r'parentIdChangeBy': PropertySchema(
      id: 29,
      name: r'parentIdChangeBy',
      type: IsarType.string,
    ),
    r'parentIdCid': PropertySchema(
      id: 30,
      name: r'parentIdCid',
      type: IsarType.string,
    ),
    r'projectId': PropertySchema(
      id: 31,
      name: r'projectId',
      type: IsarType.string,
    ),
    r'projectIdChangeAt': PropertySchema(
      id: 32,
      name: r'projectIdChangeAt',
      type: IsarType.dateTime,
    ),
    r'projectIdChangeBy': PropertySchema(
      id: 33,
      name: r'projectIdChangeBy',
      type: IsarType.string,
    ),
    r'projectIdCid': PropertySchema(
      id: 34,
      name: r'projectIdCid',
      type: IsarType.string,
    ),
    r'rank': PropertySchema(
      id: 35,
      name: r'rank',
      type: IsarType.string,
    ),
    r'rankChangeAt': PropertySchema(
      id: 36,
      name: r'rankChangeAt',
      type: IsarType.dateTime,
    ),
    r'rankChangeBy': PropertySchema(
      id: 37,
      name: r'rankChangeBy',
      type: IsarType.string,
    ),
    r'rankCid': PropertySchema(
      id: 38,
      name: r'rankCid',
      type: IsarType.string,
    ),
    r'settings': PropertySchema(
      id: 39,
      name: r'settings',
      type: IsarType.string,
    ),
    r'settingsChangeAt': PropertySchema(
      id: 40,
      name: r'settingsChangeAt',
      type: IsarType.dateTime,
    ),
    r'settingsChangeBy': PropertySchema(
      id: 41,
      name: r'settingsChangeBy',
      type: IsarType.string,
    ),
    r'settingsCid': PropertySchema(
      id: 42,
      name: r'settingsCid',
      type: IsarType.string,
    )
  },
  estimateSize: _isarTeamStateEstimateSize,
  serialize: _isarTeamStateSerialize,
  deserialize: _isarTeamStateDeserialize,
  deserializeProp: _isarTeamStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'entityId': IndexSchema(
      id: 745355021660786263,
      name: r'entityId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarTeamStateGetId,
  getLinks: _isarTeamStateGetLinks,
  attach: _isarTeamStateAttach,
  version: '3.1.0+1',
);

int _isarTeamStateEstimateSize(
  IsarTeamState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.changeBy.length * 3;
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.deletedChangeBy.length * 3;
  bytesCount += 3 + object.deletedCid.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.descriptionChangeBy.length * 3;
  bytesCount += 3 + object.descriptionCid.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.name.length * 3;
  bytesCount += 3 + object.leadId.length * 3;
  bytesCount += 3 + object.leadIdChangeBy.length * 3;
  bytesCount += 3 + object.leadIdCid.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.nameChangeBy.length * 3;
  bytesCount += 3 + object.nameCid.length * 3;
  bytesCount += 3 + object.origChangeBy.length * 3;
  bytesCount += 3 + object.origCid.length * 3;
  bytesCount += 3 + object.origProjectId.length * 3;
  bytesCount += 3 + object.parentId.length * 3;
  bytesCount += 3 + object.parentIdChangeBy.length * 3;
  bytesCount += 3 + object.parentIdCid.length * 3;
  bytesCount += 3 + object.projectId.length * 3;
  bytesCount += 3 + object.projectIdChangeBy.length * 3;
  bytesCount += 3 + object.projectIdCid.length * 3;
  {
    final value = object.rank;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rankChangeBy.length * 3;
  bytesCount += 3 + object.rankCid.length * 3;
  bytesCount += 3 + object.settings.length * 3;
  bytesCount += 3 + object.settingsChangeBy.length * 3;
  bytesCount += 3 + object.settingsCid.length * 3;
  return bytesCount;
}

void _isarTeamStateSerialize(
  IsarTeamState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.changeAt);
  writer.writeString(offsets[1], object.changeBy);
  writer.writeString(offsets[2], object.cid);
  writer.writeDateTime(offsets[3], object.cloudAt);
  writer.writeBool(offsets[4], object.deleted);
  writer.writeDateTime(offsets[5], object.deletedChangeAt);
  writer.writeString(offsets[6], object.deletedChangeBy);
  writer.writeString(offsets[7], object.deletedCid);
  writer.writeString(offsets[8], object.description);
  writer.writeDateTime(offsets[9], object.descriptionChangeAt);
  writer.writeString(offsets[10], object.descriptionChangeBy);
  writer.writeString(offsets[11], object.descriptionCid);
  writer.writeString(offsets[12], object.entityId);
  writer.writeString(offsets[13], object.entityType.name);
  writer.writeString(offsets[14], object.leadId);
  writer.writeDateTime(offsets[15], object.leadIdChangeAt);
  writer.writeString(offsets[16], object.leadIdChangeBy);
  writer.writeString(offsets[17], object.leadIdCid);
  writer.writeString(offsets[18], object.name);
  writer.writeDateTime(offsets[19], object.nameChangeAt);
  writer.writeString(offsets[20], object.nameChangeBy);
  writer.writeString(offsets[21], object.nameCid);
  writer.writeDateTime(offsets[22], object.origChangeAt);
  writer.writeString(offsets[23], object.origChangeBy);
  writer.writeString(offsets[24], object.origCid);
  writer.writeDateTime(offsets[25], object.origCloudAt);
  writer.writeString(offsets[26], object.origProjectId);
  writer.writeString(offsets[27], object.parentId);
  writer.writeDateTime(offsets[28], object.parentIdChangeAt);
  writer.writeString(offsets[29], object.parentIdChangeBy);
  writer.writeString(offsets[30], object.parentIdCid);
  writer.writeString(offsets[31], object.projectId);
  writer.writeDateTime(offsets[32], object.projectIdChangeAt);
  writer.writeString(offsets[33], object.projectIdChangeBy);
  writer.writeString(offsets[34], object.projectIdCid);
  writer.writeString(offsets[35], object.rank);
  writer.writeDateTime(offsets[36], object.rankChangeAt);
  writer.writeString(offsets[37], object.rankChangeBy);
  writer.writeString(offsets[38], object.rankCid);
  writer.writeString(offsets[39], object.settings);
  writer.writeDateTime(offsets[40], object.settingsChangeAt);
  writer.writeString(offsets[41], object.settingsChangeBy);
  writer.writeString(offsets[42], object.settingsCid);
}

IsarTeamState _isarTeamStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarTeamState();
  object.changeAt = reader.readDateTimeOrNull(offsets[0]);
  object.changeBy = reader.readString(offsets[1]);
  object.cid = reader.readString(offsets[2]);
  object.cloudAt = reader.readDateTimeOrNull(offsets[3]);
  object.deleted = reader.readBool(offsets[4]);
  object.deletedChangeAt = reader.readDateTimeOrNull(offsets[5]);
  object.deletedChangeBy = reader.readString(offsets[6]);
  object.deletedCid = reader.readString(offsets[7]);
  object.description = reader.readString(offsets[8]);
  object.descriptionChangeAt = reader.readDateTimeOrNull(offsets[9]);
  object.descriptionChangeBy = reader.readString(offsets[10]);
  object.descriptionCid = reader.readString(offsets[11]);
  object.entityId = reader.readString(offsets[12]);
  object.entityType = _IsarTeamStateentityTypeValueEnumMap[
          reader.readStringOrNull(offsets[13])] ??
      EntityType.unknown;
  object.id = id;
  object.leadId = reader.readString(offsets[14]);
  object.leadIdChangeAt = reader.readDateTimeOrNull(offsets[15]);
  object.leadIdChangeBy = reader.readString(offsets[16]);
  object.leadIdCid = reader.readString(offsets[17]);
  object.name = reader.readString(offsets[18]);
  object.nameChangeAt = reader.readDateTimeOrNull(offsets[19]);
  object.nameChangeBy = reader.readString(offsets[20]);
  object.nameCid = reader.readString(offsets[21]);
  object.origChangeAt = reader.readDateTimeOrNull(offsets[22]);
  object.origChangeBy = reader.readString(offsets[23]);
  object.origCid = reader.readString(offsets[24]);
  object.origCloudAt = reader.readDateTimeOrNull(offsets[25]);
  object.origProjectId = reader.readString(offsets[26]);
  object.parentId = reader.readString(offsets[27]);
  object.parentIdChangeAt = reader.readDateTimeOrNull(offsets[28]);
  object.parentIdChangeBy = reader.readString(offsets[29]);
  object.parentIdCid = reader.readString(offsets[30]);
  object.projectId = reader.readString(offsets[31]);
  object.projectIdChangeAt = reader.readDateTimeOrNull(offsets[32]);
  object.projectIdChangeBy = reader.readString(offsets[33]);
  object.projectIdCid = reader.readString(offsets[34]);
  object.rank = reader.readStringOrNull(offsets[35]);
  object.rankChangeAt = reader.readDateTimeOrNull(offsets[36]);
  object.rankChangeBy = reader.readString(offsets[37]);
  object.rankCid = reader.readString(offsets[38]);
  object.settings = reader.readString(offsets[39]);
  object.settingsChangeAt = reader.readDateTimeOrNull(offsets[40]);
  object.settingsChangeBy = reader.readString(offsets[41]);
  object.settingsCid = reader.readString(offsets[42]);
  return object;
}

P _isarTeamStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (_IsarTeamStateentityTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          EntityType.unknown) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 29:
      return (reader.readString(offset)) as P;
    case 30:
      return (reader.readString(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readString(offset)) as P;
    case 35:
      return (reader.readStringOrNull(offset)) as P;
    case 36:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 37:
      return (reader.readString(offset)) as P;
    case 38:
      return (reader.readString(offset)) as P;
    case 39:
      return (reader.readString(offset)) as P;
    case 40:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 41:
      return (reader.readString(offset)) as P;
    case 42:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IsarTeamStateentityTypeEnumValueMap = {
  r'unknown': r'unknown',
  r'project': r'project',
  r'team': r'team',
  r'plan': r'plan',
  r'stage': r'stage',
  r'task': r'task',
  r'member': r'member',
  r'message': r'message',
  r'portion': r'portion',
  r'passage': r'passage',
  r'reference': r'reference',
  r'document': r'document',
  r'video': r'video',
  r'patch': r'patch',
  r'gloss': r'gloss',
  r'note': r'note',
  r'comment': r'comment',
};
const _IsarTeamStateentityTypeValueEnumMap = {
  r'unknown': EntityType.unknown,
  r'project': EntityType.project,
  r'team': EntityType.team,
  r'plan': EntityType.plan,
  r'stage': EntityType.stage,
  r'task': EntityType.task,
  r'member': EntityType.member,
  r'message': EntityType.message,
  r'portion': EntityType.portion,
  r'passage': EntityType.passage,
  r'reference': EntityType.reference,
  r'document': EntityType.document,
  r'video': EntityType.video,
  r'patch': EntityType.patch,
  r'gloss': EntityType.gloss,
  r'note': EntityType.note,
  r'comment': EntityType.comment,
};

Id _isarTeamStateGetId(IsarTeamState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarTeamStateGetLinks(IsarTeamState object) {
  return [];
}

void _isarTeamStateAttach(
    IsarCollection<dynamic> col, Id id, IsarTeamState object) {
  object.id = id;
}

extension IsarTeamStateByIndex on IsarCollection<IsarTeamState> {
  Future<IsarTeamState?> getByEntityId(String entityId) {
    return getByIndex(r'entityId', [entityId]);
  }

  IsarTeamState? getByEntityIdSync(String entityId) {
    return getByIndexSync(r'entityId', [entityId]);
  }

  Future<bool> deleteByEntityId(String entityId) {
    return deleteByIndex(r'entityId', [entityId]);
  }

  bool deleteByEntityIdSync(String entityId) {
    return deleteByIndexSync(r'entityId', [entityId]);
  }

  Future<List<IsarTeamState?>> getAllByEntityId(List<String> entityIdValues) {
    final values = entityIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'entityId', values);
  }

  List<IsarTeamState?> getAllByEntityIdSync(List<String> entityIdValues) {
    final values = entityIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'entityId', values);
  }

  Future<int> deleteAllByEntityId(List<String> entityIdValues) {
    final values = entityIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'entityId', values);
  }

  int deleteAllByEntityIdSync(List<String> entityIdValues) {
    final values = entityIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'entityId', values);
  }

  Future<Id> putByEntityId(IsarTeamState object) {
    return putByIndex(r'entityId', object);
  }

  Id putByEntityIdSync(IsarTeamState object, {bool saveLinks = true}) {
    return putByIndexSync(r'entityId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntityId(List<IsarTeamState> objects) {
    return putAllByIndex(r'entityId', objects);
  }

  List<Id> putAllByEntityIdSync(List<IsarTeamState> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'entityId', objects, saveLinks: saveLinks);
  }
}

extension IsarTeamStateQueryWhereSort
    on QueryBuilder<IsarTeamState, IsarTeamState, QWhere> {
  QueryBuilder<IsarTeamState, IsarTeamState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarTeamStateQueryWhere
    on QueryBuilder<IsarTeamState, IsarTeamState, QWhereClause> {
  QueryBuilder<IsarTeamState, IsarTeamState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterWhereClause> entityIdEqualTo(
      String entityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityId',
        value: [entityId],
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterWhereClause>
      entityIdNotEqualTo(String entityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [],
              upper: [entityId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [entityId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [entityId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [],
              upper: [entityId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarTeamStateQueryFilter
    on QueryBuilder<IsarTeamState, IsarTeamState, QFilterCondition> {
  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'changeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'changeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'changeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      changeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'changeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> cidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> cidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> cidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> cidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> cidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> cidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cloudAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cloudAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cloudAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cloudAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cloudAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cloudAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cloudAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      cloudAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cloudAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deleted',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deletedChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deletedChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deletedChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deletedChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deletedChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deletedCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deletedCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deletedCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deletedCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      deletedCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deletedCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'descriptionChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'descriptionChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descriptionChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descriptionChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descriptionChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descriptionChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descriptionChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descriptionChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descriptionChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descriptionChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descriptionChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descriptionChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descriptionChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descriptionCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descriptionCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descriptionCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descriptionCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descriptionCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descriptionCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descriptionCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descriptionCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      descriptionCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descriptionCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeEqualTo(
    EntityType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeGreaterThan(
    EntityType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeLessThan(
    EntityType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeBetween(
    EntityType lower,
    EntityType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leadId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'leadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'leadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'leadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'leadId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leadId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'leadId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'leadIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'leadIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leadIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leadIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leadIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leadIdChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leadIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leadIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leadIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leadIdChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'leadIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'leadIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'leadIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'leadIdChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leadIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'leadIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leadIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leadIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leadIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leadIdCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'leadIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'leadIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'leadIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'leadIdCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leadIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      leadIdCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'leadIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nameChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nameChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      nameCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'origChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'origChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'origChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'origChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'origCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'origCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCloudAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'origCloudAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCloudAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'origCloudAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCloudAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origCloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCloudAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origCloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCloudAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origCloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origCloudAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origCloudAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origProjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'origProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'origProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origProjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      origProjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentIdChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentIdChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentIdChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentIdCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentIdCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      parentIdCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'projectIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'projectIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectIdChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectIdChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'projectIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'projectIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectIdChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectIdCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'projectIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'projectIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectIdCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      projectIdCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rank',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rank',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> rankEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> rankBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rank',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition> rankMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rank',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rank',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rank',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rankChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rankChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rankChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rankChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rankChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rankChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rankChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rankChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rankChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rankChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rankChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rankChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rankChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rankChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rankChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rankChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rankCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rankCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rankCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rankCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rankCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rankCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rankCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rankCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rankCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      rankCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rankCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settings',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settings',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settings',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settingsChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settingsChangeAt',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingsChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingsChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingsChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingsChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingsChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingsChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingsChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingsChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingsChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingsChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingsChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingsCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingsCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingsCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingsCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingsCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingsCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingsCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterFilterCondition>
      settingsCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingsCid',
        value: '',
      ));
    });
  }
}

extension IsarTeamStateQueryObject
    on QueryBuilder<IsarTeamState, IsarTeamState, QFilterCondition> {}

extension IsarTeamStateQueryLinks
    on QueryBuilder<IsarTeamState, IsarTeamState, QFilterCondition> {}

extension IsarTeamStateQuerySortBy
    on QueryBuilder<IsarTeamState, IsarTeamState, QSortBy> {
  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDeletedChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDeletedChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDeletedChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDeletedChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByDeletedCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDeletedCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDescriptionChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDescriptionChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDescriptionChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDescriptionChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDescriptionCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByDescriptionCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByLeadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByLeadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByLeadIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByLeadIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByLeadIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByLeadIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByLeadIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByLeadIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByNameChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByNameChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByNameChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByNameChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByNameCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByNameCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByOrigChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByOrigChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByOrigChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByOrigChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByOrigCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByOrigCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByOrigCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByOrigCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByOrigProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origProjectId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByOrigProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origProjectId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByParentIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByParentIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByParentIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByParentIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByParentIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByParentIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByProjectIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByProjectIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByProjectIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByProjectIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByProjectIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByProjectIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByRankChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByRankChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByRankChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortByRankChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByRankCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortByRankCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortBySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortBySettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortBySettingsChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortBySettingsChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortBySettingsChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortBySettingsChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> sortBySettingsCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      sortBySettingsCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsCid', Sort.desc);
    });
  }
}

extension IsarTeamStateQuerySortThenBy
    on QueryBuilder<IsarTeamState, IsarTeamState, QSortThenBy> {
  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDeletedChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDeletedChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDeletedChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDeletedChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByDeletedCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDeletedCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDescriptionChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDescriptionChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDescriptionChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDescriptionChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDescriptionCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByDescriptionCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descriptionCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByLeadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByLeadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByLeadIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByLeadIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByLeadIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByLeadIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByLeadIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByLeadIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByNameChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByNameChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByNameChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByNameChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByNameCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByNameCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByOrigChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByOrigChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByOrigChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByOrigChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByOrigCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByOrigCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByOrigCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByOrigCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByOrigProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origProjectId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByOrigProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origProjectId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByParentIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByParentIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByParentIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByParentIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByParentIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByParentIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByProjectIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByProjectIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByProjectIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByProjectIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByProjectIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByProjectIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByRankChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByRankChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByRankChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenByRankChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByRankCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenByRankCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankCid', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenBySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenBySettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenBySettingsChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenBySettingsChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenBySettingsChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenBySettingsChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy> thenBySettingsCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsCid', Sort.asc);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QAfterSortBy>
      thenBySettingsCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsCid', Sort.desc);
    });
  }
}

extension IsarTeamStateQueryWhereDistinct
    on QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> {
  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByChangeBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByDeletedChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByDeletedChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByDeletedCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByDescriptionChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descriptionChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByDescriptionChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descriptionChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByDescriptionCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descriptionCid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByEntityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByEntityType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByLeadId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leadId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByLeadIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leadIdChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByLeadIdChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leadIdChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByLeadIdCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leadIdCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByNameChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByNameChangeBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameChangeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByNameCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByOrigChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByOrigChangeBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origChangeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByOrigCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByOrigCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origCloudAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByOrigProjectId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origProjectId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByParentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByParentIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentIdChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByParentIdChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentIdChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByParentIdCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentIdCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByProjectId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByProjectIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectIdChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByProjectIdChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectIdChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByProjectIdCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectIdCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByRank(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rank', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctByRankChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rankChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByRankChangeBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rankChangeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctByRankCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rankCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctBySettings(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settings', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctBySettingsChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct>
      distinctBySettingsChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTeamState, IsarTeamState, QDistinct> distinctBySettingsCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsCid', caseSensitive: caseSensitive);
    });
  }
}

extension IsarTeamStateQueryProperty
    on QueryBuilder<IsarTeamState, IsarTeamState, QQueryProperty> {
  QueryBuilder<IsarTeamState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations> changeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> changeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations> cloudAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudAt');
    });
  }

  QueryBuilder<IsarTeamState, bool, QQueryOperations> deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      deletedChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations>
      deletedChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> deletedCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedCid');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      descriptionChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descriptionChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations>
      descriptionChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descriptionChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations>
      descriptionCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descriptionCid');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<IsarTeamState, EntityType, QQueryOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> leadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leadId');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      leadIdChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leadIdChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations>
      leadIdChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leadIdChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> leadIdCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leadIdCid');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      nameChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> nameChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> nameCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameCid');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      origChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> origChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> origCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origCid');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      origCloudAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origCloudAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations>
      origProjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origProjectId');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      parentIdChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentIdChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations>
      parentIdChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentIdChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> parentIdCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentIdCid');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> projectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectId');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      projectIdChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectIdChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations>
      projectIdChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectIdChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> projectIdCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectIdCid');
    });
  }

  QueryBuilder<IsarTeamState, String?, QQueryOperations> rankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rank');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      rankChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rankChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> rankChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rankChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> rankCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rankCid');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> settingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settings');
    });
  }

  QueryBuilder<IsarTeamState, DateTime?, QQueryOperations>
      settingsChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsChangeAt');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations>
      settingsChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsChangeBy');
    });
  }

  QueryBuilder<IsarTeamState, String, QQueryOperations> settingsCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsCid');
    });
  }
}
