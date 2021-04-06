import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/services/backend_service.dart';

import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/services/request_location_service.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'base_model.dart';

class RequestLocationProvider extends ShareLocationProvider {
  RequestLocationProvider();
  AtClientImpl atClientInstance;
  String currentAtSign;
  List<HybridNotificationModel> allRequestNotifications;
  // ignore: non_constant_identifier_names
  String GET_ALL_REQUEST_EVENTS = 'get_all_request_events';
  // ignore: non_constant_identifier_names
  String CHECK_REQUEST_ACKNOWLEDGED_EVENT = 'check_request_acknowledged_event';
  // ignore: non_constant_identifier_names
  String ADD_REQUEST_EVENT = 'add_request_event';
  // ignore: non_constant_identifier_names
  String MAP_UPDATED_REQUEST_LOCATION_DATA = 'map_updated_request_event';

  init(AtClientImpl clientInstance) {
    reset(GET_ALL_REQUEST_EVENTS);
    reset(CHECK_REQUEST_ACKNOWLEDGED_EVENT);
    reset(ADD_REQUEST_EVENT);
    reset(MAP_UPDATED_REQUEST_LOCATION_DATA);

    atClientInstance = clientInstance;
    currentAtSign = atClientInstance.currentAtSign;
    allRequestNotifications = [];
    super.init(clientInstance);
  }

  getSingleUserLocationRequest() async {
    setStatus(GET_ALL_REQUEST_EVENTS, Status.Loading);

    List<String> requestLocationResponse = await atClientInstance.getKeys(
      regex: 'requestlocation-',
    );

    if (requestLocationResponse.length == 0) {
      setStatus(GET_ALL_REQUEST_EVENTS, Status.Done);
      return;
    }

    requestLocationResponse.forEach((key) {
      if (('@${key.split(':')[1]}'.contains(currentAtSign)) ||
          ('@${key.split(':')[0]}'.contains(currentAtSign))) {
        HybridNotificationModel tempHyridNotificationModel =
            HybridNotificationModel(NotificationType.Location, key: key);
        allRequestNotifications.add(tempHyridNotificationModel);
      }
    });

    allRequestNotifications.forEach((notification) {
      AtKey atKey = BackendService.getInstance().getAtKey(notification.key);
      notification.atKey = atKey;
    });

    for (int i = 0; i < allRequestNotifications.length; i++) {
      AtValue value = await getAtValue(allRequestNotifications[i].atKey);
      if (value != null) {
        allRequestNotifications[i].atValue = value;
      }
    }
    convertJsonToLocationModelRequest();
    filterDataRequest();
    await checkForPendingRequestLocations();

    setStatus(GET_ALL_REQUEST_EVENTS, Status.Done);
    checkForAcknowledgeRequest();
  }

  convertJsonToLocationModelRequest() {
    for (int i = 0; i < allRequestNotifications.length; i++) {
      if (allRequestNotifications[i].atValue.value != null) {
        LocationNotificationModel locationNotificationModel =
            LocationNotificationModel.fromJson(
                jsonDecode(allRequestNotifications[i].atValue.value));
        allRequestNotifications[i].locationNotificationModel =
            locationNotificationModel;
      }
    }
  }

  filterDataRequest() {
    List<HybridNotificationModel> tempNotification = [];

    ///Uncomment if rejecting a request location should remove the person
    ///
    // allRequestNotifications.forEach((notification) {
    //   if ((notification.locationNotificationModel != null)) {
    //     if ((notification.locationNotificationModel.isAcknowledgment) &&
    //         (notification.locationNotificationModel.isExited) &&
    //         (notification.locationNotificationModel.atsignCreator ==
    //             currentAtSign)) tempNotification.add(notification);
    //   }
    // });
    // allRequestNotifications
    //     .removeWhere((element) => tempNotification.contains(element));

    for (int i = 0; i < allRequestNotifications.length; i++) {
      // ignore: unrelated_type_equality_checks
      if ((allRequestNotifications[i].locationNotificationModel == 'null') ||
          (allRequestNotifications[i].locationNotificationModel == null))
        tempNotification.add(allRequestNotifications[i]);
      else {
        if ((allRequestNotifications[i].locationNotificationModel.to != null) &&
            (allRequestNotifications[i]
                        .locationNotificationModel
                        .to
                        .difference(DateTime.now()))
                    .inMinutes <
                0) tempNotification.add(allRequestNotifications[i]);
      }
    }
    allRequestNotifications
        .removeWhere((element) => tempNotification.contains(element));
  }

  checkForPendingRequestLocations() async {
    allRequestNotifications.forEach((notification) async {
      if ((notification.locationNotificationModel.atsignCreator ==
              currentAtSign) &&
          (!notification.locationNotificationModel.isAccepted) &&
          (!notification.locationNotificationModel.isExited)) {
        String atkeyMicrosecondId =
            notification.key.split('requestlocation-')[1].split('@')[0];
        String acknowledgedKeyId =
            'requestlocationacknowledged-$atkeyMicrosecondId';
        List<String> allRegexResponses =
            await atClientInstance.getKeys(regex: acknowledgedKeyId);
        if ((allRegexResponses != null) && (allRegexResponses.length > 0)) {
          notification.haveResponded = true;
        }
      }
    });
  }

  checkForAcknowledgeRequest() {
    providerCallback<RequestLocationProvider>(NavService.navKey.currentContext,
        task: (provider) =>
            provider.updateEventAccordingToAcknowledgedDataRequest(),
        taskName: (provider) => provider.CHECK_REQUEST_ACKNOWLEDGED_EVENT,
        showLoader: false,
        onSuccess: (provider) {});
  }

  updateEventAccordingToAcknowledgedDataRequest() async {
    setStatus(CHECK_REQUEST_ACKNOWLEDGED_EVENT, Status.Loading);

    allRequestNotifications.forEach((notification) async {
      if ((notification.locationNotificationModel.atsignCreator !=
              currentAtSign) &&
          (!notification.locationNotificationModel.isAcknowledgment)) {
        String atkeyMicrosecondId =
            notification.key.split('requestlocation-')[1].split('@')[0];
        String acknowledgedKeyId =
            'requestlocationacknowledged-$atkeyMicrosecondId';

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
          RequestLocationService()
              .updateWithRequestLocationAcknowledge(acknowledgedEvent);
        }
      }
    });
    setStatus(CHECK_REQUEST_ACKNOWLEDGED_EVENT, Status.Done);
  }

  mapUpdatedLocationDataToWidgetRequest(LocationNotificationModel locationData,
      {bool remove = false}) {
    setStatus(MAP_UPDATED_REQUEST_LOCATION_DATA, Status.Loading);
    String newLocationDataKeyId =
        locationData.key.split('requestlocation-')[1].split('@')[0];

    for (int i = 0; i < allRequestNotifications.length; i++) {
      if (allRequestNotifications[i].key.contains(newLocationDataKeyId)) {
        if (!remove)
          allRequestNotifications[i].locationNotificationModel = locationData;
        else
          allRequestNotifications.remove(allRequestNotifications[i]);
      }
    }
    setStatus(MAP_UPDATED_REQUEST_LOCATION_DATA, Status.Done);
  }

  addDataToListRequest(
      LocationNotificationModel locationNotificationModel) async {
    setStatus(ADD_REQUEST_EVENT, Status.Loading);
    String newLocationDataKeyId, tempKey;
    newLocationDataKeyId = locationNotificationModel.key
        .split('requestlocation-')[1]
        .split('@')[0];
    tempKey = 'requestlocation-$newLocationDataKeyId';
    List<String> key = [];

    if (locationNotificationModel.atsignCreator == currentAtSign) {
      key = await atClientInstance.getKeys(
        regex: tempKey,
        sharedBy: locationNotificationModel.atsignCreator,
      );
    } else {
      key = await atClientInstance.getKeys(
        regex: tempKey,
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
    allRequestNotifications.add(tempHyridNotificationModel);
    setStatus(ADD_REQUEST_EVENT, Status.Done);

    return tempHyridNotificationModel;
  }

  Future<dynamic> getAtValue(AtKey key) async {
    AtValue atvalue = await atClientInstance
        .get(key)
        // ignore: return_of_invalid_type_from_catch_error
        .catchError((e) => print("error in get $e"));

    if (atvalue != null)
      return atvalue;
    else
      return null;
  }
}
