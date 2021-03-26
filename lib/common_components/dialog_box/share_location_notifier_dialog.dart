import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/contacts_initials.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/custom_toast.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/services/event_services.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/screens/event/event_time_selection.dart';
import 'package:atsign_location_app/common_components/text_tile_repeater.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/services/request_location_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

// ignore: must_be_immutable
class ShareLocationNotifierDialog extends StatefulWidget {
  String event, invitedPeopleCount, timeAndDate, userName;
  final EventNotificationModel eventData;
  final LocationNotificationModel locationData;
  bool showMembersCount;

  int minutes;
  ShareLocationNotifierDialog(
      {this.eventData,
      this.event,
      this.locationData,
      this.invitedPeopleCount,
      this.timeAndDate,
      this.userName,
      this.showMembersCount = false});

  @override
  _ShareLocationNotifierDialogState createState() =>
      _ShareLocationNotifierDialogState();
}

class _ShareLocationNotifierDialogState
    extends State<ShareLocationNotifierDialog> {
  HybridProvider hybridProvider = HybridProvider();
  int minutes;
  EventNotificationModel concurrentEvent;
  bool isOverlap = false;
  AtContact contact;
  Uint8List image;
  String locationUserImageToShow;

  @override
  void initState() {
    if (widget.locationData != null) {
      locationUserImageToShow = (widget.locationData.atsignCreator ==
              BackendService.getInstance()
                  .atClientServiceInstance
                  .atClient
                  .currentAtSign
          ? widget.locationData.receiver
          : widget.locationData.atsignCreator);

      widget.userName = locationUserImageToShow;
    }
    if (widget.eventData != null) checkForEventOverlap();
    getEventCreator();
    super.initState();

    if (widget.eventData != null) {
      widget.showMembersCount = true;
    }
  }

  getEventCreator() async {
    AtContact contact = await getAtSignDetails(widget.eventData != null
        ? widget.eventData.atsignCreator
        : locationUserImageToShow);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        setState(() {
          image = Uint8List.fromList(intList);
        });
      }
    }
  }

  checkForEventOverlap() {
    List<HybridNotificationModel> allEventsExcludingCurrentEvent = [];
    List<HybridNotificationModel> allSavedEvents =
        HomeEventService().getAllEvents;
    dynamic overlapData = [];

    allSavedEvents.forEach((event) {
      if (event.notificationType == NotificationType.Event) {
        String keyMicrosecondId =
            event.key.split('createevent-')[1].split('@')[0];
        if (!event.key.contains(keyMicrosecondId)) {
          allEventsExcludingCurrentEvent.add(event);
        }
      }
    });
    overlapData = EventService().isEventTimeSlotOverlap(
        allEventsExcludingCurrentEvent, widget.eventData);
    isOverlap = overlapData[0];
    if (isOverlap != null) {
      if (isOverlap == true) concurrentEvent = overlapData[1];
    }
  }

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
                      (widget.eventData != null)
                          ? '${widget.userName} wants to share an event with you. Are you sure you want to join and share your location with the group?'
                          : ((!widget.locationData.isRequest)
                              ? '${widget.userName} wants to share their location with you. Are you sure you want to accept their location?'
                              : '${widget.userName} wants you to share your location. Are you sure you want to share?'),
                      style: CustomTextStyles().grey16,
                      textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  Stack(
                    children: [
                      image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.toFont)),
                              child: Image.memory(
                                image,
                                width: 50.toFont,
                                height: 50.toFont,
                                fit: BoxFit.fill,
                              ),
                            )
                          : ContactInitial(
                              initials: widget.eventData != null
                                  ? widget.eventData.atsignCreator
                                      .substring(1, 3)
                                  : locationUserImageToShow.substring(1, 3),
                              size: 60,
                            ),
                      widget.showMembersCount
                          ? Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AllColors().BLUE,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                    child: Text(
                                  '+${widget.eventData.group.members.length}',
                                  style: CustomTextStyles().black10,
                                )),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  SizedBox(height: widget.eventData != null ? 10.toHeight : 0),
                  widget.eventData != null
                      ? Text(
                          widget.eventData.title,
                          style: CustomTextStyles().black18,
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(),
                  SizedBox(height: widget.eventData != null ? 5.toHeight : 0),
                  widget.eventData != null
                      ? Text(
                          (widget.eventData.group.members.length == 1)
                              ? '${widget.eventData.group.members.length} person invited'
                              : '${widget.eventData.group.members.length} people invited',
                          style: CustomTextStyles().grey14)
                      : SizedBox(),
                  SizedBox(height: widget.eventData != null ? 10.toHeight : 0),
                  widget.eventData != null
                      ? Text(
                          '${timeOfDayToString(widget.eventData.event.startTime)} on ${dateToString(widget.eventData.event.date)}',
                          style: CustomTextStyles().black14)
                      : SizedBox(),
                  isOverlap ? SizedBox(height: 10.toHeight) : SizedBox(),
                  isOverlap ? Divider(height: 2) : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  isOverlap
                      ? Text(
                          'You already have an event scheduled during this hour. Are you sure you want to accept another?',
                          textAlign: TextAlign.center,
                          style: CustomTextStyles().grey16,
                        )
                      : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  isOverlap
                      ? Text(concurrentEvent.title,
                          style: CustomTextStyles().black18)
                      : SizedBox(),
                  SizedBox(height: 5.toHeight),
                  SizedBox(height: 10.toHeight),
                  isOverlap
                      ? Text(
                          '${timeOfDayToString(concurrentEvent.event.startTime)} on ${dateToString(concurrentEvent.event.date)}',
                          style: CustomTextStyles().black14)
                      : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  CustomButton(
                    onTap: () => () async {
                      (widget.eventData != null)
                          // ignore: unnecessary_statements
                          ? {
                              bottomSheet(
                                  context,
                                  EventTimeSelection(
                                      eventNotificationModel: widget.eventData,
                                      title: AllText().LOC_START_TIME_TITLE,
                                      isStartTime: true,
                                      options: MixedConstants.startTimeOptions,
                                      onSelectionChanged: (dynamic startTime) {
                                        widget.eventData.group.members
                                                .elementAt(0)
                                                .tags['shareFrom'] =
                                            startTime.toString();

                                        bottomSheet(
                                            context,
                                            EventTimeSelection(
                                              eventNotificationModel:
                                                  widget.eventData,
                                              title:
                                                  AllText().LOC_END_TIME_TITLE,
                                              options:
                                                  MixedConstants.endTimeOptions,
                                              onSelectionChanged:
                                                  (dynamic endTime) {
                                                widget.eventData.group.members
                                                        .elementAt(0)
                                                        .tags['shareTo'] =
                                                    endTime.toString();
                                                Navigator.of(context).pop();

                                                updateEvent(widget.eventData);
                                              },
                                            ),
                                            400);
                                      }),
                                  400)
                            }
                          // ignore: unnecessary_statements
                          : ((!widget.locationData.isRequest)
                              ? {
                                  await LocationSharingService()
                                      .shareLocationAcknowledgment(
                                          true, widget.locationData, true),
                                  CustomToast().show(
                                      'Request to update data is submitted',
                                      context),
                                  Navigator.of(context).pop(),
                                }
                              : {
                                  Navigator.of(context).pop(),
                                  timeSelect(context),
                                });
                    }(),
                    child: Text('Yes',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 15.toFont)),
                    bgColor: Theme.of(context).primaryColor,
                    width: 164,
                    height: 48.toHeight,
                  ),
                  SizedBox(height: 10.toHeight),
                  InkWell(
                    onTap: () async {
                      (widget.eventData != null)
                          // ignore: unnecessary_statements
                          ? {
                              widget.eventData.group.members.forEach((element) {
                                if (element.atSign ==
                                    BackendService.getInstance()
                                        .atClientServiceInstance
                                        .atClient
                                        .currentAtSign) {
                                  element.tags['isAccepted'] = false;
                                  element.tags['isExited'] = true;
                                }
                              }),
                              providerCallback<EventProvider>(context,
                                  task: (t) => t.actionOnEvent(widget.eventData,
                                      ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
                                      isAccepted: false, isExited: true),
                                  taskName: (t) => t.UPDATE_EVENTS,
                                  onSuccess: (t) {
                                    Navigator.of(context).pop();
                                  }),
                            }
                          // ignore: unnecessary_statements
                          : ((!widget.locationData.isRequest)
                              ? {
                                  await LocationSharingService()
                                      .shareLocationAcknowledgment(
                                          true, widget.locationData, false),
                                  CustomToast().show(
                                      'Request to update data is submitted',
                                      context),
                                  Navigator.of(context).pop(),
                                }
                              : {
                                  await RequestLocationService()
                                      .requestLocationAcknowledgment(
                                          widget.locationData, false),
                                  CustomToast().show(
                                      'Request to update data is submitted',
                                      context),
                                  Navigator.of(context).pop(),
                                });
                    },
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

  timeSelect(BuildContext context) {
    int result;
    bottomSheet(
        context,
        TextTileRepeater(
          title: 'How long do you want to share your location for ?',
          options: ['30 mins', '2 hours', '24 hours', 'Until turned off'],
          onChanged: (value) {
            result = (value == '30 mins'
                ? 30
                : (value == '2 hours'
                    ? (2 * 60)
                    : (value == '24 hours' ? (24 * 60) : null)));
          },
        ),
        350, onSheetCLosed: () async {
      await RequestLocationService().requestLocationAcknowledgment(
          widget.locationData, true,
          minutes: result);
      CustomToast().show('Request to update data is submitted', context);
      return result;
    });
  }
}

updateEvent(EventNotificationModel eventData) {
  providerCallback<EventProvider>(NavService.navKey.currentContext,
      task: (t) => t.actionOnEvent(eventData, ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
          isAccepted: true, isSharing: true, isExited: false),
      taskName: (t) => t.UPDATE_EVENTS,
      onSuccess: (t) {
        Navigator.of(NavService.navKey.currentContext).pop();
        Navigator.of(NavService.navKey.currentContext).pop();
      });
}
