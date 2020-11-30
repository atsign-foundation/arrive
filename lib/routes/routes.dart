import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/screens/event/event_log.dart';
import 'package:atsign_location_app/screens/faqs/faqs.dart';
import 'package:atsign_location_app/screens/group/edit/group_edit.dart';
import 'package:atsign_location_app/screens/group/list/group_list.dart';
import 'package:atsign_location_app/screens/group/members/group_members.dart';
import 'package:atsign_location_app/screens/group/group_view/group_view.dart';
import 'package:atsign_location_app/screens/group/new_group/new_group.dart';
import 'package:atsign_location_app/screens/home/home_screen.dart';
import 'package:atsign_location_app/screens/share_location/share_location_event/share_location_event.dart';
import 'package:atsign_location_app/screens/selected_location.dart/selected_location.dart';
import 'package:atsign_location_app/screens/splash/splash.dart';
import 'package:atsign_location_app/screens/terms_conditions/terms_conditions_screen.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.SPLASH;
  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.SPLASH: (context) => Splash(),
      Routes.HOME: (context) => HomeScreen(),
      Routes.EVENT_LOG: (context) => EventLog(),
      Routes.FAQS: (context) => FaqsScreen(),
      Routes.TERMS_CONDITIONS_SCREEN: (context) => TermsConditions(),
      Routes.GROUP_LIST: (context) => GroupList(),
      Routes.NEW_GROUP: (context) => NewGroup(),
      Routes.GROUP_VIEW: (context) => GroupView(),
      Routes.GROUP_EDIT: (context) => GroupEdit(),
      Routes.GROUP_MEMBERS: (context) => GroupMembers(),
      Routes.SHARE_LOCATION_EVENT: (context) => ShareLocationEvent(),
      Routes.SELECTED_LOCATION: (context) => SelectedLocation(),
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
