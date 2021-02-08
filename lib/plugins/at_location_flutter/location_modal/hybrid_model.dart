import 'dart:typed_data';
import 'package:atsign_location_app/plugins/at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class HybridModel {
  String displayName;
  Uint8List image;
  LatLng latLng;
  String eta = '?';
  Marker marker;
  // int epocTime = DateTime.now().millisecondsSinceEpoch;
  HybridModel({
    this.displayName,
    this.eta,
    this.image,
    this.latLng,
    this.marker,
  });
}
