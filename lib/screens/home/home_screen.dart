import 'package:at_contact/at_contact.dart';
import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_events/screens/create_event.dart';
import 'package:atsign_location/atsign_location.dart';
import 'package:atsign_location/atsign_location_plugin.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/dialog_box/share_location_notifier_dialog.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/common_components/floating_icon.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/common_components/provider_handler.dart';
import 'package:atsign_location_app/common_components/tasks.dart';
import 'package:atsign_location_app/dummy_data/group_data.dart';
import 'package:atsign_location_app/dummy_data/latLng.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/screens/request_location/request_location_sheet.dart';
import 'package:atsign_location_app/screens/share_location/share_location_sheet.dart';
import 'package:atsign_location_app/screens/sidebar/sidebar.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:atsign_contacts/utils/init_contacts_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PanelController pc = PanelController();
  EventProvider eventProvider = new EventProvider();
  String currentAtSign;

  @override
  void initState() {
    super.initState();
    initializeContacts();
    eventProvider = context.read<EventProvider>();
    eventProvider
        .init(ClientSdkService.getInstance().atClientServiceInstance.atClient);
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
              // GestureDetector(
              //     onTapDown: (tapDownDetails) {
              //       return SetupRoutes.push(
              //           context, Routes.SHARE_LOCATION_EVENT);
              //     },
              //     child: AbsorbPointer(
              //         absorbing: true,
              //         child: AtsignLocationPlugin(getLatLng()))),
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
                panel: collapsedContent(true),
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
        child: ProviderHandler<EventProvider>(
            functionName: EventProvider().GET_ALL_EVENTS,
            showError: true,
            load: (provider) => provider.getAllEvents(),
            errorBuilder: (provider) => Center(
                  child: Text('Some error occured'),
                ),
            successBuilder: (provider) {
              if (provider.allNotifications.length > 0) {
                return SingleChildScrollView(
                  physics: !isExpanded
                      ? NeverScrollableScrollPhysics()
                      : AlwaysScrollableScrollPhysics(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DraggableSymbol(),
                        SizedBox(
                          height: 5.toHeight,
                        ),
                        Divider(),
                        !isExpanded
                            ? ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: 3,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      if (!(isActionRequired(provider
                                          .allNotifications[index]
                                          .eventNotificationModel))) {
                                        print(
                                            'clicked event:${provider.allNotifications[index].eventNotificationModel.group.members}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AtsignLocationPlugin(
                                                    ClientSdkService
                                                            .getInstance()
                                                        .atClientServiceInstance
                                                        .atClient,
                                                    eventListenerKeyword: provider
                                                        .allNotifications[index]
                                                        .eventNotificationModel),
                                          ),
                                        );
                                      }
                                    },
                                    child: DisplayTile(
                                      image: AllImages().PERSON2,
                                      title: provider.allNotifications[index]
                                          .eventNotificationModel.title,
                                      subTitle: provider
                                                  .allNotifications[index]
                                                  .eventNotificationModel
                                                  .event !=
                                              null
                                          ? provider
                                                      .allNotifications[index]
                                                      .eventNotificationModel
                                                      .event
                                                      .date !=
                                                  null
                                              ? 'event on ${dateToString(provider.allNotifications[index].eventNotificationModel.event.date)}'
                                              : ''
                                          : '',
                                      semiTitle: provider
                                                  .allNotifications[index]
                                                  .eventNotificationModel
                                                  .group !=
                                              null
                                          ? (isActionRequired(provider
                                                  .allNotifications[index]
                                                  .eventNotificationModel))
                                              ? 'Action required'
                                              : ''
                                          : '',
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Divider();
                                },
                              )
                            : SizedBox(),
                        !isExpanded
                            ? Container(
                                //height: 16.toHeight,
                                alignment: Alignment.topCenter,
                                width: SizeConfig().screenWidth,
                                padding: EdgeInsets.fromLTRB(56.toHeight,
                                    0.toHeight, 0.toWidth, 0.toHeight),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                child: InkWell(
                                  onTap: () => pc.open(),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      provider.allNotifications.length > 3
                                          ? Text(
                                              'See ${provider.allNotifications.length - 3} more ',
                                              style:
                                                  CustomTextStyles().darkGrey14,
                                            )
                                          : SizedBox(),
                                      Icon(Icons.keyboard_arrow_down)
                                    ],
                                  ),
                                ))
                            : SizedBox(),
                        !isExpanded
                            ? SizedBox()
                            : ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: provider.allNotifications.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      if (index == 3) {
                                        pc.open();
                                        return null;
                                      }

                                      if (isActionRequired(provider
                                          .allNotifications[index]
                                          .eventNotificationModel)) {
                                        return showDialog<void>(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (BuildContext context) {
                                            print(
                                                'selected event${provider.allNotifications[index].key}');
                                            return ShareLocationNotifierDialog(
                                                provider.allNotifications[index]
                                                    .eventNotificationModel,
                                                userName: provider
                                                    .allNotifications[index]
                                                    .eventNotificationModel
                                                    .atsignCreator);
                                          },
                                        );
                                      }
                                      print(
                                          'clicked event date:${provider.allNotifications[index].key} , member:${provider.allNotifications[index].eventNotificationModel.group.members}');

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AtsignLocationPlugin(
                                                  ClientSdkService.getInstance()
                                                      .atClientServiceInstance
                                                      .atClient,
                                                  eventListenerKeyword: provider
                                                      .allNotifications[index]
                                                      .eventNotificationModel),
                                        ),
                                      );
                                    },
                                    child: index == 3 && pc.isPanelClosed
                                        ? Text(
                                            'See ${provider.allNotifications.length - 3} more ',
                                            style:
                                                CustomTextStyles().darkGrey14,
                                          )
                                        : DisplayTile(
                                            image: AllImages().PERSON2,
                                            title: provider
                                                .allNotifications[index]
                                                .eventNotificationModel
                                                .title,
                                            subTitle: provider
                                                        .allNotifications[index]
                                                        .eventNotificationModel
                                                        .event !=
                                                    null
                                                ? provider
                                                            .allNotifications[
                                                                index]
                                                            .eventNotificationModel
                                                            .event
                                                            .date !=
                                                        null
                                                    ? 'event on ${dateToString(provider.allNotifications[index].eventNotificationModel.event.date)}'
                                                    : ''
                                                : '',
                                            semiTitle: provider
                                                        .allNotifications[index]
                                                        .eventNotificationModel
                                                        .group !=
                                                    null
                                                ? (isActionRequired(provider
                                                        .allNotifications[index]
                                                        .eventNotificationModel))
                                                    ? 'Action required'
                                                    : ''
                                                : 'Action required',
                                          ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Divider();
                                },
                              )
                      ]),
                );
              } else {
                return Center(
                  child: Text('No events found'),
                );
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
                // BackendService.getInstance().updateNotification();
                bottomSheet(
                    context,
                    CreateEvent(ClientSdkService.getInstance()
                        .atClientServiceInstance
                        .atClient),
                    SizeConfig().screenHeight * 0.9, onSheetCLosed: () {
                  eventProvider.getAllEvents();
                });
              }),
          Tasks(
              task: 'Request Location',
              icon: Icons.refresh,
              onTap: () {
                BackendService.getInstance().getAllNotificationKeys();
                // bottomSheet(context, RequestLocationSheet(),
                //     SizeConfig().screenHeight * 0.5);
              }),
          Tasks(
              task: 'Share Location',
              icon: Icons.person_add,
              onTap: () {
                eventProvider.updateEventAccordingToAcknowledgedData();
                // bottomSheet(context, ShareLocationSheet(),
                //     SizeConfig().screenHeight * 0.6);
              })
        ],
      ),
    );
  }
}

bool isActionRequired(EventNotificationModel event) {
  bool isRequired = true;
  String currentAtsign = ClientSdkService.getInstance()
      .atClientServiceInstance
      .atClient
      .currentAtSign;

  if (event.group.members.length < 1) return true;

  event.group.members.forEach((member) {
    if (member.tags['isAccepted'] != null &&
        member.tags['isAccepted'] == true &&
        member.atSign == currentAtsign) {
      isRequired = false;
    }
  });

  if (event.atsignCreator == currentAtsign) isRequired = false;

  return isRequired;
}
