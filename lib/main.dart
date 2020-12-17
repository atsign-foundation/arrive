import 'dart:async';

import 'package:atsign_location_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'view_models/theme_view_model.dart';

void main() {
  ThemeProvider themeProvider = ThemeProvider();
  WidgetsFlutterBinding.ensureInitialized();
  runZoned<Future<void>>(() async {
    ThemeColor _themeColor = await themeProvider.checkTheme();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).then((_) {
      runApp(MyApp(currentTheme: _themeColor));
    });
  });
}
