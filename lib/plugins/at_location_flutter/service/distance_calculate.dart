import 'dart:convert';
import 'package:atsign_location_app/plugins/at_location_flutter/utils/constants/constants.dart';
import 'package:latlong/latlong.dart';

import 'api_service.dart';

class DistanceCalculate {
  DistanceCalculate._();
  static final DistanceCalculate _instance = DistanceCalculate._();
  factory DistanceCalculate() => _instance;

  Future<String> caculateETA(LatLng origin, LatLng destination) async {
    try {
      var url =
          'https://router.hereapi.com/v8/routes?transportMode=car&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&return=summary&apiKey=${MixedConstants.API_KEY}';
      var response = await ApiService().getRequest("$url");
      var data = response;
      data = jsonDecode(data['body']);
      var _min = (data['routes'][0]['sections'][0]['summary']['duration'] / 60);
      var _time = _min > 60
          ? '${((_min / 60).toStringAsFixed(0))}hr ${(_min % 60).toStringAsFixed(0)}min'
          : '${_min.toStringAsFixed(2)}min';

      return _time;
    } catch (e) {
      print(' error in ETA $e');
      return '?';
    }
  }
}
