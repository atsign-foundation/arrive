import 'dart:convert';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/custom_heading.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/custom_toast.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/services/event_services.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';

class OneDayEvent extends StatefulWidget {
  @override
  _OneDayEventState createState() => _OneDayEventState();
}

class _OneDayEventState extends State<OneDayEvent> {
  EventNotificationModel eventData = new EventNotificationModel();
  @override
  void initState() {
    super.initState();
    eventData = EventNotificationModel.fromJson(jsonDecode(
        EventNotificationModel.convertEventNotificationToJson(
            EventService().eventNotificationModel)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomHeading(heading: 'Select Timings', action: 'Cancel'),
                    SizedBox(height: 25),
                    Text('Date', style: CustomTextStyles().greyLabel14),
                    SizedBox(height: 6.toHeight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomInputField(
                          width: 155.toWidth,
                          height: 50.toHeight,
                          isReadOnly: true,
                          hintText: 'Start Date',
                          icon: Icons.date_range,
                          initialValue: (eventData.event.date != null)
                              ? dateToString(eventData.event.date)
                              : '',
                          onTap: () async {
                            final DateTime datePicked = await showDatePicker(
                                context: context,
                                initialDate: (eventData.event.date != null)
                                    ? eventData.event.date
                                    : DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030));

                            if (datePicked != null) {
                              setState(() {
                                eventData.event.date = datePicked;
                                if (eventData.event.endDate == null)
                                  eventData.event.endDate = datePicked;

                                if (eventData.event.startTime != null) {
                                  eventData.event.startTime = DateTime(
                                      eventData.event.date.year,
                                      eventData.event.date.month,
                                      eventData.event.date.day,
                                      eventData.event.startTime.hour,
                                      eventData.event.startTime.minute);
                                }
                              });
                            }
                          },
                        ),
                        CustomInputField(
                          width: 155.toWidth,
                          height: 50.toHeight,
                          isReadOnly: true,
                          hintText: 'End Date',
                          icon: Icons.date_range,
                          initialValue: (eventData.event.endDate != null)
                              ? dateToString(eventData.event.endDate)
                              : '',
                          onTap: () async {
                            final DateTime datePicked = await showDatePicker(
                                context: context,
                                initialDate: (eventData.event.endDate != null)
                                    ? eventData.event.endDate
                                    : DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030));

                            if (datePicked != null) {
                              setState(() {
                                eventData.event.endDate = datePicked;
                                if (eventData.event.endTime != null) {
                                  eventData.event.endTime = DateTime(
                                      eventData.event.endDate.year,
                                      eventData.event.endDate.month,
                                      eventData.event.endDate.day,
                                      eventData.event.endTime.hour,
                                      eventData.event.endTime.minute);
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Text('Time', style: CustomTextStyles().greyLabel14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomInputField(
                          width: 155.toWidth,
                          height: 50.toHeight,
                          isReadOnly: true,
                          hintText: 'Start',
                          icon: Icons.access_time,
                          initialValue: eventData.event.startTime != null
                              ? timeOfDayToString((eventData.event.startTime))
                              : '',
                          onTap: () async {
                            final TimeOfDay timePicked = await showTimePicker(
                                context: context,
                                initialTime: eventData.event.startTime != null
                                    ? TimeOfDay.fromDateTime(
                                        eventData.event.startTime)
                                    : TimeOfDay.now(),
                                initialEntryMode: TimePickerEntryMode.input);

                            if (eventData.event.date == null) {
                              eventData.event.date = DateTime.now();
                              eventData.event.endDate = DateTime.now();
                            }

                            if (timePicked != null) {
                              setState(() {
                                eventData.event.startTime = DateTime(
                                    eventData.event.date.year,
                                    eventData.event.date.month,
                                    eventData.event.date.day,
                                    timePicked.hour,
                                    timePicked.minute);
                              });
                            }
                          },
                        ),
                        CustomInputField(
                            width: 155.toWidth,
                            height: 50.toHeight,
                            hintText: 'Stop',
                            isReadOnly: true,
                            icon: Icons.access_time,
                            initialValue: eventData.event.endTime != null
                                ? timeOfDayToString(eventData.event.endTime)
                                : '',
                            onTap: () async {
                              final TimeOfDay timePicked = await showTimePicker(
                                  context: context,
                                  initialTime: eventData.event.endTime != null
                                      ? TimeOfDay.fromDateTime(
                                          eventData.event.endTime)
                                      : TimeOfDay.now(),
                                  initialEntryMode: TimePickerEntryMode.input);

                              if (eventData.event.endDate == null) {
                                CustomToast()
                                    .show('Select start time first', context);
                                return;
                              }

                              if (timePicked != null) {
                                setState(() {
                                  eventData.event.endTime = DateTime(
                                      eventData.event.endDate.year,
                                      eventData.event.endDate.month,
                                      eventData.event.endDate.day,
                                      timePicked.hour,
                                      timePicked.minute);
                                });
                              }
                            }),
                      ],
                    )
                  ],
                ),
              ),
              Center(
                child: CustomButton(
                  onPressed: () {
                    var formValid = EventService()
                        .checForOneDayEventFormValidation(eventData);
                    if (formValid is String) {
                      CustomToast().show(formValid, context);
                      return;
                    }
                    EventService().eventNotificationModel.event.isRecurring =
                        false;
                    EventService().update(eventData: eventData);
                    Navigator.of(context).pop();
                  },
                  buttonText: 'Done',
                  buttonColor: Theme.of(context).primaryColor,
                  fontColor: Theme.of(context).scaffoldBackgroundColor,
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
