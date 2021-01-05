import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:atsign_location_app/models/event_notification.dart';
import 'package:atsign_location_app/models/location_notification.dart';
import 'package:atsign_location_app/models/message_notification.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

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
        namespace: 'arrive');
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
    monitorConnection =
        await atClientInstance.startMonitor(privateKey, fnCallBack);
    print("Monitor started");
    return true;
  }

  fnCallBack(var response) async {
    response = response.replaceFirst('notification:', '');
    var responseJson = jsonDecode(response);
    var value = responseJson['value'];
    var notificationKey = responseJson['key'];
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        .catchError(
            (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));
    if (atKey.toString().contains(AllText().MSG_NOTIFY)) {
      MessageNotificationModel msg =
          MessageNotificationModel.fromJson(jsonDecode(decryptedMessage));
    } else if (atKey.toString().contains(AllText().LOCATION_NOTIFY)) {
      LocationNotificationModel msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
    } else if (atKey.toString().contains(AllText().EVENT_NOTIFY)) {
      print(jsonDecode(decryptedMessage));
      EventNotificationModel msg =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('recieved notification ==>$msg');
    }
  }
}
