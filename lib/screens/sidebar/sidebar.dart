import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:atsign_contacts/utils/init_contacts_service.dart';
import 'package:atsign_contacts/widgets/contacts_initials.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/services/location_notification_listener.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';
import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool state = false;
  Uint8List image;
  AtContact contact;
  AtContactsImpl atContact;
  String name;

  @override
  void initState() {
    super.initState();
    getEventCreator();
    state = false;
    getLocationSharing();
  }

  getLocationSharing() async {
    bool newState = await LocationNotificationListener().getShareLocation();
    setState(() {
      state = newState;
    });
  }

  getEventCreator() async {
    AtContact contact = await getAtSignDetails(ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        setState(() {
          image = Uint8List.fromList(intList);
        });
      }
      if (contact.tags != null && contact.tags['name'] != null) {
        String newName = contact.tags['name'].toString();
        setState(() {
          name = newName;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // state = Provider.of<ThemeProvider>(context, listen: false).isDark == true
    //     ? true
    //     : false;

    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding:
            EdgeInsets.symmetric(horizontal: 30.toWidth, vertical: 0.toHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 0.toWidth, vertical: 50.toHeight),
              child: Row(
                children: [
                  (image != null)
                      ? Image.memory(image, width: 50, height: 50)
                      : ContactInitial(
                          initials: ClientSdkService.getInstance()
                              .atClientServiceInstance
                              .atClient
                              .currentAtSign
                              .substring(1, 3)),
                  Flexible(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? 'Full Name',
                          style: CustomTextStyles().darkGrey16,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          ClientSdkService.getInstance()
                                  .atClientServiceInstance
                                  .atClient
                                  .currentAtSign ??
                              '@sign',
                          style: CustomTextStyles().darkGrey14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            iconText('Events', Icons.arrow_upward,
                () => SetupRoutes.push(context, Routes.EVENT_LOG)),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
              'Contacts',
              Icons.contacts_rounded,
              () async {
                ClientSdkService clientSdkService =
                    ClientSdkService.getInstance();
                String currentAtSign = await clientSdkService.getAtSign();
                return SetupRoutes.push(context, Routes.CONTACT_SCREEN,
                    arguments: {
                      'currentAtSign': currentAtSign,
                      'asSelectionScreen': false
                    });
              },
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
              'Groups',
              Icons.group,
              () async {
                ClientSdkService clientSdkService =
                    ClientSdkService.getInstance();
                String currentAtSign = await clientSdkService.getAtSign();
                return SetupRoutes.push(context, Routes.GROUP_LIST, arguments: {
                  'currentAtSign': currentAtSign,
                });
              },
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText('FAQ', Icons.question_answer,
                () => SetupRoutes.push(context, Routes.FAQS)),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
                'Terms and Conditions',
                Icons.text_format_outlined,
                () =>
                    SetupRoutes.push(context, Routes.TERMS_CONDITIONS_SCREEN)),
            SizedBox(
              height: 25.toHeight,
            ),
            SizedBox(
              height: 40.toHeight,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Dark Theme',
            //       style: CustomTextStyles().darkGrey16,
            //     ),
            //     Switch(
            //       value: state,
            //       onChanged: (value) {
            //         value
            //             ? Provider.of<ThemeProvider>(context, listen: false)
            //                 .setTheme(ThemeColor.Dark)
            //             : Provider.of<ThemeProvider>(context, listen: false)
            //                 .setTheme(ThemeColor.Light);

            //         setState(() {
            //           state = value;
            //         });
            //       },
            //     )
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location Sharing',
                  style: CustomTextStyles().darkGrey16,
                ),
                Switch(
                  value: state,
                  onChanged: (value) {
                    LocationNotificationListener().updateShareLocation(value);
                    setState(() {
                      state = value;
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 14.toHeight,
            ),
            Flexible(
                child: Text(
              'When you turn this on, everyone you have given access to can see  your location.',
              style: CustomTextStyles().darkGrey12,
            )),
            Expanded(
                child: Container(
              height: 0,
            )),
            iconText('Switch @sign', Icons.logout, () {}),
          ],
        ),
      ),
    );
  }

  Widget iconText(String text, IconData icon, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: AllColors().DARK_GREY,
          ),
          SizedBox(
            width: 15.toWidth,
          ),
          Flexible(
            child: Text(
              text,
              style: CustomTextStyles().darkGrey16,
            ),
          ),
        ],
      ),
    );
  }
}
