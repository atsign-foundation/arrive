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
  List<HybridNotificationModel> allHybridNotifications;
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

      setStatus(HYBRID_GET_ALL_EVENTS, Status.Done);
      initialiseLocationSharing();

      // TODO: Add the code added in backend service here as well
    } catch (e) {
      print('error in getAllHybridEvents:$e');
      setStatus(HYBRID_GET_ALL_EVENTS, Status.Error);
    }
  }

  // called when a share location key is deleted => to remove from UI
  removePerson(String key) {
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Loading);

    int index = allHybridNotifications
        .indexWhere((notification) => key.contains(notification.atKey.key));

    if (index > -1) {
      if (allHybridNotifications[index]
          .locationNotificationModel
          .key
          .contains('sharelocation')) {
        allShareLocationNotifications.removeWhere(
            (notification) => key.contains(notification.atKey.key));
      } else {
        allRequestNotifications.removeWhere(
            (notification) => key.contains(notification.atKey.key));
      }

      allHybridNotifications.removeAt(index);
    }

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

            /// TODO: Update the data in respective providers
            super.mapUpdatedLocationDataToWidget(
                notification.locationNotificationModel);
          } else {
            if (!remove)
              allHybridNotifications[i].locationNotificationModel =
                  notification.locationNotificationModel;
            else
              allHybridNotifications.remove(allRequestNotifications[i]);

            /// TODO: Update the data in respective providers
            super.mapUpdatedLocationDataToWidgetRequest(
                notification.locationNotificationModel);
          }
        }

        checkLocationSharingForMappedData(allHybridNotifications[i]);

        break;
      }
    }
    HomeEventService().setAllEventsList(allHybridNotifications);
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Done);
  }

  updatePendingStatus(HybridNotificationModel notificationModel) async {
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Loading);

    for (int i = 0; i < allHybridNotifications.length; i++) {
      if (NotificationType.Event == notificationModel.notificationType) {
        if ((allHybridNotifications[i]
            .key
            .contains(notificationModel.eventNotificationModel.key))) {
          allHybridNotifications[i].haveResponded = true;
        }
      } else {
        if ((allHybridNotifications[i]
            .key
            .contains(notificationModel.locationNotificationModel.key))) {
          allHybridNotifications[i].haveResponded = true;
        }
      }
    }

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
        if (notification.eventNotificationModel.isSharing) {
          addMemberToSendingLocationList(notification);
        } else {
          removeLocationSharing(notification.key);
        }
      } else {
        AtContact currentGroupMember;
        notification.eventNotificationModel.group.members
            .forEach((groupMember) {
          // finding current group member
          if (groupMember.atSign == currentAtSign) {
            currentGroupMember = groupMember;
          }
        });

        if (currentGroupMember != null &&
            currentGroupMember.tags['isAccepted'] == true &&
            currentGroupMember.tags['isSharing'] == true &&
            currentGroupMember.tags['isExited'] == false)
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

    if (tempNotification is HybridNotificationModel) {
      allHybridNotifications.add(tempNotification);
      addMemberToSendingLocationList(tempNotification);
    }
    setStatus(HYBRID_ADD_EVENT, Status.Done);
  }

  findAtSignsToShareLocationWith() {
    AtContact currentGroupMember;
    shareLocationData = [];
    String currentAtsign = BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;
    allHybridNotifications.forEach((notification) {
      currentGroupMember = new AtContact();
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
                    .atSign; // This doent matter
              // TODO: Send it to all the users
              location = getLocationNotificationData(notification, location,
                  isCreator: true);
            }
          } else {
            notification.eventNotificationModel.group.members
                .forEach((groupMember) {
              // sending location to other group members
              if (groupMember.atSign == currentAtSign) {
                currentGroupMember = groupMember;
              }
            });

            if (currentGroupMember != null &&
                currentGroupMember.tags['isAccepted'] == true &&
                currentGroupMember.tags['isSharing'] == true &&
                currentGroupMember.tags['isExited'] == false) {
              location = LocationNotificationModel()
                ..atsignCreator = currentGroupMember.atSign
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
      HybridNotificationModel notification, LocationNotificationModel location,
      {AtContact groupMember, bool isCreator = false}) {
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

            // for creator, location sharing will be only between event start and end time
            location.from = DateTime(
                date.year, date.month, date.day, from.hour, from.minute);
            location.to = DateTime(
                endDate.year, endDate.month, endDate.day, to.hour, to.minute);

            if (groupMember != null) {
              location.from = startTimeEnumToTimeOfDay(
                  groupMember.tags['shareFrom'].toString(), location.from);

              location.to = endTimeEnumToTimeOfDay(
                  groupMember.tags['shareTo'].toString(), location.to);
            }

            if (isCreator) {
              String eventId = notification.key.split('-')[1].split('@')[0];

              location.key = 'createevent-$eventId';
            } else {
              String eventId = notification.key.split('-')[1].split('@')[0];

              location.key = 'updateeventlocation-${eventId}';
            }
            print('location.key ${location.key}');
            // TODO: add 'locationnotify.' => key = 'locationnotify.event-$id'
            // TODO: If it is creator then key will be exactly the event key => key = 'event-id'
            // TODO: Accepta param, {isCreator}

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

  initialiseLocationSharing() async {
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
      if (notification.locationNotificationModel.key
          .contains('sharelocation')) {
        SendLocationNotification()
            .addMember(notification: notification.locationNotificationModel);
      } else if ((notification.locationNotificationModel.isAccepted) &&
          (!notification.locationNotificationModel.isExited)) {
        SendLocationNotification()
            .addMember(notification: notification.locationNotificationModel);
      }
    } else if ((notification.notificationType == NotificationType.Event)) {
      var _getLocationModelFromEventModel =
          getLocationModelFromEventModel(notification);
      if (_getLocationModelFromEventModel != null
          // &&
          //     _getLocationModelFromEventModel.length > 0
          ) {
        SendLocationNotification()
            .addMember(notification: _getLocationModelFromEventModel);
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
    List<LocationNotificationModel> notificationList = [];
    String currentAtsign = BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;

    if (!notification.eventNotificationModel.isCancelled) {
      if (notification.eventNotificationModel.atsignCreator.toLowerCase() ==
          currentAtsign.toLowerCase()) {
        // TODO: Create only one key, with the same event key
        if (notification.eventNotificationModel.isSharing) {
          location = LocationNotificationModel()
            ..atsignCreator = notification.eventNotificationModel.atsignCreator
            ..isAcknowledgment = true
            ..isAccepted = true
            ..receiver = notification.eventNotificationModel.group.members
                .elementAt(0)
                .atSign; // Doesnt matter
          location = getLocationNotificationData(notification, location,
              isCreator: true);
          return location;
        }
      } else {
        AtContact currentGroupMember = new AtContact();
        notification.eventNotificationModel.group.members
            .forEach((groupMember) {
          // find current group member
          if (groupMember.atSign == currentAtSign) {
            currentGroupMember = groupMember;
          }
        });

        if (currentGroupMember != null &&
            currentGroupMember.tags['isAccepted'] == true &&
            currentGroupMember.tags['isSharing'] == true &&
            currentGroupMember.tags['isExited'] == false) {
          // TODO: Create only one key, with creator as the receiver
          //
          location = LocationNotificationModel()
            ..atsignCreator = currentGroupMember.atSign
            ..isAcknowledgment = true
            ..isAccepted = true
            ..receiver = notification.eventNotificationModel.atsignCreator;
          location = getLocationNotificationData(notification, location);
          return location;
        }
      }
    }
    return null;
  }
}
