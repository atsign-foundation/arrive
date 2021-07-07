import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/utils/constants/constants.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_flutter/screens/blocked_screen.dart';
import 'package:atsign_location_app/screens/event/event_log.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/screens/splash/splash.dart';
import 'package:atsign_location_app/screens/website_webview/website_webview.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.SPLASH;
  static String currentAtSign;
  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.SPLASH: (context) => Splash(),
      Routes.HOME: (context) => HomeScreen(),
      Routes.EVENT_LOG: (context) => EventLog(),
      Routes.FAQS: (context) => WebsiteScreen(
            title: 'FAQ',
            url: '${MixedConstants.WEBSITE_URL}/faqs',
          ),
      Routes.TERMS_CONDITIONS_SCREEN: (context) => WebsiteScreen(
            title: 'Terms and Conditions',
            url: '${MixedConstants.WEBSITE_URL}/terms-conditions',
          ),
      Routes.GROUP_LIST: (context) {
        Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
        return GroupList();
      },
      Routes.CONTACT_SCREEN: (context) {
        Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
        return ContactsScreen(
          asSelectionScreen: args['asSelectionScreen'],
          context: context,
          onSendIconPressed: args['onSendIconPressed'],
        );
      },
      Routes.BLOCKED_CONTACT_SCREEN: (context) {
        return BlockedScreen();
      },
    };
  }

  static Future push(BuildContext context, String value,
      {Object arguments, Function callbackAfterNavigation}) {
    return Navigator.of(context)
        .pushNamed(value, arguments: arguments)
        .then((response) {
      if (callbackAfterNavigation != null) {
        callbackAfterNavigation();
      }
    });
  }

  // ignore: always_declare_return_types
  static replace(BuildContext context, String value,
      {dynamic arguments, Function callbackAfterNavigation}) {
    Navigator.of(context)
        .pushReplacementNamed(value, arguments: arguments)
        .then((response) {
      if (callbackAfterNavigation != null) {
        callbackAfterNavigation();
      }
    });
  }

  // ignore: always_declare_return_types
  static pushAndRemoveAll(BuildContext context, String value,
      {dynamic arguments, Function callbackAfterNavigation}) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      value,
      (_) => false,
      arguments: arguments,
    )
        .then((response) {
      if (callbackAfterNavigation != null) {
        callbackAfterNavigation();
      }
    });
  }
}
