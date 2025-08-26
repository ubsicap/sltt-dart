// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_log_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClientChangeLogEntryCollection on Isar {
  IsarCollection<ClientChangeLogEntry> get clientChangeLogEntrys =>
      this.collection();
}

const ClientChangeLogEntrySchema = CollectionSchema(
  name: r'ClientChangeLogEntry',
  id: -1642374364194476373,
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
    r'unknownJson': PropertySchema(
      id: 15,
      name: r'unknownJson',
      type: IsarType.string,
    )
  },
  estimateSize: _clientChangeLogEntryEstimateSize,
  serialize: _clientChangeLogEntrySerialize,
  deserialize: _clientChangeLogEntryDeserialize,
  deserializeProp: _clientChangeLogEntryDeserializeProp,
  idName: r'seq',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _clientChangeLogEntryGetId,
  getLinks: _clientChangeLogEntryGetLinks,
  attach: _clientChangeLogEntryAttach,
  version: '3.1.0+1',
);

int _clientChangeLogEntryEstimateSize(
  ClientChangeLogEntry object,
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

void _clientChangeLogEntrySerialize(
  ClientChangeLogEntry object,
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
  writer.writeString(offsets[15], object.unknownJson);
}

ClientChangeLogEntry _clientChangeLogEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClientChangeLogEntry(
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
    stateChanged: reader.readBool(offsets[13]),
    storageId: reader.readString(offsets[14]),
    unknownJson: reader.readStringOrNull(offsets[15]) ?? '{}',
  );
  object.seq = id;
  return object;
}

P _clientChangeLogEntryDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset) ?? '{}') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _clientChangeLogEntryGetId(ClientChangeLogEntry object) {
  return object.seq;
}

List<IsarLinkBase<dynamic>> _clientChangeLogEntryGetLinks(
    ClientChangeLogEntry object) {
  return [];
}

void _clientChangeLogEntryAttach(
    IsarCollection<dynamic> col, Id id, ClientChangeLogEntry object) {
  object.seq = id;
}

extension ClientChangeLogEntryQueryWhereSort
    on QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QWhere> {
  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhere>
      anySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ClientChangeLogEntryQueryWhere
    on QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QWhereClause> {
  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
      seqEqualTo(Id seq) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: seq,
        upper: seq,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
      seqGreaterThan(Id seq, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: seq, includeLower: include),
      );
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
      seqLessThan(Id seq, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: seq, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
      seqBetween(
    Id lowerSeq,
    Id upperSeq, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerSeq,
        includeLower: includeLower,
        upper: upperSeq,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ClientChangeLogEntryQueryFilter on QueryBuilder<ClientChangeLogEntry,
    ClientChangeLogEntry, QFilterCondition> {
  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeByEqualTo(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeByGreaterThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeByLessThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeByBetween(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeByStartsWith(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeByEndsWith(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      changeByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'changeBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      changeByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'changeBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> changeByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'changeBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> cloudAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cloudAt',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> cloudAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cloudAt',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> cloudAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> cloudAtGreaterThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> cloudAtLessThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> cloudAtBetween(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      dataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      dataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataSchemaRevIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dataSchemaRev',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataSchemaRevIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dataSchemaRev',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataSchemaRevEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataSchemaRev',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataSchemaRevGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataSchemaRev',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataSchemaRevLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataSchemaRev',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> dataSchemaRevBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataSchemaRev',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'domainId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> domainTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainType',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> domainTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'domainType',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityIdEqualTo(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityIdGreaterThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityIdLessThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityIdBetween(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityIdStartsWith(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityIdEndsWith(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      operationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      operationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operation',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operation',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationInfoJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationInfoJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationInfoJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationInfoJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationInfoJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationInfoJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operationInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationInfoJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operationInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      operationInfoJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      operationInfoJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationInfoJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationInfoJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationInfoJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> operationInfoJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationInfoJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> schemaVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'schemaVersion',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> schemaVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'schemaVersion',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> schemaVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> schemaVersionGreaterThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> schemaVersionLessThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> schemaVersionBetween(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> seqEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seq',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> seqGreaterThan(
    Id value, {
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> seqLessThan(
    Id value, {
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> seqBetween(
    Id lower,
    Id upper, {
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> stateChangedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateChanged',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> storageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storageId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> storageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storageId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> unknownJsonEqualTo(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> unknownJsonGreaterThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> unknownJsonLessThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> unknownJsonBetween(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> unknownJsonStartsWith(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> unknownJsonEndsWith(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      unknownJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unknownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      unknownJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unknownJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> unknownJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unknownJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> unknownJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unknownJson',
        value: '',
      ));
    });
  }
}

extension ClientChangeLogEntryQueryObject on QueryBuilder<ClientChangeLogEntry,
    ClientChangeLogEntry, QFilterCondition> {}

extension ClientChangeLogEntryQueryLinks on QueryBuilder<ClientChangeLogEntry,
    ClientChangeLogEntry, QFilterCondition> {}

extension ClientChangeLogEntryQuerySortBy
    on QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QSortBy> {
  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByDataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSchemaRev', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByDataSchemaRevDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSchemaRev', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByOperationInfoJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationInfoJson', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByOperationInfoJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationInfoJson', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByStateChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateChanged', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByStateChangedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateChanged', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByStorageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByStorageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByUnknownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByUnknownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.desc);
    });
  }
}

extension ClientChangeLogEntryQuerySortThenBy
    on QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QSortThenBy> {
  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeAt', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByChangeBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByChangeByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeBy', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByCloudAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudAt', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByDataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSchemaRev', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByDataSchemaRevDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSchemaRev', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByDomainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByDomainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainType', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByOperationInfoJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationInfoJson', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByOperationInfoJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationInfoJson', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenBySeq() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenBySeqDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seq', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByStateChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateChanged', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByStateChangedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateChanged', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByStorageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByStorageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByUnknownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByUnknownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unknownJson', Sort.desc);
    });
  }
}

extension ClientChangeLogEntryQueryWhereDistinct
    on QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct> {
  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeAt');
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByChangeBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByCloudAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudAt');
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByDataSchemaRev() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataSchemaRev');
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByDomainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByDomainType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByOperation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByOperationInfoJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationInfoJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByStateChanged() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateChanged');
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByStorageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByUnknownJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unknownJson', caseSensitive: caseSensitive);
    });
  }
}

extension ClientChangeLogEntryQueryProperty on QueryBuilder<
    ClientChangeLogEntry, ClientChangeLogEntry, QQueryProperty> {
  QueryBuilder<ClientChangeLogEntry, int, QQueryOperations> seqProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seq');
    });
  }

  QueryBuilder<ClientChangeLogEntry, DateTime, QQueryOperations>
      changeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeAt');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      changeByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeBy');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<ClientChangeLogEntry, DateTime?, QQueryOperations>
      cloudAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudAt');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataJson');
    });
  }

  QueryBuilder<ClientChangeLogEntry, int?, QQueryOperations>
      dataSchemaRevProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataSchemaRev');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainId');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      domainTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainType');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      operationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operation');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      operationInfoJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationInfoJson');
    });
  }

  QueryBuilder<ClientChangeLogEntry, int?, QQueryOperations>
      schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<ClientChangeLogEntry, bool, QQueryOperations>
      stateChangedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateChanged');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      storageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storageId');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      unknownJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unknownJson');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientChangeLogEntry _$ClientChangeLogEntryFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'ClientChangeLogEntry',
      json,
      ($checkedConvert) {
        final val = ClientChangeLogEntry(
          domainId: $checkedConvert('domainId', (v) => v as String),
          entityType: $checkedConvert('entityType', (v) => v as String),
          operation: $checkedConvert('operation', (v) => v as String),
          changeAt: $checkedConvert('changeAt',
              (v) => const UtcDateTimeConverter().fromJson(v as String)),
          entityId: $checkedConvert('entityId', (v) => v as String),
          dataJson: $checkedConvert('dataJson', (v) => v as String),
          cloudAt: $checkedConvert(
              'cloudAt',
              (v) => _$JsonConverterFromJson<String, DateTime>(
                  v, const UtcDateTimeConverter().fromJson)),
          changeBy: $checkedConvert('changeBy', (v) => v as String),
          cid: $checkedConvert('cid', (v) => v as String),
          storageId: $checkedConvert('storageId', (v) => v as String),
          domainType: $checkedConvert('domainType', (v) => v as String),
          stateChanged: $checkedConvert('stateChanged', (v) => v as bool),
          operationInfoJson:
              $checkedConvert('operationInfoJson', (v) => v as String? ?? '{}'),
          unknownJson:
              $checkedConvert('unknownJson', (v) => v as String? ?? '{}'),
          dataSchemaRev:
              $checkedConvert('dataSchemaRev', (v) => (v as num?)?.toInt()),
          schemaVersion:
              $checkedConvert('schemaVersion', (v) => (v as num?)?.toInt()),
        );
        $checkedConvert('seq', (v) => val.seq = (v as num).toInt());
        return val;
      },
    );

Map<String, dynamic> _$ClientChangeLogEntryToJson(
        ClientChangeLogEntry instance) =>
    <String, dynamic>{
      'cid': instance.cid,
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
          instance.cloudAt, const UtcDateTimeConverter().toJson),
      'changeBy': instance.changeBy,
      'schemaVersion': instance.schemaVersion,
      'unknownJson': instance.unknownJson,
      'seq': instance.seq,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
