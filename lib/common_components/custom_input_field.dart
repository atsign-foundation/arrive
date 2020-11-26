import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final bool isIcon;
  final double width, height;
  final IconData icon;
  final Function onTap;

  CustomInputField(
      {this.hintText = '',
      this.isIcon = false,
      this.height = 50,
      this.width = 300,
      this.icon,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toWidth,
      height: height.toHeight,
      decoration: BoxDecoration(
        color: AllColors().LIGHT_GREY,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hintText,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintStyle: TextStyle(color: AllColors().DARK_GREY),
              ),
              onTap: () {
                if (onTap != null) {
                  onTap();
                }
              },
            ),
          ),
          isIcon
              ? Icon(
                  icon,
                  color: AllColors().DARK_GREY,
                )
              : Container()
        ],
      ),
    );
  }
}
