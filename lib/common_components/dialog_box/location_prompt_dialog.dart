import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:atsign_location_app/services/location_notification_listener.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

import '../custom_button.dart';

locationPromptDialog({
  String text,
  String yesText,
  String noText,
  Function onYesTap,
  Function onNoTap,
}) {
  return showDialog<void>(
    context: NavService.navKey.currentContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return LocationPrompt();
    },
  );
}

class LocationPrompt extends StatelessWidget {
  final String text, yesText, noText;
  final Function onYesTap, onNoTap;
  LocationPrompt(
      {this.text, this.yesText, this.noText, this.onNoTap, this.onYesTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig().screenWidth * 0.8,
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 20),
        content: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Text(
                  text ??
                      'Your main location sharing switch is turned off. Do you want to turn it on?',
                  style: CustomTextStyles().grey16,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                CustomButton(
                  onTap: onYesTap ??
                      () async {
                        await LocationNotificationListener()
                            .updateShareLocation(true);
                        return Navigator.of(context).pop();
                      },
                  child: Text(
                    yesText ?? 'Yes! Turn it on',
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor),
                  ),
                  bgColor: Theme.of(context).primaryColor,
                  width: 164.toWidth,
                  height: 48.toHeight,
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: onNoTap ?? () => Navigator.of(context).pop(),
                  child: Text(
                    noText ?? 'No!',
                    style: CustomTextStyles().black14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
