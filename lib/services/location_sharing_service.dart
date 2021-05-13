import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/common_components/dialog_box/location_prompt_dialog.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:provider/provider.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';

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

  checkForAlreadyExisting(String atsign) {
    int index = Provider.of<HybridProvider>(NavService.navKey.currentContext,
            listen: false)
        .allShareLocationNotifications
        .indexWhere((e) => ((e.locationNotificationModel.receiver == atsign)));
    if (index > -1) {
      return [
        true,
        Provider.of<HybridProvider>(NavService.navKey.currentContext,
                listen: false)
            .allShareLocationNotifications[index]
            .locationNotificationModel
      ];
    } else
      return [false];
  }

  checkIfEventIsRejected(LocationNotificationModel locationNotificationModel) {
    if ((!locationNotificationModel.isAccepted) &&
        (locationNotificationModel.isExited)) {
      return true;
    }

    return false;
  }

  sendShareLocationEvent(String atsign, bool isAcknowledgment,
      {int minutes}) async {
    try {
      var alreadyExists = checkForAlreadyExisting(atsign);
      var result;
      if (alreadyExists[0]) {
        LocationNotificationModel newLocationNotificationModel =
            LocationNotificationModel.fromJson(jsonDecode(
                LocationNotificationModel.convertLocationNotificationToJson(
                    alreadyExists[1])));

        var isRejected = checkIfEventIsRejected(newLocationNotificationModel);

        newLocationNotificationModel.to =
            DateTime.now().add(Duration(minutes: minutes));

        if (isRejected) {
          newLocationNotificationModel.rePrompt = true;
        }

        String msg = isRejected
            ? 'Your share location request has been rejected by $atsign. Would you like to prompt them again & update your request ?'
            : 'You already are sharing your location with $atsign. Would you like to update it ?';

        await locationPromptDialog(
            text: msg,
            locationNotificationModel: newLocationNotificationModel,
            isShareLocationData: true,
            isRequestLocationData: false,
            yesText: isRejected ? 'Yes! Re-Prompt' : 'Yes! Update',
            noText: 'No');
        return null;
      }

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
      result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(
              atKey,
              LocationNotificationModel.convertLocationNotificationToJson(
                  locationNotificationModel),
              isDedicated: MixedConstants.isDedicated);

      if (result) {
        if (MixedConstants.isDedicated) {
          await BackendService.getInstance().syncWithSecondary();
        }
      }

      print('sendLocationNotification:$result');
      return [result, locationNotificationModel];
    } catch (e) {
      print("error in sendShareLocationEvent $e");
      return [false, e.toString()];
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

      LocationNotificationModel newLocationNotificationModel =
          LocationNotificationModel.fromJson(jsonDecode(
              LocationNotificationModel.convertLocationNotificationToJson(
                  locationNotificationModel)));
      newLocationNotificationModel.isAccepted = isAccepted;
      newLocationNotificationModel.isExited = !isAccepted;

      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              newLocationNotificationModel);

      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .put(atKey, notification, isDedicated: MixedConstants.isDedicated);
      print('sendLocationNotificationAcknowledgment:$result');

      if (result) {
        if (MixedConstants.isDedicated) {
          await BackendService.getInstance().syncWithSecondary();
        }
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.updatePendingStatus(
                BackendService.getInstance().convertEventToHybrid(
                    NotificationType.Location,
                    locationNotificationModel: newLocationNotificationModel)),
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {});
      }

      return result;
    } catch (e) {
      return e;
    }
  }

  updateWithShareLocationAcknowledge(
      LocationNotificationModel locationNotificationModel,
      {bool isSharing,
      bool rePrompt = false}) async {
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
      locationNotificationModel.rePrompt =
          rePrompt; // Dont show dialog box again

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
          .put(key, notification, isDedicated: MixedConstants.isDedicated);
      if (result) {
        if (MixedConstants.isDedicated) {
          await BackendService.getInstance().syncWithSecondary();
        }
        BackendService.getInstance().mapUpdatedDataToWidget(
            BackendService.getInstance().convertEventToHybrid(
                NotificationType.Location,
                locationNotificationModel: locationNotificationModel));
      }

      print('update result - $result');
      return result;
    } catch (e) {
      return e;
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
      locationNotificationModel.rePrompt = false; // Dont show dialog box again

      var result = await BackendService.getInstance()
          .atClientServiceInstance
          .atClient
          .delete(key, isDedicated: MixedConstants.isDedicated);
      if (result) {
        if (MixedConstants.isDedicated) {
          await BackendService.getInstance().syncWithSecondary();
        }
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
