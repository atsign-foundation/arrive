// ignore_for_file: prefer_final_fields, missing_return

import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/services/home_event_service.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/service/home_screen_service.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/show_location.dart';
import 'package:at_location_flutter/utils/constants/constants.dart'
    as LocationPackageConstants;
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/dialog_box/delete_dialog_confirmation.dart';
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

enum FilterScreenType { Event, Location }
enum EventFilters { Sent, Received, None }
enum LocationFilters { Pending, Sent, Received, None }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  PanelController pc = PanelController();
  LocationProvider locationProvider = LocationProvider();
  LatLng myLatLng, previousLatLng;
  String currentAtSign;
  bool contactsLoaded, moveMap;
  Key _mapKey; // so that map doesnt refresh, when we dont want it to
  MapController mapController = MapController();
  TabController _controller;
  int eventsRenderedWithFilter = 0,
      locationsRenderedWithFilter =
          0; // count used to show no data found after applying filter

  EventFilters _eventFilter = EventFilters.None;
  LocationFilters _locationFilter = LocationFilters.None;

  Function setFilterIconState,
      setFloatingActionState; // to re-render this when tab bar's index change

  @override
  void initState() {
    super.initState();
    _controller =
        _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _mapKey = UniqueKey();
    contactsLoaded = false;
    initializePlugins();
    _getLocationStatus();
    // deleteAllPreviousKeys();
    // cleanKeychain();

    _controller.addListener(() {
      if (mounted) {
        if (setFilterIconState != null) {
          try {
            setFilterIconState(
                () {}); // to re-render this when tab bar's index change
          } catch (e) {
            print('Error in setFilterIconState $e');
          }
        }

        if (setFloatingActionState != null) {
          try {
            setFloatingActionState(
                () {}); // to re-render this when tab bar's index change
          } catch (e) {
            print('Error in setFloatingActionState $e');
          }
        }
      }
    });

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

      _positionStream = Geolocator.getPositionStream(
              locationSettings: LocationSettings(distanceFilter: 2))
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
      floatingActionButton: StatefulBuilder(
        builder: (_context, _setFloatingActionState) {
          setFloatingActionState =
              _setFloatingActionState; // to re-render this when tab bar's index change
          return isFilterApplied()
              ? InkWell(
                  onTap: () {
                    removeFilter();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4.toHeight),
                    child: Image.asset(
                      AllImages().FILTER_ALT_OFF,
                      height: 25.toFont,
                      color: AllColors().ORANGE,
                    ),
                  ),
                )
              : SizedBox();
        },
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
                          panelBuilder: (scrollController) => collapsedContent(
                              false,
                              scrollController,
                              emptyWidget(TextStrings
                                  .somethingWentWrongPleaseTryAgain)));
                    },
                    successBuilder: (provider) {
                      return SlidingUpPanel(
                        controller: pc,
                        minHeight: 267.toHeight,
                        maxHeight: 530.toHeight,
                        panelBuilder: (scrollController) {
                          print('builder called uppanel');
                          if ((provider.animateToIndex != -1) && (mounted)) {
                            // setFilterIconState will help to avoid position changing when tabbar is not built
                            _controller.animateTo(provider.animateToIndex);
                          }

                          if (provider.allEventNotifications.isNotEmpty ||
                              provider.allLocationNotifications.isNotEmpty) {
                            return collapsedContent(
                                false,
                                scrollController,
                                renderEventsAndLocation(
                                    provider.allEventNotifications,
                                    provider.allLocationNotifications,
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
                    SizeConfig().screenHeight * 0.9, onSheetCLosed: () {
                  _controller.animateTo(0);
                });
              }),
          Tasks(
              task: TextStrings.requestLocation,
              icon: Icons.sync,
              angle: (-3.14 / 2),
              onTap: () async {
                bottomSheet(context, RequestLocationSheet(), 500.toHeight,
                    onSheetCLosed: () {
                  _controller.animateTo(1);
                });
              }),
          Tasks(
              task: TextStrings.shareLocation,
              icon: Icons.person_add,
              onTap: () {
                bottomSheet(context, ShareLocationSheet(), 600.toHeight,
                    onSheetCLosed: () {
                  _controller.animateTo(1);
                });
              })
        ],
      ),
    );
  }

  Widget renderEventsAndLocation(
      List<EventAndLocationHybrid> eventNotifications,
      List<EventAndLocationHybrid> locationNotifications,
      ScrollController scrollController) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                child: TabBar(
                  key: Key('Tabbar'),
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 3.toHeight,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: AllColors().DARK_GREY,
                  controller: _controller,
                  tabs: [
                    Tab(
                      child: Text(
                        'Events',
                        style: TextStyle(fontSize: 16.toFont, letterSpacing: 1),
                      ),
                    ),
                    Tab(
                      child: Text('Locations',
                          style:
                              TextStyle(fontSize: 16.toFont, letterSpacing: 1)),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _openFilterDialog(_controller.index == 0
                    ? FilterScreenType.Event
                    : FilterScreenType.Location);
              },
              child: StatefulBuilder(
                builder: (_context, _setFilterIconState) {
                  setFilterIconState =
                      _setFilterIconState; // to re-render this when tab bar's index change

                  return Icon(Icons.filter_alt,
                      size: 25.toFont,
                      color: isFilterApplied()
                          ? AllColors().ORANGE
                          : Colors.black);
                },
              ),
            )
          ],
        ),
        Expanded(
            child: TabBarView(
          controller: _controller,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: renderEvents(eventNotifications, scrollController),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: renderLocations(locationNotifications, scrollController),
            )
          ],
        )),
      ],
    );
  }

  Widget renderEvents(List<EventAndLocationHybrid> eventNotifications,
      ScrollController scrollController) {
    if (eventNotifications.isNotEmpty) {
      var _list = getListView(
          eventNotifications, scrollController, FilterScreenType.Event);

      /// after rendering events, we will have [eventsRenderedWithFilter] count
      if ((_eventFilter != EventFilters.None) &&
          (eventsRenderedWithFilter == 0)) {
        return emptyWidget('No ${_eventFilter.name} Event data found');
      }

      return _list;
    } else {
      return emptyWidget('No Data Found!!');
    }
  }

  Widget renderLocations(List<EventAndLocationHybrid> locationNotifications,
      ScrollController scrollController) {
    if (locationNotifications.isNotEmpty) {
      var _list = getListView(
          locationNotifications, scrollController, FilterScreenType.Location);

      /// after rendering locations, we will have [locationsRenderedWithFilter] count

      if ((_locationFilter != LocationFilters.None) &&
          (locationsRenderedWithFilter == 0)) {
        return emptyWidget('No ${_locationFilter.name} Location data found');
      }

      return _list;
    } else {
      return emptyWidget('No Data Found!!');
    }
  }

  /// We will filter data while rendering it, using [shouldCurrentHybridBeRendered]
  /// and use [eventsRenderedWithFilter]/[locationsRenderedWithFilter] to keep count of elements rendered
  Widget getListView(
      List<EventAndLocationHybrid> allHybridNotifications,
      ScrollController slidingScrollController,
      FilterScreenType filterScreenType) {
    if (filterScreenType == FilterScreenType.Event) {
      eventsRenderedWithFilter = 0;
    } else {
      locationsRenderedWithFilter = 0;
    }

    try {
      return ListView(
        children: allHybridNotifications.map((hybridElement) {
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.15,
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Delete',
                color: AllColors().RED,
                icon: Icons.delete,
                onTap: () {
                  deleteDialogConfirmation(hybridElement);
                },
              ),
            ],
            child: shouldCurrentHybridBeRendered(hybridElement)
                ? Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (hybridElement.type ==
                              NotificationModelType.EventModel) {
                            HomeEventService().onEventModelTap(
                                hybridElement
                                    .eventKeyModel.eventNotificationModel,
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
                              ? hybridElement
                                  .eventKeyModel.eventNotificationModel.key
                              : hybridElement.locationKeyModel
                                  .locationNotificationModel.key),
                          atsignCreator: hybridElement.type ==
                                  NotificationModelType.EventModel
                              ? hybridElement.eventKeyModel
                                  .eventNotificationModel.atsignCreator
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
                          number: hybridElement.type ==
                                  NotificationModelType.EventModel
                              ? hybridElement.eventKeyModel
                                  .eventNotificationModel.group.members.length
                              : null,
                          title: hybridElement.type ==
                                  NotificationModelType.EventModel
                              ? 'Event - ' +
                                  hybridElement.eventKeyModel
                                      .eventNotificationModel.title
                              : getTitle(hybridElement
                                  .locationKeyModel.locationNotificationModel),
                          subTitle: hybridElement.type ==
                                  NotificationModelType.EventModel
                              ? HomeEventService().getSubTitle(hybridElement
                                  .eventKeyModel.eventNotificationModel)
                              : getSubTitle(hybridElement
                                  .locationKeyModel.locationNotificationModel),
                          semiTitle: hybridElement
                                      .type ==
                                  NotificationModelType.EventModel
                              ? HomeEventService().getSemiTitle(
                                  hybridElement
                                      .eventKeyModel.eventNotificationModel,
                                  hybridElement.eventKeyModel.haveResponded)
                              : getSemiTitle(
                                  hybridElement.locationKeyModel
                                      .locationNotificationModel,
                                  hybridElement.locationKeyModel.haveResponded),
                          showRetry: hybridElement.type ==
                                  NotificationModelType.EventModel
                              ? HomeEventService().calculateShowRetry(
                                  hybridElement.eventKeyModel)
                              : calculateShowRetry(
                                  hybridElement.locationKeyModel),
                          onRetryTapped: () {
                            if (hybridElement.type ==
                                NotificationModelType.EventModel) {
                              HomeEventService().onEventModelTap(
                                  hybridElement
                                      .eventKeyModel.eventNotificationModel,
                                  false);
                            } else {
                              HomeScreenService().onLocationModelTap(
                                  hybridElement.locationKeyModel
                                      .locationNotificationModel,
                                  false);
                            }
                          },
                        ),
                      ),
                      Divider()
                    ],
                  )
                : SizedBox(),
          );
        }).toList(),
      );
    } catch (e) {
      print('${TextStrings.errorInGetListView} $e');
      return emptyWidget(
          '${TextStrings.somethingWentWrongPleaseTryAgain} ${e.toString()}');
    }
  }

  bool shouldCurrentHybridBeRendered(
      EventAndLocationHybrid eventAndLocationHybrid) {
    if (eventAndLocationHybrid.type == NotificationModelType.EventModel) {
      var _shouldCurrentEventBeRendered = shouldCurrentEventBeRendered(
          eventAndLocationHybrid.eventKeyModel.eventNotificationModel);
      if (_shouldCurrentEventBeRendered) {
        eventsRenderedWithFilter++;
      }
      return _shouldCurrentEventBeRendered;
    }

    var _shouldCurrentLocationBeRendered = shouldCurrentLocationBeRendered(
        eventAndLocationHybrid.locationKeyModel.locationNotificationModel);
    if (_shouldCurrentLocationBeRendered) {
      locationsRenderedWithFilter++;
    }
    return _shouldCurrentLocationBeRendered;
  }

  bool shouldCurrentEventBeRendered(
      EventNotificationModel eventNotificationModel) {
    switch (_eventFilter) {
      case EventFilters.None:
        return true;

      case EventFilters.Sent:
        return compareAtSign(eventNotificationModel.atsignCreator,
            AtClientManager.getInstance().atClient.getCurrentAtSign());

      case EventFilters.Received:
        return !compareAtSign(eventNotificationModel.atsignCreator,
            AtClientManager.getInstance().atClient.getCurrentAtSign());
    }
  }

  bool shouldCurrentLocationBeRendered(
      LocationNotificationModel locationNotificationModel) {
    switch (_locationFilter) {
      case LocationFilters.None:
        return true;

      case LocationFilters.Pending:
        {
          if (locationNotificationModel.key.contains(
              LocationPackageConstants.MixedConstants.SHARE_LOCATION)) {
            return false;
          } else {
            if ((locationNotificationModel.isAccepted == false) &&
                (locationNotificationModel.isExited == false)) {
              return true;
            }
          }

          return false;
        }
      case LocationFilters.Sent:
        return locationNotificationModel.key.contains(
                LocationPackageConstants.MixedConstants.SHARE_LOCATION)
            ? compareAtSign(locationNotificationModel.atsignCreator,
                AtClientManager.getInstance().atClient.getCurrentAtSign())
            : compareAtSign(locationNotificationModel.receiver,
                AtClientManager.getInstance().atClient.getCurrentAtSign());
      case LocationFilters.Received:
        return locationNotificationModel.key.contains(
                LocationPackageConstants.MixedConstants.SHARE_LOCATION)
            ? compareAtSign(locationNotificationModel.receiver,
                AtClientManager.getInstance().atClient.getCurrentAtSign())
            : compareAtSign(locationNotificationModel.atsignCreator,
                AtClientManager.getInstance().atClient.getCurrentAtSign());
    }
  }

  void removeFilter() {
    if (_controller.index == 0) {
      _eventFilter = EventFilters.None;
    } else {
      _locationFilter = LocationFilters.None;
    }

    setState(() {});
  }

  bool isFilterApplied() {
    if (_controller.index == 0) {
      return _eventFilter != EventFilters.None;
    }

    return _locationFilter != LocationFilters.None;
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

  Widget collapsedContent(
      bool isExpanded, ScrollController slidingScrollController, dynamic T,
      {Key key}) {
    return Container(
        key: key,
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

  Future<void> _openFilterDialog(FilterScreenType _filterScreenType) {
    return showDialog<void>(
      context: NavService.navKey.currentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (_context, _setDialogState) {
          return AlertDialog(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Filter ${_filterScreenType.name}s',
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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var _filterValue
                        in ((_filterScreenType == FilterScreenType.Event)
                            ? EventFilters.values
                            : LocationFilters.values))
                      CheckboxListTile(
                        onChanged: (value) {
                          if (_filterScreenType == FilterScreenType.Event) {
                            _eventFilter = _filterValue;
                          } else {
                            _locationFilter = _filterValue;
                          }

                          _setDialogState(() {});
                        },
                        value: ((_filterScreenType == FilterScreenType.Event)
                            ? (_eventFilter == _filterValue)
                            : (_locationFilter == _filterValue)),
                        checkColor: Colors.white,
                        title: Text(_filterValue.name),
                      ),
                    Divider(thickness: 0.8),
                    Row(children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Provider.of<LocationProvider>(context, listen: false)
                              .animateToIndex = -1; // reset animateToIndex
                          setState(() {});
                        },
                        child: Text('Filter',
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
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)))
                    ])
                  ],
                ),
              ));
        });
      },
    );
  }
}
