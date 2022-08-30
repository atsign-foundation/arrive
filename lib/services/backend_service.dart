import 'dart:async';
import 'dart:io';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:atsign_location_app/common_components/error_dialog.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:at_client/src/service/sync_service.dart';
import 'package:at_client/src/service/sync_service_impl.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService? atClientServiceInstance;
  String? currentAtSign;
  Timer? periodicHistoryRefresh;

  // AtClientImpl atClientInstance;
  String? _atsign;
  // ignore: non_constant_identifier_names
  String? app_lifecycle_state;
  AtClientPreference? atClientPreference;
  bool autoAcceptFiles = false;
  String? get currentAtsign => _atsign;
  OutboundConnection? monitorConnection;
  Directory? downloadDirectory;
  late SyncService syncService;
  Map<String?, AtClientService> atClientServiceMap = {};
  bool isSyncedDataFetched = false;

  ///Resets [atsigns] list from device storage.
  Future<void> resetAtsigns(List atsigns) async {
    for (String atsign in atsigns) {
      await KeychainUtil.resetAtSignFromKeychain(atsign);
      atClientServiceMap.remove(atsign);
    }
  }

  Future<bool> onboard({String? atsign}) async {
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

    atClientPreference!.isLocalStoreRequired = true;
    atClientPreference!.commitLogPath = path;
    atClientPreference!.rootDomain = MixedConstants.ROOT_DOMAIN;
    atClientPreference!.hiveStoragePath = path;
    atClientPreference!.downloadPath = downloadDirectory!.path;
    atClientPreference!.outboundConnectionTimeout = MixedConstants.TIME_OUT;
    atClientPreference!.namespace = MixedConstants.appNamespace;
    atClientPreference!.syncRegex = MixedConstants.syncRegex;
    var result = await atClientServiceInstance!.onboard(
      atClientPreference: atClientPreference!,
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
      ..rootDomain = MixedConstants.ROOT_DOMAIN
      ..namespace = MixedConstants.appNamespace
      ..syncRegex = MixedConstants.syncRegex
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  ///Fetches atsign from device keychain.
  Future<String?> getAtSign() async {
    await getAtClientPreference().then((value) {
      return atClientPreference = value;
    });

    atClientServiceInstance = AtClientService();

    return await KeychainUtil.getAtSign();
  }

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
  Future<List<String>?> getAtsignList() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    return atSignsList;
  }

  // ignore: always_declare_return_types
  deleteAtSignFromKeyChain(String atsign) async {
    var atSignList = await getAtsignList();

    await KeyChainManager.getInstance().deleteAtSignFromKeychain(atsign);

    if (atSignList != null) {
      atSignList.removeWhere((element) =>
          element == AtClientManager.getInstance().atClient.getCurrentAtSign());
    }

    late var atClientPrefernce;
    await getAtClientPreference().then((value) => atClientPrefernce = value);
    var tempAtsign;
    if (atSignList == null || atSignList.isEmpty) {
      tempAtsign = '';
    } else {
      tempAtsign = atSignList.first;
    }

    if (tempAtsign == '') {
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext!,
          Routes.SPLASH, (Route<dynamic> route) => false);
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        await _checkForPermissionStatus();
      }
      final result = await AtOnboarding.onboard(
        context: NavService.navKey.currentContext!,
        atsign: tempAtsign,
        config: AtOnboardingConfig(
            atClientPreference: atClientPrefernce,
            domain: MixedConstants.ROOT_DOMAIN,
            rootEnvironment: RootEnvironment.Production,
            appAPIKey: MixedConstants.ONBOARD_API_KEY),
      );
      switch (result.status) {
        case AtOnboardingResultStatus.success:
          final atsign = result.atsign;
          await AtClientManager.getInstance().setCurrentAtSign(
            atsign!,
            MixedConstants.appNamespace,
            BackendService.getInstance().atClientPreference!,
          );
          BackendService.getInstance().syncService;
          Provider.of<LocationProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .resetData();
          final value = OnboardingService.getInstance().atClientServiceMap;
          String? atSign = atsign;
          atClientServiceInstance = atClientServiceMap[atsign];
          await KeychainUtil.makeAtSignPrimary(atsign);
          BackendService.getInstance().syncWithSecondary();
          SetupRoutes.pushAndRemoveAll(
              NavService.navKey.currentContext!, Routes.HOME);
          break;
        case AtOnboardingResultStatus.error:
          BackendService.getInstance().showErrorSnackBar(result.errorCode);
          print('Onboarding throws ${result.errorCode} error');
          break;
        case AtOnboardingResultStatus.cancel:
          break;
      }
    }
  }

  Future<void> _checkForPermissionStatus() async {
    final existingCameraStatus = await Permission.camera.status;
    if (existingCameraStatus != PermissionStatus.granted) {
      await Permission.camera.request();
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
      Provider.of<LocationProvider>(NavService.navKey.currentContext!,
              listen: false)
          .init(
              AtClientManager.getInstance(),
              AtClientManager.getInstance().atClient.getCurrentAtSign(),
              NavService.navKey);
      isSyncedDataFetched = true;
    }
  }

  // ignore: always_declare_return_types
  resetDevice(List checkedAtsigns) async {
    Navigator.of(NavService.navKey.currentContext!).pop();
    await BackendService.getInstance()
        .resetAtsigns(checkedAtsigns)
        .then((value) async {
      print('reset done ');
    }).catchError((e) {
      print('error in reset: $e');
    });
  }

  onboardNextAtsign() async {
    var atSignList = await KeychainUtil.getAtsignList();
    var atClient = AtClientManager.getInstance().atClient;
    if (atSignList != null &&
        atSignList.isNotEmpty &&
        atClient.getCurrentAtSign() != atSignList.first) {
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext!,
          Routes.SPLASH, (Route<dynamic> route) => false);
    } else if (atSignList == null || atSignList.isEmpty) {
      await Navigator.pushNamedAndRemoveUntil(NavService.navKey.currentContext!,
          Routes.SPLASH, (Route<dynamic> route) => false);
    }
  }

  // ignore: always_declare_return_types
  showErrorSnackBar(dynamic msg) {
    try {
      ScaffoldMessenger.of(NavService.navKey.currentContext!)
          .showSnackBar(SnackBar(
        backgroundColor: AllColors().RED,
        content: Text(
          '${msg..toString()}',
          style: TextStyle(
              color: AllColors().WHITE,
              fontSize: 16,
              letterSpacing: 0.1,
              fontWeight: FontWeight.normal),
        ),
      ));
    } catch (e) {
      print('Error while showing error snackbar $e');
    }
  }
}
