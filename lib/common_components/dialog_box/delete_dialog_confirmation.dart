import 'package:at_client/at_client.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/models/event_and_location.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

Future<void> deleteDialogConfirmation(
    EventAndLocationHybrid hybridElement) async {
  return showDialog<void>(
    context: NavService.navKey.currentContext,
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
                  'Are you sure you want to delete ${eventAndLocationHybridDetails(hybridElement)}?',
                  style: CustomTextStyles().grey16,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                _dialogLoading
                    ? CircularProgressIndicator()
                    : CustomButton(
                        onTap: () async {
                          _setDialogState(() {
                            _dialogLoading = true;
                          });

                          if (hybridElement.type ==
                              NotificationModelType.EventModel) {
                            await EventKeyStreamService().deleteData(
                                hybridElement
                                    .eventKeyModel.eventNotificationModel);
                          } else {
                            await KeyStreamService().deleteData(hybridElement
                                .locationKeyModel.locationNotificationModel);
                          }

                          _setDialogState(() {
                            _dialogLoading = false;
                          });
                          Navigator.of(context).pop();
                        },
                        bgColor: Theme.of(context).primaryColor,
                        width: 164.toWidth,
                        height: 48.toHeight,
                        child: Text(
                          'Yes',
                          style: TextStyle(
                              fontSize: 15.toFont,
                              color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                      ),
                SizedBox(height: 5),
                _dialogLoading
                    ? SizedBox()
                    : CustomButton(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        bgColor: Theme.of(context).scaffoldBackgroundColor,
                        width: 140.toWidth,
                        height: 36.toHeight,
                        child: Text(
                          'No! Cancel this',
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

String eventAndLocationHybridDetails(EventAndLocationHybrid hybridElement) {
  if (hybridElement.type == NotificationModelType.EventModel) {
    return hybridElement.eventKeyModel.eventNotificationModel.title;
  }

  var _type = hybridElement.locationKeyModel.locationNotificationModel.key
          .contains('sharelocation')
      ? 'share location'
      : 'request location';

  String _mode;

  if (hybridElement.locationKeyModel.locationNotificationModel.key
      .contains('sharelocation')) {
    if (hybridElement
            .locationKeyModel.locationNotificationModel.atsignCreator ==
        AtClientManager.getInstance().atClient.getCurrentAtSign()) {
      _mode =
          'sent to ${hybridElement.locationKeyModel.locationNotificationModel.receiver}';
    } else {
      _mode =
          'received from ${hybridElement.locationKeyModel.locationNotificationModel.atsignCreator}';
    }
  } else {
    if (hybridElement
            .locationKeyModel.locationNotificationModel.atsignCreator !=
        AtClientManager.getInstance().atClient.getCurrentAtSign()) {
      _mode =
          'sent to ${hybridElement.locationKeyModel.locationNotificationModel.atsignCreator}';
    } else {
      _mode =
          'received from ${hybridElement.locationKeyModel.locationNotificationModel.receiver}';
    }
  }

  return '$_type $_mode';
}
