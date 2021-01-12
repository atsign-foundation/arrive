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
      regex: 'eventnotify-',
      // sharedWith: 'baila82brilliant',
      // sharedBy: '@test_ga3',
    );

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

    print('allKeys:${allKeys[allKeys.length - 1]}');

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

  updateEvent(EventNotificationModel eventData) async {
    setStatus(UPDATE_EVENTS, Status.Loading);
    // eventData.key =
    // 'cached:@test_ga3:eventnotify-1610435771773562@baila82brilliant';
    eventData.title = 'name chnaged';
    print(
        'key is accepted:${eventData.contactList[eventData.contactList.length - 1].isAccepted}');

    try {
      AtKey key = AtKey.fromString(eventData.key);
      print('key:${eventData.key}');
      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);
      var result = await atClientInstance.put(key, jsonEncode(notification));
      print('event updated:${result}, ${notification}');

      setStatus(UPDATE_EVENTS, Status.Done);
    } catch (e) {
      print('error in updating event $e');
      setStatus(UPDATE_EVENTS, Status.Error);
    }
  }
}
