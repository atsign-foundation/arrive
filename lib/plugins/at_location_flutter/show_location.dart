import 'package:atsign_location_app/plugins/at_location_flutter/common_components/build_marker.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/hybrid_model.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'map_content/flutter_map/flutter_map.dart';
import 'map_content/flutter_map_marker_cluster/src/marker_cluster_plugin.dart';

// ignore: must_be_immutable

Widget showLocation(Key key, {LatLng location, MapController mapController}) {
  bool showMarker = true;
  Marker marker;

  if (location != null) {
    marker = buildMarker(new HybridModel(latLng: location), singleMarker: true);
    if (mapController != null) {
      mapController.move(location, 8);
    }
  } else {
    marker = buildMarker(new HybridModel(latLng: LatLng(45, 45)),
        singleMarker: true);
    showMarker = false;
  }
  return FlutterMap(
    mapController: mapController,
    options: MapOptions(
      center: (location != null) ? location : LatLng(45, 45),
      zoom: (location != null) ? 8 : 2,
      plugins: [MarkerClusterPlugin(UniqueKey())],
    ),
    layers: [
      TileLayerOptions(
        minNativeZoom: 2,
        maxNativeZoom: 18,
        minZoom: 1,
        urlTemplate:
            "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${MixedConstants.MAP_KEY}",
      ),
      MarkerLayerOptions(markers: showMarker ? [marker] : []),
    ],
  );
}
