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
    print('current atsign:${currentAtSign}');
    List<String> response = await atClientInstance.getKeys(
      regex: 'eventnotify-',
      // sharedWith: 'baila82brilliant',
      // sharedBy: '@test_ga3',
    );

    print('responses:${response}');

    if (response.length == 0) {
      setStatus(GET_ALL_EVENTS, Status.Done);
      return;
    }

    //need to confirm about filteration based on regex key.
    response.forEach((element) {
      if ('@${element.split('@')[element.split('@').length - 1]}' ==
          currentAtSign) {
        allKeys.add(element);
      }
    });

    allKeys.forEach((element) {
      AtKey key = AtKey.fromString(element);
      allAtkeys.add(key);
    });

    for (int i = 0; i < allAtkeys.length; i++) {
      AtValue value = await getAtValue(allAtkeys[i]);
      if (value != null) {
        allAtValues.add(value);
      }
    }

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
    allAtValues.forEach((atvalue) {
      if (atvalue.value != 'null' && atvalue.value != null) {
        EventNotificationModel event =
            EventNotificationModel.fromJson(jsonDecode(atvalue.value));
        if (event != null && event.isCancelled == false) allEvents.add(event);
      }
    });
    print('all events:${allEvents}');
  }
}
