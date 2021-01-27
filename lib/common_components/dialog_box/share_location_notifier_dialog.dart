import 'package:at_commons/at_commons.dart';
import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_events/services/event_services.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/common_components/provider_handler.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/notification_service.dart';
import 'package:atsign_location_app/services/request_location_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';

class ShareLocationNotifierDialog extends StatelessWidget {
  final String event, invitedPeopleCount, timeAndDate, userName;
  final EventNotificationModel eventData;
  final LocationNotificationModel locationData;
  final bool showMembersCount;
  ShareLocationNotifierDialog(
      {this.eventData,
      this.event,
      this.locationData,
      this.invitedPeopleCount,
      this.timeAndDate,
      this.userName,
      this.showMembersCount = false});
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
                      (eventData != null)
                          ? '$userName wants to share an event with you. Are you sure you want to join and share your location with the group?'
                          : ((locationData != null)
                              ? '$userName wants to share their location with you. Are you sure you want to accept their location?'
                              : '$userName wants you to share your location? Are you sure you want to share?'),
                      style: CustomTextStyles().grey16,
                      textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  Stack(
                    children: [
                      CustomCircleAvatar(
                          image: AllImages().PERSON2, size: 74.toHeight),
                      showMembersCount
                          ? Positioned(
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
                          : SizedBox()
                    ],
                  ),
                  SizedBox(height: 10.toHeight),
                  event != null
                      ? Text(event, style: CustomTextStyles().black18)
                      : SizedBox(),
                  SizedBox(height: 5.toHeight),
                  invitedPeopleCount != null
                      ? Text(invitedPeopleCount,
                          style: CustomTextStyles().grey14)
                      : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  timeAndDate != null
                      ? Text(timeAndDate, style: CustomTextStyles().black14)
                      : SizedBox(),
                  SizedBox(height: 20.toHeight),
                  CustomButton(
                    onTap: () => () async {
                      (eventData != null)
                          ? providerCallback<EventProvider>(context,
                              task: (t) => t.actionOnEvent(
                                  eventData, ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
                                  isAccepted: true),
                              taskName: (t) => t.UPDATE_EVENTS,
                              onSuccess: (t) {
                                Navigator.of(context).pop();
                                t.getAllEvents();
                              })
                          : ((!locationData.isRequest)
                              //locationData.atsignCreator != ClientSdkService.getInstance().currentAtsign
                              ? {
                                  print('accept share location'),
                                  LocationSharingService()
                                      .shareLocationAcknowledgment(
                                          true, locationData, true),
                                  Navigator.of(context).pop(),
                                }
                              : {
                                  RequestLocationService()
                                      .requestLocationAcknowledgment(
                                          locationData, true),
                                  Navigator.of(context).pop(),
                                });
                    }(),
                    child: Text('Yes',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor)),
                    bgColor: Theme.of(context).primaryColor,
                    width: 164.toWidth,
                    height: 48.toHeight,
                  ),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () async {
                      (eventData != null)
                          ? {
                              print('${eventData.key}'),
                              eventData.group.members.forEach((element) {
                                if (element.atSign ==
                                    ClientSdkService.getInstance()
                                        .atClientServiceInstance
                                        .atClient
                                        .currentAtSign) {
                                  element.tags['isAccepted'] = false;
                                  element.tags['isExited'] = false;
                                }
                              }),
                              providerCallback<EventProvider>(context,
                                  task: (t) => t.actionOnEvent(eventData,
                                      ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
                                      isAccepted: false),
                                  taskName: (t) => t.UPDATE_EVENTS,
                                  onSuccess: (t) {
                                    Navigator.of(context).pop();
                                    t.getAllEvents();
                                  }),
                            }
                          : ((!locationData.isRequest)
                              //locationData.atsignCreator != ClientSdkService.getInstance().currentAtsign
                              ? {
                                  print('accept share location'),
                                  LocationSharingService()
                                      .shareLocationAcknowledgment(
                                          true, locationData, false),
                                  Navigator.of(context).pop(),
                                }
                              : {
                                  RequestLocationService()
                                      .requestLocationAcknowledgment(
                                          locationData, false),
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
}
