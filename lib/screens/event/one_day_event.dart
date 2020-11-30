import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/dialog_box/concurrent_event_dialog.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class OneDayEvent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomAppBar(
                      centerTitle: false,
                      title: 'One Day Event',
                      action: PopButton(label: 'Close'),
                    ),
                    SizedBox(height: 25),
                    Text('Select Date', style: CustomTextStyles().greyLabel14),
                    SizedBox(height: 6.toHeight),
                    CustomInputField(
                      width: 330,
                      height: 50,
                      hintText: 'Select Date',
                      isIcon: true,
                      icon: Icons.date_range,
                    ),
                    SizedBox(height: 25),
                    Text('Select Time', style: CustomTextStyles().greyLabel14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomInputField(
                          width: 155,
                          height: 50,
                          hintText: 'Start',
                          isIcon: true,
                          icon: Icons.access_time,
                        ),
                        CustomInputField(
                          width: 155,
                          height: 50,
                          hintText: 'Stop',
                          isIcon: true,
                          icon: Icons.access_time,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Center(
                child: CustomButton(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) => ConcurrentEventDialog(
                          event: 'Tina Birthday’s Party',
                          inviteCount: '10 people invited',
                          eventDate: '10:00 am on Nov, 14')),
                  child:
                      Text('Done', style: TextStyle(color: AllColors().WHITE)),
                  bgColor: AllColors().Black,
                  width: 164.toWidth,
                  height: 48.toHeight,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
