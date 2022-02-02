import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/map_screen/events_collapsed_content.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/services/home_event_service.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/dialog_box/delete_dialog_confirmation.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/models/event_and_location.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class EventLog extends StatefulWidget {
  @override
  _EventLogState createState() => _EventLogState();
}

class _EventLogState extends State<EventLog>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    _controller =
        _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        padding: true,
        title: TextStrings.events,
        action: PopButton(label: TextStrings.close),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: SizeConfig().screenHeight - (80.toHeight),
            child: Column(
              children: <Widget>[
                Container(
                  height: 40,
                  child: TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3.toHeight,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: AllColors().DARK_GREY,
                    controller: _controller,
                    tabs: [
                      Tab(
                        child: Text(
                          TextStrings.upcoming,
                          style:
                              TextStyle(fontSize: 16.toFont, letterSpacing: 1),
                        ),
                      ),
                      Tab(
                        child: Text(TextStrings.past,
                            style: TextStyle(
                                fontSize: 16.toFont, letterSpacing: 1)),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: TabBarView(
                  controller: _controller,
                  children: [getUpcomingEvents(), getPastEvents()],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getUpcomingEvents() {
    var upcomingEvents = Provider.of<LocationProvider>(
            NavService.navKey.currentContext,
            listen: false)
        .allEventNotifications;
    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: upcomingEvents.length,
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemBuilder: (context, index) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.15,
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: AllColors().RED,
              icon: Icons.delete,
              onTap: () async {
                await deleteDialogConfirmation(upcomingEvents[index]);
                setState(() {});
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10, top: 10),
            child: InkWell(
              onTap: () {
                HomeEventService().onEventModelTap(
                    upcomingEvents[index].eventKeyModel.eventNotificationModel,
                    upcomingEvents[index].eventKeyModel.haveResponded);
              },
              child: DisplayTile(
                title: upcomingEvents[index]
                    .eventKeyModel
                    .eventNotificationModel
                    .title,
                atsignCreator: upcomingEvents[index]
                    .eventKeyModel
                    .eventNotificationModel
                    .atsignCreator,
                subTitle:
                    'Event on ${dateToString(upcomingEvents[index].eventKeyModel.eventNotificationModel.event.date)}',
                invitedBy:
                    'Invited by ${upcomingEvents[index].eventKeyModel.eventNotificationModel.atsignCreator}',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getPastEvents() {
    var pastEvents = EventKeyStreamService()
        .allPastEventNotifications
        .map((e) => e.eventNotificationModel)
        .toList();
    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: pastEvents.length,
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemBuilder: (context, index) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.15,
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: AllColors().RED,
              icon: Icons.delete,
              onTap: () async {
                await deleteDialogConfirmation(EventAndLocationHybrid(
                    NotificationModelType.EventModel,
                    eventKeyModel: EventKeyLocationModel(
                        eventNotificationModel: pastEvents[index])));
                setState(() {});
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10, top: 10),
            child: InkWell(
              onTap: () {
                bottomSheet(
                  context,
                  EventsCollapsedContent(
                    pastEvents[index],
                    key: UniqueKey(),
                    isStatic: true,
                  ),
                  300,
                  onSheetCLosed: () {},
                );
              },
              child: DisplayTile(
                title: pastEvents[index].title,
                atsignCreator: pastEvents[index].atsignCreator,
                subTitle:
                    'Event on ${dateToString(pastEvents[index].event.date)}',
                invitedBy: 'Invited by ${pastEvents[index].atsignCreator}',
              ),
            ),
          ),
        );
      },
    );
  }
}
