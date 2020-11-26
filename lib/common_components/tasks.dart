import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class Tasks extends StatelessWidget {
  final Color color;
  final String task;
  Tasks({@required this.task, @required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 55.toHeight,
          width: 55.toWidth,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0), color: color),
        ),
        SizedBox(
          height: 5.toHeight,
        ),
        Text(
          task,
          style: CustomTextStyles().darkGrey14,
        )
      ],
    );
  }
}
