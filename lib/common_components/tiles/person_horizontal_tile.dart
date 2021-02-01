import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';

class CustomPersonHorizontalTile extends StatelessWidget {
  final String imageLocation, title, subTitle;
  final bool isTopRight;
  final IconData icon;

  CustomPersonHorizontalTile({
    @required this.imageLocation,
    this.title = '',
    this.subTitle = '',
    this.isTopRight = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Stack(
            children: [
              CustomCircleAvatar(
                size: 60,
                image: imageLocation,
              ),
              icon != null
                  ? Positioned(
                      top: isTopRight ? 0 : null,
                      right: 0,
                      bottom: !isTopRight ? 0 : null,
                      child: Icon(icon))
                  : SizedBox(),
            ],
          ),
          SizedBox(width: 10.toHeight),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          )
        ],
      ),
    );
  }
}
