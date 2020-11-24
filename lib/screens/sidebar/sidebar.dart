import 'package:atsign_location_app/utils/constants/colors.dart';
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
            EdgeInsets.symmetric(horizontal: 15.toWidth, vertical: 15.toHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style:
                  TextStyle(color: AllColors().DARK_GREY, fontSize: 16.toFont),
            ),
            SizedBox(
              height: 20.toHeight,
            ),
            Text(
              'FAQ',
              style:
                  TextStyle(color: AllColors().DARK_GREY, fontSize: 16.toFont),
            ),
            SizedBox(
              height: 14.toHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share Location',
                  style: TextStyle(
                      color: AllColors().DARK_GREY, fontSize: 16.toFont),
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
              'Enabling this will show your location in all the groups you have accepted to join.',
              style:
                  TextStyle(color: AllColors().DARK_GREY, fontSize: 12.toFont),
            )),
            Expanded(
                child: Container(
              height: 0,
            )),
            Text(
              'Switch Atsign',
              style:
                  TextStyle(color: AllColors().DARK_GREY, fontSize: 16.toFont),
            )
          ],
        ),
      ),
    );
  }
}
