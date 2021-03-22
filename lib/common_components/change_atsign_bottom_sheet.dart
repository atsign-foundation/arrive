import 'dart:math';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:provider/provider.dart';

class AtSignBottomSheet extends StatefulWidget {
  final List<String> atSignList;
  AtSignBottomSheet({Key key, this.atSignList}) : super(key: key);

  @override
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  BackendService backendService = BackendService.getInstance();
  var atClientPrefernce;
  @override
  Widget build(BuildContext context) {
    backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value);
    Random r = Random();
    return BottomSheet(
      onClosing: () {},
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Container(
          height: 100,
          width: SizeConfig().screenWidth,
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                  child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.atSignList.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () async {
                    Onboarding(
                      atsign: widget.atSignList[index],
                      context: context,
                      atClientPreference: atClientPrefernce,
                      domain: MixedConstants.ROOT_DOMAIN,
                      appColor: Color.fromARGB(255, 240, 94, 62),
                      onboard: (value, atsign) async {
                        backendService.atClientServiceMap = value;

                        String atSign = backendService
                            .atClientServiceMap[atsign].atClient.currentAtSign;

                        await backendService.atClientServiceMap[atsign]
                            .makeAtSignPrimary(atSign);
                        BackendService.getInstance().atClientInstance =
                            backendService.atClientServiceMap[atsign].atClient;
                        BackendService.getInstance().atClientServiceInstance =
                            backendService.atClientServiceMap[atsign];

                        BackendService.getInstance().startMonitor();

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<EventProvider>(context, listen: false)
                              .init(BackendService.getInstance()
                                  .atClientServiceInstance
                                  .atClient);
                          Provider.of<ShareLocationProvider>(context,
                                  listen: false)
                              .init(BackendService.getInstance()
                                  .atClientServiceInstance
                                  .atClient);
                          Provider.of<RequestLocationProvider>(context,
                                  listen: false)
                              .init(BackendService.getInstance()
                                  .atClientServiceInstance
                                  .atClient);
                          Provider.of<HybridProvider>(context, listen: false)
                              .init(BackendService.getInstance()
                                  .atClientServiceInstance
                                  .atClient);

                          Provider.of<HybridProvider>(context, listen: false)
                              .init(backendService
                                  .atClientServiceMap[atsign].atClient);
                        });

                        SetupRoutes.pushAndRemoveAll(context, Routes.HOME);
                      },
                      onError: (error) {
                        print('Onboarding throws $error error');
                      },
                    );

                    setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: Column(
                      children: [
                        Container(
                          height: 40.toFont,
                          width: 40.toFont,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, r.nextInt(255),
                                r.nextInt(255), r.nextInt(255)),
                            borderRadius: BorderRadius.circular(50.toWidth),
                          ),
                          child: Center(
                            child: Text(
                              widget.atSignList[index]
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style:
                                  CustomTextStyles.whiteBold(size: (50 ~/ 3)),
                            ),
                          ),
                        ),
                        Text(widget.atSignList[index])
                      ],
                    ),
                  ),
                ),
              )),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  Onboarding(
                    atsign: "",
                    context: context,
                    atClientPreference: atClientPrefernce,
                    domain: MixedConstants.ROOT_DOMAIN,
                    appColor: Color.fromARGB(255, 240, 94, 62),
                    onboard: (value, atsign) async {
                      backendService.atClientServiceMap = value;

                      String atSign = backendService
                          .atClientServiceMap[atsign].atClient.currentAtSign;
                      await backendService.atClientServiceMap[atsign]
                          .makeAtSignPrimary(atSign);

                      await BackendService.getInstance().onboard();
                      BackendService.getInstance().startMonitor();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    onError: (error) {
                      print('Onboarding throws $error error');
                    },
                  );
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  height: 40,
                  width: 40,
                  child: Icon(
                    Icons.add_circle_outline_outlined,
                    color: Colors.orange,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
