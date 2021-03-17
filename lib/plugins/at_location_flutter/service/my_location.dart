import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

Future<LatLng> getMyLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // return Future.error('Location services are disabled.');
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    if (permission == LocationPermission.denied) {
      // return Future.error('Location permissions are denied');
      return null;
    }
  }
  Position position = await Geolocator.getCurrentPosition();
  return LatLng(position.latitude, position.longitude);
}
