import 'package:sltt_core/sltt_core.dart' show getDomainRootEntityType;
import 'package:test/test.dart';

void main() {
  group('getDomainRootEntityType', () {
    test(
      'project root entity matches when entityId == domainId and type matches',
      () {
        expect(getDomainRootEntityType('project'), equals('project'));
      },
    );

    test('user root entity uses user_profile type', () {
      expect(getDomainRootEntityType('user'), equals('user_profile'));
    });

    test('membership root entity uses member type', () {
      expect(getDomainRootEntityType('membership'), equals('member'));
    });

    test('non-root when entityType mismatches', () {
      expect(getDomainRootEntityType('randomDomain'), equals(null));
    });
  });
}
