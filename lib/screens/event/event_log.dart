import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_events/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';

class EventLog extends StatefulWidget {
  @override
  _EventLogState createState() => _EventLogState();
}

class _EventLogState extends State<EventLog> {
  List<HybridNotificationModel> allEvents;
  @override
  void initState() {
    super.initState();
    allEvents = [];
    getAllEvents();
  }

  getAllEvents() {
    List<HybridNotificationModel> allEventsNotfication =
        HomeEventService().getAllEvents;
    allEventsNotfication.forEach((event) {
      if (event.notificationType == NotificationType.Event &&
          !event.eventNotificationModel.event.isRecurring) {
        allEvents.add(event);
      }
    });
    print('all Events:${allEvents}');
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
          body: Column(
            children: <Widget>[
              Container(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        child: TabBar(
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3.toHeight,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: AllColors().DARK_GREY,
                          tabs: [
                            Tab(
                              child: Text(
                                'Upcoming',
                                style: CustomTextStyles().boldLabel16,
                              ),
                            ),
                            Tab(
                              child: Text('Past',
                                  style: CustomTextStyles().boldLabel16),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            20.toWidth, 20.toHeight, 10.toWidth, 5.toHeight),
                        height: SizeConfig().screenHeight - 190.toHeight,
                        child: TabBarView(
                          children: [
                            getUpcomingEvents(allEvents),
                            getPastEvents(allEvents)
                          ],
                        ),
                      ),
                    ],
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

Widget getUpcomingEvents(List<HybridNotificationModel> allEvents) {
  List<HybridNotificationModel> events = [];
  DateTime todaysDate = DateTime.now();
  allEvents.forEach((event) {
    DateTime eventDate = event.eventNotificationModel.event.date;

    if (event.eventNotificationModel.event.date.year == todaysDate.year &&
        event.eventNotificationModel.event.date.month == todaysDate.month &&
        event.eventNotificationModel.event.date.day == todaysDate.day) {
      events.add(event);
    } else if (todaysDate.compareTo(eventDate) == -1) events.add(event);
  });
  return ListView.separated(
    scrollDirection: Axis.vertical,
    itemCount: events.length,
    separatorBuilder: (context, index) {
      return Divider();
    },
    itemBuilder: (context, index) {
      return DisplayTile(
        title: events[index].eventNotificationModel.title,
        number: 10,
        image: AllImages().PERSON2,
        subTitle:
            'Event on ${dateToString(events[index].eventNotificationModel.event.date)}',
        invitedBy:
            'Invited by ${events[index].eventNotificationModel.atsignCreator}',
      );
    },
  );
}

Widget getPastEvents(List<HybridNotificationModel> allEvents) {
  List<HybridNotificationModel> events = [];
  DateTime todaysDate = DateTime.now();

  allEvents.forEach((event) {
    DateTime eventDate = event.eventNotificationModel.event.date;

    if ((event.eventNotificationModel.event.date.year != todaysDate.year &&
            event.eventNotificationModel.event.date.month != todaysDate.month &&
            event.eventNotificationModel.event.date.day != todaysDate.day) &&
        todaysDate.compareTo(eventDate) == 1) {
      events.add(event);
    }
  });
  return ListView.separated(
    scrollDirection: Axis.vertical,
    itemCount: events.length,
    separatorBuilder: (context, index) {
      return Divider();
    },
    itemBuilder: (context, index) {
      return DisplayTile(
        title: events[index].eventNotificationModel.title,
        number: 10,
        image: AllImages().PERSON2,
        subTitle:
            'Event on ${dateToString(events[index].eventNotificationModel.event.date)}',
        invitedBy:
            'Invited by ${events[index].eventNotificationModel.atsignCreator}',
      );
    },
  );
}
