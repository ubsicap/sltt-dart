import 'dart:math';

import 'package:sltt_core/src/services/date_time_service.dart';

/// Generate a random string of [size] characters from the provided [chars] set.
///
/// - Defaults to alphanumeric A-Z a-z 0-9.
/// - If [size] <= 0, returns an empty string.
/// - Optional [rng] parameter allows deterministic testing.
String generateRandomChars(
  int size, {
  String chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
  Random? rng,
}) {
  if (size <= 0) return '';
  final rand = rng ?? Random();
  final codeUnits = List<int>.generate(
    size,
    (_) => chars.codeUnitAt(rand.nextInt(chars.length)),
  );
  return String.fromCharCodes(codeUnits);
}

/// Generates a unique CID (Change ID) in format: YYYY-mmdd-HHMMss-sss[-_]HHmm-{4-character-random}
String generateCid([DateTime? timestamp]) {
  final now = timestamp ?? HlcTimestampGenerator.generate();
  final utc = now.toUtc();

  // Format: YYYY-mmdd-HHMMss-sss
  final datePart =
      '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}${utc.day.toString().padLeft(2, '0')}-'
      '${utc.hour.toString().padLeft(2, '0')}${utc.minute.toString().padLeft(2, '0')}${utc.second.toString().padLeft(2, '0')}-'
      '${utc.millisecond.toString().padLeft(3, '0')}';

  // Timezone offset: ±HHmm
  final offset = now.timeZoneOffset;

  /// NOTE: '+' is not as url safe as '_'
  final offsetSign = offset.isNegative ? '-' : '_';
  final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
  final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(
    2,
    '0',
  );
  final timezonePart = '$offsetSign$offsetHours$offsetMinutes';

  // 4-character random part
  final randomPart = generateRandomChars(4);

  return '$datePart$timezonePart-$randomPart';
}
