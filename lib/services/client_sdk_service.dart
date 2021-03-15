import 'dart:async';
import 'dart:io';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;

  AtClientPreference atClientPreference;
  String _atsign;
  String get currentAtsign => _atsign;
  set setAtsign(String atSign) {
    _atsign = atSign;
  }

  Future<bool> onboard({String atsign}) async {
    atClientServiceInstance = AtClientService();
    Directory downloadDirectory;
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }

    final appSupportDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appSupportDirectory.path;
    atClientPreference = AtClientPreference();

    atClientPreference.isLocalStoreRequired = true;
    atClientPreference.commitLogPath = path;
    atClientPreference.syncStrategy = SyncStrategy.IMMEDIATE;
    atClientPreference.rootDomain = MixedConstants.ROOT_DOMAIN;
    atClientPreference.hiveStoragePath = path;
    atClientPreference.downloadPath = downloadDirectory.path;
    var result = await atClientServiceInstance
        .onboard(atClientPreference: atClientPreference, atsign: atsign)
        .catchError((e) => print('Error in Onboarding: $e'));
    return result;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return await atClientServiceInstance.getAtSign();
  }
}
