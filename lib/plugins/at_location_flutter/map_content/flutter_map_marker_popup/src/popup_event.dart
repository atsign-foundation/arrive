import 'package:atsign_location_app/plugins/at_location_flutter/map_content/flutter_map/src/layer/marker_layer.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/map_content/flutter_map_marker_popup/src/popup_event_actions.dart';

class PopupEvent {
  final Marker marker;
  final List<Marker> markers;
  final PopupEventActions action;

  PopupEvent.hideInList(this.markers)
      : this.marker = null,
        this.action = PopupEventActions.hideInList;

  PopupEvent.hideAny()
      : this.marker = null,
        this.markers = null,
        this.action = PopupEventActions.hideAny;

  PopupEvent.toggle(this.marker)
      : this.markers = null,
        this.action = PopupEventActions.toggle;

  PopupEvent.show(this.marker)
      : this.markers = null,
        this.action = PopupEventActions.show;
}
