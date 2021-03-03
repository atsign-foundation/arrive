import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/location_service.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/send_location_notification.dart';
import 'package:atsign_location_app/models/enums_model.dart';
import 'package:atsign_location_app/services/backend_service.dart';

import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/services/location_notification_listener.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';
import 'package:flutter/material.dart';

import 'base_model.dart';

class HybridProvider extends RequestLocationProvider {
  HybridProvider();
  AtClientImpl atClientInstance;
  String currentAtSign;
  List<HybridNotificationModel> allHybridNotifications,
      allPastEventNotifications;
  List<LocationNotificationModel> shareLocationData;
  // ignore: non_constant_identifier_names
  String HYBRID_GET_ALL_EVENTS = 'hybrid_get_all_events';
  // ignore: non_constant_identifier_names
  String HYBRID_CHECK_ACKNOWLEDGED_EVENT = 'hybrid_check_acknowledged_event';
  // ignore: non_constant_identifier_names
  String HYBRID_ADD_EVENT = 'hybrid_ADD_EVENT';
  // ignore: non_constant_identifier_names
  String HYBRID_MAP_UPDATED_EVENT_DATA = 'hybrid_map_event_event';
  // ignore: non_constant_identifier_names
  String FIND_ATSIGNS_TO_SHARE_WITH = 'find_atsigns_to_share_with';

  init(AtClientImpl clientInstance) {
    print('hyrbid clientInstance $clientInstance');
    allHybridNotifications = [];
    allPastEventNotifications = [];
    shareLocationData = [];
    super.init(clientInstance);
  }

  getAllHybridEvents() async {
    setStatus(HYBRID_GET_ALL_EVENTS, Status.Loading);

    await super.getAllEvents();
    await super.getSingleUserLocationSharing();
    await super.getSingleUserLocationRequest();

    allHybridNotifications = [
      ...super.allNotifications,
      ...super.allShareLocationNotifications,
      ...super.allRequestNotifications
    ];

    HomeEventService().setAllEventsList(allHybridNotifications);
    filterPastEventsFromList();

    setStatus(HYBRID_GET_ALL_EVENTS, Status.Done);
    findAtSignsToShareLocationWith();
    initialiseLacationSharing();
  }

  filterPastEventsFromList() {
    for (int i = 0; i < allHybridNotifications.length; i++) {
      if (allHybridNotifications[i].notificationType ==
          NotificationType.Event) {
        if (allHybridNotifications[i]
                .eventNotificationModel
                .event
                .endTime
                .difference(DateTime.now())
                .inMinutes <
            0) allPastEventNotifications.add(allHybridNotifications[i]);
      }
    }
    allPastEventNotifications.forEach((element) {
      print('removed event data in hybrid_prvider ${element.key}');
      print('${element.locationNotificationModel}');
    });
    allHybridNotifications
        .removeWhere((element) => allPastEventNotifications.contains(element));
  }

  mapUpdatedData(HybridNotificationModel notification, {bool remove = false}) {
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Loading);
    String newEventDataKeyId = notification.notificationType ==
            NotificationType.Event
        ? notification.eventNotificationModel.key
            .split('createevent-')[1]
            .split('@')[0]
        : notification.locationNotificationModel.key.contains('sharelocation')
            ? notification.locationNotificationModel.key
                .split('sharelocation-')[1]
                .split('@')[0]
            : notification.locationNotificationModel.key
                .split('requestlocation-')[1]
                .split('@')[0];

    for (int i = 0; i < allHybridNotifications.length; i++) {
      if ((allHybridNotifications[i].key.contains(newEventDataKeyId))) {
        if (NotificationType.Event == notification.notificationType) {
          allHybridNotifications[i].eventNotificationModel =
              notification.eventNotificationModel;
          allHybridNotifications[i].eventNotificationModel.key =
              allHybridNotifications[i].key;
          LocationService().updateEventWithNewData(
              allHybridNotifications[i].eventNotificationModel);
        } else {
          if (notification.locationNotificationModel.key
              .contains('sharelocation')) {
            allHybridNotifications[i].locationNotificationModel =
                notification.locationNotificationModel;
          } else {
            if (!remove)
              allHybridNotifications[i].locationNotificationModel =
                  notification.locationNotificationModel;
            else
              allHybridNotifications.remove(allRequestNotifications[i]);
          }
        }
        break;
      }
    }
    HomeEventService().setAllEventsList(allHybridNotifications);
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Done);
  }

  addNewEvent(HybridNotificationModel notification) async {
    setStatus(HYBRID_ADD_EVENT, Status.Loading);
    HybridNotificationModel tempNotification;
    if (notification.notificationType == NotificationType.Location) {
      if (notification.locationNotificationModel.key
          .contains('sharelocation')) {
        tempNotification =
            await super.addDataToList(notification.locationNotificationModel);
      } else {
        tempNotification = await super
            .addDataToListRequest(notification.locationNotificationModel);
      }
    } else {
      tempNotification =
          await super.addDataToListEvent(notification.eventNotificationModel);

      // tempNotification = HybridNotificationModel(NotificationType.Event);
      // tempNotification.key = notification.eventNotificationModel.key;
      // tempNotification.atKey =
      //     BackendService.getInstance().getAtKey(notification.eventNotificationModel.key);
      // tempNotification.atValue = await getAtValue(tempNotification.atKey);
      // tempNotification.eventNotificationModel =
      //     notification.eventNotificationModel;
      // allNotifications.add(tempNotification);
    }
    allHybridNotifications.add(tempNotification);
    setStatus(HYBRID_ADD_EVENT, Status.Done);
  }

  findAtSignsToShareLocationWith() {
    shareLocationData = [];
    String currentAtsign = BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;
    allHybridNotifications.forEach((notification) {
      LocationNotificationModel location = LocationNotificationModel();
      if (notification.notificationType == NotificationType.Event) {
        if (!notification.eventNotificationModel.isCancelled) {
          if ((notification.eventNotificationModel.atsignCreator ==
              currentAtsign)) {
            if (notification.eventNotificationModel.isSharing) {
              location = LocationNotificationModel()
                ..atsignCreator =
                    notification.eventNotificationModel.atsignCreator
                ..isAcknowledgment = true
                ..isAccepted = true
                ..receiver = notification.eventNotificationModel.group.members
                    .elementAt(0)
                    .atSign;
              location = getLocationNotificationData(notification, location);
            }
          } else {
            if (notification.eventNotificationModel.group.members
                        .elementAt(0)
                        .tags['isAccepted'] ==
                    true &&
                notification.eventNotificationModel.group.members
                        .elementAt(0)
                        .tags['isSharing'] ==
                    true &&
                notification.eventNotificationModel.group.members
                        .elementAt(0)
                        .tags['isExited'] ==
                    false) {
              location = LocationNotificationModel()
                ..atsignCreator = notification
                    .eventNotificationModel.group.members
                    .elementAt(0)
                    .atSign
                ..isAcknowledgment = true
                ..isAccepted = true
                ..receiver = notification.eventNotificationModel.atsignCreator;
              location = getLocationNotificationData(notification, location);
            }
          }
        }
      } else if (notification.notificationType == NotificationType.Location) {
        if ((notification.locationNotificationModel.atsignCreator ==
                currentAtsign) &&
            (notification.locationNotificationModel.isSharing) &&
            (notification.locationNotificationModel.isAccepted) &&
            (!notification.locationNotificationModel.isExited)) {
          location = getLocationNotificationData(
              notification, notification.locationNotificationModel);
        }
      }
    });
  }

  LocationNotificationModel getLocationNotificationData(
      HybridNotificationModel notification,
      LocationNotificationModel location) {
    // DateTime d1 = DateTime(2021);
    // d1.month;
    // // d1.add(Duration(days: ));

    if (notification.notificationType == NotificationType.Event) {
      if (notification.eventNotificationModel.event.isRecurring) {
        // for recurring
        if (notification.eventNotificationModel.event.repeatCycle ==
            RepeatCycle.MONTH) {
          // repeat cycle is month
          List<Map<String, dynamic>> months = [];
          for (int i = 1; i <= 12; i++) {
            if (i % notification.eventNotificationModel.event.repeatDuration ==
                0) {
              print(
                  'month matched:${notification.eventNotificationModel.title}');
              // months.add(monthsList['$i']);
            }
          }
          print('recurring months: ${months}');
        } else if (notification.eventNotificationModel.event.repeatCycle ==
            RepeatCycle.WEEK) {
          // repeat every week cycle
        }
      } else {
        print(
            'date matching:${dateToString(notification.eventNotificationModel.event.date)} ,${dateToString(DateTime.now())} ');

        if (isOneDayEventOccursToday(
            notification.eventNotificationModel.event)) {
          DateTime date = notification.eventNotificationModel.event.date;
          TimeOfDay from = TimeOfDay.fromDateTime(
              notification.eventNotificationModel.event.startTime);
          TimeOfDay to = TimeOfDay.fromDateTime(
              notification.eventNotificationModel.event.endTime);
          AtContact groupMember =
              notification.eventNotificationModel.group.members.elementAt(0);

          location.from =
              DateTime(date.year, date.month, date.day, from.hour, from.minute);

          location.from = startTimeEnumToTimeOfDay(
              groupMember.tags['shareFrom'].toString(), location.from);

          if (to.hour + to.minute / 60.0 > from.hour + from.minute / 60.0) {
            location.to =
                DateTime(date.year, date.month, date.day, to.hour, to.minute);
          } else {
            location.to = DateTime(
                date.year, date.month, date.day + 1, to.hour, to.minute);
          }

          location.to = endTimeEnumToTimeOfDay(
              groupMember.tags['shareTo'].toString(), location.to);
          location.key = notification.key;
          // print(
          // '${groupMember.tags} , title:${notification.eventNotificationModel.title} :adding data to share location: ${notification.eventNotificationModel.event.startTime} , to :${notification.eventNotificationModel.event.endTime} : after edit form :${location.from} , after edit to : ${location.to}');
          shareLocationData.add(location);
          return location;
        }
      }
    } else if (notification.notificationType == NotificationType.Location) {
      print(
          'adding data to share location: ${notification.locationNotificationModel.atsignCreator}');
      shareLocationData.add(notification.locationNotificationModel);
      return location;
    }
  }

  bool isOneDayEventOccursToday(Event event) {
    bool isEventToday = false;
    // if (event.endTime.hour + event.endTime.minute / 60.0 >
    //     event.startTime.hour + event.startTime.minute / 60.0) {
    //   if (dateToString(event.date) == dateToString(DateTime.now()))
    //     isEventToday = true;
    // } else {
    //   DateTime todaysDate = DateTime.now();
    //   if ((dateToString(DateTime(
    //               event.date.year, event.date.month, event.date.day)) ==
    //           dateToString(DateTime(
    //               todaysDate.year, todaysDate.month, todaysDate.day))) ||
    //       (dateToString(DateTime(
    //               event.date.year, event.date.month, event.date.day + 1)) ==
    //           dateToString(
    //               DateTime(todaysDate.year, todaysDate.month, todaysDate.day))))
    //     isEventToday = true;
    // }

    if (dateToString(event.date) == dateToString(DateTime.now())) {
      isEventToday = true;
    }

    if (dateToString(event.endDate) == dateToString(DateTime.now())) {
      isEventToday = true;
    }

    if (DateTime.now().isAfter(event.date) &&
        DateTime.now().isBefore(event.endDate)) {
      isEventToday = true;
    }

    return isEventToday;
  }

  initialiseLacationSharing() async {
    bool isSharing = await LocationNotificationListener().getShareLocation();
    if (isSharing)
      sendLocationSharing();
    else
      stopLocationSharing();
  }

  removeLocationSharing(LocationNotificationModel locationNotificationModel) {
    shareLocationData
        .removeWhere((element) => element.key == locationNotificationModel.key);
    sendLocationSharing();
    // if the array is recalculated it will be added
  }

  sendLocationSharing() {
    SendLocationNotification().init(shareLocationData, atClientInstance);
  }

  stopLocationSharing() {
    SendLocationNotification().init([], atClientInstance);
    SendLocationNotification().deleteAllLocationKey();
    // shareLocationData.forEach((locationData) {
    //   SendLocationNotification().sendNull(locationData);
    // });
  }
}
