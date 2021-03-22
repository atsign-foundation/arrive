import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/themes/theme.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_models/theme_view_model.dart';

class MyApp extends StatefulWidget {
  final ThemeColor currentTheme;
  MyApp({this.currentTheme});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(themeColor: widget.currentTheme)),
      ChangeNotifierProvider<EventProvider>(
          create: (context) => EventProvider()),
      ChangeNotifierProvider<ShareLocationProvider>(
          create: (context) => ShareLocationProvider()),
      ChangeNotifierProvider<RequestLocationProvider>(
          create: (context) => RequestLocationProvider()),
      ChangeNotifierProvider<HybridProvider>(
          create: (context) => HybridProvider()),
    ], child: MaterialAppClass());
  }
}

class MaterialAppClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AtSign Location App',
      debugShowCheckedModeBanner: false,
      initialRoute: SetupRoutes.initialRoute,
      navigatorKey: NavService.navKey,
      theme: Themes.getThemeData(Provider.of<ThemeProvider>(context).getTheme),
      routes: SetupRoutes.routes,
    );
  }
}
