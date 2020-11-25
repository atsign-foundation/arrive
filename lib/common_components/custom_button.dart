import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CustomButton extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsets padding;
  final Widget child;
  final Function onTap;
  final Color bgColor;
  final double radius;
  final Border border;
  final bool useDefaultRadius;

  CustomButton(
      {@required this.child,
      this.height = 50,
      @required this.onTap,
      this.padding,
      this.width = 50,
      @required this.bgColor,
      this.radius,
      this.border,
      this.useDefaultRadius = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width.toWidth,
        height: height.toHeight,
        padding: padding ?? EdgeInsets.all(0),
        child: child,
        decoration: BoxDecoration(
            color: bgColor,
            border: border ?? Border(),
            borderRadius:
                useDefaultRadius ? BorderRadius.circular(radius ?? 30) : null),
      ),
    );
  }
}
