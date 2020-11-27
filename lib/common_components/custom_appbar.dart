import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackIcon;
  final Widget leadingWidget;
  final bool centerTitle;
  final Widget action;

  final double elevation;

  const CustomAppBar(
      {this.title,
      this.centerTitle = false,
      this.showBackIcon = false,
      this.leadingWidget,
      this.elevation = 0,
      this.action});
  @override
  Size get preferredSize => Size.fromHeight(60.toHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60.toHeight,
      elevation: elevation ?? 0,
      leadingWidth: (leadingWidget != null) ? 100.toWidth : 50.toWidth,
      leading: (showBackIcon)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AllColors().Black,
              ),
              onPressed: () {
                Navigator.pop(context);
              })
          : Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 16.toWidth),
              child: leadingWidget ?? null),
      centerTitle: centerTitle,
      title: Text(title, style: CustomTextStyles().black18),
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
