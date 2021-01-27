import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_events/models/hybrid_notifiation_model.dart';
import 'base_model.dart';

// all the UI related functions will happen here
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

  // List<String> allKeys = [];
  // List<AtKey> allAtkeys = [];
  // List<AtValue> allAtValues = [];
  // List<EventNotificationModel> allEvents = [];

  init(AtClientImpl clientInstance) {
    print('share clientInstance ${clientInstance == null}');
    atClientInstance = clientInstance;
    currentAtSign = atClientInstance.currentAtSign;
    allShareLocationNotifications = [];
    super.init(clientInstance);
  }

  getSingleUserLocationSharing() async {
    setStatus(GET_ALL_EVENTS, Status.Loading);

    List<String> shareLocationResponse = await atClientInstance.getKeys(
      regex: 'sharelocation-',
      // sharedWith: '@test_ga3',
    );

    if (shareLocationResponse.length == 0) {
      setStatus(GET_ALL_EVENTS, Status.Done);
      return;
    }

    shareLocationResponse.forEach((key) {
      if (('@${key.split(':')[1]}'.contains(currentAtSign)) ||
          ('@${key.split(':')[0]}'.contains(currentAtSign))) {
        print('key -> $key');
        HybridNotificationModel tempHyridNotificationModel =
            HybridNotificationModel(NotificationType.Location, key: key);
        allShareLocationNotifications.add(tempHyridNotificationModel);
        // allKeys.add(element);
      }
    });

    allShareLocationNotifications.forEach((notification) {
      AtKey atKey = AtKey.fromString(notification.key);
      print('atkey -> $atKey');
      notification.atKey = atKey;
    });

    for (int i = 0; i < allShareLocationNotifications.length; i++) {
      AtValue value = await getAtValue(allShareLocationNotifications[i].atKey);
      if (value != null) {
        print('notification.value -> $value');

        allShareLocationNotifications[i].atValue = value;
      }
    }
    convertJsonToLocationModel();

    filterData();
    setStatus(GET_ALL_EVENTS, Status.Done);
    checkForAcknowledge();
  }

  convertJsonToLocationModel() {
    print(
        'allShareLocationNotifications.length -> ${allShareLocationNotifications.length}');
    for (int i = 0; i < allShareLocationNotifications.length; i++) {
      try {
        if (allShareLocationNotifications[i].atValue.value != null) {
          LocationNotificationModel locationNotificationModel =
              LocationNotificationModel.fromJson(
                  jsonDecode(allShareLocationNotifications[i].atValue.value));
          allShareLocationNotifications[i].locationNotificationModel =
              locationNotificationModel;
          print(
              'locationNotificationModel $i -> ${locationNotificationModel.getLatLng}');
        }
      } catch (e) {
        print('convertJsonToLocationModel:$e');
        allShareLocationNotifications.remove(allShareLocationNotifications[i]);
      }
    }
  }

  filterData() {
    // List<HybridNotificationModel> tempNotification = [];
    // allShareLocationNotifications.forEach((notification) {
    //   if ((notification.locationNotificationModel != null) &&
    //       (notification.locationNotificationModel.atsignCreator !=
    //           currentAtSign) &&
    //       (!notification.locationNotificationModel.isAccepted) &&
    //       (notification.locationNotificationModel.isExited)) {
    //     tempNotification.add(notification);
    //   }
    // });

    // allShareLocationNotifications
    //     .removeWhere((element) => tempNotification.contains(element));
  }

  checkForAcknowledge() {
    // providerCallback<ShareLocationProvider>(NavService.navKey.currentContext,
    //     task: (provider) => provider.updateEventAccordingToAcknowledgedData(),
    //     taskName: (provider) => provider.CHECK_ACKNOWLEDGED_EVENT,
    //     showLoader: false,
    //     onSuccess: (provider) {});
    updateEventAccordingToAcknowledgedData();
  }

//"@mixedmartialartsexcess:sharelocation-1611303124945962@test_ga4"
  updateEventAccordingToAcknowledgedData() async {
    // from all the notifications check whose isAcknowledgment is false
    // check for sharelocationacknowledged notification with same keyID, if present then update
    setStatus(CHECK_ACKNOWLEDGED_EVENT, Status.Loading);

    allShareLocationNotifications.forEach((notification) async {
      if ((notification.locationNotificationModel.atsignCreator ==
              currentAtSign) &&
          (!notification.locationNotificationModel.isAcknowledgment)) {
        String atkeyMicrosecondId =
            notification.key.split('sharelocation-')[1].split('@')[0];
        print('atkeyMicrosecondId $atkeyMicrosecondId');
        String acknowledgedKeyId =
            'sharelocationacknowledged-$atkeyMicrosecondId';

        List<String> allRegexResponses =
            await atClientInstance.getKeys(regex: acknowledgedKeyId);
        print('lenhtg ${allRegexResponses.length}');
        if ((allRegexResponses != null) && (allRegexResponses.length > 0)) {
          AtKey acknowledgedAtKey = AtKey.fromString(allRegexResponses[0]);

          AtValue result = await atClientInstance
              .get(acknowledgedAtKey)
              .catchError((e) =>
                  print("error in get ${e.errorCode} ${e.errorMessage}"));

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
    // TODO: check for request declined
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
        // sharedWith: locationNotificationModel.receiver,
      );
    } else {
      key = await atClientInstance.getKeys(
        regex: tempKey,
        sharedBy: locationNotificationModel.atsignCreator,
      );
    }

    HybridNotificationModel tempHyridNotificationModel =
        HybridNotificationModel(NotificationType.Location, key: key[0]);
    //allShareLocationNotifications.add(tempHyridNotificationModel);
    tempHyridNotificationModel.atKey = AtKey.fromString(key[0]);
    tempHyridNotificationModel.atValue =
        await getAtValue(tempHyridNotificationModel.atKey);
    tempHyridNotificationModel.locationNotificationModel =
        locationNotificationModel;
    allShareLocationNotifications.add(tempHyridNotificationModel);
    print('addDataToList:${allShareLocationNotifications}');
    //notifyListeners();r
    //notify listenres
    setStatus(ADD_EVENT, Status.Done);
    return tempHyridNotificationModel;
  }

  Future<dynamic> getAtValue(AtKey key) async {
    try {
      AtValue atvalue = await atClientInstance.get(key).catchError(
          (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));

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
