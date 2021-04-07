import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/common_components/tasks.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/common_components/text_tile_repeater.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/services/request_location_service.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';

import 'package:flutter/material.dart';

class ContactsBottomSheet extends StatefulWidget {
  final String atsign;
  ContactsBottomSheet(this.atsign);

  @override
  _ContactsBottomSheetState createState() => _ContactsBottomSheetState();
}

class _ContactsBottomSheetState extends State<ContactsBottomSheet> {
  bool isLoading = false;
  int minutes;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.toHeight,
      margin:
          EdgeInsets.symmetric(horizontal: 10.toWidth, vertical: 10.toHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Tasks(
                      task: 'Request Location',
                      icon: Icons.sync,
                      angle: (-3.14 / 2),
                      onTap: onRequestLocation),
                ),
                Expanded(
                  child: Tasks(
                      task: 'Share Location',
                      icon: Icons.person_add,
                      onTap: () async {
                        bottomSheet(
                            context,
                            TextTileRepeater(
                              title:
                                  'How long do you want to share your location for ?',
                              options: [
                                '30 mins',
                                '2 hours',
                                '24 hours',
                                'Until turned off'
                              ],
                              onChanged: (value) async {
                                minutes = (value == '30 mins'
                                    ? 30
                                    : (value == '2 hours'
                                        ? (2 * 60)
                                        : (value == '24 hours'
                                            ? (24 * 60)
                                            : null)));
                                onShareLocation();
                              },
                            ),
                            350,
                            onSheetCLosed: () {});
                      }),
                )
              ],
            ),
    );
  }

  onRequestLocation() async {
    setState(() {
      isLoading = true;
    });
    var result =
        await RequestLocationService().sendRequestLocationEvent(widget.atsign);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result[0] == true) {
      CustomToast().show('Location Request sent', context);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      providerCallback<HybridProvider>(NavService.navKey.currentContext,
          task: (provider) => provider.addNewEvent(BackendService.getInstance()
              .convertEventToHybrid(NotificationType.Location,
                  locationNotificationModel: result[1])),
          taskName: (provider) => provider.HYBRID_ADD_EVENT,
          showLoader: false,
          onSuccess: (provider) {});
    } else {
      CustomToast().show('Something went wrong , try again.', context);
      setState(() {
        isLoading = false;
      });
    }
  }

  onShareLocation() async {
    setState(() {
      isLoading = true;
    });

    var result = await LocationSharingService()
        .sendShareLocationEvent(widget.atsign, false, minutes: minutes);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (result[0] == true) {
      CustomToast().show('Share Location Request sent', context);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      providerCallback<HybridProvider>(NavService.navKey.currentContext,
          task: (provider) => provider.addNewEvent(HybridNotificationModel(
              NotificationType.Location,
              locationNotificationModel: result[1])),
          taskName: (provider) => provider.HYBRID_ADD_EVENT,
          showLoader: false,
          onSuccess: (provider) {});
    } else {
      CustomToast().show('some thing went wrong , try again.', context);
      setState(() {
        isLoading = false;
      });
    }
  }
}
