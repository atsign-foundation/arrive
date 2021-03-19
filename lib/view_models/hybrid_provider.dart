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
    reset(HYBRID_GET_ALL_EVENTS);
    reset(HYBRID_CHECK_ACKNOWLEDGED_EVENT);
    reset(HYBRID_ADD_EVENT);
    reset(HYBRID_MAP_UPDATED_EVENT_DATA);
    reset(FIND_ATSIGNS_TO_SHARE_WITH);
  }

  getAllHybridEvents() async {
    setStatus(HYBRID_GET_ALL_EVENTS, Status.Loading);
    try {
      await super.getSingleUserLocationSharing();
      await super.getSingleUserLocationRequest();
      await super.getAllEvents();

      allHybridNotifications = [
        ...super.allNotifications,
        ...super.allShareLocationNotifications,
        ...super.allRequestNotifications
      ];

      HomeEventService().setAllEventsList(allHybridNotifications);
      filterPastEventsFromList();

      setStatus(HYBRID_GET_ALL_EVENTS, Status.Done);
      initialiseLacationSharing();
    } catch (e) {
      print(e);
      setStatus(HYBRID_GET_ALL_EVENTS, Status.Error);
    }
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

        // TODO: check for location on/off to add or remove
        checkLocationSharingForMappedData(allHybridNotifications[i]);

        break;
      }
    }
    HomeEventService().setAllEventsList(allHybridNotifications);
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Done);
  }

  checkLocationSharingForMappedData(HybridNotificationModel notification) {
    if (notification.notificationType == NotificationType.Event) {
      // if creator, then check if isSharing is true then add group member to receiving users list
      if ((notification.eventNotificationModel.atsignCreator.toLowerCase() ==
          BackendService.getInstance()
              .atClientServiceInstance
              .atClient
              .currentAtSign
              .toLowerCase())) {
        print(
            'creator current.eventNotificationModel ${notification.eventNotificationModel.isSharing}');
        if (notification.eventNotificationModel.isSharing)
          addMemberToSendingLocationList(notification);
        else
          removeLocationSharing(notification.key);
      } else {
        // if !creator, then check if ['isSharing'] is true then add creator to receiving users list
        print(
            'current.eventNotificationModel ${notification.eventNotificationModel.group.members.elementAt(0).tags['isSharing']}');
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
                false)
          addMemberToSendingLocationList(notification);
        else
          removeLocationSharing(notification.key);
      }
    } else {
      // ADD OR REMOVE LOCATION SHARING
      if (notification.locationNotificationModel.isSharing)
        addMemberToSendingLocationList(BackendService.getInstance()
            .convertEventToHybrid(NotificationType.Location,
                locationNotificationModel:
                    notification.locationNotificationModel));
      else
        removeLocationSharing(notification.key);
    }
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
    }
    allHybridNotifications.add(tempNotification);
    setStatus(HYBRID_ADD_EVENT, Status.Done);

    addMemberToSendingLocationList(tempNotification);
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
          if ((notification.eventNotificationModel.atsignCreator
                  .toLowerCase() ==
              currentAtsign.toLowerCase())) {
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
        if ((notification.locationNotificationModel.atsignCreator
                    .toLowerCase() ==
                currentAtsign.toLowerCase()) &&
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
      } else {
        print(
            'date matching:${dateToString(notification.eventNotificationModel.event.date)} ,${dateToString(DateTime.now())} ');

        if (isOneDayEventOccursToday(
            notification.eventNotificationModel.event)) {
          DateTime date = notification.eventNotificationModel.event.date;
          if (notification.eventNotificationModel.event.endDate != null) {
            DateTime endDate =
                notification.eventNotificationModel.event.endDate;
            TimeOfDay from = TimeOfDay.fromDateTime(
                notification.eventNotificationModel.event.startTime);
            TimeOfDay to = TimeOfDay.fromDateTime(
                notification.eventNotificationModel.event.endTime);
            AtContact groupMember =
                notification.eventNotificationModel.group.members.elementAt(0);

            location.from = DateTime(
                date.year, date.month, date.day, from.hour, from.minute);

            location.from = startTimeEnumToTimeOfDay(
                groupMember.tags['shareFrom'].toString(), location.from);

            location.to = DateTime(
                endDate.year, endDate.month, endDate.day, to.hour, to.minute);

            location.to = endTimeEnumToTimeOfDay(
                groupMember.tags['shareTo'].toString(), location.to);

            location.key = notification.key;

            shareLocationData
                .add(location); // for findAtSignsToShareLocatonWith
            return location;
          }
        }
      }
    } else if (notification.notificationType == NotificationType.Location) {
      print(
          'adding data to share location: ${notification.locationNotificationModel.atsignCreator}');
      shareLocationData.add(notification
          .locationNotificationModel); // for findAtSignsToShareLocatonWith
      return location;
    }
    return null;
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

  sendLocationSharing() {
    findAtSignsToShareLocationWith();
    SendLocationNotification().init(shareLocationData, atClientInstance);
  }

  stopLocationSharing() {
    SendLocationNotification().init([], atClientInstance);
    SendLocationNotification().deleteAllLocationKey();
  }

  // TODO: Only place it is wrongly getting accessed from is requestLocationAcknowledgment in request_location_service
  addMemberToSendingLocationList(HybridNotificationModel notification) {
    print('addMemberToSendingLocationList called');
    String currentAtsign = BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;
    if ((notification.notificationType == NotificationType.Location) &&
        (notification.locationNotificationModel.atsignCreator ==
            currentAtsign)) {
      print('addMemberToSendingLocationList ${notification.key} added');

      SendLocationNotification()
          .addMember(notification.locationNotificationModel);
    } else if ((notification.notificationType == NotificationType.Event)) {
      var _getLocationModelFromEventModel =
          getLocationModelFromEventModel(notification);
      if (_getLocationModelFromEventModel != null) {
        print('addMemberToSendingLocationList ${notification.key} added');

        SendLocationNotification().addMember(_getLocationModelFromEventModel);
      }
    }
  }

  // TODO: Only place it is wrongly getting accessed from is onEventModelTap in home_event_service

  removeLocationSharing(String key) {
    print('removeLocationSharing called ${key}');

    shareLocationData.removeWhere((element) => element.key == key);
    // sendLocationSharing();
    SendLocationNotification().removeMember(key);
    // if the array is recalculated it will be added
  }

  getLocationModelFromEventModel(HybridNotificationModel notification) {
    LocationNotificationModel location = LocationNotificationModel();
    String currentAtsign = BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;

    if (!notification.eventNotificationModel.isCancelled) {
      if ((notification.eventNotificationModel.atsignCreator.toLowerCase() ==
              currentAtsign.toLowerCase()) &&
          (notification.eventNotificationModel.isSharing)) {
        location = LocationNotificationModel()
          ..atsignCreator = notification.eventNotificationModel.atsignCreator
          ..isAcknowledgment = true
          ..isAccepted = true
          ..receiver = notification.eventNotificationModel.group.members
              .elementAt(0)
              .atSign;
        location = getLocationNotificationData(notification, location);
        return location;
      } else if (notification.eventNotificationModel.group.members
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
          ..atsignCreator = notification.eventNotificationModel.group.members
              .elementAt(0)
              .atSign
          ..isAcknowledgment = true
          ..isAccepted = true
          ..receiver = notification.eventNotificationModel.atsignCreator;
        location = getLocationNotificationData(notification, location);
        return location;
      }
    }
    return null;
  }
}
