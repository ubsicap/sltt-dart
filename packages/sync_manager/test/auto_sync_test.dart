import 'dart:async';

import 'package:sltt_core/sltt_core.dart';
import 'package:sync_manager/sync_manager.dart';
import 'package:test/test.dart';

void main() {
  SlttLogger.init();

  group('SyncManager auto-sync', () {
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
      syncManager.disableAutoSync();
      await syncManager.close();
      await localStorage.deleteDatabase();
    });

    test('can enable and disable auto-sync', () async {
      // Should start disabled
      expect(syncManager.autoSyncEnabled, isFalse);

      // Enable auto-sync
      syncManager.enableAutoSync();
      expect(syncManager.autoSyncEnabled, isTrue);

      // Disable auto-sync
      syncManager.disableAutoSync();
      expect(syncManager.autoSyncEnabled, isFalse);
    });

    test('change log subscription is created and cleaned up', () async {
      // Should start with no subscription
      expect(syncManager.changeLogSubscription, isNull);

      // Enable auto-sync
      syncManager.enableAutoSync();
      expect(syncManager.changeLogSubscription, isNotNull);

      // Disable auto-sync
      syncManager.disableAutoSync();
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
