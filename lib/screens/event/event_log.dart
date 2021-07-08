import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
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
    return Container(
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            centerTitle: true,
            padding: true,
            title: 'Events',
            action: PopButton(label: 'Close'),
          ),
          body: SingleChildScrollView(
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
                            'Upcoming',
                            style: TextStyle(
                                fontSize: 16.toFont, letterSpacing: 1),
                          ),
                        ),
                        Tab(
                          child: Text('Past',
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
      ),
    );
  }
}

Widget getUpcomingEvents() {
  var upcomingEvents = Provider.of<LocationProvider>(
          NavService.navKey.currentContext,
          listen: false)
      .allEventNotifications
      .map((e) => e.eventNotificationModel)
      .toList();
  return ListView.separated(
    scrollDirection: Axis.vertical,
    itemCount: upcomingEvents.length,
    separatorBuilder: (context, index) {
      return Divider();
    },
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10, top: 10),
        child: DisplayTile(
          title: upcomingEvents[index].title,
          atsignCreator: upcomingEvents[index].atsignCreator,
          subTitle:
              'Event on ${dateToString(upcomingEvents[index].event.date)}',
          invitedBy: 'Invited by ${upcomingEvents[index].atsignCreator}',
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
      return Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10, top: 10),
        child: DisplayTile(
          title: pastEvents[index].title,
          atsignCreator: pastEvents[index].atsignCreator,
          subTitle: 'Event on ${dateToString(pastEvents[index].event.date)}',
          invitedBy: 'Invited by ${pastEvents[index].atsignCreator}',
        ),
      );
    },
  );
}
