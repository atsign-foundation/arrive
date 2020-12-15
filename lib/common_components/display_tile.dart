import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class DisplayTile extends StatelessWidget {
  final String title, semiTitle, subTitle, image, invitedBy;
  final int number;
  final Widget action;
  DisplayTile(
      {@required this.title,
      @required this.image,
      @required this.subTitle,
      this.semiTitle,
      this.invitedBy,
      this.number,
      this.action});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.5),
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
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headline2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 3,
                ),
                semiTitle != null
                    ? Text(
                        semiTitle,
                        style: semiTitle == 'Action required'
                            ? CustomTextStyles().orange12
                            : CustomTextStyles().darkGrey12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox(),
                SizedBox(
                  height: 3,
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
          action ?? SizedBox()
        ],
      ),
    );
  }
}
