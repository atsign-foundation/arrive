import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final double width, height;
  final IconData icon;
  final Function onTap, onIconTap, onSubmitted;
  final Color iconColor;
  final bool isReadOnly;
  final ValueChanged<String> value;

  CustomInputField(
      {this.hintText = '',
      this.height = 50,
      this.width = 300,
      this.iconColor,
      this.icon,
      this.onTap,
      this.onIconTap,
      this.isReadOnly = false,
      this.onSubmitted,
      this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toWidth,
      height: height.toHeight,
      decoration: BoxDecoration(
        color: AllColors().INPUT_GREY_BACKGROUND,
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
              onTap: onTap ?? null,
              readOnly: isReadOnly,
              onChanged: (val) {
                value(val);
              },
              onSubmitted: (str) {
                if (onSubmitted != null) {
                  onSubmitted(str);
                }
              },
            ),
          ),
          icon != null
              ? InkWell(
                  onTap: onIconTap ?? onTap,
                  child: Icon(
                    icon,
                    color: iconColor ?? AllColors().DARK_GREY,
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
