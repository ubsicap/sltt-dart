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

const maxConcurrency = 4;

/// Adaptive chunk size based on file size
int chooseChunkSize(int fileSizeBytes) {
  if (fileSizeBytes < 20 * 1024 * 1024) return fileSizeBytes; // no chunking
  if (fileSizeBytes < 200 * 1024 * 1024) return 2 * 1024 * 1024;
  if (fileSizeBytes < 1000 * 1024 * 1024) return 5 * 1024 * 1024;
  return 10 * 1024 * 1024;
}
