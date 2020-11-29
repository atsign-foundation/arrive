import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CustomEventCard extends StatelessWidget {
  final Text eventAndGroupName,
      invitedByLabel,
      shareLocationDurationLable,
      eventDate;

  CustomEventCard({
    this.eventAndGroupName,
    this.invitedByLabel,
    this.shareLocationDurationLable,
    this.eventDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.toWidth),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 60.toWidth,
            width: 60.toWidth,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                fit: BoxFit.cover,
                image: new AssetImage(AllImages().PERSON2),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 30.toWidth,
                    height: 30.toWidth,
                    decoration: new BoxDecoration(
                      color: AllColors().EVENT_MEMBERS,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '+10',
                        style: CustomTextStyles().black10,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 10.toWidth),
          Expanded(
            child: Container(
              //color: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  eventAndGroupName ?? SizedBox(),
                  SizedBox(height: 6.toHeight),
                  shareLocationDurationLable ?? SizedBox(),
                  SizedBox(height: 6.toHeight),
                  eventDate ?? SizedBox(),
                  SizedBox(height: eventDate != null ? 10.toHeight : 0),
                  invitedByLabel ?? SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
