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
}
