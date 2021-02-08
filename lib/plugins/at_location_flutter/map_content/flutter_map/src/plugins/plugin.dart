import 'package:flutter/widgets.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/map_content/flutter_map/src/layer/layer.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/map_content/flutter_map/src/map/map.dart';

abstract class MapPlugin {
  bool supportsLayer(LayerOptions options);
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream);
}
