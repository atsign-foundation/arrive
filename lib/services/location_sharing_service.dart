import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:provider/provider.dart';

import 'backend_service.dart';
import 'client_sdk_service.dart';

// all the SDK related functions will happen here
class LocationSharingService {
  // when app starts
  // getAllRequestedEvents() {}
  // getAllSharedEvents() {}
  // //sendRequestLocationEvent
  // deleteRequestLocationEventWhenAccepted() {}
  // updateRequestLocationEventWhenRejected() {}

  // //sendShareLocationEvent
  // shareLocationAcknowledgmentEventWhenAccepted() {}
  // shareLocationAcknowledgmentEventWhenRejected() {}

  // functions
  // for requested locations

  static final LocationSharingService _singleton =
      LocationSharingService._internal();
  LocationSharingService._internal();

  factory LocationSharingService() {
    return _singleton;
  }
  sendRequestLocationEvent(String atsign) async {
    AtKey atKey = newAtKey(
        10, "requestlocation-${DateTime.now().microsecondsSinceEpoch}", atsign);

    LocationNotificationModel locationNotificationModel =
        LocationNotificationModel()
          ..atsignCreator = ClientSdkService.getInstance()
              .atClientServiceInstance
              .atClient
              .currentAtSign
          ..receiver = atsign;

    var result = await BackendService.getInstance().atClientInstance.put(
        atKey,
        LocationNotificationModel.convertLocationNotificationToJson(
            locationNotificationModel));
    print('requestLocationNotificationAcknowledgment:$result');
  }

  // for shared locations
  sendShareLocationEvent(String atsign, bool isAcknowledgment) async {
    AtKey atKey = newAtKey(
        -1, "sharelocation-${DateTime.now().microsecondsSinceEpoch}", atsign);

    LocationNotificationModel locationNotificationModel =
        LocationNotificationModel()
          ..atsignCreator = ClientSdkService.getInstance()
              .atClientServiceInstance
              .atClient
              .currentAtSign
          ..key = atKey.key
          ..lat = 12
          ..long = 12
          ..receiver = atsign
          ..isAcknowledgment = isAcknowledgment;

    var result = await BackendService.getInstance().atClientInstance.put(
        atKey,
        LocationNotificationModel.convertLocationNotificationToJson(
            locationNotificationModel));
    print('atKey $atKey');
    print(LocationNotificationModel.convertLocationNotificationToJson(
        locationNotificationModel));
    print('sendLocationNotification:$result');

    print(
        'sendLocationNotificationAcknowledgment -> ${locationNotificationModel.key}');
    return [result, locationNotificationModel];
  }

//@test_ga4:sharelocation-1611151935211511@mixedmartialartsexcess
  //update ShareLocation Event When Accepted/Rejected
  shareLocationAcknowledgment(
      bool isShareLocationAcknowledgment,
      LocationNotificationModel locationNotificationModel,
      bool isAccepted) async {
    print(locationNotificationModel.key.toString());
    String atkeyMicrosecondId =
        locationNotificationModel.key.split('sharelocation-')[1].split('@')[0];
    // int microsecondsSinceEpoch =
    //     int.parse(locationNotificationModel.key.split('-')[1]);
    // print('shareLocationAcknowledgment $microsecondsSinceEpoch');
    //.split('@')[0]);
    AtKey atKey = newAtKey(
        -1,
        isShareLocationAcknowledgment
            ? "sharelocationacknowledged-$atkeyMicrosecondId"
            : "requestlocationacknowledged-$atkeyMicrosecondId",
        locationNotificationModel.atsignCreator);
    locationNotificationModel.isAccepted = isAccepted;
    if (!isAccepted) locationNotificationModel.isExited = true;
    print(
        'after convertLocationNotificationToJson -> ${locationNotificationModel.isAccepted}');
    var notification =
        LocationNotificationModel.convertLocationNotificationToJson(
            locationNotificationModel);

    var result = await BackendService.getInstance()
        .atClientInstance
        .put(atKey, notification);
    print('sendLocationNotificationAcknowledgment:$result');
    print(
        'sendLocationNotificationAcknowledgment -> ${locationNotificationModel.isAccepted}');
    return result;
  }

  updateWithShareLocationAcknowledge(
    LocationNotificationModel locationNotificationModel,
  ) async {
    int microsecondsSinceEpoch =
        int.parse(locationNotificationModel.key.split('-')[1]);
    //.split('@')[0]);
    List<String> response = await ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .getKeys(
          regex: 'sharelocation-$microsecondsSinceEpoch',
        );

    AtKey key = AtKey.fromString(response[0]);

    locationNotificationModel.isAcknowledgment = true;
    print(
        'before convertLocationNotificationToJson -> ${locationNotificationModel.isAccepted}');

    var notification =
        LocationNotificationModel.convertLocationNotificationToJson(
            locationNotificationModel);
    print(
        'after convertLocationNotificationToJson -> ${locationNotificationModel.isAccepted}');

    print('notification:$notification');

    var result = await ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .put(key, notification);
    if (result)
      providerCallback<ShareLocationProvider>(NavService.navKey.currentContext,
          task: (provider) => provider
              .mapUpdatedLocationDataToWidget(locationNotificationModel),
          taskName: (provider) => provider.MAP_UPDATED_LOCATION_DATA,
          showLoader: false,
          onSuccess: (provider) {});

    print('update result - $result');
  }

  //
  AtKey newAtKey(int ttr, String key, String sharedWith) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = ClientSdkService.getInstance()
          .atClientServiceInstance
          .atClient
          .currentAtSign;
    return atKey;
  }
}

// reuqest location -> for event provider
// List<String> requestLocationResponse = await atClientInstance.getKeys(
//       regex: 'requestlocation-',
//       // sharedWith: '@test_ga3',
//     );

//     requestLocationResponse.forEach((key) {
//       if ('@${key.split(':')[0]}'.contains(currentAtSign)) {
//         HybridNotificationModel tempHyridNotificationModel =
//             HybridNotificationModel(NotificationType.Location, key: key);
//         allNotifications.add(tempHyridNotificationModel);
//         // allKeys.add(element);
//       }
//     });

//     allNotifications.forEach((notification) {
//       AtKey atKey = AtKey.fromString(notification.key);
//       notification.atKey = atKey;
//     });

//     for (int i = 0; i < allNotifications.length; i++) {
//       AtValue value = await getAtValue(allNotifications[i].atKey);
//       if (value != null) {
//         allNotifications[i].atValue = value;
//       }
//     }
//     convertJsonToLocationModel();
