import 'value_codec.dart';

String buildKey(List<KeySegment> segments) {
  if (segments.isEmpty) {
    return '';
  }
  return segments.map((segment) => segment.encode()).join('#');
}

sealed class KeySegment {
  const KeySegment();
  String encode();
}

class KeyLabel extends KeySegment {
  final String value;

  KeyLabel(this.value) {
    assertValidLabel(value);
  }

  @override
  String encode() => value;
}

class KeyField extends KeySegment {
  final String name;
  final String value;

  KeyField(this.name, this.value) {
    assertValidFieldName(name);
  }

  @override
  String encode() => '@$name#${encodeKeyValue(value)}';
}

void assertValidLabel(String label) {
  if (label.isEmpty) {
    throw const FormatException('Key labels must not be empty');
  }
  if (label.contains('#') || label.contains('@')) {
    throw FormatException('Invalid key label: $label');
  }
}

void assertValidFieldName(String name) {
  if (name.isEmpty) {
    throw const FormatException('Key field names must not be empty');
  }
  if (name.contains('#') || name.contains('@') || name.contains('%')) {
    throw FormatException('Invalid key field name: $name');
  }
}

List<KeySegment> parseKey(String key) {
  if (key.isEmpty) {
    return const <KeySegment>[];
  }

  final tokens = key.split('#');
  final segments = <KeySegment>[];
  var index = 0;

  while (index < tokens.length) {
    final token = tokens[index++];
    if (token.startsWith('@')) {
      final fieldName = token.substring(1);
      if (fieldName.isEmpty) {
        throw FormatException('Empty field name in key: $key');
      }
      assertValidFieldName(fieldName);
      if (index >= tokens.length) {
        throw FormatException(
          'Missing field value for $fieldName in key: $key',
        );
      }
      final fieldValue = decodeKeyValue(tokens[index++]);
      segments.add(KeyField(fieldName, fieldValue));
    } else {
      assertValidLabel(token);
      segments.add(KeyLabel(token));
    }
  }

  return segments;
}

Map<String, String> parseKeyFields(String key) {
  final result = <String, String>{};
  for (final segment in parseKey(key)) {
    if (segment is KeyField) {
      result[segment.name] = segment.value;
    }
  }
  return result;
}

String buildChangePrimaryKey({
  required String domainType,
  required String domainId,
  required String entityType,
  required String entityId,
}) {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel('change'),
    KeyField('DOMAINTYPE', domainType),
    KeyField('DOMAINID', domainId),
    KeyField('ENTITYTYPE', entityType),
    KeyField('ENTITYID', entityId),
  ]);
}

String buildChangePrimaryKeyPrefix({
  required String domainType,
  required String domainId,
}) {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel('change'),
    KeyField('DOMAINTYPE', domainType),
    KeyField('DOMAINID', domainId),
  ]);
}

String buildChangeSortKey(String cid) {
  return buildKey([
    KeyLabel(r'$changes'),
    KeyLabel('change'),
    KeyField('CID', cid),
  ]);
}

String buildChangeGsiPartition({
  required String domainType,
  required String domainId,
}) {
  return buildChangePrimaryKeyPrefix(
    domainType: domainType,
    domainId: domainId,
  );
}

String buildChangeGsiSortKey(int seq) {
  assertSafeSortKeyValue(seq.toString());
  return buildKey([
    KeyLabel('seq'),
    KeyField('VALUE', seq.toString().padLeft(19, '0')),
  ]);
}

String buildStatePrimaryKeyDomainPrefix({
  required String domainType,
  required String domainId,
}) {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel('state'),
    KeyField('DOMAINTYPE', domainType),
    KeyField('DOMAINID', domainId),
  ]);
}

String buildStatePrimaryKey({
  required String domainType,
  required String domainId,
  required String entityType,
}) {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel('state'),
    KeyField('DOMAINTYPE', domainType),
    KeyField('DOMAINID', domainId),
    KeyField('ENTITYTYPE', entityType),
  ]);
}

String buildStateSortKey({required String entityId}) {
  return buildKey([
    KeyLabel(r'$states'),
    KeyLabel('state'),
    KeyField('ENTITYID', entityId),
  ]);
}

String buildStateGsi2Partition({
  required String domainType,
  required String domainId,
  required String entityType,
  required String parentId,
}) {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel('state'),
    KeyField('DOMAINTYPE', domainType),
    KeyField('DOMAINID', domainId),
    KeyField('ENTITYTYPE', entityType),
    KeyField('PARENTID', parentId),
  ]);
}

String buildStateGsi2SortKey({
  required String parentProp,
  String? changeAtOrig,
}) {
  assertSafeSortKeyValue(parentProp);
  final segments = <KeySegment>[KeyField('PARENTPROP', parentProp)];
  if (changeAtOrig != null && changeAtOrig.isNotEmpty) {
    assertSafeSortKeyValue(changeAtOrig);
    segments.add(KeyField('CHANGEAT_ORIG', changeAtOrig));
  }
  return buildKey(segments);
}

String buildStateGsi3Partition({required String domainType}) {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel('crossDomain'),
    KeyField('DOMAINTYPE', domainType),
  ]);
}

String buildStateGsi3SortKey({
  required String entityType,
  required String entityId,
  required String domainId,
  required String changeAtOrig,
}) {
  assertSafeSortKeyValue(entityType);
  assertSafeSortKeyValue(entityId);
  assertSafeSortKeyValue(domainId);
  assertSafeSortKeyValue(changeAtOrig);
  return buildKey([
    KeyLabel('states'),
    KeyField('ENTITYTYPE', entityType),
    KeyField('ENTITYID', entityId),
    KeyField('DOMAINID', domainId),
    KeyField('CHANGEAT_ORIG', changeAtOrig),
  ]);
}

String buildStateGsi3SortKeyPrefix({required String entityType}) {
  assertSafeSortKeyValue(entityType);
  return buildKey([KeyLabel('states'), KeyField('ENTITYTYPE', entityType)]);
}

String buildStateGsi3SortKeyEntityIdPrefix({
  required String entityType,
  required String entityIdPrefix,
}) {
  assertSafeSortKeyValue(entityType);
  return '${buildStateGsi3SortKeyPrefix(entityType: entityType)}#@ENTITYID#${encodeKeyValue(entityIdPrefix)}#';
}

String buildEntityTypeSyncStatePrimaryKey({
  required String domainType,
  required String domainId,
  required bool forChangeLog,
}) {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel(forChangeLog ? 'etsc' : 'etss'),
    KeyField('DOMAINTYPE', domainType),
    KeyField('DOMAINID', domainId),
  ]);
}

String buildEntityTypeSyncStateSortKey({
  required String entityType,
  required bool forChangeLog,
}) {
  final prefix = forChangeLog ? r'$etsc' : r'$etss';
  final secondLabel = forChangeLog ? 'etsc' : 'etss';
  return buildKey([
    KeyLabel(prefix),
    KeyLabel(secondLabel),
    KeyField('ENTITYTYPE', entityType),
  ]);
}

String buildSequencePrimaryKey({
  required String domainType,
  required String domainId,
}) {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel('seq'),
    KeyField('DOMAINTYPE', domainType),
    KeyField('DOMAINID', domainId),
  ]);
}

String buildSequenceCounterSortKey() {
  return buildKey([KeyLabel(r'$seq'), KeyLabel('counter')]);
}

String buildStorageStatePrimaryKey() {
  return buildKey([
    KeyLabel(r'$sltt'),
    KeyLabel('storage'),
    KeyLabel('singleton'),
  ]);
}

String buildStorageStateSortKey() {
  return buildKey([KeyLabel(r'$storage'), KeyLabel('state')]);
}
