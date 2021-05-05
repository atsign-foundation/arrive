// ignore: implementation_imports
import 'package:at_client/src/manager/sync_manager.dart';
import 'package:atsign_location_app/services/backend_service.dart';

class SyncSecondary {
  static final SyncSecondary _singleton = SyncSecondary._();
  SyncSecondary._();

  factory SyncSecondary() => _singleton;

  bool syncing = false;

  callSyncSecondary() async {
    if (syncing) {
      return;
    } else {
      await syncSecondary();
    }
  }

  syncSecondary() async {
    syncing = true;

    SyncManager syncManager =
        BackendService.getInstance().atClientInstance.getSyncManager();
    var isSynced = await syncManager.isInSync();
    print('already synced: $isSynced');
    if (isSynced is bool && isSynced) {
    } else {
      await syncManager.sync();
      print('sync done');
    }

    syncing = false;
  }
}
