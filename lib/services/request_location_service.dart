import 'dart:convert';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:provider/provider.dart';
import 'package:atsign_location_app/common_components/dialog_box/location_prompt_dialog.dart';

import 'nav_service.dart';

class RequestLocationService {
  static final RequestLocationService _singleton =
      RequestLocationService._internal();
  RequestLocationService._internal();

  factory RequestLocationService() {
    return _singleton;
  }

  checkForAlreadyExisting(String atsign) {
    int index = Provider.of<HybridProvider>(NavService.navKey.currentContext,
            listen: false)
        .allRequestNotifications
        .indexWhere((e) => ((e.locationNotificationModel.receiver == atsign)));
    if (index > -1) {
      return [
        true,
        Provider.of<HybridProvider>(NavService.navKey.currentContext,
                listen: false)
            .allRequestNotifications[index]
            .locationNotificationModel
      ];
    } else
      return [false];
  }

  sendRequestLocationEvent(String atsign) async {
    try {
      var alreadyExists = checkForAlreadyExisting(atsign);
      var result;
      // if (alreadyExists[0]) {
      //   LocationNotificationModel newLocationNotificationModel =
      //       LocationNotificationModel.fromJson(jsonDecode(
      //           LocationNotificationModel.convertLocationNotificationToJson(
      //               alreadyExists[1])));

      //   newLocationNotificationModel.to =
      //       DateTime.now().add(Duration(minutes: minutes));

      //   await locationPromptDialog(
      //       text:
      //           'You already are sharing your location with $atsign. Would you like to update it ?',
      //       locationNotificationModel: newLocationNotificationModel,
      //       isShareLocationData: true,
      //       isRequestLocationData: false,
      //       yesText: 'Yes! Update',
      //       noText: 'No');
      //   return null;
      // }

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

      result = await BackendService.getInstance()
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

      atKey = newAtKey(
        60000,
        "requestlocationacknowledged-$atkeyMicrosecondId",
        locationNotificationModel.receiver,
      );

      LocationNotificationModel ackLocationNotificationModel =
          LocationNotificationModel()
            ..atsignCreator = locationNotificationModel.atsignCreator
            ..key = locationNotificationModel.key
            ..isRequest = true
            ..receiver = locationNotificationModel.receiver
            ..isAccepted = isAccepted
            ..isExited = !isAccepted;

      if (isSharing != null) ackLocationNotificationModel.isSharing = isSharing;

      if (isAccepted && (minutes != null)) {
        ackLocationNotificationModel.from = DateTime.now();
        ackLocationNotificationModel.to =
            DateTime.now().add(Duration(minutes: minutes));
      }

      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(
              atKey,
              LocationNotificationModel.convertLocationNotificationToJson(
                  ackLocationNotificationModel));
      print('requestLocationAcknowledgment $result');
      if (result) {
        if (result) {
          providerCallback<HybridProvider>(NavService.navKey.currentContext,
              task: (provider) => provider.updatePendingStatus(
                  BackendService.getInstance().convertEventToHybrid(
                      NotificationType.Location,
                      locationNotificationModel: ackLocationNotificationModel)),
              taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
              showLoader: false,
              onSuccess: (provider) {});
        }

        //  We have added this here, so that we need not wait for the updated data from the creator
        if (isSharing)
          Provider.of<HybridProvider>(NavService.navKey.currentContext,
                  listen: false)
              .addMemberToSendingLocationList(BackendService.getInstance()
                  .convertEventToHybrid(NotificationType.Location,
                      locationNotificationModel: ackLocationNotificationModel));
        else
          Provider.of<HybridProvider>(NavService.navKey.currentContext,
                  listen: false)
              .removeLocationSharing(ackLocationNotificationModel.key);
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
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('requestlocation-')[1]
          .split('@')[0];

      List<String> response = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .getKeys(
            regex: 'requestlocation-$atkeyMicrosecondId',
          );

      AtKey key = BackendService.getInstance().getAtKey(response[0]);

      if ((locationNotificationModel.isAccepted) &&
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
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {});

      print('update result - $result');
      return result;
    } catch (e) {
      print('error in updateWithRequestLocationAcknowledge $e');
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
  }

  sendDeleteAck(LocationNotificationModel locationNotificationModel) async {
    String atkeyMicrosecondId = locationNotificationModel.key
        .split('requestlocation-')[1]
        .split('@')[0];
    AtKey atKey;
    atKey = newAtKey(
      60000,
      "deleterequestacklocation-$atkeyMicrosecondId",
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
    return result;
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

    AtKey key = BackendService.getInstance().getAtKey(response[0]);

    locationNotificationModel.isAcknowledgment = true;

    var result = await BackendService.getInstance()
        .atClientServiceInstance
        .atClient
        .delete(key);
    print('$key delete operation $result');

    if (result) {
      providerCallback<HybridProvider>(NavService.navKey.currentContext,
          task: (provider) => provider.removePerson(key.key),
          taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
          showLoader: false,
          onSuccess: (provider) {});
    }
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
