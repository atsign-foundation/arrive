import 'package:at_client_mobile/at_client_mobile.dart';
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
  bool isSharing = false;
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

    allHybridNotifications
        .removeWhere((element) => allPastEventNotifications.contains(element));
  }

  // called when a share location key is deleted => to remove from UI
  removePerson(String key) {
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Loading);

    allHybridNotifications
        .removeWhere((notification) => key.contains(notification.atKey.key));

    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Done);

    SendLocationNotification().removeMember(key);
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

        checkLocationSharingForMappedData(allHybridNotifications[i]);

        break;
      }
    }
    HomeEventService().setAllEventsList(allHybridNotifications);
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Done);
  }

  checkLocationSharingForMappedData(HybridNotificationModel notification) {
    if (notification.notificationType == NotificationType.Event) {
      if ((notification.eventNotificationModel.atsignCreator.toLowerCase() ==
          BackendService.getInstance()
              .atClientServiceInstance
              .atClient
              .currentAtSign
              .toLowerCase())) {
        if (notification.eventNotificationModel.isSharing)
          addMemberToSendingLocationList(notification);
        else
          removeLocationSharing(notification.key);
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
                false)
          addMemberToSendingLocationList(notification);
        else
          removeLocationSharing(notification.key);
      }
    } else {
      if ((notification.locationNotificationModel.isSharing) &&
          (notification.locationNotificationModel.isAccepted))
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
    if (notification.notificationType == NotificationType.Event) {
      if (notification.eventNotificationModel.event.isRecurring) {
      } else {
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

            shareLocationData.add(location);
            return location;
          }
        }
      }
    } else if (notification.notificationType == NotificationType.Location) {
      shareLocationData.add(notification.locationNotificationModel);
      return location;
    }
    return null;
  }

  bool isOneDayEventOccursToday(Event event) {
    bool isEventToday = false;

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
    isSharing = await LocationNotificationListener().getShareLocation();
    notifyListeners();
    if (isSharing) {
      sendLocationSharing();
    } else {
      stopLocationSharing();
    }
  }

  sendLocationSharing() {
    findAtSignsToShareLocationWith();
    SendLocationNotification().init(shareLocationData, atClientInstance);
  }

  stopLocationSharing() {
    SendLocationNotification().init([], atClientInstance);
    SendLocationNotification().deleteAllLocationKey();
  }

  // Only place it is wrongly getting accessed from is requestLocationAcknowledgment in request_location_service
  addMemberToSendingLocationList(HybridNotificationModel notification) {
    String currentAtsign = BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;
    if ((notification.notificationType == NotificationType.Location) &&
        (notification.locationNotificationModel.atsignCreator ==
            currentAtsign)) {
      SendLocationNotification()
          .addMember(notification.locationNotificationModel);
    } else if ((notification.notificationType == NotificationType.Event)) {
      var _getLocationModelFromEventModel =
          getLocationModelFromEventModel(notification);
      if (_getLocationModelFromEventModel != null) {
        SendLocationNotification().addMember(_getLocationModelFromEventModel);
      }
    }
  }

  // Only place it is wrongly getting accessed from is onEventModelTap in home_event_service
  removeLocationSharing(String key) {
    shareLocationData.removeWhere((element) => element.key == key);
    SendLocationNotification().removeMember(key);
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
