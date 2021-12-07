import 'dart:async';
import 'dart:io';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atsign_location_app/common_components/error_dialog.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:at_client/src/service/sync_service.dart';
import 'package:at_client/src/service/sync_service_impl.dart';
import 'package:provider/provider.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  // AtClientImpl atClientInstance;
  String _atsign;
  // ignore: non_constant_identifier_names
  String app_lifecycle_state;
  AtClientPreference atClientPreference;
  bool autoAcceptFiles = false;
  String get currentAtsign => _atsign;
  OutboundConnection monitorConnection;
  Directory downloadDirectory;
  SyncService syncService;
  Map<String, AtClientService> atClientServiceMap = {};
  bool isSyncedDataFetched = false;

  ///Resets [atsigns] list from device storage.
  Future<void> resetAtsigns(List atsigns) async {
    for (String atsign in atsigns) {
      await KeychainUtil.resetAtSignFromKeychain(atsign);
      atClientServiceMap.remove(atsign);
    }
  }

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
    // atClientInstance = atClientServiceInstance.atClient;
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
  // Future<String> getAtSign() async {
  //   return atClientServiceInstance.atClient.currentAtSign;
  // }

  // // ///Fetches privatekey for [atsign] from device keychain.
  // Future<String> getPrivateKey(String atsign) async {
  //   return await atClientServiceInstance.getPrivateKey(atsign);
  // }

  // ///Fetches publickey for [atsign] from device keychain.
  // Future<String> getPublicKey(String atsign) async {
  //   return await atClientServiceInstance.getPublicKey(atsign);
  // }

  // Future<String> getAESKey(String atsign) async {
  //   return await atClientServiceInstance.getAESKey(atsign);
  // }

  // Future<Map<String, String>> getEncryptedKeys(String atsign) async {
  //   return await atClientServiceInstance.getEncryptedKeys(atsign);
  // }

  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();
  Future<List<String>> getAtsignList() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    return atSignsList;
  }

  // ignore: always_declare_return_types
  deleteAtSignFromKeyChain(String atsign) async {
    var atSignList = await getAtsignList();

    await KeyChainManager.getInstance().deleteAtSignFromKeychain(atsign);

    if (atSignList != null) {
      atSignList.removeWhere((element) =>
          element ==
          atClientServiceInstance.atClientManager.atClient.getCurrentAtSign());
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
          rootEnvironment: RootEnvironment.Production,
          onboard: (value, atsign) async {
            Provider.of<LocationProvider>(NavService.navKey.currentContext,
                    listen: false)
                .resetData();

            atClientServiceMap = value;

            var atSign = atsign;

            // await atClientServiceMap[atSign].makeAtSignPrimary(atSign);
            // atClientInstance = atClientServiceMap[atsign].atClient;
            atClientServiceInstance = atClientServiceMap[atsign];
            await KeychainUtil.makeAtSignPrimary(atsign);
            BackendService.getInstance().syncWithSecondary();

            SetupRoutes.pushAndRemoveAll(
                NavService.navKey.currentContext, Routes.HOME);
          },
          onError: (error) {
            print('Onboarding throws $error error');
          },
          appAPIKey: MixedConstants.ONBOARD_API_KEY);
    }
  }

  void syncWithSecondary() async {
    isSyncedDataFetched = false;
    syncService = AtClientManager.getInstance().syncService;
    syncService.sync(onDone: _onSuccessCallback);
    syncService.setOnDone(_onSuccessCallback);
  }

  void _onSuccessCallback(SyncResult syncStatus) async {
    print('syncStatus : $syncStatus, data changed : ${syncStatus.dataChange}');

    if (syncStatus.syncStatus == SyncStatus.failure) {
      // ErrorDialog()
      //     .show('Sync failed', context: NavService.navKey.currentContext);
    }

    if (syncStatus.dataChange && !isSyncedDataFetched) {
      Provider.of<LocationProvider>(NavService.navKey.currentContext,
              listen: false)
          .init(
              AtClientManager.getInstance(),
              AtClientManager.getInstance().atClient.getCurrentAtSign(),
              NavService.navKey);
      isSyncedDataFetched = true;
    }
  }
}
