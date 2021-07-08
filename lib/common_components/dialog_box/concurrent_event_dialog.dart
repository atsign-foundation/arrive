import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ConcurrentEventDialog extends StatelessWidget {
  final String event, inviteCount, eventDate;
  ConcurrentEventDialog(
      {this.inviteCount = '', this.event = '', this.eventDate = ''});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig().screenWidth * 0.8,
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        content: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Text(
                  'User Name wants to share an event with you. Are you sure you want to join and share your location with the group?',
                  style: CustomTextStyles().grey16,
                  textAlign: TextAlign.center,
                ),
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
                  bgColor: Theme.of(context).primaryColor,
                  width: 164.toWidth,
                  height: 48.toHeight,
                  child: Text(
                    'Yes! Create another',
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor),
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: null,
                  child: Text(
                    'No! Cancel this',
                    style: CustomTextStyles().black14,
                  ),
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
