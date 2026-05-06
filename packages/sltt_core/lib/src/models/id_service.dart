// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:sltt_core/sltt_core.dart' show generateRandomChars;

import '../services/date_time_service.dart';

/// Generates a unique core ID (Change ID) in format: (local) YYYY-mmdd-HHMMss-sss[-_]HH{UC}-{4-character-random}
/// ({String? userId}) embed 2 character hash of the userId after the timezone hour offset, 'UK' by default
/// Generates a unique core ID (Change ID) in format: (local) YYYY-mmdd-HHMMss-sss[-_]HH{UC}-{4-character-random}-{suffix}
/// ({String? userId}) embed 2 character hash of the userId after the timezone hour offset, 'UK' by default
String generateCoreId({String? userId, required String suffix}) {
  final context = generateCoreIdWithContext(userId: userId);
  return context.computeCoreId(suffix);
}

CoreIdContext generateCoreIdWithContext({String? userId}) {
  final hlc = HlcTimestampGenerator.generate();
  final localHlc = hlc.toLocal();
  final localOffset = localHlc.timeZoneOffset;
  final localOffsetSign = localOffset.isNegative ? '-' : '_';
  final localOffsetHours = localOffset.inHours.abs().toString().padLeft(2, '0');
  final localDtSeparator = '-';
  final localYearPart = localHlc.year.toString().padLeft(4, '0');
  final localMonthPart = localHlc.month.toString().padLeft(2, '0');
  final localHourPart = localHlc.hour.toString().padLeft(2, '0');
  final localMinutePart = localHlc.minute.toString().padLeft(2, '0');
  final localSecondPart = localHlc.second.toString().padLeft(2, '0');
  final localMillisecond = localHlc.millisecond.toString().padLeft(3, '0');
  final localDatePartString =
      '$localYearPart$localDtSeparator'
      '$localMonthPart${localHlc.day.toString().padLeft(2, '0')}$localDtSeparator'
      '$localHourPart$localMinutePart$localSecondPart$localDtSeparator'
      '$localMillisecond';
  final localTimezonePart = '$localOffsetSign$localOffsetHours';
  final randomPart = generateRandomChars(4, rng: Random());
  final userCode = (userId != null)
      ? generateRandomChars(
          2,
          chars: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
          rng: Random(userId.hashCode),
        )
      : 'UK';

  return CoreIdContext(
    hlc: hlc,
    localHlc: localHlc,
    localOffset: localOffset,
    localOffsetSign: localOffsetSign,
    localOffsetHours: localOffsetHours,
    localDtSeparator: localDtSeparator,
    localYearPart: localYearPart,
    localMonthPart: localMonthPart,
    localHourPart: localHourPart,
    localMinutePart: localMinutePart,
    localSecondPart: localSecondPart,
    localMillisecond: localMillisecond,
    localDatePartString: localDatePartString,
    localTimezonePart: localTimezonePart,
    randomPart: randomPart,
    userCode: userCode,
  );
}

class CoreIdContext {
  final DateTime hlc;
  final DateTime localHlc;
  final Duration localOffset;
  final String localOffsetSign;
  final String localOffsetHours;
  final String localDtSeparator;
  final String localYearPart;
  final String localMonthPart;
  final String localHourPart;
  final String localMinutePart;
  final String localSecondPart;
  final String localMillisecond;
  final String localDatePartString;
  final String localTimezonePart;
  final String randomPart;
  final String userCode;

  CoreIdContext({
    required this.hlc,
    required this.localHlc,
    required this.localOffset,
    required this.localOffsetSign,
    required this.localOffsetHours,
    required this.localDtSeparator,
    required this.localYearPart,
    required this.localMonthPart,
    required this.localHourPart,
    required this.localMinutePart,
    required this.localSecondPart,
    required this.localMillisecond,
    required this.localDatePartString,
    required this.localTimezonePart,
    required this.randomPart,
    required this.userCode,
  });

  String computeCoreId(String suffix) {
    return '$localDatePartString$localTimezonePart$userCode-$randomPart-$suffix';
  }
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
