import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/screens/event/one_day_event.dart';
import 'package:atsign_location_app/screens/event/recurring_event.dart';
import 'package:atsign_location_app/screens/event/select_location.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CreateEvent extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.8,
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(
            centerTitle: false,
            title: 'Create an event',
            action: PopButton(label: 'Cancel'),
          ),
          SizedBox(
            height: 25,
          ),
          Text('Send To', style: CustomTextStyles().greyLabel14),
          SizedBox(height: 6.toHeight),
          CustomInputField(
            width: 330,
            height: 50,
            hintText: 'Type @sign or search from contact',
            icon: Icons.contacts_rounded,
          ),
          SizedBox(height: 25),
          Text(
            'Title',
            style: CustomTextStyles().greyLabel14,
          ),
          SizedBox(height: 6.toHeight),
          CustomInputField(
            width: 330,
            height: 50,
            hintText: 'Title of the event',
          ),
          SizedBox(height: 25),
          Text(
            'Add Venue',
            style: CustomTextStyles().greyLabel14,
          ),
          SizedBox(height: 6.toHeight),
          CustomInputField(
            width: 330,
            height: 50,
            hintText: 'Start typing or select from map',
          ),
          SizedBox(height: 25),
          Row(
            children: <Widget>[
              Expanded(
                child: Text('One Day Event',
                    style: CustomTextStyles().greyLabel14),
              ),
              Checkbox(
                value: true,
                onChanged: (value) {
                  print('$value');
                  bottomSheet(
                      context, OneDayEvent(), SizeConfig().screenHeight * 0.9);
                },
              )
            ],
          ),
          SizedBox(
            height: 20.toHeight,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Recurring Event',
                  style: CustomTextStyles().greyLabel14,
                ),
              ),
              Checkbox(
                value: false,
                onChanged: (value) {
                  print('$value');
                  bottomSheet(context, RecurringEvent(),
                      SizeConfig().screenHeight * 0.9);
                },
              )
            ],
          ),
          Expanded(child: SizedBox()),
          Center(
            child: CustomButton(
              child: Text('Create & Invite', style: CustomTextStyles().white15),
              onTap: () => bottomSheet(
                  context, SelectLocation(), SizeConfig().screenHeight * 0.9),
              bgColor: AllColors().Black,
              width: 160,
              height: 48,
            ),
          )
        ],
      ),
    );
  }
}
