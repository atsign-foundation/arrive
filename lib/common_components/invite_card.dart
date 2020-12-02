import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class InviteCard extends StatelessWidget {
  final String event, invitedPeopleCount, timeAndDate;
  InviteCard({this.event, this.invitedPeopleCount, this.timeAndDate});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: [
              CustomCircleAvatar(image: AllImages().PERSON2, size: 74),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AllColors().BLUE,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(
                    '+10',
                    style: CustomTextStyles().black10,
                  )),
                ),
              )
            ],
          ),
          SizedBox(width: 10.toWidth),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                event != null
                    ? Text(event, style: CustomTextStyles().black18)
                    : SizedBox(),
                SizedBox(height: 5.toHeight),
                invitedPeopleCount != null
                    ? Text(invitedPeopleCount, style: CustomTextStyles().grey14)
                    : SizedBox(),
                SizedBox(height: 10.toHeight),
                timeAndDate != null
                    ? Text(timeAndDate, style: CustomTextStyles().black14)
                    : SizedBox(),
              ],
            ),
          ),
          PopButton(label: 'Decide Later')
        ],
      ),
    );
  }
}
