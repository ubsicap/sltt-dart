import 'dart:convert';

import 'package:sltt_core/sltt_core.dart';
import 'package:test/test.dart';

void main() {
  group('EntityStatesResponse', () {
    test('deserializes the paginated entity-states response shape', () {
      final response = EntityStatesResponse.fromJson({
        'domainId': 'project-123',
        'domainType': 'project',
        'entityType': 'task',
        'items': [
          {'entityId': 'task-1', 'status': 'open'},
        ],
        'cursor': 'next-page',
        'hasMore': true,
        'timestamp': '2024-01-01T00:00:00Z',
      });

      expect(response.domainId, 'project-123');
      expect(response.entityType, 'task');
      expect(response.cursor, 'next-page');
      expect(response.hasMore, isTrue);
      expect(response.items, hasLength(1));
    });

    test('serializes with the projectId wrapper key and cursor field', () {
      final response = EntityStatesResponse(
        domainId: 'project-123',
        domainType: 'project',
        entityType: 'task',
        items: [
          {'entityId': 'task-1', 'status': 'open'},
        ],
        hasMore: true,
        cursor: 'next-page',
        timestamp: '2024-01-01T00:00:00Z',
      );

      final json = response.toJson();

      expect(json['projectId'], 'project-123');
      expect(json['cursor'], 'next-page');
      expect(json['nextCursor'], isNull);
      expect(json['hasMore'], isTrue);
    });

    test('serializes stable payloads with item maps normalized', () {
      final response = EntityStatesResponse(
        domainId: 'project-123',
        domainType: 'project',
        entityType: 'task',
        items: [
          {'b': 2, 'a': 1},
        ],
        hasMore: true,
        cursor: 'next-page',
        timestamp: '2024-01-01T00:00:00Z',
      );

      final json = response.toJsonStable();

      expect(
        jsonEncode(json['items']),
        jsonEncode([
          {'a': 1, 'b': 2},
        ]),
        reason: 'stable payload should normalize item-map ordering',
      );
    });
  });

  group('CrossDomainEntityStatesResponse', () {
    test('deserializes the exact cross-domain pagination shape', () {
      final response = CrossDomainEntityStatesResponse.fromJson({
        'items': [
          {'entityId': 'task-1', 'status': 'open'},
        ],
        'nextCursor': 'next-page',
        'count': 1,
      });

      expect(response.items, hasLength(1));
      expect(response.nextCursor, 'next-page');
      expect(response.count, 1);
    });

    test('serializes the exact cross-domain pagination shape', () {
      final response = CrossDomainEntityStatesResponse(
        items: [
          {'entityId': 'task-1', 'status': 'open'},
        ],
        nextCursor: 'next-page',
        count: 1,
      );

      final json = response.toJson();

      expect(json['items'], hasLength(1));
      expect(json['nextCursor'], 'next-page');
      expect(json['cursor'], isNull);
      expect(json['count'], 1);
    });

    test('serializes stable payloads with metadata first and items last', () {
      final response = CrossDomainEntityStatesResponse(
        items: [
          {'b': 2, 'a': 1},
        ],
        nextCursor: 'next-page',
        count: 1,
      );

      final json = response.toJsonStable();
      expect(
        jsonEncode(json['items']),
        jsonEncode([
          {'a': 1, 'b': 2},
        ]),
      );
    });
  });
}
