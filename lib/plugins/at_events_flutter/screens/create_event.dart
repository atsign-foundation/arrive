import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_common_flutter/widgets/custom_input_field.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/bottom_sheet.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/custom_toast.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/error_screen.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/overlapping-contacts.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/screens/one_day_event.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/screens/recurring_event.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/custom_heading.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/screens/select_location.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/services/event_services.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

import '../at_events_flutter.dart';

class CreateEvent extends StatefulWidget {
  final AtClientImpl atClientInstance;
  final EventNotificationModel eventData;
  final ValueChanged<EventNotificationModel> onEventSaved;
  final List<HybridNotificationModel> createdEvents;
  final isUpdate;
  CreateEvent(this.atClientInstance,
      {this.isUpdate = false,
      this.eventData,
      this.onEventSaved,
      this.createdEvents});
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  List<AtContact> selectedContactList;
  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
    EventService().init(
        widget.atClientInstance,
        widget.isUpdate != null ? widget.isUpdate : false,
        widget.eventData != null ? widget.eventData : null);
    if (widget.createdEvents != null) {
      EventService().createdEvents = widget.createdEvents;
    }

    if (widget.onEventSaved != null) {
      EventService().onEventSaved = widget.onEventSaved;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: SizeConfig().screenHeight * 1,
      padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
      child: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    StreamBuilder(
                        stream: EventService().eventStream,
                        builder: (BuildContext context, snapshot) {
                          EventNotificationModel eventData = snapshot.data;

                          if (eventData != null && snapshot.hasData) {
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CustomHeading(
                                      heading: 'Create an event',
                                      action: 'Cancel'),
                                  SizedBox(height: 25),
                                  Text('Send To',
                                      style: CustomTextStyles().greyLabel14),
                                  SizedBox(height: 6.toHeight),
                                  CustomInputField(
                                    width: 330.toWidth,
                                    height: 50,
                                    isReadOnly: true,
                                    hintText:
                                        'Type @sign or search from contact',
                                    icon: Icons.contacts_rounded,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ContactsScreen(
                                            asSelectionScreen: true,
                                            context: context,
                                            selectedList: (selectedList) {
                                              selectedContactList =
                                                  selectedList;

                                              if (selectedContactList.length >
                                                  0) {
                                                EventService()
                                                    .addNewGroupMembers(
                                                        selectedContactList);
                                                EventService().update();
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 25),
                                  (EventService().selectedContacts != null &&
                                          EventService()
                                                  .selectedContacts
                                                  .length >
                                              0)
                                      ? (OverlappingContacts(
                                          selectedList:
                                              EventService().selectedContacts))
                                      : SizedBox(),
                                  (EventService().selectedContacts != null &&
                                          EventService()
                                                  .selectedContacts
                                                  .length >
                                              0)
                                      ? SizedBox(height: 25)
                                      : SizedBox(),
                                  Text(
                                    'Title',
                                    style: CustomTextStyles().greyLabel14,
                                  ),
                                  SizedBox(height: 6.toHeight),
                                  CustomInputField(
                                    width: 330.toWidth,
                                    height: 50,
                                    hintText: 'Title of the event',
                                    initialValue: eventData.title != null
                                        ? eventData.title
                                        : '',
                                    value: (val) {
                                      EventService()
                                          .eventNotificationModel
                                          .title = val;
                                    },
                                  ),
                                  SizedBox(height: 25),
                                  Text('Add Venue',
                                      style: CustomTextStyles().greyLabel14),
                                  SizedBox(height: 6.toHeight),
                                  CustomInputField(
                                    width: 330.toWidth,
                                    height: 50,
                                    isReadOnly: true,
                                    hintText: 'Start typing or select from map',
                                    initialValue: eventData.venue.label != null
                                        ? eventData.venue.label
                                        : '',
                                    onTap: () => bottomSheet(
                                        context,
                                        SelectLocation(),
                                        SizeConfig().screenHeight * 0.9),
                                  ),
                                  SizedBox(height: 25),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text('One Day Event',
                                            style:
                                                CustomTextStyles().greyLabel14),
                                      ),
                                      Checkbox(
                                        value: (EventService()
                                                        .eventNotificationModel
                                                        .event
                                                        .isRecurring !=
                                                    null &&
                                                EventService()
                                                        .eventNotificationModel
                                                        .event
                                                        .isRecurring ==
                                                    false)
                                            ? true
                                            : false,
                                        onChanged: (value) {
                                          print(value);

                                          if (value) {
                                            EventService()
                                                .eventNotificationModel
                                                .event
                                                .isRecurring = !value;
                                            EventService().update();
                                          }
                                          bottomSheet(context, OneDayEvent(),
                                              SizeConfig().screenHeight * 0.9);
                                        },
                                      )
                                    ],
                                  ),
                                  (EventService()
                                              .eventNotificationModel
                                              .event
                                              .isRecurring ==
                                          false)
                                      ? (EventService()
                                                      .eventNotificationModel
                                                      .event
                                                      .date !=
                                                  null &&
                                              EventService()
                                                      .eventNotificationModel
                                                      .event
                                                      .startTime !=
                                                  null &&
                                              EventService()
                                                      .eventNotificationModel
                                                      .event
                                                      .endTime !=
                                                  null)
                                          ? Text(
                                              'Event on ${dateToString(eventData.event.date)} (${timeOfDayToString(eventData.event.startTime)}- ${timeOfDayToString(eventData.event.endTime)})')
                                          : SizedBox()
                                      : SizedBox(),
                                  SizedBox(height: 20.toHeight),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          'Recurring Event',
                                          style: CustomTextStyles().greyLabel14,
                                        ),
                                      ),
                                      Checkbox(
                                        value: (EventService()
                                                        .eventNotificationModel
                                                        .event
                                                        .isRecurring !=
                                                    null &&
                                                EventService()
                                                        .eventNotificationModel
                                                        .event
                                                        .isRecurring ==
                                                    true)
                                            ? true
                                            : false,
                                        onChanged: (value) {
                                          if (value) {
                                            EventService()
                                                .eventNotificationModel
                                                .event
                                                .isRecurring = value;

                                            EventService().update();
                                          }
                                          bottomSheet(context, RecurringEvent(),
                                              SizeConfig().screenHeight * 0.9);
                                        },
                                      )
                                    ],
                                  ),
                                  (EventService()
                                                  .eventNotificationModel
                                                  .event
                                                  .isRecurring !=
                                              null &&
                                          EventService()
                                                  .eventNotificationModel
                                                  .event
                                                  .isRecurring ==
                                              true)
                                      ? Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              (eventData.event.repeatCycle ==
                                                          RepeatCycle.MONTH &&
                                                      eventData.event.date !=
                                                          null &&
                                                      eventData.event
                                                              .repeatDuration !=
                                                          null)
                                                  ? Text(
                                                      'Repeats every ${eventData.event.repeatDuration} month on ${eventData.event.date.day} day')
                                                  : (eventData.event
                                                                  .repeatCycle ==
                                                              RepeatCycle
                                                                  .WEEK &&
                                                          eventData.event
                                                                  .occursOn !=
                                                              null)
                                                      ? Text(
                                                          'Repeats every ${eventData.event.repeatDuration} week on ${getWeekString(eventData.event.occursOn)}')
                                                      : SizedBox(),
                                              EventService()
                                                              .eventNotificationModel
                                                              .event
                                                              .endsOn !=
                                                          null &&
                                                      EventService()
                                                              .eventNotificationModel
                                                              .event
                                                              .endsOn ==
                                                          EndsOn.AFTER
                                                  ? Text(
                                                      'Ends after ${eventData.event.endEventAfterOccurance} occurrence')
                                                  : SizedBox(),
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: ErrorScreen(
                                onPressed: EventService().init(
                                    widget.atClientInstance,
                                    widget.isUpdate != null
                                        ? widget.isUpdate
                                        : false,
                                    widget.eventData != null
                                        ? widget.eventData
                                        : null),
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        }),
                  ],
                ),
              )),
              Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : CustomButton(
                        buttonText:
                            widget.isUpdate ? 'Save' : 'Create & Invite',
                        onPressed: onCreateEvent,
                        width: 160,
                        height: 48,
                        buttonColor: Theme.of(context).primaryColor,
                        fontColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onCreateEvent() async {
    setState(() {
      isLoading = true;
    });

    var formValid = EventService().createEventFormValidation();
    if (formValid is String) {
      CustomToast().show(formValid, context);
      setState(() {
        isLoading = false;
      });
      return;
    }

    bool isOverlap = EventService().showConcurrentEventDialog(
        widget.createdEvents, EventService().eventNotificationModel, context);

    if (isOverlap) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    var result = await EventService().createEvent();

    if (result is bool && result == true) {
      CustomToast().show(
          EventService().isEventUpdate ? 'Event updated' : 'Event added',
          context);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show('some thing went wrong , try again.', context);
      setState(() {
        isLoading = false;
      });
    }
  }
}