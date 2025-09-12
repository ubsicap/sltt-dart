// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_storage_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarStorageStateCollection on Isar {
  IsarCollection<IsarStorageState> get isarStorageStates => this.collection();
}

const IsarStorageStateSchema = CollectionSchema(
  name: r'IsarStorageState',
  id: 1751824242060085882,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'storageId': PropertySchema(
      id: 1,
      name: r'storageId',
      type: IsarType.string,
    ),
    r'storageType': PropertySchema(
      id: 2,
      name: r'storageType',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _isarStorageStateEstimateSize,
  serialize: _isarStorageStateSerialize,
  deserialize: _isarStorageStateDeserialize,
  deserializeProp: _isarStorageStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarStorageStateGetId,
  getLinks: _isarStorageStateGetLinks,
  attach: _isarStorageStateAttach,
  version: '3.1.0+1',
);

int _isarStorageStateEstimateSize(
  IsarStorageState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.storageId.length * 3;
  bytesCount += 3 + object.storageType.length * 3;
  return bytesCount;
}

void _isarStorageStateSerialize(
  IsarStorageState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.storageId);
  writer.writeString(offsets[2], object.storageType);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

IsarStorageState _isarStorageStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarStorageState(
    createdAt: reader.readDateTime(offsets[0]),
    id: id,
    storageId: reader.readString(offsets[1]),
    storageType: reader.readString(offsets[2]),
    updatedAt: reader.readDateTime(offsets[3]),
  );
  return object;
}

P _isarStorageStateDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarStorageStateGetId(IsarStorageState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarStorageStateGetLinks(IsarStorageState object) {
  return [];
}

void _isarStorageStateAttach(
    IsarCollection<dynamic> col, Id id, IsarStorageState object) {}

extension IsarStorageStateQueryWhereSort
    on QueryBuilder<IsarStorageState, IsarStorageState, QWhere> {
  QueryBuilder<IsarStorageState, IsarStorageState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarStorageStateQueryWhere
    on QueryBuilder<IsarStorageState, IsarStorageState, QWhereClause> {
  QueryBuilder<IsarStorageState, IsarStorageState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterWhereClause>
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterWhereClause> idBetween(
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
}

extension IsarStorageStateQueryFilter
    on QueryBuilder<IsarStorageState, IsarStorageState, QFilterCondition> {
  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdEqualTo(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdGreaterThan(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdLessThan(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdBetween(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdStartsWith(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdEndsWith(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storageId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storageId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeEqualTo(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeGreaterThan(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeLessThan(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeBetween(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeStartsWith(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeEndsWith(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storageType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storageType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      storageTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storageType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterFilterCondition>
      updatedAtBetween(
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

extension IsarStorageStateQueryObject
    on QueryBuilder<IsarStorageState, IsarStorageState, QFilterCondition> {}

extension IsarStorageStateQueryLinks
    on QueryBuilder<IsarStorageState, IsarStorageState, QFilterCondition> {}

extension IsarStorageStateQuerySortBy
    on QueryBuilder<IsarStorageState, IsarStorageState, QSortBy> {
  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      sortByStorageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      sortByStorageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.desc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      sortByStorageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageType', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      sortByStorageTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageType', Sort.desc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IsarStorageStateQuerySortThenBy
    on QueryBuilder<IsarStorageState, IsarStorageState, QSortThenBy> {
  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByStorageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByStorageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageId', Sort.desc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByStorageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageType', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByStorageTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storageType', Sort.desc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IsarStorageStateQueryWhereDistinct
    on QueryBuilder<IsarStorageState, IsarStorageState, QDistinct> {
  QueryBuilder<IsarStorageState, IsarStorageState, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QDistinct>
      distinctByStorageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QDistinct>
      distinctByStorageType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storageType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarStorageState, IsarStorageState, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension IsarStorageStateQueryProperty
    on QueryBuilder<IsarStorageState, IsarStorageState, QQueryProperty> {
  QueryBuilder<IsarStorageState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarStorageState, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarStorageState, String, QQueryOperations> storageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storageId');
    });
  }

  QueryBuilder<IsarStorageState, String, QQueryOperations>
      storageTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storageType');
    });
  }

  QueryBuilder<IsarStorageState, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
