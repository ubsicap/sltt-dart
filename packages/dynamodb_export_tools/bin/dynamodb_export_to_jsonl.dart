import 'dart:io';

import 'package:dynamodb_export_tools/dynamodb_export_tools.dart';

void main(List<String> args) async {
  final input = _readFlag(args, '--input');
  final output = _readFlag(args, '--output');
  final exportId = _readFlag(args, '--exportId');

  if (input == null || output == null) {
    stderr.writeln(
      'Usage: dart run bin/dynamodb_export_to_jsonl.dart --input <dir> --output <dir> [--exportId <id>]',
    );
    exitCode = 64;
    return;
  }

  final converter = DynamoExportJsonlConverter();
  final manifest = await converter.convertDirectory(
    inputDirectory: Directory(input),
    outputDirectory: Directory(output),
    exportId: exportId,
  );

  stdout.writeln(manifest.toString());
}

String? _readFlag(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}
