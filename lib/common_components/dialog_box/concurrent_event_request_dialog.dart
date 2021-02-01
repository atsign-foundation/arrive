import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';

class ConcurrentEventRequest extends StatelessWidget {
  final String reqEvent,
      reqInvitedPeopleCount,
      reqTimeAndDate,
      currentEvent,
      currentEventTimeAndDate;
  ConcurrentEventRequest(
      {this.reqEvent,
      this.reqInvitedPeopleCount,
      this.reqTimeAndDate,
      this.currentEvent,
      this.currentEventTimeAndDate});

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
                    'User Name wants to share an event with you',
                    style: CustomTextStyles().grey16,
                    textAlign: TextAlign.center,
                  ),
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
                  reqEvent != null
                      ? Text(reqEvent, style: CustomTextStyles().black18)
                      : SizedBox(),
                  SizedBox(height: 5.toHeight),
                  reqInvitedPeopleCount != null
                      ? Text(reqInvitedPeopleCount,
                          style: CustomTextStyles().grey14)
                      : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  reqTimeAndDate != null
                      ? Text(reqTimeAndDate, style: CustomTextStyles().black14)
                      : SizedBox(),
                  SizedBox(height: 20.toHeight),
                  Divider(),
                  Text(
                    'You already have an event scheduled during this hour. Are you sure you want to accept another?',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles().grey16,
                  ),
                  SizedBox(height: 15.toHeight),
                  currentEvent != null
                      ? Text(currentEvent, style: CustomTextStyles().black16)
                      : SizedBox(),
                  currentEventTimeAndDate != null
                      ? Text(currentEventTimeAndDate,
                          style: CustomTextStyles().black14)
                      : SizedBox(),
                  SizedBox(height: 20.toHeight),
                  CustomButton(
                    onTap: () => null,
                    child: Text('Yes',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor)),
                    bgColor: Theme.of(context).primaryColor,
                    width: 164.toWidth,
                    height: 48.toHeight,
                  ),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: null,
                    child: Text(
                      'No',
                      style: CustomTextStyles().black14,
                    ),
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
