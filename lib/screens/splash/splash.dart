import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/triple_dot_loading.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
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

  @override
  void initState() {
    super.initState();
    // BackendService.getInstance().getAtClientPreference().then(
    //     (value) => BackendService.getInstance().atClientPreference = value);
    _initBackendService();
  }

  String state;
  void _initBackendService() async {
    try {
      BackendService.getInstance().atClientPreference =
          await BackendService.getInstance().getAtClientPreference();

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
              await KeychainUtil.makeAtSignPrimary(atsign);
              // await BackendService.getInstance().onboard();
              // BackendService.getInstance().atClientInstance =
              //     value[atsign].atClient;
              BackendService.getInstance().atClientServiceInstance =
                  value[atsign];
              BackendService.getInstance().syncWithSecondary();

              // AtClientManager.getInstance().syncService.sync();
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
    return Scaffold(
      body: SafeArea(
        child: isOnboarded
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
                    bottom: 105.toHeight,
                    right: 36.toWidth,
                    child: Opacity(
                      opacity: authenticating ? 0.5 : 1,
                      child: Column(
                        children: [
                          CustomButton(
                              height: 40,
                              width: SizeConfig().screenWidth * 0.8,
                              radius: 100.toHeight,
                              onTap: () async {
                                if (authenticating) return;

                                Onboarding(
                                    context: context,
                                    atClientPreference:
                                        BackendService.getInstance()
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                          SizedBox(height: 10.toHeight),
                          InkWell(
                            onTap: () {
                              _showResetDialog();
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _showResetDialog() async {
    bool isSelectAtsign = false;
    bool isSelectAll = false;
    var atsignsList = await KeychainUtil.getAtsignList();
    if (atsignsList == null) {
      atsignsList = [];
    }
    Map atsignMap = {};
    for (String atsign in atsignsList) {
      atsignMap[atsign] = false;
    }
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, stateSet) {
            return AlertDialog(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(TextStrings.resetDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15)),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 0.8,
                    )
                  ],
                ),
                content: atsignsList.isEmpty
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(TextStrings.noAtsignToReset,
                            style: TextStyle(fontSize: 15)),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 15,
                                // color: AtTheme.themecolor,
                              ),
                            ),
                          ),
                        )
                      ])
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CheckboxListTile(
                              onChanged: (value) {
                                isSelectAll = value;
                                atsignMap
                                    .updateAll((key, value1) => value1 = value);
                                // atsignMap[atsign] = value;
                                stateSet(() {});
                              },
                              value: isSelectAll,
                              checkColor: Colors.white,
                              title: Text('Select All',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            for (var atsign in atsignsList)
                              CheckboxListTile(
                                onChanged: (value) {
                                  atsignMap[atsign] = value;
                                  stateSet(() {});
                                },
                                value: atsignMap[atsign],
                                checkColor: Colors.white,
                                title: Text('$atsign'),
                              ),
                            Divider(thickness: 0.8),
                            if (isSelectAtsign)
                              Text(TextStrings.resetErrorText,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(TextStrings.resetWarningText,
                                style: TextStyle(fontSize: 14)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(children: [
                              TextButton(
                                onPressed: () {
                                  var tempAtsignMap = {};
                                  tempAtsignMap.addAll(atsignMap);
                                  tempAtsignMap.removeWhere(
                                      (key, value) => value == false);
                                  if (tempAtsignMap.keys.toList().isEmpty) {
                                    isSelectAtsign = true;
                                    stateSet(() {});
                                  } else {
                                    isSelectAtsign = false;
                                    _resetDevice(tempAtsignMap.keys.toList());
                                  }
                                },
                                child: Text('Remove',
                                    style: TextStyle(
                                      color: AllColors().FONT_PRIMARY,
                                      fontSize: 15,
                                    )),
                              ),
                              Spacer(),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black)))
                            ])
                          ],
                        ),
                      ));
          });
        });
  }

  _resetDevice(List checkedAtsigns) async {
    Navigator.of(context).pop();
    await BackendService.getInstance()
        .resetAtsigns(checkedAtsigns)
        .then((value) async {
      print('reset done');
    }).catchError((e) {
      print('error in reset: $e');
    });
  }

  // ignore: always_declare_return_types
  onOnboardCompletes(Map<String, AtClientService> value, String atsign) async {
    setState(() {
      authenticating = true;
      isOnboarded = true;
    });

    BackendService.getInstance().atClientServiceMap = value;
    await KeychainUtil.makeAtSignPrimary(atsign);
    BackendService.getInstance().syncWithSecondary();

    // ignore: unawaited_futures
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }
}
