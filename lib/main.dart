import 'dart:async';
import 'package:atsign_location_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:at_utils/at_logger.dart';

import 'view_models/theme_view_model.dart';

void main() {
  var themeProvider = ThemeProvider();
  AtSignLogger.root_level = 'finer';
  WidgetsFlutterBinding.ensureInitialized();
  runZoned<Future<void>>(() async {
    ThemeColor _themeColor = await themeProvider.checkTheme();
    // ignore: unawaited_futures
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).then((_) {
      runApp(MyApp(currentTheme: _themeColor));
    });
  });
}
