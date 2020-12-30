import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
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
  @override
  Widget build(BuildContext context) {
    state = Provider.of<ThemeProvider>(context, listen: false).isDark == true
        ? true
        : false;

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
                  CustomCircleAvatar(
                    size: 60,
                    image: AllImages().PERSON1,
                  ),
                  Flexible(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full Name',
                          style: CustomTextStyles().darkGrey16,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dark Theme',
                  style: CustomTextStyles().darkGrey16,
                ),
                Switch(
                  value: state,
                  onChanged: (value) {
                    value
                        ? Provider.of<ThemeProvider>(context, listen: false)
                            .setTheme(ThemeColor.Dark)
                        : Provider.of<ThemeProvider>(context, listen: false)
                            .setTheme(ThemeColor.Light);

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
