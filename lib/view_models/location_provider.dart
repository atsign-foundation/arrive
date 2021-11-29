import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/services/event_location_share.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:atsign_location_app/common_components/dialog_box/location_prompt_dialog.dart';
import 'package:atsign_location_app/data_services/hive/hive_db.dart';
import 'package:atsign_location_app/models/event_and_location.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/view_models/base_model.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:flutter/material.dart';
import 'package:at_location_flutter/service/send_location_notification.dart';

class LocationProvider extends BaseModel {
  LocationProvider();
  List<EventAndLocationHybrid> allNotifications = [];
  List<KeyLocationModel> allLocationNotifications = [];
  List<EventKeyLocationModel> allEventNotifications = [];
  final HiveDataProvider _hiveDataProvider = HiveDataProvider();
  bool isSharing = false, isGettingLoadedFirstTime = true;
  // ignore: non_constant_identifier_names
  String GET_ALL_NOTIFICATIONS = 'get_all_notifications';

  void resetData() {
    allNotifications = [];
    allLocationNotifications = [];
    allEventNotifications = [];
    isGettingLoadedFirstTime = true;

    AtLocationNotificationListener().resetMonitor();
    AtEventNotificationListener().resetMonitor();
  }

  void init(AtClientManager atClientManager, String activeAtSign,
      GlobalKey<NavigatorState> navKey) async {
    if (isGettingLoadedFirstTime) {
      setStatus(GET_ALL_NOTIFICATIONS, Status.Loading);
      isGettingLoadedFirstTime = false;
    }
    // allNotifications = [];
    allLocationNotifications = [];
    allEventNotifications = [];

    // AtClientManager.getInstance().notificationService.stopAllSubscriptions();

    initialiseLocationSharing();

    await initializeLocationService(
      navKey,
      mapKey: MixedConstants.MAP_KEY,
      apiKey: MixedConstants.API_KEY,
      // getAtValue: LocationNotificationListener().getAtValue
      showDialogBox: true,
      streamAlternative: updateLocation,
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
    // EventLocationShare().setLocationPrompt(() async {
    //   await locationPromptDialog(
    //     isShareLocationData: false,
    //     isRequestLocationData: false,
    //   );
    // });

    // setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
  }

  // ignore: always_declare_return_types
  updateLocation(List<KeyLocationModel> list) {
    print('location package updateLocation');

    allLocationNotifications = list;
    updateAllNotification(locationsList: allLocationNotifications);
  }

  // ignore: always_declare_return_types
  updateEvents(List<EventKeyLocationModel> list) {
    print('events package updateEvents');

    allEventNotifications = list;
    updateAllNotification(eventsList: allEventNotifications);
  }

  // ignore: always_declare_return_types
  updateAllNotification(
      {List<KeyLocationModel> locationsList,
      List<EventKeyLocationModel> eventsList}) async {
    allNotifications = [];

    if (locationsList != null) {
      locationsList.forEach((element) {
        var _obj = EventAndLocationHybrid(NotificationModelType.LocationModel,
            locationKeyModel: element);

        allNotifications.add(_obj);
      });
    } else {
      allLocationNotifications.forEach((element) {
        var _obj = EventAndLocationHybrid(NotificationModelType.LocationModel,
            locationKeyModel: element);

        allNotifications.add(_obj);
      });
    }

    if (eventsList != null) {
      eventsList.forEach((element) {
        var _obj = EventAndLocationHybrid(NotificationModelType.EventModel,
            eventKeyModel: element);

        allNotifications.add(_obj);
      });
    } else {
      allEventNotifications.forEach((element) {
        var _obj = EventAndLocationHybrid(NotificationModelType.EventModel,
            eventKeyModel: element);

        allNotifications.add(_obj);
      });
    }

    setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
  }

  Future<void> initialiseLocationSharing() async {
    isSharing = await getShareLocation();
    SendLocationNotification().setMasterSwitchState(isSharing);
    // EventLocationShare().setMasterSwitchState(isSharing);
    notifyListeners();
  }

  Future<void> updateShareLocation(bool value) async {
    await _hiveDataProvider.insertData(
      'Sharing',
      {
        'isSharing-${AtClientManager.getInstance().atClient.getCurrentAtSign()}':
            value.toString()
      },
    );

    isSharing = value;

    SendLocationNotification().setMasterSwitchState(value);
    // EventLocationShare().setMasterSwitchState(value);

    notifyListeners();
  }

  Future<bool> getShareLocation() async {
    var data = await _hiveDataProvider.readData('Sharing');

    if ((data['isSharing-${AtClientManager.getInstance().atClient.getCurrentAtSign()}'] ==
            null) ||
        (data['isSharing-${AtClientManager.getInstance().atClient.getCurrentAtSign()}'] ==
            'null')) {
      await updateShareLocation(true);
    }

    return (data[
                'isSharing-${AtClientManager.getInstance().atClient.getCurrentAtSign()}'] ==
            'true')
        ? true
        : false;
  }
}
