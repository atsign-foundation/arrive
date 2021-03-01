import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_authentication_helper/atsign_authentication_helper.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

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

  @override
  void initState() {
    super.initState();

    _initBackendService();
    // acceptFiles();
    // _checkForPermissionStatus();
  }

  String state;
  void _initBackendService() async {
    backendService = BackendService.getInstance();
    backendService.atClientServiceInstance = new AtClientService();
    backendService = BackendService.getInstance();
    // backendService.atClientServiceInstance = new AtClientService();
    setState(() {
      authenticating = true;
    });
    var isOnBoard = await backendService.onboard();

    if (isOnBoard != null && isOnBoard == true) {
      print('on board $isOnBoard');
      await BackendService.getInstance().onboard();
      await BackendService.getInstance().startMonitor();
      setState(() {
        authenticating = false;
      });
      SetupRoutes.push(context, Routes.HOME);
    }

    setState(() {
      authenticating = false;
    });

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
            // Positioned(
            //   top: 511.toHeight,
            //   left: 16.toWidth,
            //   child: Text(
            //     'Lorem ipsum dolor sit amet, consectetur',
            //     style: CustomTextStyles().darkGrey15,
            //   ),
            // ),
            // Positioned(
            //   top: 530.toHeight,
            //   left: 16.toWidth,
            //   child: Text(
            //     'adipiscing elit.',
            //     style: CustomTextStyles().darkGrey15,
            //   ),
            // ),
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
                  child: authenticating
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Text(
                          'Explore',
                          style: CustomTextStyles().white15,
                        ),
                  // onTap: () => cramAuthWithoutQR(),

                  // onTap: () => SetupRoutes.push(context, Routes.HOME),
                  onTap: () async {
                    if (authenticating) return;
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanQrScreen(
                          atClientServiceInstance:
                              backendService.atClientServiceInstance,
                          atClientPreference:
                              BackendService.getInstance().atClientPreference,
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
}
