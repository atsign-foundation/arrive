import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.HOME;
  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.HOME: (context) => HomeScreen(),
    };
  }
}
