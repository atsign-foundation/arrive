import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class ConcurrentEventDialog extends StatelessWidget {
  final String event, inviteCount, eventDate;
  ConcurrentEventDialog(
      {this.inviteCount = '', this.event = '', this.eventDate = ''});
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100,
      width: SizeConfig().screenWidth * 0.8,
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        content: SingleChildScrollView(
          child: Container(
            // padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Column(
              children: <Widget>[
                Text('You already have an event scheduled',
                    style: CustomTextStyles().grey16),
                SizedBox(height: 5),
                Text('during this hours. Are you sure you',
                    style: CustomTextStyles().grey16),
                SizedBox(height: 5),
                Text('want to create another?',
                    style: CustomTextStyles().grey16),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(event, style: CustomTextStyles().black16),
                SizedBox(height: 5),
                Text(inviteCount, style: CustomTextStyles().grey14),
                SizedBox(height: 5),
                Text(eventDate, style: CustomTextStyles().black14),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                CustomButton(
                  onTap: () => null,
                  child: Text('Yes! Create another',
                      style: TextStyle(color: AllColors().WHITE)),
                  bgColor: AllColors().Black,
                  width: 164.toWidth,
                  height: 48.toHeight,
                ),
                SizedBox(height: 5),
                CustomButton(
                  onTap: () => null,
                  child: Text('No! Cancel this',
                      style: TextStyle(color: AllColors().Black)),
                  bgColor: AllColors().WHITE,
                  width: 164.toWidth,
                  height: 48.toHeight,
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
