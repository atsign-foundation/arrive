import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/screens/create_event.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/utils/text_styles.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/at_location_flutter.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/my_location.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/my_location.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/floating_icon.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/common_components/provider_handler.dart';
import 'package:atsign_location_app/common_components/tasks.dart';

import 'package:atsign_location_app/screens/request_location/request_location_sheet.dart';
import 'package:atsign_location_app/screens/share_location/share_location_sheet.dart';
import 'package:atsign_location_app/screens/sidebar/sidebar.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/services/location_notification_listener.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PanelController pc = PanelController();
  EventProvider eventProvider = new EventProvider();
  HybridProvider hybridProvider = new HybridProvider();
  LatLng myLatLng;
  String currentAtSign;

  @override
  void initState() {
    super.initState();
    initializeContacts();
    getMyLocation();
    LocationNotificationListener()
        .init(BackendService.getInstance().atClientServiceInstance.atClient);
    eventProvider = context.read<EventProvider>();
    // eventProvider
    //     .init(BackendService.getInstance().atClientServiceInstance.atClient);

    hybridProvider = context.read<HybridProvider>();
    // hybridProvider
    //     .init(BackendService.getInstance().atClientServiceInstance.atClient);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<EventProvider>(context, listen: false)
          .init(BackendService.getInstance().atClientServiceInstance.atClient);
      Provider.of<ShareLocationProvider>(context, listen: false)
          .init(BackendService.getInstance().atClientServiceInstance.atClient);
      Provider.of<RequestLocationProvider>(context, listen: false)
          .init(BackendService.getInstance().atClientServiceInstance.atClient);
      Provider.of<HybridProvider>(context, listen: false)
          .init(BackendService.getInstance().atClientServiceInstance.atClient);
    });
  }

  initializeContacts() async {
    currentAtSign = await BackendService.getInstance().getAtSign();
    initializeContactsService(
        BackendService.getInstance().atClientServiceInstance.atClient,
        currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  getMyLocation() async {
    LatLng newMyLatLng = await MyLocation().myLocation();
    if ((newMyLatLng != null) || (newMyLatLng != LatLng(0, 0)))
      setState(() {
        myLatLng = newMyLatLng;
      });
  }

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
                  ? ShowLocation(UniqueKey(), location: myLatLng)
                  : ShowLocation(
                      UniqueKey(),
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
              ProviderHandler<HybridProvider>(
                functionName: HybridProvider().HYBRID_GET_ALL_EVENTS,
                showError: true,
                load: (provider) => provider.getAllHybridEvents(),
                loaderBuilder: (provider) {
                  return Container(
                    child: SlidingUpPanel(
                        controller: pc,
                        minHeight: 267.toHeight,
                        maxHeight: 530.toHeight,
                        panelBuilder: (scrollController) => collapsedContent(
                            false,
                            scrollController,
                            Center(
                              child: CircularProgressIndicator(),
                            )
                            // panel: Text(''),
                            )),
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
                          emptyWidget('Something went wrong!!')));
                },
                successBuilder: (provider) {
                  return SlidingUpPanel(
                    controller: pc,
                    minHeight: 267.toHeight,
                    maxHeight: 530.toHeight,
                    panelBuilder: (scrollController) {
                      if (provider.allHybridNotifications.length > 0)
                        return collapsedContent(
                            false,
                            scrollController,
                            getListView(provider.allHybridNotifications,
                                provider, scrollController));
                      else
                        return collapsedContent(false, scrollController,
                            emptyWidget('No Data Found!!'));
                    },
                  );
                },
              ),
            ],
          )),
    );
  }

  Widget collapsedContent(
      bool isExpanded, ScrollController slidingScrollController, dynamic T) {
    if (pc.isPanelAnimating) {
      print('animating');
    }
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
      height: 77.toHeight,
      width: 356.toWidth,
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
                List<HybridNotificationModel> allEvents = [];

                hybridProvider.allHybridNotifications.forEach((event) {
                  if (event.notificationType == NotificationType.Event) {
                    allEvents.add(event);
                  }
                });
                bottomSheet(
                    context,
                    CreateEvent(
                        BackendService.getInstance()
                            .atClientServiceInstance
                            .atClient,
                        onEventSaved: (EventNotificationModel event) {
                      providerCallback<HybridProvider>(
                          NavService.navKey.currentContext,
                          task: (provider) => provider.addNewEvent(
                              BackendService.getInstance().convertEventToHybrid(
                                  NotificationType.Event,
                                  eventNotificationModel: event)),
                          taskName: (provider) => provider.HYBRID_ADD_EVENT,
                          showLoader: false,
                          onSuccess: (provider) {
                            provider.findAtSignsToShareLocationWith();
                            provider.initialiseLacationSharing();
                          });
                    }, createdEvents: allEvents),
                    SizeConfig().screenHeight * 0.9,
                    onSheetCLosed: () {});
              }),
          Tasks(
              task: 'Request Location',
              icon: Icons.refresh,
              onTap: () async {
                bottomSheet(context, RequestLocationSheet(),
                    SizeConfig().screenHeight * 0.5);

                // SendLocationNotification().manualLocationSend(39, -121);
              }),
          Tasks(
              task: 'Share Location',
              icon: Icons.person_add,
              onTap: () {
                // eventProvider.updateEventAccordingToAcknowledgedData();
                bottomSheet(context, ShareLocationSheet(),
                    SizeConfig().screenHeight * 0.6);
              })
        ],
      ),
    );
  }

  getListView(List<HybridNotificationModel> allHybridNotifications,
      EventProvider provider, ScrollController slidingScrollController) {
    return ListView(
      children: allHybridNotifications.map((hybridElement) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                if (hybridElement.notificationType == NotificationType.Event)
                  HomeEventService().onEventModelTap(
                      hybridElement.eventNotificationModel, provider);
                else
                  HomeEventService().onLocationModelTap(
                      hybridElement.locationNotificationModel);
              },
              child: DisplayTile(
                atsignCreator:
                    hybridElement.notificationType == NotificationType.Event
                        ? hybridElement.eventNotificationModel.atsignCreator
                        : hybridElement.locationNotificationModel.atsignCreator,
                title: getTitle(hybridElement),
                subTitle: getSubTitle(hybridElement),
                semiTitle: getSemiTitle(hybridElement),
              ),
            ),
            Divider()
          ],
        );
      }).toList(),
    );
    // return ListView.separated(
    //     controller: slidingScrollController,

    //     // physics: isExpanded
    //     //     ? AlwaysScrollableScrollPhysics()
    //     //     : NeverScrollableScrollPhysics(),
    //     itemCount: allHybridNotifications.length,
    //     shrinkWrap: true,
    //     separatorBuilder: (BuildContext context, int index) {
    //       return Divider();
    //     },
    //     itemBuilder: (BuildContext context, int index) {
    //       if (allHybridNotifications[index].notificationType ==
    //               NotificationType.Event &&
    //           allHybridNotifications[index].eventNotificationModel != null) {
    //         return InkWell(
    //           onTap: () {
    //             HomeEventService().onEventModelTap(
    //                 allHybridNotifications[index].eventNotificationModel,
    //                 provider);
    //           },
    //           child: DisplayTile(
    //             atsignCreator: allHybridNotifications[index]
    //                 .eventNotificationModel
    //                 .atsignCreator,
    //             title: getTitle(allHybridNotifications[index]),
    //             subTitle: getSubTitle(allHybridNotifications[index]),
    //             semiTitle: getSemiTitle(allHybridNotifications[index]),
    //           ),
    //         );
    //       } else if (allHybridNotifications[index].notificationType ==
    //               NotificationType.Location &&
    //           allHybridNotifications[index].locationNotificationModel != null) {
    //         return InkWell(
    //           onTap: () {
    //             HomeEventService().onLocationModelTap(
    //                 allHybridNotifications[index].locationNotificationModel);
    //           },
    //           child: DisplayTile(
    //             atsignCreator: allHybridNotifications[index]
    //                 .locationNotificationModel
    //                 .atsignCreator,
    //             title: getTitle(allHybridNotifications[index]),
    //             subTitle: getSubTitle(allHybridNotifications[index]),
    //             semiTitle: getSemiTitle(allHybridNotifications[index]),
    //           ),
    //         );
    //       }
    //     });
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
