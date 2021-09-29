import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/services/home_event_service.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/service/home_screen_service.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_location_flutter/show_location.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:atsign_location_app/models/event_and_location.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/floating_icon.dart';
import 'package:atsign_location_app/common_components/provider_handler.dart';
import 'package:atsign_location_app/common_components/tasks.dart';
import 'package:atsign_location_app/screens/request_location/request_location_sheet.dart';
import 'package:atsign_location_app/screens/share_location/share_location_sheet.dart';
import 'package:atsign_location_app/screens/sidebar/sidebar.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PanelController pc = PanelController();
  LocationProvider locationProvider = LocationProvider();
  LatLng myLatLng;
  String currentAtSign;
  bool contactsLoaded;

  @override
  void initState() {
    super.initState();
    contactsLoaded = false;
    initializePlugins();
    _getMyLocation();
    // deleteAllPreviousKeys();
    // cleanKeychain();

    locationProvider = context.read<LocationProvider>();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var atClientManager =
          BackendService.getInstance().atClientServiceInstance.atClientManager;
      Provider.of<LocationProvider>(context, listen: false).init(
          atClientManager,
          atClientManager.atClient.getCurrentAtSign(),
          NavService.navKey);
    });
  }

  void initializePlugins() async {
    currentAtSign = BackendService.getInstance()
        .atClientServiceInstance
        .atClientManager
        .atClient
        .getCurrentAtSign();
    // ignore: await_only_futures
    await initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    setState(() {
      contactsLoaded = true;
    });

    initializeGroupService(rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  void _getMyLocation() async {
    var newMyLatLng = await getMyLocation();
    if (newMyLatLng != null) {
      setState(() {
        myLatLng = newMyLatLng;
      });
    }

    var permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse))) {
      Geolocator.getPositionStream(distanceFilter: 2)
          .listen((locationStream) async {
        if (mounted) {
          setState(() {
            myLatLng =
                LatLng(locationStream.latitude, locationStream.longitude);
          });
        }
      });
    }
  }

  // ignore: always_declare_return_types
  cleanKeychain() async {
    var _keyChainManager = KeyChainManager.getInstance();
    var _atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    _atSignsList?.forEach((element) {
      _keyChainManager.deleteAtSignFromKeychain(element);
    });
  }

  // void deleteAllPreviousKeys() async {
  // var atClient = BackendService.getInstance().atClientInstance;

  // var keys = [
  //   'locationnotify',
  //   'sharelocation',
  //   'sharelocationacknowledged',
  //   'requestlocation',
  //   'requestlocationacknowledged',
  //   'deleterequestacklocation',
  //   'createevent',
  //   'eventacknowledged',
  //   'updateeventlocation',
  // ];

  // for (var i = 0; i < keys.length; i++) {
  //   var response = await atClient.getKeys(
  //     regex: keys[i],
  //   );
  //   response.forEach((key) async {
  //     if (!'@$key'.contains('cached')) {
  //       // the keys i have created
  //       var atKey = getAtKey(key);
  //       var result = await atClient.delete(atKey,
  //           isDedicated: MixedConstants.isDedicated);

  //       if (result) {
  //         if (MixedConstants.isDedicated) {
  //           await SyncSecondary()
  //               .callSyncSecondary(SyncOperation.syncSecondary);
  //         }
  //       }

  //       print('$key is deleted ? $result');
  //     }
  //   });
  // }
  // }

  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          endDrawer: Container(
            width: 250.toWidth,
            child: SideBar(),
          ),
          body: Stack(
            children: [
              (myLatLng != null)
                  ? showLocation(
                      null,
                      mapController,
                      location: myLatLng,
                    )
                  : showLocation(
                      null,
                      mapController,
                    ),
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                  height: 55.toHeight,
                  child: FloatingIcon(
                      bgColor: Theme.of(context).primaryColor,
                      icon: Icons.table_rows,
                      iconColor: Theme.of(context).scaffoldBackgroundColor),
                ),
              ),
              Positioned(bottom: 264.toHeight, child: header()),
              contactsLoaded
                  ? ProviderHandler<LocationProvider>(
                      key: UniqueKey(),
                      functionName: locationProvider.GET_ALL_NOTIFICATIONS,
                      showError: false,
                      load: (provider) => {},
                      loaderBuilder: (provider) {
                        return Container(
                          child: SlidingUpPanel(
                              controller: pc,
                              minHeight: 267.toHeight,
                              maxHeight: 530.toHeight,
                              panelBuilder: (scrollController) =>
                                  collapsedContent(
                                      false,
                                      scrollController,
                                      Center(
                                        child: CircularProgressIndicator(),
                                      ))),
                        );
                      },
                      errorBuilder: (provider) {
                        return SlidingUpPanel(
                            controller: pc,
                            minHeight: 267.toHeight,
                            maxHeight: 530.toHeight,
                            panelBuilder: (scrollController) =>
                                collapsedContent(false, scrollController,
                                    emptyWidget('Something went wrong!!')));
                      },
                      successBuilder: (provider) {
                        return SlidingUpPanel(
                          controller: pc,
                          minHeight: 267.toHeight,
                          maxHeight: 530.toHeight,
                          panelBuilder: (scrollController) {
                            if (provider.allNotifications.isNotEmpty) {
                              return collapsedContent(
                                  false,
                                  scrollController,
                                  getListView(provider.allNotifications,
                                      scrollController));
                            } else {
                              return collapsedContent(false, scrollController,
                                  emptyWidget('No Data Found!!'));
                            }
                          },
                        );
                      },
                    )
                  : Container(
                      child: SlidingUpPanel(
                          controller: pc,
                          minHeight: 267.toHeight,
                          maxHeight: 530.toHeight,
                          panelBuilder: (scrollController) => collapsedContent(
                              false,
                              scrollController,
                              Center(
                                child: CircularProgressIndicator(),
                              ))),
                    ),
            ],
          )),
    );
  }

  Widget collapsedContent(
      bool isExpanded, ScrollController slidingScrollController, dynamic T) {
    return Container(
        height: !isExpanded ? 260.toHeight : 530.toHeight,
        padding: EdgeInsets.fromLTRB(15.toWidth, 7.toHeight, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AllColors().DARK_GREY,
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0),
            )
          ],
        ),
        child: T);
  }

  Widget header() {
    return Container(
      height: 85.toHeight,
      width: SizeConfig().screenWidth * 0.95,
      margin:
          EdgeInsets.symmetric(horizontal: 10.toWidth, vertical: 10.toHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AllColors().DARK_GREY,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Tasks(
              task: 'Create Event',
              icon: Icons.event,
              onTap: () {
                bottomSheet(
                    context,
                    CreateEvent(
                      BackendService.getInstance()
                          .atClientServiceInstance
                          .atClientManager,
                    ),
                    SizeConfig().screenHeight * 0.9,
                    onSheetCLosed: () {});
              }),
          Tasks(
              task: 'Request Location',
              icon: Icons.sync,
              angle: (-3.14 / 2),
              onTap: () async {
                bottomSheet(context, RequestLocationSheet(), 500.toHeight);
              }),
          Tasks(
              task: 'Share Location',
              icon: Icons.person_add,
              onTap: () {
                bottomSheet(context, ShareLocationSheet(), 600.toHeight);
              })
        ],
      ),
    );
  }

  Widget getListView(List<EventAndLocationHybrid> allHybridNotifications,
      ScrollController slidingScrollController) {
    try {
      return ListView(
        children: allHybridNotifications.map((hybridElement) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  if (hybridElement.type == NotificationModelType.EventModel) {
                    HomeEventService().onEventModelTap(
                        hybridElement.eventKeyModel.eventNotificationModel,
                        hybridElement.eventKeyModel.haveResponded);
                  } else {
                    HomeScreenService().onLocationModelTap(
                        hybridElement
                            .locationKeyModel.locationNotificationModel,
                        hybridElement.locationKeyModel.haveResponded);
                  }
                },
                child: DisplayTile(
                  atsignCreator:
                      hybridElement.type == NotificationModelType.EventModel
                          ? hybridElement.eventKeyModel.eventNotificationModel
                              .atsignCreator
                          : (hybridElement
                                      .locationKeyModel
                                      .locationNotificationModel
                                      .atsignCreator ==
                                  BackendService.getInstance()
                                      .atClientServiceInstance
                                      .atClientManager
                                      .atClient
                                      .getCurrentAtSign()
                              ? hybridElement.locationKeyModel
                                  .locationNotificationModel.receiver
                              : hybridElement.locationKeyModel
                                  .locationNotificationModel.atsignCreator),
                  number: hybridElement.type == NotificationModelType.EventModel
                      ? hybridElement.eventKeyModel.eventNotificationModel.group
                          .members.length
                      : null,
                  title: hybridElement.type == NotificationModelType.EventModel
                      ? 'Event - ' +
                          hybridElement
                              .eventKeyModel.eventNotificationModel.title
                      : getTitle(hybridElement
                          .locationKeyModel.locationNotificationModel),
                  subTitle: hybridElement.type ==
                          NotificationModelType.EventModel
                      ? HomeEventService().getSubTitle(
                          hybridElement.eventKeyModel.eventNotificationModel)
                      : getSubTitle(hybridElement
                          .locationKeyModel.locationNotificationModel),
                  semiTitle:
                      hybridElement.type == NotificationModelType.EventModel
                          ? HomeEventService().getSemiTitle(
                              hybridElement
                                  .eventKeyModel.eventNotificationModel,
                              hybridElement.eventKeyModel.haveResponded)
                          : getSemiTitle(
                              hybridElement
                                  .locationKeyModel.locationNotificationModel,
                              hybridElement.locationKeyModel.haveResponded),
                  showRetry:
                      hybridElement.type == NotificationModelType.EventModel
                          ? HomeEventService()
                              .calculateShowRetry(hybridElement.eventKeyModel)
                          : calculateShowRetry(hybridElement.locationKeyModel),
                  onRetryTapped: () {
                    if (hybridElement.type ==
                        NotificationModelType.EventModel) {
                      HomeEventService().onEventModelTap(
                          hybridElement.eventKeyModel.eventNotificationModel,
                          false);
                    } else {
                      HomeScreenService().onLocationModelTap(
                          hybridElement
                              .locationKeyModel.locationNotificationModel,
                          false);
                    }
                  },
                ),
              ),
              Divider()
            ],
          );
        }).toList(),
      );
    } catch (e) {
      print('Error in getListView $e');
      return emptyWidget('Something went wrong!! ${e.toString()}');
    }
  }

  Widget emptyWidget(String title) {
    return Column(
      children: [
        Image.asset(
          AllImages().EMPTY_GROUP,
          width: 181.toWidth,
          height: 181.toWidth,
          fit: BoxFit.cover,
        ),
        SizedBox(
          height: 15.toHeight,
        ),
        Text(title, style: CustomTextStyles().grey16),
        SizedBox(
          height: 5.toHeight,
        ),
      ],
    );
  }
}
