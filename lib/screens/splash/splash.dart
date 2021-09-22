import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/triple_dot_loading.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:at_location_flutter/utils/constants/constants.dart'
    as location_package_constants;

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool onboardSuccess = false;
  bool sharingStatus = false;
  BackendService backendService;
  Completer c = Completer();
  bool authenticating = false;
  bool isOnboarded = false;

  clearKeyChain() async {
    var _list = await KeyChainManager.getInstance().getAtSignListFromKeychain();
    for (var _atsign in _list) {
      await KeyChainManager.getInstance().deleteAtSignFromKeychain(_atsign);
    }
  }

  @override
  void initState() {
    // clearKeyChain();

    super.initState();
    BackendService.getInstance().getAtClientPreference().then(
        (value) => BackendService.getInstance().atClientPreference = value);
    _initBackendService();
  }

  String state;
  void _initBackendService() async {
    try {
      await checkLocationPermission();
      setMapKey();

      backendService = BackendService.getInstance();
      if (BackendService.getInstance().atClientPreference != null) {
        Onboarding(
            context: context,
            atClientPreference: BackendService.getInstance().atClientPreference,
            domain: MixedConstants.ROOT_DOMAIN,
            appColor: Color.fromARGB(255, 240, 94, 62),
            rootEnvironment: RootEnvironment.Production,
            onboard: (value, atsign) async {
              print('_initBackendService onboarded: $value , atsign:$atsign');
              BackendService.getInstance().atClientServiceMap = value;
              // await BackendService.getInstance().onboard();
              // BackendService.getInstance().atClientInstance =
              //     value[atsign].atClient;
              BackendService.getInstance().atClientServiceInstance =
                  value[atsign];

              AtClientManager.getInstance().syncService.sync();
              // ignore: unawaited_futures
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
            onError: (error) {
              print('_initBackendService error in onboarding: $error');
            },
            appAPIKey: MixedConstants.ONBOARD_API_KEY);
      } else {
        setState(() {
          authenticating = false;
        });
      }

      // ignore: missing_return
      SystemChannels.lifecycle.setMessageHandler((msg) {
        print('set message handler');
        state = msg;
        debugPrint('SystemChannels> $msg');
        backendService.app_lifecycle_state = msg;
        if (backendService.monitorConnection != null &&
            backendService.monitorConnection.isInValid()) {
          // backendService.startMonitor();
        }
      });
    } catch (e) {
      print('Error in _initBackendService $e');

      if (mounted) {
        setState(() {
          authenticating = false;
        });
      }
    }
  }

  // ignore: always_declare_return_types
  checkLocationPermission() async {
    try {
      /// So that we have the permission status beforehand & later we dont get
      /// PlatformException(PermissionHandler.PermissionManager) => Multiple Permissions exception
      await Geolocator.requestPermission();
    } catch (e) {
      print('Error in checkLocationPermission $e');
    }
  }

  void setMapKey() {
    location_package_constants.MixedConstants.setMapKey(MixedConstants.MAP_KEY);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        body: isOnboarded
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  Image.asset(
                    'assets/images/splash_bg.png',
                    fit: BoxFit.fill,
                    height: SizeConfig().screenHeight,
                    width: SizeConfig().screenWidth,
                  ),
                  Positioned(
                    top: 330.toHeight,
                    left: 16.toWidth,
                    child: Text(
                      'Stay connected!',
                      textScaleFactor: 1,
                      style: CustomTextStyles().blackPlayfairDisplay38,
                    ),
                  ),
                  Positioned(
                    top: 381.toHeight,
                    left: 15.toWidth,
                    child: Text(
                      'Wherever',
                      textScaleFactor: 1,
                      style: CustomTextStyles().blackPlayfairDisplay38,
                    ),
                  ),
                  Positioned(
                    top: 428.toHeight,
                    left: 15.toWidth,
                    child: Text(
                      'you go.',
                      textScaleFactor: 1,
                      style: CustomTextStyles().blackPlayfairDisplay38,
                    ),
                  ),
                  Positioned(
                    bottom: 32.toHeight,
                    left: 16.toWidth,
                    child: Text(
                      ' The @ Company Copyright 2021',
                      style: CustomTextStyles().darkGrey13,
                    ),
                  ),
                  Positioned(
                    bottom: 130.toHeight,
                    right: 36.toWidth,
                    child: Opacity(
                      opacity: authenticating ? 0.5 : 1,
                      child: CustomButton(
                          height: 40,
                          width: 150,
                          radius: 100.toHeight,
                          onTap: () async {
                            if (authenticating) return;

                            Onboarding(
                                context: context,
                                atClientPreference: BackendService.getInstance()
                                    .atClientPreference,
                                domain: MixedConstants.ROOT_DOMAIN,
                                appColor: Color.fromARGB(255, 240, 94, 62),
                                onboard: onOnboardCompletes,
                                rootEnvironment: RootEnvironment.Production,
                                onError: (error) {
                                  print('error in onboard plugin:$error');
                                  setState(() {
                                    authenticating = false;
                                  });
                                },
                                appAPIKey: MixedConstants.ONBOARD_API_KEY);
                          },
                          bgColor: AllColors().Black,
                          child: authenticating
                              ? Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Authenticating',
                                        textScaleFactor: 1,
                                        style: CustomTextStyles().white15,
                                      ),
                                      TypingIndicator(
                                        showIndicator: true,
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  'Explore',
                                  textScaleFactor: 1,
                                  style: CustomTextStyles().white15,
                                )),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ignore: always_declare_return_types
  onOnboardCompletes(Map<String, AtClientService> value, String atsign) async {
    setState(() {
      authenticating = true;
      isOnboarded = true;
    });

    BackendService.getInstance().atClientServiceMap = value;

    // ignore: unawaited_futures
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }
}
