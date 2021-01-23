import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';

import 'base_model.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_events/models/event_notification.dart';
import 'dart:convert';

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
      AtKey atKey = AtKey.fromString(notification.key);
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
        allNotifications[i].atValue = value;
      }
    }

    convertJsonToEventModel();
    setStatus(GET_ALL_EVENTS, Status.Done);

    checkForAcknowledgeEvents();
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
    for (int i = 0; i < allNotifications.length; i++) {
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
      }
    }
    // allNotifications.sort((a, b) => b.eventNotificationModel.event.date
    //     .compareTo(a.eventNotificationModel.event.date));
  }

  actionOnEvent(EventNotificationModel event, ATKEY_TYPE_ENUM keyType,
      {bool isAccepted, bool isSharing, bool isExited}) async {
    setStatus(UPDATE_EVENTS, Status.Loading);

    EventNotificationModel eventData = EventNotificationModel.fromJson(
        jsonDecode(
            EventNotificationModel.convertEventNotificationToJson(event)));

    try {
      String atkeyMicrosecondId =
          eventData.key.split('createevent-')[1].split('@')[0];

      String currentAtsign = ClientSdkService.getInstance()
          .atClientServiceInstance
          .atClient
          .currentAtSign;

      eventData.group.members.forEach((member) {
        if (member.atSign == currentAtsign) {
          member.tags['isAccepted'] =
              isAccepted != null ? isAccepted : member.tags['isAccepted'];
          member.tags['isSharing'] =
              isSharing != null ? isSharing : member.tags['isSharing'];
          member.tags['isExited'] =
              isExited != null ? isExited : member.tags['isExited'];
        }
      });

      AtKey key = formAtKey(
          keyType, atkeyMicrosecondId, eventData.atsignCreator, currentAtsign);

      // print('acknowledged data:${notification}');

      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);

      // print('acknowledged data:${notification}');

      var result = await atClientInstance.put(key, notification);
      // updateEventAccordingToAcknowledgedData();

      setStatus(UPDATE_EVENTS, Status.Done);
    } catch (e) {
      print('error in updating event $e');
      setStatus(UPDATE_EVENTS, Status.Error);
    }
  }

  AtKey formAtKey(ATKEY_TYPE_ENUM keyType, String atkeyMicrosecondId,
      String sharedWith, String sharedBy) {
    AtKey key = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..sharedWith = sharedWith
      ..sharedBy = sharedBy;

    switch (keyType) {
      case ATKEY_TYPE_ENUM.CREATEEVENT:
        key.key = 'createevent-$atkeyMicrosecondId';
        return key;
        break;

      case ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT:
        key.key = 'eventacknowledged-$atkeyMicrosecondId';
        return key;
        break;
    }
  }

  checkForAcknowledgeEvents() {
    providerCallback<EventProvider>(NavService.navKey.currentContext,
        task: (provider) => provider.updateEventAccordingToAcknowledgedData(),
        taskName: (provider) => provider.CHECK_ACKNOWLEDGED_EVENT,
        showLoader: false,
        onSuccess: (provider) {});
  }

  updateEventAccordingToAcknowledgedData() async {
    // List<String> allEventKey = await atClientInstance.getKeys(
    //   regex: 'createevent-',
    //   // sharedWith: '@test_ga3',
    //   // sharedBy: '@test_ga3',
    // );
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

//
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
            AtKey acknowledgedAtKey = AtKey.fromString(allRegexResponses[j]);
            AtKey createEventAtKey = AtKey.fromString(allNotifications[i].key);

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
                  // print(
                  // 'not matched : value changed :${acknowledgedEvent.title} , ${acknowledgedEvent.group.members}');
                  acknowledgedEvent.isUpdate = true;

                  var updateResult =
                      await updateEvent(acknowledgedEvent, createEventAtKey);
                  if (updateResult is bool && updateResult == true)
                    mapUpdatedEventDataToWidget(acknowledgedEvent);
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
    setStatus(MAP_UPDATED_EVENTS, Status.Loading);
    String newEventDataKeyId =
        eventData.key.split('createevent-')[1].split('@')[0];

    for (int i = 0; i < allNotifications.length; i++) {
      if (allNotifications[i]
          .eventNotificationModel
          .key
          .contains(newEventDataKeyId)) {
        allNotifications[i].eventNotificationModel = eventData;
      }
    }
    setStatus(MAP_UPDATED_EVENTS, Status.Done);
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
        AtKey key = AtKey.fromString(response[0]);
        updateEvent(eventData, key);
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
      return e.toString();
    }
  }
}

enum ATKEY_TYPE_ENUM { CREATEEVENT, ACKNOWLEDGEEVENT }
