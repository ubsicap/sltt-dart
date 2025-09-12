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
    r'change_changeAt': PropertySchema(
      id: 0,
      name: r'change_changeAt',
      type: IsarType.dateTime,
    ),
    r'change_changeAt_orig_': PropertySchema(
      id: 1,
      name: r'change_changeAt_orig_',
      type: IsarType.dateTime,
    ),
    r'change_changeBy': PropertySchema(
      id: 2,
      name: r'change_changeBy',
      type: IsarType.string,
    ),
    r'change_changeBy_orig_': PropertySchema(
      id: 3,
      name: r'change_changeBy_orig_',
      type: IsarType.string,
    ),
    r'change_cid': PropertySchema(
      id: 4,
      name: r'change_cid',
      type: IsarType.string,
    ),
    r'change_cid_orig_': PropertySchema(
      id: 5,
      name: r'change_cid_orig_',
      type: IsarType.string,
    ),
    r'change_cloudAt': PropertySchema(
      id: 6,
      name: r'change_cloudAt',
      type: IsarType.dateTime,
    ),
    r'change_dataSchemaRev': PropertySchema(
      id: 7,
      name: r'change_dataSchemaRev',
      type: IsarType.long,
    ),
    r'change_domainId': PropertySchema(
      id: 8,
      name: r'change_domainId',
      type: IsarType.string,
    ),
    r'change_domainId_orig_': PropertySchema(
      id: 9,
      name: r'change_domainId_orig_',
      type: IsarType.string,
    ),
    r'data_contentLength': PropertySchema(
      id: 10,
      name: r'data_contentLength',
      type: IsarType.long,
    ),
    r'data_deleted': PropertySchema(
      id: 11,
      name: r'data_deleted',
      type: IsarType.bool,
    ),
    r'data_deleted_changeAt_': PropertySchema(
      id: 12,
      name: r'data_deleted_changeAt_',
      type: IsarType.dateTime,
    ),
    r'data_deleted_changeBy_': PropertySchema(
      id: 13,
      name: r'data_deleted_changeBy_',
      type: IsarType.string,
    ),
    r'data_deleted_cid_': PropertySchema(
      id: 14,
      name: r'data_deleted_cid_',
      type: IsarType.string,
    ),
    r'data_deleted_cloudAt_': PropertySchema(
      id: 15,
      name: r'data_deleted_cloudAt_',
      type: IsarType.dateTime,
    ),
    r'data_deleted_dataSchemaRev_': PropertySchema(
      id: 16,
      name: r'data_deleted_dataSchemaRev_',
      type: IsarType.long,
    ),
    r'data_parentId': PropertySchema(
      id: 17,
      name: r'data_parentId',
      type: IsarType.string,
    ),
    r'data_parentId_changeAt_': PropertySchema(
      id: 18,
      name: r'data_parentId_changeAt_',
      type: IsarType.dateTime,
    ),
    r'data_parentId_changeBy_': PropertySchema(
      id: 19,
      name: r'data_parentId_changeBy_',
      type: IsarType.string,
    ),
    r'data_parentId_cid_': PropertySchema(
      id: 20,
      name: r'data_parentId_cid_',
      type: IsarType.string,
    ),
    r'data_parentId_cloudAt_': PropertySchema(
      id: 21,
      name: r'data_parentId_cloudAt_',
      type: IsarType.dateTime,
    ),
    r'data_parentId_dataSchemaRev_': PropertySchema(
      id: 22,
      name: r'data_parentId_dataSchemaRev_',
      type: IsarType.long,
    ),
    r'data_rank': PropertySchema(
      id: 23,
      name: r'data_rank',
      type: IsarType.string,
    ),
    r'data_rank_changeAt_': PropertySchema(
      id: 24,
      name: r'data_rank_changeAt_',
      type: IsarType.dateTime,
    ),
    r'data_rank_changeBy_': PropertySchema(
      id: 25,
      name: r'data_rank_changeBy_',
      type: IsarType.string,
    ),
    r'data_rank_cid_': PropertySchema(
      id: 26,
      name: r'data_rank_cid_',
      type: IsarType.string,
    ),
    r'data_rank_cloudAt_': PropertySchema(
      id: 27,
      name: r'data_rank_cloudAt_',
      type: IsarType.dateTime,
    ),
    r'data_rank_dataSchemaRev_': PropertySchema(
      id: 28,
      name: r'data_rank_dataSchemaRev_',
      type: IsarType.long,
    ),
    r'data_title': PropertySchema(
      id: 29,
      name: r'data_title',
      type: IsarType.string,
    ),
    r'data_title_changeAt_': PropertySchema(
      id: 30,
      name: r'data_title_changeAt_',
      type: IsarType.dateTime,
    ),
    r'data_title_cid_': PropertySchema(
      id: 31,
      name: r'data_title_cid_',
      type: IsarType.string,
    ),
    r'domainType': PropertySchema(
      id: 32,
      name: r'domainType',
      type: IsarType.string,
    ),
    r'entityId': PropertySchema(
      id: 33,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 34,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 35,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'unknownJson': PropertySchema(
      id: 36,
      name: r'unknownJson',
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
  bytesCount += 3 + object.change_changeBy.length * 3;
  bytesCount += 3 + object.change_changeBy_orig_.length * 3;
  bytesCount += 3 + object.change_cid.length * 3;
  bytesCount += 3 + object.change_cid_orig_.length * 3;
  bytesCount += 3 + object.change_domainId.length * 3;
  bytesCount += 3 + object.change_domainId_orig_.length * 3;
  {
    final value = object.data_deleted_changeBy_;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.data_deleted_cid_;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.data_parentId.length * 3;
  bytesCount += 3 + object.data_parentId_changeBy_.length * 3;
  bytesCount += 3 + object.data_parentId_cid_.length * 3;
  {
    final value = object.data_rank;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.data_rank_changeBy_;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.data_rank_cid_;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.data_title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.data_title_cid_;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.domainType.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.length * 3;
  bytesCount += 3 + object.unknownJson.length * 3;
  return bytesCount;
}

void _isarDocumentStateSerialize(
  IsarDocumentState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.change_changeAt);
  writer.writeDateTime(offsets[1], object.change_changeAt_orig_);
  writer.writeString(offsets[2], object.change_changeBy);
  writer.writeString(offsets[3], object.change_changeBy_orig_);
  writer.writeString(offsets[4], object.change_cid);
  writer.writeString(offsets[5], object.change_cid_orig_);
  writer.writeDateTime(offsets[6], object.change_cloudAt);
  writer.writeLong(offsets[7], object.change_dataSchemaRev);
  writer.writeString(offsets[8], object.change_domainId);
  writer.writeString(offsets[9], object.change_domainId_orig_);
  writer.writeLong(offsets[10], object.data_contentLength);
  writer.writeBool(offsets[11], object.data_deleted);
  writer.writeDateTime(offsets[12], object.data_deleted_changeAt_);
  writer.writeString(offsets[13], object.data_deleted_changeBy_);
  writer.writeString(offsets[14], object.data_deleted_cid_);
  writer.writeDateTime(offsets[15], object.data_deleted_cloudAt_);
  writer.writeLong(offsets[16], object.data_deleted_dataSchemaRev_);
  writer.writeString(offsets[17], object.data_parentId);
  writer.writeDateTime(offsets[18], object.data_parentId_changeAt_);
  writer.writeString(offsets[19], object.data_parentId_changeBy_);
  writer.writeString(offsets[20], object.data_parentId_cid_);
  writer.writeDateTime(offsets[21], object.data_parentId_cloudAt_);
  writer.writeLong(offsets[22], object.data_parentId_dataSchemaRev_);
  writer.writeString(offsets[23], object.data_rank);
  writer.writeDateTime(offsets[24], object.data_rank_changeAt_);
  writer.writeString(offsets[25], object.data_rank_changeBy_);
  writer.writeString(offsets[26], object.data_rank_cid_);
  writer.writeDateTime(offsets[27], object.data_rank_cloudAt_);
  writer.writeLong(offsets[28], object.data_rank_dataSchemaRev_);
  writer.writeString(offsets[29], object.data_title);
  writer.writeDateTime(offsets[30], object.data_title_changeAt_);
  writer.writeString(offsets[31], object.data_title_cid_);
  writer.writeString(offsets[32], object.domainType);
  writer.writeString(offsets[33], object.entityId);
  writer.writeString(offsets[34], object.entityType);
  writer.writeLong(offsets[35], object.schemaVersion);
  writer.writeString(offsets[36], object.unknownJson);
}

IsarDocumentState _isarDocumentStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarDocumentState(
    change_changeAt: reader.readDateTime(offsets[0]),
    change_changeAt_orig_: reader.readDateTime(offsets[1]),
    change_changeBy: reader.readString(offsets[2]),
    change_changeBy_orig_: reader.readString(offsets[3]),
    change_cid: reader.readString(offsets[4]),
    change_cid_orig_: reader.readString(offsets[5]),
    change_cloudAt: reader.readDateTimeOrNull(offsets[6]),
    change_dataSchemaRev: reader.readLongOrNull(offsets[7]),
    change_domainId: reader.readString(offsets[8]),
    change_domainId_orig_: reader.readString(offsets[9]),
    data_contentLength: reader.readLongOrNull(offsets[10]),
    data_deleted: reader.readBoolOrNull(offsets[11]),
    data_deleted_changeAt_: reader.readDateTimeOrNull(offsets[12]),
    data_deleted_changeBy_: reader.readStringOrNull(offsets[13]),
    data_deleted_cid_: reader.readStringOrNull(offsets[14]),
    data_deleted_cloudAt_: reader.readDateTimeOrNull(offsets[15]),
    data_deleted_dataSchemaRev_: reader.readLongOrNull(offsets[16]),
    data_parentId: reader.readString(offsets[17]),
    data_parentId_changeAt_: reader.readDateTime(offsets[18]),
    data_parentId_changeBy_: reader.readString(offsets[19]),
    data_parentId_cid_: reader.readString(offsets[20]),
    data_parentId_cloudAt_: reader.readDateTimeOrNull(offsets[21]),
    data_parentId_dataSchemaRev_: reader.readLongOrNull(offsets[22]),
    data_rank: reader.readStringOrNull(offsets[23]),
    data_rank_changeAt_: reader.readDateTimeOrNull(offsets[24]),
    data_rank_changeBy_: reader.readStringOrNull(offsets[25]),
    data_rank_cid_: reader.readStringOrNull(offsets[26]),
    data_rank_cloudAt_: reader.readDateTimeOrNull(offsets[27]),
    data_rank_dataSchemaRev_: reader.readLongOrNull(offsets[28]),
    data_title: reader.readStringOrNull(offsets[29]),
    data_title_changeAt_: reader.readDateTimeOrNull(offsets[30]),
    data_title_cid_: reader.readStringOrNull(offsets[31]),
    entityId: reader.readString(offsets[33]),
    entityType: reader.readStringOrNull(offsets[34]) ?? 'document',
    id: id,
    schemaVersion: reader.readLongOrNull(offsets[35]),
    unknownJson: reader.readString(offsets[36]),
  );
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
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDateTime(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 28:
      return (reader.readLongOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readString(offset)) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset) ?? 'document') as P;
    case 35:
      return (reader.readLongOrNull(offset)) as P;
    case 36:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

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
      change_changeAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_changeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeAt_orig_EqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_changeAt_orig_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeAt_orig_GreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_changeAt_orig_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeAt_orig_LessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_changeAt_orig_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeAt_orig_Between(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_changeAt_orig_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_changeBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'change_changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'change_changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'change_changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'change_changeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_changeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'change_changeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_changeBy_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_changeBy_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_changeBy_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_changeBy_orig_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'change_changeBy_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'change_changeBy_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'change_changeBy_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_Matches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'change_changeBy_orig_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_changeBy_orig_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_changeBy_orig_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'change_changeBy_orig_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_cid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'change_cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'change_cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'change_cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'change_cid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_cid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'change_cid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_cid_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_cid_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_cid_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_cid_orig_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'change_cid_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'change_cid_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'change_cid_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'change_cid_orig_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_cid_orig_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cid_orig_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'change_cid_orig_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cloudAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'change_cloudAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cloudAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'change_cloudAt',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cloudAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_cloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cloudAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_cloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cloudAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_cloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_cloudAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_cloudAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_dataSchemaRevIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'change_dataSchemaRev',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_dataSchemaRevIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'change_dataSchemaRev',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_dataSchemaRevEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_dataSchemaRev',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_dataSchemaRevGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_dataSchemaRev',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_dataSchemaRevLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_dataSchemaRev',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_dataSchemaRevBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_dataSchemaRev',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_domainId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'change_domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'change_domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'change_domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'change_domainId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_domainId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'change_domainId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_domainId_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'change_domainId_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'change_domainId_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'change_domainId_orig_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'change_domainId_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'change_domainId_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'change_domainId_orig_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_Matches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'change_domainId_orig_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'change_domainId_orig_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      change_domainId_orig_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'change_domainId_orig_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_contentLengthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_contentLength',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_contentLengthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_contentLength',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_contentLengthEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_contentLength',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_contentLengthGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_contentLength',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_contentLengthLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_contentLength',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_contentLengthBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_contentLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deletedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_deleted',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deletedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_deleted',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deletedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_deleted',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeAt_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_deleted_changeAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeAt_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_deleted_changeAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeAt_EqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_deleted_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeAt_GreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_deleted_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeAt_LessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_deleted_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeAt_Between(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_deleted_changeAt_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_deleted_changeBy_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_deleted_changeBy_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_deleted_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_deleted_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_deleted_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_deleted_changeBy_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_deleted_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_deleted_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_Contains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_deleted_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_Matches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_deleted_changeBy_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_deleted_changeBy_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_changeBy_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_deleted_changeBy_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_deleted_cid_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_deleted_cid_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_deleted_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_deleted_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_deleted_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_deleted_cid_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_deleted_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_deleted_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_deleted_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_deleted_cid_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_deleted_cid_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cid_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_deleted_cid_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cloudAt_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_deleted_cloudAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cloudAt_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_deleted_cloudAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cloudAt_EqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_deleted_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cloudAt_GreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_deleted_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cloudAt_LessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_deleted_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_cloudAt_Between(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_deleted_cloudAt_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_dataSchemaRev_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_deleted_dataSchemaRev_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_dataSchemaRev_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_deleted_dataSchemaRev_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_dataSchemaRev_EqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_deleted_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_dataSchemaRev_GreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_deleted_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_dataSchemaRev_LessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_deleted_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_deleted_dataSchemaRev_Between(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_deleted_dataSchemaRev_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_parentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_parentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_parentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_parentId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeAt_EqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeAt_GreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_parentId_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeAt_LessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_parentId_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeAt_Between(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_parentId_changeAt_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_parentId_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_parentId_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_parentId_changeBy_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_parentId_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_parentId_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_Contains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_parentId_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_Matches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_parentId_changeBy_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId_changeBy_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_changeBy_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_parentId_changeBy_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_parentId_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_parentId_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_parentId_cid_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_parentId_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_parentId_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_parentId_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_parentId_cid_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId_cid_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cid_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_parentId_cid_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cloudAt_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_parentId_cloudAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cloudAt_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_parentId_cloudAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cloudAt_EqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cloudAt_GreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_parentId_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cloudAt_LessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_parentId_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_cloudAt_Between(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_parentId_cloudAt_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_dataSchemaRev_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_parentId_dataSchemaRev_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_dataSchemaRev_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_parentId_dataSchemaRev_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_dataSchemaRev_EqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_parentId_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_dataSchemaRev_GreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_parentId_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_dataSchemaRev_LessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_parentId_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_parentId_dataSchemaRev_Between(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_parentId_dataSchemaRev_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_rank',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_rank',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_rank',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_rank',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_rank',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rankIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_rank',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeAt_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_rank_changeAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeAt_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_rank_changeAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeAt_EqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeAt_GreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_rank_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeAt_LessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_rank_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeAt_Between(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_rank_changeAt_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_rank_changeBy_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_rank_changeBy_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_rank_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_rank_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_rank_changeBy_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_rank_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_rank_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_rank_changeBy_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_rank_changeBy_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank_changeBy_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_changeBy_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_rank_changeBy_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_rank_cid_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_rank_cid_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_rank_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_rank_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_rank_cid_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_rank_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_rank_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_rank_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_rank_cid_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank_cid_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cid_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_rank_cid_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cloudAt_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_rank_cloudAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cloudAt_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_rank_cloudAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cloudAt_EqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cloudAt_GreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_rank_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cloudAt_LessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_rank_cloudAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_cloudAt_Between(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_rank_cloudAt_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_dataSchemaRev_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_rank_dataSchemaRev_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_dataSchemaRev_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_rank_dataSchemaRev_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_dataSchemaRev_EqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_rank_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_dataSchemaRev_GreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_rank_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_dataSchemaRev_LessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_rank_dataSchemaRev_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_rank_dataSchemaRev_Between(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_rank_dataSchemaRev_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_title',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_title',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_title',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_changeAt_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_title_changeAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_changeAt_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_title_changeAt_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_changeAt_EqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_title_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_changeAt_GreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_title_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_changeAt_LessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_title_changeAt_',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_changeAt_Between(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_title_changeAt_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data_title_cid_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data_title_cid_',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_title_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data_title_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data_title_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data_title_cid_',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data_title_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data_title_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data_title_cid_',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data_title_cid_',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data_title_cid_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      data_title_cid_IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data_title_cid_',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'domainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'domainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'domainType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'domainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'domainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'domainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'domainType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      domainTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'domainType',
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
    String value, {
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
    String value, {
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
    String value, {
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
    String lower,
    String upper, {
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
      schemaVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'schemaVersion',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      schemaVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'schemaVersion',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      schemaVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      schemaVersionGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      schemaVersionLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      schemaVersionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unknownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unknownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unknownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unknownJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unknownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unknownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unknownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unknownJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unknownJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterFilterCondition>
      unknownJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unknownJson',
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
      sortByChange_changeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_changeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_changeAt_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeAt_orig_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_changeAt_orig_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeAt_orig_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_changeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_changeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_changeBy_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeBy_orig_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_changeBy_orig_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeBy_orig_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_cid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_cidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_cid_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cid_orig_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_cid_orig_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cid_orig_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_cloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_cloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_dataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_dataSchemaRev', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_dataSchemaRevDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_dataSchemaRev', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_domainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_domainId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_domainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_domainId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_domainId_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_domainId_orig_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByChange_domainId_orig_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_domainId_orig_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_contentLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_contentLength', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_contentLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_contentLength', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_changeAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_changeAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_changeAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_changeBy_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_changeBy_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_changeBy_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_changeBy_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_cid_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_cid_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_cid_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_cid_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_cloudAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_cloudAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_cloudAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_dataSchemaRev_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_deleted_dataSchemaRev_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_dataSchemaRev_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_changeAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_changeAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_changeAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_changeBy_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_changeBy_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_changeBy_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_changeBy_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_cid_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_cid_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_cid_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_cid_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_cloudAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_cloudAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_cloudAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_dataSchemaRev_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_parentId_dataSchemaRev_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_dataSchemaRev_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_changeAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_changeAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_changeAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_changeBy_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_changeBy_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_changeBy_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_changeBy_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_cid_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_cid_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_cid_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_cid_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_cloudAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_cloudAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_cloudAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_dataSchemaRev_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_rank_dataSchemaRev_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_dataSchemaRev_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_title() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_titleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_title_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title_changeAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_title_changeAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title_changeAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_title_cid_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title_cid_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByData_title_cid_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title_cid_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
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
      sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByUnknownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      sortByUnknownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.desc);
    });
  }
}

extension IsarDocumentStateQuerySortThenBy
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QSortThenBy> {
  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_changeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_changeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_changeAt_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeAt_orig_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_changeAt_orig_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeAt_orig_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_changeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_changeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_changeBy_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeBy_orig_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_changeBy_orig_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_changeBy_orig_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_cid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cid', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_cidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cid', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_cid_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cid_orig_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_cid_orig_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cid_orig_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_cloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_cloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_cloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_dataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_dataSchemaRev', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_dataSchemaRevDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_dataSchemaRev', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_domainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_domainId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_domainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_domainId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_domainId_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_domainId_orig_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByChange_domainId_orig_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'change_domainId_orig_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_contentLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_contentLength', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_contentLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_contentLength', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_changeAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_changeAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_changeAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_changeBy_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_changeBy_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_changeBy_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_changeBy_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_cid_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_cid_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_cid_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_cid_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_cloudAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_cloudAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_cloudAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_dataSchemaRev_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_deleted_dataSchemaRev_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_deleted_dataSchemaRev_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_changeAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_changeAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_changeAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_changeBy_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_changeBy_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_changeBy_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_changeBy_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_cid_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_cid_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_cid_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_cid_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_cloudAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_cloudAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_cloudAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_dataSchemaRev_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_parentId_dataSchemaRev_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_parentId_dataSchemaRev_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_changeAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_changeAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_changeAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_changeBy_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_changeBy_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_changeBy_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_changeBy_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_cid_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_cid_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_cid_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_cid_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_cloudAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_cloudAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_cloudAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_dataSchemaRev_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_rank_dataSchemaRev_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_rank_dataSchemaRev_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_title() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_titleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_title_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title_changeAt_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_title_changeAt_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title_changeAt_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_title_cid_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title_cid_', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByData_title_cid_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data_title_cid_', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
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
      thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByUnknownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.asc);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QAfterSortBy>
      thenByUnknownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.desc);
    });
  }
}

extension IsarDocumentStateQueryWhereDistinct
    on QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct> {
  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_changeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_changeAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_changeAt_orig_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_changeAt_orig_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_changeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_changeBy',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_changeBy_orig_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_changeBy_orig_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_cid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_cid_orig_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_cid_orig_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_cloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_cloudAt');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_dataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_dataSchemaRev');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_domainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_domainId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByChange_domainId_orig_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'change_domainId_orig_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_contentLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_contentLength');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_deleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_deleted');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_deleted_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_deleted_changeAt_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_deleted_changeBy_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_deleted_changeBy_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_deleted_cid_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_deleted_cid_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_deleted_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_deleted_cloudAt_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_deleted_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_deleted_dataSchemaRev_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_parentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_parentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_parentId_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_parentId_changeAt_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_parentId_changeBy_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_parentId_changeBy_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_parentId_cid_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_parentId_cid_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_parentId_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_parentId_cloudAt_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_parentId_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_parentId_dataSchemaRev_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_rank({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_rank', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_rank_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_rank_changeAt_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_rank_changeBy_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_rank_changeBy_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_rank_cid_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_rank_cid_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_rank_cloudAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_rank_cloudAt_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_rank_dataSchemaRev_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_rank_dataSchemaRev_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_title({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_title_changeAt_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_title_changeAt_');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByData_title_cid_({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data_title_cid_',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByDomainType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainType', caseSensitive: caseSensitive);
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
      distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<IsarDocumentState, IsarDocumentState, QDistinct>
      distinctByUnknownJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unknownJson', caseSensitive: caseSensitive);
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

  QueryBuilder<IsarDocumentState, DateTime, QQueryOperations>
      change_changeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_changeAt');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime, QQueryOperations>
      change_changeAt_orig_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_changeAt_orig_');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      change_changeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_changeBy');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      change_changeBy_orig_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_changeBy_orig_');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      change_cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_cid');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      change_cid_orig_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_cid_orig_');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      change_cloudAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_cloudAt');
    });
  }

  QueryBuilder<IsarDocumentState, int?, QQueryOperations>
      change_dataSchemaRevProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_dataSchemaRev');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      change_domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_domainId');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      change_domainId_orig_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'change_domainId_orig_');
    });
  }

  QueryBuilder<IsarDocumentState, int?, QQueryOperations>
      data_contentLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_contentLength');
    });
  }

  QueryBuilder<IsarDocumentState, bool?, QQueryOperations>
      data_deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_deleted');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      data_deleted_changeAt_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_deleted_changeAt_');
    });
  }

  QueryBuilder<IsarDocumentState, String?, QQueryOperations>
      data_deleted_changeBy_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_deleted_changeBy_');
    });
  }

  QueryBuilder<IsarDocumentState, String?, QQueryOperations>
      data_deleted_cid_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_deleted_cid_');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      data_deleted_cloudAt_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_deleted_cloudAt_');
    });
  }

  QueryBuilder<IsarDocumentState, int?, QQueryOperations>
      data_deleted_dataSchemaRev_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_deleted_dataSchemaRev_');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      data_parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_parentId');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime, QQueryOperations>
      data_parentId_changeAt_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_parentId_changeAt_');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      data_parentId_changeBy_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_parentId_changeBy_');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      data_parentId_cid_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_parentId_cid_');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      data_parentId_cloudAt_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_parentId_cloudAt_');
    });
  }

  QueryBuilder<IsarDocumentState, int?, QQueryOperations>
      data_parentId_dataSchemaRev_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_parentId_dataSchemaRev_');
    });
  }

  QueryBuilder<IsarDocumentState, String?, QQueryOperations>
      data_rankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_rank');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      data_rank_changeAt_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_rank_changeAt_');
    });
  }

  QueryBuilder<IsarDocumentState, String?, QQueryOperations>
      data_rank_changeBy_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_rank_changeBy_');
    });
  }

  QueryBuilder<IsarDocumentState, String?, QQueryOperations>
      data_rank_cid_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_rank_cid_');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      data_rank_cloudAt_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_rank_cloudAt_');
    });
  }

  QueryBuilder<IsarDocumentState, int?, QQueryOperations>
      data_rank_dataSchemaRev_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_rank_dataSchemaRev_');
    });
  }

  QueryBuilder<IsarDocumentState, String?, QQueryOperations>
      data_titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_title');
    });
  }

  QueryBuilder<IsarDocumentState, DateTime?, QQueryOperations>
      data_title_changeAt_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_title_changeAt_');
    });
  }

  QueryBuilder<IsarDocumentState, String?, QQueryOperations>
      data_title_cid_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data_title_cid_');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      domainTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainType');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<IsarDocumentState, int?, QQueryOperations>
      schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<IsarDocumentState, String, QQueryOperations>
      unknownJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unknownJson');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IsarDocumentState _$IsarDocumentStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'IsarDocumentState',
      json,
      ($checkedConvert) {
        final val = IsarDocumentState(
          id: $checkedConvert(
              'id', (v) => (v as num?)?.toInt() ?? Isar.autoIncrement),
          entityId: $checkedConvert('entityId', (v) => v as String),
          entityType:
              $checkedConvert('entityType', (v) => v as String? ?? 'document'),
          schemaVersion:
              $checkedConvert('schemaVersion', (v) => (v as num?)?.toInt()),
          unknownJson: $checkedConvert('unknownJson', (v) => v as String),
          change_domainId:
              $checkedConvert('change_domainId', (v) => v as String),
          change_domainId_orig_:
              $checkedConvert('change_domainId_orig_', (v) => v as String),
          change_changeAt: $checkedConvert(
              'change_changeAt', (v) => DateTime.parse(v as String)),
          change_changeAt_orig_: $checkedConvert(
              'change_changeAt_orig_', (v) => DateTime.parse(v as String)),
          change_cid: $checkedConvert('change_cid', (v) => v as String),
          change_cid_orig_:
              $checkedConvert('change_cid_orig_', (v) => v as String),
          change_dataSchemaRev: $checkedConvert(
              'change_dataSchemaRev', (v) => (v as num?)?.toInt()),
          change_cloudAt: $checkedConvert('change_cloudAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          change_changeBy:
              $checkedConvert('change_changeBy', (v) => v as String),
          change_changeBy_orig_:
              $checkedConvert('change_changeBy_orig_', (v) => v as String),
          data_rank_dataSchemaRev_: $checkedConvert(
              'data_rank_dataSchemaRev_', (v) => (v as num?)?.toInt()),
          data_rank: $checkedConvert('data_rank', (v) => v as String?),
          data_rank_changeAt_: $checkedConvert('data_rank_changeAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_rank_cid_:
              $checkedConvert('data_rank_cid_', (v) => v as String?),
          data_rank_changeBy_:
              $checkedConvert('data_rank_changeBy_', (v) => v as String?),
          data_rank_cloudAt_: $checkedConvert('data_rank_cloudAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_deleted: $checkedConvert('data_deleted', (v) => v as bool?),
          data_deleted_dataSchemaRev_: $checkedConvert(
              'data_deleted_dataSchemaRev_', (v) => (v as num?)?.toInt()),
          data_deleted_changeAt_: $checkedConvert('data_deleted_changeAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_deleted_cid_:
              $checkedConvert('data_deleted_cid_', (v) => v as String?),
          data_deleted_changeBy_:
              $checkedConvert('data_deleted_changeBy_', (v) => v as String?),
          data_deleted_cloudAt_: $checkedConvert('data_deleted_cloudAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_parentId: $checkedConvert('data_parentId', (v) => v as String),
          data_parentId_dataSchemaRev_: $checkedConvert(
              'data_parentId_dataSchemaRev_', (v) => (v as num?)?.toInt()),
          data_parentId_changeAt_: $checkedConvert(
              'data_parentId_changeAt_', (v) => DateTime.parse(v as String)),
          data_parentId_cid_:
              $checkedConvert('data_parentId_cid_', (v) => v as String),
          data_parentId_changeBy_:
              $checkedConvert('data_parentId_changeBy_', (v) => v as String),
          data_parentId_cloudAt_: $checkedConvert('data_parentId_cloudAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_title: $checkedConvert('data_title', (v) => v as String?),
          data_contentLength: $checkedConvert(
              'data_contentLength', (v) => (v as num?)?.toInt()),
          data_title_changeAt_: $checkedConvert('data_title_changeAt_',
              (v) => v == null ? null : DateTime.parse(v as String)),
          data_title_cid_:
              $checkedConvert('data_title_cid_', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$IsarDocumentStateToJson(IsarDocumentState instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'unknownJson': instance.unknownJson,
      'schemaVersion': instance.schemaVersion,
      'change_domainId': instance.change_domainId,
      'change_domainId_orig_': instance.change_domainId_orig_,
      'change_changeAt': instance.change_changeAt.toIso8601String(),
      'change_changeAt_orig_': instance.change_changeAt_orig_.toIso8601String(),
      'change_cid': instance.change_cid,
      'change_cid_orig_': instance.change_cid_orig_,
      'change_dataSchemaRev': instance.change_dataSchemaRev,
      'change_cloudAt': instance.change_cloudAt?.toIso8601String(),
      'change_changeBy': instance.change_changeBy,
      'change_changeBy_orig_': instance.change_changeBy_orig_,
      'data_rank': instance.data_rank,
      'data_rank_dataSchemaRev_': instance.data_rank_dataSchemaRev_,
      'data_rank_changeAt_': instance.data_rank_changeAt_?.toIso8601String(),
      'data_rank_cid_': instance.data_rank_cid_,
      'data_rank_changeBy_': instance.data_rank_changeBy_,
      'data_rank_cloudAt_': instance.data_rank_cloudAt_?.toIso8601String(),
      'data_deleted': instance.data_deleted,
      'data_deleted_dataSchemaRev_': instance.data_deleted_dataSchemaRev_,
      'data_deleted_changeAt_':
          instance.data_deleted_changeAt_?.toIso8601String(),
      'data_deleted_cid_': instance.data_deleted_cid_,
      'data_deleted_changeBy_': instance.data_deleted_changeBy_,
      'data_deleted_cloudAt_':
          instance.data_deleted_cloudAt_?.toIso8601String(),
      'data_parentId': instance.data_parentId,
      'data_parentId_dataSchemaRev_': instance.data_parentId_dataSchemaRev_,
      'data_parentId_changeAt_':
          instance.data_parentId_changeAt_.toIso8601String(),
      'data_parentId_cid_': instance.data_parentId_cid_,
      'data_parentId_changeBy_': instance.data_parentId_changeBy_,
      'data_parentId_cloudAt_':
          instance.data_parentId_cloudAt_?.toIso8601String(),
      'id': instance.id,
      'entityId': instance.entityId,
      'data_title': instance.data_title,
      'data_contentLength': instance.data_contentLength,
      'data_title_changeAt_': instance.data_title_changeAt_?.toIso8601String(),
      'data_title_cid_': instance.data_title_cid_,
    };
