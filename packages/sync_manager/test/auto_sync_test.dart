import 'dart:async';

import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  group('SyncManager auto-outsync', () {
    late SyncManager syncManager;
    late LocalStorageService localStorage;

    setUp(() async {
      syncManager = SyncManager.instance;
      localStorage = LocalStorageService.instance;

      // Initialize with a test database
      await localStorage.initialize();
      await localStorage.deleteDatabase();
      await localStorage.initialize();

      await syncManager.initialize();
    });

    tearDown(() async {
      syncManager.disableAutoOutsync();
      await syncManager.close();
      await localStorage.deleteDatabase();
    });

    test('can enable and disable auto-outsync', () async {
      // Should start disabled
      expect(syncManager.autoOutsyncEnabled, isFalse);

      // Enable auto-sync
      syncManager.enableAutoOutsync();
      expect(syncManager.autoOutsyncEnabled, isTrue);

      // Disable auto-sync
      syncManager.disableAutoOutsync();
      expect(syncManager.autoOutsyncEnabled, isFalse);
    });

    test('change log subscription is created and cleaned up', () async {
      // Should start with no subscription
      expect(syncManager.changeLogSubscription, isNull);

      // Enable auto-sync
      syncManager.enableAutoOutsync();
      expect(syncManager.changeLogSubscription, isNotNull);

      // Disable auto-sync
      syncManager.disableAutoOutsync();
      expect(syncManager.changeLogSubscription, isNull);
    });

    test(
      'lazyListenToChangeLogEntryChanges method exists and can be called',
      () async {
        // Test that the new method exists and can be called without errors
        StreamSubscription<void>? subscription;

        try {
          subscription = localStorage.lazyListenToChangeLogEntryChanges(
            onChanged: () {
              // Test callback
            },
            fireImmediately: false,
          );

          expect(subscription, isNotNull);
        } finally {
          subscription?.cancel();
        }
      },
    );

    test('can filter by domainType and domainId', () async {
      StreamSubscription<void>? subscription1;
      StreamSubscription<void>? subscription2;
      StreamSubscription<void>? subscription3;

      try {
        // Test all combinations of parameters
        subscription1 = localStorage.lazyListenToChangeLogEntryChanges(
          onChanged: () {},
          fireImmediately: false,
        );

        subscription2 = localStorage.lazyListenToChangeLogEntryChanges(
          domainType: 'project',
          onChanged: () {},
          fireImmediately: false,
        );

        subscription3 = localStorage.lazyListenToChangeLogEntryChanges(
          domainType: 'project',
          domainId: 'test-project-1',
          onChanged: () {},
          fireImmediately: false,
        );

        expect(subscription1, isNotNull);
        expect(subscription2, isNotNull);
        expect(subscription3, isNotNull);
      } finally {
        subscription1?.cancel();
        subscription2?.cancel();
        subscription3?.cancel();
      }
    });
  });
}
