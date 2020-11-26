import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
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
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Create an event',
                            style: CustomTextStyles().black16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: CustomTextStyles().orange16,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text('Send To', style: CustomTextStyles().darkGrey14),
                  SizedBox(height: 6.toHeight),
                  CustomInputField(
                    width: 330,
                    height: 50,
                    hintText: 'Type @sign or search from contact',
                    isIcon: true,
                    icon: Icons.contacts_rounded,
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Title',
                    style: CustomTextStyles().darkGrey14,
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
                    style: CustomTextStyles().darkGrey14,
                  ),
                  SizedBox(height: 6.toHeight),
                  CustomInputField(
                    width: 330,
                    height: 50,
                    hintText: 'Start typing or select from map',
                    isIcon: false,
                  ),
                  SizedBox(height: 25),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: <Widget>[
                  // CustomInputField(
                  //   width: 150,
                  //   hintText: 'Select a date',
                  //   isIcon: true,
                  //   icon: Icons.calendar_today,
                  //   onTap: () async {
                  //     DateTime selectedDate = await showDatePicker(
                  //       context: context,
                  //       initialDate: DateTime.now(),
                  //       firstDate: DateTime(2020),
                  //       lastDate: DateTime.now(),
                  //       initialEntryMode: DatePickerEntryMode.calendar,
                  //     );

                  //     if (selectedDate != null) {
                  //       print('selected date: $selectedDate');
                  //     }
                  //   },
                  // ),
                  // CustomInputField(
                  //   width: 150,
                  //   hintText: 'Select a time',
                  //   isIcon: true,
                  //   icon: Icons.calendar_today,
                  //   onTap: () async {
                  //     TimeOfDay selectedTime = await showTimePicker(
                  //       context: context,
                  //       initialTime: TimeOfDay(hour: 00, minute: 00),
                  //     );

                  //     if (selectedTime != null) {
                  //       print('selected time: ${selectedTime}');
                  //     }
                  //   },
                  // ),
                  // ],
                  // ),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('One Day Event',
                            style: CustomTextStyles().darkGrey14),
                      ),
                      Checkbox(
                        value: true,
                        onChanged: (value) {
                          print('$value');
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
                          style: CustomTextStyles().darkGrey14,
                        ),
                      ),
                      Checkbox(
                        value: false,
                        onChanged: (value) {
                          print('$value');
                        },
                      )
                    ],
                  ),
                ],
              ),
              CustomButton(
                child: Text('Create & Invite',
                    style: TextStyle(color: AllColors().WHITE)),
                onTap: null,
                bgColor: AllColors().Black,
                width: 160,
                height: 48,
              )
            ],
          ),
        ),
      ),
    );
  }
}
