import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool state = true;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
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
                  Stack(
                    children: [
                      Image.asset(
                        AllImages().PERSON1,
                        width: 60.toWidth,
                        height: 60.toHeight,
                        fit: BoxFit.cover,
                      ),
                    ],
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
            iconText('Events', Icons.arrow_upward, () {}),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText('Contacts', Icons.contacts_rounded, () {}),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText('Groups', Icons.group, () {
              SetupRoutes.push(context, Routes.GROUP_LIST);
            }),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText('FAQ', Icons.question_answer, () {}),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText('Terms and Conditions', Icons.text_format_outlined, () {}),
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
                  'Share Location',
                  style: CustomTextStyles().darkGrey16,
                ),
                Switch(
                    value: state,
                    onChanged: (value) {
                      setState(() {
                        state = value;
                      });
                    })
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
