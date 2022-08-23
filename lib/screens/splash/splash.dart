import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/triple_dot_loading.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:at_location_flutter/utils/constants/constants.dart'
    as location_package_constants;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool onboardSuccess = false;
  bool sharingStatus = false;
  late BackendService backendService;
  Completer c = Completer();
  bool authenticating = false;
  bool isOnboarded = false;

  @override
  void initState() {
    super.initState();
    _initBackendService();
  }

  String? state;
  void _initBackendService() async {
    try {
      BackendService.getInstance().atClientPreference =
          await BackendService.getInstance().getAtClientPreference();

      await checkLocationPermission();
      setMapKey();

      backendService = BackendService.getInstance();
      if (BackendService.getInstance().atClientPreference != null) {
        if (Platform.isAndroid || Platform.isIOS) {
          await _checkForPermissionStatus();
        }
        final result = await AtOnboarding.onboard(
          context: NavService.navKey.currentContext!,
          atsign: '',
          config: AtOnboardingConfig(
            domain: MixedConstants.ROOT_DOMAIN,
            atClientPreference:
                BackendService.getInstance().atClientPreference!,
            rootEnvironment: RootEnvironment.Production,
            appAPIKey: MixedConstants.ONBOARD_API_KEY,
          ),
        );
        switch (result.status) {
          case AtOnboardingResultStatus.success:
            // TODO: Handle this case.
            final atsign = result.atsign;
            final value = result;
            await AtClientManager.getInstance().setCurrentAtSign(
                atsign!,
                MixedConstants.appNamespace,
                BackendService.getInstance().atClientPreference!);
            BackendService.getInstance().syncService =
                AtClientManager.getInstance().syncService;

            Provider.of<LocationProvider>(context, listen: false).resetData();

            print('_initBackendService onboarded: $value , atsign:$atsign');
            await KeychainUtil.makeAtSignPrimary(atsign);

            BackendService.getInstance().syncWithSecondary();

            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
            break;
          case AtOnboardingResultStatus.error:
            BackendService.getInstance().showErrorSnackBar(result.errorCode);
            print(
                '_initBackendService error in onboarding: ${result.errorCode}');
            break;
          case AtOnboardingResultStatus.cancel:
            break;
        }
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
            backendService.monitorConnection!.isInValid()) {
          // backendService.startMonitor();
        }
      } as Future<String?> Function(String?)?);
    } catch (e) {
      print('Error in _initBackendService $e');

      if (mounted) {
        setState(() {
          authenticating = false;
        });
      }
    }
  }

  Future<void> _checkForPermissionStatus() async {
    final existingCameraStatus = await Permission.camera.status;
    if (existingCameraStatus != PermissionStatus.granted) {
      await Permission.camera.request();
    }
    final existingStorageStatus = await Permission.storage.status;
    if (existingStorageStatus != PermissionStatus.granted) {
      await Permission.storage.request();
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
        body: isOnboarded
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(children: [
                Container(
                    width: SizeConfig().screenWidth,
                    height: SizeConfig().screenHeight,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          AllImages().SPLASH_BG,
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 8, child: SizedBox()),
                          Expanded(
                            flex: 8,
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 36.toWidth,
                                  vertical: 10.toHeight,
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              TextStrings.stayConnected,
                                              textScaleFactor: 1,
                                              style: CustomTextStyles()
                                                  .blackPlayfairDisplay38,
                                            ),
                                            SizedBox(height: 5.toHeight),
                                            Text(
                                              TextStrings.whereEver,
                                              textScaleFactor: 1,
                                              style: CustomTextStyles()
                                                  .blackPlayfairDisplay38,
                                            ),
                                            SizedBox(
                                              height: 5.toHeight,
                                            ),
                                            Text(
                                              TextStrings.youGo,
                                              textScaleFactor: 1,
                                              style: CustomTextStyles()
                                                  .blackPlayfairDisplay38,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ])),
                          ),
                          Expanded(flex: 1, child: SizedBox()),
                          Expanded(
                              flex: 4,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.toWidth),
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
                                            final result =
                                                await AtOnboarding.onboard(
                                              context: context,
                                              config: AtOnboardingConfig(
                                                  atClientPreference:
                                                      BackendService
                                                              .getInstance()
                                                          .atClientPreference!,
                                                  rootEnvironment:
                                                      RootEnvironment
                                                          .Production,
                                                  domain: MixedConstants
                                                      .ROOT_DOMAIN,
                                                  appAPIKey: MixedConstants
                                                      .ONBOARD_API_KEY),
                                            );
                                            switch (result.status) {
                                              case AtOnboardingResultStatus
                                                  .success:
                                                // TODO: Handle this case.
                                                onOnboardCompletes;
                                                break;
                                              case AtOnboardingResultStatus
                                                  .error:
                                                // TODO: Handle this case.
                                                print(
                                                    'error in onboard plugin:${result.errorCode}');
                                                BackendService.getInstance()
                                                    .showErrorSnackBar(
                                                        result.errorCode);
                                                setState(() {
                                                  authenticating = false;
                                                });
                                                break;
                                              case AtOnboardingResultStatus
                                                  .cancel:
                                                // TODO: Handle this case.
                                                break;
                                            }
                                            ;
                                          },
                                          bgColor: AllColors().Black,
                                          child: authenticating
                                              ? Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        TextStrings
                                                            .authenticating,
                                                        textScaleFactor: 1,
                                                        style:
                                                            CustomTextStyles()
                                                                .white15,
                                                      ),
                                                      TypingIndicator(
                                                        showIndicator: true,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Text(
                                                  TextStrings.explore,
                                                  textScaleFactor: 1,
                                                  style: CustomTextStyles()
                                                      .white15,
                                                )),
                                      SizedBox(height: 15.toHeight),
                                      InkWell(
                                        onTap: () {
                                          _showResetDialog();
                                        },
                                        child: Text(
                                          TextStrings.resetButton,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          Center(
                            child: Text(
                              TextStrings.appName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              TextStrings.copyRight,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'HelveticaNeu',
                                color: Colors.grey.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                authenticating
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red)),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  TextStrings.loggingIn,
                                  style: CustomTextStyles().white15,
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : SizedBox()
              ]));
  }

  _showResetDialog() async {
    var isSelectAtsign = false;
    bool? isSelectAll = false;
    var atsignsList = await KeychainUtil.getAtsignList();
    if (atsignsList == null) {
      atsignsList = [];
    }
    Map atsignMap = {};
    for (var atsign in atsignsList) {
      atsignMap[atsign] = false;
    }
    await showDialog(
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
                content: atsignsList!.isEmpty
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
                              TextStrings.close,
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
                              title: Text(TextStrings.selectAll,
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
                                child: Text(TextStrings.remove,
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
                                  child: Text(TextStrings.cancel,
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
  onOnboardCompletes(
      Map<String?, AtClientService> value, String? atsign) async {
    await AtClientManager.getInstance().setCurrentAtSign(
        atsign!,
        MixedConstants.appNamespace,
        BackendService.getInstance().atClientPreference!);
    BackendService.getInstance().syncService =
        AtClientManager.getInstance().syncService;

    setState(() {
      authenticating = true;
      isOnboarded = true;
    });

    Provider.of<LocationProvider>(context, listen: false).resetData();

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
