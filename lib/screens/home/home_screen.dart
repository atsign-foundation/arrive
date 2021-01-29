import 'package:at_commons/at_commons.dart';
import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_events/screens/create_event.dart';
import 'package:atsign_location/atsign_location.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
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
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/services/location_notification_listener.dart';
import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:atsign_contacts/utils/init_contacts_service.dart';
import 'package:atsign_events/models/hybrid_notifiation_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PanelController pc = PanelController();
  EventProvider eventProvider = new EventProvider();
  HybridProvider hybridProvider = new HybridProvider();

  String currentAtSign;

  @override
  void initState() {
    super.initState();
    initializeContacts();
    LocationNotificationListener()
        .init(ClientSdkService.getInstance().atClientServiceInstance.atClient);
    eventProvider = context.read<EventProvider>();
    // eventProvider
    //     .init(ClientSdkService.getInstance().atClientServiceInstance.atClient);

    hybridProvider = context.read<HybridProvider>();
    // hybridProvider
    //     .init(ClientSdkService.getInstance().atClientServiceInstance.atClient);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<EventProvider>(context, listen: false).init(
          ClientSdkService.getInstance().atClientServiceInstance.atClient);
      Provider.of<ShareLocationProvider>(context, listen: false).init(
          ClientSdkService.getInstance().atClientServiceInstance.atClient);
      Provider.of<RequestLocationProvider>(context, listen: false).init(
          ClientSdkService.getInstance().atClientServiceInstance.atClient);
      Provider.of<HybridProvider>(context, listen: false).init(
          ClientSdkService.getInstance().atClientServiceInstance.atClient);
    });
  }

  initializeContacts() async {
    currentAtSign = await ClientSdkService.getInstance().getAtSign();
    initializeContactsService(
        ClientSdkService.getInstance().atClientServiceInstance.atClient,
        currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
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
              GestureDetector(
                child: AbsorbPointer(
                  absorbing: false,
                  child: ShowLocation(LatLng(20, 30)),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: FloatingIcon(
                    bgColor: Theme.of(context).primaryColor,
                    icon: Icons.table_rows,
                    iconColor: Theme.of(context).scaffoldBackgroundColor),
              ),
              Positioned(bottom: 264.toHeight, child: header()),
              SlidingUpPanel(
                controller: pc,
                minHeight: 267.toHeight,
                maxHeight: 530.toHeight,
                // collapsed: Text('sss'),
                panel: collapsedContent(false),
                // panel: Text(''),
              )
            ],
          )),
    );
  }

  Widget collapsedContent(bool isExpanded) {
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
        child: ProviderHandler<HybridProvider>(
            functionName: HybridProvider().HYBRID_GET_ALL_EVENTS,
            showError: true,
            load: (provider) => provider.getAllHybridEvents(),
            errorBuilder: (provider) => Center(
                  child: Text('Some error occured'),
                ),
            successBuilder: (provider) {
              if (provider.allHybridNotifications.length == 0) {
                return Center(
                  child: Text('No data found'),
                );
              } else {
                return ListView.separated(
                    // physics: NeverScrollableScrollPhysics(),
                    itemCount: provider.allHybridNotifications.length,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      if (provider.allHybridNotifications[index]
                                  .notificationType ==
                              NotificationType.Event &&
                          provider.allHybridNotifications[index]
                                  .eventNotificationModel !=
                              null) {
                        return InkWell(
                          onTap: () {
                            HomeEventService().onEventModelTap(
                                provider.allHybridNotifications[index]
                                    .eventNotificationModel,
                                provider);
                          },
                          child: DisplayTile(
                            atsignCreator: provider
                                .allHybridNotifications[index]
                                .eventNotificationModel
                                .atsignCreator,
                            title: getTitle(
                                provider.allHybridNotifications[index]),
                            subTitle: getSubTitle(
                                provider.allHybridNotifications[index]),
                            semiTitle: getSemiTitle(
                                provider.allHybridNotifications[index]),
                          ),
                        );
                      } else if (provider.allHybridNotifications[index]
                                  .notificationType ==
                              NotificationType.Location &&
                          provider.allHybridNotifications[index]
                                  .locationNotificationModel !=
                              null) {
                        return InkWell(
                          onTap: () {
                            HomeEventService().onLocationModelTap(provider
                                .allHybridNotifications[index]
                                .locationNotificationModel);
                          },
                          child: DisplayTile(
                            atsignCreator: provider
                                .allHybridNotifications[index]
                                .locationNotificationModel
                                .atsignCreator,
                            title: getTitle(
                                provider.allHybridNotifications[index]),
                            subTitle: getSubTitle(
                                provider.allHybridNotifications[index]),
                            semiTitle: getSemiTitle(
                                provider.allHybridNotifications[index]),
                          ),
                        );
                      }
                    });
              }
            }));
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
                        ClientSdkService.getInstance()
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
                          onSuccess: (provider) {});
                    }, createdEvents: allEvents),
                    SizeConfig().screenHeight * 0.9, onSheetCLosed: () {
                  eventProvider.getAllEvents();
                });
              }),
          Tasks(
              task: 'Request Location',
              icon: Icons.refresh,
              onTap: () async {
                BackendService.getInstance().getAllNotificationKeys();
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
}
