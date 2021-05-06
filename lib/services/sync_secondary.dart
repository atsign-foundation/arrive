// ignore: implementation_imports
import 'package:at_client/src/manager/sync_manager.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';

class SyncSecondary {
  static final SyncSecondary _singleton = SyncSecondary._();
  SyncSecondary._();

  factory SyncSecondary() => _singleton;

  bool syncing = false;

  notifyAllInSync(AtKey atKey, String notification, OperationEnum operation,
      {bool isDedicated = MixedConstants.isDedicated}) async {
    while (syncing) {
      await Future.delayed(Duration(seconds: 4));
      print('waiting in notifyAllInSync');
    }

    var notifyAllResult = await BackendService.getInstance()
        .atClientInstance
        .notifyAll(atKey, notification, OperationEnum.update,
            isDedicated: isDedicated);

    return notifyAllResult;
  }

  callSyncSecondary() async {
    if (syncing) {
      return;
    } else {
      await _syncSecondary();
    }
  }

  _syncSecondary() async {
    syncing = true;

    try {
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
    } catch (e) {
      print('error in _syncSecondary $e');
      syncing = false;
    }
  }
}
