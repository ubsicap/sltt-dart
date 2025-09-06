import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:syncable_entity_state_data/src/generator.dart';
import 'package:test/test.dart';

void main() {
  group('SyncableEntityStateDataGenerator failure', () {
    test('fails generation when field not Isar compatible (enforced)',
        () async {
      const source = r'''// test input
        import 'package:syncable_entity_state_data/syncable_entity_state_data.dart';

        class CustomType { final int x; const CustomType(this.x); }

        @SyncableEntityStateData(enforceIsarCompatibility: true)
        class BadData implements CoreSyncableEntityDataFields {
          @override
          final String parentId;
          @override
          final bool? deleted;
          @override
            final String? rank;
          final CustomType complex; // not supported
          const BadData({
            required this.parentId,
            this.deleted,
            this.rank,
            required this.complex,
          });
        }
      ''';

      final assets = {
        'syncable_entity_state_data|lib/bad_data.dart': source,
      };

      final builder = syncableEntityStateDataBuilder(BuilderOptions(const {}));
      final reader = await PackageAssetReader.currentIsolate();
      await expectLater(
        () => testBuilder(
          builder,
          assets,
          reader: reader,
          generateFor: const {'syncable_entity_state_data|lib/bad_data.dart'},
        ),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('Fields not Isar-compatible'),
          ),
        ),
      );
    });
  });
}
