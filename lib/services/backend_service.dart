import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
// import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/common_components/dialog_box/share_location_notifier_dialog.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/models/message_notification.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/services/request_location_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';

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
  Function ask_user_acceptance;
  String app_lifecycle_state;
  AtClientPreference atClientPreference;
  bool autoAcceptFiles = false;
  final String AUTH_SUCCESS = "Authentication successful";
  String get currentAtsign => _atsign;
  OutboundConnection monitorConnection;
  Directory downloadDirectory;

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
    var result = await atClientServiceInstance.onboard(
      atClientPreference: atClientPreference,
      atsign: atsign,
    );
    atClientInstance = atClientServiceInstance.atClient;
    return result;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return await atClientServiceInstance.getAtSign();
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
    await atClientInstance.startMonitor(privateKey, fnCallBack);
    print("Monitor started");
    return true;
  }

  fnCallBack(var response) async {
    print('fnCallBack called');
    response = response.replaceFirst('notification:', '');
    var responseJson = jsonDecode(response);
    var value = responseJson['value'];
    var notificationKey = responseJson['key'];
    print('fn call back:${response} , notification key: ${notificationKey}');
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        .catchError((e) =>
            print("error in decrypting: ${e.errorCode} ${e.errorMessage}"));
    if (atKey.toString().contains('locationNotify')) {
      LocationNotificationModel msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      LocationNotificationListener().updateHybridList(msg);
    } else if (atKey.toString().contains('createevent')) {
      EventNotificationModel eventData =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (eventData.isUpdate != null && eventData.isUpdate == false) {
        showMyDialog(fromAtSign, eventData: eventData);
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.addNewEvent(HybridNotificationModel(
                NotificationType.Event,
                eventNotificationModel: eventData)),
            taskName: (provider) => provider.HYBRID_ADD_EVENT,
            showLoader: false,
            onSuccess: (provider) {
              provider.findAtSignsToShareLocationWith();
              provider.initialiseLacationSharing();
            });
      } else if (eventData.isUpdate)
        mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Event,
            eventNotificationModel: eventData));
    } else if (atKey.toString().contains('eventacknowledged')) {
      EventNotificationModel msg =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      createEventAcknowledge(msg, atKey);
    } else if (atKey.toString().contains('requestlocationacknowledged')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('sharelocationacknowledged ${locationData.isAccepted}');
      RequestLocationService()
          .updateWithRequestLocationAcknowledge(locationData);
      // if .isAccepted = true -> delete the key
      // .isAccepted = false -> update the key with isAccepted = false
    } else if (atKey.toString().contains('requestlocation')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (locationData.isAcknowledgment == true) {
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.mapUpdatedData(
                convertEventToHybrid(NotificationType.Location,
                    locationNotificationModel: locationData),
                remove: (!locationData
                    .isAccepted)), // if isAccepted = true => dont remove, else remove
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {
              provider.findAtSignsToShareLocationWith();
              provider.initialiseLacationSharing();
            });

        print('add this to our list');
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
      // yes -> new notification with key 'sharelocation' & .isAcknowledgment = true && add toyour list
      //      along with a new notification with key 'requestlocationacknowledged' & isAccepted = yes
      // no -> a new notification with key 'requestlocationacknowledged' & isAccepted = no
    } else if (atKey.toString().contains('sharelocationacknowledged')) {
      // TODO: compare with location-sharing branch
      // if someone reacts to my share location notification
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('sharelocationacknowledged ${locationData.isAccepted}');
      LocationSharingService().updateWithShareLocationAcknowledge(locationData);
    } else if (atKey.toString().contains('sharelocation')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('backend service -> ${locationData.isAccepted}');
      if (locationData.isAcknowledgment == true) {
        mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Location,
            locationNotificationModel: locationData));

        print('add this to our list');
      } else {
        print('add this to our list else');
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.addNewEvent(HybridNotificationModel(
                NotificationType.Location,
                locationNotificationModel: locationData)),
            taskName: (provider) => provider.HYBRID_ADD_EVENT,
            showLoader: false,
            onSuccess: (provider) {});

        showMyDialog(fromAtSign, locationData: locationData);
      }
      // yes -> new notification with key 'sharelocationacknowledged' & .isAccepted = true && add toyour list
      // no -> new notification with key 'sharelocationacknowledged' & .isAccepted = false
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

  createEventAcknowledge(
      EventNotificationModel acknowledgedEvent, String atKey) async {
    String eventId = atKey.split('eventacknowledged-')[1].split('@')[0];
    print(
        'acknowledged notification received:${acknowledgedEvent} , key:${atKey} , ${eventId}');

    EventNotificationModel presentEventData;
    HomeEventService().allEvents.forEach((element) {
      if (element.key.contains('createevent-$eventId')) {
        presentEventData = element.eventNotificationModel;
      }
    });

    List<String> response = await atClientInstance.getKeys(
      regex: 'createevent-$eventId',
      // sharedBy: '@test_ga3',
      // sharedWith: '@test_ga3',
    );

    AtKey key = AtKey.fromString(response[0]);

    acknowledgedEvent.isUpdate = true;
    acknowledgedEvent.isCancelled = presentEventData.isCancelled;
    acknowledgedEvent.isSharing = presentEventData.isSharing;

    var notification = EventNotificationModel.convertEventNotificationToJson(
        acknowledgedEvent);

    print('notification:$notification');

    var result = await atClientInstance.put(key, notification);
    if (result)
      mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Event,
          eventNotificationModel: acknowledgedEvent));
    print('acknowledgement received:$result');
  }

  mapUpdatedDataToWidget(HybridNotificationModel notification) {
    providerCallback<HybridProvider>(NavService.navKey.currentContext,
        task: (t) => t.mapUpdatedData(notification),
        showLoader: false,
        taskName: (t) => t.HYBRID_MAP_UPDATED_EVENT_DATA,
        onSuccess: (t) {
          t.findAtSignsToShareLocationWith();
          t.initialiseLacationSharing();
        });
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

  sendMessage() async {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      // ..metadata.ttr = 10
      ..key = "${AllText().MSG_NOTIFY}/${DateTime.now()}"
      // ..key = "${AllText().LOCATION_NOTIFY}}"
      ..sharedWith = '@baila82brilliant';
    print('atKey: ${atKey.metadata}');

    var notification = json.encode({
      'content': 'Hi..',
      'acknowledged': 'false',
      'timeStamp': DateTime.now().toString()
    });
    // var notification = json.encode({
    //   'lat': '12',
    //   'long': '10'
    //   // 'timeStamp': DateTime.now().toString()
    // });
    var result = await atClientInstance.put(atKey, notification);
    print('send msg result:$result');
  }

  getAllNotificationKeys() async {
    atClientInstance =
        ClientSdkService.getInstance().atClientServiceInstance.atClient;
    List<String> response = await atClientInstance.getKeys(
      regex: '1610648226523619',
      // sharedBy: '@test_ga3',
      // sharedWith: '@test_ga3',
    );
    print('keys:${response}');
    print('sharedBy:${response[0]}, ${response[0].contains('cached')}');

    AtKey key = AtKey.fromString(response[1]);
    print('key :${key.key} , ${key}');

    AtValue result = await atClientInstance.get(key).catchError(
        (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));
    print('result - ${result.value}');

    EventNotificationModel msg =
        EventNotificationModel.fromJson(jsonDecode(result.value));

    print(
        'EventNotificationModel msg:${msg.group.name},members: ${msg.group.members}');
  }

  updateNotification() async {
    List<String> response = await atClientInstance.getKeys(
      regex: '1610602925484075',
    );
    print('response:${response}, ${response.length}');
    AtKey key0 = AtKey.fromString(response[0]);
    AtKey key1 = AtKey.fromString(response[1]);
    print('key0 :${key0} ,key1: ${key1}');

    // var result =
    //     await atClientInstance.put(key, json.encode({'changed': 'value2'}));
    // print('update result:${result}');
  }
}
