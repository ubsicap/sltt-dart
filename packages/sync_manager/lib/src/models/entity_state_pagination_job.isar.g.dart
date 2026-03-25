// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_state_pagination_job.isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEntityStatePaginationJobRecordCollection on Isar {
  IsarCollection<EntityStatePaginationJobRecord>
  get entityStatePaginationJobRecords => this.collection();
}

const EntityStatePaginationJobRecordSchema = CollectionSchema(
  name: r'EntityStatePaginationJobRecord',
  id: 607910659633697379,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'cursor': PropertySchema(id: 1, name: r'cursor', type: IsarType.string),
    r'domainId': PropertySchema(
      id: 2,
      name: r'domainId',
      type: IsarType.string,
    ),
    r'domainType': PropertySchema(
      id: 3,
      name: r'domainType',
      type: IsarType.string,
    ),
    r'enqueuedAt': PropertySchema(
      id: 4,
      name: r'enqueuedAt',
      type: IsarType.dateTime,
    ),
    r'entityId': PropertySchema(
      id: 5,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 6,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'hasMore': PropertySchema(id: 7, name: r'hasMore', type: IsarType.bool),
    r'isCollection': PropertySchema(
      id: 8,
      name: r'isCollection',
      type: IsarType.bool,
    ),
    r'jobKey': PropertySchema(id: 9, name: r'jobKey', type: IsarType.string),
    r'lastError': PropertySchema(
      id: 10,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'limit': PropertySchema(id: 11, name: r'limit', type: IsarType.long),
    r'parentId': PropertySchema(
      id: 12,
      name: r'parentId',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 13,
      name: r'priority',
      type: IsarType.string,
    ),
    r'scopeKey': PropertySchema(
      id: 14,
      name: r'scopeKey',
      type: IsarType.string,
    ),
    r'startedAt': PropertySchema(
      id: 15,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(id: 16, name: r'status', type: IsarType.string),
  },

  estimateSize: _entityStatePaginationJobRecordEstimateSize,
  serialize: _entityStatePaginationJobRecordSerialize,
  deserialize: _entityStatePaginationJobRecordDeserialize,
  deserializeProp: _entityStatePaginationJobRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'jobKey': IndexSchema(
      id: 2761579878982916397,
      name: r'jobKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'jobKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'scopeKey': IndexSchema(
      id: -388923758492624597,
      name: r'scopeKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scopeKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'enqueuedAt': IndexSchema(
      id: -4839139693606149152,
      name: r'enqueuedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'enqueuedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _entityStatePaginationJobRecordGetId,
  getLinks: _entityStatePaginationJobRecordGetLinks,
  attach: _entityStatePaginationJobRecordAttach,
  version: '3.3.0',
);

int _entityStatePaginationJobRecordEstimateSize(
  EntityStatePaginationJobRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cursor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.domainId.length * 3;
  bytesCount += 3 + object.domainType.length * 3;
  {
    final value = object.entityId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.entityType.length * 3;
  bytesCount += 3 + object.jobKey.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.priority.length * 3;
  bytesCount += 3 + object.scopeKey.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _entityStatePaginationJobRecordSerialize(
  EntityStatePaginationJobRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeString(offsets[1], object.cursor);
  writer.writeString(offsets[2], object.domainId);
  writer.writeString(offsets[3], object.domainType);
  writer.writeDateTime(offsets[4], object.enqueuedAt);
  writer.writeString(offsets[5], object.entityId);
  writer.writeString(offsets[6], object.entityType);
  writer.writeBool(offsets[7], object.hasMore);
  writer.writeBool(offsets[8], object.isCollection);
  writer.writeString(offsets[9], object.jobKey);
  writer.writeString(offsets[10], object.lastError);
  writer.writeLong(offsets[11], object.limit);
  writer.writeString(offsets[12], object.parentId);
  writer.writeString(offsets[13], object.priority);
  writer.writeString(offsets[14], object.scopeKey);
  writer.writeDateTime(offsets[15], object.startedAt);
  writer.writeString(offsets[16], object.status);
}

EntityStatePaginationJobRecord _entityStatePaginationJobRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EntityStatePaginationJobRecord(
    completedAt: reader.readDateTimeOrNull(offsets[0]),
    cursor: reader.readStringOrNull(offsets[1]),
    domainId: reader.readString(offsets[2]),
    domainType: reader.readString(offsets[3]),
    enqueuedAt: reader.readDateTime(offsets[4]),
    entityId: reader.readStringOrNull(offsets[5]),
    entityType: reader.readString(offsets[6]),
    hasMore: reader.readBoolOrNull(offsets[7]),
    id: id,
    isCollection: reader.readBool(offsets[8]),
    jobKey: reader.readString(offsets[9]),
    lastError: reader.readStringOrNull(offsets[10]),
    limit: reader.readLongOrNull(offsets[11]),
    parentId: reader.readStringOrNull(offsets[12]),
    priority: reader.readString(offsets[13]),
    scopeKey: reader.readString(offsets[14]),
    startedAt: reader.readDateTimeOrNull(offsets[15]),
    status: reader.readString(offsets[16]),
  );
  return object;
}

P _entityStatePaginationJobRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _entityStatePaginationJobRecordGetId(EntityStatePaginationJobRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _entityStatePaginationJobRecordGetLinks(
  EntityStatePaginationJobRecord object,
) {
  return [];
}

void _entityStatePaginationJobRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  EntityStatePaginationJobRecord object,
) {
  object.id = id;
}

extension EntityStatePaginationJobRecordByIndex
    on IsarCollection<EntityStatePaginationJobRecord> {
  Future<EntityStatePaginationJobRecord?> getByJobKey(String jobKey) {
    return getByIndex(r'jobKey', [jobKey]);
  }

  EntityStatePaginationJobRecord? getByJobKeySync(String jobKey) {
    return getByIndexSync(r'jobKey', [jobKey]);
  }

  Future<bool> deleteByJobKey(String jobKey) {
    return deleteByIndex(r'jobKey', [jobKey]);
  }

  bool deleteByJobKeySync(String jobKey) {
    return deleteByIndexSync(r'jobKey', [jobKey]);
  }

  Future<List<EntityStatePaginationJobRecord?>> getAllByJobKey(
    List<String> jobKeyValues,
  ) {
    final values = jobKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'jobKey', values);
  }

  List<EntityStatePaginationJobRecord?> getAllByJobKeySync(
    List<String> jobKeyValues,
  ) {
    final values = jobKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'jobKey', values);
  }

  Future<int> deleteAllByJobKey(List<String> jobKeyValues) {
    final values = jobKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'jobKey', values);
  }

  int deleteAllByJobKeySync(List<String> jobKeyValues) {
    final values = jobKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'jobKey', values);
  }

  Future<Id> putByJobKey(EntityStatePaginationJobRecord object) {
    return putByIndex(r'jobKey', object);
  }

  Id putByJobKeySync(
    EntityStatePaginationJobRecord object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'jobKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByJobKey(
    List<EntityStatePaginationJobRecord> objects,
  ) {
    return putAllByIndex(r'jobKey', objects);
  }

  List<Id> putAllByJobKeySync(
    List<EntityStatePaginationJobRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'jobKey', objects, saveLinks: saveLinks);
  }
}

extension EntityStatePaginationJobRecordQueryWhereSort
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QWhere
        > {
  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhere
  >
  anyEnqueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'enqueuedAt'),
      );
    });
  }
}

extension EntityStatePaginationJobRecordQueryWhere
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QWhereClause
        > {
  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
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

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  jobKeyEqualTo(String jobKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'jobKey', value: [jobKey]),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  jobKeyNotEqualTo(String jobKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey',
                lower: [],
                upper: [jobKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey',
                lower: [jobKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey',
                lower: [jobKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey',
                lower: [],
                upper: [jobKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  scopeKeyEqualTo(String scopeKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'scopeKey', value: [scopeKey]),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  scopeKeyNotEqualTo(String scopeKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scopeKey',
                lower: [],
                upper: [scopeKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scopeKey',
                lower: [scopeKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scopeKey',
                lower: [scopeKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scopeKey',
                lower: [],
                upper: [scopeKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  enqueuedAtEqualTo(DateTime enqueuedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'enqueuedAt', value: [enqueuedAt]),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  enqueuedAtNotEqualTo(DateTime enqueuedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'enqueuedAt',
                lower: [],
                upper: [enqueuedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'enqueuedAt',
                lower: [enqueuedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'enqueuedAt',
                lower: [enqueuedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'enqueuedAt',
                lower: [],
                upper: [enqueuedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  enqueuedAtGreaterThan(DateTime enqueuedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'enqueuedAt',
          lower: [enqueuedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  enqueuedAtLessThan(DateTime enqueuedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'enqueuedAt',
          lower: [],
          upper: [enqueuedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterWhereClause
  >
  enqueuedAtBetween(
    DateTime lowerEnqueuedAt,
    DateTime upperEnqueuedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'enqueuedAt',
          lower: [lowerEnqueuedAt],
          includeLower: includeLower,
          upper: [upperEnqueuedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EntityStatePaginationJobRecordQueryFilter
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QFilterCondition
        > {
  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  completedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  completedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cursor'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cursor'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cursor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cursor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cursor',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cursor', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  cursorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cursor', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'domainId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'domainId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'domainId', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'domainId', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'domainType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'domainType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'domainType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'domainType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'domainType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'domainType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'domainType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'domainType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'domainType', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  domainTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'domainType', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  enqueuedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enqueuedAt', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  enqueuedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'enqueuedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  enqueuedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'enqueuedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  enqueuedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'enqueuedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'entityId'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'entityId'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityType', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityType', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  hasMoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'hasMore'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  hasMoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'hasMore'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  hasMoreEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasMore', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  isCollectionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isCollection', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'jobKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'jobKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'jobKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'jobKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'jobKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'jobKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'jobKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'jobKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'jobKey', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  jobKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'jobKey', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  limitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'limit'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  limitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'limit'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  limitEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'limit', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  limitGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'limit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  limitLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'limit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  limitBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'limit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'parentId'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'parentId'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parentId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parentId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parentId', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  parentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parentId', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'priority',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'priority',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'priority', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  priorityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'priority', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'scopeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'scopeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'scopeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'scopeKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'scopeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'scopeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'scopeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'scopeKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'scopeKey', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  scopeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'scopeKey', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  startedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'startedAt'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  startedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'startedAt'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  startedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  startedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  startedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  startedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterFilterCondition
  >
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }
}

extension EntityStatePaginationJobRecordQueryObject
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QFilterCondition
        > {}

extension EntityStatePaginationJobRecordQueryLinks
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QFilterCondition
        > {}

extension EntityStatePaginationJobRecordQuerySortBy
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QSortBy
        > {
  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByEnqueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enqueuedAt', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByEnqueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enqueuedAt', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByHasMore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMore', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByHasMoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMore', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByIsCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollection', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByIsCollectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollection', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByJobKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobKey', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByJobKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobKey', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limit', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limit', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByScopeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeKey', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByScopeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeKey', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension EntityStatePaginationJobRecordQuerySortThenBy
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QSortThenBy
        > {
  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByEnqueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enqueuedAt', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByEnqueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enqueuedAt', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByHasMore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMore', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByHasMoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMore', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByIsCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollection', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByIsCollectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollection', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByJobKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobKey', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByJobKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobKey', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limit', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limit', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByScopeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeKey', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByScopeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeKey', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QAfterSortBy
  >
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension EntityStatePaginationJobRecordQueryWhereDistinct
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QDistinct
        > {
  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByCursor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cursor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByDomainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByDomainType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByEnqueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enqueuedAt');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByHasMore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasMore');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByIsCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCollection');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByJobKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jobKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'limit');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByParentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByPriority({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByScopeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scopeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobRecord,
    EntityStatePaginationJobRecord,
    QDistinct
  >
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension EntityStatePaginationJobRecordQueryProperty
    on
        QueryBuilder<
          EntityStatePaginationJobRecord,
          EntityStatePaginationJobRecord,
          QQueryProperty
        > {
  QueryBuilder<EntityStatePaginationJobRecord, int, QQueryOperations>
  idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, DateTime?, QQueryOperations>
  completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String?, QQueryOperations>
  cursorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cursor');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String, QQueryOperations>
  domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainId');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String, QQueryOperations>
  domainTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainType');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, DateTime, QQueryOperations>
  enqueuedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enqueuedAt');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String?, QQueryOperations>
  entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String, QQueryOperations>
  entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, bool?, QQueryOperations>
  hasMoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasMore');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, bool, QQueryOperations>
  isCollectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCollection');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String, QQueryOperations>
  jobKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jobKey');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String?, QQueryOperations>
  lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, int?, QQueryOperations>
  limitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'limit');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String?, QQueryOperations>
  parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String, QQueryOperations>
  priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String, QQueryOperations>
  scopeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scopeKey');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, DateTime?, QQueryOperations>
  startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<EntityStatePaginationJobRecord, String, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
