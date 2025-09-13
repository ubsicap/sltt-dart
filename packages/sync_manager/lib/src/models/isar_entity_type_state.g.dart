// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_entity_type_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarEntityTypeSyncStateCollection on Isar {
  IsarCollection<IsarEntityTypeSyncState> get isarEntityTypeSyncStates =>
      this.collection();
}

const IsarEntityTypeSyncStateSchema = CollectionSchema(
  name: r'IsarEntityTypeSyncState',
  id: 2094836321068223920,
  properties: {
    r'changeAt': PropertySchema(
      id: 0,
      name: r'changeAt',
      type: IsarType.dateTime,
    ),
    r'cid': PropertySchema(
      id: 1,
      name: r'cid',
      type: IsarType.string,
    ),
    r'created': PropertySchema(
      id: 2,
      name: r'created',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deleted': PropertySchema(
      id: 4,
      name: r'deleted',
      type: IsarType.long,
    ),
    r'domainId': PropertySchema(
      id: 5,
      name: r'domainId',
      type: IsarType.string,
    ),
    r'domainType': PropertySchema(
      id: 6,
      name: r'domainType',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 7,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'seq': PropertySchema(
      id: 8,
      name: r'seq',
      type: IsarType.long,
    ),
    r'storageId': PropertySchema(
      id: 9,
      name: r'storageId',
      type: IsarType.string,
    ),
    r'storageType': PropertySchema(
      id: 10,
      name: r'storageType',
      type: IsarType.string,
    ),
    r'updated': PropertySchema(
      id: 11,
      name: r'updated',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _isarEntityTypeSyncStateEstimateSize,
  serialize: _isarEntityTypeSyncStateSerialize,
  deserialize: _isarEntityTypeSyncStateDeserialize,
  deserializeProp: _isarEntityTypeSyncStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'entityType_domainId': IndexSchema(
      id: 8189438628310890733,
      name: r'entityType_domainId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'entityType',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'domainId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarEntityTypeSyncStateGetId,
  getLinks: _isarEntityTypeSyncStateGetLinks,
  attach: _isarEntityTypeSyncStateAttach,
  version: '3.1.0+1',
);

int _isarEntityTypeSyncStateEstimateSize(
  IsarEntityTypeSyncState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.domainId.length * 3;
  bytesCount += 3 + object.domainType.length * 3;
  bytesCount += 3 + object.entityType.length * 3;
  bytesCount += 3 + object.storageId.length * 3;
  bytesCount += 3 + object.storageType.length * 3;
  return bytesCount;
}

void _isarEntityTypeSyncStateSerialize(
  IsarEntityTypeSyncState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.changeAt);
  writer.writeString(offsets[1], object.cid);
  writer.writeLong(offsets[2], object.created);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeLong(offsets[4], object.deleted);
  writer.writeString(offsets[5], object.domainId);
  writer.writeString(offsets[6], object.domainType);
  writer.writeString(offsets[7], object.entityType);
  writer.writeLong(offsets[8], object.seq);
  writer.writeString(offsets[9], object.storageId);
  writer.writeString(offsets[10], object.storageType);
  writer.writeLong(offsets[11], object.updated);
  writer.writeDateTime(offsets[12], object.updatedAt);
}

IsarEntityTypeSyncState _isarEntityTypeSyncStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarEntityTypeSyncState(
    changeAt: reader.readDateTime(offsets[0]),
    cid: reader.readString(offsets[1]),
    created: reader.readLongOrNull(offsets[2]) ?? 0,
    createdAt: reader.readDateTimeOrNull(offsets[3]),
    deleted: reader.readLongOrNull(offsets[4]) ?? 0,
    domainId: reader.readString(offsets[5]),
    domainType: reader.readString(offsets[6]),
    entityType: reader.readString(offsets[7]),
    id: id,
    seq: reader.readLong(offsets[8]),
    storageId: reader.readString(offsets[9]),
    storageType: reader.readString(offsets[10]),
    updated: reader.readLongOrNull(offsets[11]) ?? 0,
    updatedAt: reader.readDateTimeOrNull(offsets[12]),
  );
  return object;
}

P _isarEntityTypeSyncStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarEntityTypeSyncStateGetId(IsarEntityTypeSyncState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarEntityTypeSyncStateGetLinks(
    IsarEntityTypeSyncState object) {
  return [];
}

void _isarEntityTypeSyncStateAttach(
    IsarCollection<dynamic> col, Id id, IsarEntityTypeSyncState object) {}

extension IsarEntityTypeSyncStateByIndex
    on IsarCollection<IsarEntityTypeSyncState> {
  Future<IsarEntityTypeSyncState?> getByEntityTypeDomainId(
      String entityType, String domainId) {
    return getByIndex(r'entityType_domainId', [entityType, domainId]);
  }

  IsarEntityTypeSyncState? getByEntityTypeDomainIdSync(
      String entityType, String domainId) {
    return getByIndexSync(r'entityType_domainId', [entityType, domainId]);
  }

  Future<bool> deleteByEntityTypeDomainId(String entityType, String domainId) {
    return deleteByIndex(r'entityType_domainId', [entityType, domainId]);
  }

  bool deleteByEntityTypeDomainIdSync(String entityType, String domainId) {
    return deleteByIndexSync(r'entityType_domainId', [entityType, domainId]);
  }

  Future<List<IsarEntityTypeSyncState?>> getAllByEntityTypeDomainId(
      List<String> entityTypeValues, List<String> domainIdValues) {
    final len = entityTypeValues.length;
    assert(domainIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityTypeValues[i], domainIdValues[i]]);
    }

    return getAllByIndex(r'entityType_domainId', values);
  }

  List<IsarEntityTypeSyncState?> getAllByEntityTypeDomainIdSync(
      List<String> entityTypeValues, List<String> domainIdValues) {
    final len = entityTypeValues.length;
    assert(domainIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityTypeValues[i], domainIdValues[i]]);
    }

    return getAllByIndexSync(r'entityType_domainId', values);
  }

  Future<int> deleteAllByEntityTypeDomainId(
      List<String> entityTypeValues, List<String> domainIdValues) {
    final len = entityTypeValues.length;
    assert(domainIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityTypeValues[i], domainIdValues[i]]);
    }

    return deleteAllByIndex(r'entityType_domainId', values);
  }

  int deleteAllByEntityTypeDomainIdSync(
      List<String> entityTypeValues, List<String> domainIdValues) {
    final len = entityTypeValues.length;
    assert(domainIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityTypeValues[i], domainIdValues[i]]);
    }

    return deleteAllByIndexSync(r'entityType_domainId', values);
  }

  Future<Id> putByEntityTypeDomainId(IsarEntityTypeSyncState object) {
    return putByIndex(r'entityType_domainId', object);
  }

  Id putByEntityTypeDomainIdSync(IsarEntityTypeSyncState object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'entityType_domainId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntityTypeDomainId(
      List<IsarEntityTypeSyncState> objects) {
    return putAllByIndex(r'entityType_domainId', objects);
  }

  List<Id> putAllByEntityTypeDomainIdSync(List<IsarEntityTypeSyncState> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'entityType_domainId', objects,
        saveLinks: saveLinks);
  }
}

extension IsarEntityTypeSyncStateQueryWhereSort
    on QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QWhere> {
  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarEntityTypeSyncStateQueryWhere on QueryBuilder<
    IsarEntityTypeSyncState, IsarEntityTypeSyncState, QWhereClause> {
  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterWhereClause> entityTypeEqualToAnyDomainId(String entityType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityType_domainId',
        value: [entityType],
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterWhereClause> entityTypeNotEqualToAnyDomainId(String entityType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType_domainId',
              lower: [],
              upper: [entityType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType_domainId',
              lower: [entityType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType_domainId',
              lower: [entityType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType_domainId',
              lower: [],
              upper: [entityType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterWhereClause>
      entityTypeDomainIdEqualTo(String entityType, String domainId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityType_domainId',
        value: [entityType, domainId],
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterWhereClause>
      entityTypeEqualToDomainIdNotEqualTo(String entityType, String domainId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType_domainId',
              lower: [entityType],
              upper: [entityType, domainId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType_domainId',
              lower: [entityType, domainId],
              includeLower: false,
              upper: [entityType],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType_domainId',
              lower: [entityType, domainId],
              includeLower: false,
              upper: [entityType],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType_domainId',
              lower: [entityType],
              upper: [entityType, domainId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarEntityTypeSyncStateQueryFilter on QueryBuilder<
    IsarEntityTypeSyncState, IsarEntityTypeSyncState, QFilterCondition> {
  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> changeAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> changeAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> changeAtLessThan(
    DateTime value, {
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> changeAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> cidEqualTo(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> cidGreaterThan(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> cidLessThan(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> cidBetween(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> cidStartsWith(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> cidEndsWith(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      cidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      cidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'created',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> deletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deleted',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> deletedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deleted',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> deletedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deleted',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> deletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deleted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'domainId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      domainIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'domainId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      domainIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'domainId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'domainId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainTypeEqualTo(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainTypeGreaterThan(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainTypeLessThan(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainTypeBetween(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainTypeStartsWith(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainTypeEndsWith(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      domainTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'domainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      domainTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'domainType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> domainTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'domainType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> entityTypeEqualTo(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> entityTypeGreaterThan(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> entityTypeLessThan(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> entityTypeBetween(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> entityTypeStartsWith(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> entityTypeEndsWith(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> seqEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seq',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> seqGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'seq',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> seqLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'seq',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> seqBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'seq',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'storageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'storageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'storageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'storageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'storageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      storageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      storageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storageId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storageId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'storageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'storageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'storageType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'storageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'storageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      storageTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
          QAfterFilterCondition>
      storageTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storageType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storageType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> storageTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storageType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarEntityTypeSyncStateQueryObject on QueryBuilder<
    IsarEntityTypeSyncState, IsarEntityTypeSyncState, QFilterCondition> {}

extension IsarEntityTypeSyncStateQueryLinks on QueryBuilder<
    IsarEntityTypeSyncState, IsarEntityTypeSyncState, QFilterCondition> {}

extension IsarEntityTypeSyncStateQuerySortBy
    on QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QSortBy> {
  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortBySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortBySeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByStorageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByStorageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByStorageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageType', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByStorageTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageType', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updated', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updated', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IsarEntityTypeSyncStateQuerySortThenBy on QueryBuilder<
    IsarEntityTypeSyncState, IsarEntityTypeSyncState, QSortThenBy> {
  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenBySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenBySeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByStorageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByStorageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByStorageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageType', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByStorageTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageType', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updated', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updated', Sort.desc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IsarEntityTypeSyncStateQueryWhereDistinct on QueryBuilder<
    IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct> {
  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeAt');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'created');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByDomainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByDomainType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctBySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seq');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByStorageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByStorageType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storageType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updated');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, IsarEntityTypeSyncState, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension IsarEntityTypeSyncStateQueryProperty on QueryBuilder<
    IsarEntityTypeSyncState, IsarEntityTypeSyncState, QQueryProperty> {
  QueryBuilder<IsarEntityTypeSyncState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, DateTime, QQueryOperations>
      changeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeAt');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, String, QQueryOperations>
      cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, int, QQueryOperations>
      createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'created');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, int, QQueryOperations>
      deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, String, QQueryOperations>
      domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainId');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, String, QQueryOperations>
      domainTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainType');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, String, QQueryOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, int, QQueryOperations> seqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seq');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, String, QQueryOperations>
      storageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storageId');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, String, QQueryOperations>
      storageTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storageType');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, int, QQueryOperations>
      updatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updated');
    });
  }

  QueryBuilder<IsarEntityTypeSyncState, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
