import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart'
    as newKeyLocationmodel;

class EventAndLocationHybrid {
  NotificationModelType type;
  newKeyLocationmodel.KeyLocationModel locationKeyModel;
  EventKeyLocationModel eventKeyModel;

  EventAndLocationHybrid(this.type,
      {this.locationKeyModel, this.eventKeyModel});
}

enum NotificationModelType { LocationModel, EventModel }
