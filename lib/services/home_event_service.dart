import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_location/atsign_location_plugin.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location_app/common_components/dialog_box/share_location_notifier_dialog.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/common_components/dialog_box/share_location_notifier_dialog.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';

class HomeEventService {
  HomeEventService._();
  static HomeEventService _instance = HomeEventService._();
  factory HomeEventService() => _instance;

  onLocationModelTap(LocationNotificationModel locationNotificationModel) {
    String currentAtsign = ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;

    locationNotificationModel.atsignCreator != currentAtsign
        ? (locationNotificationModel.isAccepted
            ? null
            : BackendService.getInstance().showMyDialog(
                locationNotificationModel.atsignCreator,
                locationData: locationNotificationModel))
        : null;
  }

  onEventModelTap(
      EventNotificationModel eventNotificationModel, EventProvider provider) {
    if (isActionRequired(eventNotificationModel) &&
        !eventNotificationModel.isCancelled) {
      return BackendService.getInstance().showMyDialog(
          eventNotificationModel.atsignCreator,
          eventData: eventNotificationModel);
    }

    Navigator.push(
      NavService.navKey.currentContext,
      MaterialPageRoute(
        builder: (context) => AtsignLocationPlugin(
            ClientSdkService.getInstance().atClientServiceInstance.atClient,
            () {
          provider.cancelEvent(eventNotificationModel);
        }, () {
          provider.actionOnEvent(
              eventNotificationModel, ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
              isExited: true);
        }, onEventUpdate: (EventNotificationModel eventData) {
          provider.mapUpdatedEventDataToWidget(eventData);
        }, eventListenerKeyword: eventNotificationModel),
      ),
    );
  }
}

bool isActionRequired(EventNotificationModel event) {
  if (event.isCancelled) return true;

  bool isRequired = true;
  String currentAtsign = ClientSdkService.getInstance()
      .atClientServiceInstance
      .atClient
      .currentAtSign;

  if (event.group.members.length < 1) return true;

  event.group.members.forEach((member) {
    if (member.tags['isAccepted'] != null &&
        member.tags['isAccepted'] == true &&
        member.atSign == currentAtsign) {
      isRequired = false;
    }
  });

  if (event.atsignCreator == currentAtsign) isRequired = false;

  return isRequired;
}

String getActionString(EventNotificationModel event) {
  if (event.isCancelled) return 'Cancelled';
  String label = 'Action required';
  String currentAtsign = ClientSdkService.getInstance()
      .atClientServiceInstance
      .atClient
      .currentAtSign;

  if (event.group.members.length < 1) return '';

  event.group.members.forEach((member) {
    if (member.tags['isExited'] != null &&
        member.tags['isExited'] == true &&
        member.atSign == currentAtsign) {
      label = 'Request declined';
    }
  });

  return label;
}
