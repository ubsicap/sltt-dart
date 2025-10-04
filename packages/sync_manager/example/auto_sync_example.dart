// Example usage of the new auto-sync functionality

import 'package:sync_manager/sync_manager.dart';

void main() async {
  // Initialize the sync manager
  final syncManager = SyncManager.instance;
  await syncManager.initialize();

  // Enable automatic synchronization
  // This will listen for changes to the change log entries and trigger
  // a full sync 500ms after the last change
  syncManager.enableAutoSync();

  // You can also enable auto-sync for a specific domain
  syncManager.enableAutoSync(domainType: 'project');

  // Or for a specific entity within a domain
  syncManager.enableAutoSync(domainType: 'project', domainId: 'my-project-123');

  // Now any changes to entities will automatically trigger sync after 500ms

  // Later, when you want to stop auto-sync:
  syncManager.disableAutoSync();

  // Always clean up when done
  await syncManager.close();
}
