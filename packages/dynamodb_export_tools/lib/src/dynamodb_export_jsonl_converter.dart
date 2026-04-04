import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'dynamodb_export_classifier.dart';
import 'dynamodb_export_decoder.dart';
import 'dynamodb_export_manifest.dart';

class DynamoExportJsonlConverter {
  DynamoExportJsonlConverter({
    DynamoExportClassifier? classifier,
    DynamoExportDecoder? decoder,
    this.unsupportedSampleLimit = 20,
  }) : classifier = classifier ?? const DynamoExportClassifier(),
       decoder = decoder ?? const DynamoExportDecoder();

  final DynamoExportClassifier classifier;
  final DynamoExportDecoder decoder;
  final int unsupportedSampleLimit;

  Future<DynamoExportManifest> convertDirectory({
    required Directory inputDirectory,
    required Directory outputDirectory,
    String? exportId,
  }) async {
    if (!await inputDirectory.exists()) {
      throw ArgumentError.value(
        inputDirectory.path,
        'inputDirectory',
        'Input directory does not exist',
      );
    }

    await outputDirectory.create(recursive: true);

    final writers = <String, IOSink>{};
    final tableCounts = <String, int>{};
    final unsupportedSamples = <DynamoExportUnsupportedSample>[];
    var totalRowsSeen = 0;
    var unsupportedRows = 0;

    Future<IOSink> writerFor(String tableName) async {
      final existing = writers[tableName];
      if (existing != null) return existing;
      final file = File(p.join(outputDirectory.path, '$tableName.jsonl'));
      final sink = file.openWrite(mode: FileMode.writeOnly);
      writers[tableName] = sink;
      return sink;
    }

    Future<void> writeRow(String tableName, Map<String, dynamic> row) async {
      final sink = await writerFor(tableName);
      sink.writeln(jsonEncode(row));
      tableCounts.update(tableName, (value) => value + 1, ifAbsent: () => 1);
    }

    try {
      await for (final row in _iterDecodedRows(inputDirectory)) {
        totalRowsSeen += 1;
        final classification = classifier.classifyDecodedItem(row);

        await writeRow(DynamoExportClassifier.rawItemsTableName, row);

        if (!classification.usesRawFallback) {
          await writeRow(classification.logicalTableName, row);
        }

        if (!classification.isSupported) {
          unsupportedRows += 1;
          await writeRow('unsupported_items', row);
          if (unsupportedSamples.length < unsupportedSampleLimit) {
            unsupportedSamples.add(
              DynamoExportUnsupportedSample(
                reason: classification.unsupportedReason ?? 'Unsupported item',
                pk: row['pk']?.toString(),
                sk: row['sk']?.toString(),
                logicalTableName: classification.logicalTableName,
              ),
            );
          }
        }
      }
    } finally {
      for (final sink in writers.values) {
        await sink.flush();
        await sink.close();
      }
    }

    final manifest = DynamoExportManifest(
      inputDirectory: inputDirectory.path,
      outputDirectory: outputDirectory.path,
      exportId: exportId ?? _findExportIdInPath(inputDirectory.path),
      generatedAt: DateTime.now().toUtc(),
      totalRowsSeen: totalRowsSeen,
      rawRowsWritten:
          tableCounts[DynamoExportClassifier.rawItemsTableName] ?? 0,
      unsupportedRows: unsupportedRows,
      tables:
          tableCounts.entries
              .map(
                (entry) => DynamoExportTableStat(
                  tableName: entry.key,
                  rowCount: entry.value,
                ),
              )
              .toList(growable: false)
            ..sort((a, b) => a.tableName.compareTo(b.tableName)),
      unsupportedSamples: unsupportedSamples,
    );

    final manifestFile = File(p.join(outputDirectory.path, 'manifest.json'));
    await manifestFile.writeAsString('${manifest.toString()}\n');
    return manifest;
  }

  Stream<Map<String, dynamic>> _iterDecodedRows(Directory root) async* {
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final lowerName = entity.path.toLowerCase();
      if (!lowerName.endsWith('.json') && !lowerName.endsWith('.json.gz')) {
        continue;
      }

      await for (final object in _readJsonLineObjects(entity)) {
        final row = decoder.decodeExportLineObject(object);
        if (row != null) {
          yield row;
        }
      }
    }
  }

  Stream<Map<String, dynamic>> _readJsonLineObjects(File file) async* {
    final byteStream = file.openRead();
    final textStream = await _isGzipCompressed(file)
        ? byteStream.transform(gzip.decoder).transform(utf8.decoder)
        : byteStream.transform(utf8.decoder);

    await for (final line in textStream.transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          yield decoded;
        } else if (decoded is Map) {
          yield Map<String, dynamic>.from(decoded);
        }
      } on FormatException {
        // Ignore non-line-delimited JSON files such as manifest blobs.
      }
    }
  }

  Future<bool> _isGzipCompressed(File file) async {
    final header = await file.openRead(0, 2).fold<List<int>>(<int>[], (
      previous,
      chunk,
    ) {
      previous.addAll(chunk);
      return previous;
    });

    return header.length >= 2 && header[0] == 0x1f && header[1] == 0x8b;
  }

  String? _findExportIdInPath(String inputPath) {
    for (final segment in p.split(inputPath)) {
      final separator = segment.indexOf('-');
      if (separator <= 0 || separator == segment.length - 1) {
        continue;
      }
      final left = segment.substring(0, separator);
      final right = segment.substring(separator + 1);
      if (int.tryParse(left) != null && right.isNotEmpty) {
        return segment;
      }
    }
    return null;
  }
}
