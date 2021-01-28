import 'package:at_commons/at_commons.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';
import 'package:atsign_events/models/hybrid_notifiation_model.dart';

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

// before
// notification.value -> AtValue{value: {"atsignCreator":"@bob🛠","receiver":"@colin🛠","lat":"null","long":"null","key":"requestlocation-1611818639695437","from":"null","to":"null","isAcknowledgment":"false","isRequest":"true","isAccepted":"false","isExited":"false","updateMap":"false","isSharing":"true"}, metadata: Metadata{ttl: null, ttb: null, ttr: -1,ccd: false, isPublic: false, isHidden: false, availableAt : null, expiresAt : null, refreshAt : null, createdAt : 2021-01-28 07:29:27.380Z,updatedAt : 2021-01-28 07:29:27.380Z,isBinary : null, isEncrypted : null, isCached : false, dataSignature: null}}
// @colin🛠:requestlocationacknowledged-1611818639695437@bob🛠 => 30 min from 1:03pm

//
// @bob🛠:requestlocation-1611818478179344@colin🛠 => ttl 1:17:36
  requestLocationAcknowledgment(
      LocationNotificationModel locationNotificationModel, bool isAccepted,
      {int minutes}) async {
    String atkeyMicrosecondId = locationNotificationModel.key
        .split('requestlocation-')[1]
        .split('@')[0];
    AtKey atKey;
    if (minutes != null)
      atKey = newAtKey(-1, "requestlocationacknowledged-$atkeyMicrosecondId",
          locationNotificationModel.receiver,
          ttl: DateTime.now()
              .add(Duration(minutes: minutes))
              .microsecondsSinceEpoch);
    else
      atKey = newAtKey(
        -1,
        "requestlocationacknowledged-$atkeyMicrosecondId",
        locationNotificationModel.receiver,
      );

    locationNotificationModel
      ..isAccepted = isAccepted
      ..isExited = !isAccepted
      ..lat = isAccepted ? 12 : 0
      ..long = isAccepted ? 12 : 0;
    //..updateMap = true;

    if (isAccepted) {
      locationNotificationModel.from = DateTime.now();
      locationNotificationModel.to =
          DateTime.now().add(Duration(minutes: minutes));
    }

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

    if (locationNotificationModel.isAccepted) {
      key.metadata.ttl = locationNotificationModel.to.microsecondsSinceEpoch;
      key.metadata.expiresAt = locationNotificationModel.to;
    }

    locationNotificationModel.isAcknowledgment = true;

    var notification =
        LocationNotificationModel.convertLocationNotificationToJson(
            locationNotificationModel);
    var result;
    result = await ClientSdkService.getInstance()
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
  }

  AtKey newAtKey(int ttr, String key, String sharedWith,
      {int ttl, DateTime expiresAt}) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = ClientSdkService.getInstance()
          .atClientServiceInstance
          .atClient
          .currentAtSign;
    if (ttl != null) atKey.metadata.ttl = ttl;
    if (expiresAt != null) atKey.metadata.expiresAt = expiresAt;

    return atKey;
  }
}
