import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/services/home_event_service.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/service/home_screen_service.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/show_location.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/models/event_and_location.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/floating_icon.dart';
import 'package:atsign_location_app/common_components/provider_handler.dart';
import 'package:atsign_location_app/common_components/tasks.dart';
import 'package:atsign_location_app/screens/request_location/request_location_sheet.dart';
import 'package:atsign_location_app/screens/share_location/share_location_sheet.dart';
import 'package:atsign_location_app/screens/sidebar/sidebar.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  LatLng myLatLng, previousLatLng;
  String currentAtSign;
  bool contactsLoaded, moveMap;
  Key _mapKey; // so that map doesnt refresh, when we dont want it to
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _mapKey = UniqueKey();
    contactsLoaded = false;
    initializePlugins();
    _getLocationStatus();
    // deleteAllPreviousKeys();
    // cleanKeychain();

    locationProvider = context.read<LocationProvider>();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var atClientManager = AtClientManager.getInstance();
      Provider.of<LocationProvider>(context, listen: false).init(
          atClientManager,
          atClientManager.atClient.getCurrentAtSign(),
          NavService.navKey);
    });
  }

  void initializePlugins() async {
    currentAtSign = AtClientManager.getInstance().atClient.getCurrentAtSign();
    // ignore: await_only_futures
    await initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    setState(() {
      contactsLoaded = true;
    });

    initializeGroupService(rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  void _getLocationStatus() async {
    await _getMyLocation();

    Geolocator.getServiceStatusStream().listen((event) {
      _mapKey = UniqueKey();
      if (event == ServiceStatus.disabled) {
        setState(() {
          myLatLng = null;
        });
      } else if (event == ServiceStatus.enabled) {
        _getMyLocation();
      }
    });
  }

  StreamSubscription<Position> _positionStream;

  Future<void> _getMyLocation() async {
    var newMyLatLng = await getMyLocation();
    if (newMyLatLng != null) {
      setState(() {
        myLatLng = newMyLatLng;
      });
    }

    var permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse))) {
      if (_positionStream != null) {
        await _positionStream.cancel();
      }

      _positionStream = Geolocator.getPositionStream(distanceFilter: 2)
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

  void shouldMoveMap() {
    if (myLatLng != null) {
      if (moveMap == null) {
        moveMap = true;
      } else {
        moveMap = false;
      }
    }

    previousLatLng = myLatLng;
  }

  void zoomOutFn() {
    if (mapController != null) {
      mapController.move(myLatLng, 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    shouldMoveMap();

    return Scaffold(
      endDrawer: Container(
        width: 250.toWidth,
        child: SideBar(),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            (myLatLng != null)
                ? showLocation(
                    _mapKey,
                    mapController,
                    location: myLatLng,
                    moveMap: moveMap ?? false,
                  )
                : showLocation(
                    _mapKey,
                    mapController,
                    moveMap: moveMap ?? false,
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
            myLatLng != null
                ? Positioned(
                    top: 100,
                    right: 0,
                    child: FloatingIcon(
                        icon: Icons.zoom_out_map, onPressed: zoomOutFn),
                  )
                : SizedBox(),
            contactsLoaded
                ? ProviderHandler<LocationProvider>(
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
                          panelBuilder: (scrollController) => collapsedContent(
                              false,
                              scrollController,
                              emptyWidget(TextStrings.somethingWentWrongPleaseTryAgain)));
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
                                emptyWidget(TextStrings.noDataFound));
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
        ),
      ),
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
              task: TextStrings.createEvent,
              icon: Icons.event,
              onTap: () {
                bottomSheet(
                    context,
                    CreateEvent(
                      AtClientManager.getInstance(),
                    ),
                    SizeConfig().screenHeight * 0.9,
                    onSheetCLosed: () {});
              }),
          Tasks(
              task: TextStrings.requestLocation,
              icon: Icons.sync,
              angle: (-3.14 / 2),
              onTap: () async {
                bottomSheet(context, RequestLocationSheet(), 500.toHeight);
              }),
          Tasks(
              task: TextStrings.shareLocation,
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
              Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.15,
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: TextStrings.delete,
                    color: AllColors().RED,
                    icon: Icons.delete,
                    onTap: () {
                      _deleteDialogConfirmation(hybridElement);
                    },
                  ),
                ],
                child: InkWell(
                  onTap: () {
                    if (hybridElement.type ==
                        NotificationModelType.EventModel) {
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
                    key: Key(hybridElement.type ==
                            NotificationModelType.EventModel
                        ? hybridElement.eventKeyModel.eventNotificationModel.key
                        : hybridElement
                            .locationKeyModel.locationNotificationModel.key),
                    atsignCreator:
                        hybridElement.type == NotificationModelType.EventModel
                            ? hybridElement.eventKeyModel.eventNotificationModel
                                .atsignCreator
                            : (hybridElement
                                        .locationKeyModel
                                        .locationNotificationModel
                                        .atsignCreator ==
                                    AtClientManager.getInstance()
                                        .atClient
                                        .getCurrentAtSign()
                                ? hybridElement.locationKeyModel
                                    .locationNotificationModel.receiver
                                : hybridElement.locationKeyModel
                                    .locationNotificationModel.atsignCreator),
                    number:
                        hybridElement.type == NotificationModelType.EventModel
                            ? hybridElement.eventKeyModel.eventNotificationModel
                                .group.members.length
                            : null,
                    title:
                        hybridElement.type == NotificationModelType.EventModel
                            ? TextStrings.event +
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
                    showRetry: hybridElement.type ==
                            NotificationModelType.EventModel
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
              ),
              Divider()
            ],
          );
        }).toList(),
      );
    } catch (e) {
      print(TextStrings.errorInGetListView +'$e');
      return emptyWidget(TextStrings.somethingWentWrongPleaseTryAgain +'${e.toString()}');
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

  Future<void> _deleteDialogConfirmation(
      EventAndLocationHybrid hybridElement) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (_context, _setDialogState) {
          var _dialogLoading = false;

          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 20),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TextStrings.areYouSureYouWantToDelete+'${eventAndLocationHybridDetails(hybridElement)}?',
                    style: CustomTextStyles().grey16,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  _dialogLoading
                      ? CircularProgressIndicator()
                      : CustomButton(
                          onTap: () async {
                            _setDialogState(() {
                              _dialogLoading = true;
                            });

                            if (hybridElement.type ==
                                NotificationModelType.EventModel) {
                              await EventKeyStreamService().deleteData(
                                  hybridElement
                                      .eventKeyModel.eventNotificationModel);
                            } else {
                              await KeyStreamService().deleteData(hybridElement
                                  .locationKeyModel.locationNotificationModel);
                            }

                            _setDialogState(() {
                              _dialogLoading = false;
                            });
                            Navigator.of(context).pop();
                          },
                          bgColor: Theme.of(context).primaryColor,
                          width: 164.toWidth,
                          height: 48.toHeight,
                          child: Text(
                            TextStrings.yes,
                            style: TextStyle(
                                fontSize: 15.toFont,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          ),
                        ),
                  SizedBox(height: 5),
                  _dialogLoading
                      ? SizedBox()
                      : CustomButton(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          bgColor: Theme.of(context).scaffoldBackgroundColor,
                          width: 140.toWidth,
                          height: 36.toHeight,
                          child: Text(
                            TextStrings.noCancelThis,
                            style: TextStyle(
                                fontSize: 14.toFont,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  String eventAndLocationHybridDetails(EventAndLocationHybrid hybridElement) {
    if (hybridElement.type == NotificationModelType.EventModel) {
      return hybridElement.eventKeyModel.eventNotificationModel.title;
    }

    var _type = hybridElement.locationKeyModel.locationNotificationModel.key
            .contains('sharelocation')
        ? 'share location'
        : 'request location';

    String _mode;

    if (hybridElement.locationKeyModel.locationNotificationModel.key
        .contains('sharelocation')) {
      if (hybridElement
              .locationKeyModel.locationNotificationModel.atsignCreator ==
          AtClientManager.getInstance().atClient.getCurrentAtSign()) {
        _mode =
            'sent to ${hybridElement.locationKeyModel.locationNotificationModel.receiver}';
      } else {
        _mode =
            'received from ${hybridElement.locationKeyModel.locationNotificationModel.atsignCreator}';
      }
    } else {
      if (hybridElement
              .locationKeyModel.locationNotificationModel.atsignCreator !=
          AtClientManager.getInstance().atClient.getCurrentAtSign()) {
        _mode =
            'sent to ${hybridElement.locationKeyModel.locationNotificationModel.atsignCreator}';
      } else {
        _mode =
            'received from ${hybridElement.locationKeyModel.locationNotificationModel.receiver}';
      }
    }

    return '$_type $_mode';
  }
}
