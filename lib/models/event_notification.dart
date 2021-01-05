import 'dart:convert';

class EventNotificationModel {
  EventNotificationModel();
  List<String> contactList;
  String title;
  Venue venue;
  Event event;
  EventNotificationModel.fromJson(Map<String, dynamic> data)
      : contactList =
            data['contactList'] != null ? data['contactList'].split(',') : null,
        title = data['title'] ?? '',
        venue = Venue.fromJson(jsonDecode(data['venue'])),
        event = data['event'] != null
            ? Event.fromJson(jsonDecode(data['event']))
            : null;

  static String convertEventNotificationToJson(
      EventNotificationModel eventNotification) {
    var notification = json.encode({
      'title': eventNotification.title.toString(),
      'contactList': eventNotification.contactList.toString(),
      'venue': json.encode({
        'latitude': eventNotification.venue.latitude.toString(),
        'longitude': eventNotification.venue.longitude.toString(),
        'label': eventNotification.venue.label
      }),
      'event': json.encode({
        'isRecurring': true.toString(),
        'date': eventNotification.event.date.toString(),
        'startTime': eventNotification.event.startTime.toString(),
        'endTime': eventNotification.event.endTime.toString(),
        'repeatDuration': eventNotification.event.repeatDuration.toString(),
        'repeatCycle': eventNotification.event.repeatCycle.toString(),
        'occursOn': eventNotification.event.occursOn.toString(),
        'endsOn': eventNotification.event.endsOn.toString(),
        'endEventOn': eventNotification.event.endEventOn.toString(),
      })
    });
    return notification;
  }
}

class Venue {
  Venue();
  double latitude, longitude;
  String label;
  Venue.fromJson(Map<String, dynamic> data)
      : latitude = double.parse(data['latitude']) ?? 0,
        longitude = double.parse(data['longitude']) ?? 0,
        label = data['label'] ?? '';
}

class Event {
  Event();
  bool isRecurring;
  DateTime date, startTime, endTime; //one day event
  int repeatDuration;
  RepeatCycle repeatCycle;
  dynamic occursOn;
  EndsOn endsOn;
  dynamic endEventOn;
  Event.fromJson(Map<String, dynamic> data) {
    startTime = DateTime.parse(data['startTime']);
    endTime = DateTime.parse(data['endTime']);
    isRecurring = data['isRecurring'] == 'true' ? true : false;
    if (!isRecurring) {
      date = DateTime.parse(data['date']);
    } else {
      repeatDuration = int.parse(data['repeatDuration']) ?? -1;
      repeatCycle = (data['repeatCycle'] == RepeatCycle.WEEK.toString()
          ? RepeatCycle.WEEK
          : (data['repeatCycle'] == RepeatCycle.MONTH.toString()
              ? RepeatCycle.MONTH
              : null));
      switch (repeatCycle) {
        case RepeatCycle.WEEK:
          occursOn = (data['occursOn'] == Week.SUNDAY.toString()
              ? Week.SUNDAY
              : (data['occursOn'] == Week.MONDAY.toString()
                  ? Week.MONDAY
                  : (data['occursOn'] == Week.TUESDAY.toString()
                      ? Week.TUESDAY
                      : (data['occursOn'] == Week.WEDNESDAY.toString()
                          ? Week.WEDNESDAY
                          : (data['occursOn'] == Week.THURSDAY.toString()
                              ? Week.THURSDAY
                              : (data['occursOn'] == Week.FRIDAY.toString()
                                  ? Week.FRIDAY
                                  : (data['occursOn'] ==
                                          Week.SATURDAY.toString()
                                      ? Week.SATURDAY
                                      : null)))))));
          break;
        case RepeatCycle.MONTH:
          occursOn = int.parse(data['occursOn']);
          break;
      }
      endsOn = (data['endsOn'] == EndsOn.NEVER.toString()
          ? EndsOn.NEVER
          : (data['endsOn'] == EndsOn.ON.toString()
              ? EndsOn.ON
              : (data['endsOn'] == EndsOn.AFTER.toString()
                  ? EndsOn.AFTER
                  : null)));
      switch (endsOn) {
        case EndsOn.ON:
          endEventOn = DateTime.parse(data['endEventOn']);
          break;
        case EndsOn.AFTER:
          endEventOn = int.parse(data['endEventOn']);
          break;
        case EndsOn.NEVER:
          endEventOn = null;
          break;
      }
    }
  }
}

enum RepeatCycle { WEEK, MONTH }
enum Week { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY }
enum EndsOn { NEVER, ON, AFTER }
