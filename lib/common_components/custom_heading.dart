import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class CustomHeading extends StatelessWidget {
  final String heading, action;
  CustomHeading({this.heading, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          heading != null
              ? Text(heading, style: Theme.of(context).textTheme.headline1)
              : SizedBox(),
          Expanded(child: SizedBox()),
          action != null
              ? Text(action, style: CustomTextStyles().orange16)
              : SizedBox()
        ],
      ),
    );
  }
}
