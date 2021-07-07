import 'dart:async';
import 'dart:io';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
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
    print('paths => $downloadDirectory $appSupportDirectory');
    var path = appSupportDirectory.path;
    atClientPreference = AtClientPreference();

    atClientPreference.isLocalStoreRequired = true;
    atClientPreference.commitLogPath = path;
    atClientPreference.syncStrategy = SyncStrategy.ONDEMAND;
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
    var path = appDocumentDirectory.path;
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

  // ignore: always_declare_return_types
  deleteAtSignFromKeyChain(String atsign) async {
    var atSignList = await getAtsignList();

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
      Onboarding(
        atsign: tempAtsign,
        context: NavService.navKey.currentContext,
        atClientPreference: atClientPrefernce,
        domain: MixedConstants.ROOT_DOMAIN,
        appColor: Color.fromARGB(255, 240, 94, 62),
        onboard: (value, atsign) async {
          atClientServiceMap = value;

          var atSign = atClientServiceMap[atsign].atClient.currentAtSign;

          await atClientServiceMap[atSign].makeAtSignPrimary(atSign);
          atClientInstance = atClientServiceMap[atsign].atClient;
          atClientServiceInstance = atClientServiceMap[atsign];

          SetupRoutes.pushAndRemoveAll(
              NavService.navKey.currentContext, Routes.HOME);
        },
        onError: (error) {
          print('Onboarding throws $error error');
        },
      );
    }
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  // Future<bool> startMonitor() async {
  // _atsign = await getAtSign();
  // String privateKey = await getPrivateKey(_atsign);
  // // ignore: await_only_futures
  // await atClientInstance.startMonitor(privateKey, fnCallBack);
  // print("Monitor started");
  //   return true;
  // }

  // decodeJSON(String response) async {
  //   try {
  //     var result = jsonDecode(response);
  //     print('length without error ${response.length}');
  //     return result;
  //   } catch (e) {
  //     print('length with error ${response.length}');

  //     print('error in decodeJSON $e');

  //     if (e is FormatException) {
  //       print('${e.offset} length');
  //       var splitOnComma = response.split(',');

  //       print('splitOnComma length ${splitOnComma.length}');

  //       await Future.forEach(splitOnComma, (element) async {
  //         print('before element $element');

  //         element.toString().replaceAll('/"', '');
  //         print('element $element');
  //         var list = element.split(':');
  //         print('list length ${list.length}');

  //         print('list[0] ${list[0]}');

  //         if ((list.length != 0) && (list[0].contains('key'))) {
  //           print('key = ${list[1]}');
  //           print(
  //               'atkey ${list[2].toString().substring(0, list[2].toString().length - 1)}');
  //           AtKey key = BackendService.getInstance().getAtKey(
  //               list[2].toString().substring(0, list[2].toString().length - 1));
  //           print('atkey = $key');

  //           var atvalue = await atClientInstance
  //               .get(key)
  //               // ignore: return_of_invalid_type_from_catch_error
  //               .catchError((e) => print('error in get decodeJSON $e'));

  //           if (atvalue != null) {
  //             var notification = json.encode({
  //               'value': atvalue.value,
  //               'key': key.key,
  //               'from': key.sharedBy,
  //               'operation': 'update',
  //             });
  //             print('notification $notification');

  //             return jsonDecode(notification);
  //           } else {
  //             return null;
  //           }
  //         }
  //       });
  //     }
  //   }
  // }

  // fnCallBack(var response) async {
  //   print('fnCallBack called');
  //   SyncSecondary().completePrioritySync(response);
  // }

  // afterSynced(var response) async {
  //   response = response.replaceFirst('notification:', '');
  //   print('length ${response.length} response $response');

  //   var responseJson = jsonDecode(response);
  //   // var responseJson = await decodeJSON(response);

  //   if (responseJson == null) {
  //     print('decodeJSON returned null');
  //     return;
  //   }

  //   var value = responseJson['value'];
  //   var notificationKey = responseJson['key'];

  //   // print('fn call back:$response , notification key: $notificationKey');

  //   var fromAtSign = responseJson['from'];
  //   var atKey = notificationKey.split(':')[1];
  //   var operation = responseJson['operation'];

  //   /// Check for blocked contact
  //   if (ContactService()
  //           .blockContactList
  //           .indexWhere((contact) => contact.atSign == fromAtSign) >=
  //       0) {
  //     print('Notification received from blocked contact $fromAtSign');
  //     return;
  //   }

  //   if (operation == 'delete') {
  //     if (atKey.toString().toLowerCase().contains('locationnotify')) {
  //       print('$notificationKey deleted');
  //       LocationNotificationListener().deleteReceivedData(fromAtSign);
  //       return;
  //     }

  //     if (atKey.toString().toLowerCase().contains('sharelocation')) {
  //       print('$notificationKey containing sharelocation deleted');
  //       providerCallback<HybridProvider>(NavService.navKey.currentContext,
  //           task: (provider) => provider.removePerson(atKey),
  //           taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
  //           showLoader: false,
  //           onSuccess: (provider) {});
  //       return;
  //     }

  //     if (atKey.toString().toLowerCase().contains('requestlocation')) {
  //       print('$notificationKey containing requestlocation deleted');
  //       providerCallback<HybridProvider>(NavService.navKey.currentContext,
  //           task: (provider) => provider.removePerson(atKey),
  //           taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
  //           showLoader: false,
  //           onSuccess: (provider) {});
  //       return;
  //     }
  //   }

  //   var decryptedMessage = await atClientInstance.encryptionService
  //       .decrypt(value, fromAtSign)
  //       // ignore: return_of_invalid_type_from_catch_error
  //       .catchError((e) => print('error in decrypting: $e'));

  //   if (atKey.toString().toLowerCase().contains('updateeventlocation')) {
  //     // Update the atGroup.member['latLng'] of the fromAtSign in the event that has this id
  //     // also add a new param atGroup.member['updatedAt'] with DateTime.now()
  //     // Send to all the users

  //     var locationData =
  //         LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
  //     updateLocationData(locationData, atKey, fromAtSign);
  //     return;
  //   }

  //   /// Received when a request location's removed person is called
  //   /// Based on this current user will delete the original key
  //   if (atKey.toString().toLowerCase().contains('deleterequestacklocation')) {
  //     var msg =
  //         LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
  //     RequestLocationService().deleteKey(msg);
  //     return;
  //   }

  //   if (atKey.toString().toLowerCase().contains('locationnotify')) {
  //     var msg =
  //         LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
  //     LocationNotificationListener().updateHybridList(msg);
  //     return;
  //   }

  //   if (atKey.toString().contains('createevent')) {
  //     var eventData =
  //         EventNotificationModel.fromJson(jsonDecode(decryptedMessage));

  //     if (eventData.isUpdate != null && eventData.isUpdate == false) {
  //       await providerCallback<HybridProvider>(NavService.navKey.currentContext,
  //           task: (provider) => provider.addNewEvent(HybridNotificationModel(
  //               NotificationType.Event,
  //               eventNotificationModel: eventData)),
  //           taskName: (provider) => provider.HYBRID_ADD_EVENT,
  //           showLoader: false,
  //           showDialog: false,
  //           onSuccess: (provider) {
  //             showMyDialog(fromAtSign, eventData: eventData);
  //           });
  //     } else if (eventData.isUpdate) {
  //       mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Event,
  //           eventNotificationModel: eventData));
  //     }
  //     return;
  //   }

  //   if (atKey.toString().contains('eventacknowledged')) {
  //     var msg = EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
  //     createEventAcknowledge(msg, atKey, fromAtSign);
  //     return;
  //   }

  //   if (atKey.toString().contains('requestlocationacknowledged')) {
  //     var locationData =
  //         LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
  //     RequestLocationService()
  //         .updateWithRequestLocationAcknowledge(locationData);
  //     return;
  //   }

  //   if (atKey.toString().contains('requestlocation')) {
  //     var locationData =
  //         LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
  //     if (locationData.isAcknowledgment == true) {
  //       providerCallback<HybridProvider>(NavService.navKey.currentContext,
  //           task: (provider) => provider.mapUpdatedData(
  //                 convertEventToHybrid(NotificationType.Location,
  //                     locationNotificationModel: locationData),
  //                 // remove: (!locationData.isAccepted)
  //               ),
  //           taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
  //           showLoader: false,
  //           onSuccess: (provider) {});

  //       if (locationData.rePrompt) {
  //         showMyDialog(fromAtSign, locationData: locationData);
  //       }
  //     } else {
  //       providerCallback<HybridProvider>(NavService.navKey.currentContext,
  //           task: (provider) => provider.addNewEvent(convertEventToHybrid(
  //               NotificationType.Location,
  //               locationNotificationModel: locationData)),
  //           taskName: (provider) => provider.HYBRID_ADD_EVENT,
  //           showLoader: false,
  //           showDialog: false,
  //           onSuccess: (provider) {
  //             showMyDialog(fromAtSign, locationData: locationData);
  //           });
  //     }
  //     return;
  //   }

  //   if (atKey.toString().contains('sharelocationacknowledged')) {
  //     var locationData =
  //         LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
  //     LocationSharingService().updateWithShareLocationAcknowledge(locationData);
  //     return;
  //   }

  //   if (atKey.toString().contains('sharelocation')) {
  //     var locationData =
  //         LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
  //     if (locationData.isAcknowledgment == true) {
  //       mapUpdatedDataToWidget(convertEventToHybrid(NotificationType.Location,
  //           locationNotificationModel: locationData));

  //       if (locationData.rePrompt) {
  //         showMyDialog(fromAtSign, locationData: locationData);
  //       }
  //     } else {
  //       providerCallback<HybridProvider>(NavService.navKey.currentContext,
  //           task: (provider) => provider.addNewEvent(HybridNotificationModel(
  //               NotificationType.Location,
  //               locationNotificationModel: locationData)),
  //           taskName: (provider) => provider.HYBRID_ADD_EVENT,
  //           showLoader: false,
  //           showDialog: false,
  //           onSuccess: (provider) {
  //             showMyDialog(fromAtSign, locationData: locationData);
  //           });
  //     }
  //     return;
  //   }
  // }

}
