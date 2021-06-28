import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/dialog_box/share_location_notifier_dialog.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/sync_secondary.dart';

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
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';

import 'package:at_client/src/manager/sync_manager.dart';
import 'package:provider/provider.dart';
import 'location_notification_listener.dart';
import 'package:atsign_location_app/routes/routes.dart';

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

  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();
  Future<List<String>> getAtsignList() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    return atSignsList;
  }

  deleteAtSignFromKeyChain(String atsign) async {
    List<String> atSignList = await getAtsignList();

    await atClientServiceMap[atsign].deleteAtSignFromKeychain(atsign);

    if (atSignList != null) {
      atSignList
          .removeWhere((element) => element == atClientInstance.currentAtSign);
    }

    var atClientPrefernce;
    await getAtClientPreference().then((value) => atClientPrefernce = value);
    var tempAtsign;
    if (atSignList == null || atSignList.isEmpty) {
      tempAtsign = '';
    } else {
      tempAtsign = atSignList.first;
    }

    if (tempAtsign == '') {
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext,
          Routes.SPLASH, (Route<dynamic> route) => false);
    } else {
      await Onboarding(
        atsign: tempAtsign,
        context: NavService.navKey.currentContext,
        atClientPreference: atClientPrefernce,
        domain: MixedConstants.ROOT_DOMAIN,
        appColor: Color.fromARGB(255, 240, 94, 62),
        onboard: (value, atsign) async {
          atClientServiceMap = value;

          String atSign = atClientServiceMap[atsign].atClient.currentAtSign;

          await atClientServiceMap[atSign].makeAtSignPrimary(atSign);
          atClientInstance = atClientServiceMap[atsign].atClient;
          atClientServiceInstance = atClientServiceMap[atsign];

          BackendService.getInstance().startMonitor();
          // await initializeContactsService(
          //     atClientInstance, atClientInstance.currentAtSign);
          // await onboard(atsign: atsign, atClientPreference: atClientPreference, atClientServiceInstance: );
          // await Navigator.pushNamedAndRemoveUntil(
          //     NavService.navKey.currentContext,
          //     Routes.SPLASH,
          //     (Route<dynamic> route) => false);
          SetupRoutes.pushAndRemoveAll(
              NavService.navKey.currentContext, Routes.HOME);
        },
        onError: (error) {
          print('Onboarding throws $error error');
        },
        // nextScreen: WelcomeScreen(),
      );
    }
    // if (atClientInstance != null) {
    //   await startMonitor();
    // }
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

  decodeJSON(String response) async {
    try {
      var result = jsonDecode(response);
      print('length without error ${response.length}');
      return result;
    } catch (e) {
      print('length with error ${response.length}');

      print('error in decodeJSON $e');

      if (e is FormatException) {
        print('${e.offset} length');
        List<String> splitOnComma = response.split(',');

        print('splitOnComma length ${splitOnComma.length}');

        await Future.forEach(splitOnComma, (element) async {
          print('before element $element');

          element.toString().replaceAll('/"', '');
          print('element $element');
          var list = element.split(':');
          print('list length ${list.length}');

          print('list[0] ${list[0]}');

          if ((list.length != 0) && (list[0].contains('key'))) {
            print('key = ${list[1]}');
            print(
                'atkey ${list[2].toString().substring(0, list[2].toString().length - 1)}');
            AtKey key = BackendService.getInstance().getAtKey(
                list[2].toString().substring(0, list[2].toString().length - 1));
            print('atkey = $key');

            AtValue atvalue = await atClientInstance
                .get(key)
                // ignore: return_of_invalid_type_from_catch_error
                .catchError((e) => print("error in get decodeJSON $e"));

            if (atvalue != null) {
              var notification = json.encode({
                "value": atvalue.value,
                "key": key.key,
                "from": key.sharedBy,
                "operation": "update",
              });
              print('notification $notification');

              return jsonDecode(notification);
            } else {
              return null;
            }
          }
        });
      }
    }
  }

  fnCallBack(var response) async {
    print('fnCallBack called');
    SyncSecondary().completePrioritySync(response);
  }

  afterSynced(var response) async {
    response = response.replaceFirst('notification:', '');
    print('length ${response.length} response $response');

    var responseJson = jsonDecode(response);
    // var responseJson = await decodeJSON(response);

    if (responseJson == null) {
      print('decodeJSON returned null');
      return;
    }

    var value = responseJson['value'];
    var notificationKey = responseJson['key'];

    // print('fn call back:$response , notification key: $notificationKey');

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

    if (atKey.toString().toLowerCase().contains('updateeventlocation')) {
      // TODO:
      // Update the atGroup.member['latLng'] of the fromAtSign in the event that has this id
      // also add a new param atGroup.member['updatedAt'] with DateTime.now()
      // Send to all the users

      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      updateLocationData(locationData, atKey, fromAtSign);
      return;
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

      if (eventData.isUpdate != null && eventData.isUpdate == false) {
        await providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.addNewEvent(HybridNotificationModel(
                NotificationType.Event,
                eventNotificationModel: eventData)),
            taskName: (provider) => provider.HYBRID_ADD_EVENT,
            showLoader: false,
            showDialog: false,
            onSuccess: (provider) {
              showMyDialog(fromAtSign, eventData: eventData);
            });
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

        if (locationData.rePrompt) {
          showMyDialog(fromAtSign, locationData: locationData);
        }
      } else {
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.addNewEvent(convertEventToHybrid(
                NotificationType.Location,
                locationNotificationModel: locationData)),
            taskName: (provider) => provider.HYBRID_ADD_EVENT,
            showLoader: false,
            showDialog: false,
            onSuccess: (provider) {
              showMyDialog(fromAtSign, locationData: locationData);
            });
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

        if (locationData.rePrompt) {
          showMyDialog(fromAtSign, locationData: locationData);
        }
      } else {
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.addNewEvent(HybridNotificationModel(
                NotificationType.Location,
                locationNotificationModel: locationData)),
            taskName: (provider) => provider.HYBRID_ADD_EVENT,
            showLoader: false,
            showDialog: false,
            onSuccess: (provider) {
              showMyDialog(fromAtSign, locationData: locationData);
            });
      }
      return;
    }
  }

  syncWithSecondary() async {
    await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
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
      Provider.of<HybridProvider>(NavService.navKey.currentContext,
              listen: false)
          .allHybridNotifications
          .forEach((element) {
        if (element.key.contains('createevent-$eventId')) {
          presentEventData = EventNotificationModel.fromJson(jsonDecode(
              EventNotificationModel.convertEventNotificationToJson(
                  element.eventNotificationModel)));

          // print(
          //     'presentEventData ${EventNotificationModel.convertEventNotificationToJson(presentEventData)}');
        }
      });

      if (presentEventData == null) {
        return;
      }

      Map<dynamic, dynamic> tags;

      presentEventData.group.members.forEach((presentGroupMember) {
        if (presentGroupMember.atSign[0] != '@')
          presentGroupMember.atSign = '@' + presentGroupMember.atSign;

        if (fromAtSign[0] != '@') fromAtSign = '@' + fromAtSign;

        if (presentGroupMember.atSign.toLowerCase() ==
            fromAtSign.toLowerCase()) {
          presentGroupMember.tags['lat'] = locationData.lat;
          presentGroupMember.tags['long'] = locationData.long;

          tags = presentGroupMember.tags;
        }

        // print('presentGroupMember ${presentGroupMember.tags}');
      });

      presentEventData.isUpdate = true;

      List<String> allAtsignList = [];
      presentEventData.group.members.forEach((element) {
        allAtsignList.add(element.atSign);
      });

      var notification = EventNotificationModel.convertEventNotificationToJson(
          presentEventData);

      AtKey key = BackendService.getInstance().getAtKey(presentEventData.key);

      var result = await atClientInstance.put(key, notification,
          isDedicated: MixedConstants.isDedicated);

      key.sharedWith = jsonEncode(allAtsignList);

      var notifyAllResult = await SyncSecondary().callSyncSecondary(
        SyncOperation.notifyAll,
        atKey: key,
        notification: notification,
        operation: OperationEnum.update,
        isDedicated: MixedConstants.isDedicated,
      );

      /// Dont sync as notifyAll is called

      if (result is bool && result) {
        mapUpdatedDataToWidget(
            convertEventToHybrid(NotificationType.Event,
                eventNotificationModel: presentEventData),
            tags: tags,
            tagOfAtsign: fromAtSign,
            updateLatLng: true);
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
      eventId = eventId.replaceAll('.rrive', '');

      EventNotificationModel presentEventData;
      Provider.of<HybridProvider>(NavService.navKey.currentContext,
              listen: false)
          .allHybridNotifications
          .forEach((element) {
        if (element.key.contains('createevent-$eventId')) {
          presentEventData = EventNotificationModel.fromJson(jsonDecode(
              EventNotificationModel.convertEventNotificationToJson(
                  element.eventNotificationModel)));

          // print(
          //     'presentEventData ${EventNotificationModel.convertEventNotificationToJson(presentEventData)}');
        }
      });

      List<String> response = await atClientInstance.getKeys(
        regex: 'createevent-$eventId',
      );

      AtKey key = BackendService.getInstance().getAtKey(response[0]);

      Map<dynamic, dynamic> tags;

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
            // print(
            //     'acknowledgedGroupMember.tags ${acknowledgedGroupMember.tags}');
            presentGroupMember.tags = acknowledgedGroupMember.tags;
            tags = presentGroupMember.tags;
          }
        });
        // print('presentGroupMember.tags ${presentGroupMember.tags}');
      });

      presentEventData.isUpdate = true;
      List<String> allAtsignList = [];
      presentEventData.group.members.forEach((element) {
        allAtsignList.add(element.atSign);
      });

      var notification = EventNotificationModel.convertEventNotificationToJson(
          presentEventData);

      // print('notification $notification');

      var result = await atClientInstance.put(key, notification,
          isDedicated: MixedConstants.isDedicated);

      key.sharedWith = jsonEncode(allAtsignList);

      var notifyAllResult = await SyncSecondary().callSyncSecondary(
        SyncOperation.notifyAll,
        atKey: key,
        notification: notification,
        operation: OperationEnum.update,
        isDedicated: MixedConstants.isDedicated,
      );

      /// Dont sync as notifyAll is called

      if (result is bool && result) {
        mapUpdatedDataToWidget(
            convertEventToHybrid(NotificationType.Event,
                eventNotificationModel: presentEventData),
            tags: tags,
            tagOfAtsign: fromAtSign);
        // print('acknowledgement for $fromAtSign completed');
      }
    } catch (e) {
      print('error in event acknowledgement: $e');
    }
  }

  mapUpdatedDataToWidget(HybridNotificationModel notification,
      {bool remove = false,
      Map<dynamic, dynamic> tags,
      String tagOfAtsign,
      bool updateLatLng = false}) {
    providerCallback<HybridProvider>(NavService.navKey.currentContext,
        task: (t) => t.mapUpdatedData(
              notification,
              tags: tags,
              tagOfAtsign: tagOfAtsign,
              updateLatLng: updateLatLng,
            ),
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
    // atKey.metadata.ttl = MixedConstants.maxTTL; // 7 days
    atKey.metadata.ccd = true;
    return atKey;
  }
}
