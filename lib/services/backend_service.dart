import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/dialog_box/share_location_notifier_dialog.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/services/request_location_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';

import 'package:at_client/src/manager/sync_manager.dart';
import 'location_notification_listener.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  String _atsign;
  // ignore: non_constant_identifier_names
  String app_lifecycle_state;
  AtClientPreference atClientPreference;
  bool autoAcceptFiles = false;
  String get currentAtsign => _atsign;
  OutboundConnection monitorConnection;
  Directory downloadDirectory;
  Map<String, AtClientService> atClientServiceMap = {};

  Future<bool> onboard({String atsign}) async {
    atClientServiceInstance = AtClientService();
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }

    final appSupportDirectory =
        await path_provider.getApplicationSupportDirectory();
    print("paths => $downloadDirectory $appSupportDirectory");
    String path = appSupportDirectory.path;
    atClientPreference = AtClientPreference();

    atClientPreference.isLocalStoreRequired = true;
    atClientPreference.commitLogPath = path;
    atClientPreference.syncStrategy = SyncStrategy.IMMEDIATE;
    atClientPreference.rootDomain = MixedConstants.ROOT_DOMAIN;
    atClientPreference.hiveStoragePath = path;
    atClientPreference.downloadPath = downloadDirectory.path;
    atClientPreference.outboundConnectionTimeout = MixedConstants.TIME_OUT;
    atClientPreference.namespace = MixedConstants.appNamespace;
    atClientPreference.syncRegex = MixedConstants.syncRegex;
    var result = await atClientServiceInstance.onboard(
      atClientPreference: atClientPreference,
      atsign: atsign,
    );
    atClientInstance = atClientServiceInstance.atClient;
    return result;
  }

  Future<AtClientPreference> getAtClientPreference() async {
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..syncStrategy = SyncStrategy.IMMEDIATE
      ..rootDomain = MixedConstants.ROOT_DOMAIN
      ..namespace = MixedConstants.appNamespace
      ..syncRegex = MixedConstants.syncRegex
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return atClientServiceInstance.atClient.currentAtSign;
  }

  // ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceInstance.getPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String> getPublicKey(String atsign) async {
    return await atClientServiceInstance.getPublicKey(atsign);
  }

  Future<String> getAESKey(String atsign) async {
    return await atClientServiceInstance.getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    return await atClientServiceInstance.getEncryptedKeys(atsign);
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    _atsign = await getAtSign();
    String privateKey = await getPrivateKey(_atsign);
    // ignore: await_only_futures
    await atClientInstance.startMonitor(privateKey, fnCallBack);
    print("Monitor started");
    return true;
  }

  fnCallBack(var response) async {
    print('fnCallBack called');
    await syncWithSecondary();
    response = response.replaceFirst('notification:', '');
    var responseJson = jsonDecode(response);
    var value = responseJson['value'];
    var notificationKey = responseJson['key'];

    print('fn call back:$response , notification key: $notificationKey');

    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    var operation = responseJson['operation'];

    /// Check for blocked contact
    if (ContactService()
            .blockContactList
            .indexWhere((contact) => contact.atSign == fromAtSign) >=
        0) {
      print('Notification received from blocked contact $fromAtSign');
      return;
    }

    if (operation == 'delete') {
      if (atKey.toString().toLowerCase().contains('locationnotify')) {
        print('$notificationKey deleted');
        LocationNotificationListener().deleteReceivedData(fromAtSign);
        return;
      }

      if (atKey.toString().toLowerCase().contains('sharelocation')) {
        print('$notificationKey containing sharelocation deleted');
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.removePerson(atKey),
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {});
        return;
      }

      if (atKey.toString().toLowerCase().contains('requestlocation')) {
        print('$notificationKey containing requestlocation deleted');
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.removePerson(atKey),
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {});
        return;
      }
    }

    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        // ignore: return_of_invalid_type_from_catch_error
        .catchError((e) => print("error in decrypting: $e"));

    if (atKey.toString().toLowerCase().contains('event.locationnotify')) {
      // TODO:
      // Update the atGroup.member['latLng'] of the fromAtSign in the event that has this id
      // also add a new param atGroup.member['updatedAt'] with DateTime.now()
      // Send to all the users

      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      updateLocationData(locationData, atKey, fromAtSign);
    }

    /// Received when a request location's removed person is called
    /// Based on this current user will delete the original key
    if (atKey.toString().toLowerCase().contains('deleterequestacklocation')) {
      LocationNotificationModel msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      RequestLocationService().deleteKey(msg);
      return;
    }

    if (atKey.toString().toLowerCase().contains('locationnotify')) {
      LocationNotificationModel msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      LocationNotificationListener().updateHybridList(msg);
      return;
    }

    if (atKey.toString().contains('createevent')) {
      EventNotificationModel eventData =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));

      // TODO: update all the users location in our LocationNotificationListener

      if (eventData.isUpdate != null && eventData.isUpdate == false) {
        showMyDialog(fromAtSign, eventData: eventData);
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.addNewEvent(HybridNotificationModel(
                NotificationType.Event,
                eventNotificationModel: eventData)),
            taskName: (provider) => provider.HYBRID_ADD_EVENT,
            showLoader: false,
            onSuccess: (provider) {});
      } else if (eventData.isUpdate) {
        mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Event,
            eventNotificationModel: eventData));
      }
      return;
    }

    if (atKey.toString().contains('eventacknowledged')) {
      EventNotificationModel msg =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      createEventAcknowledge(msg, atKey, fromAtSign);
      return;
    }

    if (atKey.toString().contains('requestlocationacknowledged')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      RequestLocationService()
          .updateWithRequestLocationAcknowledge(locationData);
      return;
    }

    if (atKey.toString().contains('requestlocation')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (locationData.isAcknowledgment == true) {
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.mapUpdatedData(
                  convertEventToHybrid(NotificationType.Location,
                      locationNotificationModel: locationData),
                  // remove: (!locationData.isAccepted)
                ),
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {});
      } else {
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.addNewEvent(convertEventToHybrid(
                NotificationType.Location,
                locationNotificationModel: locationData)),
            taskName: (provider) => provider.HYBRID_ADD_EVENT,
            showLoader: false,
            onSuccess: (provider) {});

        showMyDialog(fromAtSign, locationData: locationData);
      }
      return;
    }

    if (atKey.toString().contains('sharelocationacknowledged')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      LocationSharingService().updateWithShareLocationAcknowledge(locationData);
      return;
    }

    if (atKey.toString().contains('sharelocation')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (locationData.isAcknowledgment == true) {
        mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Location,
            locationNotificationModel: locationData));
      } else {
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.addNewEvent(HybridNotificationModel(
                NotificationType.Location,
                locationNotificationModel: locationData)),
            taskName: (provider) => provider.HYBRID_ADD_EVENT,
            showLoader: false,
            onSuccess: (provider) {});

        showMyDialog(fromAtSign, locationData: locationData);
      }
      return;
    }
  }

  syncWithSecondary() async {
    SyncManager syncManager = atClientInstance.getSyncManager();
    var isSynced = await syncManager.isInSync();
    if (isSynced is bool && isSynced) {
    } else {
      await syncManager.sync();
    }
  }

  Future<void> showMyDialog(String fromAtSign,
      {EventNotificationModel eventData,
      LocationNotificationModel locationData}) async {
    return showDialog<void>(
      context: NavService.navKey.currentContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ShareLocationNotifierDialog(
          userName: fromAtSign,
          eventData: eventData,
          locationData: locationData,
        );
      },
    );
  }

  // TODO: Will be called when a group member wants to update his data
  void updateLocationData(LocationNotificationModel locationData, String atKey,
      String fromAtSign) async {
    try {
      String eventId =
          locationData.key.split('-')[1].split('@')[0]; // TODO: Might be wrong

      EventNotificationModel presentEventData;
      HomeEventService().allEvents.forEach((element) {
        if (element.key.contains('createevent-$eventId')) {
          presentEventData = EventNotificationModel.fromJson(jsonDecode(
              EventNotificationModel.convertEventNotificationToJson(
                  element.eventNotificationModel)));
        }
      });

      presentEventData.group.members.forEach((presentGroupMember) {
        if (presentGroupMember.atSign[0] != '@')
          presentGroupMember.atSign = '@' + presentGroupMember.atSign;

        if (fromAtSign[0] != '@') fromAtSign = '@' + fromAtSign;

        if (presentGroupMember.atSign.toLowerCase() ==
            fromAtSign.toLowerCase()) {
          presentGroupMember.tags['lat'] = locationData.lat;
          presentGroupMember.tags['long'] = locationData.long;
        }
      });

      presentEventData.isUpdate = true;

      List<String> allAtsignList = [];
      presentEventData.group.members.forEach((element) {
        allAtsignList.add(element.atSign);
      });

      var notification = EventNotificationModel.convertEventNotificationToJson(
          presentEventData);

      AtKey key = BackendService.getInstance().getAtKey(presentEventData.key);

      var result = await atClientInstance.put(key, notification);

      key.sharedWith = jsonEncode(allAtsignList);

      var notifyAllResult = await atClientInstance.notifyAll(
          key, notification, OperationEnum.update);

      if (result is bool && result) {
        mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Event,
            eventNotificationModel: presentEventData));
      }
    } catch (e) {
      print('error in event acknowledgement: $e');
    }
  }

  createEventAcknowledge(EventNotificationModel acknowledgedEvent, String atKey,
      String fromAtSign) async {
    try {
      String eventId =
          acknowledgedEvent.key.split('createevent-')[1].split('@')[0];

      EventNotificationModel presentEventData;
      HomeEventService().allEvents.forEach((element) {
        if (element.key.contains('createevent-$eventId')) {
          presentEventData = EventNotificationModel.fromJson(jsonDecode(
              EventNotificationModel.convertEventNotificationToJson(
                  element.eventNotificationModel)));
        }
      });

      List<String> response = await atClientInstance.getKeys(
        regex: 'createevent-$eventId',
      );

      AtKey key = BackendService.getInstance().getAtKey(response[0]);

      presentEventData.group.members.forEach((presentGroupMember) {
        acknowledgedEvent.group.members.forEach((acknowledgedGroupMember) {
          if (acknowledgedGroupMember.atSign[0] != '@')
            acknowledgedGroupMember.atSign =
                '@' + acknowledgedGroupMember.atSign;

          if (presentGroupMember.atSign[0] != '@')
            presentGroupMember.atSign = '@' + presentGroupMember.atSign;

          if (fromAtSign[0] != '@') fromAtSign = '@' + fromAtSign;

          if (acknowledgedGroupMember.atSign.toLowerCase() ==
                  presentGroupMember.atSign.toLowerCase() &&
              acknowledgedGroupMember.atSign.toLowerCase() ==
                  fromAtSign.toLowerCase()) {
            presentGroupMember.tags = acknowledgedGroupMember.tags;
          }
        });
      });
      presentEventData.isUpdate = true;
      List<String> allAtsignList = [];
      presentEventData.group.members.forEach((element) {
        allAtsignList.add(element.atSign);
      });

      var notification = EventNotificationModel.convertEventNotificationToJson(
          presentEventData);

      var result = await atClientInstance.put(key, notification);

      key.sharedWith = jsonEncode(allAtsignList);

      var notifyAllResult = await atClientInstance.notifyAll(
          key, notification, OperationEnum.update);

      if (result is bool && result) {
        mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Event,
            eventNotificationModel: presentEventData));
      }
    } catch (e) {
      print('error in event acknowledgement: $e');
    }
  }

  mapUpdatedDataToWidget(HybridNotificationModel notification) {
    providerCallback<HybridProvider>(NavService.navKey.currentContext,
        task: (t) => t.mapUpdatedData(notification),
        showLoader: false,
        taskName: (t) => t.HYBRID_MAP_UPDATED_EVENT_DATA,
        onSuccess: (t) {});
  }

  HybridNotificationModel convertEventToHybrid(
      NotificationType notificationType,
      {EventNotificationModel eventNotificationModel,
      LocationNotificationModel locationNotificationModel}) {
    return notificationType == NotificationType.Event
        ? HybridNotificationModel(notificationType,
            eventNotificationModel: eventNotificationModel)
        : HybridNotificationModel(notificationType,
            locationNotificationModel: locationNotificationModel);
  }

  getAtKey(String regexKey) {
    AtKey atKey = AtKey.fromString(regexKey);
    atKey.metadata.ttr = -1;
    atKey.metadata.ccd = true;
    return atKey;
  }
}
