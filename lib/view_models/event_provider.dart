import 'package:atsign_location_app/services/client_sdk_service.dart';

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

  AtClientImpl atClientInstance;
  String currentAtSign;
  List<String> allKeys = [];
  List<AtKey> allAtkeys = [];
  List<AtValue> allAtValues = [];
  List<EventNotificationModel> allEvents = [];

  init(AtClientImpl clientInstance) {
    atClientInstance = clientInstance;
    currentAtSign = atClientInstance.currentAtSign;
  }

  getAllEvents() async {
    setStatus(GET_ALL_EVENTS, Status.Loading);
    allKeys = [];
    allAtkeys = [];
    allAtValues = [];
    allEvents = [];
    List<String> response = await atClientInstance.getKeys(
      regex: 'createevent-',
      // sharedWith: '@test_ga3',
      // sharedBy: '@test_ga3',
    );

    print('all response =========>>>>>>>:${response}');

    await updateEventAccordingToAcknowledgedData();

    print('responses:${response} , ${response.length}');

    if (response.length == 0) {
      setStatus(GET_ALL_EVENTS, Status.Done);
      return;
    }

    //need to confirm about filteration based on regex key.
    response.forEach((element) {
      if ('@${element.split(':')[1]}'.contains(currentAtSign)) {
        allKeys.add(element);
      }
    });

    print('allKeys:${allKeys}');

    allKeys.forEach((element) {
      AtKey key = AtKey.fromString(element);
      allAtkeys.add(key);
    });

    // print('allAtkeys:${allAtkeys}');

    for (int i = 0; i < allAtkeys.length; i++) {
      AtValue value = await getAtValue(allAtkeys[i]);
      if (value != null) {
        allAtValues.add(value);
      }
    }

    // print('allAtValues:${allAtValues}');

    convertJsonToEventModel();
    setStatus(GET_ALL_EVENTS, Status.Done);
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
    for (int i = 0; i < allAtValues.length; i++) {
      if (allAtValues[i].value != 'null' && allAtValues[i].value != null) {
        if (jsonDecode(allAtValues[i].value).runtimeType != String) {
          EventNotificationModel event =
              EventNotificationModel.fromJson(jsonDecode(allAtValues[i].value));

          if (event != null &&
              event.isCancelled == false &&
              event.contactList.length > 0) {
            event.key = allKeys[i];
            // print(
            // 'for loop in event:${event.key}, ${event.title} , ${event.contactList[0].isAccepted}');
            allEvents.add(event);
          }
        }
      }
    }

    // print(
    // 'all events is accepted:${allEvents[allEvents.length - 1].contactList[0].isAccepted} , ${allEvents[allEvents.length - 1].key} : ${allEvents[allEvents.length - 1].title}');
  }

  actionOnEvent(EventNotificationModel eventData, ATKEY_TYPE_ENUM keyType,
      {bool isAccepted, bool isSharing, bool isExited}) async {
    setStatus(UPDATE_EVENTS, Status.Loading);

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

          print('is accepted updated:${member.tags['isAccepted']} ');
        }
      });

      AtKey key =
          formAtKey(keyType, atkeyMicrosecondId, eventData.atsignCreator);

      // print('acknowledged data:${notification}');

      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);

      print('acknowledged data:${notification}');

      var result = await atClientInstance.put(key, notification);
      print('event updated:${result}, ${notification}');

      setStatus(UPDATE_EVENTS, Status.Done);
    } catch (e) {
      print('error in updating event $e');
      setStatus(UPDATE_EVENTS, Status.Error);
    }
  }

  AtKey formAtKey(
      ATKEY_TYPE_ENUM keyType, String atkeyMicrosecondId, String sharedWith) {
    AtKey key = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..sharedWith = sharedWith;

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

  updateEventAccordingToAcknowledgedData() async {
    List<String> allEventKey = await atClientInstance.getKeys(
      regex: 'createevent-',
      // sharedWith: '@test_ga3',
      // sharedBy: '@test_ga3',
    );
    print('all event key:$allEventKey');
    List<String> allRegexResponses = [];
    for (int i = 0; i < allEventKey.length; i++) {
      allRegexResponses = [];
      String atkeyMicrosecondId =
          allEventKey[i].split('createevent-')[1].split('@')[0];
      String acknowledgedKeyId = 'eventacknowledged-$atkeyMicrosecondId';

      allRegexResponses =
          await atClientInstance.getKeys(regex: acknowledgedKeyId);
      print('all regex responses: $allRegexResponses');

      if (allRegexResponses.length > 0) {
        for (int j = 0; j < allRegexResponses.length; j++) {
          if (allRegexResponses[j] != null) {
            print('acknowledged key :${allRegexResponses[j]}');

            AtKey acknowledgedAtKey = AtKey.fromString(allRegexResponses[j]);
            AtKey createEventAtKey = AtKey.fromString(allEventKey[i]);
            print('atkey of acknowledged:$createEventAtKey');

            AtValue result = await atClientInstance
                .get(acknowledgedAtKey)
                .catchError((e) =>
                    print("error in get ${e.errorCode} ${e.errorMessage}"));
            print('acknowledged value - ${result.value}');

            EventNotificationModel acknowledgedEvent =
                EventNotificationModel.fromJson(jsonDecode(result.value));

            print(
                'updating main data:${acknowledgedEvent.group.members} , key used:${createEventAtKey}');

            // await actionOnEvent(acknowledgedEvent, ATKEY_TYPE_ENUM.CREATEEVENT);
            await updateEvent(acknowledgedEvent, createEventAtKey);
          }
        }
      }
    }
  }

  updateEvent(EventNotificationModel eventData, AtKey key) async {
    var notification =
        EventNotificationModel.convertEventNotificationToJson(eventData);

    var result = await atClientInstance.put(key, notification);
    print('event updated:${result}, ${notification}');
  }
}

enum ATKEY_TYPE_ENUM { CREATEEVENT, ACKNOWLEDGEEVENT }
