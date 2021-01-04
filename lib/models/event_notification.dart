import 'dart:convert';

class EventNotificationModel {
  EventNotificationModel();
  List<String> contactList;
  String title;
  Venue venue;
  bool isRecurring;
  OneDayEvent oneDayEvent;
  RecurringEvent recurringEvent;
  EventNotificationModel.fromJson(Map<String, dynamic> data)
      : contactList =
            data['contactList'] != null ? data['contactList'].split(',') : null,
        title = data['title'] ?? '',
        venue = Venue.fromJson(jsonDecode(data['venue'])),
        isRecurring = data['isRecurring'] == 'true' ? true : false,
        oneDayEvent = data['oneDayEvent'] != null
            ? OneDayEvent.fromJson(jsonDecode(data['oneDayEvent']))
            : null,
        recurringEvent = data['recurringEvent'] != null
            ? RecurringEvent.fromJson(jsonDecode(data['recurringEvent']))
            : null;
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

class OneDayEvent {
  OneDayEvent();
  DateTime date, startTime, stopTime;
  OneDayEvent.fromJson(Map<String, dynamic> data)
      : date = DateTime.parse(data['date']),
        startTime = DateTime.parse(data['startTime']),
        stopTime = DateTime.parse(data['stopTime']);
}

class RecurringEvent {
  int repeatDuration;
  RepeatCycle repeatCycle;
  Week occursOn;
  DateTime startTime, stopTime;
  EndsOn endsOn;
  dynamic endEventOn;
  RecurringEvent.fromJson(Map<String, dynamic> data)
      : repeatDuration = int.parse(data['repeatDuration']) ?? -1,
        repeatCycle = (data['repeatCycle'] == RepeatCycle.WEEK.toString()
            ? RepeatCycle.WEEK
            : (data['repeatCycle'] == RepeatCycle.MONTH.toString()
                ? RepeatCycle.MONTH
                : (data['repeatCycle'] == RepeatCycle.YEAR.toString()
                    ? RepeatCycle.YEAR
                    : null))),
        occursOn = (data['repeatCycle'] == Week.SUNDAY.toString()
            ? Week.SUNDAY
            : (data['repeatCycle'] == Week.MONDAY.toString()
                ? Week.MONDAY
                : (data['repeatCycle'] == Week.TUESDAY.toString()
                    ? Week.TUESDAY
                    : (data['repeatCycle'] == Week.WEDNESDAY.toString()
                        ? Week.WEDNESDAY
                        : (data['repeatCycle'] == Week.THURSDAY.toString()
                            ? Week.THURSDAY
                            : (data['repeatCycle'] == Week.FRIDAY.toString()
                                ? Week.FRIDAY
                                : (data['repeatCycle'] ==
                                        Week.SATURDAY.toString()
                                    ? Week.SATURDAY
                                    : null))))))),
        startTime = DateTime.parse(data['startTime']),
        stopTime = DateTime.parse(data['stopTime']),
        endsOn = (data['repeatCycle'] == EndsOn.NEVER.toString()
            ? EndsOn.NEVER
            : (data['repeatCycle'] == EndsOn.ON.toString()
                ? EndsOn.ON
                : (data['repeatCycle'] == EndsOn.AFTER.toString()
                    ? EndsOn.AFTER
                    : null)));
}

enum RepeatCycle { WEEK, MONTH, YEAR }
enum Week { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY }
enum EndsOn { NEVER, ON, AFTER }
