import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:provider/provider.dart';

import 'nav_service.dart';

class RequestLocationService {
  static final RequestLocationService _singleton =
      RequestLocationService._internal();
  RequestLocationService._internal();

  factory RequestLocationService() {
    return _singleton;
  }

  sendRequestLocationEvent(String atsign) async {
    try {
      AtKey atKey = newAtKey(60000,
          "requestlocation-${DateTime.now().microsecondsSinceEpoch}", atsign);

      LocationNotificationModel locationNotificationModel =
          LocationNotificationModel()
            ..atsignCreator = atsign
            ..key = atKey.key
            ..isRequest = true
            ..receiver = BackendService.getInstance()
                .atClientServiceInstance
                .atClient
                .currentAtSign;

      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(
              atKey,
              LocationNotificationModel.convertLocationNotificationToJson(
                  locationNotificationModel));
      print('requestLocationNotification:$result');
      return [result, locationNotificationModel];
    } catch (e) {
      print(e);
      return [false];
    }
  }

  requestLocationAcknowledgment(
      LocationNotificationModel locationNotificationModel, bool isAccepted,
      {int minutes, bool isSharing}) async {
    try {
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('requestlocation-')[1]
          .split('@')[0];
      AtKey atKey;
      // if (minutes != null)
      //   atKey = newAtKey(
      //       60000,
      //       "requestlocationacknowledged-$atkeyMicrosecondId",
      //       locationNotificationModel.receiver,
      //       ttl: (minutes * 60000));
      // else
      atKey = newAtKey(
        60000,
        "requestlocationacknowledged-$atkeyMicrosecondId",
        locationNotificationModel.receiver,
      );

      locationNotificationModel
        ..isAccepted = isAccepted
        ..isExited = !isAccepted
        ..lat = isAccepted ? 12 : 0
        ..long = isAccepted ? 12 : 0;

      if (isSharing != null) locationNotificationModel.isSharing = isSharing;

      if (isAccepted && (minutes != null)) {
        // if error => remove this (minutes != null)
        locationNotificationModel.from = DateTime.now();
        locationNotificationModel.to =
            DateTime.now().add(Duration(minutes: minutes));
      }

      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(
              atKey,
              LocationNotificationModel.convertLocationNotificationToJson(
                  locationNotificationModel));
      print('requestLocationAcknowledgment $result');
      if ((result) && (!isSharing)) {
        Provider.of<HybridProvider>(NavService.navKey.currentContext,
                listen: false)
            .removeLocationSharing(locationNotificationModel);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  updateWithRequestLocationAcknowledge(
    LocationNotificationModel locationNotificationModel,
  ) async {
    try {
      // dont use the locationNotificationModel sent with reuqest acknowledgment
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('requestlocation-')[1]
          .split('@')[0];

      List<String> response = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .getKeys(
            regex: 'requestlocation-$atkeyMicrosecondId',
            // sharedBy: BackendService.getInstance()
            //     .atClientServiceInstance
            //     .atClient
            //     .currentAtSign
          );

      AtKey key = AtKey.fromString(response[0]);

      if (locationNotificationModel.isAccepted) {
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

      locationNotificationModel.isAcknowledgment = true;

      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel);
      var result;
      result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(key, notification);

      if (result)
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.mapUpdatedData(
                BackendService.getInstance().convertEventToHybrid(
                    NotificationType.Location,
                    locationNotificationModel: locationNotificationModel),
                remove: false),
            // as i requested so i wont remove this notification irrespective of yes/no
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {});

      print('update result - $result');
      return result;
    } catch (e) {
      return false;
    }
  }

  removePerson(LocationNotificationModel locationNotificationModel) async {
    var result;
    if (locationNotificationModel.atsignCreator !=
        BackendService.getInstance()
            .atClientServiceInstance
            .atClient
            .currentAtSign) {
      locationNotificationModel.isAccepted = false;
      locationNotificationModel.isExited = true;
      result =
          await updateWithRequestLocationAcknowledge(locationNotificationModel);
    } else {
      result =
          await requestLocationAcknowledgment(locationNotificationModel, false);
    }
    return result;
    // print('remove person called Request');
  }

  sendDeleteAck(LocationNotificationModel locationNotificationModel) async {
    String atkeyMicrosecondId = locationNotificationModel.key
        .split('requestlocation-')[1]
        .split('@')[0];
    AtKey atKey;
    atKey = newAtKey(
      60000,
      "deleterequestlocation-$atkeyMicrosecondId",
      locationNotificationModel.receiver,
    );

    var result = await BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(
                locationNotificationModel));
    print('requestLocationAcknowledgment $result');
  }

  deleteKey(LocationNotificationModel locationNotificationModel) async {
    String atkeyMicrosecondId = locationNotificationModel.key
        .split('requestlocation-')[1]
        .split('@')[0];

    List<String> response = await BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .getKeys(
          regex: 'requestlocation-$atkeyMicrosecondId',
        );

    AtKey key = AtKey.fromString(response[0]);

    locationNotificationModel.isAcknowledgment = true;

    var result = await BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .delete(key);
    return result;
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
