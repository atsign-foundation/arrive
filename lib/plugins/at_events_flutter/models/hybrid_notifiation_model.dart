import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';

class HybridNotificationModel {
  NotificationType notificationType;
  EventNotificationModel eventNotificationModel;
  LocationNotificationModel locationNotificationModel;
  String key;
  AtKey atKey;
  AtValue atValue;
  HybridNotificationModel(this.notificationType,
      {this.eventNotificationModel,
      this.locationNotificationModel,
      this.key,
      this.atKey,
      this.atValue});
}

enum NotificationType { Location, Event }
