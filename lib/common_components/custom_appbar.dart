import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackIcon, centerTitle;
  final Widget leadingWidget, action;

  const CustomAppBar(
      {this.title,
      this.centerTitle = false,
      this.showBackIcon = false,
      this.leadingWidget,
      this.action});
  @override
  Size get preferredSize => Size.fromHeight(60.toHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60.toHeight,
      leadingWidth: (leadingWidget != null)
          ? 100.toWidth
          : (showBackIcon)
              ? 50.toWidth
              : 0,
      leading: (showBackIcon)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AllColors().Black,
              ),
              onPressed: () => Navigator.pop(context))
          : Container(
              alignment: Alignment.center,
              // padding: leadingWidget != null
              //     ? EdgeInsets.only(left: 0.toWidth)
              //     : EdgeInsets.only(left: 0.toWidth),
              child: leadingWidget ?? null),
      centerTitle: centerTitle,
      title: title != null
          ? Text(title, style: CustomTextStyles().black18)
          : SizedBox(),
      actions: [
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: 16.toWidth),
            child: action ?? null)
      ],
      automaticallyImplyLeading: false,
      backgroundColor: AllColors().WHITE,
    );
  }
}
