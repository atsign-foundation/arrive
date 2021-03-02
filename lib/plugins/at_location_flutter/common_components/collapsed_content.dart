import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/common_components/loading_widget.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/custom_toast.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/screens/create_event.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/utils/colors.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/utils/text_styles.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/common_components/participants.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/hybrid_model.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/location_service.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/send_location_notification.dart';
import 'package:flutter/material.dart';

class CollapsedContent extends StatefulWidget {
  Key key;
  bool expanded, isAdmin;
  LocationNotificationModel userListenerKeyword;
  EventNotificationModel eventListenerKeyword;
  AtClientImpl atClientInstance;
  CollapsedContent(this.key, this.expanded, this.isAdmin, this.atClientInstance,
      {this.userListenerKeyword, this.eventListenerKeyword});
  @override
  _CollapsedContentState createState() => _CollapsedContentState();
}

class _CollapsedContentState extends State<CollapsedContent> {
  bool isCreator, isSharing, isSharingEvent = false;
  @override
  void initState() {
    super.initState();
    isCreator = (LocationService().myData != null) &&
            (widget.eventListenerKeyword != null)
        ? widget.eventListenerKeyword.atsignCreator ==
            LocationService().myData.displayName
        : false;
    if (widget.userListenerKeyword != null)
      isSharing = widget.userListenerKeyword.isSharing;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.expanded ? 431 : 205,
        padding: EdgeInsets.fromLTRB(15, 3, 15, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AllColors().DARK_GREY,
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0),
            )
          ],
        ),
        child: (widget.eventListenerKeyword != null)
            ? forEvent(widget.expanded, context, onLocationOff: (void a) {
                // print('')
                // setState(() {});
              })
            : forUser(widget.expanded, context));
  }

  Widget forEvent(bool expanded, BuildContext context,
      {ValueChanged onLocationOff}) {
    if (widget.isAdmin) {
      if (LocationService().eventListenerKeyword.isSharing)
        isSharingEvent = true;
    } else {
      if (LocationService().eventListenerKeyword != null) {
        if (LocationService()
                .eventListenerKeyword
                .group
                .members
                .elementAt(0)
                .tags['isSharing'] ==
            true) {
          isSharingEvent = true;
        }
      }
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DraggableSymbol(),
          SizedBox(height: 3),
          StreamBuilder(
              stream: LocationService().eventStream,
              builder: (BuildContext context,
                  AsyncSnapshot<EventNotificationModel> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.data == null) {
                  return Text('No event found');
                } else
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              snapshot.data.title ?? 'Event Location',
                              style:
                                  Theme.of(context).primaryTextTheme.headline1,
                            ),
                            widget.isAdmin
                                ? InkWell(
                                    onTap: () {
                                      bottomSheet(
                                        context,
                                        CreateEvent(
                                          widget.atClientInstance,
                                          isUpdate: true,
                                          eventData: snapshot.data,
                                          onEventSaved: (event) {
                                            if (LocationService()
                                                    .onEventUpdate !=
                                                null) {
                                              LocationService()
                                                  .onEventUpdate(event);
                                              LocationService()
                                                  .eventSink
                                                  .add(event);
                                            }
                                          },
                                        ),
                                        SizeConfig().screenHeight * 0.9,
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Edit',
                                            style: CustomTextStyles().orange16),
                                        Icon(Icons.edit,
                                            color: AllColors().ORANGE)
                                      ],
                                    ),
                                  )
                                : SizedBox()
                          ],
                        ),
                        Text(
                          '${snapshot.data.atsignCreator}',
                          style: CustomTextStyles().black14,
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          dateToString(snapshot.data.event.date) ?? '',
                          style: CustomTextStyles().darkGrey14,
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          '${timeOfDayToString(snapshot.data.event.startTime)} - ${timeOfDayToString(snapshot.data.event.endTime)}' ??
                              'Event timings',
                          style: CustomTextStyles().darkGrey14,
                        ),
                        Divider(),
                        DisplayTile(
                            title:
                                '${snapshot.data.atsignCreator} and ${snapshot.data.group.members.length} more' ??
                                    'Event participants',
                            atsignCreator: snapshot.data.atsignCreator,
                            semiTitle: (snapshot.data.group.members.length == 1)
                                ? '${snapshot.data.group.members.length} person'
                                : '${snapshot.data.group.members.length} people',
                            number: snapshot.data.group.members.length,
                            subTitle:
                                'Share my location from ${timeOfDayToString(snapshot.data.event.startTime)} on ${dateToString(snapshot.data.event.date)}',
                            action: Transform.rotate(
                              angle: 5.8,
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: AllColors().ORANGE,
                                ),
                                child: Icon(
                                  Icons.send_outlined,
                                  color: AllColors().WHITE,
                                  size: 25,
                                ),
                              ),
                            )),
                      ],
                    ),
                  );
              }),
          StreamBuilder(
              stream: LocationService().atHybridUsersStream,
              builder: (context, AsyncSnapshot<List<HybridModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasError) {
                    return participants(() => null);
                  } else {
                    List<HybridModel> data = snapshot.data;
                    return participants(() => bottomSheet(
                        context,
                        Participants(
                          true,
                          data: data,
                          atsign: LocationService().atsignsAtMonitor,
                        ),
                        422));
                  }
                } else {
                  return participants(() => bottomSheet(
                      context,
                      Participants(
                        false,
                        atsign: LocationService().atsignsAtMonitor,
                      ),
                      422));
                }
              }),
          expanded
              ? Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(),
                      Text(
                        'Address',
                        style: CustomTextStyles().darkGrey14,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Flexible(
                        child: Text(
                          '${widget.eventListenerKeyword.venue.label}' ??
                              'Event location',
                          style: CustomTextStyles().darkGrey14,
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Share Location',
                            style: CustomTextStyles().darkGrey16,
                          ),
                          Switch(
                              value: isSharingEvent,
                              onChanged: (value) async {
                                LoadingDialog().show();
                                try {
                                  print(value);
                                  if (widget.isAdmin) {
                                    LocationService()
                                        .eventListenerKeyword
                                        .isSharing = value;
                                  } else {
                                    LocationService()
                                        .eventListenerKeyword
                                        .group
                                        .members
                                        .elementAt(0)
                                        .tags['isSharing'] = value;
                                  }

                                  print(
                                      'in collapsed content:${EventNotificationModel.convertEventNotificationToJson(LocationService().eventListenerKeyword)}');

                                  var result = await LocationService()
                                      .onEventExit(
                                          isSharing: value,
                                          keyType: widget.isAdmin
                                              ? ATKEY_TYPE_ENUM.CREATEEVENT
                                              : ATKEY_TYPE_ENUM
                                                  .ACKNOWLEDGEEVENT,
                                          eventData: LocationService()
                                              .eventListenerKeyword);
                                  print('share off:${result}');
                                  if (result == true) {
                                    // onLocationOff(value);
                                    setState(() {
                                      isSharingEvent = value;
                                    });

                                    if (widget.isAdmin) {
                                      LocationService().onEventUpdate(
                                          LocationService()
                                              .eventListenerKeyword);
                                    }
                                  } else
                                    CustomToast().show(
                                        'something went wrong , please try again.',
                                        context);
                                  LoadingDialog().hide();
                                } catch (e) {
                                  print(e);
                                  CustomToast().show(
                                      'something went wrong , please try again.',
                                      context);
                                  LoadingDialog().hide();
                                }
                              })
                        ],
                      ),
                      Divider(),
                      widget.isAdmin
                          ? SizedBox()
                          : Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (widget.eventListenerKeyword.group.members
                                          .elementAt(0)
                                          .tags['isExited'] ==
                                      false) {
                                    LoadingDialog().show();
                                    try {
                                      await LocationService().onEventExit(
                                          isExited: true,
                                          keyType: widget.isAdmin
                                              ? ATKEY_TYPE_ENUM.CREATEEVENT
                                              : ATKEY_TYPE_ENUM
                                                  .ACKNOWLEDGEEVENT);
                                      LoadingDialog().hide();
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      print(e);
                                      CustomToast().show(
                                          'something went wrong , please try again.',
                                          context);
                                      LoadingDialog().hide();
                                    }
                                  }
                                },
                                child: Text(
                                  widget.eventListenerKeyword.group.members
                                              .elementAt(0)
                                              .tags['isExited'] ==
                                          true
                                      ? 'Exited'
                                      : 'Exit Event',
                                  style: CustomTextStyles().orange16,
                                ),
                              ),
                            ),
                      widget.isAdmin ? SizedBox() : Divider(),
                      widget.isAdmin
                          ? Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (!widget
                                      .eventListenerKeyword.isCancelled) {
                                    LoadingDialog().show();
                                    try {
                                      var result = await LocationService()
                                          .onEventCancel();
                                      LoadingDialog().hide();
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      print(e);
                                      CustomToast().show(
                                          'something went wrong , please try again.',
                                          context);
                                      LoadingDialog().hide();
                                    }
                                  }
                                },
                                child: Text(
                                  widget.eventListenerKeyword.isCancelled
                                      ? 'Event Cancelled'
                                      : 'Cancel Event',
                                  style: CustomTextStyles().orange16,
                                ),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                )
              : SizedBox(
                  height: 2,
                )
        ]);
  }

  Widget forUser(bool expanded, BuildContext context) {
    bool amICreator = widget.userListenerKeyword.atsignCreator ==
        LocationService().getAtSign();
    DateTime to = widget.userListenerKeyword.to;
    String time;
    if (to != null)
      time = 'until ${timeOfDayToString(widget.userListenerKeyword.to)} today';
    else
      time = '';

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          amICreator ? DraggableSymbol() : SizedBox(height: 2),
          SizedBox(
            height: 3,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DisplayTile(
                        title: amICreator
                            ? '${widget.userListenerKeyword.receiver}'
                            : '${widget.userListenerKeyword.atsignCreator}',
                        showName: true,
                        atsignCreator: amICreator
                            ? '${widget.userListenerKeyword.receiver}'
                            : '${widget.userListenerKeyword.atsignCreator}',
                        subTitle: amICreator
                            ? '${widget.userListenerKeyword.receiver}'
                            : '${widget.userListenerKeyword.atsignCreator}'),
                    Text(
                      amICreator
                          ? 'This user does not share their location'
                          : '',
                      style: CustomTextStyles().grey12,
                    ),
                    Text(
                      amICreator
                          ? 'Sharing my location $time'
                          : 'Sharing their location $time',
                      style: CustomTextStyles().black12,
                    )
                  ],
                ),
              ),
              Transform.rotate(
                angle: 5.8,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: AllColors().ORANGE,
                  ),
                  child: Icon(
                    Icons.send_outlined,
                    color: AllColors().WHITE,
                    size: 25,
                  ),
                ),
              )
            ],
          ),
          expanded
              ? Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(),
                      amICreator
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Share my Location',
                                  style: CustomTextStyles().darkGrey16,
                                ),
                                Switch(
                                    value: isSharing,
                                    onChanged: (value) async {
                                      LoadingDialog().show();
                                      try {
                                        var result;
                                        print(
                                            "${LocationService().onShareToggle}");
                                        if (widget.userListenerKeyword.key
                                            .contains("sharelocation")) {
                                          result = await LocationService()
                                              .onShareToggle(
                                                  widget.userListenerKeyword,
                                                  isSharing: value);
                                        } else if (widget
                                            .userListenerKeyword.key
                                            .contains("requestlocation")) {
                                          result = await LocationService()
                                              .onShareToggle(
                                                  widget.userListenerKeyword,
                                                  true,
                                                  isSharing: value);
                                        }
                                        print('result $result');
                                        if (result) {
                                          if (!value) {
                                            SendLocationNotification().sendNull(
                                                widget.userListenerKeyword);
                                          }
                                          setState(() {
                                            isSharing = value;
                                          });
                                        } else {
                                          CustomToast().show(
                                              'some thing went wrong , try again.',
                                              context);
                                        }
                                        LoadingDialog().hide();
                                      } catch (e) {
                                        print(e);
                                        CustomToast().show(
                                            'something went wrong , please try again.',
                                            context);
                                        LoadingDialog().hide();
                                      }
                                    })
                              ],
                            )
                          : SizedBox(),
                      amICreator ? Divider() : SizedBox(),
                      amICreator
                          ? Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await LocationService().onRequest();
                                },
                                child: Text(
                                  'Request Location',
                                  style: CustomTextStyles().darkGrey16,
                                ),
                              ),
                            )
                          : SizedBox(),
                      amICreator ? Divider() : SizedBox(),
                      amICreator
                          ? Expanded(
                              child: InkWell(
                                onTap: () async {
                                  LoadingDialog().show();
                                  try {
                                    print(
                                        LocationService().onRemove.toString());
                                    var result = await LocationService()
                                        .onRemove(widget.userListenerKeyword);
                                    if (result) {
                                      SendLocationNotification()
                                          .sendNull(widget.userListenerKeyword);
                                      LoadingDialog().hide();

                                      Navigator.pop(context);
                                    } else {
                                      LoadingDialog().hide();

                                      CustomToast().show(
                                          'Something went wrong, try again.',
                                          context);
                                    }
                                  } catch (e) {
                                    print(e);
                                    CustomToast().show(
                                        'something went wrong , please try again.',
                                        context);
                                    LoadingDialog().hide();
                                  }
                                },
                                child: Text(
                                  'Remove Person',
                                  style: CustomTextStyles().orange16,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                )
              : SizedBox(
                  height: 2,
                )
        ]);
  }

  Widget participants(Function() onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 56),
      child: InkWell(
        onTap: onTap,
        child: Text(
          'See Participants',
          style: CustomTextStyles().orange14,
        ),
      ),
    );
  }
}
