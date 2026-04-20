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
  final String? rank;
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
    );
  }

  DynamoExportItemClassification classifyCompositeKeys({
    required String pk,
    required String sk,
    String? gsi2pk,
    String? gsi2sk,
  }) {
    final pkFields = _parseFields(pk);
    final skFields = _parseFields(sk);
    final gsi2PkFields = gsi2pk == null
        ? const <String, String>{}
        : _parseFields(gsi2pk);
    final gsi2SkFields = gsi2sk == null
        ? const <String, String>{}
        : _parseFields(gsi2sk);

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
        parentId: gsi2PkFields['parentId'],
        parentProp: gsi2SkFields['parentProp'],
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
    for (final segment in compositeKey.split('#')) {
      final separator = segment.indexOf('_');
      if (separator <= 0 || separator == segment.length - 1) {
        continue;
      }
      final fieldName = segment.substring(0, separator);
      final fieldValue = segment.substring(separator + 1);
      switch (fieldName) {
        case 'domainType':
        case 'domainId':
        case 'entityType':
        case 'entityId':
        case 'parentId':
        case 'parentProp':
        case 'rank':
          fields[fieldName] = fieldValue;
      }
    }
    return fields;
  }
}
