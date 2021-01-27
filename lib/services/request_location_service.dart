import 'package:at_commons/at_commons.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';

import 'client_sdk_service.dart';
import 'nav_service.dart';

class RequestLocationService {
  static final RequestLocationService _singleton =
      RequestLocationService._internal();
  RequestLocationService._internal();

  factory RequestLocationService() {
    return _singleton;
  }

  sendRequestLocationEvent(String atsign) async {
    AtKey atKey = newAtKey(
        10, "requestlocation-${DateTime.now().microsecondsSinceEpoch}", atsign);

    LocationNotificationModel locationNotificationModel =
        LocationNotificationModel()
          ..atsignCreator = atsign
          ..key = atKey.key
          ..isRequest = true
          ..receiver = ClientSdkService.getInstance()
              .atClientServiceInstance
              .atClient
              .currentAtSign;

    var result = await ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(
                locationNotificationModel));
    print('requestLocationNotification:$result');
    return [result, locationNotificationModel];
  }

  requestLocationAcknowledgment(
      LocationNotificationModel locationNotificationModel,
      bool isAccepted) async {
    String atkeyMicrosecondId = locationNotificationModel.key
        .split('requestlocation-')[1]
        .split('@')[0];
    AtKey atKey = newAtKey(
        -1,
        "requestlocationacknowledged-$atkeyMicrosecondId",
        locationNotificationModel.receiver);

    // locationNotificationModel.isAccepted = isAccepted;

    // if (!isAccepted) locationNotificationModel.isExited = true;

    locationNotificationModel
      ..isAccepted = isAccepted
      ..isExited = !isAccepted
      ..lat = isAccepted ? 12 : 0
      ..long = isAccepted ? 12 : 0;
    //..updateMap = true;

    var result = await ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(
                locationNotificationModel));
    print('requestLocationAcknowledgment $result');
    return result;
  }

  // sendShareLocationForRequest(
  //     LocationNotificationModel locationNotificationModel, AtKey key) async {
  //   var result = await ClientSdkService.getInstance()
  //       .atClientServiceInstance
  //       .atClient
  //       .put(
  //           key,
  //           LocationNotificationModel.convertLocationNotificationToJson(
  //               locationNotificationModel));
  //   if (result)
  //     providerCallback<ShareLocationProvider>(NavService.navKey.currentContext,
  //         task: (provider) => provider.addDataToList(locationNotificationModel),
  //         taskName: (provider) => provider.ADD_EVENT,
  //         showLoader: false,
  //         onSuccess: (provider) {});
  //   return [result, locationNotificationModel];
  // }

  updateWithRequestLocationAcknowledge(
    LocationNotificationModel locationNotificationModel,
  ) async {
    // dont use the locationNotificationModel sent with reuqest acknowledgment
    String atkeyMicrosecondId = locationNotificationModel.key
        .split('requestlocation-')[1]
        .split('@')[0];

    List<String> response = await ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .getKeys(
          regex: 'requestlocation-$atkeyMicrosecondId',
          // sharedBy: ClientSdkService.getInstance()
          //     .atClientServiceInstance
          //     .atClient
          //     .currentAtSign
        );

    AtKey key = AtKey.fromString(response[0]);

    locationNotificationModel.isAcknowledgment = true;

    var notification =
        LocationNotificationModel.convertLocationNotificationToJson(
            locationNotificationModel);
    var result;
    result = await ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .put(key, notification);
    // if ((locationNotificationModel.isAccepted == false) &&
    //     (locationNotificationModel.isExited == true)) {
    //   result = await ClientSdkService.getInstance()
    //       .atClientServiceInstance
    //       .atClient
    //       .put(key, notification);
    // } else if ((locationNotificationModel.isAccepted == true) &&
    //     (locationNotificationModel.isExited == false)) {
    //   result = await ClientSdkService.getInstance()
    //       .atClientServiceInstance
    //       .atClient
    //       .put(key, notification);
    //   // result = await ClientSdkService.getInstance()
    //   //     .atClientServiceInstance
    //   //     .atClient
    //   //     .delete(key);
    // }

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
  }

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
