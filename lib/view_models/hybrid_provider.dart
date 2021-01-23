import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_location_app/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';

import 'base_model.dart';

class HybridProvider extends ShareLocationProvider {
  HybridProvider();
  AtClientImpl atClientInstance;
  String currentAtSign;
  List<HybridNotificationModel> allHybridNotifications;
  // ignore: non_constant_identifier_names
  String HYBRID_GET_ALL_EVENTS = 'hybrid_get_all_events';
  // ignore: non_constant_identifier_names
  String HYBRID_CHECK_ACKNOWLEDGED_EVENT = 'hybrid_check_acknowledged_event';
  // ignore: non_constant_identifier_names
  String HYBRID_ADD_EVENT = 'hybrid_ADD_EVENT';
  // ignore: non_constant_identifier_names
  String HYBRID_MAP_UPDATED_EVENT_DATA = 'hybrid_map_event_event';

  init(AtClientImpl clientInstance) {
    print('hyrbid clientInstance $clientInstance');
    allHybridNotifications = [];
    super.init(clientInstance);
  }

  getAllHybridEvents() async {
    setStatus(HYBRID_GET_ALL_EVENTS, Status.Loading);

    await getAllEvents();
    await super.getSingleUserLocationSharing();

    allHybridNotifications = [
      ...super.allNotifications,
      ...super.allShareLocationNotifications
    ];

    setStatus(HYBRID_GET_ALL_EVENTS, Status.Done);
  }

  mapUpdatedEventDataToWidget(EventNotificationModel eventData) {
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Loading);
    String newEventDataKeyId =
        eventData.key.split('createevent-')[1].split('@')[0];

    for (int i = 0; i < allHybridNotifications.length; i++) {
      if (allHybridNotifications[i].notificationType ==
          NotificationType.Event) {
        if (allHybridNotifications[i]
            .eventNotificationModel
            .key
            .contains(newEventDataKeyId)) {
          allHybridNotifications[i].eventNotificationModel = eventData;
        }
      }
    }
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Done);
  }
}
