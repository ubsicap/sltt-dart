// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_document_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarDocumentStateCollection on Isar {
  IsarCollection<IsarDocumentState> get isarDocumentStates => this.collection();
}

const IsarDocumentStateSchema = CollectionSchema(
  name: r'IsarDocumentState',
  id: 4901048636627225628,
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
    r'content': PropertySchema(
      id: 4,
      name: r'content',
      type: IsarType.string,
    ),
    r'contentChangeAt': PropertySchema(
      id: 5,
      name: r'contentChangeAt',
      type: IsarType.dateTime,
    ),
    r'contentChangeBy': PropertySchema(
      id: 6,
      name: r'contentChangeBy',
      type: IsarType.string,
    ),
    r'contentCid': PropertySchema(
      id: 7,
      name: r'contentCid',
      type: IsarType.string,
    ),
    r'deleted': PropertySchema(
      id: 8,
      name: r'deleted',
      type: IsarType.bool,
    ),
    r'deletedChangeAt': PropertySchema(
      id: 9,
      name: r'deletedChangeAt',
      type: IsarType.dateTime,
    ),
    r'deletedChangeBy': PropertySchema(
      id: 10,
      name: r'deletedChangeBy',
      type: IsarType.string,
    ),
    r'deletedCid': PropertySchema(
      id: 11,
      name: r'deletedCid',
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
      enumMap: _IsarDocumentStateentityTypeEnumValueMap,
    ),
    r'origChangeAt': PropertySchema(
      id: 14,
      name: r'origChangeAt',
      type: IsarType.dateTime,
    ),
    r'origChangeBy': PropertySchema(
      id: 15,
      name: r'origChangeBy',
      type: IsarType.string,
    ),
    r'origCid': PropertySchema(
      id: 16,
      name: r'origCid',
      type: IsarType.string,
    ),
    r'origCloudAt': PropertySchema(
      id: 17,
      name: r'origCloudAt',
      type: IsarType.dateTime,
    ),
    r'origProjectId': PropertySchema(
      id: 18,
      name: r'origProjectId',
      type: IsarType.string,
    ),
    r'parentId': PropertySchema(
      id: 19,
      name: r'parentId',
      type: IsarType.string,
    ),
    r'parentIdChangeAt': PropertySchema(
      id: 20,
      name: r'parentIdChangeAt',
      type: IsarType.dateTime,
    ),
    r'parentIdChangeBy': PropertySchema(
      id: 21,
      name: r'parentIdChangeBy',
      type: IsarType.string,
    ),
    r'parentIdCid': PropertySchema(
      id: 22,
      name: r'parentIdCid',
      type: IsarType.string,
    ),
    r'projectId': PropertySchema(
      id: 23,
      name: r'projectId',
      type: IsarType.string,
    ),
    r'projectIdChangeAt': PropertySchema(
      id: 24,
      name: r'projectIdChangeAt',
      type: IsarType.dateTime,
    ),
    r'projectIdChangeBy': PropertySchema(
      id: 25,
      name: r'projectIdChangeBy',
      type: IsarType.string,
    ),
    r'projectIdCid': PropertySchema(
      id: 26,
      name: r'projectIdCid',
      type: IsarType.string,
    ),
    r'rank': PropertySchema(
      id: 27,
      name: r'rank',
      type: IsarType.string,
    ),
    r'rankChangeAt': PropertySchema(
      id: 28,
      name: r'rankChangeAt',
      type: IsarType.dateTime,
    ),
    r'rankChangeBy': PropertySchema(
      id: 29,
      name: r'rankChangeBy',
      type: IsarType.string,
    ),
    r'rankCid': PropertySchema(
      id: 30,
      name: r'rankCid',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 31,
      name: r'title',
      type: IsarType.string,
    ),
    r'titleChangeAt': PropertySchema(
      id: 32,
      name: r'titleChangeAt',
      type: IsarType.dateTime,
    ),
    r'titleChangeBy': PropertySchema(
      id: 33,
      name: r'titleChangeBy',
      type: IsarType.string,
    ),
    r'titleCid': PropertySchema(
      id: 34,
      name: r'titleCid',
      type: IsarType.string,
    )
  },
  estimateSize: _isarDocumentStateEstimateSize,
  serialize: _isarDocumentStateSerialize,
  deserialize: _isarDocumentStateDeserialize,
  deserializeProp: _isarDocumentStateDeserializeProp,
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
  getId: _isarDocumentStateGetId,
  getLinks: _isarDocumentStateGetLinks,
  attach: _isarDocumentStateAttach,
  version: '3.1.0+1',
);

int _isarDocumentStateEstimateSize(
  IsarDocumentState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.changeBy.length * 3;
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.content.length * 3;
  bytesCount += 3 + object.contentChangeBy.length * 3;
  bytesCount += 3 + object.contentCid.length * 3;
  bytesCount += 3 + object.deletedChangeBy.length * 3;
  bytesCount += 3 + object.deletedCid.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.name.length * 3;
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
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.titleChangeBy.length * 3;
  bytesCount += 3 + object.titleCid.length * 3;
  return bytesCount;
}

void _isarDocumentStateSerialize(
  IsarDocumentState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.changeAt);
  writer.writeString(offsets[1], object.changeBy);
  writer.writeString(offsets[2], object.cid);
  writer.writeDateTime(offsets[3], object.cloudAt);
  writer.writeString(offsets[4], object.content);
  writer.writeDateTime(offsets[5], object.contentChangeAt);
  writer.writeString(offsets[6], object.contentChangeBy);
  writer.writeString(offsets[7], object.contentCid);
  writer.writeBool(offsets[8], object.deleted);
  writer.writeDateTime(offsets[9], object.deletedChangeAt);
  writer.writeString(offsets[10], object.deletedChangeBy);
  writer.writeString(offsets[11], object.deletedCid);
  writer.writeString(offsets[12], object.entityId);
  writer.writeString(offsets[13], object.entityType.name);
  writer.writeDateTime(offsets[14], object.origChangeAt);
  writer.writeString(offsets[15], object.origChangeBy);
  writer.writeString(offsets[16], object.origCid);
  writer.writeDateTime(offsets[17], object.origCloudAt);
  writer.writeString(offsets[18], object.origProjectId);
  writer.writeString(offsets[19], object.parentId);
  writer.writeDateTime(offsets[20], object.parentIdChangeAt);
  writer.writeString(offsets[21], object.parentIdChangeBy);
  writer.writeString(offsets[22], object.parentIdCid);
  writer.writeString(offsets[23], object.projectId);
  writer.writeDateTime(offsets[24], object.projectIdChangeAt);
  writer.writeString(offsets[25], object.projectIdChangeBy);
  writer.writeString(offsets[26], object.projectIdCid);
  writer.writeString(offsets[27], object.rank);
  writer.writeDateTime(offsets[28], object.rankChangeAt);
  writer.writeString(offsets[29], object.rankChangeBy);
  writer.writeString(offsets[30], object.rankCid);
  writer.writeString(offsets[31], object.title);
  writer.writeDateTime(offsets[32], object.titleChangeAt);
  writer.writeString(offsets[33], object.titleChangeBy);
  writer.writeString(offsets[34], object.titleCid);
}

IsarDocumentState _isarDocumentStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarDocumentState();
  object.changeAt = reader.readDateTimeOrNull(offsets[0]);
  object.changeBy = reader.readString(offsets[1]);
  object.cid = reader.readString(offsets[2]);
  object.cloudAt = reader.readDateTimeOrNull(offsets[3]);
  object.content = reader.readString(offsets[4]);
  object.contentChangeAt = reader.readDateTimeOrNull(offsets[5]);
  object.contentChangeBy = reader.readString(offsets[6]);
  object.contentCid = reader.readString(offsets[7]);
  object.deleted = reader.readBool(offsets[8]);
  object.deletedChangeAt = reader.readDateTimeOrNull(offsets[9]);
  object.deletedChangeBy = reader.readString(offsets[10]);
  object.deletedCid = reader.readString(offsets[11]);
  object.entityId = reader.readString(offsets[12]);
  object.entityType = _IsarDocumentStateentityTypeValueEnumMap[
          reader.readStringOrNull(offsets[13])] ??
      EntityType.project;
  object.id = id;
  object.origChangeAt = reader.readDateTimeOrNull(offsets[14]);
  object.origChangeBy = reader.readString(offsets[15]);
  object.origCid = reader.readString(offsets[16]);
  object.origCloudAt = reader.readDateTimeOrNull(offsets[17]);
  object.origProjectId = reader.readString(offsets[18]);
  object.parentId = reader.readString(offsets[19]);
  object.parentIdChangeAt = reader.readDateTimeOrNull(offsets[20]);
  object.parentIdChangeBy = reader.readString(offsets[21]);
  object.parentIdCid = reader.readString(offsets[22]);
  object.projectId = reader.readString(offsets[23]);
  object.projectIdChangeAt = reader.readDateTimeOrNull(offsets[24]);
  object.projectIdChangeBy = reader.readString(offsets[25]);
  object.projectIdCid = reader.readString(offsets[26]);
  object.rank = reader.readStringOrNull(offsets[27]);
  object.rankChangeAt = reader.readDateTimeOrNull(offsets[28]);
  object.rankChangeBy = reader.readString(offsets[29]);
  object.rankCid = reader.readString(offsets[30]);
  object.title = reader.readString(offsets[31]);
  object.titleChangeAt = reader.readDateTimeOrNull(offsets[32]);
  object.titleChangeBy = reader.readString(offsets[33]);
  object.titleCid = reader.readString(offsets[34]);
  return object;
}

P _isarDocumentStateDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (_IsarDocumentStateentityTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          EntityType.project) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IsarDocumentStateentityTypeEnumValueMap = {
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
const _IsarDocumentStateentityTypeValueEnumMap = {
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

Id _isarDocumentStateGetId(IsarDocumentState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarDocumentStateGetLinks(
    IsarDocumentState object) {
  return [];
}

void _isarDocumentStateAttach(
    IsarCollection<dynamic> col, Id id, IsarDocumentState object) {
  object.id = id;
}

extension IsarDocumentStateByIndex on IsarCollection<IsarDocumentState> {
  Future<IsarDocumentState?> getByEntityId(String entityId) {
    return getByIndex(r'entityId', [entityId]);
  }

  IsarDocumentState? getByEntityIdSync(String entityId) {
    return getByIndexSync(r'entityId', [entityId]);
  }

  Future<bool> deleteByEntityId(String entityId) {
    return deleteByIndex(r'entityId', [entityId]);
  }

  bool deleteByEntityIdSync(String entityId) {
    return deleteByIndexSync(r'entityId', [entityId]);
  }

  Future<List<IsarDocumentState?>> getAllByEntityId(
      List<String> entityIdValues) {
    final values = entityIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'entityId', values);
  }

  List<IsarDocumentState?> getAllByEntityIdSync(List<String> entityIdValues) {
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

  Future<Id> putByEntityId(IsarDocumentState object) {
    return putByIndex(r'entityId', object);
  }

  Id putByEntityIdSync(IsarDocumentState object, {bool saveLinks = true}) {
    return putByIndexSync(r'entityId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntityId(List<IsarDocumentState> objects) {
    return putAllByIndex(r'entityId', objects);
  }

  List<Id> putAllByEntityIdSync(List<IsarDocumentState> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'entityId', objects, saveLinks: saveLinks);
  }
}

extension IsarDocumentStateQueryWhereSort
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QWhere> {
  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarDocumentStateQueryWhere
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QWhereClause> {
  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterWhereClause>
      entityIdEqualTo(String entityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityId',
        value: [entityId],
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterWhereClause>
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

extension IsarDocumentStateQueryFilter
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QFilterCondition> {
  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      changeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'changeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      changeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'changeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      changeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      changeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      changeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'changeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      changeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      changeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'changeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cidEqualTo(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cidLessThan(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cidBetween(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cidEndsWith(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cloudAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cloudAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cloudAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cloudAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      cloudAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      contentCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deleted',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deletedChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deletedChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deletedChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deletedCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deletedCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      deletedCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deletedCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'origChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'origChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origCloudAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'origCloudAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origCloudAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'origCloudAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origCloudAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origCloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origProjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origProjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origProjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origProjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origProjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      origProjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origProjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentIdChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentIdCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      parentIdCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'projectIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'projectIdChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectIdChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectIdChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectIdChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectIdChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectIdCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectIdCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      projectIdCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectIdCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rank',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rank',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankEqualTo(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankBetween(
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rank',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rank',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rank',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rankChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rankChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rankChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rankChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rankChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rankChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rankChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
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

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rankCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rankCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rankCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      rankCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rankCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'titleChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'titleChangeAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'titleChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'titleChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'titleChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'titleChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'titleChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'titleChangeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'titleChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'titleChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'titleChangeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'titleChangeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleChangeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'titleChangeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'titleCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'titleCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'titleCid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'titleCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'titleCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'titleCid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'titleCid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleCid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      titleCidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'titleCid',
        value: '',
      ));
    });
  }
}

extension IsarDocumentStateQueryObject
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QFilterCondition> {}

extension IsarDocumentStateQueryLinks
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QFilterCondition> {}

extension IsarDocumentStateQuerySortBy
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QSortBy> {
  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy> sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByContentChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByContentChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByContentChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByContentChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByContentCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByContentCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDeletedChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDeletedChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDeletedChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDeletedChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDeletedCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDeletedCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origProjectId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByOrigProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origProjectId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByParentIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByParentIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByParentIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByParentIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByParentIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByParentIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByProjectIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByProjectIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByProjectIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByProjectIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByProjectIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByProjectIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByRankChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByRankChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByRankChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByRankChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByRankCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByRankCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByTitleChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByTitleChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByTitleChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByTitleChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByTitleCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByTitleCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleCid', Sort.desc);
    });
  }
}

extension IsarDocumentStateQuerySortThenBy
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QSortThenBy> {
  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy> thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByContentChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByContentChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByContentChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByContentChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByContentCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByContentCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDeletedChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDeletedChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDeletedChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDeletedChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDeletedCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDeletedCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origCloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origProjectId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByOrigProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origProjectId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByParentIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByParentIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByParentIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByParentIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByParentIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByParentIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByProjectIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByProjectIdChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByProjectIdChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByProjectIdChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByProjectIdCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByProjectIdCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectIdCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByRankChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByRankChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByRankChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByRankChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByRankCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByRankCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankCid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByTitleChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleChangeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByTitleChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleChangeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByTitleChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleChangeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByTitleChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleChangeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByTitleCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleCid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByTitleCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleCid', Sort.desc);
    });
  }
}

extension IsarDocumentStateQueryWhereDistinct
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct> {
  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct> distinctByCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByContentChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByContentChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByContentCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByDeletedChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByDeletedChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByDeletedCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByOrigChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByOrigChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origChangeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByOrigCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByOrigCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origCloudAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByOrigProjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origProjectId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByParentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByParentIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentIdChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByParentIdChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentIdChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByParentIdCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentIdCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByProjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByProjectIdChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectIdChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByProjectIdChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectIdChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByProjectIdCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectIdCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct> distinctByRank(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rank', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByRankChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rankChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByRankChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rankChangeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByRankCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rankCid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByTitleChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titleChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByTitleChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titleChangeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByTitleCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titleCid', caseSensitive: caseSensitive);
    });
  }
}

extension IsarDocumentStateQueryProperty
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QQueryProperty> {
  QueryBuilder<IsarDocumentState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      changeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> changeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      cloudAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      contentChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      contentChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentChangeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      contentCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentCid');
    });
  }

  QueryBuilder<IsarDocumentState, bool, QQueryOperations> deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      deletedChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      deletedChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedChangeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      deletedCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedCid');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<IsarDocumentState, EntityType, QQueryOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      origChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      origChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origChangeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> origCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origCid');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      origCloudAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origCloudAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      origProjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origProjectId');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      parentIdChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentIdChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      parentIdChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentIdChangeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      parentIdCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentIdCid');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      projectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectId');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      projectIdChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectIdChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      projectIdChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectIdChangeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      projectIdCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectIdCid');
    });
  }

  QueryBuilder<IsarDocumentState, String?, QQueryOperations> rankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rank');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      rankChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rankChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      rankChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rankChangeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> rankCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rankCid');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      titleChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titleChangeAt');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      titleChangeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titleChangeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> titleCidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titleCid');
    });
  }
}
