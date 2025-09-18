import 'dart:math';

import 'package:sltt_core/src/services/uid_service.dart';
import 'package:test/test.dart';

void main() {
  test('generateRandomChars returns empty for non-positive size', () {
    expect(generateRandomChars(0), equals(''));
    expect(generateRandomChars(-5), equals(''));
  });

  test('generateRandomChars returns correct length and allowed chars', () {
    final s = generateRandomChars(16, rng: Random(42));
    expect(s.length, 16);
    const allowed =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (final ch in s.split('')) {
      expect(allowed.contains(ch), isTrue);
    }
  });
}
