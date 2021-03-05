import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:flutter/material.dart';

import 'base_model.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'dart:convert';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';

class EventProvider extends BaseModel {
  EventProvider();

  // ignore: non_constant_identifier_names
  String GET_ALL_EVENTS = 'get_all_events';
  // ignore: non_constant_identifier_names
  String UPDATE_EVENTS = 'update_event';
  // ignore: non_constant_identifier_names
  String CHECK_ACKNOWLEDGED_EVENT = 'check_acknowledged_event';
  // ignore: non_constant_identifier_names
  String MAP_UPDATED_EVENTS = 'map_updated_event';

  // ignore: non_constant_identifier_names
  String GET_SINGLE_USER = 'get_single_user';

  AtClientImpl atClientInstance;
  String currentAtSign;
  List<HybridNotificationModel> allNotifications = [];

  init(AtClientImpl clientInstance) {
    print('event clientInstance $clientInstance');

    atClientInstance = clientInstance;
    currentAtSign = atClientInstance.currentAtSign;
  }

  getAllEvents() async {
    setStatus(GET_ALL_EVENTS, Status.Loading);

    allNotifications = [];

    List<String> response = await atClientInstance.getKeys(
      regex: 'createevent-',
    );

    if (response.length == 0) {
      setStatus(GET_ALL_EVENTS, Status.Done);
      return;
    }

    //need to confirm about filteration based on regex key.
    response.forEach((key) {
      if ('@${key.split(':')[1]}'.contains(currentAtSign)) {
        HybridNotificationModel tempHyridNotificationModel =
            HybridNotificationModel(NotificationType.Event, key: key);
        allNotifications.add(tempHyridNotificationModel);
        // allKeys.add(element);
      }
    });

    allNotifications.forEach((notification) {
      AtKey atKey = BackendService.getInstance().getAtKey(notification.key);
      notification.atKey = atKey;
    });

    // for (int i = 0; i < allAtkeys.length; i++) {
    //   AtValue value = await getAtValue(allAtkeys[i]);
    //   if (value != null) {
    //     allAtValues.add(value);
    //   }
    // }

    for (int i = 0; i < allNotifications.length; i++) {
      AtValue value = await getAtValue(allNotifications[i].atKey);
      if (value != null) {
        print('at value event $value');
        allNotifications[i].atValue = value;
      }
    }

    convertJsonToEventModel();

    setStatus(GET_ALL_EVENTS, Status.Done);

    updateEventDataAccordingToAcknowledgedData();
  }

  Future<dynamic> getAtValue(AtKey key) async {
    AtValue atvalue = await atClientInstance.get(key).catchError(
        (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));

    if (atvalue != null)
      return atvalue;
    else
      return null;
  }

  convertJsonToEventModel() {
    List<HybridNotificationModel> tempRemoveEventArray = [];

    for (int i = 0; i < allNotifications.length; i++) {
      try {
        if (allNotifications[i].atValue != 'null' &&
            allNotifications[i].atValue != null) {
          EventNotificationModel event = EventNotificationModel.fromJson(
              jsonDecode(allNotifications[i].atValue.value));

          if (event != null &&
              // event.isCancelled == false &&
              event.group.members.length > 0) {
            event.key = allNotifications[i].key;

            allNotifications[i].eventNotificationModel = event;
          }
        } else {
          tempRemoveEventArray.add(allNotifications[i]);
        }
      } catch (e) {
        tempRemoveEventArray.add(allNotifications[i]);
      }
    }

    allNotifications
        .removeWhere((element) => tempRemoveEventArray.contains(element));
    // allNotifications.sort((a, b) => b.eventNotificationModel.event.date
    //     .compareTo(a.eventNotificationModel.event.date));
  }

  actionOnEvent(EventNotificationModel event, ATKEY_TYPE_ENUM keyType,
      {bool isAccepted, bool isSharing, bool isExited}) async {
    setStatus(UPDATE_EVENTS, Status.Loading);

    EventNotificationModel eventData = EventNotificationModel.fromJson(
        jsonDecode(
            EventNotificationModel.convertEventNotificationToJson(event)));

    print('in action on event admin:${event.isSharing}');
    print(
        'in action on event member:${event.group.members.elementAt(0).tags['isSharing']}');

    try {
      String atkeyMicrosecondId =
          eventData.key.split('createevent-')[1].split('@')[0];

      String currentAtsign = BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .currentAtSign;

      if (eventData.atsignCreator.toLowerCase() ==
          currentAtsign.toLowerCase()) {
        eventData.isSharing =
            isSharing != null ? isSharing : eventData.isSharing;
      }

      eventData.group.members.forEach((member) {
        if (member.atSign[0] != '@') member.atSign = '@' + member.atSign;
        if (currentAtsign[0] != '@') currentAtsign = '@' + currentAtsign;

        if (member.atSign.toLowerCase() == currentAtsign.toLowerCase()) {
          member.tags['isAccepted'] =
              isAccepted != null ? isAccepted : member.tags['isAccepted'];
          member.tags['isSharing'] =
              isSharing != null ? isSharing : member.tags['isSharing'];
          member.tags['isExited'] =
              isExited != null ? isExited : member.tags['isExited'];
        }
      });

      AtKey key = formAtKey(keyType, atkeyMicrosecondId,
          eventData.atsignCreator, currentAtsign, event);

      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);

      print('notification data:${notification}');
      var result = await atClientInstance.put(key, notification);
      setStatus(UPDATE_EVENTS, Status.Done);

      // updateEventAccordingToAcknowledgedData();
      return result;
    } catch (e) {
      print('error in updating event $e');
      setStatus(UPDATE_EVENTS, Status.Error);
      return false;
    }
  }

  AtKey formAtKey(ATKEY_TYPE_ENUM keyType, String atkeyMicrosecondId,
      String sharedWith, String sharedBy, EventNotificationModel eventData) {
    switch (keyType) {
      case ATKEY_TYPE_ENUM.CREATEEVENT:
        AtKey atKey;
        List<HybridNotificationModel> allEventsNotfication =
            HomeEventService().getAllEvents;
        allEventsNotfication.forEach((event) {
          if (event.notificationType == NotificationType.Event &&
              event.key == eventData.key) {
            atKey = event.atKey;
            atKey.metadata.ttr = -1;
          }
        });
        return atKey;
        break;

      case ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT:
        AtKey key = AtKey()
          ..metadata = Metadata()
          ..metadata.ttr = -1
          ..sharedWith = sharedWith
          ..sharedBy = sharedBy;

        key.key = 'eventacknowledged-$atkeyMicrosecondId';
        return key;
        break;
    }
  }

  checkForAcknowledgeEvents() {
    providerCallback<EventProvider>(NavService.navKey.currentContext,
        task: (provider) =>
            provider.updateEventDataAccordingToAcknowledgedData(),
        taskName: (provider) => provider.CHECK_ACKNOWLEDGED_EVENT,
        showLoader: false,
        onSuccess: (provider) {});
  }

  updateEventDataAccordingToAcknowledgedData() async {
    List<String> allEventKey = [];
    List<String> response = await atClientInstance.getKeys(
      regex: 'createevent-',
    );

    if (response.length == 0) {
      // setStatus(CHECK_ACKNOWLEDGED_EVENT, Status.Done);
      return;
    }

    //need to confirm about filteration based on regex key.
    response.forEach((element) {
      if ('@${element.split(':')[1]}'.contains(currentAtSign)) {
        allEventKey.add(element);
      }
    });

    List<String> allRegexResponses = [];
    for (int i = 0; i < allNotifications.length; i++) {
      allRegexResponses = [];
      String atkeyMicrosecondId =
          allNotifications[i].key.split('createevent-')[1].split('@')[0];
      String acknowledgedKeyId = 'eventacknowledged-$atkeyMicrosecondId';

      allRegexResponses =
          await atClientInstance.getKeys(regex: acknowledgedKeyId);

      if (allRegexResponses.length > 0) {
        for (int j = 0; j < allRegexResponses.length; j++) {
          if (allRegexResponses[j] != null &&
              !allNotifications[i].key.contains('cached')) {
            AtKey acknowledgedAtKey =
                BackendService.getInstance().getAtKey(allRegexResponses[j]);
            AtKey createEventAtKey =
                BackendService.getInstance().getAtKey(allNotifications[i].key);

            AtValue result = await atClientInstance
                .get(acknowledgedAtKey)
                .catchError((e) =>
                    print("error in get ${e.errorCode} ${e.errorMessage}"));

            EventNotificationModel acknowledgedEvent =
                EventNotificationModel.fromJson(jsonDecode(result.value));
            EventNotificationModel storedEvent = new EventNotificationModel();

            String acknowledgedEventKeyId =
                acknowledgedEvent.key.split('createevent-')[1].split('@')[0];
            String evenetKeyId = 'createevent-$atkeyMicrosecondId';

            for (int k = 0; k < allNotifications.length; k++) {
              if (allNotifications[k]
                  .eventNotificationModel
                  .key
                  .contains(acknowledgedEventKeyId)) {
                storedEvent = allNotifications[k].eventNotificationModel;

                if (!compareEvents(storedEvent, acknowledgedEvent)) {
                  storedEvent.isUpdate = true;
                  storedEvent.group = acknowledgedEvent.group;

                  var updateResult =
                      await updateEvent(storedEvent, createEventAtKey);
                  print('ack data updated:${storedEvent.title}');
                  if (updateResult is bool && updateResult == true)
                    mapUpdatedEventDataToWidget(storedEvent);
                } else {
                  print('matched : no changes');
                }
              }
            }
          }
        }
      }
    }
  }

  mapUpdatedEventDataToWidget(EventNotificationModel eventData) {
    BackendService.getInstance().mapUpdatedDataToWidget(
        BackendService.getInstance().convertEventToHybrid(
            NotificationType.Event,
            eventNotificationModel: eventData));
  }

  bool compareEvents(
      EventNotificationModel eventOne, EventNotificationModel eventTwo) {
    if (eventOne.group.members.elementAt(0).tags['isAccepted'] ==
            eventTwo.group.members.elementAt(0).tags['isAccepted'] &&
        eventOne.group.members.elementAt(0).tags['isSharing'] ==
            eventTwo.group.members.elementAt(0).tags['isSharing'] &&
        eventOne.group.members.elementAt(0).tags['isExited'] ==
            eventTwo.group.members.elementAt(0).tags['isExited']) {
      return true;
    } else
      return false;
  }

  cancelEvent(EventNotificationModel event) async {
    EventNotificationModel eventData = EventNotificationModel.fromJson(
        jsonDecode(
            EventNotificationModel.convertEventNotificationToJson(event)));
    if (eventData.atsignCreator == currentAtSign && !eventData.isCancelled) {
      try {
        eventData.isCancelled = true;
        List<String> response = await atClientInstance.getKeys(
          regex: '${eventData.key}',
        );
        AtKey key = BackendService.getInstance().getAtKey(response[0]);
        bool result = await updateEvent(eventData, key);
        if (result) {
          BackendService.getInstance().mapUpdatedDataToWidget(
              BackendService.getInstance().convertEventToHybrid(
                  NotificationType.Event,
                  eventNotificationModel: eventData));
        }
      } catch (e) {
        print('error in cancelling event:$e');
      }
    }
  }

  Future<dynamic> updateEvent(
      EventNotificationModel eventData, AtKey key) async {
    try {
      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);

      var result = await atClientInstance.put(key, notification);
      if (result is bool) {
        print('updated:$result');
        return result;
      } else if (result != null) {
        return result.toString();
      } else
        return result;
    } catch (e) {
      print('error in updating notification:$e');
      return false;
    }
  }

  addDataToListEvent(EventNotificationModel eventNotificationModel) async {
    // setStatus(Add, Status.Loading);
    String newLocationDataKeyId, tempKey;
    newLocationDataKeyId =
        eventNotificationModel.key.split('createevent-')[1].split('@')[0];
    tempKey = 'createevent-$newLocationDataKeyId';
    List<String> key = [];

    key = await atClientInstance.getKeys(
      regex: tempKey,
      sharedBy: eventNotificationModel.atsignCreator,
    );

    HybridNotificationModel tempHyridNotificationModel =
        HybridNotificationModel(NotificationType.Event, key: key[0]);
    eventNotificationModel.key = key[0];
    //allRequestNotifications.add(tempHyridNotificationModel);
    tempHyridNotificationModel.atKey =
        BackendService.getInstance().getAtKey(key[0]);
    tempHyridNotificationModel.atValue =
        await getAtValue(tempHyridNotificationModel.atKey);
    tempHyridNotificationModel.eventNotificationModel = eventNotificationModel;
    allNotifications.add(tempHyridNotificationModel);
    // setStatus(ADD_REQUEST_EVENT, Status.Done);

    return tempHyridNotificationModel;
  }
}
