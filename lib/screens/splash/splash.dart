import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/triple_dot_loading.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
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
              Provider.of<LocationProvider>(context, listen: false).resetData();

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
                                              'Stay connected!',
                                              textScaleFactor: 1,
                                              style: CustomTextStyles()
                                                  .blackPlayfairDisplay38,
                                            ),
                                            SizedBox(height: 5.toHeight),
                                            Text(
                                              'Wherever',
                                              textScaleFactor: 1,
                                              style: CustomTextStyles()
                                                  .blackPlayfairDisplay38,
                                            ),
                                            SizedBox(
                                              height: 5.toHeight,
                                            ),
                                            Text(
                                              'you go.',
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
                                            Onboarding(
                                                context: context,
                                                atClientPreference:
                                                    BackendService.getInstance()
                                                        .atClientPreference,
                                                domain:
                                                    MixedConstants.ROOT_DOMAIN,
                                                appColor: Color.fromARGB(
                                                    255, 240, 94, 62),
                                                onboard: onOnboardCompletes,
                                                rootEnvironment:
                                                    RootEnvironment.Production,
                                                onError: (error) {
                                                  print(
                                                      'error in onboard plugin:$error');
                                                  setState(() {
                                                    authenticating = false;
                                                  });
                                                },
                                                appAPIKey: MixedConstants
                                                    .ONBOARD_API_KEY);
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
                                                        'Authenticating',
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
                                                  'Explore',
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
                                  'Logging in',
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
