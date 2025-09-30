// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_change_log_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarChangeLogEntryCollection on Isar {
  IsarCollection<IsarChangeLogEntry> get isarChangeLogEntrys =>
      this.collection();
}

const IsarChangeLogEntrySchema = CollectionSchema(
  name: r'IsarChangeLogEntry',
  id: 2453136887945526353,
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
    r'cid': PropertySchema(id: 2, name: r'cid', type: IsarType.string),
    r'cloudAt': PropertySchema(
      id: 3,
      name: r'cloudAt',
      type: IsarType.dateTime,
    ),
    r'dataJson': PropertySchema(
      id: 4,
      name: r'dataJson',
      type: IsarType.string,
    ),
    r'dataSchemaRev': PropertySchema(
      id: 5,
      name: r'dataSchemaRev',
      type: IsarType.long,
    ),
    r'domainId': PropertySchema(
      id: 6,
      name: r'domainId',
      type: IsarType.string,
    ),
    r'domainType': PropertySchema(
      id: 7,
      name: r'domainType',
      type: IsarType.string,
    ),
    r'entityId': PropertySchema(
      id: 8,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 9,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'operation': PropertySchema(
      id: 10,
      name: r'operation',
      type: IsarType.string,
    ),
    r'operationInfoJson': PropertySchema(
      id: 11,
      name: r'operationInfoJson',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 12,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'stateChanged': PropertySchema(
      id: 13,
      name: r'stateChanged',
      type: IsarType.bool,
    ),
    r'storageId': PropertySchema(
      id: 14,
      name: r'storageId',
      type: IsarType.string,
    ),
    r'storedAt': PropertySchema(
      id: 15,
      name: r'storedAt',
      type: IsarType.dateTime,
    ),
    r'unknownJson': PropertySchema(
      id: 16,
      name: r'unknownJson',
      type: IsarType.string,
    ),
  },

  estimateSize: _isarChangeLogEntryEstimateSize,
  serialize: _isarChangeLogEntrySerialize,
  deserialize: _isarChangeLogEntryDeserialize,
  deserializeProp: _isarChangeLogEntryDeserializeProp,
  idName: r'seq',
  indexes: {
    r'cid': IndexSchema(
      id: 2203098626925536187,
      name: r'cid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _isarChangeLogEntryGetId,
  getLinks: _isarChangeLogEntryGetLinks,
  attach: _isarChangeLogEntryAttach,
  version: '3.3.0-dev.2',
);

int _isarChangeLogEntryEstimateSize(
  IsarChangeLogEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.changeBy.length * 3;
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.dataJson.length * 3;
  bytesCount += 3 + object.domainId.length * 3;
  bytesCount += 3 + object.domainType.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.length * 3;
  bytesCount += 3 + object.operation.length * 3;
  bytesCount += 3 + object.operationInfoJson.length * 3;
  bytesCount += 3 + object.storageId.length * 3;
  bytesCount += 3 + object.unknownJson.length * 3;
  return bytesCount;
}

void _isarChangeLogEntrySerialize(
  IsarChangeLogEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.changeAt);
  writer.writeString(offsets[1], object.changeBy);
  writer.writeString(offsets[2], object.cid);
  writer.writeDateTime(offsets[3], object.cloudAt);
  writer.writeString(offsets[4], object.dataJson);
  writer.writeLong(offsets[5], object.dataSchemaRev);
  writer.writeString(offsets[6], object.domainId);
  writer.writeString(offsets[7], object.domainType);
  writer.writeString(offsets[8], object.entityId);
  writer.writeString(offsets[9], object.entityType);
  writer.writeString(offsets[10], object.operation);
  writer.writeString(offsets[11], object.operationInfoJson);
  writer.writeLong(offsets[12], object.schemaVersion);
  writer.writeBool(offsets[13], object.stateChanged);
  writer.writeString(offsets[14], object.storageId);
  writer.writeDateTime(offsets[15], object.storedAt);
  writer.writeString(offsets[16], object.unknownJson);
}

IsarChangeLogEntry _isarChangeLogEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarChangeLogEntry(
    changeAt: reader.readDateTime(offsets[0]),
    changeBy: reader.readString(offsets[1]),
    cid: reader.readString(offsets[2]),
    cloudAt: reader.readDateTimeOrNull(offsets[3]),
    dataJson: reader.readString(offsets[4]),
    dataSchemaRev: reader.readLongOrNull(offsets[5]),
    domainId: reader.readString(offsets[6]),
    domainType: reader.readString(offsets[7]),
    entityId: reader.readString(offsets[8]),
    entityType: reader.readString(offsets[9]),
    operation: reader.readString(offsets[10]),
    operationInfoJson: reader.readStringOrNull(offsets[11]) ?? '{}',
    schemaVersion: reader.readLongOrNull(offsets[12]),
    seq: id,
    stateChanged: reader.readBool(offsets[13]),
    storageId: reader.readString(offsets[14]),
    storedAt: reader.readDateTimeOrNull(offsets[15]),
    unknownJson: reader.readStringOrNull(offsets[16]) ?? '{}',
  );
  return object;
}

P _isarChangeLogEntryDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset) ?? '{}') as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset) ?? '{}') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarChangeLogEntryGetId(IsarChangeLogEntry object) {
  return object.seq;
}

List<IsarLinkBase<dynamic>> _isarChangeLogEntryGetLinks(
  IsarChangeLogEntry object,
) {
  return [];
}

void _isarChangeLogEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarChangeLogEntry object,
) {
  object.seq = id;
}

extension IsarChangeLogEntryByIndex on IsarCollection<IsarChangeLogEntry> {
  Future<IsarChangeLogEntry?> getByCid(String cid) {
    return getByIndex(r'cid', [cid]);
  }

  IsarChangeLogEntry? getByCidSync(String cid) {
    return getByIndexSync(r'cid', [cid]);
  }

  Future<bool> deleteByCid(String cid) {
    return deleteByIndex(r'cid', [cid]);
  }

  bool deleteByCidSync(String cid) {
    return deleteByIndexSync(r'cid', [cid]);
  }

  Future<List<IsarChangeLogEntry?>> getAllByCid(List<String> cidValues) {
    final values = cidValues.map((e) => [e]).toList();
    return getAllByIndex(r'cid', values);
  }

  List<IsarChangeLogEntry?> getAllByCidSync(List<String> cidValues) {
    final values = cidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cid', values);
  }

  Future<int> deleteAllByCid(List<String> cidValues) {
    final values = cidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cid', values);
  }

  int deleteAllByCidSync(List<String> cidValues) {
    final values = cidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cid', values);
  }

  Future<Id> putByCid(IsarChangeLogEntry object) {
    return putByIndex(r'cid', object);
  }

  Id putByCidSync(IsarChangeLogEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'cid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCid(List<IsarChangeLogEntry> objects) {
    return putAllByIndex(r'cid', objects);
  }

  List<Id> putAllByCidSync(
    List<IsarChangeLogEntry> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'cid', objects, saveLinks: saveLinks);
  }
}

extension IsarChangeLogEntryQueryWhereSort
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QWhere> {
  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterWhere> anySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarChangeLogEntryQueryWhere
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QWhereClause> {
  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterWhereClause>
  seqEqualTo(Id seq) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: seq, upper: seq),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterWhereClause>
  seqNotEqualTo(Id seq) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: seq, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: seq, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: seq, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: seq, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterWhereClause>
  seqGreaterThan(Id seq, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: seq, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterWhereClause>
  seqLessThan(Id seq, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: seq, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterWhereClause>
  seqBetween(
    Id lowerSeq,
    Id upperSeq, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerSeq,
          includeLower: includeLower,
          upper: upperSeq,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterWhereClause>
  cidEqualTo(String cid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'cid', value: [cid]),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterWhereClause>
  cidNotEqualTo(String cid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'cid',
                lower: [],
                upper: [cid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'cid',
                lower: [cid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'cid',
                lower: [cid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'cid',
                lower: [],
                upper: [cid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension IsarChangeLogEntryQueryFilter
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QFilterCondition> {
  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'changeAt', value: value),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'changeAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'changeAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'changeAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'changeBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'changeBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'changeBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'changeBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'changeBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'changeBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'changeBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'changeBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'changeBy', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  changeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'changeBy', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cid', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cid', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cloudAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cloudAt'),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cloudAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cloudAt'),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cloudAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cloudAt', value: value),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cloudAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cloudAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  cloudAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataJson', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataJson', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataSchemaRevIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dataSchemaRev'),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataSchemaRevIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dataSchemaRev'),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataSchemaRevEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataSchemaRev', value: value),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataSchemaRevGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataSchemaRev',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataSchemaRevLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataSchemaRev',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  dataSchemaRevBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataSchemaRev',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'domainId', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'domainId', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  domainTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'domainType', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  domainTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'domainType', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  entityIdEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  entityIdGreaterThan(
    String value, {
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  entityIdLessThan(
    String value, {
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  entityIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityType', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityType', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'operation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'operation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'operation', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'operation', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'operationInfoJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'operationInfoJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'operationInfoJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'operationInfoJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'operationInfoJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'operationInfoJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'operationInfoJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'operationInfoJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'operationInfoJson', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  operationInfoJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'operationInfoJson', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  schemaVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'schemaVersion'),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  schemaVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'schemaVersion'),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  schemaVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schemaVersion', value: value),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  schemaVersionGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  schemaVersionLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  schemaVersionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'schemaVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  seqEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seq', value: value),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  seqGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seq',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  seqLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seq',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  seqBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seq',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  stateChangedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stateChanged', value: value),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'storageId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'storageId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'storageId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'storageId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'storageId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'storageId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'storageId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'storageId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'storageId', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'storageId', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'storedAt'),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'storedAt'),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'storedAt', value: value),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'storedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'storedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  storedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'storedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unknownJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unknownJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unknownJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unknownJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unknownJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unknownJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unknownJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unknownJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unknownJson', value: ''),
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterFilterCondition>
  unknownJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unknownJson', value: ''),
      );
    });
  }
}

extension IsarChangeLogEntryQueryObject
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QFilterCondition> {}

extension IsarChangeLogEntryQueryLinks
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QFilterCondition> {}

extension IsarChangeLogEntryQuerySortBy
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QSortBy> {
  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByDataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSchemaRev', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByDataSchemaRevDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSchemaRev', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByOperationInfoJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationInfoJson', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByOperationInfoJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationInfoJson', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByStateChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateChanged', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByStateChangedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateChanged', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByStorageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByStorageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByStoredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByStoredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByUnknownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  sortByUnknownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.desc);
    });
  }
}

extension IsarChangeLogEntryQuerySortThenBy
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QSortThenBy> {
  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByDataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSchemaRev', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByDataSchemaRevDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSchemaRev', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByOperationInfoJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationInfoJson', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByOperationInfoJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationInfoJson', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenBySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenBySeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByStateChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateChanged', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByStateChangedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateChanged', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByStorageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByStorageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByStoredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByStoredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByUnknownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.asc);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QAfterSortBy>
  thenByUnknownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.desc);
    });
  }
}

extension IsarChangeLogEntryQueryWhereDistinct
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct> {
  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeAt');
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudAt');
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByDataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataSchemaRev');
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByDomainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByDomainType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByOperation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByOperationInfoJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'operationInfoJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByStateChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateChanged');
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByStorageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByStoredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storedAt');
    });
  }

  QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QDistinct>
  distinctByUnknownJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unknownJson', caseSensitive: caseSensitive);
    });
  }
}

extension IsarChangeLogEntryQueryProperty
    on QueryBuilder<IsarChangeLogEntry, IsarChangeLogEntry, QQueryProperty> {
  QueryBuilder<IsarChangeLogEntry, int, QQueryOperations> seqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seq');
    });
  }

  QueryBuilder<IsarChangeLogEntry, DateTime, QQueryOperations>
  changeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeAt');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  changeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeBy');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<IsarChangeLogEntry, DateTime?, QQueryOperations>
  cloudAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudAt');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataJson');
    });
  }

  QueryBuilder<IsarChangeLogEntry, int?, QQueryOperations>
  dataSchemaRevProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataSchemaRev');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainId');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  domainTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainType');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  operationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operation');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  operationInfoJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationInfoJson');
    });
  }

  QueryBuilder<IsarChangeLogEntry, int?, QQueryOperations>
  schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<IsarChangeLogEntry, bool, QQueryOperations>
  stateChangedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateChanged');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  storageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storageId');
    });
  }

  QueryBuilder<IsarChangeLogEntry, DateTime?, QQueryOperations>
  storedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storedAt');
    });
  }

  QueryBuilder<IsarChangeLogEntry, String, QQueryOperations>
  unknownJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unknownJson');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IsarChangeLogEntry _$IsarChangeLogEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('IsarChangeLogEntry', json, ($checkedConvert) {
      final val = IsarChangeLogEntry(
        cid: $checkedConvert('cid', (v) => v as String),
        seq: $checkedConvert(
          'seq',
          (v) => (v as num?)?.toInt() ?? Isar.autoIncrement,
        ),
        domainId: $checkedConvert('domainId', (v) => v as String),
        entityType: $checkedConvert('entityType', (v) => v as String),
        operation: $checkedConvert('operation', (v) => v as String),
        changeAt: $checkedConvert(
          'changeAt',
          (v) => const UtcDateTimeConverter().fromJson(v as String),
        ),
        entityId: $checkedConvert('entityId', (v) => v as String),
        dataJson: $checkedConvert('dataJson', (v) => v as String),
        cloudAt: $checkedConvert(
          'cloudAt',
          (v) => _$JsonConverterFromJson<String, DateTime>(
            v,
            const UtcDateTimeConverter().fromJson,
          ),
        ),
        storedAt: $checkedConvert(
          'storedAt',
          (v) => _$JsonConverterFromJson<String, DateTime>(
            v,
            const UtcDateTimeConverter().fromJson,
          ),
        ),
        changeBy: $checkedConvert('changeBy', (v) => v as String),
        storageId: $checkedConvert('storageId', (v) => v as String),
        domainType: $checkedConvert('domainType', (v) => v as String),
        stateChanged: $checkedConvert('stateChanged', (v) => v as bool),
        operationInfoJson: $checkedConvert(
          'operationInfoJson',
          (v) => v as String? ?? '{}',
        ),
        unknownJson: $checkedConvert(
          'unknownJson',
          (v) => v as String? ?? '{}',
        ),
        dataSchemaRev: $checkedConvert(
          'dataSchemaRev',
          (v) => (v as num?)?.toInt(),
        ),
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$IsarChangeLogEntryToJson(IsarChangeLogEntry instance) =>
    <String, dynamic>{
      'storageId': instance.storageId,
      'domainType': instance.domainType,
      'domainId': instance.domainId,
      'entityType': instance.entityType,
      'operation': instance.operation,
      'operationInfoJson': instance.operationInfoJson,
      'stateChanged': instance.stateChanged,
      'changeAt': const UtcDateTimeConverter().toJson(instance.changeAt),
      'entityId': instance.entityId,
      'dataJson': instance.dataJson,
      'dataSchemaRev': instance.dataSchemaRev,
      'cloudAt': _$JsonConverterToJson<String, DateTime>(
        instance.cloudAt,
        const UtcDateTimeConverter().toJson,
      ),
      'storedAt': _$JsonConverterToJson<String, DateTime>(
        instance.storedAt,
        const UtcDateTimeConverter().toJson,
      ),
      'changeBy': instance.changeBy,
      'schemaVersion': instance.schemaVersion,
      'unknownJson': instance.unknownJson,
      'seq': instance.seq,
      'cid': instance.cid,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
