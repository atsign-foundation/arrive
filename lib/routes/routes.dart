// import 'package:atsign_contacts_group/screens/empty_group/empty_group.dart';
// import 'package:atsign_contacts_group/screens/list/group_list.dart';
import 'package:atsign_contacts_group/atsign_contacts_group.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_contacts/screens/contacts_screen.dart';
import 'package:atsign_location_app/screens/event/event_log.dart';
import 'package:atsign_location_app/screens/faqs/faqs.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/screens/request_location/request_location_screen.dart';
import 'package:atsign_location_app/screens/share_location/share_location_screen.dart';
import 'package:atsign_location_app/screens/selected_location.dart/selected_location.dart';
import 'package:atsign_location_app/screens/splash/splash.dart';
import 'package:atsign_location_app/screens/terms_conditions/terms_conditions_screen.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.SPLASH;
  static String currentAtSign;
  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.SPLASH: (context) => Splash(),
      Routes.HOME: (context) => HomeScreen(),
      Routes.EVENT_LOG: (context) => EventLog(),
      Routes.FAQS: (context) => FaqsScreen(),
      Routes.TERMS_CONDITIONS_SCREEN: (context) => TermsConditions(),
      Routes.GROUP_LIST: (context) {
        Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
        return GroupList(
          currentAtsign: args['currentAtSign'],
          //  useTheme: true
        );
      },
      Routes.SHARE_LOCATION_EVENT: (context) => ShareLocationScreen(
            length: (ModalRoute.of(context).settings.arguments as Map ??
                {})["length"],
          ),
      Routes.SELECTED_LOCATION: (context) => SelectedLocation(),
      Routes.REQUEST_LOCATION_EVENT: (context) => RequestLocationScreen(),
      Routes.CONTACT_SCREEN: (context) {
        Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
        return ContactsScreen(
          asSelectionScreen: args['asSelectionScreen'],
          context: context,
        );
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
