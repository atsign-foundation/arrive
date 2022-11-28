import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

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
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:showcaseview/showcaseview.dart';

class AtSignBottomSheet extends StatefulWidget {
  final List<String>? atSignList;
  AtSignBottomSheet({Key? key, this.atSignList}) : super(key: key);

  @override
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  BuildContext? myContext;
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

  Future<void> _checkForPermissionStatus() async {
    final existingCameraStatus = await Permission.camera.status;
    if (existingCameraStatus != PermissionStatus.granted) {
      await Permission.camera.request();
    }
  }

  BackendService backendService = BackendService.getInstance();
  bool isLoading = false;
  var atClientPrefernce;
  @override
  Widget build(BuildContext context) {
    backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value);
    var r = Random();

    return ShowCaseWidget(
      builder: Builder(builder: (context) {
        myContext = context;
        return Stack(
          children: [
            Positioned(
              child: BottomSheet(
                onClosing: () {},
                backgroundColor: Colors.transparent,
                builder: (context) => ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: Container(
                    height: 155.toHeight < 155 ? 155 : 150.toHeight,
                    width: SizeConfig().screenWidth,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Showcase(
                              key: _one,
                              description:
                                  'You can pair multiple atSigns with this app.',
                              shapeBorder: CircleBorder(),
                              disableAnimation: true,
                              radius: BorderRadius.all(Radius.circular(40)),
                              showArrow: false,
                              overlayPadding: EdgeInsets.all(5),
                              blurValue: 2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Text(TextStrings.sidebarSwitchOut,
                                    style:
                                        CustomTextStyles().blackBold(size: 15)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ShowCaseWidget.of(myContext!)
                                    .startShowCase([_one, _two]);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(50)),
                                margin: EdgeInsets.all(0),
                                height: 20,
                                width: 20,
                                child: Icon(
                                  Icons.question_mark,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 100.toHeight < 105 ? 105 : 100.toHeight,
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
                                    onTap: isLoading
                                        ? () {}
                                        : () async {
                                            if (Platform.isAndroid || Platform.isIOS) {
                                              await _checkForPermissionStatus();
                                            }
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
                                                await KeychainUtil.makeAtSignPrimary(atsign);

                                                BackendService.getInstance().atClientServiceInstance =
                                                    backendService.atClientServiceMap[atsign];
                                                BackendService.getInstance().syncWithSecondary();
                                                WidgetsBinding.instance.addPostFrameCallback((_) {});
                                                SetupRoutes.pushAndRemoveAll(context, Routes.HOME);
                                                break;
                                              case AtOnboardingResultStatus.error:
                                                BackendService.getInstance()
                                                    .showErrorSnackBar(result.errorCode);
                                                print('Onboarding throws ${result.errorCode} error');
                                                break;
                                              case AtOnboardingResultStatus.cancel:
                                                break;
                                            }

                                            setState(() {});
                                          },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10, top: 20),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 40.toFont,
                                            width: 40.toFont,
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255,
                                                  r.nextInt(255),
                                                  r.nextInt(255),
                                                  r.nextInt(255)),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      50.toWidth),
                                            ),
                                            child: Center(
                                              child: image != null
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
                                                      initials: widget
                                                          .atSignList![index]),
                                            ),
                                          ),
                                          Text(widget.atSignList![index],
                                              style: TextStyle(
                                                fontSize: 15.toFont,
                                                fontWeight: FontWeight.normal,
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )),
                              const SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (Platform.isAndroid || Platform.isIOS) {
                                    await _checkForPermissionStatus();
                                  }
                                  final result = await AtOnboarding.onboard(
                                    isSwitchingAtsign: true,
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
                                      BackendService.getInstance()
                                          .showErrorSnackBar(result.errorCode);
                                      print('Onboarding throws ${result.errorCode} error');
                                      break;
                                    case AtOnboardingResultStatus.cancel:
                                      break;
                                  }
                                },
                                child: Showcase(
                                  key: _two,
                                  description:
                                      'Use the + icon to either generate a new free atSign or pair an existing one. All paired atSigns will appear here, where you can switch between them.',
                                  shapeBorder: CircleBorder(),
                                  radius: BorderRadius.all(Radius.circular(40)),
                                  showArrow: false,
                                  disableAnimation: true,
                                  overlayPadding: EdgeInsets.all(5),
                                  blurValue: 2,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    height: 40,
                                    width: 40,
                                    child: Icon(
                                        Icons.add_circle_outline_outlined,
                                        color: Colors.orange,
                                        size: 25.toFont),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}