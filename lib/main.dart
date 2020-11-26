import 'dart:async';

import 'package:atsign_location_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZoned<Future<void>>(() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).then((_) {
      runApp(MyApp());
    });
  });
}
