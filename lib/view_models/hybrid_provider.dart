import 'package:at_client_mobile/at_client_mobile.dart';
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
    super.init(clientInstance);
    allHybridNotifications = [];
  }

  getAllHybridEvents() async {
    setStatus(HYBRID_GET_ALL_EVENTS, Status.Loading);

    await super.getAllEvents();
    print('super.allNotifications - ${super.allNotifications}');
    await super.getSingleUserLocationSharing();
    print(
        'super.allShareLocationNotifications - ${super.allShareLocationNotifications}');

    setStatus(HYBRID_GET_ALL_EVENTS, Status.Done);
  }
}
