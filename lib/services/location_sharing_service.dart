import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/send_location_notification.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';

import 'backend_service.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';

import 'nav_service.dart';

class LocationSharingService {
  static final LocationSharingService _singleton =
      LocationSharingService._internal();
  LocationSharingService._internal();

  factory LocationSharingService() {
    return _singleton;
  }

  sendShareLocationEvent(String atsign, bool isAcknowledgment,
      {int minutes}) async {
    try {
      AtKey atKey;
      if (minutes != null)
        atKey = newAtKey((minutes * 60000),
            "sharelocation-${DateTime.now().microsecondsSinceEpoch}", atsign,
            ttl: (minutes * 60000),
            expiresAt: DateTime.now().add(Duration(minutes: minutes)));
      else
        atKey = newAtKey(
          60000,
          "sharelocation-${DateTime.now().microsecondsSinceEpoch}",
          atsign,
        );

      LocationNotificationModel locationNotificationModel =
          LocationNotificationModel()
            ..atsignCreator = BackendService.getInstance()
                .atClientServiceInstance
                .atClient
                .currentAtSign
            ..key = atKey.key
            ..lat = 12
            ..long = 12
            ..receiver = atsign
            ..from = DateTime.now()
            ..isAcknowledgment = isAcknowledgment;

      if ((minutes != null))
        locationNotificationModel.to =
            DateTime.now().add(Duration(minutes: minutes));
      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(
              atKey,
              LocationNotificationModel.convertLocationNotificationToJson(
                  locationNotificationModel));

      print('sendLocationNotification:$result');
      return [result, locationNotificationModel];
    } catch (e) {
      print("error in sendShareLocationEvent $e");
      return [false];
    }
  }

  shareLocationAcknowledgment(
      bool isShareLocationAcknowledgment,
      LocationNotificationModel locationNotificationModel,
      bool isAccepted) async {
    try {
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('sharelocation-')[1]
          .split('@')[0];
      AtKey atKey = newAtKey(
          -1,
          isShareLocationAcknowledgment
              ? "sharelocationacknowledged-$atkeyMicrosecondId"
              : "requestlocationacknowledged-$atkeyMicrosecondId",
          locationNotificationModel.atsignCreator);
      locationNotificationModel.isAccepted = isAccepted;
      locationNotificationModel.isExited = !isAccepted;

      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel);

      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(atKey, notification);
      print('sendLocationNotificationAcknowledgment:$result');

      return result;
    } catch (e) {
      return false;
    }
  }

  updateWithShareLocationAcknowledge(
      LocationNotificationModel locationNotificationModel,
      {bool isSharing}) async {
    try {
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('sharelocation-')[1]
          .split('@')[0];

      List<String> response = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .getKeys(
            regex: 'sharelocation-$atkeyMicrosecondId',
          );

      AtKey key = BackendService.getInstance().getAtKey(response[0]);

      locationNotificationModel.isAcknowledgment = true;

      if (isSharing != null) locationNotificationModel.isSharing = isSharing;

      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel);

      if ((locationNotificationModel.from != null) &&
          (locationNotificationModel.to != null)) {
        key.metadata.ttl = locationNotificationModel.to
                .difference(locationNotificationModel.from)
                .inMinutes *
            60000;
        key.metadata.ttr = locationNotificationModel.to
                .difference(locationNotificationModel.from)
                .inMinutes *
            60000;
        key.metadata.expiresAt = locationNotificationModel.to;
      }
      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(key, notification);
      if (result) {
        BackendService.getInstance().mapUpdatedDataToWidget(
            BackendService.getInstance().convertEventToHybrid(
                NotificationType.Location,
                locationNotificationModel: locationNotificationModel));
      }

      print('update result - $result');
      return result;
    } catch (e) {
      return false;
    }
  }

  removePerson(LocationNotificationModel locationNotificationModel) async {
    var result;
    if (locationNotificationModel.atsignCreator ==
        BackendService.getInstance()
            .atClientServiceInstance
            .atClient
            .currentAtSign) {
      locationNotificationModel.isAccepted = false;
      locationNotificationModel.isExited = true;
      result =
          await updateWithShareLocationAcknowledge(locationNotificationModel);
    } else {
      result = await shareLocationAcknowledgment(
          true, locationNotificationModel, false);
    }
    return result;
  }

  deleteKey(LocationNotificationModel locationNotificationModel) async {
    try {
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('sharelocation-')[1]
          .split('@')[0];

      List<String> response = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .getKeys(
            regex: 'sharelocation-$atkeyMicrosecondId',
          );

      AtKey key = BackendService.getInstance().getAtKey(response[0]);

      locationNotificationModel.isAcknowledgment = true;

      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .delete(key);
      if (result) {
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.removePerson(key.key),
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {});
      }
      return result;
    } catch (e) {
      print('error in deleting key $e');
      return false;
    }
  }

  AtKey newAtKey(int ttr, String key, String sharedWith,
      {int ttl, DateTime expiresAt}) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = ttr
      ..metadata.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .currentAtSign;
    if (ttl != null) atKey.metadata.ttl = ttl;
    if (expiresAt != null) atKey.metadata.expiresAt = expiresAt;
    return atKey;
  }
}
