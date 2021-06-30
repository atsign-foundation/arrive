import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/location_notification_listener.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/view_models/base_model.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart'
    as newKeyLocationmodel;
import 'package:flutter/material.dart';

class LocationProvider extends BaseModel {
  LocationProvider();
  List<HybridNotificationModel> allLocationNotifications = [];
  // ignore: non_constant_identifier_names
  String GET_ALL_NOTIFICATIONS = 'get_all_notifications';

  void init(AtClientImpl atClient, String activeAtSign,
      GlobalKey<NavigatorState> navKey) {
    initializeLocationService(
      atClient, activeAtSign, navKey,
      mapKey: MixedConstants.MAP_KEY,
      apiKey: MixedConstants.API_KEY,
      // getAtValue: LocationNotificationListener().getAtValue
      streamAlternative: notificationUpdate,
    );

    setStatus(GET_ALL_NOTIFICATIONS, Status.Done);

    print('Out Event ');

    KeyStreamService().atNotificationsController.stream.listen((event) {
      setStatus(GET_ALL_NOTIFICATIONS, Status.Loading);
      print('Event received $event');
      allLocationNotifications = [];

      event.forEach((notification) {
        var _hybridNotificationModel = HybridNotificationModel(
            NotificationType.Location,
            locationNotificationModel: notification.locationNotificationModel,
            key: notification.key,
            atKey: notification.atKey,
            atValue: notification.atValue);
        allLocationNotifications.add(_hybridNotificationModel);
      });

      setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
    });
  }

  // ignore: always_declare_return_types
  notificationUpdate(List<newKeyLocationmodel.KeyLocationModel> list) {
    print('notificationUpdate');
    allLocationNotifications = [];

    list.forEach((notification) {
      var _hybridNotificationModel = HybridNotificationModel(
          NotificationType.Location,
          locationNotificationModel: notification.locationNotificationModel,
          key: notification.key,
          atKey: notification.atKey,
          atValue: notification.atValue);
      allLocationNotifications.add(_hybridNotificationModel);
    });

    setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
  }
}
