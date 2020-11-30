import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String image;
  final double size;

  const CustomCircleAvatar({Key key, this.image, this.size = 50})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.toFont,
      width: size.toFont,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.toWidth),
      ),
      // border: Border.all(width: 0.5, color: ColorConstants.fontSecondary)),
      child: CircleAvatar(
        radius: (size - 5).toFont,
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage(image),
      ),
    );
  }
}
