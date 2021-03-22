import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class CustomHeading extends StatelessWidget {
  final String heading, action;
  CustomHeading({this.heading, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          heading != null
              ? Text(heading,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.headline1.color,
                      fontSize: 18.toFont))
              : SizedBox(),
          action != null
              ? Text(action,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.headline2.color,
                      fontSize: 18.toFont))
              : SizedBox()
        ],
      ),
    );
  }
}
