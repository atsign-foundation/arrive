import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class Tasks extends StatelessWidget {
  final IconData icon;
  final String task;
  final Function onTap;
  final double angle;
  Tasks(
      {@required this.task,
      @required this.icon,
      @required this.onTap,
      this.angle = 0.0});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44.toHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Transform.rotate(
              angle: angle,
              child: Icon(
                icon,
                size: 20.toWidth,
                color: AllColors().ORANGE,
              ),
            ),
            Flexible(
              child: Text(
                task,
                style: Theme.of(context).primaryTextTheme.headline3,
              ),
            )
          ],
        ),
      ),
    );
  }
}
