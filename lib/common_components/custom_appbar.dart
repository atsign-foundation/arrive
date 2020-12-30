import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackIcon, centerTitle, padding;
  final Widget leadingWidget, action;

  const CustomAppBar(
      {this.title,
      this.centerTitle = false,
      this.showBackIcon = false,
      this.padding = false,
      this.leadingWidget,
      this.action});
  @override
  Size get preferredSize => Size.fromHeight(60.toHeight);

  @override
  Widget build(BuildContext context) {
    // print(context.owner);
    return Padding(
      padding: EdgeInsets.only(right: (padding) ? 16.toWidth : 0),
      child: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context))
            : (leadingWidget != null)
                ? Container(alignment: Alignment.center, child: leadingWidget)
                : SizedBox(),
        centerTitle: centerTitle,
        titleSpacing: 0.0,
        title: title != null
            ? Text(
                title,
                style: Theme.of(context).appBarTheme.textTheme.headline1,
              )
            : SizedBox(),
        actions: [Center(child: action ?? null)],
      ),
    );
  }
}
