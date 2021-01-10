// import 'dart:convert';

// import 'package:latlong/latlong.dart';

// class LocationNotificationModel {
//   double lat, long;
//   LocationNotificationModel({this.lat, this.long});
//   LocationNotificationModel.fromJson(Map<String, dynamic> json)
//       : lat = double.parse(json['lat']) ?? 0,
//         long = double.parse(json['long']) ?? 0;
//   Map<String, dynamic> toJson() => {
//         'lat': lat,
//         'long': long,
//       };

//   LatLng get getLatLng => LatLng(this.lat, this.long);

//   static String convertLocationNotificationToJson(
//       LocationNotificationModel locationNotificationModel) {
//     var notification = json.encode({
//       'lat': locationNotificationModel.lat,
//       'long': locationNotificationModel.long
//     });
//     return notification;
//   }
// }
