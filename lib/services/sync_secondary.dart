// ignore: implementation_imports
import 'package:at_client/src/manager/sync_manager.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';

class SyncSecondary {
  static final SyncSecondary _singleton = SyncSecondary._();
  SyncSecondary._();

  factory SyncSecondary() => _singleton;

  List<SyncOperationDetails> _operations = [], _priorityOperations = [];

  bool syncing = false;

  callSyncSecondary(
    SyncOperation _syncOperation, {
    AtKey atKey,
    String notification,
    OperationEnum operation,
    bool isDedicated = MixedConstants.isDedicated,
  }) async {
    _operations.insert(
      0,
      SyncOperationDetails(
        _syncOperation,
        atKey: atKey,
        notification: notification,
        operation: operation,
        isDedicated: isDedicated,
      ),
    );
    if (syncing) {
      return;
    } else {
      _startSyncing();
    }
  }

  completePrioritySync(String _response) {
    _priorityOperations.add(
        SyncOperationDetails(SyncOperation.syncSecondary, response: _response));
    if (!syncing) {
      _startSyncing();
    }
  }

  _startSyncing() async {
    syncing = true;

    while ((_operations.length > 0) || (_priorityOperations.length > 0)) {
      if (_priorityOperations.length > 0) {
        var _tempPriorityOperations = _priorityOperations;
        _priorityOperations = [];
        _operations.removeWhere((_operation) =>
            _operation.syncOperation == SyncOperation.syncSecondary);
        await _syncSecondary();
        _executeAfterSynced(_tempPriorityOperations);
      }

      if (_operations.length > 0) {
        SyncOperationDetails _syncOperationDetails = _operations.removeLast();
        if (_syncOperationDetails.syncOperation == SyncOperation.notifyAll) {
          await _notifyAllInSync(
            _syncOperationDetails.atKey,
            _syncOperationDetails.notification,
            _syncOperationDetails.operation,
          );
        } else {
          _operations.removeWhere((_operation) =>
              _operation.syncOperation == SyncOperation.syncSecondary);
          await _syncSecondary();
        }
      }
    }

    syncing = false;
  }

  _executeAfterSynced(List<SyncOperationDetails> _tempPriorityOperations) {
    _tempPriorityOperations.forEach((e) {
      if (e.response != null) {
        BackendService.getInstance().afterSynced(e.response);
      }
    });
  }

  _notifyAllInSync(AtKey atKey, String notification, OperationEnum operation,
      {bool isDedicated = MixedConstants.isDedicated}) async {
    var notifyAllResult = await BackendService.getInstance()
        .atClientInstance
        .notifyAll(atKey, notification, OperationEnum.update,
            isDedicated: isDedicated);

    print('notifyAllResult $notifyAllResult');
  }

  _syncSecondary() async {
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
    } catch (e) {
      print('error in _syncSecondary $e');
    }
  }
}

class SyncOperationDetails {
  SyncOperation syncOperation;
  AtKey atKey;
  String notification;
  OperationEnum operation;
  bool isDedicated;
  String response;

  SyncOperationDetails(
    this.syncOperation, {
    this.response,
    this.atKey,
    this.notification,
    this.operation,
    this.isDedicated,
  });
}

enum SyncOperation { syncSecondary, notifyAll }
