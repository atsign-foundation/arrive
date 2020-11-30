import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class DisplayTile extends StatelessWidget {
  final String title, semiTitle, subTitle, image, invitedBy;
  final int number;
  DisplayTile(
      {@required this.title,
      @required this.image,
      @required this.subTitle,
      this.semiTitle,
      this.invitedBy,
      this.number});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.5.toHeight),
      child: Row(
        children: [
          Stack(
            children: [
              CustomCircleAvatar(
                image: image,
                size: 46,
              ),
              number != null
                  ? Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        alignment: Alignment.center,
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: AllColors().BLUE),
                        child: Text(
                          '+$number',
                          style: CustomTextStyles().black10,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Flexible(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyles().darkGrey14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 3.toHeight,
                ),
                semiTitle != null
                    ? Text(
                        semiTitle,
                        style: CustomTextStyles().orange12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox(),
                SizedBox(
                  height: 3.toHeight,
                ),
                Text(
                  subTitle,
                  style: CustomTextStyles().darkGrey12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                invitedBy != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child:
                            Text(invitedBy, style: CustomTextStyles().grey14),
                      )
                    : SizedBox()
              ],
            ),
          )),
        ],
      ),
    );
  }
}
