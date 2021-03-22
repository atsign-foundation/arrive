import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/services/backend_service.dart';

import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'base_model.dart';

class ShareLocationProvider extends EventProvider {
  ShareLocationProvider();
  AtClientImpl atClientInstance;
  String currentAtSign;
  List<HybridNotificationModel> allShareLocationNotifications = [];
  // ignore: non_constant_identifier_names
  String GET_ALL_EVENTS = 'get_all_events';
  // ignore: non_constant_identifier_names
  String CHECK_ACKNOWLEDGED_EVENT = 'check_acknowledged_event';
  // ignore: non_constant_identifier_names
  String ADD_EVENT = 'ADD_EVENT';
  // ignore: non_constant_identifier_names
  String MAP_UPDATED_LOCATION_DATA = 'map_updated_event';

  init(AtClientImpl clientInstance) {
    reset(GET_ALL_EVENTS);
    reset(ADD_EVENT);
    reset(CHECK_ACKNOWLEDGED_EVENT);
    reset(MAP_UPDATED_LOCATION_DATA);
    atClientInstance = clientInstance;
    currentAtSign = atClientInstance.currentAtSign;
    allShareLocationNotifications = [];
    super.init(clientInstance);
  }

  getSingleUserLocationSharing() async {
    setStatus(GET_ALL_EVENTS, Status.Loading);

    List<String> shareLocationResponse = await atClientInstance.getKeys(
      regex: 'sharelocation-',
    );

    if (shareLocationResponse.length == 0) {
      setStatus(GET_ALL_EVENTS, Status.Done);
      return;
    }

    shareLocationResponse.forEach((key) {
      if (('@${key.split(':')[1]}'.contains(currentAtSign)) ||
          ('@${key.split(':')[0]}'.contains(currentAtSign))) {
        HybridNotificationModel tempHyridNotificationModel =
            HybridNotificationModel(NotificationType.Location, key: key);
        allShareLocationNotifications.add(tempHyridNotificationModel);
      }
    });

    allShareLocationNotifications.forEach((notification) {
      AtKey atKey = BackendService.getInstance().getAtKey(notification.key);
      notification.atKey = atKey;
    });

    for (int i = 0; i < allShareLocationNotifications.length; i++) {
      AtValue value = await getAtValue(allShareLocationNotifications[i].atKey);
      if (value != null) {
        allShareLocationNotifications[i].atValue = value;
      }
    }
    convertJsonToLocationModel();

    filterData();
    setStatus(GET_ALL_EVENTS, Status.Done);
    checkForAcknowledge();
  }

  convertJsonToLocationModel() {
    for (int i = 0; i < allShareLocationNotifications.length; i++) {
      try {
        if ((allShareLocationNotifications[i].atValue.value != null) &&
            (allShareLocationNotifications[i].atValue.value != "null")) {
          LocationNotificationModel locationNotificationModel =
              LocationNotificationModel.fromJson(
                  jsonDecode(allShareLocationNotifications[i].atValue.value));
          allShareLocationNotifications[i].locationNotificationModel =
              locationNotificationModel;
        }
      } catch (e) {
        print('convertJsonToLocationModel:$e');
      }
    }
  }

  filterData() {
    List<HybridNotificationModel> tempArray = [];
    for (int i = 0; i < allShareLocationNotifications.length; i++) {
      // ignore: unrelated_type_equality_checks
      if ((allShareLocationNotifications[i].locationNotificationModel ==
              'null') ||
          (allShareLocationNotifications[i].locationNotificationModel ==
              null)) {
        tempArray.add(allShareLocationNotifications[i]);
      } else {
        if ((allShareLocationNotifications[i].locationNotificationModel.to !=
                null) &&
            (allShareLocationNotifications[i]
                    .locationNotificationModel
                    .to
                    .difference(DateTime.now())
                    .inMinutes <
                0)) tempArray.add(allShareLocationNotifications[i]);
      }
    }
    allShareLocationNotifications
        .removeWhere((element) => tempArray.contains(element));
  }

  checkForAcknowledge() {
    updateEventAccordingToAcknowledgedData();
  }

  updateEventAccordingToAcknowledgedData() async {
    setStatus(CHECK_ACKNOWLEDGED_EVENT, Status.Loading);

    allShareLocationNotifications.forEach((notification) async {
      if ((notification.locationNotificationModel.atsignCreator ==
              currentAtSign) &&
          (!notification.locationNotificationModel.isAcknowledgment)) {
        String atkeyMicrosecondId =
            notification.key.split('sharelocation-')[1].split('@')[0];
        String acknowledgedKeyId =
            'sharelocationacknowledged-$atkeyMicrosecondId';

        List<String> allRegexResponses =
            await atClientInstance.getKeys(regex: acknowledgedKeyId);
        if ((allRegexResponses != null) && (allRegexResponses.length > 0)) {
          AtKey acknowledgedAtKey =
              BackendService.getInstance().getAtKey(allRegexResponses[0]);

          AtValue result = await atClientInstance
              .get(acknowledgedAtKey)
              // ignore: return_of_invalid_type_from_catch_error
              .catchError((e) => print("error in get $e"));

          LocationNotificationModel acknowledgedEvent =
              LocationNotificationModel.fromJson(jsonDecode(result.value));
          LocationSharingService()
              .updateWithShareLocationAcknowledge(acknowledgedEvent);
        }
      }
    });
    setStatus(CHECK_ACKNOWLEDGED_EVENT, Status.Done);
  }

  mapUpdatedLocationDataToWidget(LocationNotificationModel locationData) {
    setStatus(MAP_UPDATED_LOCATION_DATA, Status.Loading);
    String newLocationDataKeyId =
        locationData.key.split('sharelocation-')[1].split('@')[0];

    for (int i = 0; i < allShareLocationNotifications.length; i++) {
      if (allShareLocationNotifications[i].key.contains(newLocationDataKeyId)) {
        allShareLocationNotifications[i].locationNotificationModel =
            locationData;
      }
    }
    setStatus(MAP_UPDATED_LOCATION_DATA, Status.Done);
  }

  Future<HybridNotificationModel> addDataToList(
      LocationNotificationModel locationNotificationModel) async {
    setStatus(ADD_EVENT, Status.Loading);

    String newLocationDataKeyId =
        locationNotificationModel.key.split('sharelocation-')[1].split('@')[0];
    String tempKey = 'sharelocation-$newLocationDataKeyId';
    List<String> key = [];
    if (locationNotificationModel.atsignCreator == currentAtSign) {
      key = await atClientInstance.getKeys(
        regex: tempKey,
      );
    } else {
      key = await atClientInstance.getKeys(
        regex: tempKey,
        sharedBy: locationNotificationModel.atsignCreator,
      );
    }

    HybridNotificationModel tempHyridNotificationModel =
        HybridNotificationModel(NotificationType.Location, key: key[0]);
    tempHyridNotificationModel.atKey =
        BackendService.getInstance().getAtKey(key[0]);
    tempHyridNotificationModel.atValue =
        await getAtValue(tempHyridNotificationModel.atKey);
    tempHyridNotificationModel.locationNotificationModel =
        locationNotificationModel;
    allShareLocationNotifications.add(tempHyridNotificationModel);

    setStatus(ADD_EVENT, Status.Done);
    return tempHyridNotificationModel;
  }

  Future<dynamic> getAtValue(AtKey key) async {
    try {
      AtValue atvalue = await atClientInstance
          .get(key)
          // ignore: return_of_invalid_type_from_catch_error
          .catchError((e) => print("error in get $e"));

      if (atvalue != null)
        return atvalue;
      else
        return null;
    } catch (e) {
      print('getAtValue:$e');
      return null;
    }
  }
}
