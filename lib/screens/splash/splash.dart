import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_authentication_helper/atsign_authentication_helper.dart';
import 'package:atsign_contacts/utils/init_contacts_service.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
// import 'package:atsign_location_app/screens/scan_qr/scan_qr.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // NotificationService _notificationService;
  bool onboardSuccess = false;
  bool sharingStatus = false;
  BackendService backendService;
  String atSign, activeAtSign;
  // bool userAcceptance;
  final Permission _cameraPermission = Permission.camera;
  final Permission _storagePermission = Permission.storage;
  Completer c = Completer();
  bool authenticating = false;
  StreamSubscription _intentDataStreamSubscription;
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  // FilePickerProvider filePickerProvider;

  @override
  void initState() {
    super.initState();
    // _notificationService = NotificationService();

    _initBackendService();
    // _checkToOnboard();
    // acceptFiles();
    // _checkForPermissionStatus();
  }

  void _checkToOnboard() async {
    // onboard call to get the already setup atsigns
    await backendService.onboard().then((isChecked) async {
      if (!isChecked) {
        c.complete(true);
        print("onboard returned: $isChecked");
      } else {
        await backendService.startMonitor();
        onboardSuccess = true;
        // // if (FilePickerProvider().selectedFiles.isNotEmpty) {
        // //   BuildContext cd = NavService.navKey.currentContext;
        // //   await Navigator.pushReplacementNamed(cd, Routes.WELCOME_SCREEN);
        // }
        c.complete(true);
      }
    }).catchError((error) async {
      c.complete(true);
      print("Error in authenticating: $error");
    });
  }

  String state;
  void _initBackendService() async {
    backendService = BackendService.getInstance();
    backendService.atClientServiceInstance = new AtClientService();
    clientSdkService = ClientSdkService.getInstance();
    // clientSdkService.atClientServiceInstance = new AtClientService();
    var isOnBoard = await clientSdkService.onboard();
    if (isOnBoard != null && isOnBoard == true) {
      print('on board $isOnBoard');
      await BackendService.getInstance().onboard();
      await BackendService.getInstance().startMonitor();
      getAtSignAndInitializeContacts();
      SetupRoutes.push(context, Routes.HOME);
    }

    // _notificationService.setOnNotificationClick(onNotificationClick);
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('set message handler');
      state = msg;
      debugPrint('SystemChannels> $msg');
      backendService.app_lifecycle_state = msg;
      if (backendService.monitorConnection != null &&
          backendService.monitorConnection.isInValid()) {
        backendService.startMonitor();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              "assets/images/splash_bg.png",
              fit: BoxFit.fill,
              height: SizeConfig().screenHeight,
              width: SizeConfig().screenWidth,
            ),
            Positioned(
              top: 330.toHeight,
              left: 16.toWidth,
              child: Text(
                'Stay connected!',
                style: CustomTextStyles().blackPlayfairDisplay38,
              ),
            ),
            Positioned(
              top: 381.toHeight,
              left: 15.toWidth,
              child: Text(
                'Wherever',
                style: CustomTextStyles().blackPlayfairDisplay38,
              ),
            ),
            Positioned(
              top: 428.toHeight,
              left: 15.toWidth,
              child: Text(
                'you go.',
                style: CustomTextStyles().blackPlayfairDisplay38,
              ),
            ),
            Positioned(
              top: 511.toHeight,
              left: 16.toWidth,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur',
                style: CustomTextStyles().darkGrey15,
              ),
            ),
            Positioned(
              top: 530.toHeight,
              left: 16.toWidth,
              child: Text(
                'adipiscing elit.',
                style: CustomTextStyles().darkGrey15,
              ),
            ),
            Positioned(
              bottom: 32.toHeight,
              left: 16.toWidth,
              child: Text(
                ' The @ Company Copyright 2020',
                style: CustomTextStyles().darkGrey13,
              ),
            ),
            Positioned(
              bottom: 130.toHeight,
              right: 36.toWidth,
              child: CustomButton(
                  height: 40,
                  width: 120,
                  radius: 100.toHeight,
                  child: Text(
                    'Explore',
                    style: CustomTextStyles().white15,
                  ),
                  // onTap: () => cramAuthWithoutQR(),

                  // onTap: () => SetupRoutes.push(context, Routes.HOME),
                  onTap: () async {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanQrScreen(
                          atClientServiceInstance:
                              clientSdkService.atClientServiceInstance,
                          nextScreen: HomeScreen(),
                        ),
                      ),
                    );
                  },
                  bgColor: AllColors().Black),
            ),
          ],
        ),
      ),
    );
  }

  getAtSignAndInitializeContacts() async {
    String currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeContactsService(
        clientSdkService.atClientServiceInstance.atClient, currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }
}
