import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/view_models/add_contact_provider.dart';
import 'package:atsign_location_app/view_models/blocked_contact_provider.dart';
import 'package:atsign_location_app/view_models/contact_provider.dart';
import 'package:atsign_location_app/view_models/scan_qr_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AddContactProvider>(
            create: (context) => AddContactProvider()),
        ChangeNotifierProvider<ContactProvider>(
            create: (context) => ContactProvider()),
        ChangeNotifierProvider<BlockedContactProvider>(
            create: (context) => BlockedContactProvider()),
        ChangeNotifierProvider<ScanQrProvider>(
            create: (context) => ScanQrProvider())
      ],
      child: MaterialApp(
        title: 'AtSign Location App',
        debugShowCheckedModeBanner: false,
        initialRoute: SetupRoutes.initialRoute,
        navigatorKey: NavService.navKey,
        theme: ThemeData(
          fontFamily: 'HelveticaNeu',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            color: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          buttonBarTheme: ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
          ),
        ),
        routes: SetupRoutes.routes,
      ),
    );
  }
}
