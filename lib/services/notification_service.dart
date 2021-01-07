import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/models/event_notification.dart';
import 'package:atsign_location_app/models/location_notification.dart';
import 'package:atsign_location_app/models/message_notification.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';

class NotificationService {
  static final NotificationService _singleton = NotificationService._internal();
  NotificationService._internal();

  factory NotificationService() {
    return _singleton;
  }

  sendMessageNotification(
    String content,
    bool acknowledged,
    DateTime timeStamp,
  ) async {
    AtKey atKey =
        newAtKey(-1, "${AllText().MSG_NOTIFY}/${DateTime.now()}", '@test_ga3');

    MessageNotificationModel messageNotificationModel =
        MessageNotificationModel()
          ..content = 'Hi'
          ..acknowledged = false
          ..timeStamp = DateTime.now();

    var result = await BackendService.getInstance().atClientInstance.put(
        atKey,
        MessageNotificationModel.convertMessageNotificationToJson(
            messageNotificationModel));
    print('send msg result:$result');
  }

  sendLocationNotification(double lat, double long) async {
    AtKey atKey = newAtKey(10, "${AllText().LOCATION_NOTIFY}}", '@test_ga3');

    LocationNotificationModel locationNotificationModel =
        LocationNotificationModel()
          ..lat = 12
          ..long = 12;

    var result = await BackendService.getInstance().atClientInstance.put(
        atKey,
        LocationNotificationModel.convertLocationNotificationToJson(
            locationNotificationModel));
    print('send msg result:$result');
  }

  sendEventNotification(
      List<String> contactList,
      String title,
      String label,
      double latitude,
      double longitude,
      DateTime startTime,
      DateTime endTime,
      bool isRecurring,
      {DateTime date,
      int repeatDuration,
      RepeatCycle repeatCycle,
      dynamic occursOn,
      EndsOn endsOn,
      dynamic endEventOn}) async {
    AtKey atKey = newAtKey(-1, "${AllText().EVENT_NOTIFY}/${DateTime.now()}",
        '@mixedmartialartsexcess');

    EventNotificationModel eventNotification = EventNotificationModel()
      ..contactList = ['@mixedmartialartsexcess', '@aa']
      ..title = 'my event'
      ..venue = Venue()
      ..venue.label = 'my current location'
      ..venue.latitude = 12
      ..venue.longitude = 10
      ..event = Event()
      ..event.isRecurring = true
      ..event.repeatDuration = 2
      ..event.date = DateTime.now()
      ..event.startTime = DateTime.now()
      ..event.endTime = DateTime.now()
      ..event.repeatCycle = RepeatCycle.WEEK
      ..event.occursOn = Week.FRIDAY
      ..event.endsOn = EndsOn.ON
      ..event.endEventOn = DateTime.now();

    var result = await BackendService.getInstance().atClientInstance.put(
        atKey,
        EventNotificationModel.convertEventNotificationToJson(
            eventNotification));
    print('send msg result:$result');
  }

  AtKey newAtKey(int ttr, String key, String sharedWith) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = ttr
      ..key = key
      ..sharedWith = sharedWith;
    return atKey;
  }
}
