import 'dart:math';

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
