import 'dart:io';

/// fast and memory-efficient file concatenation
Future<void> concatenateFiles({
  required List<File> parts,
  required File output,
}) async {
  final sink = output.openWrite(); // streaming write

  try {
    for (final part in parts) {
      // Stream bytes directly from disk → sink
      await sink.addStream(part.openRead());
    }
  } finally {
    await sink.close();
  }
}
