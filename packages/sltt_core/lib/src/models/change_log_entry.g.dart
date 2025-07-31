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
    r'cid': PropertySchema(
      id: 1,
      name: r'cid',
      type: IsarType.string,
    ),
    r'cloudAt': PropertySchema(
      id: 2,
      name: r'cloudAt',
      type: IsarType.dateTime,
    ),
    r'dataJson': PropertySchema(
      id: 3,
      name: r'dataJson',
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
      enumMap: _ClientChangeLogEntryentityTypeEnumValueMap,
    ),
    r'operation': PropertySchema(
      id: 6,
      name: r'operation',
      type: IsarType.string,
    ),
    r'outdatedBy': PropertySchema(
      id: 7,
      name: r'outdatedBy',
      type: IsarType.long,
    ),
    r'projectId': PropertySchema(
      id: 8,
      name: r'projectId',
      type: IsarType.string,
    )
  },
  estimateSize: _clientChangeLogEntryEstimateSize,
  serialize: _clientChangeLogEntrySerialize,
  deserialize: _clientChangeLogEntryDeserialize,
  deserializeProp: _clientChangeLogEntryDeserializeProp,
  idName: r'seq',
  indexes: {
    r'projectId': IndexSchema(
      id: 3305656282123791113,
      name: r'projectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'projectId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'cid': IndexSchema(
      id: 2203098626925536187,
      name: r'cid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
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
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.dataJson.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.name.length * 3;
  bytesCount += 3 + object.operation.length * 3;
  bytesCount += 3 + object.projectId.length * 3;
  return bytesCount;
}

void _clientChangeLogEntrySerialize(
  ClientChangeLogEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.changeAt);
  writer.writeString(offsets[1], object.cid);
  writer.writeDateTime(offsets[2], object.cloudAt);
  writer.writeString(offsets[3], object.dataJson);
  writer.writeString(offsets[4], object.entityId);
  writer.writeString(offsets[5], object.entityType.name);
  writer.writeString(offsets[6], object.operation);
  writer.writeLong(offsets[7], object.outdatedBy);
  writer.writeString(offsets[8], object.projectId);
}

ClientChangeLogEntry _clientChangeLogEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClientChangeLogEntry(
    changeAt: reader.readDateTime(offsets[0]),
    cid: reader.readString(offsets[1]),
    cloudAt: reader.readDateTimeOrNull(offsets[2]),
    dataJson: reader.readString(offsets[3]),
    entityId: reader.readString(offsets[4]),
    entityType: _ClientChangeLogEntryentityTypeValueEnumMap[
            reader.readStringOrNull(offsets[5])] ??
        EntityType.project,
    operation: reader.readString(offsets[6]),
    outdatedBy: reader.readLongOrNull(offsets[7]),
    projectId: reader.readString(offsets[8]),
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (_ClientChangeLogEntryentityTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          EntityType.project) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ClientChangeLogEntryentityTypeEnumValueMap = {
  r'project': r'project',
  r'plan': r'plan',
  r'member': r'member',
  r'message': r'message',
  r'portion': r'portion',
  r'passage': r'passage',
  r'reference': r'reference',
  r'document': r'document',
  r'video': r'video',
  r'gloss': r'gloss',
  r'note': r'note',
  r'comment': r'comment',
};
const _ClientChangeLogEntryentityTypeValueEnumMap = {
  r'project': EntityType.project,
  r'plan': EntityType.plan,
  r'member': EntityType.member,
  r'message': EntityType.message,
  r'portion': EntityType.portion,
  r'passage': EntityType.passage,
  r'reference': EntityType.reference,
  r'document': EntityType.document,
  r'video': EntityType.video,
  r'gloss': EntityType.gloss,
  r'note': EntityType.note,
  r'comment': EntityType.comment,
};

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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
      projectIdEqualTo(String projectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'projectId',
        value: [projectId],
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
      projectIdNotEqualTo(String projectId) {
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
      cidEqualTo(String cid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cid',
        value: [cid],
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterWhereClause>
      cidNotEqualTo(String cid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cid',
              lower: [],
              upper: [cid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cid',
              lower: [cid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cid',
              lower: [cid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cid',
              lower: [],
              upper: [cid],
              includeUpper: false,
            ));
      }
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityTypeGreaterThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityTypeLessThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> entityTypeBetween(
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
      QAfterFilterCondition> outdatedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'outdatedBy',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> outdatedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'outdatedBy',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> outdatedByEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outdatedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> outdatedByGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outdatedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> outdatedByLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outdatedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> outdatedByBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outdatedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> projectIdEqualTo(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> projectIdGreaterThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> projectIdLessThan(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> projectIdBetween(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> projectIdStartsWith(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> projectIdEndsWith(
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

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      projectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
          QAfterFilterCondition>
      projectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> projectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry,
      QAfterFilterCondition> projectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectId',
        value: '',
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
      sortByOutdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdatedBy', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByOutdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdatedBy', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      sortByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
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
      thenByOutdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdatedBy', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByOutdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdatedBy', Sort.desc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QAfterSortBy>
      thenByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
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
      distinctByOutdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outdatedBy');
    });
  }

  QueryBuilder<ClientChangeLogEntry, ClientChangeLogEntry, QDistinct>
      distinctByProjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectId', caseSensitive: caseSensitive);
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

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<ClientChangeLogEntry, EntityType, QQueryOperations>
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

  QueryBuilder<ClientChangeLogEntry, int?, QQueryOperations>
      outdatedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outdatedBy');
    });
  }

  QueryBuilder<ClientChangeLogEntry, String, QQueryOperations>
      projectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectId');
    });
  }
}
