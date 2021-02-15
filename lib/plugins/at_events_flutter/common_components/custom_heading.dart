import 'package:atsign_location_app/plugins/at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class CustomHeading extends StatelessWidget {
  final String heading, action;
  CustomHeading({this.heading, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        heading != null
            ? Text(heading, style: CustomTextStyles().black18)
            : SizedBox(),
        action != null
            ? Text(action, style: CustomTextStyles().orange18)
            : SizedBox()
      ],
    );
  }
}
