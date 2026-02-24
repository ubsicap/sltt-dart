import 'package:sltt_core/src/models/id_service.dart';
import 'package:test/test.dart';

void main() {
  test('CoreIdParts validate', () {
    final id = '2026-0108-161325-580_06UK-XQZK-vidZ';
    final parts = CoreIdParts(id: id);
    expect(parts.YYYY, equals('2026'));
    expect(parts.mmdd, equals('0108'));
    expect(parts.HHMMss, equals('161325'));
    expect(parts.zzz, equals('580'));
    expect(parts.tzOffset, equals('_06'));
    expect(parts.usrHash, equals('UK'));
    expect(parts.randomPart, equals('XQZK'));
    expect(parts.suffix, equals('vidZ'));
    expect(() => parts.validate(), returnsNormally);
  });

  test('generateCoreId returns valid id', () {
    final id = generateCoreId(userId: 'user123', suffix: 'test');
    final parts = CoreIdParts(id: id);
    expect(() => parts.validate(), returnsNormally);
  });

  test('generateCoreId with different userId returns different usrHash', () {
    final id1 = generateCoreId(userId: 'user123', suffix: 'test');
    final id2 = generateCoreId(userId: 'user456', suffix: 'test');
    final parts1 = CoreIdParts(id: id1);
    final parts2 = CoreIdParts(id: id2);
    expect(parts1.usrHash, isNot(equals(parts2.usrHash)));
  });

  test('generateCoreId without userId returns UK part', () {
    final id1 = generateCoreId(suffix: 'test');
    final parts = CoreIdParts(id: id1);
    expect(parts.usrHash, equals('UK'));
  });

  test('generateCoreId with same userId returns same usrHash', () {
    final id1 = generateCoreId(userId: 'user123', suffix: 'test');
    final id2 = generateCoreId(userId: 'user123', suffix: 'test');
    final parts1 = CoreIdParts(id: id1);
    final parts2 = CoreIdParts(id: id2);
    expect(parts1.usrHash, equals(parts2.usrHash));
  });
}
