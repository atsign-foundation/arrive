import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class ShareLocationNotifierDialog extends StatelessWidget {
  final String event, invitedPeopleCount, timeAndDate;
  ShareLocationNotifierDialog(
      {this.event, this.invitedPeopleCount, this.timeAndDate});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(10, 20, 5, 10),
        content: Container(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                      'User Name wants to share an event with you. Are you sure you want to join and share your location with the group?',
                      style: CustomTextStyles().grey16,
                      textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  Stack(
                    children: [
                      CustomCircleAvatar(
                          image: AllImages().PERSON2, size: 74.toHeight),
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
                  SizedBox(height: 10.toHeight),
                  event != null
                      ? Text(event, style: CustomTextStyles().black18)
                      : SizedBox(),
                  SizedBox(height: 5.toHeight),
                  invitedPeopleCount != null
                      ? Text(invitedPeopleCount,
                          style: CustomTextStyles().grey14)
                      : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  timeAndDate != null
                      ? Text(timeAndDate, style: CustomTextStyles().black14)
                      : SizedBox(),
                  SizedBox(height: 20.toHeight),
                  CustomButton(
                    onTap: () => null,
                    child:
                        Text('Yes', style: TextStyle(color: AllColors().WHITE)),
                    bgColor: AllColors().Black,
                    width: 164.toWidth,
                    height: 48.toHeight,
                  ),
                  SizedBox(height: 5),
                  CustomButton(
                    onTap: () => null,
                    child:
                        Text('No', style: TextStyle(color: AllColors().Black)),
                    bgColor: AllColors().WHITE,
                    width: 164.toWidth,
                    height: 48.toHeight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
