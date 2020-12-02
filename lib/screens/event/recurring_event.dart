import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class RecurringEvent extends StatefulWidget {
  @override
  _RecurringEventState createState() => _RecurringEventState();
}

class _RecurringEventState extends State<RecurringEvent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.8,
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomAppBar(
                      centerTitle: false,
                      title: 'Recurring event',
                      action: PopButton(label: 'Cancel'),
                    ),
                    SizedBox(height: 25),
                    Text('Repeat every', style: CustomTextStyles().greyLabel14),
                    SizedBox(height: 6.toHeight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomInputField(
                          width: 155,
                          height: 50,
                          hintText: 'Start',
                          icon: Icons.keyboard_arrow_down,
                        ),
                        CustomInputField(
                          width: 155,
                          height: 50,
                          hintText: 'Stop',
                          icon: Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                    SizedBox(height: 25.toHeight),
                    Text('Occurs on', style: CustomTextStyles().greyLabel14),
                    SizedBox(height: 6.toHeight),
                    CustomInputField(
                      width: 330,
                      height: 50,
                      hintText: 'Select Day',
                      icon: Icons.keyboard_arrow_down,
                    ),
                    SizedBox(height: 25.toHeight),
                    Text('Select a time',
                        style: CustomTextStyles().greyLabel14),
                    SizedBox(height: 6.toHeight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomInputField(
                          width: 155,
                          height: 50,
                          hintText: 'Start',
                          icon: Icons.access_time,
                        ),
                        CustomInputField(
                          width: 155,
                          height: 50,
                          hintText: 'Stop',
                          icon: Icons.access_time,
                        ),
                      ],
                    ),
                    SizedBox(height: 25.toHeight),
                    Text('Ends On', style: CustomTextStyles().greyLabel14),
                    SizedBox(height: 25.toHeight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Never', style: CustomTextStyles().black14),
                        Radio(
                          groupValue: true,
                          toggleable: true,
                          value: true,
                          onChanged: (event) {
                            print('$event');
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 6.toHeight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('On', style: CustomTextStyles().black14),
                        Radio(
                          groupValue: true,
                          toggleable: true,
                          value: false,
                          onChanged: (event) {
                            print('$event');
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 6.toHeight),
                    CustomInputField(
                      width: 330.toWidth,
                      height: 50,
                      hintText: 'Select a Date',
                      icon: Icons.keyboard_arrow_down,
                    ),
                    SizedBox(height: 6.toHeight),
                    Text('After', style: CustomTextStyles().greyLabel14),
                    SizedBox(height: 6.toHeight),
                    CustomInputField(
                      width: 330.toWidth,
                      height: 50,
                      hintText: 'Select a Date',
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: CustomButton(
                onTap: null,
                child: Text('Done', style: CustomTextStyles().white15),
                bgColor: AllColors().Black,
                width: 164.toWidth,
                height: 48.toHeight,
              ),
            )
          ],
        ),
      ),
    );
  }
}
