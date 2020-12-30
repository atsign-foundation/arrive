import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';

class CustomPersonVerticalTile extends StatelessWidget {
  final String imageLocation, title, subTitle;
  final bool isTopRight;
  final IconData icon;

  CustomPersonVerticalTile({
    @required this.imageLocation,
    this.title = '',
    this.subTitle = '',
    this.isTopRight = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                height: 60,
                width: 60,
                child: CustomCircleAvatar(
                  size: 60,
                  image: imageLocation,
                ),
              ),
              icon != null
                  ? Positioned(
                      top: isTopRight ? 0 : null,
                      bottom: !isTopRight ? 0 : null,
                      right: 0,
                      child: Icon(icon))
                  : SizedBox(),
            ],
          ),
          SizedBox(height: 5.toHeight),
          Text(
            title,
            style: CustomTextStyles().black14,
          ),
          SizedBox(height: 5.toHeight),
          Text(
            subTitle,
            style: CustomTextStyles().darkGrey10,
          ),
        ],
      ),
    );
  }
}
