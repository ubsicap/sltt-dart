import 'dart:convert';

class DynamoExportTableStat {
  const DynamoExportTableStat({
    required this.tableName,
    required this.rowCount,
  });

  final String tableName;
  final int rowCount;

  Map<String, dynamic> toJson() => {
    'tableName': tableName,
    'rowCount': rowCount,
  };
}

class DynamoExportUnsupportedSample {
  const DynamoExportUnsupportedSample({
    required this.reason,
    this.pk,
    this.sk,
    this.logicalTableName,
  });

  final String reason;
  final String? pk;
  final String? sk;
  final String? logicalTableName;

  Map<String, dynamic> toJson() => {
    'reason': reason,
    'pk': pk,
    'sk': sk,
    'logicalTableName': logicalTableName,
  };
}

class DynamoExportManifest {
  const DynamoExportManifest({
    required this.inputDirectory,
    required this.outputDirectory,
    required this.generatedAt,
    required this.totalRowsSeen,
    required this.rawRowsWritten,
    required this.unsupportedRows,
    required this.tables,
    required this.unsupportedSamples,
    this.exportId,
  });

  final String inputDirectory;
  final String outputDirectory;
  final String? exportId;
  final DateTime generatedAt;
  final int totalRowsSeen;
  final int rawRowsWritten;
  final int unsupportedRows;
  final List<DynamoExportTableStat> tables;
  final List<DynamoExportUnsupportedSample> unsupportedSamples;

  Map<String, dynamic> toJson() => {
    'inputDirectory': inputDirectory,
    'outputDirectory': outputDirectory,
    'exportId': exportId,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'totalRowsSeen': totalRowsSeen,
    'rawRowsWritten': rawRowsWritten,
    'unsupportedRows': unsupportedRows,
    'tables': tables.map((table) => table.toJson()).toList(growable: false),
    'unsupportedSamples': unsupportedSamples
        .map((sample) => sample.toJson())
        .toList(growable: false),
  };

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());
}
