// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncStateCollection on Isar {
  IsarCollection<SyncState> get syncStates => this.collection();
}

const SyncStateSchema = CollectionSchema(
  name: r'SyncState',
  id: 8359124993045979625,
  properties: {
    r'changeLogId': PropertySchema(
      id: 0,
      name: r'changeLogId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'lastChangeAt': PropertySchema(
      id: 2,
      name: r'lastChangeAt',
      type: IsarType.dateTime,
    ),
    r'lastSeq': PropertySchema(
      id: 3,
      name: r'lastSeq',
      type: IsarType.long,
    ),
    r'projectId': PropertySchema(
      id: 4,
      name: r'projectId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _syncStateEstimateSize,
  serialize: _syncStateSerialize,
  deserialize: _syncStateDeserialize,
  deserializeProp: _syncStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'projectId': IndexSchema(
      id: 3305656282123791113,
      name: r'projectId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'projectId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncStateGetId,
  getLinks: _syncStateGetLinks,
  attach: _syncStateAttach,
  version: '3.1.0+1',
);

int _syncStateEstimateSize(
  SyncState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.changeLogId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.projectId.length * 3;
  return bytesCount;
}

void _syncStateSerialize(
  SyncState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.changeLogId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDateTime(offsets[2], object.lastChangeAt);
  writer.writeLong(offsets[3], object.lastSeq);
  writer.writeString(offsets[4], object.projectId);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

SyncState _syncStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncState();
  object.changeLogId = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.lastChangeAt = reader.readDateTimeOrNull(offsets[2]);
  object.lastSeq = reader.readLongOrNull(offsets[3]);
  object.projectId = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _syncStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncStateGetId(SyncState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncStateGetLinks(SyncState object) {
  return [];
}

void _syncStateAttach(IsarCollection<dynamic> col, Id id, SyncState object) {
  object.id = id;
}

extension SyncStateByIndex on IsarCollection<SyncState> {
  Future<SyncState?> getByProjectId(String projectId) {
    return getByIndex(r'projectId', [projectId]);
  }

  SyncState? getByProjectIdSync(String projectId) {
    return getByIndexSync(r'projectId', [projectId]);
  }

  Future<bool> deleteByProjectId(String projectId) {
    return deleteByIndex(r'projectId', [projectId]);
  }

  bool deleteByProjectIdSync(String projectId) {
    return deleteByIndexSync(r'projectId', [projectId]);
  }

  Future<List<SyncState?>> getAllByProjectId(List<String> projectIdValues) {
    final values = projectIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'projectId', values);
  }

  List<SyncState?> getAllByProjectIdSync(List<String> projectIdValues) {
    final values = projectIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'projectId', values);
  }

  Future<int> deleteAllByProjectId(List<String> projectIdValues) {
    final values = projectIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'projectId', values);
  }

  int deleteAllByProjectIdSync(List<String> projectIdValues) {
    final values = projectIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'projectId', values);
  }

  Future<Id> putByProjectId(SyncState object) {
    return putByIndex(r'projectId', object);
  }

  Id putByProjectIdSync(SyncState object, {bool saveLinks = true}) {
    return putByIndexSync(r'projectId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProjectId(List<SyncState> objects) {
    return putAllByIndex(r'projectId', objects);
  }

  List<Id> putAllByProjectIdSync(List<SyncState> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'projectId', objects, saveLinks: saveLinks);
  }
}

extension SyncStateQueryWhereSort
    on QueryBuilder<SyncState, SyncState, QWhere> {
  QueryBuilder<SyncState, SyncState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension SyncStateQueryWhere
    on QueryBuilder<SyncState, SyncState, QWhereClause> {
  QueryBuilder<SyncState, SyncState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> idBetween(
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

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> projectIdEqualTo(
      String projectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'projectId',
        value: [projectId],
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> projectIdNotEqualTo(
      String projectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [],
              upper: [projectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [projectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [projectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [],
              upper: [projectId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> createdAtEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> createdAtNotEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> updatedAtEqualTo(
      DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> updatedAtNotEqualTo(
      DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterWhereClause> updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncStateQueryFilter
    on QueryBuilder<SyncState, SyncState, QFilterCondition> {
  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      changeLogIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'changeLogId',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      changeLogIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'changeLogId',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> changeLogIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeLogId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      changeLogIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changeLogId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> changeLogIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changeLogId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> changeLogIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changeLogId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      changeLogIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'changeLogId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> changeLogIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'changeLogId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> changeLogIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'changeLogId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> changeLogIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'changeLogId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      changeLogIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeLogId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      changeLogIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'changeLogId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      lastChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastChangeAt',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      lastChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastChangeAt',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> lastChangeAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      lastChangeAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      lastChangeAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastChangeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> lastChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastChangeAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> lastSeqIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSeq',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> lastSeqIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSeq',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> lastSeqEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> lastSeqGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> lastSeqLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeq',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> lastSeqBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeq',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> projectIdEqualTo(
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> projectIdLessThan(
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> projectIdBetween(
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> projectIdStartsWith(
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> projectIdEndsWith(
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> projectIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> projectIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> projectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      projectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<SyncState, SyncState, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

extension SyncStateQueryObject
    on QueryBuilder<SyncState, SyncState, QFilterCondition> {}

extension SyncStateQueryLinks
    on QueryBuilder<SyncState, SyncState, QFilterCondition> {}

extension SyncStateQuerySortBy on QueryBuilder<SyncState, SyncState, QSortBy> {
  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByChangeLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeLogId', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByChangeLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeLogId', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByLastChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChangeAt', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByLastChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChangeAt', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByLastSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeq', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByLastSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeq', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SyncStateQuerySortThenBy
    on QueryBuilder<SyncState, SyncState, QSortThenBy> {
  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByChangeLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeLogId', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByChangeLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeLogId', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByLastChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChangeAt', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByLastChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChangeAt', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByLastSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeq', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByLastSeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeq', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncState, SyncState, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SyncStateQueryWhereDistinct
    on QueryBuilder<SyncState, SyncState, QDistinct> {
  QueryBuilder<SyncState, SyncState, QDistinct> distinctByChangeLogId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeLogId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncState, SyncState, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SyncState, SyncState, QDistinct> distinctByLastChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastChangeAt');
    });
  }

  QueryBuilder<SyncState, SyncState, QDistinct> distinctByLastSeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeq');
    });
  }

  QueryBuilder<SyncState, SyncState, QDistinct> distinctByProjectId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncState, SyncState, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SyncStateQueryProperty
    on QueryBuilder<SyncState, SyncState, QQueryProperty> {
  QueryBuilder<SyncState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncState, String?, QQueryOperations> changeLogIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeLogId');
    });
  }

  QueryBuilder<SyncState, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SyncState, DateTime?, QQueryOperations> lastChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastChangeAt');
    });
  }

  QueryBuilder<SyncState, int?, QQueryOperations> lastSeqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeq');
    });
  }

  QueryBuilder<SyncState, String, QQueryOperations> projectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectId');
    });
  }

  QueryBuilder<SyncState, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
