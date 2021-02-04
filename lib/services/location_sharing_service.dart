import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'backend_service.dart';
import 'client_sdk_service.dart';
import 'package:atsign_events/models/hybrid_notifiation_model.dart';

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

  // for shared locations
  sendShareLocationEvent(String atsign, bool isAcknowledgment,
      {int minutes}) async {
    try {
      AtKey atKey;
      if (minutes != null)
        atKey = newAtKey(60000,
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
            ..atsignCreator = ClientSdkService.getInstance()
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
      var result = await ClientSdkService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(
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
    } catch (e) {
      return [false];
    }
  }

//@test_ga4:sharelocation-1611151935211511@mixedmartialartsexcess
  //update ShareLocation Event When Accepted/Rejected
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
      if (!isAccepted) locationNotificationModel.isExited = true;
      print(
          'locationNotificationModel.isExited ${locationNotificationModel.isExited}');
      print(
          'after convertLocationNotificationToJson -> ${locationNotificationModel.isAccepted}');
      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel);

      var result = await ClientSdkService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(atKey, notification);
      print('sendLocationNotificationAcknowledgment:$result');
      print(
          'sendLocationNotificationAcknowledgment -> ${locationNotificationModel.isAccepted}');
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

      List<String> response = await ClientSdkService.getInstance()
          .atClientServiceInstance
          .atClient
          .getKeys(
            regex: 'sharelocation-$atkeyMicrosecondId',
          );

      AtKey key = AtKey.fromString(response[0]);

      locationNotificationModel.isAcknowledgment = true;

      if (isSharing != null) locationNotificationModel.isSharing = isSharing;

      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel);

      var result = await ClientSdkService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(key, notification);
      if (result)
        BackendService.getInstance().mapUpdatedDataToWidget(
            BackendService.getInstance().convertEventToHybrid(
                NotificationType.Location,
                locationNotificationModel: locationNotificationModel));

      print('update result - $result');
      return result;
    } catch (e) {
      return false;
    }
  }

  removePerson(LocationNotificationModel locationNotificationModel) async {
    var result;
    if (locationNotificationModel.atsignCreator ==
        ClientSdkService.getInstance()
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

  //
  AtKey newAtKey(int ttr, String key, String sharedWith,
      {int ttl, DateTime expiresAt}) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = ttr
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
