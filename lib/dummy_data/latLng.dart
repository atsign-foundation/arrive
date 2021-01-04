import 'package:latlong/latlong.dart';

List<LatLng> getLatLng({int length}) {
  List<List<double>> raw = [
    [148.29, -31.33],
    [148.51, -35.2],
    [149.69, -35.04],
    [149.78, -35.02],
    [149.86, -31.43],
    [150.04, -32.72],
    [150.3, -33.96],
    [150.33, -32.3],
    [150.35, -31.7],
    [150.41, -31.12],
    [150.63, -35.8],
    [150.76, -32.96],
    [150.89, -32.77],
    [150.92, -34.97],
    [151.31, -31.48],
    [151.36, -33.53],
    [151.47, -31.18],
    [151.64, -32.31],
    [151.96, -32.14],
    [152.53, -34.12],
  ];
  if (length != null)
    return raw.getRange(0, length).map((e) => LatLng(e[1], e[0])).toList();
  return raw.map((e) => LatLng(e[1], e[0])).toList();
}

List<LatLng> getLatLng2 = [
  LatLng(13, 77.5),
  LatLng(13.02001, 77.51001),
  LatLng(13.05, 77.53),
  LatLng(13.059, 77.56),
  LatLng(13.064, 77.58),
  LatLng(13.07001, 77.55001),
];
