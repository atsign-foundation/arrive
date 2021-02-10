import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class MyLocation {
  MyLocation._();
  static final _instance = MyLocation._();
  factory MyLocation() => _instance;

  Future<LatLng> myLocation() async {
    Location _location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return LatLng(0, 0);
      }
    }
    print('_serviceEnabled $_serviceEnabled');
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return LatLng(0, 0);
      }
    }
    print('_permissionGranted $_permissionGranted');

    // return LatLng(37.785834, -122.406417);

    _locationData = await _location.getLocation();
    print('_locationData $_locationData');

    return LatLng(_locationData.latitude, _locationData.longitude);
  }
}