import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_location_flutter/common_components/contacts_initial.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:provider/provider.dart';

class AtSignBottomSheet extends StatefulWidget {
  final List<String>? atSignList;
  AtSignBottomSheet({Key? key, this.atSignList}) : super(key: key);

  @override
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  Map<String, AtContact> contactDetails = {};
  @override
  void initState() {
    super.initState();
    getAtContactDetails();
  }

  // ignore: always_declare_return_types
  getAtContactDetails() async {
    contactDetails = {};

    await Future.forEach(widget.atSignList!, (dynamic element) async {
      var _currentAtsign =
          AtClientManager.getInstance().atClient.getCurrentAtSign()!;
      var contactDetail = await getAtSignDetails(_currentAtsign);
      contactDetails['$_currentAtsign'] = contactDetail;
    });
    setState(() {});
  }

  BackendService backendService = BackendService.getInstance();
  late var atClientPrefernce;
  @override
  Widget build(BuildContext context) {
    backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value);
    return BottomSheet(
      onClosing: () {},
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Container(
          height: 120.toHeight,
          width: SizeConfig().screenWidth,
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                  child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.atSignList!.length,
                itemBuilder: (context, index) {
                  Uint8List? image;

                  if (contactDetails['${widget.atSignList![index]}'] != null) {
                    if (contactDetails['${widget.atSignList![index]}']!.tags !=
                            null &&
                        contactDetails['${widget.atSignList![index]}']!
                                .tags!['image'] !=
                            null) {
                      List<int> intList =
                          contactDetails['${widget.atSignList![index]}']!
                              .tags!['image']
                              .cast<int>();
                      image = Uint8List.fromList(intList);
                    }
                  }

                  return GestureDetector(
                    onTap: () async {
                      final result = await AtOnboarding.onboard(
                        context: context,
                        atsign: widget.atSignList![index],
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
                            atClientPrefernce,
                          );
                          BackendService.getInstance().syncService =
                              AtClientManager.getInstance().syncService;
                          Provider.of<LocationProvider>(context, listen: false)
                              .resetData();
                          // backendService.atClientServiceMap = value;
                          await KeychainUtil.makeAtSignPrimary(atsign);
                          // String? atSign = atsign;
                          // atClientServiceInstance = atClientServiceMap[atsign];
                          BackendService.getInstance().atClientServiceInstance =
                              backendService.atClientServiceMap[atsign];
                          BackendService.getInstance().syncWithSecondary();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // TODO: Add LocationProvider init here if any issue
                          });
                          SetupRoutes.pushAndRemoveAll(context, Routes.HOME);
                          break;
                        case AtOnboardingResultStatus.error:
                          // TODO: Handle this case.
                          BackendService.getInstance()
                              .showErrorSnackBar(result.errorCode);
                          print('Onboarding throws ${result.errorCode} error');
                          break;
                        case AtOnboardingResultStatus.cancel:
                          // TODO: Handle this case.
                          break;
                      }
                      // Onboarding(
                      //     atsign: widget.atSignList![index],
                      //     context: context,
                      //     atClientPreference: atClientPrefernce,
                      //     domain: MixedConstants.ROOT_DOMAIN,
                      //     appColor: Color.fromARGB(255, 240, 94, 62),
                      //     rootEnvironment: RootEnvironment.Production,
                      //     onboard: (value, atsign) async {
                      //       await AtClientManager.getInstance()
                      //           .setCurrentAtSign(
                      //               atsign!,
                      //               MixedConstants.appNamespace,
                      //               atClientPrefernce);
                      //       BackendService.getInstance().syncService =
                      //           AtClientManager.getInstance().syncService;

                      //       Provider.of<LocationProvider>(context,
                      //               listen: false)
                      //           .resetData();
                      //       backendService.atClientServiceMap = value;
                      //       await KeychainUtil.makeAtSignPrimary(atsign);

                      //       // var atSign = backendService
                      //       //     .atClientServiceMap[atsign]
                      //       //     .atClient
                      //       //     .currentAtSign;

                      //       // await backendService.atClientServiceMap[atsign]
                      //       //     .makeAtSignPrimary(atSign);
                      //       // BackendService.getInstance().atClientInstance =
                      //       //     backendService
                      //       //         .atClientServiceMap[atsign].atClient;
                      //       BackendService.getInstance()
                      //               .atClientServiceInstance =
                      //           backendService.atClientServiceMap[atsign];

                      //       BackendService.getInstance().syncWithSecondary();

                      //       WidgetsBinding.instance.addPostFrameCallback((_) {
                      //         // TODO: Add LocationProvider init here if any issue
                      //       });

                      //       SetupRoutes.pushAndRemoveAll(context, Routes.HOME);
                      //     },
                      //     onError: (error) {
                      //       BackendService.getInstance()
                      //           .showErrorSnackBar(error);
                      //       print('Onboarding throws $error error');
                      //     },
                      //     appAPIKey: MixedConstants.ONBOARD_API_KEY);

                      setState(() {});
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Column(
                        children: [
                          (image != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(30.toFont)),
                                  child: Image.memory(
                                    image,
                                    width: 50.toFont,
                                    height: 50.toFont,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : ContactInitial(
                                  initials: widget.atSignList![index],
                                ),
                          Text(
                            widget.atSignList![index],
                            style: TextStyle(fontSize: 15.toFont),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () async {
                  final result = await AtOnboarding.onboard(
                    context: context,
                    atsign: '',
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
                        atClientPrefernce,
                      );
                      BackendService.getInstance().syncService =
                          AtClientManager.getInstance().syncService;
                      Provider.of<LocationProvider>(context, listen: false)
                          .resetData();
                      // backendService.atClientServiceMap = value;
                      final value = backendService.atClientServiceMap;
                      await KeychainUtil.makeAtSignPrimary(atsign);
                      await BackendService.getInstance().onboard();
                      BackendService.getInstance().syncWithSecondary();
                      //ignore: unawaited_futures
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                      break;
                    case AtOnboardingResultStatus.error:
                      // TODO: Handle this case.
                      BackendService.getInstance()
                          .showErrorSnackBar(result.errorCode);
                      print('Onboarding throws ${result.errorCode} error');
                      break;
                    case AtOnboardingResultStatus.cancel:
                      // TODO: Handle this case.
                      break;
                  }
                },
                //   Onboarding(
                //       atsign: '',
                //       context: context,
                //       atClientPreference: atClientPrefernce,
                //       domain: MixedConstants.ROOT_DOMAIN,
                //       appColor: Color.fromARGB(255, 240, 94, 62),
                //       rootEnvironment: RootEnvironment.Production,
                //       onboard: (value, atsign) async {
                //         await AtClientManager.getInstance().setCurrentAtSign(
                //             atsign!,
                //             MixedConstants.appNamespace,
                //             atClientPrefernce);
                //         BackendService.getInstance().syncService =
                //             AtClientManager.getInstance().syncService;

                //         Provider.of<LocationProvider>(context, listen: false)
                //             .resetData();
                //         backendService.atClientServiceMap = value;
                //         await KeychainUtil.makeAtSignPrimary(atsign);

                //         // var atSign = backendService
                //         //     .atClientServiceMap[atsign].atClient.currentAtSign;
                //         // await backendService.atClientServiceMap[atsign]
                //         //     .makeAtSignPrimary(atSign);

                //         await BackendService.getInstance().onboard();
                //         BackendService.getInstance().syncWithSecondary();

                //         // ignore: unawaited_futures
                //         Navigator.pushReplacement(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => HomeScreen(),
                //           ),
                //         );
                //       },
                //       onError: (error) {
                //         BackendService.getInstance().showErrorSnackBar(error);
                //         print('Onboarding throws $error error');
                //       },
                //       appAPIKey: MixedConstants.ONBOARD_API_KEY);
                //   setState(() {});
                // },
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  height: 40,
                  width: 40,
                  child: Icon(
                    Icons.add_circle_outline_outlined,
                    color: Colors.orange,
                    size: 25.toFont,
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
