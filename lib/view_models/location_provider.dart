import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:atsign_location_app/common_components/dialog_box/location_prompt_dialog.dart';
import 'package:atsign_location_app/data_services/hive/hive_db.dart';
import 'package:atsign_location_app/models/event_and_location.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/view_models/base_model.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:flutter/material.dart';
import 'package:at_location_flutter/service/send_location_notification.dart';

class LocationProvider extends BaseModel {
  LocationProvider();
  List<EventAndLocationHybrid> allLocationNotifications = [];
  List<EventAndLocationHybrid> allEventNotifications = [];
  final HiveDataProvider _hiveDataProvider = HiveDataProvider();
  String locationSharingKey =
      'issharing-${AtClientManager.getInstance().atClient.getCurrentAtSign()!.replaceAll('@', '')}';
  bool isSharing = false,
      isGettingLoadedFirstTime = true,
      locationSharingSwitchProcessing = false;
  // ignore: non_constant_identifier_names
  String GET_ALL_NOTIFICATIONS = 'get_all_notifications';
  int animateToIndex = -1;

  void resetData() {
    animateToIndex = -1;
    allLocationNotifications = [];
    allEventNotifications = [];
    isGettingLoadedFirstTime = true;
    locationSharingSwitchProcessing = false;
    locationSharingKey =
        'issharing-${AtClientManager.getInstance().atClient.getCurrentAtSign()!.replaceAll('@', '')}';

    AtLocationNotificationListener().resetMonitor();
    AtEventNotificationListener().resetMonitor();
  }

  void init(AtClientManager atClientManager, String? activeAtSign,
      GlobalKey<NavigatorState> navKey) async {
    if (isGettingLoadedFirstTime) {
      setStatus(GET_ALL_NOTIFICATIONS, Status.Loading);
      isGettingLoadedFirstTime = false;
    }
    allLocationNotifications = [];
    allEventNotifications = [];

    initialiseLocationSharing();

    await initializeLocationService(
      navKey,
      mapKey: MixedConstants.MAP_KEY,
      apiKey: MixedConstants.API_KEY,
      showDialogBox: true,
      streamAlternative: updateLocation,
      isEventInUse: true,
    );

    await initialiseEventService(
      navKey,
      mapKey: MixedConstants.MAP_KEY,
      apiKey: MixedConstants.API_KEY,
      rootDomain: MixedConstants.ROOT_DOMAIN,
      streamAlternative: updateEvents,
      initLocation: false,
    );

    SendLocationNotification().setLocationPrompt(() async {
      await locationPromptDialog(
        isShareLocationData: false,
        isRequestLocationData: false,
      );
    });
  }

  // ignore: always_declare_return_types
  updateLocation(List<KeyLocationModel> list) async {

    allLocationNotifications = list
        .map((e) => EventAndLocationHybrid(NotificationModelType.LocationModel,
            locationKeyModel: e))
        .toList();
    setStatus(GET_ALL_NOTIFICATIONS, Status.Done);

    /// to navigate to new tab, we give some time for screens to re render
    await Future.delayed(Duration(milliseconds: 500));
    if (allLocationNotifications.length < list.length) {
      animateToIndex = 1; // Locations is index 1 in home screen
    } else {
      animateToIndex = -1; // don't animate
    }
    setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
  }

  // ignore: always_declare_return_types
  updateEvents(List<EventKeyLocationModel> list) async {
    
    allEventNotifications = list
        .map((e) => EventAndLocationHybrid(NotificationModelType.EventModel,
            eventKeyModel: e))
        .toList();
    setStatus(GET_ALL_NOTIFICATIONS, Status.Done);

    /// to navigate to new tab, we give some time for screens to re render
    await Future.delayed(Duration(milliseconds: 500));
    if (allEventNotifications.length < list.length) {
      animateToIndex = 0; // Events is index 0 in home screen
    } else {
      animateToIndex = -1; // don't animate
    }
  }

  void changeLocationSharingMode(bool _mode) {
    locationSharingSwitchProcessing = _mode;
    notifyListeners();
  }

  Future<void> initialiseLocationSharing() async {
    isSharing = await getShareLocation();
    SendLocationNotification().setMasterSwitchState(isSharing);
    // EventLocationShare().setMasterSwitchState(isSharing);
    notifyListeners();
  }

  Future<bool> getShareLocation() async {
    var allLocationSharingKey =
        await AtClientManager.getInstance().atClient.getAtKeys(
              regex: locationSharingKey,
            );

    var alreadyExists = allLocationSharingKey.isNotEmpty;

    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = -1
      ..metadata!.ccd = true
      ..key = locationSharingKey;
    var value =
        await AtClientManager.getInstance().atClient.get(atKey).catchError(
            // ignore: invalid_return_type_for_catch_error
            (e) async {
      print('error in get getShareLocation $e');

      /// create
      /// if key already exists, then make false for safer side
      /// else make it true, as a default value
      await updateLocationSharingKey(!alreadyExists);
    });

    return (value != null && value.value == 'true') ? true : false;
  }

  Future<bool> updateLocationSharingKey(bool value) async {
    try {
      var atKey = AtKey()
        ..metadata = Metadata()
        ..metadata!.ttr = -1
        ..metadata!.ccd = true
        ..key = locationSharingKey;

      var result = await AtClientManager.getInstance()
          .atClient
          .put(atKey, value.toString());

      if (result == true) {
        isSharing = value;
        SendLocationNotification().setMasterSwitchState(value);
      }

      notifyListeners();

      return result;
    } catch (e) {
      CustomToast().show('Error in switching location sharing $e ',
          NavService.navKey.currentContext);
      return false;
    }
  }
}
