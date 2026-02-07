import 'dart:math';

/// Generates a unique core ID (Change ID) in format: (local) YYYY-mmdd-HHMMss-sss[-_]HH{UC}-{4-character-random}
/// ({String? userId}) embed 2 character hash of the userId after the timezone hour offset, 'UK' by default
/// Generates a unique core ID (Change ID) in format: (local) YYYY-mmdd-HHMMss-sss[-_]HH{UC}-{4-character-random}-{suffix}
/// ({String? userId}) embed 2 character hash of the userId after the timezone hour offset, 'UK' by default
String generateCoreId({String? userId, required String suffix}) {
  final now = DateTime.now();
  final local = now.toLocal();

  // Format: YYYY-mmdd-HHMMss-sss
  final datePart =
      '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}${local.day.toString().padLeft(2, '0')}-'
      '${local.hour.toString().padLeft(2, '0')}${local.minute.toString().padLeft(2, '0')}${local.second.toString().padLeft(2, '0')}-'
      '${local.millisecond.toString().padLeft(3, '0')}';

  // Timezone offset: ±HHmm
  final offset = local.timeZoneOffset;
  final offsetSign = offset.isNegative ? '-' : '_';
  final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
  final timezonePart = '$offsetSign$offsetHours';

  // 4-character random part
  final rng = Random();
  final randomPart = generateRandomChars(4, rng: rng);
  final userCode = (userId != null)
      ? generateRandomChars(
          2,
          chars: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
          rng: Random(1234567890),
        )
      : 'UK';
  return '$datePart$timezonePart$userCode-$randomPart-$suffix';
}

/// Generates a random string of [length] using [chars] and [rng].
String generateRandomChars(int length, {String? chars, Random? rng}) {
  const defaultChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final charSet = chars ?? defaultChars;
  final random = rng ?? Random();
  return List.generate(
    length,
    (_) => charSet[random.nextInt(charSet.length)],
  ).join();
}

/// Extracts the YYYY (year) part from an id string.
String extractYYYY(String id) => id.substring(0, 4);

/// Extracts the mmdd (month and day) part from an id string.
String extractMMDD(String id) => id.substring(5, 9);

/// Extracts the HHMMss (hour, minute, second) part from an id string.
String extractHHMMss(String id) => id.substring(10, 16);

/// Extracts the zzz (millisecond) part from an id string.
String extractZZZ(String id) => id.substring(17, 20);

/// Extracts the tzOffset (timezone offset, e.g. -06 or _06) part from an id string.
String extractTzOffset(String id) => id.substring(20, 23);

/// Extracts the usrHash (user hash, 2 chars) part from an id string.
String extractUsrHash(String id) => id.substring(23, 25);

/// Extracts the randomPart (4 chars) from an id string.
String extractRandomPart(String id) => id.substring(26, 30);

/// Extracts the suffix (4 chars) from an id string.
String extractSuffix(String id) => id.substring(31, 35);

/// Validates the structure of a generated id string (lengths and field sizes).
/// Throws FormatException if invalid.
void validateIdStructure({
  required String id,
  required String YYYY,
  required String mmdd,
  required String HHMMss,
  required String zzz,
  required String tzOffset,
  required String usrHash,
  required String randomPart,
  required String suffix,
  int expectedLength = 35,
}) {
  if (id.length != expectedLength) {
    throw FormatException(
      'Invalid id length: \\${id.length}, expected \\$expectedLength',
    );
  }
  if (YYYY.length != 4 ||
      mmdd.length != 4 ||
      HHMMss.length != 6 ||
      zzz.length != 3 ||
      tzOffset.length != 3 ||
      usrHash.length != 2 ||
      randomPart.length != 4 ||
      suffix.length != 4) {
    throw FormatException('Invalid id format: \\$id');
  }
}

/// Example: 2026-0108-161325-580-06UK-XQZK-viTr
class CoreIdParts {
  final String YYYY;
  final String mmdd;
  final String HHMMss;
  final String zzz;

  /// [_-]HH
  final String tzOffset;

  /// {UC}
  final String usrHash;
  final String randomPart;
  final String suffix;
  final String id;

  void validate({int expectedLength = 35}) {
    validateIdStructure(
      id: id,
      YYYY: YYYY,
      mmdd: mmdd,
      HHMMss: HHMMss,
      zzz: zzz,
      tzOffset: tzOffset,
      usrHash: usrHash,
      randomPart: randomPart,
      suffix: suffix,
      expectedLength: expectedLength,
    );
  }

  CoreIdParts({required this.id})
    : YYYY = extractYYYY(id),
      mmdd = extractMMDD(id),
      HHMMss = extractHHMMss(id),
      zzz = extractZZZ(id),
      tzOffset = extractTzOffset(id),
      usrHash = extractUsrHash(id),
      randomPart = extractRandomPart(id),
      suffix = extractSuffix(id);
}
