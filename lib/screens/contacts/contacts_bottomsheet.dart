import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/tasks.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/common_components/text_tile_repeater.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
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
                      task: TextStrings.requestLocation,
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
                                  TextStrings.shareLocationDurationDescription,
                              options: [
                                TextStrings.k30mins,
                                TextStrings.k2hours,
                                TextStrings.k24hours,
                                TextStrings.untilTurnedOff
                              ],
                              onChanged: (value) async {
                                minutes = (value == '30 mins'
                                    ? 30
                                    : (value == '2 hours'
                                        ? (2 * 60)
                                        : (value == '24 hours'
                                            ? (24 * 60)
                                            : null)));
                              },
                            ),
                            350, onSheetCLosed: () async {
                          await onShareLocation();
                        });
                      }),
                )
              ],
            ),
    );
  }

  // ignore: always_declare_return_types
  onRequestLocation() async {
    setState(() {
      isLoading = true;
    });
    var result = await sendRequestLocationNotification(widget.atsign);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast().show(TextStrings.locationRequestSent, context, isSuccess: true);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show(TextStrings.somethingWentWrong +'${result.toString()}', context,
          isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }

  // ignore: always_declare_return_types
  onShareLocation() async {
    setState(() {
      isLoading = true;
    });

    var result = await sendShareLocationNotification(widget.atsign, minutes);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast()
          .show(TextStrings.shareLocationRequestSent, context, isSuccess: true);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show(TextStrings.somethingWentWrong, context, isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }
}
