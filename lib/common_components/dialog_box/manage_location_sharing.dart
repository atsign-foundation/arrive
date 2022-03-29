import 'package:at_client/at_client.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/services/home_event_service.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:atsign_location_app/common_components/loading_widget.dart';
import 'package:atsign_location_app/models/event_and_location.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atsign_location_app/common_components/custom_button.dart'
    // ignore: library_prefixes
    as customButton;

Future<void> manageLocationSharing() {
  var value = showDialog<void>(
    context: NavService.navKey.currentContext!,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return _ManageLocationSharing();
    },
  );
  return value;
}

class _ManageLocationSharing extends StatefulWidget {
  const _ManageLocationSharing({Key? key}) : super(key: key);

  @override
  __ManageLocationSharingState createState() => __ManageLocationSharingState();
}

class __ManageLocationSharingState extends State<_ManageLocationSharing> {
  List<LocationSharingData> allNotificationsSharingLocationFor = [];

  @override
  void initState() {
    calculateSharingLocationFor();
    super.initState();
  }

  void calculateSharingLocationFor() {
    allNotificationsSharingLocationFor = [];

    /// check events
    for (var _notification
        in Provider.of<LocationProvider>(context, listen: false)
            .allEventNotifications) {
      var _event = _notification.eventKeyModel!.eventNotificationModel!;
      if (!_event.isCancelled!) {
        var _myEventInfo = HomeEventService().getMyEventInfo(_event);
        if ((_myEventInfo != null) && (!_myEventInfo.isExited)) {
          allNotificationsSharingLocationFor.add(LocationSharingData(
            eventAndLocationHybrid: _notification,
            eventInfo: _myEventInfo,
            locationInfo: null,
          ));
        }
      }
    }

    /// check locations
    for (var _notification
        in Provider.of<LocationProvider>(context, listen: false)
            .allLocationNotifications) {
      var _locationData =
          _notification.locationKeyModel!.locationNotificationModel!;

      if (compareAtSign(_locationData.atsignCreator!,
          AtClientManager.getInstance().atClient.getCurrentAtSign()!)) {
        var _myLocationInfo = getMyLocationInfo(_locationData)!;
        if (_myLocationInfo.isAccepted) {
          allNotificationsSharingLocationFor.add(LocationSharingData(
            eventAndLocationHybrid: _notification,
            eventInfo: null,
            locationInfo: _myLocationInfo,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 20),
      content: SizedBox(
        width: SizeConfig().screenWidth * 0.8,
        height: allNotificationsSharingLocationFor.isNotEmpty ? 400 : 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            allNotificationsSharingLocationFor.isNotEmpty
                ? Text(
                    TextStrings.youAreCurrentlySharingYourLocationForThese,
                    style: CustomTextStyles().grey16,
                    textAlign: TextAlign.center,
                  )
                : Text(
                    TextStrings.youAreNotSharingYourLocationWithAnyone,
                    style: CustomTextStyles().grey16,
                    textAlign: TextAlign.center,
                  ),
            SizedBox(
                height: allNotificationsSharingLocationFor.isNotEmpty ? 30 : 0),
            allNotificationsSharingLocationFor.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                        itemCount: allNotificationsSharingLocationFor.length,
                        itemBuilder: (_context, _int) {
                          return locationSharingSwitch(
                              allNotificationsSharingLocationFor[_int]);
                        }),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget locationSharingSwitch(LocationSharingData _locationSharingData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          ' -  ' + textForLocationSharingSwitch(_locationSharingData)!,
          style: CustomTextStyles().darkGrey16,
        ),
        Switch(
          value: booleanForLocationSharingSwitch(_locationSharingData),
          onChanged: (value) async {
            await functionForLocationSharingSwitch(_locationSharingData, value);
          },
        ),
      ],
    );
  }

  String? textForLocationSharingSwitch(
      LocationSharingData _locationSharingData) {
    if (_locationSharingData.eventAndLocationHybrid.type ==
        NotificationModelType.EventModel) {
      return _locationSharingData
          .eventAndLocationHybrid.eventKeyModel!.eventNotificationModel!.title;
    }

    return _locationSharingData.eventAndLocationHybrid.locationKeyModel!
        .locationNotificationModel!.receiver;
  }

  bool booleanForLocationSharingSwitch(
      LocationSharingData _locationSharingData) {
    if (_locationSharingData.eventAndLocationHybrid.type ==
        NotificationModelType.EventModel) {
      return _locationSharingData.eventInfo!.isSharing;
    }

    return _locationSharingData.locationInfo!.isSharing;
  }

  Future<void> functionForLocationSharingSwitch(
      LocationSharingData _locationSharingData, bool _value) async {
    if (_locationSharingData.eventAndLocationHybrid.type ==
        NotificationModelType.EventModel) {
      await _changeEventLocationSharing(_locationSharingData, _value);
      return;
    }

    await _changeLocationSharing(_locationSharingData, _value);
  }

  Future<void> _changeEventLocationSharing(
      LocationSharingData _locationSharingData, bool _value) async {
    LoadingDialog().show(text: TextStrings.updating);

    var result = await EventKeyStreamService().actionOnEvent(
      _locationSharingData
          .eventAndLocationHybrid.eventKeyModel!.eventNotificationModel!,
      ATKEY_TYPE_ENUM.CREATEEVENT, // doesn't effect now
      isSharing: _value,
      isAccepted: true,
      isExited: false,
    );

    LoadingDialog().hide();
    if (result == true) {
      _locationSharingData.eventInfo = HomeEventService().getMyEventInfo(
          _locationSharingData
              .eventAndLocationHybrid.eventKeyModel!.eventNotificationModel!);

      setState(() {});
    } else {
      CustomToast().show(TextStrings.somethingWentWrongPleaseTryAgain, context,
          isError: true);
    }
  }

  Future<void> _changeLocationSharing(
      LocationSharingData _locationSharingData, bool _value) async {
    var locationNotificationModel = _locationSharingData
        .eventAndLocationHybrid.locationKeyModel!.locationNotificationModel;
    late bool result;

    if ((!_value) && (locationNotificationModel!.to == null)) {
      await removePerson(_locationSharingData);
      return;
    }

    LoadingDialog().show(text: TextStrings.updating);
    if (locationNotificationModel!.key!
        .contains(MixedConstants.SHARE_LOCATION)) {
      result = await SharingLocationService()
          .updateWithShareLocationAcknowledge(locationNotificationModel,
              isSharing: _value);
    } else if (locationNotificationModel.key!
        .contains(MixedConstants.REQUEST_LOCATION)) {
      result = await RequestLocationService().requestLocationAcknowledgment(
          locationNotificationModel, true,
          isSharing: _value);
    }
    LoadingDialog().hide();

    if (result) {
      _locationSharingData.locationInfo =
          getMyLocationInfo(locationNotificationModel);
      setState(() {});
    } else {
      CustomToast().show(TextStrings.somethingWentWrongPleaseTryAgain, context,
          isError: true);
    }
  }

  Future<void> removePerson(LocationSharingData _locationSharingData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (_context, _setDialogState) {
          var _dialogLoading = false;

          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 20),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TextStrings.areYouSureYouWantToRemove,
                    style: CustomTextStyles().grey16,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  _dialogLoading
                      ? CircularProgressIndicator()
                      : customButton.CustomButton(
                          onTap: () async {
                            await _dialogYesPressed(_locationSharingData);
                          },
                          bgColor: Theme.of(context).primaryColor,
                          width: 164.toWidth,
                          height: 48.toHeight,
                          child: Text(
                            TextStrings.yes,
                            style: TextStyle(
                                fontSize: 15.toFont,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          ),
                        ),
                  SizedBox(height: 5),
                  _dialogLoading
                      ? SizedBox()
                      : customButton.CustomButton(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          bgColor: Theme.of(context).scaffoldBackgroundColor,
                          width: 140.toWidth,
                          height: 36.toHeight,
                          child: Text(
                            TextStrings.noCancelThis,
                            style: TextStyle(
                                fontSize: 14.toFont,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _dialogYesPressed(
      LocationSharingData _locationSharingData) async {
    var locationNotificationModel = _locationSharingData
        .eventAndLocationHybrid.locationKeyModel!.locationNotificationModel!;
    late bool result;

    LoadingDialog().show(text: TextStrings.updating);
    if (locationNotificationModel.key!.contains('sharelocation')) {
      result =
          await SharingLocationService().deleteKey(locationNotificationModel);
    } else if (locationNotificationModel.key!.contains('requestlocation')) {
      result = await RequestLocationService()
          .sendDeleteAck(locationNotificationModel);
    }
    LoadingDialog().hide();

    if (result) {
      calculateSharingLocationFor();
      setState(() {});
      Navigator.of(context).pop();
    } else {
      CustomToast().show(TextStrings.somethingWentWrongPleaseTryAgain, context,
          isError: true);
    }
  }
}

class LocationSharingData {
  EventAndLocationHybrid eventAndLocationHybrid;
  LocationInfo? locationInfo; // for type location
  EventInfo? eventInfo; // for type event

  LocationSharingData({
    required this.eventAndLocationHybrid,
    required this.locationInfo,
    required this.eventInfo,
  });
}
