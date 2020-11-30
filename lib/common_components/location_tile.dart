import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class LocationTile extends StatelessWidget {
  final String title, subTitle;
  final IconData icon;

  LocationTile({this.title = '', this.subTitle = '', this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          icon != null ? Icon(icon, color: AllColors().ORANGE) : SizedBox(),
          SizedBox(width: 15.toWidth),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: CustomTextStyles().greyLabel14),
                Text(subTitle, style: CustomTextStyles().greyLabel12),
              ],
            ),
          )
        ],
      ),
    );
  }
}
