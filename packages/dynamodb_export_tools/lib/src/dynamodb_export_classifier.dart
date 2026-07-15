import 'package:meta/meta.dart';

enum DynamoExportItemFamily {
  changeLog,
  entityState,
  entityTypeSyncStateChangeLog,
  entityTypeSyncStateEntityState,
  sequenceCounter,
  storageState,
  unknown,
}

@immutable
class DynamoExportItemClassification {
  const DynamoExportItemClassification({
    required this.family,
    required this.logicalTableName,
    required this.usesRawFallback,
    this.domainType,
    this.domainId,
    this.entityType,
    this.entityId,
    this.parentId,
    this.parentProp,
    this.rank,
    this.changeAtOrig,
    this.unsupportedReason,
  });

  final DynamoExportItemFamily family;
  final String logicalTableName;
  final bool usesRawFallback;
  final String? domainType;
  final String? domainId;
  final String? entityType;
  final String? entityId;
  final String? parentId;
  final String? parentProp;

  /// deprecated in gsi2sk in favor of changeAt_orig_
  final String? rank;
  final String? changeAtOrig;
  final String? unsupportedReason;

  bool get isSupported => unsupportedReason == null;
}

class DynamoExportClassifier {
  static const String rawItemsTableName = 'raw_items';
  static const String changeLogTableName = 'change_log_entries';

  const DynamoExportClassifier();

  DynamoExportItemClassification classifyDecodedItem(
    Map<String, dynamic> item,
  ) {
    final pk = item['pk']?.toString();
    final sk = item['sk']?.toString();
    final gsi2pk = item['gsi2pk']?.toString();
    final gsi2sk = item['gsi2sk']?.toString();
    final gsi3pk = item['gsi3pk']?.toString();
    final gsi3sk = item['gsi3sk']?.toString();

    if (pk == null || pk.isEmpty || sk == null || sk.isEmpty) {
      return const DynamoExportItemClassification(
        family: DynamoExportItemFamily.unknown,
        logicalTableName: rawItemsTableName,
        usesRawFallback: true,
        unsupportedReason: 'Missing pk/sk fields',
      );
    }

    return classifyCompositeKeys(
      pk: pk,
      sk: sk,
      gsi2pk: gsi2pk,
      gsi2sk: gsi2sk,
      gsi3pk: gsi3pk,
      gsi3sk: gsi3sk,
    );
  }

  DynamoExportItemClassification classifyCompositeKeys({
    required String pk,
    required String sk,
    String? gsi2pk,
    String? gsi2sk,
    String? gsi3pk,
    String? gsi3sk,
  }) {
    final pkFields = _parseFields(pk);
    final skFields = _parseFields(sk);
    final gsi2PkFields = gsi2pk == null
        ? const <String, String>{}
        : _parseFields(gsi2pk);
    final gsi2SkFields = gsi2sk == null
        ? const <String, String>{}
        : _parseFields(gsi2sk);
    final gsi3PkFields = gsi3pk == null
        ? const <String, String>{}
        : _parseFields(gsi3pk);
    final gsi3SkFields = gsi3sk == null
        ? const <String, String>{}
        : _parseFields(gsi3sk);

    if (pk.startsWith(r'$sltt#change#') && sk.startsWith(r'$changes#change#')) {
      return DynamoExportItemClassification(
        family: DynamoExportItemFamily.changeLog,
        logicalTableName: changeLogTableName,
        usesRawFallback: false,
        domainType: pkFields['domainType'],
        domainId: pkFields['domainId'],
        entityType: pkFields['entityType'],
        entityId: pkFields['entityId'],
      );
    }

    if (pk.startsWith(r'$sltt#state#') && sk.startsWith(r'$states#state#')) {
      final entityType = pkFields['entityType'];
      if (entityType == null || entityType.isEmpty) {
        return DynamoExportItemClassification(
          family: DynamoExportItemFamily.entityState,
          logicalTableName: rawItemsTableName,
          usesRawFallback: true,
          domainType: pkFields['domainType'],
          domainId: pkFields['domainId'],
          unsupportedReason: 'entity_state item missing entityType in pk',
        );
      }

      return DynamoExportItemClassification(
        family: DynamoExportItemFamily.entityState,
        logicalTableName: entityStateTableName(entityType),
        usesRawFallback: false,
        domainType: pkFields['domainType'],
        domainId: pkFields['domainId'],
        entityType: entityType,
        entityId: skFields['entityId'],
        parentId: gsi2PkFields['parentId'] ?? gsi3PkFields['parentId'],
        parentProp: gsi2SkFields['parentProp'],
        changeAtOrig:
            gsi2SkFields['changeAt_orig_'] ?? gsi3SkFields['changeAt_orig_'],
        rank: gsi2SkFields['rank'],
      );
    }

    if (pk.startsWith(r'$sltt#etsc#') && sk.startsWith(r'$etsc#etsc#')) {
      return DynamoExportItemClassification(
        family: DynamoExportItemFamily.entityTypeSyncStateChangeLog,
        logicalTableName: rawItemsTableName,
        usesRawFallback: true,
        domainType: pkFields['domainType'],
        domainId: pkFields['domainId'],
        entityType: skFields['entityType'],
      );
    }

    if (pk.startsWith(r'$sltt#etss#') && sk.startsWith(r'$etss#etss#')) {
      return DynamoExportItemClassification(
        family: DynamoExportItemFamily.entityTypeSyncStateEntityState,
        logicalTableName: rawItemsTableName,
        usesRawFallback: true,
        domainType: pkFields['domainType'],
        domainId: pkFields['domainId'],
        entityType: skFields['entityType'],
      );
    }

    if (pk.startsWith(r'$sltt#seq#') && sk == r'$seq#counter') {
      return DynamoExportItemClassification(
        family: DynamoExportItemFamily.sequenceCounter,
        logicalTableName: rawItemsTableName,
        usesRawFallback: true,
        domainType: pkFields['domainType'],
        domainId: pkFields['domainId'],
      );
    }

    if (pk == r'$sltt#storage#singleton' && sk == r'$storage#state') {
      return const DynamoExportItemClassification(
        family: DynamoExportItemFamily.storageState,
        logicalTableName: rawItemsTableName,
        usesRawFallback: true,
      );
    }

    return DynamoExportItemClassification(
      family: DynamoExportItemFamily.unknown,
      logicalTableName: rawItemsTableName,
      usesRawFallback: true,
      unsupportedReason: 'Unsupported composite key pattern',
      domainType: pkFields['domainType'],
      domainId: pkFields['domainId'],
      entityType: pkFields['entityType'] ?? skFields['entityType'],
      entityId: pkFields['entityId'] ?? skFields['entityId'],
    );
  }

  static String entityStateTableName(String entityType) {
    final normalized = entityType.trim().replaceAll(
      RegExp(r'[^A-Za-z0-9_]+'),
      '_',
    );
    return 'entity_state__$normalized';
  }

  Map<String, String> _parseFields(String compositeKey) {
    final fields = <String, String>{};
    final tokens = compositeKey.split('#');
    var index = 0;

    while (index < tokens.length) {
      final token = tokens[index++];
      if (token.isEmpty) {
        continue;
      }

      if (!token.startsWith('@')) {
        continue;
      }

      final rawFieldName = token.substring(1);
      if (rawFieldName.isEmpty || index >= tokens.length) {
        continue;
      }

      final rawValue = tokens[index++];
      final normalizedName = _normalizeFieldName(rawFieldName);
      if (normalizedName != null) {
        fields[normalizedName] = _decodeKeyValue(rawValue);
      }
    }

    return fields;
  }

  String? _normalizeFieldName(String rawFieldName) {
    switch (rawFieldName) {
      case 'DOMAINTYPE':
        return 'domainType';
      case 'DOMAINID':
        return 'domainId';
      case 'ENTITYTYPE':
        return 'entityType';
      case 'ENTITYID':
        return 'entityId';
      case 'PARENTID':
        return 'parentId';
      case 'PARENTPROP':
        return 'parentProp';
      case 'RANK':
        return 'rank';
      case 'CHANGEAT_ORIG':
        return 'changeAt_orig_';
      default:
        return null;
    }
  }

  /// NOTE: duplicated from packages/aws_backend/lib/src/storage/value_codec.dart
  String _decodeKeyValue(String value) {
    return value
        .replaceAll('%25', '%')
        .replaceAll('%23', '#')
        .replaceAll('%40', '@');
  }
}
