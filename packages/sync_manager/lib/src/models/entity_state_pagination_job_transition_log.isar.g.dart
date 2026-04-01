// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_state_pagination_job_transition_log.isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEntityStatePaginationJobTransitionLogRecordCollection on Isar {
  IsarCollection<EntityStatePaginationJobTransitionLogRecord>
  get entityStatePaginationJobTransitionLogRecords => this.collection();
}

const EntityStatePaginationJobTransitionLogRecordSchema = CollectionSchema(
  name: r'EntityStatePaginationJobTransitionLogRecord',
  id: -3871392612584884887,
  properties: {
    r'cursor': PropertySchema(id: 0, name: r'cursor', type: IsarType.string),
    r'detailsJson': PropertySchema(
      id: 1,
      name: r'detailsJson',
      type: IsarType.string,
    ),
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
    r'entityId': PropertySchema(
      id: 4,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 5,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'fromStatus': PropertySchema(
      id: 6,
      name: r'fromStatus',
      type: IsarType.string,
    ),
    r'hasMore': PropertySchema(id: 7, name: r'hasMore', type: IsarType.bool),
    r'isCollection': PropertySchema(
      id: 8,
      name: r'isCollection',
      type: IsarType.bool,
    ),
    r'jobKey': PropertySchema(id: 9, name: r'jobKey', type: IsarType.string),
    r'jobRecordId': PropertySchema(
      id: 10,
      name: r'jobRecordId',
      type: IsarType.long,
    ),
    r'message': PropertySchema(id: 11, name: r'message', type: IsarType.string),
    r'parentId': PropertySchema(
      id: 12,
      name: r'parentId',
      type: IsarType.string,
    ),
    r'scopeKey': PropertySchema(
      id: 13,
      name: r'scopeKey',
      type: IsarType.string,
    ),
    r'toStatus': PropertySchema(
      id: 14,
      name: r'toStatus',
      type: IsarType.string,
    ),
    r'transitionAt': PropertySchema(
      id: 15,
      name: r'transitionAt',
      type: IsarType.dateTime,
    ),
    r'transitionType': PropertySchema(
      id: 16,
      name: r'transitionType',
      type: IsarType.string,
    ),
  },

  estimateSize: _entityStatePaginationJobTransitionLogRecordEstimateSize,
  serialize: _entityStatePaginationJobTransitionLogRecordSerialize,
  deserialize: _entityStatePaginationJobTransitionLogRecordDeserialize,
  deserializeProp: _entityStatePaginationJobTransitionLogRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'jobKey_transitionAt': IndexSchema(
      id: 8642683145479233693,
      name: r'jobKey_transitionAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'jobKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'transitionAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'fromStatus': IndexSchema(
      id: 8235042078430762137,
      name: r'fromStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fromStatus',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'toStatus': IndexSchema(
      id: -327892744042302685,
      name: r'toStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'toStatus',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'transitionType': IndexSchema(
      id: 7326430371951656436,
      name: r'transitionType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transitionType',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'transitionAt': IndexSchema(
      id: 6116347599710313564,
      name: r'transitionAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transitionAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _entityStatePaginationJobTransitionLogRecordGetId,
  getLinks: _entityStatePaginationJobTransitionLogRecordGetLinks,
  attach: _entityStatePaginationJobTransitionLogRecordAttach,
  version: '3.3.0',
);

int _entityStatePaginationJobTransitionLogRecordEstimateSize(
  EntityStatePaginationJobTransitionLogRecord object,
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
  {
    final value = object.detailsJson;
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
  bytesCount += 3 + object.fromStatus.length * 3;
  bytesCount += 3 + object.jobKey.length * 3;
  {
    final value = object.message;
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
  bytesCount += 3 + object.scopeKey.length * 3;
  bytesCount += 3 + object.toStatus.length * 3;
  bytesCount += 3 + object.transitionType.length * 3;
  return bytesCount;
}

void _entityStatePaginationJobTransitionLogRecordSerialize(
  EntityStatePaginationJobTransitionLogRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cursor);
  writer.writeString(offsets[1], object.detailsJson);
  writer.writeString(offsets[2], object.domainId);
  writer.writeString(offsets[3], object.domainType);
  writer.writeString(offsets[4], object.entityId);
  writer.writeString(offsets[5], object.entityType);
  writer.writeString(offsets[6], object.fromStatus);
  writer.writeBool(offsets[7], object.hasMore);
  writer.writeBool(offsets[8], object.isCollection);
  writer.writeString(offsets[9], object.jobKey);
  writer.writeLong(offsets[10], object.jobRecordId);
  writer.writeString(offsets[11], object.message);
  writer.writeString(offsets[12], object.parentId);
  writer.writeString(offsets[13], object.scopeKey);
  writer.writeString(offsets[14], object.toStatus);
  writer.writeDateTime(offsets[15], object.transitionAt);
  writer.writeString(offsets[16], object.transitionType);
}

EntityStatePaginationJobTransitionLogRecord
_entityStatePaginationJobTransitionLogRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EntityStatePaginationJobTransitionLogRecord(
    cursor: reader.readStringOrNull(offsets[0]),
    detailsJson: reader.readStringOrNull(offsets[1]),
    domainId: reader.readString(offsets[2]),
    domainType: reader.readString(offsets[3]),
    entityId: reader.readStringOrNull(offsets[4]),
    entityType: reader.readString(offsets[5]),
    fromStatus: reader.readString(offsets[6]),
    hasMore: reader.readBoolOrNull(offsets[7]),
    id: id,
    isCollection: reader.readBool(offsets[8]),
    jobKey: reader.readString(offsets[9]),
    jobRecordId: reader.readLongOrNull(offsets[10]),
    message: reader.readStringOrNull(offsets[11]),
    parentId: reader.readStringOrNull(offsets[12]),
    scopeKey: reader.readString(offsets[13]),
    toStatus: reader.readString(offsets[14]),
    transitionAt: reader.readDateTime(offsets[15]),
    transitionType: reader.readString(offsets[16]),
  );
  return object;
}

P _entityStatePaginationJobTransitionLogRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _entityStatePaginationJobTransitionLogRecordGetId(
  EntityStatePaginationJobTransitionLogRecord object,
) {
  return object.id;
}

List<IsarLinkBase<dynamic>>
_entityStatePaginationJobTransitionLogRecordGetLinks(
  EntityStatePaginationJobTransitionLogRecord object,
) {
  return [];
}

void _entityStatePaginationJobTransitionLogRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  EntityStatePaginationJobTransitionLogRecord object,
) {
  object.id = id;
}

extension EntityStatePaginationJobTransitionLogRecordQueryWhereSort
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QWhere
        > {
  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhere
  >
  anyTransitionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'transitionAt'),
      );
    });
  }
}

extension EntityStatePaginationJobTransitionLogRecordQueryWhere
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QWhereClause
        > {
  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  jobKeyEqualToAnyTransitionAt(String jobKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'jobKey_transitionAt',
          value: [jobKey],
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  jobKeyNotEqualToAnyTransitionAt(String jobKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey_transitionAt',
                lower: [],
                upper: [jobKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey_transitionAt',
                lower: [jobKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey_transitionAt',
                lower: [jobKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey_transitionAt',
                lower: [],
                upper: [jobKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  jobKeyTransitionAtEqualTo(String jobKey, DateTime transitionAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'jobKey_transitionAt',
          value: [jobKey, transitionAt],
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  jobKeyEqualToTransitionAtNotEqualTo(String jobKey, DateTime transitionAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey_transitionAt',
                lower: [jobKey],
                upper: [jobKey, transitionAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey_transitionAt',
                lower: [jobKey, transitionAt],
                includeLower: false,
                upper: [jobKey],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey_transitionAt',
                lower: [jobKey, transitionAt],
                includeLower: false,
                upper: [jobKey],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'jobKey_transitionAt',
                lower: [jobKey],
                upper: [jobKey, transitionAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  jobKeyEqualToTransitionAtGreaterThan(
    String jobKey,
    DateTime transitionAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'jobKey_transitionAt',
          lower: [jobKey, transitionAt],
          includeLower: include,
          upper: [jobKey],
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  jobKeyEqualToTransitionAtLessThan(
    String jobKey,
    DateTime transitionAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'jobKey_transitionAt',
          lower: [jobKey],
          upper: [jobKey, transitionAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  jobKeyEqualToTransitionAtBetween(
    String jobKey,
    DateTime lowerTransitionAt,
    DateTime upperTransitionAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'jobKey_transitionAt',
          lower: [jobKey, lowerTransitionAt],
          includeLower: includeLower,
          upper: [jobKey, upperTransitionAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  fromStatusEqualTo(String fromStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'fromStatus', value: [fromStatus]),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  fromStatusNotEqualTo(String fromStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fromStatus',
                lower: [],
                upper: [fromStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fromStatus',
                lower: [fromStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fromStatus',
                lower: [fromStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fromStatus',
                lower: [],
                upper: [fromStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  toStatusEqualTo(String toStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'toStatus', value: [toStatus]),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  toStatusNotEqualTo(String toStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'toStatus',
                lower: [],
                upper: [toStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'toStatus',
                lower: [toStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'toStatus',
                lower: [toStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'toStatus',
                lower: [],
                upper: [toStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  transitionTypeEqualTo(String transitionType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'transitionType',
          value: [transitionType],
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  transitionTypeNotEqualTo(String transitionType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transitionType',
                lower: [],
                upper: [transitionType],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transitionType',
                lower: [transitionType],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transitionType',
                lower: [transitionType],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transitionType',
                lower: [],
                upper: [transitionType],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  transitionAtEqualTo(DateTime transitionAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'transitionAt',
          value: [transitionAt],
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  transitionAtNotEqualTo(DateTime transitionAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transitionAt',
                lower: [],
                upper: [transitionAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transitionAt',
                lower: [transitionAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transitionAt',
                lower: [transitionAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transitionAt',
                lower: [],
                upper: [transitionAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  transitionAtGreaterThan(DateTime transitionAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transitionAt',
          lower: [transitionAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  transitionAtLessThan(DateTime transitionAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transitionAt',
          lower: [],
          upper: [transitionAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterWhereClause
  >
  transitionAtBetween(
    DateTime lowerTransitionAt,
    DateTime upperTransitionAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transitionAt',
          lower: [lowerTransitionAt],
          includeLower: includeLower,
          upper: [upperTransitionAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EntityStatePaginationJobTransitionLogRecordQueryFilter
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QFilterCondition
        > {
  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'detailsJson'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'detailsJson'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'detailsJson',
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'detailsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'detailsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'detailsJson', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  detailsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'detailsJson', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fromStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fromStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fromStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fromStatus',
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fromStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fromStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fromStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fromStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fromStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  fromStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fromStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  jobRecordIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'jobRecordId'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  jobRecordIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'jobRecordId'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  jobRecordIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'jobRecordId', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  jobRecordIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'jobRecordId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  jobRecordIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'jobRecordId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  jobRecordIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'jobRecordId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'message'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'message'),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'message',
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'message',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'message', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'message', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'toStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'toStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'toStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'toStatus',
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'toStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'toStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'toStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'toStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'toStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  toStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'toStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transitionAt', value: value),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transitionAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transitionAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transitionAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'transitionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transitionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transitionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transitionType',
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
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'transitionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'transitionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'transitionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'transitionType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transitionType', value: ''),
      );
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterFilterCondition
  >
  transitionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'transitionType', value: ''),
      );
    });
  }
}

extension EntityStatePaginationJobTransitionLogRecordQueryObject
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QFilterCondition
        > {}

extension EntityStatePaginationJobTransitionLogRecordQueryLinks
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QFilterCondition
        > {}

extension EntityStatePaginationJobTransitionLogRecordQuerySortBy
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QSortBy
        > {
  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByFromStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromStatus', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByFromStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromStatus', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByHasMore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMore', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByHasMoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMore', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByIsCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollection', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByIsCollectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollection', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByJobKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobKey', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByJobKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobKey', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByJobRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobRecordId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByJobRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobRecordId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByScopeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeKey', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByScopeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeKey', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByToStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toStatus', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByToStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toStatus', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByTransitionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionAt', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByTransitionAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionAt', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByTransitionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  sortByTransitionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionType', Sort.desc);
    });
  }
}

extension EntityStatePaginationJobTransitionLogRecordQuerySortThenBy
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QSortThenBy
        > {
  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detailsJson', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByFromStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromStatus', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByFromStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromStatus', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByHasMore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMore', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByHasMoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMore', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByIsCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollection', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByIsCollectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollection', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByJobKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobKey', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByJobKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobKey', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByJobRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobRecordId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByJobRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobRecordId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByScopeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeKey', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByScopeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeKey', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByToStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toStatus', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByToStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toStatus', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByTransitionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionAt', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByTransitionAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionAt', Sort.desc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByTransitionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionType', Sort.asc);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QAfterSortBy
  >
  thenByTransitionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionType', Sort.desc);
    });
  }
}

extension EntityStatePaginationJobTransitionLogRecordQueryWhereDistinct
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QDistinct
        > {
  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByCursor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cursor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByDetailsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detailsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByDomainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByDomainType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByFromStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByHasMore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasMore');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByIsCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCollection');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByJobKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jobKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByJobRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jobRecordId');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'message', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByParentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByScopeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scopeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByToStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByTransitionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transitionAt');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    EntityStatePaginationJobTransitionLogRecord,
    QDistinct
  >
  distinctByTransitionType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'transitionType',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension EntityStatePaginationJobTransitionLogRecordQueryProperty
    on
        QueryBuilder<
          EntityStatePaginationJobTransitionLogRecord,
          EntityStatePaginationJobTransitionLogRecord,
          QQueryProperty
        > {
  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    int,
    QQueryOperations
  >
  idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String?,
    QQueryOperations
  >
  cursorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cursor');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String?,
    QQueryOperations
  >
  detailsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detailsJson');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String,
    QQueryOperations
  >
  domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainId');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String,
    QQueryOperations
  >
  domainTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainType');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String?,
    QQueryOperations
  >
  entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String,
    QQueryOperations
  >
  entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String,
    QQueryOperations
  >
  fromStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromStatus');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    bool?,
    QQueryOperations
  >
  hasMoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasMore');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    bool,
    QQueryOperations
  >
  isCollectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCollection');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String,
    QQueryOperations
  >
  jobKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jobKey');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    int?,
    QQueryOperations
  >
  jobRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jobRecordId');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String?,
    QQueryOperations
  >
  messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'message');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String?,
    QQueryOperations
  >
  parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String,
    QQueryOperations
  >
  scopeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scopeKey');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String,
    QQueryOperations
  >
  toStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toStatus');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    DateTime,
    QQueryOperations
  >
  transitionAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transitionAt');
    });
  }

  QueryBuilder<
    EntityStatePaginationJobTransitionLogRecord,
    String,
    QQueryOperations
  >
  transitionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transitionType');
    });
  }
}
